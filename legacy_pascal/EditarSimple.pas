unit EditarSimple;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Sustratos, ExtCtrls, LResources;

type
  TfrmEditarSimple = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtNombre: TEdit;
    lblNumero: TLabel;
    btnColor: TButton;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    ColorDialog1: TColorDialog;
    shpColor: TShape;
    procedure btnColorClick(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtNombreKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    Indice: Integer;
  end;

var
  frmEditarSimple: TfrmEditarSimple;

implementation

uses
 EditorSustratos;


procedure TfrmEditarSimple.btnColorClick(Sender: TObject);
begin
  if ColorDialog1.Execute then
    shpColor.Brush.Color := ColorDialog1.Color;
end;

procedure TfrmEditarSimple.btbAceptarClick(Sender: TObject);
var
  Simple: TSustratoSimple;
begin
  Simple.Nombre := edtNombre.Text;
  Simple.Color := shpColor.Brush.Color;
  frmEditorSustratos.JuegoSustratos.SustratoSimple[Indice] := Simple;
end;

procedure TfrmEditarSimple.edtNombreKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', 'a'..'z', 'A'..'Z', '_', #8]) then
    Key := #0;
end;

initialization
  {$i EditarSimple.lrs}

end.
