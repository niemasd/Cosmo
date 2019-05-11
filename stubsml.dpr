program stubsml;

uses
  FFLzs,
  CommDlg,
  Windows,
  Classes,
  SysUtils,
  Registry,
  LGPStruct,
  FF7Edit;

{$R *.RES}

procedure Msg(M:String);
begin
end;

procedure Prog(Cur,Max:Integer);
begin
end;

procedure ApplyPatch(Src:TMemoryStream;Tgt:String);
var
Raw:        TRawLGPFile;
Lvl:        TFF7Level;
LGP:        TLGPFile;
Tmp,Mem,Pat:TMemoryStream;
I,J:        Integer;
Tbl:        TLGP_TableEntry;
Ent:        TLGP_Entry;
begin
Pat := LzsMemDecompress(Src);
Raw := TRawLGPFile.CreateFromFile(Tgt);
LGP := TLGPFile.CreateFromStream(Pat,False);
Lvl := TFF7Level.Create;
Tmp := TMemoryStream.Create;
Mem := TMemoryStream.Create;
For I := 0 to Raw.NumEntries-1 do begin
  Tbl := Raw.TableEntry[I];
  J := LGP.EntryIndex[Tbl.Filename];
  If J<>-1 then begin
    Msg('Patching '+Tbl.Filename);
    Ent := LGP.Entry[J];
    Mem.Clear;
    Raw.Extract(I,Mem);
    Lvl.LoadFromStream(Mem);
    ExtractS(Pat,Ent,Tmp);
    Tmp.Position := 0;
    Lvl.ApplyDiff(Tmp);
    Mem.Clear; Tmp.Clear;
    Msg('Updating LGP for '+Tbl.Filename);
    Lvl.SaveToStream(Mem);
    Raw.UpdateFile(I,Mem);
    Mem.Clear;
  end;
  Prog(I,Raw.NumEntries);
end;
Mem.Free;
Lvl.Free;
Tmp.Free;
Pat.Free;
LGP.Free;
Raw.Free;
Msg('Done!');
end;


var
OFN:            TOpenFilename;
Filter:         PChar;
FName:          PChar;
Ext:            PChar;
NT:             Array[0..MAX_PATH] of Char;
Tgt,FilN:       String;
StubSize:       Integer;
FS:             TFileStream;
Mem:            TMemoryStream;
Target:         Array[0..63] of Char;
Reg:            TRegistry;
begin
GetModuleFilename(hInstance,@NT,255);
FilN := StrPas(NT);
FS := TFileStream.Create(FilN,fmOpenRead or fmShareDenyNone);
FS.Position := FS.Size - 68;
FS.ReadBuffer(StubSize,4);
FS.ReadBuffer(Target,64);

Reg := TRegistry.Create;
try
Reg.RootKey := HKEY_LOCAL_MACHINE;
If Reg.OpenKey('\Software\Square Soft, Inc.\Final Fantasy VII',False) then
  If Reg.ValueExists('AppPath') then
    ChDir(Reg.ReadString('AppPath')+'data\field');
finally
Reg.Free;
end;

Mem := TMemoryStream.Create;
Mem.Size := FS.Size - StubSize - 68;
FS.Position := StubSize;
Mem.CopyFrom(FS,Mem.Size);
FS.Free;

Tgt := 'FF7 Level Archive'#0'FLEVEL.LGP'#0'FF7 Archives'#0'*.LGP'#0'All files'#0'*.*'#0#0;

Filter := PChar(Tgt);
Ext := 'LGP';
GetMem(FName,512);
Fname^ := #0;
OFN.lStructSize := Sizeof(OFN);
OFN.hWndOwner := 0;
OFN.lpstrFilter := Filter;
OFN.lpstrCustomFilter := nil;
OFN.nFilterIndex := 1;
OFN.lpstrFile := FName;
OFN.nMaxFile := 511;
OFN.lpstrFileTitle := nil;
OFN.lpstrInitialDir := nil;
OFN.lpstrTitle := nil;
OFN.Flags := OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
OFN.lpstrDefExt := Ext;
Tgt := StrPas(Target);
MessageBox(0,PChar('This is a self-extracting LGP Cosmo patch.'#13'The patch was made with Ficedula''s Cosmo Editor.'#13'http://members.tripod.co.uk/ficedula/'#13'Additional info about this patch:'#13+Tgt+'Please select the LGP file to patch:'),'Cosmo Patcher',0);
If GetOpenFileName(OFN) then ApplyPatch(Mem,FName);
FreeMem(FName);
Mem.Free;
MessageBox(0,'Process completed!','Cosmo Patcher',0);
end.
