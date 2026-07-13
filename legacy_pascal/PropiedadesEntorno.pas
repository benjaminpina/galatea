unit PropiedadesEntorno;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, LResources;

type
  TfrmPropiedadesEntorno = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    edtTitulo: TEdit;
    memComentarios: TMemo;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    Label5: TLabel;
    edtCiclos: TEdit;
    procedure edtCiclosKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Importavalores;
    procedure ExportaValores;
  end;

var
  frmPropiedadesEntorno: TfrmPropiedadesEntorno;

implementation

uses
  EditorEntornos;


procedure TfrmPropiedadesEntorno.edtCiclosKeyPress(Sender: TObject;
  var Key: Char);
begin
   if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmPropiedadesEntorno.ExportaValores;
begin
  frmEditorEntornos.Entorno.Titulo := edtTitulo.Text;
  frmEditorEntornos.Entorno.Ciclos := StrToInt(edtCiclos.Text);
  frmEditorEntornos.Entorno.Comentarios := memComentarios.Text;
end;

procedure TfrmPropiedadesEntorno.Importavalores;
begin
  edtTitulo.Text := frmEditorEntornos.Entorno.Titulo;
  edtCiclos.Text := IntToStr(frmEditorEntornos.Entorno.Ciclos);
  memComentarios.Text := frmEditorEntornos.Entorno.Comentarios;
end;

procedure TfrmPropiedadesEntorno.FormCreate(Sender: TObject);
begin
  Importavalores;
end;

procedure TfrmPropiedadesEntorno.btbAceptarClick(Sender: TObject);
begin
  ExportaValores;
end;

initialization
  {$i PropiedadesEntorno.lrs}
  {$i PropiedadesEntorno.lrs}

end.
