program stublrg;

uses
  CommDlg,
  Windows,
  Classes,
  SysUtils,
  Registry,
  Forms,
  stubwindow in 'stubwindow.pas' {frmStubWindow};

{$R *.RES}

var
NT:             Array[0..MAX_PATH] of Char;
FilN:           String;
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

Application.CreateForm(TfrmStubWindow, frmStubWindow);

frmStubWindow.Src := Mem;
frmStubWindow.lblAbout.Caption := StrPas(Target);
frmStubWindow.ShowModal;
Mem.Free;

end.
