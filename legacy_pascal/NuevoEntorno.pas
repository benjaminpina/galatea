unit NuevoEntorno;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, LResources;

type

  { TfrmNuevoEntorno }

  TfrmNuevoEntorno = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtTitulo: TEdit;
    edtEscenario: TEdit;
    memComentarios: TMemo;
    btnEscenario: TButton;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    Label4: TLabel;
    edtAgentes: TEdit;
    btnAgentes: TButton;
    edtCiclos: TEdit;
    Label5: TLabel;
    odlEscenario: TOpenDialog;
    odlAgentes: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnEscenarioClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbAceptarClick(Sender: TObject);
    procedure btnAgentesClick(Sender: TObject);
    procedure edtCiclosKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
  public
    { Public declarations }
  end;

var
  frmNuevoEntorno: TfrmNuevoEntorno;

implementation

uses
  Multilenguaje, Dialogos, SeleccionarEscenario, SeleccionarJuegoAgentes,
  Comunes;


procedure TfrmNuevoEntorno.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := ML(mlSnTtl);
  edtEscenario.Text := '';
  edtAgentes.Text := '';
  edtCiclos.Text := '0';
  memComentarios.Text := '';
  PuedeCerrar := True;
end;

procedure TfrmNuevoEntorno.btnEscenarioClick(Sender: TObject);
var
  RutaEscenario: string;
begin
  RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios)+ Diag;
  if DirectoryExists(RutaEscenario) then
    odlEscenario.InitialDir := RutaEscenario;
  if odlEscenario.Execute then
     edtEscenario.Text := odlEscenario.FileName;
  {frmSeleccionarEscenario := TfrmSeleccionarEscenario.Create(Application);
  if  frmSeleccionarEscenario.ShowModal = mrOK then
    edtEscenario.Text := frmSeleccionarEscenario.NombreArchivo;
  FreeAndNil(frmSeleccionarEscenario); }
end;

procedure TfrmNuevoEntorno.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmNuevoEntorno.btbAceptarClick(Sender: TObject);
begin
  if not FileExists(edtEscenario.Text) then
  begin
    Fallo(ML(mlErrFltEs), ML(mlEdEntGlt));
    edtEscenario.SetFocus;
    PuedeCerrar := False;
    Exit; //-->
  end;
  if not FileExists(edtAgentes.Text) then
  begin
    Fallo(ML(mlFltJgAgnts), ML(mlEdEntGlt));
    edtAgentes.SetFocus;
    PuedeCerrar := False;
  end;
end;

procedure TfrmNuevoEntorno.btnAgentesClick(Sender: TObject);
var
  RutaAgentes: string;
begin
  RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes)+ Diag;
  if DirectoryExists(RutaAgentes) then
    odlAgentes.InitialDir := RutaAgentes;
  if odlAgentes.Execute then
    edtAgentes.Text := odlAgentes.FileName;
  {frmSeleccionarJuegoAgentes := TfrmSeleccionarJuegoAgentes.Create(Application);
  if frmSeleccionarJuegoAgentes.ShowModal = mrOK then
    edtAgentes.Text := frmSeleccionarJuegoAgentes.NombreArchivo;
  FreeAndNil(frmSeleccionarJuegoAgentes);}
end;

procedure TfrmNuevoEntorno.edtCiclosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

initialization
  {$i NuevoEntorno.lrs}

end.
