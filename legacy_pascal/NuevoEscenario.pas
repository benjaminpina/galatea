unit NuevoEscenario;

{$MODE Delphi}

{*******************************************************************************
Cuadro de diálogo para crear nuevo escenario.
Proyecto: EdEsGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, SeleccionaJuego, LResources;

type

  { TfrmNuevoEscenario }

  TfrmNuevoEscenario = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtTitulo: TEdit;
    edtAltura: TEdit;
    edtAnchura: TEdit;
    cmbSustrato: TComboBox;
    memComentarios: TMemo;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    Label6: TLabel;
    edtJuego: TEdit;
    btnSeleccionaJuego: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbAceptarClick(Sender: TObject);
    procedure btbCancelarClick(Sender: TObject);
    procedure btnSeleccionaJuegoClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar : Boolean;
    function Valida: Boolean;
  public
    { Public declarations }
    procedure ExportaValores;
  end;

var
  frmNuevoEscenario: TfrmNuevoEscenario;
  Altura,
  Anchura : Integer;

implementation


uses
 EditorEscenarios, Multilenguaje, Comunes, Dialogos;

procedure TfrmNuevoEscenario.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := ML(mlSnTtl);
  edtAltura.Text := '50';
  edtAnchura.Text := '50';
  edtJuego.Text := '';
  memComentarios.Text := '';
  PuedeCerrar := True;
end;

procedure TfrmNuevoEscenario.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
end;

function TfrmNuevoEscenario.Valida: Boolean;
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
  if edtJuego.Text = '' then
  begin
    Fallo(ML(mlErrFltJS), ML(mlEdEsGl));//falta archivo de juego sustratos
    edtJuego.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  if not FileExists(edtJuego.Text) then
  begin
    Fallo(ML(mlErrArchvNE), ML(mlEdEsGl));//archivo de juego sustratos no existe
    edtJuego.SetFocus;
    PuedeCerrar := False;
    Result := False;
    exit; //-->
  end;
  PuedeCerrar := True;
  Result := True;
end;

procedure TfrmNuevoEscenario.btbAceptarClick(Sender: TObject);
begin
  Valida;
end;

procedure TfrmNuevoEscenario.btbCancelarClick(Sender: TObject);
begin
  PuedeCerrar := True;
end;

procedure TfrmNuevoEscenario.btnSeleccionaJuegoClick(Sender: TObject);
//var
  //i: Integer;
var
  RutaSustrato: string;
begin
  {frmSeleccionaJuego := TfrmSeleccionaJuego.Create(Self);
  if frmSeleccionaJuego.ShowModal = mrOK then
  begin
    edtJuego.Text := frmSeleccionaJuego.NombreArchivo;
    cmbSustrato.Clear;
    for i := 1 to 7 do
      cmbSustrato.Items.Add(IntToStr(i) + ' '
                  + frmSeleccionaJuego.JuegoSustratos.SustratoSimple[i].Nombre);
    cmbSustrato.ItemIndex := 0;
  end;
  FreeAndNil(frmSeleccionaJuego); }
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    OpenDialog1.InitialDir := RutaSustrato;
  if OpenDialog1.Execute then
    edtJuego.Text := OpenDialog1.FileName;
end;

procedure TfrmNuevoEscenario.ExportaValores;
begin
  with frmEditorEscenarios do
  begin
    Escenario.Titulo := edtTitulo.Text;
    Escenario.Altura := Altura;
    Escenario.Anchura := Anchura;
    Escenario.Comentarios := memComentarios.Text;
    Escenario.JuegoSustratos.Carga(edtJuego.Text);
    SustratoBase := Chr(cmbSustrato.ItemIndex + 49);
  end;
end;

initialization
  {$i NuevoEscenario.lrs}
  {$i NuevoEscenario.lrs}

end.
