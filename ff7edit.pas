unit ff7edit;

interface

Uses CosmoUtil, FFLzs, Classes, SysUtils, DebugLog, FF7Ed,
      PluginTypes, FF7Types, BaseUtil;

{$DEFINE TEMPDUMP}

Type
  TFF7Level = class
    private
      FTextItems:                   TList;
      DCmp,OCmp:                    TMemoryStream;
      FOldMidi,FMidi:               Byte;
      FOffset,FSize,FStart,FFOffset:Integer;
      RewriteScript:                Boolean;
      procedure Cleanup;
      procedure Init;
      function GetNumText: Integer;
      function GetItem(Index:Integer): TFF7TextItem;
      procedure SetItem(Index:Integer;Item:TFF7TextItem);
    public
      Constructor Create;
      Constructor CreateFromFile(FName:String);
      Constructor CreateFromStream(Strm:TStream);
      Destructor Destroy; Override;
      procedure LoadFromFile(FName:String);
      procedure LoadFromStream(Strm:TStream);
      procedure SaveToFile(FName:String);
      procedure SaveToStream(Strm:TStream);
      procedure Clear;
      function OriginalData: TMemoryStream;
      function DecompressedData: TMemoryStream;
      function MakeDiff(Original:TFF7Level): TMemoryStream;
      function ApplyDiff(Diff:TMemoryStream): Boolean;
      property TextItems[Index:Integer]: TFF7TextItem read GetItem write SetItem; default;
      property NumTextItems: Integer read GetNumText;
      property MidiIndex: Byte read FMidi write FMidi;
  end;

var
  DefTextFactor: Integer = 13;

implementation

Constructor TFF7Level.Create;
begin
Inherited;
Init;
end;

Constructor TFF7Level.CreateFromFile(FName:String);
begin
Inherited;
Init;
LoadFromFile(FName);
end;

Constructor TFF7Level.CreateFromStream(Strm:TStream);
begin
Inherited;
Init;
LoadFromStream(Strm);
end;

Destructor TFF7Level.Destroy;
begin
Cleanup;
FTextItems.Free;
Inherited;
end;

function TFF7Level.OriginalData: TMemoryStream;
begin
Result := TMemoryStream.Create;
Result.CopyFrom(OCmp,0);
end;

function TFF7Level.DecompressedData: TMemoryStream;
begin
Result := TMemoryStream.Create;
Result.CopyFrom(DCmp,0);
end;

procedure TFF7Level.Clear;
begin
Cleanup;
end;

procedure TFF7Level.LoadFromFile(FName:String);
var
Fil:      TFileStream;
begin
Fil := TFileStream.Create(FName, fmOpenRead or fmShareDenyNone);
LoadFromStream(Fil);
Fil.Free;
end;

procedure TFF7Level.LoadFromStream(Strm:TStream);
var
Decode,Txt:       TMemoryStream;
Tmp:              TStringList;
First,Next:       String;
Scale,CurOS,Last,Cur,I: Integer;
Tbl:              TList;
PI:               ^Integer;
PB:               PByte;
Item:             PFF7TextItem;
Info:             TTextInfoRec;
begin
Cleanup; DCmp := nil;
OCmp := TMemoryStream.Create;
OCmp.CopyFrom(Strm,0);
OCmp.Position := 0;
OCmp.ReadBuffer(I,4);
If I<>OCmp.Size-4 then Exit;
OCmp.Position := 0;
DCmp := LZS_DecompressS(OCmp);

Info.Factor := DefTextFactor;
Txt := FF7_ExtractText(DCmp,Tbl,Info);
Tmp := TStringList.Create;
Decode := TMemoryStream.Create;
{$IFDEF TEMPDUMP}
Txt.SaveToFile('C:\temp\text.dump');
DCmp.SaveToFile('C:\temp\file.dump');
For CurOS := 0 to Tbl.Count-1 do
  Tmp.Add(IntToStr(Integer(Tbl[CurOS])));
Tmp.SaveToFile('C:\temp\table.dump');
Tmp.Clear;
{$ENDIF}
try
Log('Decompressed text.');

If Txt.Size=0 then Exit;

FOffset := Info.Offset;
FSize := Info.Size;
FStart := Info.Start;
FFOffset := Info.FileOffset;
RewriteScript := Info.UsedScriptOffset;

PB := DCmp.Memory;
Inc(PB,FOffset + FSize);
Cur := Min($FF, (DCmp.Size)-(FOffset+FSize) );
For I := 1 to Cur do begin
  PI := Pointer(PB);
  Inc(PB);
  If PI^=AKAO_CODE then begin
    Inc(PB,3);
    FMidi := PB^-1;
    FOldMidi := FMidi;
    Break;
  end;
  If I=$FF then FMidi := $FF;
end;

Scale := 0;
CurOS := Tbl.Count;
If Tbl.Count>0 then begin
  While (Tbl.Count>0) and ( (Integer(Tbl[0]) < 0) or (Integer(Tbl[0]) > Txt.Size) ) do
    Tbl.Delete(0);
  If CurOS=Tbl.Count then Scale := -Integer(Tbl[0]);
end;

If Tbl.Count<1 then Exit;

Last := Integer(Tbl[0])+Scale;
For I := 1 to Tbl.Count do begin
  If I<Tbl.Count then Cur := Integer(Tbl[I]) else Cur := Txt.Size;
  Inc(Cur,Scale);
  Decode.Clear;
  Txt.Position := Last;
  If (Last < 0) or (Cur > Txt.Size) or (Cur < Last) then Break;
  Decode.CopyFrom(Txt,Cur-Last);
  Tmp.Clear;
  Tmp.Text := (FF7_DecodeText(Decode));

  First := Tmp[0]; If Tmp.Count>1 then Next := Tmp[1] else Next := '';

  New(Item);
  FTextItems.Add(Item);

  Tmp.Delete(0);
  Item^.Name := '';
  Item^.Changed := False;
  If BeginsWith(First,'[Begin]') then Item^.TextType := ff7MiscSpeech
    else if BeginsWith(Next,'[Begin]') then begin
        Item^.TextType := ff7NameSpeech;
        Item^.Name := First;
    end else Item^.TextType := ff7Misc;
  If BeginsWith(Next,'[Begin]') then begin
    First := Next; Tmp.Delete(0);
  end;
  Repeat
    If BeginsWith(First,'[Begin]') then Delete(First,1,7);
    If EndsWith(First,'[End]') then Delete(First,Length(First)-4,5);
    Item^.Text := Item^.Text + #13#10 + First;
    If Tmp.Count>0 then begin
      First := Tmp[0]; Tmp.Delete(0);
    end else Break;
  Until (First = '[End of dialogue]');
  If BeginsWith(Item^.Text,#13#10) then Delete(Item^.Text,1,2);
  Last := Cur;
end;

finally
Tbl.Free;
Tmp.Free;
Decode.Free;
Txt.Free;
end;
end;

procedure TFF7Level.SaveToFile(FName:String);
var
Fil:      TFileStream;
begin
Fil := TFileStream.Create(FName, fmCreate or fmShareDenyWrite);
SaveToStream(Fil);
Fil.Free;
end;

function PreProcess(Item:TFF7TextItem;Last:Boolean):String;
var
I:       Integer;
Orig:    String;
begin
Orig := Item.Text;
If EndsWith(Orig,#13#10) and Item.Changed then Delete(Orig,Length(Orig)-1,2);
If Item.TextType <> ff7Misc then Orig := '[Begin]'+Orig;
If Item.TextType = ff7NameSpeech then
  Orig := Item.Name +#13#10+ Orig;
If (Not Last) and (Item.TextType <> ff7Misc) then Orig := Orig+'[End]';
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

procedure TFF7Level.SaveToStream(Strm:TStream);
var
S:                    String;
NewD,MemS:            TMemoryStream;
Old,Change,CurOS,J,I: Integer;
W:                    Word;
Tbl:                  TList;
PI:                   ^Integer;
PB:                   PByte;
Item:                 PFF7TextItem;
begin

NewD := TMemoryStream.Create;
Tbl := TList.Create;
Tbl.Add(Pointer(-FTextItems.Count-2));
CurOS := 0;
For I := 0 to FTextItems.Count-1 do begin
  Item := FTextItems[I];
  S := PreProcess(Item^,I=FTextItems.Count-1);
  MemS := FF7_EncodeText(PChar(S));
  If (I=FTextItems.Count-1) then MemS.Size := MemS.Size-1;
  NewD.CopyFrom(MemS,0);
  Tbl.Add(Pointer(CurOS));
  Inc(CurOS,MemS.Size);
  MemS.Free;
end;

Change := NewD.Size - FSize;

//NewBlkSize := NewD.Size;

MemS := NewD;
NewD := TMemoryStream.Create;
Dcmp.Position := 0;
NewD.Size := DCmp.Size;

NewD.CopyFrom(DCmp,FStart);
For I := 0 to Tbl.Count-1 do begin
  J := Integer(Tbl[I]);
  W := J + 2*Tbl.Count;
  NewD.WriteBuffer(W,2);
end;

MemS.Position := 0;
NewD.CopyFrom(MemS,MemS.Size);
DCmp.Position := FOffset + FSize;

NewD.CopyFrom(DCmp,DCmp.Size - DCmp.Position);

PB := NewD.Memory;
Inc(PB,FStart + MemS.Size + 2*Tbl.Count);
If (FMidi<>$FF) and (FMidi<>FOldMidi) then
  For I := 1 to 24 do begin
    PI := Pointer(PB); Inc(PB);
    If PI^=AKAO_CODE then begin
      Inc(PB,3);
      PB^ := FMidi+1;
      Break;
    end;
  end;

MemS.Free;
Tbl.Free;

NewD.Position := 2;
NewD.ReadBuffer(J,4);
For I := 1 to J do begin
  NewD.ReadBuffer(CurOS,4);
  Old := NewD.Position;
  If I>1 then begin
    CurOS := CurOS + Change;
    NewD.Seek(-4,soFromCurrent);
    NewD.WriteBuffer(CurOS,4);
  end else begin
    NewD.Position := CurOS;
    NewD.ReadBuffer(CurOS,4);
    CurOS := CurOS + Change;
    NewD.Seek(-4,soFromCurrent);
    NewD.WriteBuffer(CurOS,4);
    NewD.Position := Old;
  end;
end;

NewD.Position := FFOffset;
NewD.ReadBuffer(CurOS,4);
CurOS := CurOS + Change;
NewD.Seek(-4,soFromCurrent);
If RewriteScript then NewD.WriteBuffer(CurOS,4);

MemS := DodgyCompressSO(NewD);

Strm.CopyFrom(MemS,0);
NewD.Free;
MemS.Free;
end;

procedure TFF7Level.Cleanup;
var
PItem:    PFF7TextItem;
I:        Integer;
begin
For I := 0 to FTextItems.Count-1 do begin
  PItem := FTextItems[I];
  Dispose(PItem);
end;
FTextItems.Clear;
If DCmp<>nil then DCmp.Free; DCmp := nil;
If OCmp<>nil then OCmp.Free; OCmp := nil;
end;

procedure TFF7Level.Init;
begin
FTextItems := TList.Create;
DCmp := nil; OCmp := nil;
end;

function TFF7Level.GetItem(Index:Integer): TFF7TextItem;
var
PItem:    PFF7TextItem;
begin
PItem := FTextItems[Index];
Result := PItem^;
end;

procedure TFF7Level.SetItem(Index:Integer;Item:TFF7TextItem);
var
PItem:    PFF7TextItem;
begin
PItem := FTextItems[Index];
PItem^ := Item;
PItem^.Changed := True;
end;

function TFF7Level.GetNumText: Integer;
begin
Result := FTextItems.Count;
end;

function TFF7Level.MakeDiff(Original:TFF7Level): TMemoryStream;
var
I:            Integer;
OItem,NItem:  TFF7TextItem;
WTmp,NA:      Word;
begin
Result := TMemoryStream.Create;
NA := $FFFF;
If Original.NumTextItems = NumTextItems then begin
  Result.WriteBuffer(Original.FOffset,4);
  Result.WriteBuffer(Original.FSize,4);
  Result.WriteBuffer(Original.FStart,4);
  Result.WriteBuffer(Original.FFOffset,4);
  I := NumTextItems;
  Result.WriteBuffer(I,4);
  Result.WriteBuffer(Self.MidiIndex,1);
  For I := 0 to FTextItems.Count-1 do begin
    OItem := Original.TextItems[I];
    NItem := Self.TextItems[I];
    If OItem.Name <> NItem.Name then begin
      WTmp := Length(NItem.Name);
      Result.WriteBuffer(WTmp,2);
      Result.WriteBuffer(NItem.Name,Length(NItem.Name)+1);
    end else Result.WriteBuffer(NA,2);
    If OItem.Text <> NItem.Text then begin
      WTmp := Length(NItem.Text);
      Result.WriteBuffer(WTmp,2);
      Result.WriteBuffer(PChar(NItem.Text)^,Length(NItem.Text));
    end else Result.WriteBuffer(NA,2);
  end;
end;
If Result.Size<=(21+4*NumTextItems) then begin
  Result.Free;
  Result := nil;
end;
end;

function TFF7Level.ApplyDiff(Diff:TMemoryStream): Boolean;
var
WTmp:     Word;
Item:     TFF7TextItem;
I,ITmp:   Integer;
BTmp:     Byte;
begin
Result := False;

Diff.ReadBuffer(ITmp,4);
If FOffset<>ITmp then Exit;
Diff.ReadBuffer(ITmp,4);
If FSize<>ITmp then Exit;
Diff.ReadBuffer(ITmp,4);
If FStart<>ITmp then Exit;
Diff.ReadBuffer(ITmp,4);
If FFOffset<>ITmp then Exit;
Diff.ReadBuffer(ITmp,4);
If NumTextItems<>ITmp then Exit;
Diff.ReadBuffer(BTmp,1);
MidiIndex := BTmp;

For I := 0 to FTextItems.Count-1 do begin
  Item := Self.TextItems[I];
  Diff.ReadBuffer(WTmp,2);
  If WTmp<>$FFFF then begin
    SetLength(Item.Name,WTmp);
    Diff.ReadBuffer(Item.Name,WTmp+1);
  end;
  Diff.ReadBuffer(WTmp,2);
  If WTmp<>$FFFF then begin
    SetLength(Item.Text,WTmp);
    Diff.ReadBuffer(PChar(Item.Text)^,WTmp);
  end;
  Self.TextItems[I] := Item;
end;
Result := True;
end;

end.
