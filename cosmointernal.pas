unit cosmointernal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FF7Ed, StdCtrls, ComCtrls, BaseUtil, Buttons, PluginTypes;

type
  TfrmInternal = class(TForm)
    Tree: TTreeView;
    edtHelp: TEdit;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    edtText: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Status: TProgressBar;
    lblStatus: TLabel;
    btnRestore: TBitBtn;
    TreeImages: TImageList;
    procedure InitData(Data:TCosmoPlugin);
    procedure FormHide(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure edtTextChange(Sender: TObject);
  private
    { Private declarations }
    SSL:            TStringList;
    CurSL:          TStringList;
    CurIndex:       Integer;
    Plugin:         TCosmoPlugin;
  public
    { Public declarations }
    KernelFile:     String;
    procedure SetMsg(Msg:String);
  end;

var
  frmInternal: TfrmInternal;

{$R KERNEL.RES}

Const
  SRC_ORIG = 0;
  SRC_EDIT = 1;
  SRC_CAREFUL = 2;
Var
  Links: Array[0..17] of Integer =
    (8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7, -1, -1);
  Sources: Array[0..17] of Integer =
    (SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT,
      SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT,
      SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_EDIT, SRC_ORIG, SRC_EDIT);
  Images: Array[0..17] of Integer =
    (2, 3, 5, 6, 1, 0, 7, 5, 2, 3, 5, 6, 1, 0, 7, 5, -1, 4);
    {Access Arm Wpn Mag Sum Itm Gun Mat}


implementation

{$R *.DFM}

procedure FillArray(var Arr: Array of Integer; Spec:String);
var
Mx,I:    Integer;
begin
Mx := Min(High(Arr), Length(Spec)-1);
For I := Low(Arr) to Mx do
  If Spec[I+1] in ['0'..'9'] then
    Arr[I] := StrToInt(Spec[I+1])
  else if Spec[I+1] in ['A'..'Z'] then
    Arr[I] := Ord(Spec[I+1])-55
  else Arr[I] := -1;
end;

procedure TfrmInternal.InitData(Data:TCosmoPlugin);
var
Strm:     TStream;
Ch,Node:  TTreeNode;
Index:    Integer;
SL:       TStringList;
begin
CurSL := nil;
Plugin := Data;
Strm := Plugin.InputStream('KernelTree');
Tree.LoadFromStream(Strm);
Strm.Free;
Strm := Plugin.InputStream('KernelEditor');
SL := TStringList.Create;
SL.LoadFromStream(Strm);
Strm.Free;
FillArray(Links,SL.Values['Links']);
FillArray(Sources,SL.Values['Sources']);
FillArray(Images,SL.Values['Images']);
SL.Free;

Index := 0; Node := Tree.Items.GetFirstNode;
While Node<>nil do begin
  Node.ImageIndex := Images[Index];
  Node.SelectedIndex := Images[Index];
  Ch := Node.GetFirstChild;
  While Ch<>nil do begin
    Ch.ImageIndex := Images[Index];
    Ch.SelectedIndex := Images[Index];
    Ch := Ch.GetNextSibling;
  end;
  Inc(Index);
  Node := Node.GetNextSibling;
end;
end;

procedure TfrmInternal.FormHide(Sender: TObject);
var
I:  Integer;
begin
For I := SSL.Count-1 downto 0 do
  SSL.Objects[I].Free;
SSL.Free;
end;

procedure TfrmInternal.TreeChange(Sender: TObject; Node: TTreeNode);
var
Cur,Par:    TTreeNode;
Obj:        TStringList;
begin
If Tree.Selected=nil then Exit;
Cur := Tree.Selected;
Par := Cur.Parent;
CurSL := nil;
If Par=nil then Exit;
If Cur.Text='' then begin
  edtText.Text := ''; edtText.Enabled := False;
  edtHelp.Text := 'Cosmo can''t edit this yet...';
  Exit;
end;
edtText.Enabled := True;
Obj := TStringList(SSL.Objects[Par.Index]);
CurSL := Obj; CurIndex := Cur.Index;
edtText.Text := Obj[Cur.Index];
If Links[Par.Index]=-1 then edtHelp.Text := ''
  else begin
    Obj := TStringList(SSL.Objects[Links[Par.Index]]);
    edtHelp.Text := Obj[Cur.Index];
  end;
end;

procedure TfrmInternal.FormShow(Sender: TObject);
var
Fil,Tmp,Src:    TMemoryStream;
Old,I:          Integer;
First,W,W2:     Word;
S:              String;
T:              TextFile;
B:              Byte;
Obj:            TStringList;
P:              Pointer;
begin
SSL := TStringList.Create;
Tmp := TMemoryStream.Create;
Tmp.LoadFromFile(KernelFile);
Fil := Plugin.LZS_Decompress(Tmp);
Tmp.Free;
Fil.Position :=0;
//AssignFile(T,'C:\temp\kernel.txt');
//Rewrite(T);
While Fil.Position < (Fil.Size-4) do begin
Fil.ReadBuffer(I,4);
Obj := TStringList.Create;
SSL.AddObject('Group',Obj);
Tmp := TMemoryStream.Create;
Tmp.CopyFrom(Fil,I);
Tmp.Position := 0;
Src := TMemoryStream.Create;
Tmp.ReadBuffer(W,2);
First := W;
//Writeln(T,'Text group');
While Tmp.Position < First do begin
  W2 := W;
  Tmp.ReadBuffer(W,2);
  Old := Tmp.Position;
  Tmp.Position := W2;
  Src.Clear;
  Src.Position := 0;
  Src.CopyFrom(Tmp,W-W2);
  Src.Position := 0;
  S := (FF7DecodeTextS(Src));
  If BeginsWith(S,'[TRIANGLE]"') then Delete(S,1,11);
  If EndsWith(S,StPC[$FF]) then
    Delete(S,Length(S)-Length(StPC[$FF])+1,Length(StPC[$FF]));
  P := Pointer( Word( Src.Size and $FFFF ) );
  Obj.AddObject(S,P);
//  Writeln(T,'  '+S);
  Tmp.Position := Old;
end;
Tmp.Position := W;
Src.Clear;
Repeat
  Tmp.ReadBuffer(B,1);
  Src.WriteBuffer(B,1);
until B=$FF;
  S := (FF7DecodeTextS(Src));
  If BeginsWith(S,'[TRIANGLE]"') then Delete(S,1,11);
  If EndsWith(S,StPC[$FF]) then
    Delete(S,Length(S)-Length(StPC[$FF])+1,Length(StPC[$FF]));
//  Writeln(T,'  '+S);
  Obj.Add(S);
Src.Free;
Tmp.Free;
end;

I := GetFileAttributes(PChar(KernelFile));
If (I and FILE_ATTRIBUTE_READONLY)<>0 then
  SetFileAttributes(PChar(KernelFile),I-FILE_ATTRIBUTE_READONLY);

//CloseFile(T);
end;

procedure TfrmInternal.SetMsg(Msg:String);
begin
lblStatus.Caption := Msg;
lblStatus.Refresh;
end;

procedure Updater(Cur,Max:Integer);
begin
If frmInternal.Status.Max<>Max then frmInternal.Status.Max := Max;
frmInternal.Status.Position := Cur;
end;

procedure TfrmInternal.btnSaveClick(Sender: TObject);
var
Txt,Section,OrigSect,Orig,Dst,Fil:  TMemoryStream;
J,Cnt,I:                            Integer;
SL:                                 TStringList;
WTmp,Last,W:                        Word;
B:                                  Byte;
Index:                              TList;
begin
//backup kernel
CopyFile(PChar(KernelFile),PChar(ExtractFilePath(KernelFile)+'KERNEL2.BAK'),True);

SetMsg('Opening...');
Dst := TMemoryStream.Create;
Dst.LoadFromFile(KernelFile);
Orig := Plugin.LZS_Decompress(Dst);
Orig.Position := 0;
Dst.Clear;
OrigSect := TMemoryStream.Create;
Section := TMemoryStream.Create;
Index := TList.Create;
Cnt := 0;
For I := 0 to SSL.Count-1 do
  Inc(Cnt,TStringList(SSL.Objects[I]).Count);
Status.Max := Cnt;
SetMsg('Compiling...');
For I := 0 to SSL.Count-1 do begin
  SL := TStringList(SSL.Objects[I]);
  Orig.ReadBuffer(Cnt,4);
  OrigSect.Clear;
  OrigSect.CopyFrom(Orig,Cnt);
  OrigSect.Position := 0;

  Case Sources[I] of
    SRC_ORIG: begin
        Dst.WriteBuffer(Cnt,4);
        Dst.CopyFrom(OrigSect,Cnt);
        Status.StepBy(SL.Count);
      end;
    SRC_EDIT: begin
        Index.Clear;
        Section.Clear;
        Cnt := 0;
        For J := 0 to SL.Count-2 do begin
          Txt := FF7EncodeTextQS(SL[J]);
          Index.Add(Pointer(Cnt));
          Inc(Cnt,Txt.Size);
          Section.CopyFrom(Txt,0);
          Txt.Free;
          Status.StepIt;
        end;
        Txt := FF7EncodeTextQS(SL[SL.Count-1]);
    //    Inc(Cnt,Txt.Size);
        Section.CopyFrom(Txt,0);
        B := $FF;
        Section.WriteBuffer(B,1);
        Txt.Free;
    {    B := 0;
        Section.WriteBuffer(B,1);}
        Index.Add(Pointer(Cnt));
        J := Section.Size + 2*Index.Count;
        Dst.WriteBuffer(J,4);
        For J := 0 to Index.Count-1 do begin
          W := Word(Index[J]);
          Inc(W,2*Index.Count);
          Dst.WriteBuffer(W,2);
        end;
        Dst.CopyFrom(Section,0);
      end;
    SRC_CAREFUL: begin
        Section.Clear;
        Index.Clear;
        OrigSect.ReadBuffer(W,2);
        WTmp := SL.Count*2;
        For J := 0 to SL.Count-1 do begin
          Last := W;
          If J=SL.Count-1 then W := OrigSect.Size
          else begin
            OrigSect.Position := (J+1)*2;
            OrigSect.ReadBuffer(W,2);
          end;
          Cnt := Integer(SL.Objects[J]);
          If (Cnt and $10000)=0 then begin
            OrigSect.Position := Last;
            Section.CopyFrom(OrigSect,W-Last);
            Index.Add(Pointer(WTmp));
            Inc(WTmp,Cnt and $FFFF);
          end else begin
            Txt := FF7EncodeTextQS(SL[J]);
            Index.Add(Pointer(WTmp));
            Inc(WTmp,Txt.Size);
            Section.CopyFrom(Txt,0);
            Txt.Free;
          end;
          Status.StepIt;
        end;
        Cnt := Section.Size + 2*Index.Count;
        Dst.WriteBuffer(Cnt,4);
        For J := 0 to Index.Count-1 do begin
          W := Word(Index[J]);
          Dst.WriteBuffer(W,2);
        end;
        Dst.CopyFrom(Section,0);
    end;

  end;
end;
Index.Free;
Section.Free;
Orig.Free;
OrigSect.Free;
//LzPointerSeek := DodgySeek0;
//Callback := Updater;
SetMsg('Compressing...');
Fil := Plugin.LZS_Compress(Dst);
Fil.SaveToFile(KernelFile);
Fil.Free;
Dst.Free;
SetMsg('Done!');
end;

procedure TfrmInternal.btnRestoreClick(Sender: TObject);
begin
CopyFile(PChar(ExtractFilePath(KernelFile)+'KERNEL2.BAK'),PChar(KernelFile),False);
SetFileAttributes(PChar(KernelFile),FILE_ATTRIBUTE_NORMAL);
FormHide(Sender);
FormShow(Sender);
end;

procedure TfrmInternal.edtTextChange(Sender: TObject);
var
P:      Pointer;
begin
If CurSL<>nil then begin
  CurSL[CurIndex] := edtText.Text;
  P := Pointer($10000 or Word(Length(edtText.Text) and $FFFF));
  CurSL.Objects[CurIndex] := P;
end;
end;

end.
