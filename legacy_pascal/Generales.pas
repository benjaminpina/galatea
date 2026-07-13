unit Generales;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Buttons, ComCtrls, LResources;

type

  { TfrmGenerales }

  TfrmGenerales = class(TForm)
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    chkAutoGuardado: TCheckBox;
    sedCiclos: TSpinEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtSustratos: TEdit;
    edtEscenarios: TEdit;
    edtEntornos: TEdit;
    edtProyectos: TEdit;
    btnSustratos: TButton;
    btnEscenarios: TButton;
    btnEntornos: TButton;
    btnProyectos: TButton;
    edtAgentes: TEdit;
    btnAgentes: TButton;
    GroupBox3: TGroupBox;
    chkRecordar: TCheckBox;
    GroupBox4: TGroupBox;
    chkInformar: TCheckBox;
    sedInformar: TSpinEdit;
    Label7: TLabel;
    GroupBox5: TGroupBox;
    Label8: TLabel;
    chkDetener: TCheckBox;
    sedDetener: TSpinEdit;
    Label9: TLabel;
    edtSalida: TEdit;
    btnSalida: TButton;
    GroupBox6: TGroupBox;
    Label10: TLabel;
    sedSalida: TSpinEdit;
    Label11: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure btnAceptarClick(Sender: TObject);
    procedure chkAutoGuardadoClick(Sender: TObject);
    procedure btnSustratosClick(Sender: TObject);
    procedure btnEscenariosClick(Sender: TObject);
    procedure btnAgentesClick(Sender: TObject);
    procedure btnEntornosClick(Sender: TObject);
    procedure btnProyectosClick(Sender: TObject);
    procedure chkInformarClick(Sender: TObject);
    procedure chkDetenerClick(Sender: TObject);
    procedure btnSalidaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGenerales: TfrmGenerales;

implementation

uses
  Principal, Multilenguaje, BuscarCarpeta, Comunes;


procedure TfrmGenerales.FormCreate(Sender: TObject);
var
  s: string;
begin
  with frmPrincipal.Temporizadores do
  begin
    chkAutoGuardado.Checked := Autoguardado;
    chkInformar.Checked := Informar;
    chkDetener.Checked := Detener;
    sedCiclos.Value := IntervaloAutoGuardado;
    sedInformar.Value := IntervaloInformar;
    sedDetener.Value := Detencion;
    sedSalida.Value := IntervaloSalida;
  end;
  sedCiclos.Enabled := chkAutoGuardado.Checked;
  sedInformar.Enabled := chkInformar.Checked;
  sedDetener.Enabled := chkDetener.Checked;
  with frmPrincipal.ArchivoInicio do
  begin
    chkRecordar.Checked := ReadBool('General', 'Recordar', True);
    s := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
    edtSustratos.Text := ReadString('Directorios', 'Sustratos', s);
    s := ExtractFilePath(Application.ExeName) + ML(mlEscenarios) + Diag;
    edtEscenarios.Text := ReadString('Directorios', 'Escenarios', s);
    s := ExtractFilePath(Application.ExeName) + ML(mlAgentes) + Diag;
    edtAgentes.Text := ReadString('Directorios', 'Agentes', s);
    s := ExtractFilePath(Application.ExeName) + ML(mlEntornos) + Diag;
    edtEntornos.Text := ReadString('Directorios', 'Entornos', s);
    s := ExtractFilePath(Application.ExeName) + ML(mlProyectos) + Diag;
    edtProyectos.Text := ReadString('Directorios', 'Proyectos', s);
    s := ExtractFilePath(Application.ExeName) + ML(mlSalida) + Diag;
    edtSalida.Text := ReadString('Directorios', 'Salida', s);
  end;
end;

procedure TfrmGenerales.TabSheet2ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmGenerales.btnAceptarClick(Sender: TObject);
begin
  with frmPrincipal.Temporizadores do
  begin
    Autoguardado := chkAutoGuardado.Checked;
    Informar := chkInformar.Checked;
    Detener := chkDetener.Checked;
    IntervaloAutoGuardado := StrToInt(sedCiclos.Text);
    IntervaloInformar := StrToInt(sedInformar.Text);
    IntervaloSalida := StrToInt(sedSalida.Text);
    Detencion := StrToInt(sedDetener.Text);
  end;
  with frmPrincipal.ArchivoInicio do
  begin
    WriteBool('General', 'Recordar', chkRecordar.Checked);
    WriteInteger('General', 'IntervaloAutoguardado', sedCiclos.Value);
    WriteInteger('General', 'IntervaloInformar', sedInformar.Value);
    WriteInteger('General', 'Detencion', sedDetener.Value);
    WriteInteger('General', 'IntervaloSalida', sedSalida.Value);
    WriteString('Directorios', 'Sustratos', edtSustratos.Text);
    WriteString('Directorios', 'Escenarios', edtEscenarios.Text);
    WriteString('Directorios', 'Agentes', edtAgentes.Text);
    WriteString('Directorios', 'Entornos', edtEntornos.Text);
    WriteString('Directorios', 'Proyectos', edtProyectos.Text);
    WriteString('Directorios', 'Salida', edtSalida.Text);
  end;
end;

procedure TfrmGenerales.chkAutoGuardadoClick(Sender: TObject);
begin
  sedCiclos.Enabled := chkAutoGuardado.Checked;
end;

procedure TfrmGenerales.btnSustratosClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlSustratos);
  frmBuscarCarpeta.Directorio := edtSustratos.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtSustratos.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

procedure TfrmGenerales.btnEscenariosClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlEscenarios);
  frmBuscarCarpeta.Directorio := edtEscenarios.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtEscenarios.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

procedure TfrmGenerales.btnAgentesClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlAgentes);
  frmBuscarCarpeta.Directorio := edtAgentes.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtAgentes.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

procedure TfrmGenerales.btnEntornosClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlEntornos);
  frmBuscarCarpeta.Directorio := edtEntornos.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtEntornos.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

procedure TfrmGenerales.btnProyectosClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlProyectos);
  frmBuscarCarpeta.Directorio := edtProyectos.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtProyectos.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

procedure TfrmGenerales.chkInformarClick(Sender: TObject);
begin
  sedInformar.Enabled := chkInformar.Checked;
end;

procedure TfrmGenerales.chkDetenerClick(Sender: TObject);
begin
  sedDetener.Enabled := chkDetener.Checked;
end;

procedure TfrmGenerales.btnSalidaClick(Sender: TObject);
begin
  frmBuscarCarpeta := TfrmBuscarCarpeta.Create(Application);
  frmBuscarCarpeta.Titulo := ML(mlArchSalida);
  frmBuscarCarpeta.Directorio := edtSalida.Text;
  if frmBuscarCarpeta.ShowModal = mrOK then
    edtSalida.Text := frmBuscarCarpeta.Directorio;
  frmBuscarCarpeta.Release;
end;

initialization
  {$i Generales.lrs}
  {$i Generales.lrs}

end.
