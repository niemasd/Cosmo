unit FF7Types;

interface

Type
  TFF7BgSprite = packed record
    ZZ1,X,Y:    Smallint;
    ZZ2:        Array[0..1] of Smallint;
    SrcX,SrcY:  Smallint;
    ZZ3:        Array[0..3] of Smallint;
    Pal:        Smallint;
    Flags:      Word;
    ZZ4:        Array[0..2] of Smallint;
    Page,Sfx:   Smallint;
    NA:         Longint;
    ZZ5:        Smallint;
    OffX,OffY:  Longint;
    ZZ6:        Smallint;
  end;
  PFF7BgSprite = ^TFF7BGSPRITE;
  TFF7TextType = (ff7Misc, ff7MiscSpeech, ff7NameSpeech);
  TFF7TextItem = record
    TextType:       TFF7TextType;
    Name:           ShortString;
    Text:           AnsiString;
    Changed:        Boolean;
  end;
  PFF7TextItem = ^TFF7TextItem;

  TFF7Color = Array[0..3] of Byte;
  PInt = ^Integer;
  PWord = ^Word;
  PSmall = ^Smallint;
  PByte = ^Byte;
  TFF7Name = Array[0..7] of Char;

Const
  AKAO_CODE = $4F414B41;
  DEF_PALETTE_CODE = $01E00000;

  NA = $D0;
  FIELD_TERMINATOR: Array[0..16] of Char = (
    'E', 'N', 'D', 'F', 'I', 'N', 'A', 'L',' ',
    'F', 'A', 'N', 'T', 'A', 'S', 'Y', '7' );

  FF7Ch: Array[Byte] of Byte =
  ( {0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F}
    $FF, NA, NA, NA, NA, NA, NA, NA, NA,$E1,$E7, NA, NA,$E8, NA, NA, {0}
     NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, {1}
    $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F, {2}
    $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F, {3}

    $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F, {4}
    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F, {5}
    $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F, {6}
    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E, NA, {7}

     NA, NA,$C2,$A4,$C3,$A9, NA,$D6, NA,$C4, NA,$BC,$AE, NA, NA, NA, {8}
     NA,$B4,$B5,$B2,$B3,$C0,$B0,$B1,$8C,$8A, NA,$BD,$AF, NA, NA,$B9, {9}
    $AA,$A1,$82,$83,$BB,$94, NA, NA, NA,$89,$9B,$A7,$A2, NA,$88, NA, {A}
    $81,$91, NA, NA,$8B,$95,$86,$C1, NA, NA,$9C,$A8, NA, NA, NA,$A0, {B}

    $AB,$61,$C5,$AC,$60, NA,$8E,$62,$C9,$63,$C6,$C8,$CD,$CA,$CB,$CC, {C}
     NA,$64,$D1,$CE,$CF,$AD,$65, NA,$8F, NA,$84,$85,$66, NA, NA,$87, {D}
    $68,$67,$69,$6B,$6A,$6C,$9E,$6D,$6F,$6E,$70,$71,$73,$72,$74,$75, {E}
     NA,$76,$78,$77,$79,$7B,$7A,$B6,$9F,$7D,$7C,$7E,$7F, NA, NA,$B8  {F}
  );


implementation

end.
