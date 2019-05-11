unit cosmoindex;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FF7Ed, LGPStruct, FFLzs, BaseUtil, ComCtrls, Buttons, FF7Edit,
  FF7Types;

type
  TfrmCosmoIndex = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtLGP: TEdit;
    btnLGP: TButton;
    opnLGP: TOpenDialog;
    btnScan: TBitBtn;
    btnCancel: TBitBtn;
    Progress: TProgressBar;
    lblCurrent: TLabel;
    procedure btnScanClick(Sender: TObject);
    procedure btnLGPClick(Sender: TObject);
  private
    { Private declarations }
    function ProcessFile(Data:TMemoryStream): String;
  public
    { Public declarations }
  end;

var
  frmCosmoIndex: TfrmCosmoIndex;

implementation

{$R *.DFM}

Uses TxtEdt;

function PointToStr(P:TPoint):String;
begin
P.X := Min(P.X,800);
P.Y := Min(P.Y,600);
Result := IntToStr(P.X)+'x'+IntToStr(P.Y);
end;


function TfrmCosmoIndex.ProcessFile(Data:TMemoryStream): String;
var
I:       Integer;
Lvl:     TFF7Level;
Item:    TFF7TextItem;
begin
Lvl := TFF7Level.CreateFromStream(Data);
Result := '';
try
For I := 0 to Lvl.NumTextItems-1 do begin
  Item := Lvl.TextItems[I];
  Result := Result + PointToStr(TextBlockSizeNeeded(Item.Name,Item.Text,(Item.TextType<>ff7Misc))) + ',';
end;
finally
Lvl.Free;
end;
end;

procedure TfrmCosmoIndex.btnScanClick(Sender: TObject);
var
Mem:TMemoryStream;
Fil:TFileStream;
LGP:TLGPFile;
S:String;
J,I:  Integer;
Ent:TLGP_Entry;
Rslt:TStringList;
begin
LGP := TLGPFile.CreateFromFile(edtLGP.Text,False);
Progress.Max := LGP.NumFiles;
Progress.Position := 0;
//Progress.Step := 1;
Fil := TFileStream.Create(edtLGP.Text,fmOpenRead or fmShareDenyNone);
Mem := TMemoryStream.Create;
Rslt := TStringList.Create;
//Rslt.LoadFromFile(ExtractFilePath(ParamStr(0))+'PREVIEW.IDX');

For I := 0 to LGP.NumFiles-1 do begin
  Ent := LGP[I];
  Progress.Position := I;
  lblCurrent.Caption := Ent.Filename; lblCurrent.Refresh;
  If Rslt.Values[Ent.Filename]<>'' then Continue;
  Mem.Clear;
  ExtractS(Fil,Ent,Mem);
  Mem.Position := 0;
  Mem.ReadBuffer(J,4);
  If J<>(Mem.Size-4) then Continue;

  try
  S := ProcessFile(Mem);
  except
  //So what?
  end;
  
  Rslt.Values[Ent.Filename] := S;
end;

Progress.Position := LGP.NumFiles;
lblCurrent.Caption := 'Done!'; lblCurrent.Refresh;

Mem.Free; Fil.Free; LGP.Free;

Rslt.SaveToFile(ExtractFilePath(ParamStr(0))+'PREVIEW.IDX');

frmTextView.PrevIndex.Assign(Rslt);

Rslt.Free;

end;

procedure TfrmCosmoIndex.btnLGPClick(Sender: TObject);
begin
If opnLGP.Execute then edtLGP.Text := opnLGP.Filename;
end;

end.
