unit cosmosplash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Jpeg;

type
  TfrmSplash = class(TForm)
    imgColour: TImage;
    imgGrey: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    PC:     Integer;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
    procedure SetPCDone(Val:Integer);
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.DFM}

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
PC := 0;
end;

procedure TfrmSplash.SetPCDone(Val:Integer);
begin
//PC := Val;
Repaint;
end;

procedure TfrmSplash.FormPaint(Sender: TObject);
begin
//Canvas.CopyRect(Rect(0,0,Trunc(Width*PC/100),Height),imgColour.Picture.Bitmap.Canvas,Rect(0,0,Trunc(Width*PC/100),Height));
//Canvas.CopyRect(Rect(Trunc(Width*PC/100),0,Width,Height),imgGrey.Picture.Bitmap.Canvas,Rect(Trunc(Width*PC/100),0,Width,Height));
end;

procedure TfrmSplash.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
//Message.Result := 1;
end;

end.
