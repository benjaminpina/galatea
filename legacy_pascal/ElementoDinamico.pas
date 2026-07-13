unit ElementoDinamico;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Elementos, LResources;

type
  TfrmElementoDinamico = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    sttTipo: TStaticText;
    Label1: TLabel;
    edtNivel: TEdit;
    Label2: TLabel;
    edtCalidad: TEdit;
    Label5: TLabel;
    Label3: TLabel;
    edtMaximo: TEdit;
    edtTasa: TEdit;
    Label6: TLabel;
    edtNombre: TEdit;
    procedure edtNivelKeyPress(Sender: TObject; var Key: Char);
    procedure edtCalidadKeyPress(Sender: TObject; var Key: Char);
    procedure edtTasaKeyPress(Sender: TObject; var Key: Char);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtMaximoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure ActualizaValores;
  public
    { Public declarations }
    Dinamico: TDinamico;
    procedure DespliegaValores;
  end;

var
  frmElementoDinamico: TfrmElementoDinamico;

implementation

uses
  Multilenguaje;


procedure TfrmElementoDinamico.edtNivelKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmElementoDinamico.edtCalidadKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmElementoDinamico.edtTasaKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TfrmElementoDinamico.ActualizaValores;
begin
  with Dinamico do
  begin
    Nombre := edtNombre.Text;
    Nivel := StrToInt(edtNivel.Text);
    Calidad := StrToInt(edtCalidad.Text);
    Maximo := StrToInt(edtMaximo.Text);
    Tasa := StrToFloat(edtTasa.Text);
  end;
end;

procedure TfrmElementoDinamico.DespliegaValores;
begin
  with Dinamico do
  begin
    case TipoED of
      edFntAgua    : sttTipo.Caption := ML(mlFntAgua);
      edFntGrasa   : sttTipo.Caption := ML(mlFntGrasa);
      edFntAzucar  : sttTipo.Caption := ML(mlFntAzucar);
      edFntProteina: sttTipo.Caption := ML(mlFntPrtn);
    end;
    edtNombre.Text := Nombre;
    edtNivel.Text := IntToStr(Nivel);
    edtCalidad.Text := IntToStr(Calidad);
    edtMaximo.Text := IntToStr(Maximo);
    edtTasa.Text := FloatToStr(Tasa);
  end;
end;

procedure TfrmElementoDinamico.btbAceptarClick(Sender: TObject);
begin
  ActualizaValores;
end;

procedure TfrmElementoDinamico.edtMaximoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

initialization
  {$i ElementoDinamico.lrs}
  {$i ElementoDinamico.lrs}

end.
