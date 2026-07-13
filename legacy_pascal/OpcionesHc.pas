unit OpcionesHc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TfrmOpcionesHc = class(TForm)
    PageControl1: TPageControl;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    edtTitulo: TEdit;
    memComentarios: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cmbNeutro: TComboBox;
    cmbOviposicion: TComboBox;
    cmbAlimenticio: TComboBox;
    cmbRepulsivo: TComboBox;
    TabSheet4: TTabSheet;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edtFuentes: TEdit;
    edtMachos: TEdit;
    edtHembras: TEdit;
    StaticText1: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAceptarClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    function Valida: Boolean;
    procedure DespliegaDatos;
  public
    { Public declarations }
    wAgentes,
    wFuentes,
    wMachos,
    wHembras: Word;
  end;

var
  frmOpcionesHc: TfrmOpcionesHc;

implementation

uses
  Principal, Proyectos, Multilenguaje, Dialogos, Escenarios;

{$R *.dfm}

procedure TfrmOpcionesHc.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  DespliegaDatos;
  PuedeCerrar := True;
end;

function TfrmOpcionesHc.Valida: Boolean;
var
  s   : string;
  i ,c: Integer;
  Max,
  Min : Word;
begin
  with frmPrincipal.ProyectoHc.Escenario do
  begin
    Max := (Altura * Anchura) div 3;
    Min := 1;
    s := edtFuentes.Text;
    Val(s, i, c);
    if (c <> 0) or (s = '') then
    begin
      Fallo(ML(mlErrNVld), 'Galatea');
      Result := False;
      edtFuentes.SetFocus;
      Exit; //-->
    end;
    if (i > Max) or (i < Min) then
    begin
      Fallo(ML(mlErrVlMyMn) + '(' + IntToStr(Min) + '-'
                                  + IntToStr(Max) + ')', 'Galatea');
      Result := False;
      edtFuentes.SetFocus;
      Exit; //-->
    end;
    wFuentes := i;
  end; //with
  s := edtMachos.Text;
  Val(s, i, c);
  if (c <> 0) or (s = '') then
  begin
    Fallo(ML(mlErrNVld), 'Galatea');
    Result := False;
    edtMachos.SetFocus;
    Exit; //-->
  end;
  if (i < 0) then
  begin
    Fallo(ML(mlErrNeg), 'Galatea');
    Result := False;
    edtMachos.SetFocus;
    Exit; //-->
  end;
  wMachos := i;
  s := edtHembras.Text;
  Val(s, i, c);
  if (c <> 0) or (s = '') then
  begin
    Fallo(ML(mlErrNVld), 'Galatea');
    Result := False;
    edtHembras.SetFocus;
    Exit; //-->
  end;
  if (i < 0) then
  begin
    Fallo(ML(mlErrNeg), 'Galatea');
    Result := False;
    edtHembras.SetFocus;
    Exit; //-->
  end;
  wHembras := i;
  Result := True;
end;

procedure TfrmOpcionesHc.DespliegaDatos;
var
  i: Integer;
begin
  with frmPrincipal.ProyectoHc do
  begin
    edtTitulo.Text := Titulo;
    memComentarios.Text := Comentarios;
    edtFuentes.Text := IntToStr(NumFuentes);
    edtMachos.Text := IntToStr(Proporcion.Machos);
    edtHembras.Text := IntToStr(Proporcion.Hembras);
    cmbNeutro.Clear;
    cmbOviposicion.Clear;
    cmbAlimenticio.Clear;
    cmbRepulsivo.Clear;
    for i := 1 to 7 do
    begin
      cmbNeutro.Items.Add
                    (Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
      cmbOviposicion.Items.Add
                    (Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
      cmbAlimenticio.Items.Add
                    (Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
      cmbRepulsivo.Items.Add
                    (Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
    end;
    cmbNeutro.ItemIndex := Ord(SustNeutro) - 49;
    cmbOviposicion.ItemIndex := Ord(SustOviposicion) - 49;
    cmbAlimenticio.ItemIndex := Ord(SustAlimenticio) - 49;
    cmbRepulsivo.ItemIndex  := Ord(SustRepulsivo) - 49;
  end;
end;

procedure TfrmOpcionesHc.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmOpcionesHc.btnCancelarClick(Sender: TObject);
begin
  PuedeCerrar := True;
end;

procedure TfrmOpcionesHc.btnAceptarClick(Sender: TObject);
begin
  PuedeCerrar := Valida;
end;

end.
