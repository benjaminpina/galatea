unit PropiedadesEscenario;

{$MODE Delphi}

{*******************************************************************************
Cuadro de diálogo para modificar las propiedades del escenario actual.
Proyecto: EdEsGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources;

type
  TfrmPropiedadesEscenario = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    edtTitulo: TEdit;
    edtAltura: TEdit;
    edtAnchura: TEdit;
    memComentarios: TMemo;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    Label4: TLabel;
    cmbSustrato: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbAceptarClick(Sender: TObject);
    procedure btbCancelarClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar : Boolean;
    function Valida: Boolean;
  public
    { Public declarations }
  end;

var
  frmPropiedadesEscenario: TfrmPropiedadesEscenario;
  Altura,
  Anchura : Integer;

implementation


uses
  EditorEscenarios, Multilenguaje, Dialogos;

procedure TfrmPropiedadesEscenario.btbAceptarClick(Sender: TObject);
begin
  if Valida then
    with frmEditorEscenarios do
    begin
      Escenario.Titulo := edtTitulo.Text;
      Escenario.Altura := Altura;
      Escenario.Anchura := Anchura;
      Escenario.Comentarios := memComentarios.Text;
      SustratoBase := Chr(cmbSustrato.ItemIndex + 49);
    end;
end;

procedure TfrmPropiedadesEscenario.btbCancelarClick(Sender: TObject);
begin
  PuedeCerrar := True;
end;

procedure TfrmPropiedadesEscenario.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
end;

procedure TfrmPropiedadesEscenario.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := frmEditorEscenarios.Escenario.Titulo;
  edtAltura.Text := IntToStr(frmEditorEscenarios.Escenario.Altura);
  edtAnchura.Text := IntToStr(frmEditorEscenarios.Escenario.Anchura);
  memComentarios.Text := frmEditorEscenarios.Escenario.Comentarios;
  PuedeCerrar := True;
end;

function TfrmPropiedadesEscenario.Valida: Boolean;
var
  c : Integer;
begin
  Val(edtAltura.Text, Altura, c);
  if c <> 0 then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdEsGl));  //valor incorrecto
    edtAltura.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  Val(edtAnchura.Text, Anchura, c);
  if c <> 0 then
   begin
    Fallo(ML(mlErrNVld), ML(mlEdEsGl));//valor incorrecto
    edtAnchura.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  if Altura < 50 then
  begin
    Fallo(ML(mlErrMinPer) + '50.', ML(mlEdEsGl)); //valor menor al permitido
    edtAltura.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  if Anchura < 50 then
  begin
    Fallo(ML(mlErrMinPer) + ' 50.', ML(mlEdEsGl));//valor menor al permitido
    edtAnchura.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  PuedeCerrar := True;
  Result := True;
end;

initialization
  {$i PropiedadesEscenario.lrs}
  {$i PropiedadesEscenario.lrs}

end.
