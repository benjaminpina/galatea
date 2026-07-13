unit NuevoProyecto;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, LResources;

type

  { TfrmNuevoProyecto }

  TfrmNuevoProyecto = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtTitulo: TEdit;
    edtEntorno: TEdit;
    memComentarios: TMemo;
    btnEntorno: TButton;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure btnEntornoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
  public
    { Public declarations }
  end;

var
  frmNuevoProyecto: TfrmNuevoProyecto;

implementation

uses
  SeleccionaEntorno, Dialogos, Multilenguaje, Comunes;


procedure TfrmNuevoProyecto.btnEntornoClick(Sender: TObject);
var
  RutaEntornos: string;
begin
  RutaEntornos := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ Diag;
  if DirectoryExists(RutaEntornos) then
    OpenDialog1.FileName := RutaEntornos;
  if OpenDialog1.Execute then
     edtEntorno.Text := OpenDialog1.FileName;
  {frmSeleccionaEntorno := TfrmSeleccionaEntorno.Create(Self);
  if frmSeleccionaEntorno.ShowModal = mrOK then
    edtEntorno.Text := frmSeleccionaEntorno.NombreArchivo; }
end;

procedure TfrmNuevoProyecto.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := ML(mlSnTtl);
  edtEntorno.Text := '';
  memComentarios.Text := '';
  PuedeCerrar := True;
end;

procedure TfrmNuevoProyecto.btbAceptarClick(Sender: TObject);
begin
  if not FileExists(edtEntorno.Text) then
  begin
    Fallo(ML(mlFltArchEntrn), 'Galatea');
    PuedeCerrar := False;
    edtEntorno.SetFocus;
  end;
end;

procedure TfrmNuevoProyecto.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

initialization
  {$i NuevoProyecto.lrs}
  {$i NuevoProyecto.lrs}

end.
