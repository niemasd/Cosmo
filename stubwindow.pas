unit stubwindow;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, LGPStruct, FF7Edit, FFLzs;


type
  TfrmStubWindow = class(TForm)
    Label1: TLabel;
    lblAbout: TLabel;
    GroupBox1: TGroupBox;
    edtTarget: TEdit;
    btnTarget: TButton;
    opnFLevel: TOpenDialog;
    lblMsg: TLabel;
    Progress: TProgressBar;
    btnBegin: TBitBtn;
    btnCancel: TBitBtn;
    procedure btnBeginClick(Sender: TObject);
    procedure btnTargetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Src:  TMemoryStream;
  end;

var
  frmStubWindow: TfrmStubWindow;

implementation

{$R *.DFM}

procedure Msg(M:String);
begin
frmStubWindow.lblMsg.Caption := M;
frmStubWindow.lblMsg.Refresh;
end;

procedure Prog(Cur,Max:Integer);
begin
If frmStubWindow.Progress.Max <> Max then
  frmStubWindow.Progress.Max := Max;
frmStubWindow.Progress.Position := Cur;
end;

procedure ApplyPatch(Src:TMemoryStream;Tgt:String);
var
Raw:        TRawLGPFile;
Lvl:        TFF7Level;
LGP:        TLGPFile;
Tmp,Mem,Pat:TMemoryStream;
I,J:        Integer;
Tbl:        TLGP_TableEntry;
Ent:        TLGP_Entry;
begin
Pat := LzsMemDecompress(Src);
Raw := TRawLGPFile.CreateFromFile(Tgt);
LGP := TLGPFile.CreateFromStream(Pat,False);
Lvl := TFF7Level.Create;
Tmp := TMemoryStream.Create;
Mem := TMemoryStream.Create;
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


procedure TfrmStubWindow.btnBeginClick(Sender: TObject);
begin
LzPointerSeek := DodgySeekQhimm;
If Not FileExists(edtTarget.Text) then ShowMessage('Select a file first!')
 else ApplyPatch(Src,edtTarget.Text);
end;

procedure TfrmStubWindow.btnTargetClick(Sender: TObject);
begin
If opnFLevel.Execute then edtTarget.Text := opnFLevel.Filename; 
end;

end.
