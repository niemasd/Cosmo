unit txtedt;

//TODO: Implement PLUG_LOADFILE flag

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CosmoUtil, BaseUtil, ShellAPI, Registry, ComCtrls, DebugLog, FFLZs,
  LGPStruct, LGPContents, Menus, AboutCosmo, TB97, TB97Tlbr, TB97Ctls,
  ExtCtrls, IniFiles, FileCtrl, kapdlg, MPlayer, TB97Tlwn, FF7Types,
  ffctrl, CosmoIndex, FF7Edit, FiceStream, MessageFrm, PluginTypes;
  
{___$DEFINE TEMPDUMP}

{$R MIDIDATA.RES}

type

  TViewOption = (Scale14, Scale12, Scale11, Scale21, StretchAll, StretchRatio);

  TFriendlyFFPanel = class(TFFPanel)
  end;

  TfrmTextView = class(TForm)
    lstKey: TListBox;
    mmoText: TMemo;
    opnAllLGP: TOpenDialog;
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    mnuOptions: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuOpenlevel: TMenuItem;
    N1: TMenuItem;
    mnuSavechanges: TMenuItem;
    mnuMergelevelintoLGP: TMenuItem;
    N2: TMenuItem;
    mnuExit: TMenuItem;
    mnuRecalculateConstantly: TMenuItem;
    mnuSettextcode: TMenuItem;
    N3: TMenuItem;
    mnuRecalculateNow: TMenuItem;
    mnuSaveAsSeparate: TMenuItem;
    savAny: TSaveDialog;
    mnuCompression: TMenuItem;
    mnuNoCompression: TMenuItem;
    mnu8Bit: TMenuItem;
    mnu16bit: TMenuItem;
    Status: TStatusBar;
    dockTop: TDock97;
    dockLeft: TDock97;
    dockRight: TDock97;
    tbCosmoFiles: TToolbar97;
    btnSaveSeparate: TToolbarButton97;
    btnOpen: TToolbarButton97;
    btnLGPOpen: TToolbarButton97;
    btnSave: TToolbarButton97;
    btnMerge: TToolbarButton97;
    mnuToolbars: TMenuItem;
    mnuFlatbuttons: TMenuItem;
    mnuText: TMenuItem;
    N4: TMenuItem;
    mnuFiletoolbar: TMenuItem;
    mnuOpenfromsameLGP: TMenuItem;
    opnLGP: TOpenDialog;
    SelFolder: TFolderDialog;
    mnuSetFF7Folder: TMenuItem;
    mnuDodgyCompression: TMenuItem;
    tbCosmoMidi: TToolbar97;
    btnMIDIDesc: TToolbarButton97;
    popMIDI: TPopupMenu;
    mnuMIDIFilenames: TMenuItem;
    mnuMIDITitles: TMenuItem;
    mnuMIDIDescriptions: TMenuItem;
    cmbMIDI: TComboBox;
    dockBottom: TDock97;
    btnPlayMIDI: TToolbarButton97;
    Media: TMediaPlayer;
    mnuMiditoolbar: TMenuItem;
    winCosmoBack: TToolWindow97;
    imgBack: TImage;
    mnuBackgroundtoolbar: TMenuItem;
    popBackground: TPopupMenu;
    Resizewindowby1: TMenuItem;
    mnuStretchtowindow: TMenuItem;
    mnuStretchmaintainratio: TMenuItem;
    mnuStretch14: TMenuItem;
    mnuStretch12: TMenuItem;
    mnuStretch11: TMenuItem;
    mnuStretch21: TMenuItem;
    winCosmoPreview: TToolWindow97;
    FFPanel: TFFPanel;
    mnuPreviewtoolbar: TMenuItem;
    ilsFF7: TImageList;
    Label1: TLabel;
    mnuTools: TMenuItem;
    mnuIndexer: TMenuItem;
    mnuClose: TMenuItem;
    mnuFind: TMenuItem;
    mnuFindNext: TMenuItem;
    mnuHelpHelp: TMenuItem;
    N5: TMenuItem;
    mnuQhimms: TMenuItem;
    N6: TMenuItem;
    mnuViewdebuglog: TMenuItem;
    N7: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuLoadClick(Sender: TObject);
    procedure lstKeyClick(Sender: TObject);
    procedure mmoTextChange(Sender: TObject);
    procedure mnuMergeClick(Sender: TObject);
    procedure mnuRecalculateNowClick(Sender: TObject);
    procedure mnuToggleClick(Sender: TObject);
    procedure mnuSavechangesClick(Sender: TObject);
    procedure mnuSaveAsSeparateClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuSettextcodeClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure StatusDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure SetMsg(Msg:String);
    procedure mnuFlatbuttonsClick(Sender: TObject);
    procedure mnuTextClick(Sender: TObject);
    procedure tbCosmoFilesVisibleChanged(Sender: TObject);
    procedure mnuFiletoolbarClick(Sender: TObject);
    procedure mnuOpenfromsameLGPClick(Sender: TObject);
    procedure mnu16bitClick(Sender: TObject);
    procedure mnu8BitClick(Sender: TObject);
    procedure mnuNoCompressionClick(Sender: TObject);
    procedure mnuSetFF7FolderClick(Sender: TObject);
    procedure mnuMIDIClick(Sender: TObject);
    procedure btnMIDIDescClick(Sender: TObject);
    procedure btnPlayMIDIClick(Sender: TObject);
    procedure mnuMiditoolbarClick(Sender: TObject);
    procedure tbCosmoMidiVisibleChanged(Sender: TObject);
    procedure mnuBackgroundtoolbarClick(Sender: TObject);
    procedure winCosmoBackVisibleChanged(Sender: TObject);
    procedure mnuViewOptionClick(Sender: TObject);
    procedure lstKeyDblClick(Sender: TObject);
    procedure winCosmoPreviewResize(Sender: TObject);
    procedure mnuPreviewtoolbarClick(Sender: TObject);
    procedure winCosmoPreviewVisibleChanged(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure mnuIndexerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuCloseClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuFindNextClick(Sender: TObject);
    procedure mnuHelpHelpClick(Sender: TObject);
    procedure mnuQhimmsClick(Sender: TObject);
    procedure mnuPluginClick(Sender: TObject);
    procedure mnuViewdebuglogClick(Sender: TObject);
  private
    { Private declarations }
    Lvl:            TFF7Level;
    Dcmp:           TMemoryStream;
    TxtChanged:     Boolean;
    SrcFile:        String;
    LGPIndex:       Integer;
    RawLGP:         TRawLGPFile;
    LastKey:        Integer;
    FF7Path:        String;
    MIDIStrs:       Array[0..2] of TStringList;
    TempMid:        String;
    Midi:           TLGPFile;
    ViewBack:       TViewOption;
    Previews:       TStringList;
    PreviewIndex:   Integer;
    PreviewOn:      Boolean;
    LastFind:       TPoint; //index of text, index within text
    LastFindText:   String;
    CurFile:        String;
    procedure UpdateLocalImage;
    procedure Recalculate;
    procedure LogError(Sender: TObject; E: Exception);
    procedure LoadLevel(Src:TMemoryStream);
    procedure GetBackground;
    procedure PreviewText(Name,Txt:String;Speech:Boolean);
    procedure DrawPreview;
  public
    PrevIndex:      TStringList;
    procedure ClearList(ClearLGP:Boolean);
    procedure DrawBackground(Bmp:TBitmap);
    { Public declarations }
  end;

  function HtmlHelpA(hWndCaller:Longint;pszFile:PChar;uCommand,dwData:Longint):Longint;stdcall;

Const
  BTN_WIDTH_BOTH = 84;
  BTN_WIDTH_IMG = 32;

var
  frmTextView: TfrmTextView;
  ProgCur,ProgMax:Integer;

Text_Sizes: Array [0..126] of Integer =
   (10,06,10,20,14,20,18,06,10,10,14,
    14,08,10,06,14,16,10,16,16,16,
    16,16,16,16,16,06,08,14,16,14,12,
    20,18,14,16,16,14,14,16,16,06,
    12,14,14,22,16,18,14,18,14,14,14,
    16,18,22,16,18,14,08,12,08,14,
    16,08,14,14,12,14,14,12,14,14,06,
    08,12,06,22,14,14,14,14,10,12,
    12,14,14,22,14,16,12,10,06,10,16,
    12,
    17,15,15,15,15,15,15,15,15,15,
    14,10,12,08,18,18,14,22,24,14,
    14,14,16,14,14,18,16,14,16,14,
    12
    );//subtract one for optimal view...

Char_Shift: array[Byte] of Byte =
  ( $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,

    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,

    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$9C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,

    $00,$00,$00,$00,$8E,$8F,$92,$80,$00,$90,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$99,$00,$9D,$00,$00,$00,$9A,$00,$00,$00,
    $85,$00,$83,$00,$84,$86,$91,$87,$8A,$82,$88,$89,$8D,$00,$8C,$8B,
    $00,$00,$95,$00,$93,$00,$94,$00,$9B,$97,$00,$96,$81,$00,$00,$98 );



implementation

{$R *.DFM}

function HtmlHelpA(hWndCaller:Longint;pszFile:PChar;uCommand,dwData:Longint):Longint;stdcall;external 'hhctrl.ocx';


procedure Updater(Cur,Max:Integer);
begin
ProgMax := Max;
ProgCur := Cur;
frmTextView.Status.Refresh;
end;

procedure TfrmTextView.LogError(Sender: TObject; E: Exception);
begin
Log('EXCEPTION: '+E.ClassName+' '+E.Message);
end;

procedure TfrmTextView.FormCreate(Sender: TObject);
var
Reg:      TRegistry;
Ini:      TIniFile;
I,J:      Integer;
B:        Boolean;
Tmp:      TStringList;
Strm:     TStream;
begin

ProgCur := 0; ProgMax := 1; Midi := nil;
Log('Creating...preparing to read from registry.');
Application.OnException := LogError;
Lvl := TFF7Level.Create;
Previews := TStringList.Create; PreviewOn := True;
PrevIndex := TStringList.Create;
DCmp := nil; {Monitor := nil; }RawLGP := nil;
TempMid := TempPath+'COSMO.MID';
LGPStruct.Progress := @Updater;

For I := 0 to 2 do begin
  MIDIStrs[I] := TStringList.Create;
  Strm := InputStream('MidiData'+IntToStr(I));
  If I=0 then MIDIStrs[I].LoadFromStream(Strm) else begin
    Tmp := TStringList.Create; Tmp.LoadFromStream(Strm);
    For J := 0 to MIDIStrs[0].Count-1 do
      MIDIStrs[I].Add(Tmp.Values[Lowercase(MIDIStrs[0][J])+'.mid']);
    Tmp.Free;
  end;
  Strm.Free;
end;

Ini := TIniFile.Create('FICEDULA.INI');
try
I := Ini.ReadInteger('Cosmo','Compression',2);
Case I of
  0: mnuNoCompressionClick(Sender);
  1: mnu8BitClick(Sender);
  2: mnu16BitClick(Sender);
  3: mnuQhimmsClick(Sender);
end;
Width := Ini.ReadInteger('Cosmo','Width',Width);
Height := Ini.ReadInteger('Cosmo','Height',Height);
Top := Ini.ReadInteger('Cosmo','Top',Top);
Left := Ini.ReadInteger('Cosmo','Left',Left);
I := Ini.ReadInteger('Cosmo','ViewBackground',5);
case I of
  0: mnuStretch14.Click;
  1: mnuStretch12.Click;
  2: mnuStretch11.Click;
  3: mnuStretch21.Click;
  4: mnuStretchToWindow.Click;
  5: mnuStretchMaintainRatio.Click;
end;

btnMIDIDesc.Tag := Ini.ReadInteger('Cosmo','MIDIDesc',0)-1;
btnMIDIDesc.Click;
B := Ini.ReadBool('Cosmo','FlatBtn',False);
mnuFlatButtons.Checked := Not B;
mnuFlatButtonsClick(mnuFlatButtons);
B := Ini.ReadBool('Cosmo','TextBtn',True);
FF7Path := Ini.ReadString('Cosmo','FF7Path','::');
mnuText.Checked := Not B;
mnuTextClick(mnuText);
mnuRecalculateConstantly.Checked := Ini.ReadBool('Cosmo','ConstantRecalc',True);
mnuDodgyCompression.Checked := Ini.ReadBool('Cosmo','DodgyComp',True);
finally
end;
Ini.Free;
IniLoadToolbarPositions(Self,'FICEDULA.INI');

tbCosmoFilesVisibleChanged(Sender);
tbCosmoMidiVisibleChanged(Sender);
winCosmoBackVisibleChanged(Sender);
winCosmoPreviewVisibleChanged(Sender);

If Not DirectoryExists(FF7Path) then begin
Reg := TRegistry.Create;
try
Reg.RootKey := HKEY_LOCAL_MACHINE;
If Reg.OpenKey('\Software\Square Soft, Inc.\Final Fantasy VII',False) then
  If Reg.ValueExists('AppPath') then
    FF7Path := Reg.ReadString('AppPath');
finally
Reg.Free;
end;
end;
If Not DirectoryExists(FF7Path) then
  ShowMessage('Warning! Cosmo doesn''t know where FF7 is installed. Please select the correct folder from the ''Options'' menu.')
  else ChDir(FF7Path+'data');

Log('Created: Registry examined, StrStrList created.');
TxtChanged := False;

{If Uppercase(ParamStr(1))='-SHOWALL' then
  For I := 0 to ComponentCount-1 do
    If Components[I] is TControl then
      TControl(Components[I]).Show;}

end;

procedure TfrmTextView.ClearList(ClearLGP:Boolean);
begin
Log('Clearing list...');
If DCmp <> nil then DCmp.Free;

If ClearLGP then begin
  If RawLGP <> nil then RawLGP.Free;
  RawLGP := nil;
end;
DCmp := nil;
mmoText.Text := '';
lstKey.Items.Clear;
LastFind := Point(0,0);
LastFindText := '';
Lvl.Clear;
Caption := 'Cosmo FF7 Editor';
Curfile := '';
Log('Done.');
end;

procedure TfrmTextView.FormDestroy(Sender: TObject);
var
Ini:      TIniFile;
I:        Integer;
begin
IniSaveToolbarPositions(Self,'FICEDULA.INI');
ClearList(True);
Lvl.Free;
Previews.Free;
PrevIndex.Free;
If Midi<>nil then Midi.Free;

For I := 0 to 2 do MIDIStrs[I].Free;

Ini := TIniFile.Create('FICEDULA.INI');
If mnuNoCompression.Checked then I := 0
  else if mnu8Bit.Checked then I := 1
    else if mnu16Bit.Checked then I := 2
      else I := 3;
Ini.WriteInteger('Cosmo','Compression',I);
Ini.WriteBool('Cosmo','FlatBtn',mnuFlatButtons.Checked);
Ini.WriteBool('Cosmo','TextBtn',mnuText.Checked);
Ini.WriteString('Cosmo','FF7Path',FF7Path);
Ini.WriteBool('Cosmo','ConstantRecalc',mnuRecalculateConstantly.Checked);
Ini.WriteBool('Cosmo','DodgyComp',mnuDodgyCompression.Checked);
Ini.WriteInteger('Cosmo','MIDIDesc',btnMIDIDesc.Tag);
Ini.WriteInteger('Cosmo','Width',Width);
Ini.WriteInteger('Cosmo','Height',Height);
Ini.WriteInteger('Cosmo','Top',Top);
Ini.WriteInteger('Cosmo','Left',Left);
Ini.WriteInteger('Cosmo','ViewBackground',Integer(ViewBack));
Ini.Free;
If FileExists(TempMid) then DeleteFile(TempMid);
end;

procedure TfrmTextView.mnuLoadClick(Sender: TObject);
var
Src:        TMemoryStream;
I:          Integer;
LGP:        TLGPFile;
begin
If Not opnAllLGP.Execute then Exit;
ClearList(True);
Src := TMemoryStream.Create;
SrcFile := opnAllLGP.Filename; LGPIndex := -1;
If Uppercase(ExtractFileExt(opnAllLGP.Filename))='.LGP' then begin
  LGP := TLGPFile.CreateFromFile(opnAllLGP.Filename,True);
  SetMsg('Opening LGP archive...');
  try
    frmLGPContents.List.Clear;
    For I := 0 to LGP.NumFiles-1 do
      frmLGPContents.List.Items.Add(LGP[I].Filename);
    frmLGPContents.Text.Caption := 'Which level file to load text from?';
    frmLGPContents.LGP := LGP;
    I := frmLGPContents.ShowModal;
    If I <> mrOK then Exit;
    If frmLGPContents.List.ItemIndex<0 then Exit;
    LGP.Extract(frmLGPContents.List.ItemIndex,Src);
    LGPIndex := frmLGPContents.List.ItemIndex;
    RawLGP := TRawLGPFile.CreateFromFile(SrcFile);
    Caption := 'Cosmo FF7 Editor: '+ExtractFileName(SrcFile)+'?'+frmLGPContents.List.Items[frmLGPContents.List.ItemIndex];
    CurFile := SrcFile+'?'+frmLGPContents.List.Items[frmLGPContents.List.ItemIndex];
  finally
  LGP.Free;
  end;
end else begin
  Src.LoadFromFile(opnAllLGP.Filename);
  Caption := 'Cosmo FF7 Editor: '+ExtractFileName(SrcFile);
  CurFile := SrcFile;
end;

LoadLevel(Src);
end;

procedure TfrmTextView.LoadLevel(Src:TMemoryStream);
var
I:    Integer;
Item: TFF7TextItem;
begin
Lvl.LoadFromStream(Src);
DCmp := Lvl.DecompressedData;
If winCosmoBack.Visible then GetBackground;
lstKey.Items.Clear;
For I := 0 to Lvl.NumTextItems-1 do begin
  Item := Lvl.TextItems[I];
  Case Item.TextType of
    ff7Misc:      lstKey.Items.Add('Misc text');
    ff7MiscSpeech:lstKey.Items.Add('Misc speech');
    ff7NameSpeech:lstKey.Items.Add('Speech: '+UnFilterText(Item.Name));
  end;
end;
cmbMidi.ItemIndex := Lvl.MidiIndex;
end;

procedure TfrmTextView.UpdateLocalImage;
var
Item: TFF7TextItem;
begin
Item := Lvl.TextItems[LastKey];
Item.Text := FilterText(mmoText.Lines.Text);
Lvl.TextItems[LastKey] := Item;
Lvl.MidiIndex := cmbMidi.ItemIndex;
end;


procedure TfrmTextView.lstKeyClick(Sender: TObject);
var
Item: TFF7TextItem;
SL:   TStringList;
S:    String;
I:    Integer;
begin
If lstKey.ItemIndex<0 then Exit;
If TxtChanged then
  If MessageDlg('Text has changed. Keep the changes?',mtConfirmation,[mbYes,mbNo],0)=mrYes then UpdateLocalImage;
Item := Lvl.TextItems[lstKey.ItemIndex];
PreviewOn := False;
mmoText.Lines.Text := UnFilterText(Item.Text);
PreviewOn := True;
TxtChanged := False;
LastKey := lstKey.ItemIndex;

If LGPIndex>=0 then S := Lowercase(RawLGP.TableEntry[LGPIndex].Filename)
  else S := Lowercase(ChangeFileExt(ExtractFilename(opnAllLGP.Filename),''));

S := PrevIndex.Values[S];
SL := TStringList.Create;
StrSLTokenize(S,SL,[',']);
If lstKey.ItemIndex < SL.Count then S := SL[lstKey.ItemIndex] else S := '';
I := Pos('x',S);
SL.Free;
If I>0 then begin
  winCosmoPreview.Width := Min(StrToInt(Copy(S,1,I-1))+20,800);
  winCosmoPreview.Height := Min(StrToInt(Copy(S,I+1,Length(S)))+35,600);
  winCosmoPreview.Caption := 'Previewer *';
end;
DrawPreview;
end;

function PreProcess(Orig,Key:String;Last:Boolean):String;
var
I:       Integer;
begin
If EndsWith(Orig,#13#10) then Delete(Orig,Length(Orig)-1,2);
If Key <> 'Misc text' then Orig := '[Begin]'+Orig;
If BeginsWith(Key, 'Speech:') then Orig := Copy(Key,9,64) +#13#10+ Orig;
If (Not Last) and (Key <> 'Misc text') then Orig := Orig+'[End]';
Orig := Orig + #13#10'[End of dialogue]'#13#10;
Repeat
  I := Pos(#13#10'[NewScreen]'#13#10,Orig);
  If I<>0 then
    Orig := Copy(Orig,1,I-1) + '[End]'#13#10'[Tobe...]'#13#10'[Begin]' + Copy(Orig,I+15,Length(Orig));
Until I=0;
Repeat
  I := Pos('[Tobe...]',Orig);
  If I<>0 then
    Orig := Copy(Orig,1,I-1) + '[NewScreen]' + Copy(Orig,I+9,Length(Orig));
Until I=0;
Result := Orig;
end;

procedure TfrmTextView.Recalculate;
var
S:      String;
MemS:   TMemoryStream;
begin
Exit;
S := mmoText.Text;
S := PreProcess(S,lstKey.Items[lstKey.ItemIndex],lstKey.ItemIndex=lstKey.Items.Count-1);
//Mem := TStringList.Create; Mem.Add(S); Mem.SaveToFile('c:\temp\tmp.tmp'); Mem.Free;
{$IFDEF TEMPDUMP}
MemS := FF7EncodeTextS(S);
MemS.SaveToFile('C:\temp\altered.dump');
MemS.Free;
{$ENDIF}
end;

procedure TfrmTextView.mmoTextChange(Sender: TObject);
var
S:String;
begin
TxtChanged := True;
If mnuRecalculateConstantly.Checked then Recalculate;
If lstKey.ItemIndex<0 then Exit;
S := lstKey.Items[lstKey.ItemIndex];
If BeginsWith(S,'Speech: ') then begin
  S := Copy(S,9,Length(S));
  PreviewText(S,mmoText.Text,True);
end else PreviewText('',mmoText.Text,False);
end;

procedure TfrmTextView.mnuMergeClick(Sender: TObject);
var
Tbl:      TLGP_TableEntry;
I:        Integer;
Tmp:      TMemoryStream;
NewHead:  TRawHeader;
OthRaw:   TRawLGPFile;
begin
If Lvl.NumTextItems<1 then Exit;
If not opnLGP.Execute then Exit;
OthRaw := TRawLGPFile.CreateFromFile(opnLGP.Filename);
frmLGPContents.List.Clear;
For I := 0 to OthRaw.NumEntries-1 do begin
  Tbl := OthRaw.TableEntry[I];
  frmLGPContents.List.Items.Add(StrPas(Tbl.Filename));
end;
frmLGPContents.Text.Caption := 'Which file to replace data for?';
I := frmLGPContents.ShowModal;
If I<>mrOK then Exit;
If frmLGPContents.List.ItemIndex<0 then Exit;
UpdateLocalImage;

Tmp := TMemoryStream.Create;
Lvl.SaveToStream(Tmp);

NewHead.Data := Tmp.Memory;
StrPCopy(NewHead.Head.Filename,(frmLGPContents.List.Items[frmLGPContents.List.ItemIndex]));
NewHead.Head.FileLen := Tmp.Size;
OthRaw.AddHeader(NewHead);
Tbl := OthRaw.TableEntry[frmLGPContents.List.ItemIndex];
Tbl.EntryStart := OthRaw.Header[RawLGP.NumHeaders-1].Offset;
OthRaw.TableEntry[frmLGPContents.List.ItemIndex] := Tbl;
OthRaw.Free;
Tmp.Free;
end;

procedure TfrmTextView.mnuRecalculateNowClick(Sender: TObject);
begin
Recalculate;
end;

procedure TfrmTextView.mnuToggleClick(Sender: TObject);
begin
with (Sender as TMenuItem) do
  Checked := Not Checked;
end;

procedure TfrmTextView.mnuSavechangesClick(Sender: TObject);
var
NewFile:    TMemoryStream;
I:          Integer;
Tbl:        TLGP_TableEntry;
RawHead:    TRawHeader;
begin
If Lvl.NumTextItems<1 then Exit;
SetMsg('Committing changes...');
UpdateLocalImage;
Callback := Updater;
SetMsg('Compressing...');

NewFile := TMemoryStream.Create;
Lvl.SaveToStream(NewFile);

If LGPIndex=-1 then
  NewFile.SaveToFile(ChangeFileExt(SrcFile,'.NEW'))
else begin
  SetMsg('Rewriting LGP...');
  Tbl := RawLGP.TableEntry[LGPIndex];
  For I := 0 to RawLGP.NumHeaders-1 do begin
    RawHead := RawLGP.Header[I];
    If RawHead.Offset = Tbl.EntryStart then begin
      RawHead.Data := NewFile.Memory;
      RawHead.Head.FileLen := NewFile.Size;
      If Not RawLGP.ReplaceData(I,RawHead) then begin
        RawLGP.AddHeader(RawHead);
        Tbl.EntryStart := RawLGP.Header[RawLGP.NumHeaders-1].Offset;
        RawLGP.TableEntry[LGPIndex] := Tbl;
        RawHead.Offset := Tbl.EntryStart;
      end;
      Break;
    end;
  end;
  If RawHead.Offset <> Tbl.EntryStart then ShowMessage('Warning! Save into LGP may have failed.');
end;
NewFile.Free;
SetMsg('Done!');
end;

procedure TfrmTextView.mnuSaveAsSeparateClick(Sender: TObject);
var
Mem:    TMemoryStream;
begin
If Lvl.NumTextItems<1 then Exit;
If Not savAny.Execute then Exit;
UpdateLocalImage;
Mem := TMemoryStream.Create;
Lvl.SaveToStream(Mem);
Mem.SaveToFile(savAny.Filename);
Mem.Free;
end;

procedure TfrmTextView.mnuAboutClick(Sender: TObject);
begin
frmAboutCosmo.ShowModal;
end;

procedure TfrmTextView.mnuSettextcodeClick(Sender: TObject);
begin
DefTextFactor := StrToIntDef(InputBox('Text factor','Enter a new text factor: ',IntToStr(DefTextFactor)),13);
end;

procedure TfrmTextView.mnuExitClick(Sender: TObject);
begin
Application.Terminate;
end;

procedure TfrmTextView.StatusDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
FR:       TRect;
begin
With StatusBar.Canvas do begin
  FR := Rect;
  FR.Right := FR.Left + Trunc((FR.Right - FR.Left)*ProgCur/ProgMax);
  Brush.Style := bsSolid;
  Brush.Color := clHighlight;
  FillRect(FR);
end;
end;

procedure TfrmTextView.SetMsg(Msg:String);
begin
Status.Panels[0].Text := Msg;
end;

procedure TfrmTextView.mnuFlatbuttonsClick(Sender: TObject);
var
Flat:     Boolean;
I:        Integer;
begin
Flat := Not (Sender as TMenuItem).Checked;
(Sender as TMenuItem).Checked := Flat;
For I := 0 to ComponentCount-1 do
  If Components[I] is TToolbarButton97 then
    (Components[I] as TToolbarButton97).Flat := Flat;
end;

procedure TfrmTextView.mnuTextClick(Sender: TObject);
var
Text:     Boolean;
I,Width:  Integer;
Mode:     TButtonDisplayMode;
begin
Text := Not (Sender as TMenuItem).Checked;
(Sender as TMenuItem).Checked := Text;
If Text then Mode := dmBoth else Mode := dmGlyphOnly;
If Text then Width := BTN_WIDTH_BOTH else Width := BTN_WIDTH_IMG;
For I := 0 to ComponentCount-1 do
  If Components[I] is TToolbarButton97 then
    If (Components[I] as TToolbarButton97).Glyph.Width<>0 then begin
      (Components[I] as TToolbarButton97).DisplayMode := Mode;
      (Components[I] as TToolbarButton97).Width := Width;
    end;

end;

procedure TfrmTextView.tbCosmoFilesVisibleChanged(Sender: TObject);
begin
mnuFileToolbar.Checked := tbCosmoFiles.Visible;
end;

procedure TfrmTextView.mnuFiletoolbarClick(Sender: TObject);
begin
(Sender as TMenuItem).Checked := Not (Sender as TMenuItem).Checked;
tbCosmoFiles.Visible := (Sender as TMenuItem).Checked;
end;

procedure TfrmTextView.mnuOpenfromsameLGPClick(Sender: TObject);
var
I:    Integer;
Src:  TMemoryStream;
Tbl:  TLGP_TableEntry;
begin
frmLGPContents.List.Clear;
If RawLGP=nil then Exit;
For I := 0 to RawLGP.NumEntries-1 do begin
  Tbl := RawLGP.TableEntry[I];
  frmLGPContents.List.Items.Add(StrPas(Tbl.Filename));
end;
frmLGPContents.LGP := TLGPFile.CreateFromFile(RawLGP.SourceFile,False);
I := frmLGPContents.ShowModal;
frmLGPContents.LGP.Free;
frmLGPContents.LGP := nil;
If I<>mrOK then Exit;
I := frmLGPContents.List.ItemIndex;
Src := TMemoryStream.Create;
Caption := 'Cosmo FF7 Editor: '+ExtractFilename(opnAllLGP.Filename)+'?'+frmLGPContents.List.Items[frmLGPContents.List.ItemIndex];
CurFile := opnAllLGP.Filename+'?'+frmLGPContents.List.Items[frmLGPContents.List.ItemIndex];
RawLGP.Extract(I,Src);
LGPIndex := I;
ClearList(False);
LoadLevel(Src);
end;

procedure TfrmTextView.mnu16bitClick(Sender: TObject);
begin
LzPointerSeek := DodgySeek16;
mnu16Bit.Checked := True;
end;

procedure TfrmTextView.mnu8BitClick(Sender: TObject);
begin
LzPointerSeek := DodgySeek8;
mnu8Bit.Checked := True;
end;

procedure TfrmTextView.mnuNoCompressionClick(Sender: TObject);
begin
LzPointerSeek := DodgySeek0;
mnuNoCompression.Checked := True;
end;

procedure TfrmTextView.mnuSetFF7FolderClick(Sender: TObject);
begin
SelFolder.Path := FF7Path;
If SelFolder.Execute then FF7Path := SelFolder.Path;
end;

procedure TfrmTextView.mnuMIDIClick(Sender: TObject);
var
Tmp:  Integer;
begin
btnMIDIDesc.Caption := RemoveChar((Sender as TMenuItem).Caption,'&');
btnMIDIDesc.Tag := (Sender as TMenuItem).Tag;
(Sender as TMenuItem).Checked := True;
Tmp := cmbMIDI.ItemIndex;
cmbMIDI.Items.Assign(MIDIStrs[btnMIDIDesc.Tag]);
cmbMIDI.ItemIndex := Tmp;
end;

procedure TfrmTextView.btnMIDIDescClick(Sender: TObject);
begin
popMIDI.Items.Items[(btnMIDIDesc.Tag+1) mod 3].Click;
end;

procedure TfrmTextView.btnPlayMIDIClick(Sender: TObject);
var
Ent:    TLGP_Entry;
Strm:   TFileStream;
begin

Try
If Media.Mode=mpPlaying then Media.Stop;
Media.Close;
Except
end;

If Midi=nil then
  If Not FileExists(FF7Path+'data\midi\midi.lgp') then begin
    ShowMessage('Can''t preview midi - MIDI.LGP not found. (Tried '+FF7Path+'data\midi\midi.lgp'+')');
    Exit;
  end else Midi := TLGPFile.CreateFromFile(FF7Path+'data\midi\midi.lgp',False);

Ent := Midi.EntryName[MIDIStrs[0][cmbMIDI.ItemIndex]+'.MID'];
Strm := TFileStream.Create(Midi.Filename,fmOpenRead or fmShareDenyNone);
Extract(Strm,Ent,TempMid);
Strm.Free;

Media.Filename := TempMid;
Media.Open;
Media.Play;

end;

procedure TfrmTextView.mnuMiditoolbarClick(Sender: TObject);
begin
(Sender as TMenuItem).Checked := Not (Sender as TMenuItem).Checked;
tbCosmoMidi.Visible := (Sender as TMenuItem).Checked;
end;

procedure TfrmTextView.tbCosmoMidiVisibleChanged(Sender: TObject);
begin
mnuMidiToolbar.Checked := tbCosmoMidi.Visible;
end;

procedure TfrmTextView.mnuBackgroundtoolbarClick(Sender: TObject);
begin
(Sender as TMenuItem).Checked := Not (Sender as TMenuItem).Checked;
winCosmoBack.Visible := (Sender as TMenuItem).Checked;
end;

procedure TfrmTextView.winCosmoBackVisibleChanged(Sender: TObject);
begin
mnuBackgroundToolbar.Checked := winCosmoBack.Visible;
If winCosmoBack.Visible then GetBackground;
end;

procedure TfrmTextView.DrawBackground(Bmp:TBitmap);
var
Scale:Single;
Done: TBitmap;
begin
If Not winCosmoBack.Visible then Exit;
  If Bmp<>nil then begin
    If (Bmp.Width <0) or (Bmp.Height <0) then begin
      imgBack.Picture.Bitmap.Assign(nil);
      Exit;
    end;
    Done := TBitmap.Create;
    Case ViewBack of
      Scale14:  begin
                  Done.Width := Bmp.Width div 4;
                  Done.Height := Bmp.Height div 4;
                  Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                end;
      Scale12:  begin
                  Done.Width := Bmp.Width div 2;
                  Done.Height := Bmp.Height div 2;
                  Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                end;
      Scale11:  begin
                  Done.Width := Bmp.Width div 1;
                  Done.Height := Bmp.Height div 1;
                  Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                end;
      Scale21:  begin
                  Done.Width := Bmp.Width * 2;
                  Done.Height := Bmp.Height * 2;
                  Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                end;
      StretchAll: begin
                    Done.Width := winCosmoBack.ClientWidth;
                    Done.Height := winCosmoBack.ClientHeight;
                    Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                  end;
      StretchRatio: begin
                    Scale := MinF( winCosmoBack.ClientWidth/Bmp.Width, winCosmoBack.ClientHeight/Bmp.Height);
                    Done.Width := Trunc(Bmp.Width*Scale);
                    Done.Height := Trunc(Bmp.Height*Scale);
                    Done.Canvas.StretchDraw(Rect(0,0,Done.Width,Done.Height),Bmp);
                  end;
    end;

    If ViewBack<StretchAll then begin
      winCosmoBack.ClientWidth := Done.Width;
      winCosmoBack.ClientHeight := Done.Height;
    end;
    imgBack.Picture.Bitmap.Assign(Done);
    Done.Free;
  end;
end;

procedure TfrmTextView.GetBackground;
var
Bmp:        TBitmap;
Back:       TMemoryStream;
begin
SetMsg('Extracting background image...');
If DCmp<>nil then begin
  Back := TMemoryStream.Create;
  Back.LoadFromStream(DCmp);
  Log('Beginning background decode');
  imgBack.Picture.Bitmap.Height := 0;
  try
  Bmp := FF7_GetBackground(Back);
  except
  Log('Failed to decode background properly');
  Bmp := nil;
  end;
  DrawBackground(Bmp);
  Bmp.Free;
  try
  Back.Free;
  except
  Log('Unexpected fault - couldn''t free background stream');
  end;

end;
SetMsg('OK!');
end;

procedure TfrmTextView.mnuViewOptionClick(Sender: TObject);
begin
ViewBack := TViewOption( (Sender as TMenuItem).Tag );
(Sender as TMenuItem).Checked := True;
If (Sender as TMenuItem).Parent.Tag=123 then
  (Sender as TMenuItem).Parent.Checked := True;
If winCosmoBack.Visible then GetBackground;
end;

procedure TfrmTextView.lstKeyDblClick(Sender: TObject);
var
S:      String;
Item:   TFF7TextItem;
begin
If lstKey.ItemIndex < 0 then Exit;
Item := Lvl.TextItems[lstKey.ItemIndex];
If Item.TextType <> ff7NameSpeech then Exit;
S := FilterText(InputBox('Change speaker','Enter the new name for the speaker:',UnFilterText(Item.Name)));
If S='' then S := UnFilterText(Item.Name);
Item.Name := S;
Lvl.TextItems[lstKey.ItemIndex] := Item;
lstKey.Items[lstKey.ItemIndex] := 'Speech: '+Item.Name;
end;

procedure TfrmTextView.winCosmoPreviewResize(Sender: TObject);
begin
FFPanel.Calculate;
//imgPreview.Picture.Bitmap.Height := winCosmoPreview.ClientHeight;
//imgPreview.Picture.Bitmap.Width := winCosmoPreview.ClientWidth;
winCosmoPreview.Caption := 'Previewer';
DrawPreview;
end;

procedure TfrmTextView.mnuPreviewtoolbarClick(Sender: TObject);
begin
(Sender as TMenuItem).Checked := Not (Sender as TMenuItem).Checked;
winCosmoPreview.Visible := (Sender as TMenuItem).Checked;
end;

procedure TfrmTextView.winCosmoPreviewVisibleChanged(Sender: TObject);
begin
mnuPreviewToolbar.Checked := winCosmoPreview.Visible;
If winCosmoPreview.Visible then DrawPreview;
end;

procedure TfrmTextView.PreviewText(Name,Txt:String;Speech:Boolean);
  procedure AddS(S:String);
  var
  Ad:String;
  begin
  Ad := '';
//  Name := FilterText(Name);
//  Txt := FilterText(Txt);
  If EndsWith(S,#13#10) then begin Delete(S,Length(S)-1,2); Ad := #13#10; end;
  If Name<>'' then begin
    Previews.Add(Name+#13#10#158+S+#127+Ad); Name := ''; Exit;
  end;
  If Speech then Previews.Add(#158+S+#127+Ad) else Previews.Add(S+Ad);
  end;
var
Ps:       Integer;
begin
Previews.Clear;
Repeat
  Ps := Pos(#13#10'[NewScreen]'#13#10,Txt);
  If Ps=0 then Break;
  AddS(Copy(Txt,1,Ps-1));
  Delete(Txt,1,Ps+14);
Until False;
If Txt<>'' then AddS(Txt);
PreviewIndex := 0;
DrawPreview;
end;

procedure TfrmTextView.DrawPreview;
var
X,Y:  Integer;
I:    Byte;
Txt:  String;
begin

If (Not PreviewOn) or (Not winCosmoPreview.Visible) then Exit;

X := 15; Y := 20;
If PreviewIndex >= Previews.Count then Exit;
Txt := Previews[PreviewIndex];
FFPanel.Repaint;
ilsFF7.BlendColor := clWhite;

While Txt<>'' do begin
  If BeginsWith(Txt,'[Colour:White]') then begin
    Delete(Txt,1,14); ilsFF7.BlendColor := clWhite; Continue;
  end;
  If BeginsWith(Txt,'[Colour:Cyan]') then begin
    Delete(Txt,1,13); ilsFF7.BlendColor := clAqua; Continue;
  end;
  If BeginsWith(Txt,'[Colour:Green]') then begin
    Delete(Txt,1,14); ilsFF7.BlendColor := clLime; Continue;
  end;
  If BeginsWith(Txt,'[Colour:Purple]') then begin
    Delete(Txt,1,15); ilsFF7.BlendColor := clFuchsia; Continue;
  end;

  If BeginsWith(Txt,'[Choice]') then begin
    Delete(Txt,1,8); Inc(X,55); Continue;
  end;

  I := Byte(Txt[1]);
  If Char_Shift[I]<>0 then I := Char_Shift[I];
  Delete(Txt,1,1);
  Case I of
    9:  Inc(X,25);
    13: begin X := 15; Inc(Y,30); end;
    10: X := 15;
    else begin
      ilsFF7.Draw(TFriendlyFFPanel(FFPanel).Canvas,X,Y,I-32);
      Inc(X,Text_Sizes[I-32]-1);
    end;
  end;
end;
end;

procedure TfrmTextView.Label1Click(Sender: TObject);
begin
If Previews=nil then Exit;
PreviewIndex := (PreviewIndex+1) mod Previews.Count;
DrawPreview;
end;


procedure TfrmTextView.mnuIndexerClick(Sender: TObject);
begin
frmCosmoIndex.ShowModal;
end;

procedure TfrmTextView.FormShow(Sender: TObject);
var
Strm:   TStream;
I:      Integer;
MI:     TMenuItem;
begin
FFPanel.Calculate;
If FileExists(ExtractFilePath(ParamStr(0))+'PREVIEW.IDX') then begin
  Strm := InputStream('PREVIEW.IDX');
  PrevIndex.LoadFromStream(Strm);
  Strm.Free;
end else If MessageDlg('To use the preview feature, Cosmo must build a preview index. No index was found. Do you want to build one now?',mtConfirmation,[mbYes,mbNo],0)=mrYes then frmCosmoIndex.ShowModal;
InitPlugins;
For I := 0 to Plugins.Count-1 do begin
  MI := TMenuItem.Create(mnuTools);
  mnuTools.Insert(0,MI);
  MI.Caption := Plugins[I];
  MI.Tag := Integer(Plugins.Objects[I]);
  MI.OnClick := mnuPluginClick;
end;
end;

procedure TfrmTextView.mnuCloseClick(Sender: TObject);
begin
ClearList(True);
end;

procedure TfrmTextView.mnuFindClick(Sender: TObject);
var
Fnd:        String;
Item:       TFF7TextItem;
I,J:        Integer;
begin
Fnd := '';
If Not InputQuery('Find in level','Enter the text to find:',Fnd) then Exit;
For I := 0 to Lvl.NumTextItems-1 do begin
  Item := Lvl.TextItems[I];
  J := Pos(Uppercase(Fnd),Uppercase(UnFilterText(Item.Text)));
  If J<>0 then begin
    lstKey.ItemIndex := I;
    lstKeyClick(Sender);
    mmoText.SelStart := J-1;
    mmoText.SelLength := Length(Fnd);
    LastFind := Point(I,J);
    LastFindText := Fnd;
    Exit;
  end;
end;
ShowMessage('Not found!');
end;

procedure TfrmTextView.mnuFindNextClick(Sender: TObject);
var
Item:       TFF7TextItem;
I,J:        Integer;
S:          String;
begin
If LastFindText='' then Exit;
Item := Lvl.TextItems[LastFind.X];
S := Copy(Item.Text,LastFind.Y+1,Length(UnFilterText(Item.Text)));
J := Pos(Uppercase(LastFindText),Uppercase(S));
If J<>0 then begin
  lstKey.ItemIndex := LastFind.X;
  lstKeyClick(Sender);
  mmoText.SelStart := LastFind.Y+J-1;
  mmoText.SelLength := Length(LastFindText);
  LastFind.Y := LastFind.Y + J;
  Exit;
end;
For I := LastFind.X+1 to Lvl.NumTextItems-1 do begin
  Item := Lvl.TextItems[I];
  J := Pos(Uppercase(LastFindText),Uppercase(UnFilterText(Item.Text)));
  If J<>0 then begin
    lstKey.ItemIndex := I;
    lstKeyClick(Sender);
    mmoText.SelStart := J-1;
    mmoText.SelLength := Length(LastFindText);
    LastFind := Point(I,J);
    Exit;
  end;
end;
ShowMessage('Not found!');
end;

procedure TfrmTextView.mnuHelpHelpClick(Sender: TObject);
begin
HtmlHelpA(Handle,PChar(ExtractFilePath(ParamStr(0))+'\Cosmo.chm'),0,0);
end;

procedure TfrmTextView.mnuQhimmsClick(Sender: TObject);
begin
LzPointerSeek := DodgySeekQhimm;
mnuQhimms.Checked := True;
end;

procedure TfrmTextView.mnuPluginClick(Sender: TObject);
var
I:      Integer;
Func:   TPluginFunc;
Data:   TCosmoPlugin;
OldFile:String;
begin
@Func := Pointer((Sender as TMenuItem).Tag);
Data.MainWindow := Handle;
Data.FF7Path := FF7Path;
Data.CurFile := CurFile;
Data.InputStream := InputStream;
Data.LZS_Decompress := LZS_DecompressS;
Data.LZS_Compress := DodgyCompressSO;
Data.Log := Log;
Data.InputExists := FiceExists;
Data.GetProcedure := FiceProcAddress;
If RawLGP<>nil then OldFile := RawLGP.SourceFile else OldFile := '';
mnuCloseClick(Sender);
I := Func(Data);
If (I and PLUG_SUCCESS)=0 then ShowMessage('Plugin failed!');
If (I and PLUG_CLOSEFILE)<>0 then mnuCloseClick(Sender);
If (I and PLUG_LOADFILE)<>0 then ;
If OldFile<>'' then RawLGP := TRawLGPFile.CreateFromFile(OldFile);
end;

procedure TfrmTextView.mnuViewdebuglogClick(Sender: TObject);
begin
AssignDebugMessages(frmMessages.Memo.Lines);
frmMessages.ShowModal;
end;

end.
