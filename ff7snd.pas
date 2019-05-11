unit ff7snd;

interface

Uses MMSystem, Classes, SysUtils, Cappo, RiffUtil;

Const
  WAVE_FORMAT_ADPCM = $2;

Type
  EFF7Error = class(Exception);
  TADPCMCoefset = packed record
    iCoef1,iCoef2:    Smallint;
  end;
  TFF7SndHeader = packed record
    Length, Offset:   Longint;
    ZZ1:              Array[0..15] of Char;
    wfex:             TWaveFormatEx;
    wSamplesPerBlock,wNumCoef:  Word;
    aCoef:            Array[0..7] of TADPCMCoefset;
  end;
  TFF7SoundDesc = packed record
    Index:    Integer;
    Freq:     Integer;
    Size:     Integer;
  end;
  TFF7Sound = class
    private
      FNumFiles:    Integer;
      Offsets:      TList;
      Datfile:      TFileStream;
      Hdrfile:      TMemoryStream;
      SrcPath:      String;
      procedure LoadHeader;
      function GetDesc(Index:Integer): TFF7SoundDesc;
      function GetSoundData(Num:Integer):TMemoryStream;
      procedure SetSoundData(Num:Integer;Mem:TMemoryStream);
    public
      Constructor CreateFromFolder(Fld:String);
      Destructor Destroy; Override;
      procedure PlaySound(Num:Integer);
      property NumFiles: Integer read FNumFiles;
      property Data[Index:Integer]: TMemoryStream read GetSoundData write SetSoundData;
      property Sounds[Index:Integer]: TFF7SoundDesc read GetDesc;
      property Path: String read SrcPath;
  end;

implementation

Constructor TFF7Sound.CreateFromFolder(Fld:String);
begin
Inherited;
Datfile := TFileStream.Create(Fld+'AUDIO.DAT',fmOpenReadWrite or fmShareDenyWrite);
Hdrfile := TMemoryStream.Create;
Hdrfile.LoadFromFile(Fld+'AUDIO.FMT');
Offsets := TList.Create;
LoadHeader;
SrcPath := Fld;
end;

Destructor TFF7Sound.Destroy;
begin
Hdrfile.Free; Datfile.Free; Offsets.Free;
end;

procedure TFF7Sound.LoadHeader;
var
N:      Integer;
Head:   TFF7SndHeader;
begin
N := 0; FNumFiles := 0;
Hdrfile.Position := 0;
While N<Hdrfile.Size do begin
  Hdrfile.Position := N;
  Hdrfile.ReadBuffer(Head,Min(Sizeof(Head),Hdrfile.Size-N));
  If (Head.Length=0) then begin
    Inc(N,42); Continue;
  end;
  Offsets.Add(Pointer(N));
  Inc(N,46+Head.wNumCoef*4);
  Inc(FNumFiles);
end;
end;

function TFF7Sound.GetDesc(Index:Integer): TFF7SoundDesc;
var
Head:   TFF7SndHeader;
OS:     Integer;
begin
Result.Index := Index;
OS := Integer(Offsets[Index]);
Hdrfile.Position := OS;
Hdrfile.ReadBuffer(Head,Sizeof(Head));
Result.Freq := Head.wfex.nSamplesPerSec;
Result.Size := Head.Length;
end;

procedure TFF7Sound.PlaySound(Num:Integer);
var
Mem:    TMemoryStream;
begin
Mem := GetSoundData(Num);
MMSystem.PlaySound(Mem.Memory,0,SND_MEMORY or SND_NODEFAULT or SND_SYNC);
Mem.Free;
end;

function TFF7Sound.GetSoundData(Num:Integer):TMemoryStream;
var
FCC:    String[4];
Head:   TFF7SndHeader;
OS:     Integer;
I:      Integer;
begin
OS := Integer(Offsets[Num]);
Hdrfile.Position := OS;
Hdrfile.ReadBuffer(Head,Sizeof(Head));
Result := TMemoryStream.Create;
FCC := 'RIFF';
Result.WriteBuffer(FCC[1],4);
I := Head.Length+38;
If Head.wfex.cbSize<>0 then Inc(I,4+Head.wNumCoef*4);
Result.WriteBuffer(I,4);
FCC := 'WAVE';
Result.WriteBuffer(FCC[1],4);
FCC := 'fmt ';
Result.WriteBuffer(FCC[1],4);
I := 18;
If Head.wfex.cbSize<>0 then Inc(I,4+Head.wNumCoef*4);
Result.WriteBuffer(I,4);
Result.WriteBuffer(Head.wfex,I);
FCC := 'data';
Result.WriteBuffer(FCC[1],4);
I := Head.Length;
Result.WriteBuffer(I,4);
Datfile.Position := Head.Offset;
Result.CopyFrom(Datfile,Head.Length);
Result.Position := 0;
end;

procedure TFF7Sound.SetSoundData(Num:Integer;Mem:TMemoryStream);
var
Riff:       TRIFFFile;
Root,Node:  TRIFFNode;
Dat:        TMemoryStream;
wfex:       TWaveFormatEx;
Head:       TFF7SndHeader;
OS:         Integer;
begin
Riff := TRIFFFile.CreateFromStream(Mem);
Root := Riff.GetTopNode;
Node := nil; Dat := nil;
try
Node := Root.Children[0];
If Node.SubType <> 'WAVE' then raise EFF7Error.Create('Error: Input data not Microsoft ADPCM wave format!');
Node := Node.GetChildByName('fmt ');
If Node=nil then raise EFF7Error.Create('Error: Input data not Microsoft ADPCM wave format!');
Dat := Node.GetDataStream;
Dat.Position := 0;
Dat.ReadBuffer(wfex,Sizeof(wfex));
If wfex.wFormatTag <> WAVE_FORMAT_ADPCM then raise EFF7Error.Create('Error: Input data not Microsoft ADPCM wave format!');

OS := Integer(Offsets[Num]);
Hdrfile.Position := OS;
Hdrfile.ReadBuffer(Head,Sizeof(Head));
Dat.Position := 0;
Dat.ReadBuffer(Head.wfex,Dat.Size);
Dat.Free; Dat := nil;

Node := Root.Children[0];
Node := Node.GetChildByName('data');
Dat := Node.GetDataStream;
Head.Offset := Datfile.Size;
Head.Length := Dat.Size;
Dat.Position := 0;
Datfile.Position := Datfile.Size;
Datfile.CopyFrom(Dat,Dat.Size);
Dat.Free; Dat := nil;

Hdrfile.Position := OS;
Hdrfile.WriteBuffer(Head,Sizeof(Head));
Hdrfile.SaveToFile(SrcPath+'AUDIO.FMT');
finally
If Dat<>nil then Dat.Free;
If Node<>nil then Node.Free;
Root.Free;
end;
end;

end.
