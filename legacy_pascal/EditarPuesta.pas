unit EditarPuesta;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, LResources;

type
  TfrmEditarPuesta = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    cmbPadre: TComboBox;
    cmbMadre: TComboBox;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    edtNumero: TEdit;
    UpDown1: TUpDown;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    edtEdad: TEdit;
    Label5: TLabel;
    procedure edtNumeroKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtEdadKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FTitulo: string;
    FTamanoOmision: Integer;
    { Private declarations }
    procedure LlenaListas;
    procedure SetTitulo(const Value: string);
    procedure SetTamanoOmision(const Value: Integer);
  public
    { Public declarations }
    Veces,
    Edad: Word;
    Padre,
    Madre: string;
    property Titulo: string
      read FTitulo write SetTitulo;
    property TamanoOmision: Integer read FTamanoOmision write SetTamanoOmision;
  end;

var
  frmEditarPuesta: TfrmEditarPuesta;

implementation

uses
  EditorEntornos, Entornos, Comunes, Mediadores, Multilenguaje;


procedure TfrmEditarPuesta.edtNumeroKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarPuesta.FormCreate(Sender: TObject);
begin
  LlenaListas;
end;

procedure TfrmEditarPuesta.btbAceptarClick(Sender: TObject);
begin
  Veces := StrToInt(edtNumero.Text);
  Edad := StrToInt(edtEdad.Text);
  Padre := Copy(cmbPadre.Text, 1, 10);
  Madre := Copy(cmbMadre.Text, 1, 10);
end;

procedure TfrmEditarPuesta.LlenaListas;
var
  i: Integer;
  Mediador: TMediador;
begin
  with frmEditorEntornos.Entorno do
  begin
    for i := 1 to ListaAgentes.Contador do
      if ListaAgentes.Elementos[i].Adulto then
        case ListaAgentes.Elementos[i].Sexo of
          sxMacho:
          begin
            Mediador := TMediador.Create(frmEditorEntornos.Entorno);
            cmbPadre.Items.Add(ListaAgentes.Elementos[i].Nombre
                + '[' + Mediador.NombrePrototipo + ']');
            Mediador.Free;
          end;
          sxHembra:
          begin
            Mediador := TMediador.Create(frmEditorEntornos.Entorno);
            cmbMadre.Items.Add(ListaAgentes.Elementos[i].Nombre + '['
                + Mediador.NombrePrototipo + ']');
            Mediador.Free;
          end;
        end;
  end;
end;

procedure TfrmEditarPuesta.edtEdadKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarPuesta.SetTitulo(const Value: string);
begin
  FTitulo := Value;
  Self.Caption := ML(mlLlnrCld) + ' [' + FTitulo + ']';
end;

procedure TfrmEditarPuesta.SetTamanoOmision(const Value: Integer);
begin
  FTamanoOmision := Value;
  edtNumero.Text := IntToStr(Value);
end;

procedure TfrmEditarPuesta.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FTamanoOmision := StrToInt(edtNumero.Text);
end;

initialization
  {$i EditarPuesta.lrs}
  {$i EditarPuesta.lrs}

end.
