unit PluginTypes;

interface

Uses Windows, Classes, Graphics;

Type
  TGetStreamFunc = function (FName:ShortString): TStream;
  TStreamExistsFunc = function (FName:ShortString): Boolean;
  TGetProcFunc = function (FuncName:ShortString): Pointer;
  TDecompressFunc = function (Src:TMemoryStream): TMemoryStream;
  TCompressFunc = function (Src:TStream): TMemoryStream;
  TTextInfoRec = packed record
    Factor, Offset, Size, Start, FileOffset: Integer;
    UsedScriptOffset:                        Boolean; 
  end;
  TErrorMessageFunc = procedure (Msg:String);
  TCosmoPlugin = packed record
    MainWindow:     THandle;
    FF7Path:        Shortstring;
    CurFile:        Shortstring;
    InputStream:    TGetStreamFunc;
    LZS_Decompress: TDecompressFunc;
    LZS_Compress:   TCompressFunc;
    Log:            TErrorMessageFunc;
    InputExists:    TStreamExistsFunc;
    GetProcedure:   TGetProcFunc;
  end;

  TExtractTextFunc = function (Src:TMemoryStream;var Table:TList;var Info:TTextInfoRec): TMemoryStream;
  TDecodeTextFunc = function (Src:TStream): String;
  TEncodeTextFunc = function (Src:String): TMemoryStream;
  TGetBackgroundFunc = function (Src:TMemoryStream): TBitmap;
  TLGPRepairFunc = procedure (FName:ShortString);
  TLGPCreateFunc = procedure (SrcFolder,OutputFile:ShortString;DeleteOriginal,UseErrorCheck:Boolean);
  TLGPPackFunc = procedure (FName:ShortString);
  TGetPluginFunc = procedure (Functions:TStringList);
  TPluginFunc = function (Data:TCosmoPlugin): Integer;
  TCombinerFunc = function(Original:TMemoryStream;NewForeground,NewBackground:TBitmap):TMemoryStream;

Const
  PLUG_SUCCESS = $1;
  PLUG_CLOSEFILE = $2;
  PLUG_LOADFILE = $4;

implementation

end.
