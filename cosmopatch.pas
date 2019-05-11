unit cosmopatch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, FF7Edit, FFLzs, LGPStruct, BaseUtil, ExtCtrls,
  FiceStream, CosmoUtil;

type
  TfrmCosmoPatch = class(TForm)
    pageMain: TPageControl;
    tabMake: TTabSheet;
    tabApply: TTabSheet;
    GroupBox1: TGroupBox;
    edtOriginal: TEdit;
    btnSelOriginal: TButton;
    GroupBox2: TGroupBox;
    edtAltered: TEdit;
    btnSelAltered: TButton;
    btnGo: TBitBtn;
    btnClose: TBitBtn;
    lstMsgs: TListBox;
    GroupBox3: TGroupBox;
    edtOriginalApply: TEdit;
    btnSelOriginalApply: TButton;
    GroupBox4: TGroupBox;
    edtPatch: TEdit;
    btnSelPatch: TButton;
    opnFLevel: TOpenDialog;
    opnLGP: TOpenDialog;
    Progress: TProgressBar;
    savPat: TSaveDialog;
    tabSelfExe: TTabSheet;
    opnPat: TOpenDialog;
    GroupBox5: TGroupBox;
    btnSelSrcPatch: TButton;
    edtSrcPatch: TEdit;
    GroupBox6: TGroupBox;
    edtDesc: TEdit;
    radStub: TRadioGroup;
    savEXE: TSaveDialog;
    procedure btnGoClick(Sender: TObject);
    procedure btnSelOriginalClick(Sender: TObject);
    procedure btnSelAlteredClick(Sender: TObject);
    procedure btnSelOriginalApplyClick(Sender: TObject);
    procedure btnSelPatchClick(Sender: TObject);
    procedure btnSelSrcPatchClick(Sender: TObject);
  private
    { Private declarations }
    procedure DoCreate;
    procedure DoApply;
    procedure DoConvert;
    procedure Msg(M:String);
  public
    { Public declarations }
  end;

var
  frmCosmoPatch: TfrmCosmoPatch;
  procedure Prog(Cur,Max:Integer);

implementation

{$R *.DFM}

Uses TxtEdt;

procedure TfrmCosmoPatch.DoCreate;
var
Orig,Alter:       TFF7Level;
OrigL,AlterL:     TLGPFile;
OrigF,AlterF:     TFileStream;
Mem,Diff:         TMemoryStream;
I,J:              Integer;
Entry:            TLGP_Entry;
TPath:            String;
begin
If Not savPat.Execute then Exit;
TPath := TempPath+'COSMOTMP';
{$I-}
MkDir(TPath);
If IOResult<>0 then begin
{$I-}
  Msg('Couldn''t make folder '+TPath+' - aborting.');
  ShowMessage('Cosmo couldn''t make the folder '+TPath+'. Make sure this folder does not exist already!');
  Exit;
end;
{$I-}

OrigL := TLGPFile.CreateFromFile(edtOriginal.Text,False);
AlterL := TLGPFile.CreateFromFile(edtAltered.Text,False);
Mem := TMemoryStream.Create;
OrigF := TFileStream.Create(edtOriginal.Text,fmOpenRead or fmShareDenyNone);
AlterF := TFileStream.Create(edtAltered.Text,fmOpenRead or fmShareDenyNone);
Orig := TFF7Level.Create;
Alter := TFF7Level.Create;

For I := 0 to OrigL.NumFiles-1 do begin
  Entry := OrigL.Entry[I];
  J := AlterL.EntryIndex[Entry.FileName];
  If J=-1 then Msg('File '+Entry.FileName+' in original LGP has no match in altered!')
  else begin
    Msg('File '+Entry.Filename);
    Mem.Clear;
    ExtractS(OrigF,Entry,Mem);
    Orig.LoadFromStream(Mem);
    Mem.Clear;
    Entry := AlterL.Entry[J];
    ExtractS(AlterF,Entry,Mem);
    Alter.LoadFromStream(Mem);
    Diff := Alter.MakeDiff(Orig);
    If Diff<>nil then begin
      Msg('File '+Entry.FileName+' changed - saving diff');
      Diff.SaveToFile(TPath+'\'+Entry.FileName);
      Diff.Free;
    end;
  end;
  Prog(I,OrigL.NumFiles);
end;
AlterL.Free;
OrigL.Free;
Orig.Free;
Alter.Free;
AlterF.Free;
OrigF.Free;

Msg('Completing diff scan. Compiling into patch...');

Progress := @Prog;
LGP_Create(TPath,savPat.Filename,True,False);
Msg('Compressing patch...');
Mem.Clear;
Mem.LoadFromFile(savPat.Filename);
Diff := DodgyCompressSO(Mem);
Mem.Free;
Diff.SaveToFile(savPat.Filename);
Diff.Free;
RmDir(TPath);
Msg('Done!');
end;

procedure TfrmCosmoPatch.DoApply;
var
Raw:        TRawLGPFile;
Lvl:        TFF7Level;
LGP:        TLGPFile;
Tmp,Mem,Pat:TMemoryStream;
I,J:        Integer;
Tbl:        TLGP_TableEntry;
Ent:        TLGP_Entry;
begin
Mem := TMemoryStream.Create;
Mem.LoadFromFile(edtPatch.Text);
Pat := LzsMemDecompress(Mem);
Mem.Clear;
Raw := TRawLGPFile.CreateFromFile(edtOriginalApply.Text);
LGP := TLGPFile.CreateFromStream(Pat,False);
Lvl := TFF7Level.Create;
Tmp := TMemoryStream.Create;
For I := 0 to Raw.NumEntries-1 do begin
  Tbl := Raw.TableEntry[I];
  J := LGP.EntryIndex[Tbl.Filename];
  If J<>-1 then begin
    Msg('Patching '+Tbl.Filename);
    Ent := LGP.Entry[J];
    Mem.Clear;
    Raw.Extract(I,Mem);
    Lvl.LoadFromStream(Mem);
    ExtractS(Pat,Ent,Tmp);
    Tmp.Position := 0;
    Lvl.ApplyDiff(Tmp);
    Mem.Clear; Tmp.Clear;
    Msg('Updating LGP for '+Tbl.Filename);
    Lvl.SaveToStream(Mem);
    Raw.UpdateFile(I,Mem);
    Mem.Clear;
  end;
  Prog(I,Raw.NumEntries);
end;
Mem.Free;
Lvl.Free;
Tmp.Free;
Pat.Free;
LGP.Free;
Raw.Free;
Msg('Done!');
end;

procedure TfrmCosmoPatch.DoConvert;
var
Pat,Output:         TMemoryStream;
Stub:               TStream;
Desc:               Array[0..63] of Char;
I:                  Integer;
begin
If not savExe.Execute then Exit;
Msg('Loading data...');
Case radStub.ItemIndex of
  0: Stub := InputStream('STUBSML.BIN');
  1: Stub := InputStream('STUBLRG.BIN');
end;
Pat := TMemoryStream.Create;
Pat.LoadFromFile(edtSrcPatch.Text);
Output := TMemoryStream.Create;
Msg('Compiling EXE...');
Output.CopyFrom(Stub,0);
Output.CopyFrom(Pat,0);
I := Stub.Size;
Output.WriteBuffer(I,4);
StrPCopy(Desc,edtDesc.Text);
Output.WriteBuffer(Desc,64);
Output.SaveToFile(savExe.Filename);
Output.Free;
Pat.Free;
Stub.Free;
Msg('Done!');
end;

procedure TfrmCosmoPatch.Msg(M:String);
begin
lstMsgs.Items.Add(M);
lstMsgs.ItemIndex := lstMsgs.Items.Count-1;
lstMsgs.Refresh;
end;

procedure Prog(Cur,Max:Integer);
begin
If frmCosmoPatch.Progress.Max<>Max then frmCosmoPatch.Progress.Max := Max;
frmCosmoPatch.Progress.Position := Cur;
end;

procedure TfrmCosmoPatch.btnGoClick(Sender: TObject);
begin
lstMsgs.Items.Clear;
frmTextView.mnuClose.Click;
If pageMain.ActivePage=tabMake then DoCreate
  else If pageMain.ActivePage=tabApply then DoApply
    else DoConvert;
end;

procedure TfrmCosmoPatch.btnSelOriginalClick(Sender: TObject);
begin
If opnFLevel.Execute then edtOriginal.Text := opnFLevel.Filename;
end;

procedure TfrmCosmoPatch.btnSelAlteredClick(Sender: TObject);
begin
If opnFLevel.Execute then edtAltered.Text := opnFLevel.Filename;
end;

procedure TfrmCosmoPatch.btnSelOriginalApplyClick(Sender: TObject);
begin
If opnFLevel.Execute then edtOriginalApply.Text := opnFLevel.Filename;
end;

procedure TfrmCosmoPatch.btnSelPatchClick(Sender: TObject);
begin
If opnLGP.Execute then edtPatch.Text := opnLGP.Filename;
end;

procedure TfrmCosmoPatch.btnSelSrcPatchClick(Sender: TObject);
begin
If opnPat.Execute then edtSrcPatch.Text := opnPat.Filename;
end;

end.
