unit PropiedadesJuegoAgentes;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources;

type

  { TfrmPropiedadesJuegoAgentes }

  TfrmPropiedadesJuegoAgentes = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    edtTitulo: TEdit;
    memComentarios: TMemo;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPropiedadesJuegoAgentes: TfrmPropiedadesJuegoAgentes;

implementation


{ TfrmPropiedadesJuegoAgentes }

procedure TfrmPropiedadesJuegoAgentes.btbAceptarClick(Sender: TObject);
begin

end;

initialization
  {$i PropiedadesJuegoAgentes.lrs}

end.
