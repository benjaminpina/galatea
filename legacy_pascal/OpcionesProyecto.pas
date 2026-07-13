unit OpcionesProyecto;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, LResources;

type

  { TfrmOpcionesProyecto }

  TfrmOpcionesProyecto = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    edtTitulo: TEdit;
    memComentarios: TMemo;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
  public
    { Public declarations }
  end;

var
  frmOpcionesProyecto: TfrmOpcionesProyecto;

implementation

uses
  SeleccionaEntorno;


procedure TfrmOpcionesProyecto.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := '';
  memComentarios.Text := '';
  PuedeCerrar := True;
end;

procedure TfrmOpcionesProyecto.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmOpcionesProyecto.btbAceptarClick(Sender: TObject);
begin

end;

initialization
  {$i OpcionesProyecto.lrs}
  {$i OpcionesProyecto.lrs}

end.
