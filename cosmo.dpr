program cosmo;

uses
  ShareMem,
  DebugLog in '..\..\..\compnent\DebugLog.pas',
  Ficestream in '..\Ficestream.pas',
  Forms,
  KapGrad,
  Graphics,
  txtedt in 'txtedt.pas' {frmTextView},
  lgpcontents in 'lgpcontents.pas' {frmLGPContents},
  aboutcosmo in 'aboutcosmo.pas' {frmAboutCosmo},
  cosmointernal in 'cosmointernal.pas' {frmInternal},
  cosmoindex in 'cosmoindex.pas' {frmCosmoIndex},
  ff7edit in 'ff7edit.pas',
  cosmosearch in 'cosmosearch.pas' {frmSearchReplace},
  cosmopatch in 'cosmopatch.pas' {frmCosmoPatch},
  ff7sound in 'ff7sound.pas' {frmCosmoSound},
  messagefrm in 'messagefrm.pas' {frmMessages},
  CosmoUtil in 'CosmoUtil.pas',
  cosmo_default in 'cosmo_default.pas',
  cosmobackground in 'cosmobackground.pas' {frmCosmoBackground},
  ff7background in 'ff7background.pas',
  FF7Types in 'FF7Types.pas',
  baseutil in '..\..\..\COMPNENT\baseutil.pas';

{$R *.RES}

function FF7Ed_EditorVersion: Comp; export;
begin
Result := AppVersion;
end;

exports
  FF7Ed_ExtractText,
  FF7Ed_DecodeText,
  FF7Ed_EncodeText,
  FF7Ed_GetBackground,
  FF7Ed_EditorVersion,
  LGPPack,
  LGPRepair,
  LGPCreate,
  Cosmo_GetPlugins,
  FF7Ed_BackgroundRebuilder;
  
begin
  Application.Initialize;
  Application.Title := 'Cosmo Beta Release by Ficedula';
  Application.CreateForm(TfrmTextView, frmTextView);
  Application.CreateForm(TfrmCosmoIndex, frmCosmoIndex);
  Application.CreateForm(TfrmLGPContents, frmLGPContents);
  Application.CreateForm(TfrmAboutCosmo, frmAboutCosmo);
  Application.CreateForm(TfrmInternal, frmInternal);
  Application.CreateForm(TfrmCosmoIndex, frmCosmoIndex);
  Application.CreateForm(TfrmSearchReplace, frmSearchReplace);
  Application.CreateForm(TfrmCosmoPatch, frmCosmoPatch);
  Application.CreateForm(TfrmCosmoSound, frmCosmoSound);
  Application.CreateForm(TfrmMessages, frmMessages);
  Application.CreateForm(TfrmCosmoBackground, frmCosmoBackground);
  Application.Run;
end.
