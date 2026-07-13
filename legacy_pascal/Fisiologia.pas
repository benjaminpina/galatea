unit Fisiologia;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Grids, LResources;

type

  { TfrmFisiologia }

  TfrmFisiologia = class(TForm)
    btbCancelar: TBitBtn;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    stgMetabolismo: TStringGrid;
    stgMovimiento: TStringGrid;
    stgVelocidad: TStringGrid;
    stgAlimentacion: TStringGrid;
    stgCombate: TStringGrid;
    stgCortejo: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    btbAceptar: TBitBtn;
    Label16: TLabel;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    Label3: TLabel;
    edtMaximoH: TEdit;
    Label1: TLabel;
    edtMaximoP: TEdit;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtAguaH: TEdit;
    edtGrasaH: TEdit;
    edtAzucarH: TEdit;
    edtProteinasH: TEdit;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edtAguaP: TEdit;
    edtGrasaP: TEdit;
    edtAzucarP: TEdit;
    edtProteinasP: TEdit;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    edtEsperma: TEdit;
    edtMaxPaquetes: TEdit;
    edtConsumoPaquete: TEdit;
    GroupBox9: TGroupBox;
    Label29: TLabel;
    Label30: TLabel;
    edtFertilizados: TEdit;
    edtPaternidad: TEdit;
    GroupBox8: TGroupBox;
    Label31: TLabel;
    edtHuevos: TEdit;
    TabSheet5: TTabSheet;
    GroupBox10: TGroupBox;
    GroupBox11: TGroupBox;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    edtAgua: TEdit;
    edtAzucar: TEdit;
    edtGrasa: TEdit;
    edtProteina: TEdit;
    spbNotas: TSpeedButton;
    btnImportar: TButton;
    GroupBox12: TGroupBox;
    Label32: TLabel;
    edtFraccionPaquete: TEdit;
    Label33: TLabel;
    edtFraccionHuevo: TEdit;
    Label11: TLabel;
    edtDegradacion: TEdit;
    procedure edtAguaDblClick(Sender: TObject);
    procedure edtAguaHDblClick(Sender: TObject);
    procedure edtAguaPDblClick(Sender: TObject);
    procedure edtAzucarDblClick(Sender: TObject);
    procedure edtAzucarHDblClick(Sender: TObject);
    procedure edtAzucarPDblClick(Sender: TObject);
    procedure edtConsumoPaqueteDblClick(Sender: TObject);
    procedure edtDegradacionDblClick(Sender: TObject);
    procedure edtEspermaDblClick(Sender: TObject);
    procedure edtFertilizadosDblClick(Sender: TObject);
    procedure edtFraccionHuevoDblClick(Sender: TObject);
    procedure edtFraccionPaqueteDblClick(Sender: TObject);
    procedure edtGrasaDblClick(Sender: TObject);
    procedure edtGrasaHDblClick(Sender: TObject);
    procedure edtGrasaPDblClick(Sender: TObject);
    procedure edtHuevosDblClick(Sender: TObject);
    procedure edtMaximoHDblClick(Sender: TObject);
    procedure edtMaximoPDblClick(Sender: TObject);
    procedure edtMaxPaquetesDblClick(Sender: TObject);
    procedure edtPaternidadDblClick(Sender: TObject);
    procedure edtProteinaDblClick(Sender: TObject);
    procedure edtProteinasHDblClick(Sender: TObject);
    procedure edtProteinasPDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtAguaHMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAguaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAguaPMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAzucarHMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAzucarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAzucarPMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtConsumoPaqueteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtDegradacionMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtEspermaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtFertilizadosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtFraccionHuevoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtFraccionPaqueteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtGrasaHMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtGrasaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtGrasaPMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtHuevosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMaxPaquetesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMaximoHMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMaximoPMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtPaternidadMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtProteinaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtProteinasHMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtProteinasPMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl1Change(Sender: TObject);
    procedure stgMetabolismoDblClick(Sender: TObject);
    procedure stgMovimientoDblClick(Sender: TObject);
    procedure stgVelocidadDblClick(Sender: TObject);
    procedure stgAlimentacionDblClick(Sender: TObject);
    procedure stgCombateDblClick(Sender: TObject);
    procedure stgCortejoDblClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure ExportaValores;
    procedure Encabezados;
  public
    { Public declarations }
  end;

var
  frmFisiologia: TfrmFisiologia;

implementation

uses
  Multilenguaje, EditorAgentes, EditorFormulas, EditorNotas,
  Sustratos, SeleccionaJuego, Comunes;


procedure TfrmFisiologia.ExportaValores;
var
  i, j: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to 5 do
      for j := 1 to 4 do
        Metabolismo[i,j] := stgMetabolismo.Cells[i,j];
    MaxHuevos := edtMaximoH.Text;
    CostoHuevo[1] := edtAguaH.Text;
    CostoHuevo[2] := edtAzucarH.Text;
    CostoHuevo[3] := edtGrasaH.Text;
    CostoHuevo[4] := edtProteinasH.Text;
    MaxPaquetes := edtMaximoP.Text;
    CostoPaquete[1] := edtAguaP.Text;
    CostoPaquete[2] := edtAzucarP.Text;
    CostoPaquete[3] := edtGrasaP.Text;
    CostoPaquete[4] := edtProteinasP.Text;
    for i := 1 to 4 do
      for j := 1 to 2 do
        Movimiento.Costos[i,j] := stgMovimiento.Cells[i,j];
    for i := 1 to 7 do  //Número de sustratos = 7
      Movimiento.Velocidad[i] := stgVelocidad.Cells[i,1];
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j] := stgAlimentacion.Cells[i,j];
    for i := 1 to 4 do
      for j := 1 to 3 do
        CostosCombate[i,j] := stgCombate.Cells[i,j];
    for i := 1 to 4 do
      for j := 1 to 6 do
        CostosCortejo[i,j] := stgCortejo.Cells[i,j];
    PaquetesTransferidos := edtEsperma.Text;
    HuevosFertilizados := edtFertilizados.Text;
    Paternidad := edtPaternidad.Text;
    DegradacionEsperma := edtDegradacion.Text;
    MaxPaquetesH := edtMaxPaquetes.Text;
    TasaConsumo := edtConsumoPaquete.Text;
    HuevosCiclo := edtHuevos.Text;
    FraccionHuevo := edtFraccionHuevo.Text;
    FraccionPaquete := edtFraccionPaquete.Text;
    Alimentacion.Ganancias[1] := edtAgua.Text;
    Alimentacion.Ganancias[2] := edtAzucar.Text;
    Alimentacion.Ganancias[3] := edtGrasa.Text;
    Alimentacion.Ganancias[4] := edtProteina.Text;
  end;
end;

procedure TfrmFisiologia.FormCreate(Sender: TObject);
begin
  Encabezados;
  ImportaValores;
end;

procedure TfrmFisiologia.edtAguaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAgua.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAgua.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtAguaHDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAguaH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                    + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAguaH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtAguaPDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAguaP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAguaP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtAzucarDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucar.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucar.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtAzucarHDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucarH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                   + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucarH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtAzucarPDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucarP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucarP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtConsumoPaqueteDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtConsumoPaquete.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlTasaConsmPE);
  if frmEditorFormulas.ShowModal = mrOK then
    edtConsumoPaquete.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtDegradacionDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtDegradacion.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                      + '-' + ML(mlDegrEsperma);
  if frmEditorFormulas.ShowModal = mrOK then
    edtDegradacion.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtEspermaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtEsperma.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlNmrPETC);
  if frmEditorFormulas.ShowModal = mrOK then
    edtEsperma.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtFertilizadosDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFertilizados.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlFrccHFC);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFertilizados.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtFraccionHuevoDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFraccionHuevo.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdEnrgtc)
                                                          + '-' + ML(mlPrddHv);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFraccionHuevo.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtFraccionPaqueteDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFraccionPaquete.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdEnrgtc)
                                                           + '-' + ML(mlPrddPE);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFraccionPaquete.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtGrasaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasa.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasa.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtGrasaHDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasaH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                    + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasaH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtGrasaPDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasaP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasaP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtHuevosDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtHuevos.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlHvsOvpstd);
  frmEditorFormulas.Dinamico := True;
  if frmEditorFormulas.ShowModal = mrOK then
    edtHuevos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtMaximoHDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaximoH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                                                              + ML(mlMaxHuevos);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaximoH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtMaximoPDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaximoP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                                                             + ML(mlMaxEsperma);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaximoP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtMaxPaquetesDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaxPaquetes.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlMaxPEAH);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaxPaquetes.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtPaternidadDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtPaternidad.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlPrbbPtrnd);
  if frmEditorFormulas.ShowModal = mrOK then
    edtPaternidad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtProteinaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteina.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteina.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtProteinasHDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteinasH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                 + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteinasH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.edtProteinasPDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteinasP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteinasP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmFisiologia.ImportaValores;
var
  i, j: Integer;
begin
  with stgMovimiento do
  begin
    for i := 1 to 4 do
      for j := 1 to 2 do
        Cells[i,j] := frmEditorAgentes.JuegoAgentes.Movimiento.Costos[i,j];
  end;  //with
  with stgVelocidad do
  begin
    for i := 1 to 7 do  //Número de sustratos = 7
    begin
      Cells[i,0] := frmEditorAgentes.JuegoAgentes.Sustratos[i];
      Cells[i,1] := frmEditorAgentes.JuegoAgentes.Movimiento.Velocidad[i];
    end;
  end;  //with
  with stgAlimentacion do
  begin
    for i := 1 to 4 do
      for j := 1 to 4 do
        Cells[i,j] := frmEditorAgentes.JuegoAgentes.Alimentacion.Costos[i,j];
  end;
  with stgCombate do
  begin
    for i := 1 to 4 do
      for j := 1 to 3 do
        Cells[i,j] := frmEditorAgentes.JuegoAgentes.CostosCombate[i,j];
  end;
  with stgCortejo do
  begin
    for i := 1 to 4 do
      for j := 1 to 6 do
        Cells[i,j] := frmEditorAgentes.JuegoAgentes.CostosCortejo[i,j];
  end;
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to 5 do
      for j := 1 to 4 do
        stgMetabolismo.Cells[i,j] := Metabolismo[i,j];
    edtMaximoH.Text := MaxHuevos;
    edtAguaH.Text := CostoHuevo[1];
    edtAzucarH.Text := CostoHuevo[2];
    edtGrasaH.Text := CostoHuevo[3];
    edtProteinasH.Text := CostoHuevo[4];
    edtMaximoP.Text := MaxPaquetes;
    edtAguaP.Text := CostoPaquete[1];
    edtAzucarP.Text := CostoPaquete[2];
    edtGrasaP.Text := CostoPaquete[3];
    edtProteinasP.Text := CostoPaquete[4];
    edtAgua.Text := Alimentacion.Ganancias[1];
    edtAzucar.Text := Alimentacion.Ganancias[2];
    edtGrasa.Text := Alimentacion.Ganancias[3];
    edtProteina.Text := Alimentacion.Ganancias[4];
    edtEsperma.Text := PaquetesTransferidos;
    edtFertilizados.Text := HuevosFertilizados;
    edtPaternidad.Text := Paternidad;
    edtDegradacion.Text := DegradacionEsperma;
    edtMaxPaquetes.Text := MaxPaquetesH;
    edtConsumoPaquete.Text := TasaConsumo;
    edtHuevos.Text := HuevosCiclo;
    edtFraccionHuevo.Text := FraccionHuevo;
    edtFraccionPaquete.Text := FraccionPaquete;
  end;
end;

procedure TfrmFisiologia.btbAceptarClick(Sender: TObject);
begin
  ExportaValores;
end;

procedure TfrmFisiologia.edtAguaHMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAguaH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                    + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAguaH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtAguaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAgua.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAgua.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtAguaPMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAguaP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAgua);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAguaP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtAzucarHMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucarH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                   + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucarH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtAzucarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucar.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucar.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtAzucarPMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucarP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucarP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtConsumoPaqueteMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtConsumoPaquete.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlTasaConsmPE);
  if frmEditorFormulas.ShowModal = mrOK then
    edtConsumoPaquete.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtDegradacionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtDegradacion.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                      + '-' + ML(mlDegrEsperma);
  if frmEditorFormulas.ShowModal = mrOK then
    edtDegradacion.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtEspermaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtEsperma.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlNmrPETC);
  if frmEditorFormulas.ShowModal = mrOK then
    edtEsperma.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtFertilizadosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFertilizados.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlFrccHFC);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFertilizados.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtFraccionHuevoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFraccionHuevo.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdEnrgtc)
                                                          + '-' + ML(mlPrddHv);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFraccionHuevo.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtFraccionPaqueteMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtFraccionPaquete.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdEnrgtc)
                                                           + '-' + ML(mlPrddPE);
  if frmEditorFormulas.ShowModal = mrOK then
    edtFraccionPaquete.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtGrasaHMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasaH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                    + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasaH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtGrasaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasa.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasa.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtGrasaPMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasaP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasaP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtHuevosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtHuevos.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlHvsOvpstd);
  frmEditorFormulas.Dinamico := True;
  if frmEditorFormulas.ShowModal = mrOK then
    edtHuevos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtMaxPaquetesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaxPaquetes.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                          + '-' + ML(mlMaxPEAH);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaxPaquetes.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtMaximoHMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaximoH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                                                              + ML(mlMaxHuevos);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaximoH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtMaximoPMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMaximoP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                                                             + ML(mlMaxEsperma);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMaximoP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtPaternidadMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtPaternidad.Text;
  frmEditorFormulas.InteraccionAgente := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlDinGam)
                                                        + '-' + ML(mlPrbbPtrnd);
  if frmEditorFormulas.ShowModal = mrOK then
    edtPaternidad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtProteinaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteina.Text;
  frmEditorFormulas.Dinamico := True;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlNtrmntUndds) + ':'
                              + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteina.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtProteinasHMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteinasH.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
                 + ML(mlHuevo) + ':' + ML(mlCostoUnidad) + '-' + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteinasH.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.edtProteinasPMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteinasP.Text;
  frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlPrdccnGmts) + '-'
            + ML(mlPqtEsprmtc) + ':' + ML(mlCostoUnidad) + '-' + ML(mlProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteinasP.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmFisiologia.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmFisiologia.Encabezados;
var
  i: Integer;
begin
  with stgMetabolismo do
  begin
    ColWidths[0] := 90;
    for i := 1 to 5 do
      ColWidths[i] := 120;
    Cells[0,0] := ML(mlNutrimentos) + '\' + ML(mlValores);
    Cells[1,0] := ML(mlMinimo);
    Cells[2,0] := ML(mlCritico);
    Cells[3,0] := ML(mlOptimo);
    Cells[4,0] := ML(mlInicial);
    Cells[5,0] := ML(mlMaximo);
    Cells[0,1] := ML(mlAgua);
    Cells[0,2] := ML(mlAzucar);
    Cells[0,3] := ML(mlGrasa);
    Cells[0,4] := ML(mlProteina);
  end;
   with stgMovimiento do
  begin
    ColWidths[0] := 80;
    for i := 1 to 4 do
      ColWidths[i] := 150;
    Cells[0,0] := ML(mlConducta) + '\' + ML(mlCosto);
    Cells[1,0] := ML(mlAgua);
    Cells[2,0] := ML(mlAzucar);
    Cells[3,0] := ML(mlGrasa);
    Cells[4,0] := ML(mlProteina);
    Cells[0,1] := ML(mlMovimiento);
    Cells[0,2] := ML(mlEnReposo);
  end;
   with stgVelocidad do
  begin
    ColWidths[0] := 80;
    for i := 1 to 7 do
      ColWidths[i] := 85;
    Cells[0,0] := '\' + ML(mlSustrato);
    Cells[0,1] := ML(mlVelocidad);
  end;
  with stgAlimentacion do
  begin
    ColWidths[0] := 100;
    for i := 1 to 4 do
      ColWidths[i] := 150;
    Cells[0,0] := ML(mlConducta) + '\' + ML(mlCosto);
    Cells[1,0] := ML(mlAgua);
    Cells[2,0] := ML(mlAzucar);
    Cells[3,0] := ML(mlGrasa);
    Cells[4,0] := ML(mlProteina);
    Cells[0,1] := ML(mlBeber);
    Cells[0,2] := ML(mlCmrAzucar);
    Cells[0,3] := ML(mlCmrGrasa);
    Cells[0,4] := ML(mlCmrProteina);
  end;
  with stgCombate do
  begin
    ColWidths[0] := 100;
    for i := 1 to 4 do
      ColWidths[i] := 150;
    Cells[0,0] := ML(mlConducta) + '\' + ML(mlCosto);
    Cells[1,0] := ML(mlAgua);
    Cells[2,0] := ML(mlAzucar);
    Cells[3,0] := ML(mlGrasa);
    Cells[4,0] := ML(mlProteina);
    Cells[0,1] := ML(mlDesplegar);
    Cells[0,2] := ML(mlEscalar);
    Cells[0,3] := ML(mlRetirar);
  end;
  with stgCortejo do
  begin
    ColWidths[0] := 100;
    for i := 1 to 4 do
      ColWidths[i] := 150;
    Cells[0,0] := ML(mlConducta) + '\' + ML(mlCosto);
    Cells[1,0] := ML(mlAgua);
    Cells[2,0] := ML(mlAzucar);
    Cells[3,0] := ML(mlGrasa);
    Cells[4,0] := ML(mlProteina);
    Cells[0,1] := ML(mlIA);
    Cells[0,2] := ML(mlIB);
    Cells[0,3] := ML(mlAceptacion);
    Cells[0,4] := ML(mlRechazar);
    Cells[0,5] := ML(mlCopular);
    Cells[0,6] := ML(mlOvipositar);
  end;
end;

procedure TfrmFisiologia.stgMetabolismoDblClick(Sender: TObject);
begin
  with stgMetabolismo do
  begin
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlMetabolismo)
                                  + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.stgMovimientoDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgMovimiento do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlMovimiento) + ':'
                       + ml(mlCostos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.stgVelocidadDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgVelocidad do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlMovimiento) + ':'
                    + ml(mlVelocidad) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.stgAlimentacionDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgAlimentacion do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Dinamico := True;
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlForrajeo) + ':'
                      + ML(mlCostos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.stgCombateDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.InteraccionAgente := True;
  with stgCombate do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlCombate) + ':'
                      + ML(mlCostos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.stgCortejoDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.InteraccionAgente := True;
  with stgCortejo do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlFisiologia) + '-' + ML(mlCortejo) + ':'
                      + ML(mlCostos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmFisiologia.spbNotasClick(Sender: TObject);
var
  Apartados: TStringList;
  i: Integer;
begin
  Apartados := TStringList.Create;
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Fisiologia';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  for i := 0 to PageControl1.PageCount - 1 do
    Apartados.Add(PageControl1.Pages[i].Caption);
  frmEditorNotas.CreaApartados(Apartados);
  frmEditorNotas.Show;
  FreeAndNil(Apartados);
end;

procedure TfrmFisiologia.btnImportarClick(Sender: TObject);
var
  RutaSustrato: string;
  JuegoSustratos: TJuegoSustratos;
  NombreArchivo : string;
  i             : Integer;
begin
  {frmSeleccionaJuego := TfrmSeleccionaJuego.Create(Application);
  if frmSeleccionaJuego.ShowModal = mrOK then
  begin
    NombreArchivo := frmSeleccionaJuego.NombreArchivo;
    if not FileExists(NombreArchivo) then
      Exit; //-->
    JuegoSustratos := TJuegoSustratos.Create;
    JuegoSustratos.Carga(NombreArchivo);
    for i := 1 to 7 do
    begin
      stgVelocidad.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      frmEditorAgentes.CambiaNombreVariablePrefijos
                          (frmEditorAgentes.JuegoAgentes.Sustratos[i],
                           JuegoSustratos.SustratoSimple[i].Nombre);
      frmEditorAgentes.JuegoAgentes.Sustratos[i] :=
                                      JuegoSustratos.SustratoSimple[i].Nombre;
    end;
    FreeAndNil(JuegoSustratos);
    frmEditorAgentes.Salvado := False;
  end;
  FreeAndNil(frmSeleccionaJuego);}
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    OpenDialog1.InitialDir := RutaSustrato;
  if OpenDialog1.Execute then
  begin
    NombreArchivo := OpenDialog1.FileName;
    if not FileExists(NombreArchivo) then
      Exit; //-->
    JuegoSustratos := TJuegoSustratos.Create;
    JuegoSustratos.Carga(NombreArchivo);
    for i := 1 to 7 do
    begin
      stgVelocidad.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      frmEditorAgentes.CambiaNombreVariablePrefijos
                          (frmEditorAgentes.JuegoAgentes.Sustratos[i],
                           JuegoSustratos.SustratoSimple[i].Nombre);
      frmEditorAgentes.JuegoAgentes.Sustratos[i] :=
                                      JuegoSustratos.SustratoSimple[i].Nombre;
    end;
    FreeAndNil(JuegoSustratos);
    frmEditorAgentes.Salvado := False;
  end;
end;

procedure TfrmFisiologia.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(frmEditorNotas) then
  begin
    frmEditorNotas.ExportaTexto;
    frmEditorNotas.Close;
    FreeAndNil(frmEditorNotas);
  end;
end;

initialization
  {$i Fisiologia.lrs}

end.
