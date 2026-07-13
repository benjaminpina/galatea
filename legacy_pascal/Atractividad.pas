unit Atractividad;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources, Menus;

type

  { TfrmAtractividad }

  TfrmAtractividad = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    Label16: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label1: TLabel;
    edtAtractividad: TEdit;
    edtRadio: TEdit;
    Label3: TLabel;
    chbInicializar: TCheckBox;
    procedure btbAceptarClick(Sender: TObject);
    procedure edtAtractividadDblClick(Sender: TObject);
    procedure edtAtractividadMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtRadioDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtRadioMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FTitulo: string;
    { Private declarations }
    procedure ConstruyeCelda;
    procedure SetTitulo(const Value: string);
  public
    { Public declarations }
    Adulto: Boolean;
    InteraccionAgente: Boolean;
    Dinamico: Boolean;
    Celda: string;
    procedure Despliega;
    property Titulo: string
      read FTitulo write SetTitulo;
  end;

var
  frmAtractividad: TfrmAtractividad;

implementation

uses
  Comunes, EditorFormulas, EditorNotas, Multilenguaje;


{ TfrmAtractividad }

procedure TfrmAtractividad.ConstruyeCelda;
begin
  Celda := edtAtractividad.Text + ',' + edtRadio.Text;
end;

procedure TfrmAtractividad.Despliega;
begin
  edtAtractividad.Text := ObtenNsimo(Celda,1);
  edtRadio.Text := ObtenNsimo(Celda,2);
end;

procedure TfrmAtractividad.btbAceptarClick(Sender: TObject);
begin
  ConstruyeCelda;
end;

procedure TfrmAtractividad.edtAtractividadDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAtractividad.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlAtractividad);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAtractividad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;


procedure TfrmAtractividad.edtAtractividadMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAtractividad.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlAtractividad);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAtractividad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmAtractividad.edtRadioDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRadio.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlRdPrcpcn);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRadio.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmAtractividad.FormCreate(Sender: TObject);
begin
  Adulto := True;
  InteraccionAgente := False;
  Dinamico := False;
end;

procedure TfrmAtractividad.edtRadioMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRadio.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlRdPrcpcn);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRadio.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmAtractividad.SetTitulo(const Value: string);
begin
  FTitulo := Value;
  Self.Caption := ML(mlAtractividad) + ' [' + FTitulo + ']';
end;

initialization
  {$i Atractividad.lrs}

end.
