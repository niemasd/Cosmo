unit cosmosearch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, FF7Edit, LGPStruct, DebugLog,
  BaseUtil, PluginTypes, CosmoUtil, FF7Types;

type
  TfrmSearchReplace = class(TForm)
    radSearchIn: TRadioGroup;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtSearch: TEdit;
    Label2: TLabel;
    edtReplace: TEdit;
    btnAdd: TButton;
    btnRemove: TButton;
    lstItems: TListView;
    btnScan: TBitBtn;
    btnClose: TBitBtn;
    ProgAll: TProgressBar;
    lblMsg: TLabel;
    chkCase: TCheckBox;
    GroupBox2: TGroupBox;
    edtMask: TEdit;
    chkConfirm: TCheckBox;
    btnMask: TButton;
    procedure btnRemoveClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnMaskClick(Sender: TObject);
  private
    { Private declarations }
    Exclusions:       TStringList;
    function ProcessLevel(Lvl:TFF7Level):Boolean;
  public
    { Public declarations }
    CurFile:        String;
    Data:           TCosmoPlugin;
  end;

var
  frmSearchReplace: TfrmSearchReplace;

implementation

{$R *.DFM}
{$R EXCLUSIONS.RES}

Uses TxtEdt;

procedure TfrmSearchReplace.btnRemoveClick(Sender: TObject);
begin
If lstItems.Selected <> nil then
  lstItems.Selected.Delete;
end;

procedure TfrmSearchReplace.btnAddClick(Sender: TObject);
begin
If (edtReplace.Text<>'') and (edtSearch.Text<>'') then
  With lstItems.Items.Add do begin
    Caption := edtSearch.Text;
    Subitems.Add(edtReplace.Text);
  end;
end;

function TfrmSearchReplace.ProcessLevel(Lvl:TFF7Level):Boolean;
var
I,J,K:    Integer;
Item:     TFF7TextItem;
S,S2:     String;
Conf:     Boolean;
begin
Result := False;
Conf := chkConfirm.Checked;
For I := 0 to Lvl.NumTextItems-1 do begin
  Item := Lvl.TextItems[I];
  If radSearchIn.ItemIndex <> 1 then begin //search in text
    For J := 0 to lstItems.Items.Count-1 do begin
      If chkCase.Checked then begin
        S := Item.Text; S2 := lstItems.Items[J].Caption;
      end else begin
        S := Uppercase(Item.Text); S2 := Uppercase(lstItems.Items[J].Caption);
      end;
      K := Pos(S2,S);
      If K<>0 then
        If (Not Conf) or (MessageDlg('In text:'#13#13+Item.Name+#13+Item.Text+#13#13+' change '+S2+' to '+lstItems.Items[J].Subitems[0]+'?',mtConfirmation,[mbYes,mbNo],0)=mrYes) then
          While K<>0 do begin
            Item.Text := Copy(Item.Text,1,K-1) + lstItems.Items[J].Subitems[0] + Copy(Item.Text,K+Length(S2),Length(S));
            Result := True;
            If chkCase.Checked then S := Item.Text else S := Uppercase(Item.Text);
            K := Pos(S2,S);
          end;
    end;
  end;
  If radSearchIn.ItemIndex <> 0 then begin //search in name
    For J := 0 to lstItems.Items.Count-1 do begin
      If chkCase.Checked then begin
        S := Item.Name; S2 := lstItems.Items[J].Caption;
      end else begin
        S := Uppercase(Item.Name); S2 := Uppercase(lstItems.Items[J].Caption);
      end;
      K := Pos(S2,S);
      If K<>0 then
        If (Not Conf) or (MessageDlg('In text:'#13+Item.Name+#13+Item.Text+#13+' change '+S2+' to '+lstItems.Items[J].Subitems[0]+'?',mtConfirmation,[mbYes,mbNo],0)=mrYes) then
          While K<>0 do begin
            Item.Name := Copy(Item.Name,1,K-1) + lstItems.Items[J].Subitems[0] + Copy(Item.Name,K+Length(S2),Length(S));
            Result := True;
            If chkCase.Checked then S := Item.Name else S := Uppercase(Item.Name);
            K := Pos(S2,S);
          end;
    end;
  end;
  Lvl.TextItems[I] := Item;
end;
end;

procedure TfrmSearchReplace.btnScanClick(Sender: TObject);
var
RawLGP:       TRawLGPFile;
SR:           TSearchRec;
Tbl:          TLGP_TableEntry;
J,MS,Sz,I,Cnt,Scan,Empty:     Integer;
Mem:          TMemoryStream;
Lvl:          TFF7Level;
Details:      TStringList;
Skip:         Boolean;
begin
If GetFileRec(CurFile,SR) then Sz := SR.Size else Sz := 0;
If edtMask.Text='' then begin
  ShowMessage('You must enter a file mask. Try ''*'' for all files.');
  Exit;
end;
If lstItems.Items.Count=0 then begin
  ShowMessage('You must first add at least one search/replace pair to the list.');
  Exit;
end;
MS := GetTickCount;
lblMsg.Caption := 'Initialising...';
lblMsg.Refresh;
frmTextView.ClearList(True);
RawLGP := TRawLGPFile.CreateFromFile(CurFile);
ProgAll.Max := RawLGP.NumEntries;
ProgAll.Position := 0; Cnt := 0; Scan := 0; Empty := 0;
//Callback := Updater;
Mem := TMemoryStream.Create;
Lvl := TFF7Level.Create;
Details := TStringList.Create;
Data.Log('Starting search/replace...');
For I := 0 to RawLGP.NumEntries-1 do begin
  ProgAll.Position := I;
  Tbl := RawLGP.TableEntry[I];
  lblMsg.Caption := Tbl.Filename;
  lblMsg.Refresh;
  If Not MatchWildcard(edtMask.Text,Tbl.Filename) then Continue;
  Skip := False;
  For J := 0 to Exclusions.Count-1 do
    If (Exclusions[J]<>'') and MatchWildcard(Uppercase(Exclusions[J]),Uppercase(Tbl.Filename)) then Skip := True;
  If Skip then Continue;
  Inc(Scan);
  Mem.Clear;
  RawLGP.Extract(I,Mem);
  Lvl.LoadFromStream(Mem);
  If Lvl.NumTextItems = 0 then Inc(Empty);
  If ProcessLevel(Lvl) then begin
    Data.Log('File '+Tbl.Filename+' changed - updating LGP');
    Inc(Cnt);
    Lvl.MidiIndex := $FF; //don't change midi
    lblMsg.Caption := Tbl.Filename+' - compressing';
    lblMsg.Refresh;
    Mem.Clear;
    Lvl.SaveToStream(Mem);
    RawLGP.UpdateFile(I,Mem);
    Details.Add(Tbl.Filename+' - edited and updated');
  end else
    If Lvl.NumTextItems=0 then Details.Add(Tbl.Filename+' - error opening text')
      else Details.Add(Tbl.Filename+' - not changed');
end;
ProgAll.Position := ProgAll.Max;
Data.Log('Search/replace done');
Lvl.Free;
Mem.Free;
MS := GetTickCount - MS;
ShowMessage('Search/Replace is complete.'#13+
            Format('Took %d:%.2d to process files',[ (MS div 60000), (MS div 1000) mod 60 ] )+#13+
            'Files in archive: '+IntToStr(RawLGP.NumEntries)+#13+
            'Files actually examined: '+IntToStr(Scan)+#13+
            'Files successfully opened: '+IntToStr(Scan-Empty)+#13+
            'Files actually edited/changed: '+IntToStr(Cnt));
RawLGP.Free;
Data.Log(Details.Text);
Details.Free;
If Sz <> 0 then
  If GetFileRec(CurFile,SR) then
    If SR.Size > (Sz * 11) div 10 then
      If MessageDlg('Archive has increased noticeably in size. Do you wish to pack the archive now?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
        LGP_Pack(CurFile);

end;

procedure TfrmSearchReplace.FormCreate(Sender: TObject);
begin
Exclusions := TStringList.Create;
end;

procedure TfrmSearchReplace.FormDestroy(Sender: TObject);
begin
Exclusions.Free;
end;

procedure TfrmSearchReplace.FormShow(Sender: TObject);
var
Strm:     TStream;
begin
Strm := Data.InputStream('Search_Exclusions');
Exclusions.LoadFromStream(Strm);
Data.Log('Search/Replace tool: '+IntToStr(Exclusions.Count)+' exclusions loaded');
Strm.Free;
end;

procedure TfrmSearchReplace.btnMaskClick(Sender: TObject);
begin
ShowMessage('This lets you specify which files to scan. Wildcard expressions (* and ?) are allowed.'#13+
            'For example, "a*" means all files beginning with a, "?????" is all files with 5 letters in the name.'#13+
            'In addition, the following files have been excluded automatically:'#13#13+
            Exclusions.Text); 
end;

end.
