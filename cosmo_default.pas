unit cosmo_default;

//Default 'plugins' built into exe file

interface

Uses CosmoInternal, FF7Sound, CosmoPatch, CosmoSearch, Classes, CosmoUtil,
      Windows, CosmoBackground, PluginTypes, Graphics, FF7Background;

procedure Cosmo_GetPlugins(Fill:TStringList); export;

function InternalEditor(Data:TCosmoPlugin): Integer; export;
function AudioEditor(Data:TCosmoPlugin): Integer; export;
function PatchTool(Data:TCosmoPlugin): Integer; export;
function SearchTool(Data:TCosmoPlugin): Integer; export;
function BackgroundEditor(Data:TCosmoPlugin): Integer; export;
function PackArchive(Data:TCosmoPlugin): Integer; export;

function FF7Ed_BackgroundRebuilder(Original:TMemoryStream;NewForeground,NewBackground:TBitmap):TMemoryStream; export;

implementation

procedure Cosmo_GetPlugins(Fill:TStringList); export;
begin
Fill.AddObject('Internal Editor',@InternalEditor);
Fill.AddObject('Audio Editor',@AudioEditor);
Fill.AddObject('Patch Tool',@PatchTool);
Fill.AddObject('Search/Replace Tool',@SearchTool);
Fill.AddObject('Background Editor',@BackgroundEditor);
Fill.AddObject('Pack LGP',@PackArchive);
end;

function InternalEditor(Data:TCosmoPlugin): Integer;
begin
If frmInternal.Tree.Items.Count=0 then frmInternal.InitData(Data);
//Windows.SetParent(frmInternal.Handle,Data.MainWindow);
frmInternal.KernelFile := Data.FF7Path+'DATA\KERNEL\KERNEL2.BIN';
frmInternal.ShowModal;
Result := PLUG_SUCCESS;
end;

function AudioEditor(Data:TCosmoPlugin): Integer;
begin
ChDir(Data.FF7Path+'DATA\SOUND');
frmCosmoSound.ShowModal;
Result := PLUG_SUCCESS;
end;

function PatchTool(Data:TCosmoPlugin): Integer;
begin
ChDir(Data.FF7Path+'DATA\FIELD');
frmCosmoPatch.ShowModal;
Result := PLUG_SUCCESS or PLUG_CLOSEFILE;
end;

function SearchTool(Data:TCosmoPlugin): Integer;
begin
frmSearchReplace.CurFile := Data.FF7Path+'DATA\FIELD\FLEVEL.LGP';
frmSearchReplace.Data := Data;
frmSearchReplace.ShowModal;
Result := PLUG_SUCCESS or PLUG_CLOSEFILE;
end;

function PackArchive(Data:TCosmoPlugin): Integer; export;
var
I:    Integer;
begin
I := Pos('?',Data.CurFile);
If I<>0 then begin
  LGP_Pack(Copy(Data.CurFile,1,I-1));
  Result := PLUG_SUCCESS or PLUG_CLOSEFILE or PLUG_LOADFILE;
end else Result := 0;
end;

function BackgroundEditor(Data:TCosmoPlugin): Integer; export;
begin
frmCosmoBackground.Plugin := Data;
frmCosmoBackground.OpenFile(Data.CurFile);
frmCosmoBackground.ShowModal;
Result := PLUG_SUCCESS or PLUG_CLOSEFILE or PLUG_LOADFILE;
end;

function FF7Ed_BackgroundRebuilder(Original:TMemoryStream;NewForeground,NewBackground:TBitmap):TMemoryStream; export;
begin
Result := RebuildBackground(Original,NewForeground,NewBackground);
end;


end.
