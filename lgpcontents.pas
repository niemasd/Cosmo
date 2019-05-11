unit lgpcontents;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, LGPStruct, CosmoUtil, ExtCtrls, FFLZS, IniFiles;

type
  TfrmLGPContents = class(TForm)
    List: TListBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    Text: TLabel;
    PicTimer: TTimer;
    chkPreview: TCheckBox;
    procedure ListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure PicTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LGP:      TLGPFile;
  end;

var
  frmLGPContents: TfrmLGPContents;
//  Decoder:        TBackgroundDecodeThread;

implementation

{$R *.DFM}

Uses TxtEdt;

procedure TfrmLGPContents.ListDblClick(Sender: TObject);
begin
If Uppercase(ExtractFileExt(List.Items[List.ItemIndex]))='.TEX' then Exit;
ModalResult := mrOK;
end;

procedure TfrmLGPContents.FormShow(Sender: TObject);
begin
//Decoder := nil;
end;

procedure TfrmLGPContents.FormCreate(Sender: TObject);
var
Ini:  TIniFile;
begin
LGP := nil;
Ini := TIniFile.Create('FICEDULA.INI');
chkPreview.Checked := Ini.ReadBool('Cosmo','LGPContentsPreview',False);
Ini.Free;
end;

procedure TfrmLGPContents.ListClick(Sender: TObject);
var
Tmp,Src:  TMemoryStream;
Bmp:      TBitmap;
begin
btnOK.Enabled := True;
If Uppercase(ExtractFileExt(List.Items[List.ItemIndex]))='.TEX' then begin
  btnOK.Enabled := False;
  Exit;
end;
If LGP=nil then Exit;
If List.ItemIndex<0 then Exit;
If Not chkPreview.Checked then Exit;
Src := TMemoryStream.Create;
LGP.Extract(List.ItemIndex,Src);
Tmp := LzsMemDecompress(Src);
Bmp := FF7_GetBackground(Tmp);
Src.Free; Tmp.Free;
frmTextView.DrawBackground(Bmp);
Bmp.Free;
{
If Decoder<>nil then begin
  Decoder.Terminate;
  Decoder.WaitFor;
  Decoder.Output.Free;
  Decoder.Free;
end;
Src := TMemoryStream.Create;
LGP.Extract(List.ItemIndex,Src);
Decoder := TBackgroundDecodeThread.Create(Src);
Decoder.FreeOnTerminate := False;
Decoder.Resume;
Src.Free;
}
end;

procedure TfrmLGPContents.PicTimerTimer(Sender: TObject);
begin
{If Decoder=nil then Exit;
If Decoder.ReturnValue<>1 then Exit;
frmTextView.imgBack.Picture.Bitmap.Assign(Decoder.Output);
Decoder.Output.Free;
Decoder.Free;
Decoder := nil;}
end;

procedure TfrmLGPContents.FormDestroy(Sender: TObject);
var
Ini:  TIniFile;
begin
Ini := TIniFile.Create('FICEDULA.INI');
Ini.WriteBool('Cosmo','LGPContentsPreview',chkPreview.Checked);
Ini.Free;
end;

procedure TfrmLGPContents.btnOKClick(Sender: TObject);
begin
If Uppercase(ExtractFileExt(List.Items[List.ItemIndex]))='.TEX' then Exit;
ModalResult := mrOK;
end;

end.
