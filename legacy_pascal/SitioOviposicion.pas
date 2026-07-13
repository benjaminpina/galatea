unit SitioOviposicion;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Elementos, LResources;

type
  TfrmSitioOviposicion = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    edtCalidad: TEdit;
    edtMaximo: TEdit;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    sttNivel: TStaticText;
    procedure edtCalidadKeyPress(Sender: TObject; var Key: Char);
    procedure edtMaximoKeyPress(Sender: TObject; var Key: Char);
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
     procedure ActualizaValores;
  public
    { Public declarations }
    Oviposicion: TSitioOviposicion;
    procedure DespliegaValores;
  end;

var
  frmSitioOviposicion: TfrmSitioOviposicion;

implementation


{ TfrmSitioOviposicion }

procedure TfrmSitioOviposicion.ActualizaValores;
begin
  Oviposicion.Calidad := StrToInt(edtCalidad.Text);
  Oviposicion.Maximo := StrToInt(edtMaximo.Text);
end;

procedure TfrmSitioOviposicion.DespliegaValores;
begin
  with Oviposicion do
  begin
    sttNivel.Caption := IntToStr(Nivel);
    edtCalidad.Text := IntToStr(Calidad);
    edtMaximo.Text := IntToStr(Maximo);
  end;
end;

procedure TfrmSitioOviposicion.edtCalidadKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmSitioOviposicion.edtMaximoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmSitioOviposicion.btbAceptarClick(Sender: TObject);
begin
  ActualizaValores;
end;

initialization
  {$i SitioOviposicion.lrs}
  {$i SitioOviposicion.lrs}

end.
