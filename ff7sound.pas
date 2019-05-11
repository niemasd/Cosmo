unit ff7sound;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FF7Snd, StdCtrls, ComCtrls, Buttons, BaseUtil;

type
  TfrmCosmoSound = class(TForm)
    lstSound: TListView;
    savWAV: TSaveDialog;
    opnWav: TOpenDialog;
    opnAudio: TOpenDialog;
    btnOpen: TBitBtn;
    btnExtract: TBitBtn;
    btnReplace: TBitBtn;
    btnPlay: TBitBtn;
    BitBtn1: TBitBtn;
    btnRestore: TBitBtn;
    procedure btnLoadClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnExtractClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFromFolder(Fld:String);
  end;

var
  frmCosmoSound:  TfrmCosmoSound;
  Snd:            TFF7Sound=nil;

implementation

{$R *.DFM}

procedure TfrmCosmoSound.LoadFromFolder(Fld:String);
var
LI:       TListItem;
I:        Integer;
Desc:     TFF7SoundDesc;
begin
Snd := TFF7Sound.CreateFromFolder(Fld);
lstSound.Items.Clear;
For I := 0 to Snd.NumFiles-1 do begin
  LI := lstSound.Items.Add;
  LI.Caption := IntToStr(I);
  Desc := Snd.Sounds[I];
  LI.Subitems.Add(FileSizeStr(Desc.Size));
  LI.Subitems.Add(IntToStr(Desc.Freq));
end;
end;

procedure TfrmCosmoSound.btnLoadClick(Sender: TObject);
begin
If Not opnAudio.Execute then Exit;
LoadFromFolder(ExtractFilePath(opnAudio.Filename));
end;

procedure TfrmCosmoSound.FormDestroy(Sender: TObject);
begin
If Snd<>nil then Snd.Free;
end;

procedure TfrmCosmoSound.btnPlayClick(Sender: TObject);
begin
If lstSound.Selected<>nil then begin
  btnPlay.Enabled := False;
  Snd.PlaySound(lstSound.Selected.Index);
  btnPlay.Enabled := True;
end;
end;

procedure TfrmCosmoSound.btnExtractClick(Sender: TObject);
var
Mem:    TMemoryStream;
begin
If lstSound.Selected=nil then Exit;
If not savWAV.Execute then Exit;
Mem := Snd.Data[lstSound.Selected.Index];
Mem.SaveToFile(savWAV.Filename);
Mem.Free;
end;

procedure TfrmCosmoSound.btnReplaceClick(Sender: TObject);
var
Mem:    TMemoryStream;
begin
If lstSound.Selected=nil then Exit;
If not opnWAV.Execute then Exit;
CopyFile(PChar(opnAudio.Filename),PChar(ExtractFilePath(opnAudio.Filename)+'AUDIOFMT.BAK'),True);
Mem := TMemoryStream.Create;
Mem.LoadFromFile(opnWAV.Filename);
Snd.Data[lstSound.Selected.Index] := Mem;
Mem.Free;
Snd.Free;
Snd := nil;
LoadFromFolder(ExtractFilePath(opnAudio.Filename));
end;

procedure TfrmCosmoSound.btnRestoreClick(Sender: TObject);
begin
CopyFile(PChar(ExtractFilePath(opnAudio.Filename)+'AUDIOFMT.BAK'),PChar(opnAudio.Filename),False);
end;

end.
 