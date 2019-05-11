unit CosmoUtil;

interface

Uses Windows, SysUtils, Classes, FiceStream, FF7Ed, DebugLog, Graphics,
      LGPStruct, FFLzs, PluginTypes;

Type
    TFourWords = array[1..4] of Word;

var
  FF7_ExtractText:    TExtractTextFunc=nil;
  FF7_DecodeText:     TDecodeTextFunc=nil;
  FF7_EncodeText:     TEncodeTextFunc=nil;
  FF7_GetBackground:  TGetBackgroundFunc=nil;
  LGP_Repair:         TLGPRepairFunc=nil;
  LGP_Create:         TLGPCreateFunc=nil;
  LGP_Pack:           TLGPPackFunc=nil;


function FF7Ed_ExtractText(Src:TMemoryStream;var Table:TList;var Info:TTextInfoRec): TMemoryStream; export;
function FF7Ed_DecodeText(Src:TStream): String; export;
function FF7Ed_EncodeText(Src:String): TMemoryStream; export;
function FF7Ed_GetBackground(Src:TMemoryStream): TBitmap; export;
procedure LGPRepair(FName:Shortstring); export;
procedure LGPCreate(SrcFolder,OutputFile:ShortString;DeleteOriginal,UseErrorCheck:Boolean); export;
procedure LGPPack(FName:ShortString); export;

function MaxVer: Comp;
function MaxVerString: String;
procedure InitPlugins;
function FilterText(Orig:String): String;
function UnFilterText(Orig:String): String;

var
  Plugins:    TStringList;

implementation

var
  MaxVersion: Comp = 0;
  UnfilterTbl,FilterTbl:  Array[Char] of Char;
  Filter:     Boolean;

function FilterText(Orig:String): String;
var
I:    Integer;
begin
If Not Filter then begin
  Result := Orig; Exit;
end;
SetLength(Result,Length(Orig));
For I := 1 to Length(Orig) do
  Result[I] := FilterTbl[Orig[I]];
end;

function UnFilterText(Orig:String): String;
var
I:    Integer;
begin
If Not Filter then begin
  Result := Orig; Exit;
end;
SetLength(Result,Length(Orig));
For I := 1 to Length(Orig) do
  Result[I] := UnFilterTbl[Orig[I]];
end;

procedure InitPlugins;
var
I,J:      Integer;
C:        Char;
S:        String;
GetPlug:  TGetPluginFunc;
Tmp:      TStringList;
Strm:     TStream;
begin
Plugins.Clear;
Tmp := TStringList.Create;
Log('Init plugins');
For I := 0 to DLLs.Count-1 do begin
  Tmp.Clear;
  GetPlug := GetProcAddress(Integer(DLLs.Objects[I]),'Cosmo_GetPlugins');
  If @GetPlug=nil then Continue;
  GetPlug(Tmp);
  For J := 0 to Tmp.Count-1 do
    If Plugins.IndexOf(Tmp[J])=-1 then begin
      Plugins.AddObject(Tmp[J],Tmp.Objects[J]);
      Log(' Plugin function '+Tmp[J]+' found in library '+DLLs[I]);
    end;
end;
Log('Plugins ready');
Tmp.Clear;
Strm := InputStream('Trans_Table');
Filter := (Strm<>nil);
If Filter then begin
  Tmp.LoadFromStream(Strm);
  Strm.Free;
  For C := #0 to #255 do begin
    S := Tmp.Values[C];
    If S='' then FilterTbl[C] := C
      else FilterTbl[C] := S[1];
    UnfilterTbl[FilterTbl[C]] := C;
  end;
end;
Tmp.Free;
end;

function FF7Ed_ExtractText(Src:TMemoryStream;var Table:TList;var Info:TTextInfoRec): TMemoryStream;
begin
Result := ExtractTextRTN(Src,Table,Info);
end;

function FF7Ed_DecodeText(Src:TStream): String;
var
S:  String;
begin
Result := FF7DecodeTextS(Src);
end;

function FF7Ed_EncodeText(Src:String): TMemoryStream;
begin
Result := FF7EncodeTextS(Src);
end;

function FF7Ed_GetBackground(Src:TMemoryStream): TBitmap;
begin
Result := GetFF7Background(Src);
end;

procedure LGPRepair(FName:ShortString);
begin
LGPRepairArchive(FName);
end;

procedure LGPCreate(SrcFolder,OutputFile:ShortString;DeleteOriginal,UseErrorCheck:Boolean);
begin
LGPCreateArchive(SrcFolder,OutputFile,DeleteOriginal,UseErrorCheck);
end;

procedure LGPPack(FName:ShortString);
begin
LGPPackArchive(FName);
end;

Const
  VersionOrder: Array[1..4] of Byte = (2,1,4,3);

function CompWords(I1,I2: TFourWords): Integer;
var
I:    Integer;
begin
For I := 1 to 4 do
  If I1[VersionOrder[I]] > I2[VersionOrder[I]] then begin
    Result := -1; Exit;
  end else If I1[VersionOrder[I]] < I2[VersionOrder[I]] then begin
    Result := 1; Exit;
  end;
Result := 0;
end;

function PrioritiseLibraries(Item1, Item2: Pointer): Integer;
var
Ver1, Ver2:     Function: Comp;
Vers:           Array[1..2] of ^TFourWords;
R1,R2:          Comp;
begin
Ver1 := GetProcAddress(Integer(Item1),'FF7Ed_EditorVersion');
Ver2 := GetProcAddress(Integer(Item2),'FF7Ed_EditorVersion');
ZeroMemory(@R1,8); ZeroMemory(@R2,8);
If @Ver1<>nil then R1 := Ver1;
If @Ver2<>nil then R2 := Ver2;

Vers[1] := @R1;
Vers[2] := @R2;
If CompWords(Vers[1]^,TFourWords(MaxVersion))=-1 then MaxVersion := R1;
If CompWords(Vers[2]^,TFourWords(MaxVersion))=-1 then MaxVersion := R2;

Result := CompWords(Vers[1]^,Vers[2]^);
end;

function MaxVer: Comp;
begin
Result := MaxVersion;
end;

function MaxVerString: String;
var
W1,W2,W3,W4:  ^Word;
begin
W1 := @MaxVersion;
W2 := @MaxVersion; Inc(W2);
W3 := @MaxVersion; Inc(W3,2);
W4 := @MaxVersion; Inc(W4,3);
Result := Format('%d.%d.%d build %d', [W2^, W1^, W4^, W3^]);
end;

procedure InitFuncs;
var
I:    Integer;
begin
Log('CosmoUtil: Acquiring editing functions');
FF7_ExtractText := FiceProcAddress('FF7Ed_ExtractText');
FF7_DecodeText := FiceProcAddress('FF7Ed_DecodeText');
FF7_EncodeText := FiceProcAddress('FF7Ed_EncodeText');
FF7_GetBackground := FiceProcAddress('FF7Ed_GetBackground');
LGP_Repair := FiceProcAddress('LGPRepair');
LGP_Pack := FiceProcAddress('LGPPack');
LGP_Create := FiceProcAddress('LGPCreate');
Log('CosmoUtil: Prioritising editing function sources');
ZeroMemory(@MaxVersion,8);
FiceProcSort(PrioritiseLibraries);
Log('CosmoUtil: Installed libaries:');
For I := 0 to DLLs.Count-1 do
  Log('   Library '+DLLs[I]);
Log('CosmoUtil: Init done');
end;

initialization
InitFuncs;
Plugins := TStringList.Create;
finalization
Plugins.Free;
end.
