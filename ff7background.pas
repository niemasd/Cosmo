unit ff7background;

interface

Uses Windows, SysUtils, Classes, Graphics, FF7Types;

function RebuildBackground(Original:TMemoryStream;NewForeground,NewBackground:TBitmap):TMemoryStream;

Type
  TFullTile = array[0..15,0..15] of Word;
  TTile = array[0..15,0..15] of Byte;
  PTile = ^TTile;
  TPalettePage = array[Byte] of Word;
  PPalettePage = ^TPalettePage;
  TPalette = class
    private
      Data:   Pointer;
      FSize:  Integer;
      function GetColour(Idx:Integer):Word;
      function GetPage(Idx:Integer):TPalettePage;
    public
      Constructor CreateFromLevel(Lvl:TStream);
      Constructor Create;
      Destructor Destroy; Override;
      property Colour[Index:Integer]: Word read GetColour;
      property Page[Index:Integer]: TPalettePage read GetPage;
      property NumColours: Integer read FSize;
  end;
  TBuildPalette = class(TPalette)
    private

    public
      function GetTilePageIndex(Tile:TFullTile): Integer;
      function GetSection: TMemoryStream;
  end;
  TTileCollection = class
    private
      Data:   Pointer;
      FSize:  Integer;
      function GetTile(Idx:Integer):TTile;
      function GetTileEx(X,Y,Page:Integer):TTile;
    public
      Constructor CreateFromLevel(Lvl:TStream);
      Destructor Destroy; Override;
      property Tile[Index:Integer]: TTile read GetTile;
      property PageTile[I1,I2,I3:Integer]: TTile read GetTileEx;
      property NumTiles: Integer read FSize;
  end;
  TBackground = class
    private
      Back,Fore:        PFF7BgSprite;
      NumBack,NumFore:  Integer;
      Palette:          TPalette;
      Texture:          PByte;
    public
      Constructor Create;
      Destructor Destroy; Override;
      function GetSection: TMemoryStream;
      function GetPaletteSection: TMemoryStream;
      procedure WriteBackground(NewBack:TBitmap);
      procedure WriteForeground(NewFore:TBitmap);
  end;

implementation

function BuildFieldFile(Src: Array of TStream): TMemoryStream;
begin
end;

Constructor TPalette.CreateFromLevel(Lvl:TStream);
var
Offset,Offset2:     Integer;
begin
Inherited Create;
Lvl.Position := 2 + (3+1)*4;
Lvl.ReadBuffer(Offset,4); Inc(Offset,4);
Lvl.ReadBuffer(Offset2,4);
Lvl.Position := Offset + $C;
GetMem(Data,Offset2-Offset);
Lvl.ReadBuffer(Data^,Offset2-Offset);
FSize := (Offset2-Offset) div 2;
end;

Constructor TPalette.Create;
begin
Inherited Create;
FSize := 0; Data := nil;
end;

Destructor TPalette.Destroy;
begin
FreeMem(Data);
Inherited Destroy;
end;

function TPalette.GetColour(Idx:Integer):Word;
var
PW:   PWord;
begin
If (Idx<0) or (Idx>=FSize) then Raise EListError.Create('Attempt to access invalid palette entry in FF7Background.TPalette.GetColour!');
PW := Data;
Inc(PW,Idx);
Result := PW^;
end;

function TPalette.GetPage(Idx:Integer):TPalettePage;
var
PPage:  PPalettePage;
begin
If (Idx<0) or (Idx>=(FSize div 256)) then Raise EListError.Create('Attempt to access invalid palette page in FF7Background.TPalette.GetPage!');
PPage := Data;
Inc(PPage,Idx);
Result := PPage^;
end;

function TileMatchesPalette(Tile:TFullTile;Palette:TPalettePage):Boolean;
var
I,J,K:        Integer;
begin
Result := False;
For I := 0 to 15 do
  For J := 0 to 15 do begin
    K := 0;
    While (K<=$FF) and (Palette[K] <> Tile[I,J]) do Inc(K);
    If Palette[K] <> Tile[I,J] then Exit;
  end;
Result := True;
end;

function TBuildPalette.GetTilePageIndex(Tile:TFullTile): Integer;
var
I:      Integer;
PW:     PWord;
begin
For I := 0 to (FSize div $100)-1 do
  If TileMatchesPalette(Tile,Page[I]) then begin
    Result := I;
    Exit;
  end;
ReallocMem(Data,(FSize*2)+($200));
PW := Data;
Inc(PW,FSize);
For I := 0 to $FF do begin
  PW^ := Tile[ I div 16, I mod 16];
  Inc(PW);
end;
Inc(FSize,$100);
Result := (FSize div $100)-1;
end;

function TBuildPalette.GetSection: TMemoryStream;
var
I:    Integer;
begin
Result := TMemoryStream.Create; Result.Size := (FSize*2)+$C;
I := Result.Size-4;
Result.Position := 0;
Result.WriteBuffer(I,4);
Result.WriteBuffer(I,4);
I := DEF_PALETTE_CODE;
Result.WriteBuffer(I,4);
Result.WriteBuffer(Data^,FSize*2);
end;

Constructor TTileCollection.CreateFromLevel(Lvl:TStream);
begin
Inherited Create;

end;

Destructor TTileCollection.Destroy;
begin

Inherited Destroy;
end;

function TTileCollection.GetTile(Idx:Integer):TTile;
begin
end;

function TTileCollection.GetTileEx(X,Y,Page:Integer):TTile;
begin
end;

Constructor TBackground.Create;
begin
end;

Destructor TBackground.Destroy;
begin
end;

function TBackground.GetSection: TMemoryStream;
begin
end;

function TBackground.GetPaletteSection: TMemoryStream;
begin
end;

procedure TBackground.WriteBackground(NewBack:TBitmap);
begin
end;

procedure TBackground.WriteForeground(NewFore:TBitmap);
begin
end;

function GetTileFromBitmap(Src:TBitmap;SrcX,SrcY:Integer):TFullTile;
var
Tmp:        TBitmap;
PW:         PWord;
Output,I,J: Integer;
begin
Tmp := TBitmap.Create;
With Tmp do begin
  Height := Src.Height;
  Width := Src.Width;
  PixelFormat := pf15Bit;
  Canvas.Draw(0,0,Src);
end;
Output := 0;
For I := SrcY to (SrcY+15) do begin
  PW := Tmp.ScanLine[I]; Inc(PW,SrcX);
  For J := 0 to 15 do begin
    Result[Output,J] := PW^;
    Inc(PW);
  end;
  Inc(Output);
end;
Tmp.Free;
end;

function TilesAreSame(Tile1,Tile2:TTile;Pal1,Pal2:TPalettePage):Boolean;
var
I,J:  Integer;
begin
Result := False; I := 0;
For I := 0 to 15 do
  For J := 0 to 15 do
    If Pal1[Tile1[I,J]]<>Pal2[Tile2[I,J]] then Exit;
Result := True;
end;

function GetPalColour(Pal:TPalettePage;Colour:Word): Byte;
var
I:      Integer;
begin
For I := 0 to $FF do
  If Pal[I]=Colour then begin
    Result := I; Exit;
  end;
end;

function PalettizeFullTile(Original:TFullTile;Palette:TPalettePage): TTile;
var
I,J:      Integer;
begin
For I := 0 to $F do
  For J := 0 to $F do
    Result[I,J] := GetPalColour(Palette,Original[I,J]);
end;

function SpritesAreSame(Spr1,Spr2:TFF7BgSprite;Palette:TPalette;Tiles:TTileCollection):Boolean;
var
Page1,Page2:  TPalettePage;
begin
Page1 := Palette.Page[Spr1.Pal];
Page2 := Palette.Page[Spr2.Pal];
Result := TilesAreSame(Tiles.PageTile[Spr1.SrcX,Spr1.SrcY,Spr1.Page],Tiles.PageTile[Spr2.SrcX,Spr2.SrcY,Spr2.Page],Page1,Page2);
end;

function RebuildBackground(Original:TMemoryStream;NewForeground,NewBackground:TBitmap):TMemoryStream;
begin
Result := nil;
end;

end.
