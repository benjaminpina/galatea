unit NuevoJuegoAgentes;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources;

type

  { TfrmNuevoJuegoAgentes }

  TfrmNuevoJuegoAgentes = class(TForm)
    edtTitulo: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    memComentarios: TMemo;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNuevoJuegoAgentes: TfrmNuevoJuegoAgentes;

implementation

uses
  Multilenguaje;


procedure TfrmNuevoJuegoAgentes.FormCreate(Sender: TObject);
begin
  edtTitulo.Text := ML(mlSnTtl);
  memComentarios.Text := '';
end;

procedure TfrmNuevoJuegoAgentes.btbAceptarClick(Sender: TObject);
begin

end;

initialization
  {$i NuevoJuegoAgentes.lrs}
  {$i NuevoJuegoAgentes.lrs}

end.
