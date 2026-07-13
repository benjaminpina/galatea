unit NuevoEntono;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls;

type
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
    procedure FormCreate(Sender: TObject);
    procedure btnEscenarioClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbAceptarClick(Sender: TObject);
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
  Multilenguaje, Dialogos, SeleccionarEscenario;

{$R *.dfm}

procedure TfrmNuevoEntorno.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := ML(mlSnTtl);
  edtEscenario.Text := '';
  memComentarios.Text := '';
  PuedeCerrar := True;
end;

procedure TfrmNuevoEntorno.btnEscenarioClick(Sender: TObject);
begin
  frmSeleccionarEscenario := TfrmSeleccionarEscenario.Create(Self);
  if  frmSeleccionarEscenario.ShowModal = mrOK then
    edtEscenario.Text := frmSeleccionarEscenario.NombreArchivo;
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
  end;
end;

end.
