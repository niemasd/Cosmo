unit aboutcosmo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ShellAPI, BaseUtil, CosmoUtil;

type
  TfrmAboutCosmo = class(TForm)
    Image1: TImage;
    Label12: TLabel;
    LabelVersion: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    BitBtn1: TBitBtn;
    Label2: TLabel;
    Label1: TLabel;
    LabelMax: TLabel;
    procedure Label11Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAboutCosmo: TfrmAboutCosmo;

implementation

{$R *.DFM}

procedure TfrmAboutCosmo.Label11Click(Sender: TObject);
begin
ShellExecute(0,'open',PChar('mailto:ficedula@lycos.co.uk'),'','',SW_SHOW);
end;

procedure TfrmAboutCosmo.Label12Click(Sender: TObject);
begin
ShellExecute(0,'open',PChar('http://members.tripod.co.uk/ficedula/'),'','',SW_SHOW);
end;

procedure TfrmAboutCosmo.FormCreate(Sender: TObject);
begin
LabelVersion.Caption := 'Cosmo '+ReadVersionInfo+' by';
end;

procedure TfrmAboutCosmo.FormShow(Sender: TObject);
begin
LabelMax.Caption := MaxVerString;
end;

end.
