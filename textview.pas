unit textview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ffctrl;

type
  TForm1 = class(TForm)
    ilsFF7: TImageList;
    Edit1: TEdit;
    Button1: TButton;
    FFPanel1: TFFPanel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

Const
  Text_Sizes: Array [0..94] of Integer =
  (10,06,10,20,14,20,18,06,10,10,14,
  14,08,10,06,14,16,10,16,16,16,
  16,16,16,16,16,06,08,14,16,14,12,
  20,18,14,16,16,14,14,16,16,06,
  12,14,14,22,16,18,14,18,14,14,14,
  16,18,22,16,18,14,08,12,08,14,
  16,08,14,14,12,14,14,12,14,14,06,
  08,12,06,22,14,14,14,14,10,12,
  12,14,14,22,14,16,12,10,06,10,16);

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
S:      String;
I,J:    Integer;
begin
S := Edit1.Text; J := 0;
While S<>'' do begin
  I := Byte(S[1]);
  Delete(S,1,1);
  ilsFF7.Overlay(I-32,0);
  ilsFF7.DrawOverlay(Canvas,J,0,I-32,0);
  Inc(J,Text_Sizes[I-32]-1);
end;

end;

end.
