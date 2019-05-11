unit cosmobackground;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtDlgs, PluginTypes, LGPStruct, ExtCtrls, Math, FF7Types;

type
  TfrmCosmoBackground = class(TForm)
    Scroller: TScrollBox;
    savBmp: TSaveDialog;
    opnBmp: TOpenPictureDialog;
    Image: TImage;
    Panel1: TPanel;
    cmbLayer: TComboBox;
    btnExport: TBitBtn;
    btnImport: TBitBtn;
    btnSave: TBitBtn;
    BitBtn1: TBitBtn;
    procedure cmbLayerChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    Foreground, Background, Combine, Palette, Tiles:   TBitmap;
    RawLGP:                   TRawLGPFile;
    CurFile:                  String;
    Data:                     TMemoryStream;
    procedure Cleanup;
    procedure FillBitmaps;
    procedure DoCombine;
  public
    { Public declarations }
    Plugin:     TCosmoPlugin;
    Rebuild:    TCombinerFunc;
    procedure OpenFile(FName:String);
  end;

var
  frmCosmoBackground: TfrmCosmoBackground;

implementation

{$R *.DFM}

procedure TfrmCosmoBackground.FillBitmaps;
var
K,J,TOffset,TDest,I,B3Off,BOff:               Integer;
DCol,bgnsprites2,bgwidth,bgheight,bgnsprites: Word;
bgpsprites2,bgpsprites,psprite:               PFF7BGSPRITE;
Col,Dest,Pal:                                 PWord;
Source,Image,Comb,Picture,PB:                 PByte;
PI:                                           PInteger;
Bmp: TBitmap;
begin
Data.Position := 2 + (8+1)*4;
Data.ReadBuffer(BOff,4); Inc(BOff,4);
Data.Position := 2 + (3+1)*4;
Data.ReadBuffer(B3Off,4); Inc(B3Off,4);
Data.Position := BOff + $28;
Data.ReadBuffer(bgwidth,2);
Data.Position := BOff + $2A;
Data.ReadBuffer(bgheight,2);
Data.Position := BOff + $2C;
Data.ReadBuffer(bgnsprites,2);
GetMem(bgpsprites,Sizeof(TFF7BGSPRITE)*bgnsprites);
Data.Position := BOff + $32;
Data.ReadBuffer(bgpsprites^,Sizeof(TFF7BGSPRITE)*bgnsprites);
Data.Position := BOff + bgnsprites*52+$39;
Data.ReadBuffer(bgnsprites2,2);
GetMem(bgpsprites2,Sizeof(TFF7BGSPRITE)*bgnsprites2);
Data.Position := BOff + $32 + bgnsprites*52 + $1B;
Data.ReadBuffer(bgpsprites2^,Sizeof(TFF7BGSPRITE)*bgnsprites2);
PB := Data.Memory;
Inc(PB,B3Off + $C);
Pal := Pointer(PB);

begin {Palette creation}
  Palette := TBitmap.Create;
  PB := Data.Memory;
  Inc(PB,B3Off);
  PI := Pointer(PB);
  I := PI^ - $C;
  Palette.Width := 256;
  Palette.Height := (I div 2);
  For J := 1 to (I div 2) do begin
    Col := Pal;
    Inc(Col,J-1);
    K := ( (Col^ and $1F) shl 3 ) or ( ( (Col^ and $3E0) shr 5) shl 11) or ( ( (Col^ and $7C00) shr 10) shl 19);
    Palette.Canvas.Brush.Color := K;
    Palette.Canvas.Brush.Style := bsSolid;
    Palette.Canvas.FillRect(Rect( (16*(J mod 16)),(16*(J div 16)),(16+16*(J mod 16)),(16+16*(J div 16))));
  end;
end;

Picture := Data.Memory;
Inc(Picture,BOff + bgnsprites*52 + bgnsprites2*52 + $58);
GetMem(Image,bgwidth*bgheight*2);
{
Dest := Pointer(Image);
For I := 1 to bgwidth*bgheight do begin
  Dest^ := $1F shl 5;
  Inc(Dest);
end;
}
ZeroMemory(Image,bgwidth*bgheight*2);

For I := 0 to bgnsprites-1 do begin
  PSprite := BGPSprites;
  Inc(PSprite,I);
  TOffset := (PSprite^.Page shl 16) or ( (PSprite^.SrcY shl 8) or (PSprite^.SrcX) ) + (PSprite^.Page+1)*6;
  TDest := ((PSprite^.Y + (bgheight shr 1))*bgwidth)+(PSprite^.X+(bgwidth shr 1));
  TDest := TDest shl 1;
  If PSprite^.Sfx <> 0 then Continue;
  For J := 0 to 15 do begin
    Source := Picture;
    If TOffset > Data.Size then Continue;
    Inc(Source,TOffset);
    PB := Image;
    If TDest > (BGWidth*BGHeight*2) then Continue;
    Inc(PB,TDest);
    Dest := Pointer(PB);
    For K := 0 to 15 do begin
      If Source^=0 then begin
        Inc(Source); Inc(Dest); Continue;
      end;
      If (Integer(Dest) > ( Integer(Image) + 2*BGHeight*BGWidth - 2 )) or (Integer(Dest) < Integer(Image)) then Continue;
      Col := Pal;
      Inc(Col, (PSprite^.Pal shl 8) + Source^ );
      If Integer(Col) > ( Integer(Data.Memory) + Data.Size ) then Continue;
      Inc(Source);
      DCol := 0;
      DCol := DCol or ( (Col^ and $1F) shl 10 );
      DCol := DCol or (Col^ and $3E0);
      DCol := DCol or ( (Col^ and $7C00) shr 10);
      Dest^ := DCol;
      Inc(Dest);
    end;
    TDest := TDest + (BGWidth shl 1);
    Inc(TOffset,256);
  end;
end;

Background := TBitmap.Create;
Background.PixelFormat := pf15Bit;
Background.Width := BGWidth;
Background.Height := BGHeight;
PB := Image;
For I := 0 to BGHeight-1 do begin
  Source := Background.ScanLine[I];
  CopyMemory(Source,PB,BGWidth*2);
  Inc(PB,BGWidth*2);
end;

Dest := Pointer(Image);
For I := 1 to bgwidth*bgheight do begin
  Dest^ := $1F shl 5;
  Inc(Dest);
end;

For I := 0 to bgnsprites2-1 do begin
  PSprite := BGPSprites2;
  Inc(PSprite,I);
  TOffset := (PSprite^.Page shl 16) or ( (PSprite^.SrcY shl 8) or (PSprite^.SrcX) ) + (PSprite^.Page+1)*6;
  TDest := ((PSprite^.Y + (bgheight shr 1))*bgwidth)+(PSprite^.X+(bgwidth shr 1));
  TDest := TDest shl 1;
  If PSprite^.Sfx <> 0 then Continue;
  For J := 0 to 15 do begin
    Source := Picture;
    If TOffset > Data.Size then Continue;
    Inc(Source,TOffset);
    PB := Image;
    If TDest > (BGWidth*BGHeight*2) then Continue;
    Inc(PB,TDest);
    Dest := Pointer(PB);
    For K := 0 to 15 do begin
      If Source^=0 then begin
        Inc(Source); Inc(Dest); Continue;
      end;
      If (Integer(Dest) > ( Integer(Image) + 2*BGHeight*BGWidth - 2 )) or (Integer(Dest) < Integer(Image)) then Continue;
      Col := Pal;
      Inc(Col, (PSprite^.Pal shl 8) + Source^ );
      Inc(Source);
      DCol := 0;
      DCol := DCol or ( (Col^ and $1F) shl 10 );
      DCol := DCol or (Col^ and $3E0);
      DCol := DCol or ( (Col^ and $7C00) shr 10);
      Dest^ := DCol; //!!!
      Inc(Dest);
    end;
    TDest := TDest + (BGWidth shl 1);
    Inc(TOffset,256);
  end;
end;

Foreground := TBitmap.Create;
Foreground.PixelFormat := pf15Bit;
Foreground.Width := BGWidth;
Foreground.Height := BGHeight;
PB := Image;
For I := 0 to BGHeight-1 do begin
  Source := Foreground.ScanLine[I];
  CopyMemory(Source,PB,BGWidth*2);
  Inc(PB,BGWidth*2);
end;
FreeMem(Image);
FreeMem(BGPSprites);
FreeMem(BGPSprites2);
end;

procedure TfrmCosmoBackground.cmbLayerChange(Sender: TObject);
begin
btnImport.Enabled := (cmbLayer.ItemIndex<>2);
Case cmbLayer.ItemIndex of
  0: Image.Picture.Assign(Background);
  1: Image.Picture.Assign(Foreground);
  2: Image.Picture.Assign(Combine);
  3: Image.Picture.Assign(Palette);
  4: Image.Picture.Assign(Tiles);
end;
end;

procedure TfrmCosmoBackground.FormCreate(Sender: TObject);
begin
Foreground := nil; Background := nil; RawLGP := nil; Data := nil;
Combine := nil; Palette := nil; Tiles := nil; Rebuild := nil;
end;

procedure TfrmCosmoBackground.Cleanup;
begin
If Foreground<>nil then Foreground.Free; Foreground := nil;
If Background<>nil then Background.Free; Background := nil;
If Combine<>nil then Combine.Free; Combine := nil;
If Palette<>nil then Palette.Free; Palette := nil;
If Tiles<>nil then Tiles.Free; Tiles := nil;
If RawLGP<>nil then RawLGP.Free; RawLGP := nil;
If Data<>nil then Data.Free; Data := nil;
end;

procedure TfrmCosmoBackground.FormDestroy(Sender: TObject);
begin
Cleanup;
end;

procedure TfrmCosmoBackground.OpenFile(FName:String);
var
I:          Integer;
LGP,Fil:    String;
Tmp:        TMemoryStream;
begin
Cleanup;
CurFile := FName;
I := Pos('?',CurFile);
Tmp := TMemoryStream.Create;
If I=0 then begin
  Tmp.LoadFromFile(CurFile);
end else begin
  LGP := Copy(CurFile,1,I-1);
  Fil := Copy(CurFile,I+1,Length(CurFile));
  RawLGP := TRawLGPFile.CreateFromFile(LGP);
  For I := 0 to RawLGP.NumEntries-1 do
    If Uppercase(RawLGP.TableEntry[I].Filename)=Uppercase(Fil) then begin
      RawLGP.Extract(I,Tmp);
      Break;
    end;
end;
If Tmp.Size=0 then Cleanup else begin
  Data := Plugin.LZS_Decompress(Tmp);
  FillBitmaps;
  DoCombine;
end;                                                  
Tmp.Free;
@Rebuild := Plugin.GetProcedure('FF7Ed_BackgroundRebuilder');
end;

procedure TfrmCosmoBackground.DoCombine;
var
PW1,PW2:  PWord;
I,J:      Integer;
begin
Combine := TBitmap.Create;
Combine.Width := Background.Width;
Combine.Height := Background.Height;
Combine.PixelFormat := pf15Bit;
For I := 0 to Background.Height-1 do begin
  PW1 := Background.ScanLine[I];
  PW2 := Combine.ScanLine[I];
  For J := 0 to Background.Width-1 do begin
    PW2^ := PW1^;
    Inc(PW1); Inc(PW2);
  end;
end;
For I := 0 to Foreground.Height-1 do begin
  PW1 := Foreground.ScanLine[I];
  PW2 := Combine.ScanLine[I];
  For J := 0 to Foreground.Width-1 do begin
    If PW1^<>($1F shl 5) then PW2^ := PW1^;
    Inc(PW1); Inc(PW2);
  end;
end;
end;

procedure TfrmCosmoBackground.btnExportClick(Sender: TObject);
begin
If savBMP.Execute then
  Image.Picture.Bitmap.SaveToFile(savBMP.Filename);
end;

procedure TfrmCosmoBackground.btnImportClick(Sender: TObject);
var
Bmp:    TBitmap;
Tmp:    TMemoryStream;
PI:     PInteger;
PB:     PByte;
Colr,I,OldNum,NewNum,Siz:    Integer;
W:      Word;
begin
If Not opnBMP.Execute then Exit;
Bmp := TBitmap.Create;
Bmp.LoadFromFile(opnBMP.Filename);
Bmp.PixelFormat := pf15Bit;

If cmbLayer.ItemIndex<2 then
If (Bmp.Height<>Background.Height) or (Bmp.Width<>Background.Width) then begin
  ShowMessage(Format('Bitmap is wrong size (should be %dx%d)',[Background.Width,Background.Height]));
  Bmp.Free; Exit;
end;
Case cmbLayer.ItemIndex of
  0:  begin Background.Free; Background := Bmp; end;
  1:  begin Foreground.Free; Foreground := Bmp; end;
  3:  begin
        Bmp.Free; Palette.LoadFromFile(opnBMP.Filename);
        PB := Data.Memory; Inc(PB,2+(3+1)*4);
        PI := Pointer(PB); Siz := PI^;
        PB := Data.Memory; Inc(PB,Siz);
        PI := Pointer(PB);
        OldNum := (PI^ - $C) div 2;
        NewNum := (Palette.Width div 16) * (Palette.Height div 16);
        If OldNum>NewNum then ShowMessage('Warning! New palette is smaller than old one. This may cause problems.');
        Tmp := TMemoryStream.Create;
        Data.Position := 0;
        Tmp.CopyFrom(Data,Siz);
        I := NewNum*2 + $C;
        Tmp.Position := Siz;
        Tmp.WriteBuffer(I,4);
        Tmp.WriteBuffer(I,4);
        Data.Position := Siz+8;
        Data.ReadBuffer(I,4);
        Tmp.WriteBuffer(I,4);
        For I := 0 to (NewNum-1) do begin
          Colr := Palette.Canvas.Pixels[ (I mod 16)*16+8, (I div 16)*16+8];
          W := ((Colr and $FF) shr 3) or ((Colr and $F800) shr 6) or ((Colr and $F80000) shr 9);
          Tmp.WriteBuffer(W,2);
        end;
        Data.Position := Siz + PI^;
        Tmp.CopyFrom(Data,Data.Size-Data.Position);
        PB := Data.Memory;
        Inc(PB,22);
        PI := Pointer(PB);
        Dec(PB,20);
        For I := 1 to PB^ do begin
          PI^ := PI^ + (NewNum-OldNum)*2;
          Inc(PI);
        end;
        Data.Free;
        Data := Tmp;
        FillBitmaps;
      end;
end;
DoCombine;
cmbLayerChange(Sender);

end;

procedure TfrmCosmoBackground.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Cleanup;
end;

procedure TfrmCosmoBackground.btnSaveClick(Sender: TObject);
var
I:      Integer;
LGP,Fil:String;
Tmp:    TMemoryStream;
begin
ShowMessage('This will only save *palette* changes at the moment, sorry...');
I := Pos('?',CurFile);
Tmp := Plugin.LZS_Compress(Data);
If I=0 then begin
  Tmp.SaveToFile(CurFile);
  Tmp.Free;
end else begin
  LGP := Copy(CurFile,1,I-1);
  Fil := Copy(CurFile,I+1,Length(CurFile));
  For I := 0 to RawLGP.NumEntries-1 do
    If Uppercase(RawLGP.TableEntry[I].Filename)=Uppercase(Fil) then begin
      RawLGP.UpdateFile(I,Tmp);
      Break;
    end;
end;

end;

end.
