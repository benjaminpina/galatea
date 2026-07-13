unit PantallaEscenario;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, LResources;

type
  TfrmPantallaEscenario = class(TForm)
    imgEscenario: TImage;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgEscenarioMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    PorcentajeActual: Word;
    procedure DibujaEscenario;
  public
    { Public declarations }
  end;

var
  frmPantallaEscenario: TfrmPantallaEscenario;

implementation

uses
  EditorEscenarios;


procedure TfrmPantallaEscenario.FormKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #27 then
    Self.Close;
end;

procedure TfrmPantallaEscenario.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  imgEscenario.Width := Self.Width;
  imgEscenario.Height := Self.Height;
  with frmEditorEscenarios.Escenario do
  begin
    PorcentajeActual := Porcentaje;
    for i := 5 downto 1 do
    begin
      Porcentaje := i * 20;
      if (imgEscenario.Width > AnchuraFisica)
        and (imgEscenario.Height > AlturaFisica) then
        Break; //->
    end;
  end;  //with
  DibujaEscenario;
end;

procedure TfrmPantallaEscenario.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmEditorEscenarios.Escenario.Porcentaje := PorcentajeActual;
end;

procedure TfrmPantallaEscenario.DibujaEscenario;
var
  i, j: Integer;
begin
  with frmEditorEscenarios.Escenario do
  begin
    imgEscenario.Canvas.Pen.Style := psSolid;
   // imgEscenario.Canvas.Pen.Color := clBlack;
    imgEscenario.Canvas.Brush.Style := bsSolid;
    //imgEscenario.Width := AnchuraFisica;
    //imgEscenario.Height := AlturaFisica;
    for i := 1 to Anchura do
      for j := 1 to Altura do
      begin
        imgEscenario.Canvas.Brush.Color := ObtenColorSustrato(Cuadro[i,j]);
        imgEscenario.Canvas.Pen.Color := ObtenColorSustrato(Cuadro[i,j]);
        imgEscenario.Canvas.Rectangle(XFisica(i) , YFisica(j),
                  XFisica(i) + CuadroFisico, YFisica(j) + CuadroFisico);
      end;
  end;
end;

procedure TfrmPantallaEscenario.imgEscenarioMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Self.Close;
end;

initialization
  {$i PantallaEscenario.lrs}
  {$i PantallaEscenario.lrs}

end.
