unit PropiedadesEscenarios;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPropiedadesEscenario: TfrmPropiedadesEscenario;

implementation

{$R *.dfm}

uses
  Editor;

end.
