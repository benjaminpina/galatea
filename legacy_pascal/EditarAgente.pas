unit EditarAgente;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Grids, Agentes, LResources;

type

  { TfrmEditarAgente }

  TfrmEditarAgente = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    PageControl1: TPageControl;
    stgSustratos: TStringGrid;
    stgDinamicos: TStringGrid;
    stgAgentes: TStringGrid;
    stgConducta: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet6: TTabSheet;
    GroupBox20: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtAgua: TEdit;
    edtAzucar: TEdit;
    edtGrasa: TEdit;
    edtProteina: TEdit;
    sbxLC: TScrollBox;
    grpLCP1: TGroupBox;
    rdbLCDP1: TRadioButton;
    rdbLCRP1: TRadioButton;
    edtLCP1: TEdit;
    grpLCM1: TGroupBox;
    rdbLCDM1: TRadioButton;
    rdbLCRM1: TRadioButton;
    edtLCM1: TEdit;
    grpLC1: TGroupBox;
    sttLC1: TStaticText;
    sbxLD: TScrollBox;
    grpLDP1: TGroupBox;
    rdbLDDP1: TRadioButton;
    rdbLDRP1: TRadioButton;
    edtLDP1: TEdit;
    grpLDM1: TGroupBox;
    rdbLDDM1: TRadioButton;
    rdbLDRM1: TRadioButton;
    edtLDM1: TEdit;
    grpLD1: TGroupBox;
    sttLD1: TStaticText;
    GroupBox60: TGroupBox;
    Label12: TLabel;
    edtNombre: TEdit;
    Label1: TLabel;
    cmbDireccion: TComboBox;
    Label2: TLabel;
    edtEdad: TEdit;
    GroupBox21: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    sttSexo: TStaticText;
    sttPrototipo: TStaticText;
    GroupBox2: TGroupBox;
    //vleSustratos: TValueListEditor;
    GroupBox3: TGroupBox;
    //vleDinamicos: TValueListEditor;
    GroupBox4: TGroupBox;
    //vleAgentes: TValueListEditor;
    GroupBox5: TGroupBox;
    //vleConductas: TValueListEditor;
    Label15: TLabel;
    Label16: TLabel;
    sttPadre: TStaticText;
    sttMadre: TStaticText;
    GroupBox6: TGroupBox;
    Label17: TLabel;
    Label18: TLabel;
    edtCiclosEstadio: TEdit;
    edtCiclosSustrato: TEdit;
    sttPortados: TStaticText;
    sttAlmacenados: TStaticText;
    sttPaquetes: TStaticText;
    sttHuevos: TStaticText;
    sttFertilizados: TStaticText;
    Label19: TLabel;
    Label20: TLabel;
    edtCiclosInteraccion: TEdit;
    sttSituacion: TStaticText;
    Label21: TLabel;
    sttInteractuante: TStaticText;
    TabSheet5: TTabSheet;
    PageControl2: TPageControl;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    stgContinuos: TStringGrid;
    stgDiscretos: TStringGrid;
    procedure GroupBox4Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure TabSheet6ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet8ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure edtEdadKeyPress(Sender: TObject; var Key: Char);
    procedure edtLC1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLD1KeyPress(Sender: TObject; var Key: Char);
    procedure edtAguaKeyPress(Sender: TObject; var Key: Char);
    procedure edtAzucarKeyPress(Sender: TObject; var Key: Char);
    procedure edtGrasaKeyPress(Sender: TObject; var Key: Char);
    procedure edtProteinaKeyPress(Sender: TObject; var Key: Char);
    procedure edtPaquetesKeyPress(Sender: TObject; var Key: Char);
    procedure edtHuevosKeyPress(Sender: TObject; var Key: Char);
    procedure edtFertilizadosKeyPress(Sender: TObject; var Key: Char);
    procedure edtPortadosKeyPress(Sender: TObject; var Key: Char);
    procedure edtAlamacenadosKeyPress(Sender: TObject; var Key: Char);
    procedure vleSustratosKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtLCP1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLCM1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLDP1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLDM1KeyPress(Sender: TObject; var Key: Char);
    procedure rdbLCDP1Click(Sender: TObject);
    procedure rdbLCDM1Click(Sender: TObject);
    procedure rdbLCRP1Click(Sender: TObject);
    procedure rdbLCRM1Click(Sender: TObject);
    procedure rdbLDDP1Click(Sender: TObject);
    procedure rdbLDRP1Click(Sender: TObject);
    procedure rdbLDRM1Click(Sender: TObject);
    procedure rdbLDDM1Click(Sender: TObject);
    procedure edtLCP1Change(Sender: TObject);
    procedure edtLCM1Change(Sender: TObject);
    procedure edtLDP1Change(Sender: TObject);
    procedure edtLDM1Change(Sender: TObject);
    procedure edtCiclosEstadioKeyPress(Sender: TObject; var Key: Char);
    procedure edtCiclosSustratoKeyPress(Sender: TObject; var Key: Char);
    procedure edtCiclosInteraccionKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    {Controles creados en tiempo de ejecución}
    grpLCP: array [1..15] of TGroupBox;
    rdbLCDP: array [1..15] of TRadioButton;
    rdbLCRP: array [1..15] of TRadioButton;
    edtLCP: array [1..15] of TEdit;
    grpLCM: array [1..15] of TGroupBox;
    rdbLCDM: array [1..15] of TRadioButton;
    rdbLCRM: array [1..15] of TRadioButton;
    edtLCM: array [1..15] of TEdit;
    grpLC: array [1..15] of TGroupBox;
    sttLC: array [1..15] of TStaticText;
    grpLDP: array [1..15] of TGroupBox;
    rdbLDDP: array [1..15] of TRadioButton;
    rdbLDRP: array [1..15] of TRadioButton;
    edtLDP: array [1..15] of TEdit;
    grpLDM: array [1..15] of TGroupBox;
    rdbLDDM: array [1..15] of TRadioButton;
    rdbLDRM: array [1..15] of TRadioButton;
    edtLDM: array [1..15] of TEdit;
    grpLD: array [1..15] of TGroupBox;
    sttLD: array [1..15] of TStaticText;
    procedure InsertaControles;
    procedure InsertaCajas;
    procedure InsertaRadios;
    procedure InsertaCuadros;
    procedure ActualizaValores;
  public
    { Public declarations }
    Agente: TAgente;
    procedure DespliegaValores;
  end;

var
  frmEditarAgente: TfrmEditarAgente;

implementation

uses
  Multilenguaje, EditorEntornos, Comunes, Mediadores, Elementos;


function ExpresadoContinuo(LocPat, LocMat: string;
  DomPat, DomMat: Boolean): string;
{Regresa el valor expresado (en cadena) segun valores y cualidades de locus
pasados como parámetros}
var
  Pat, Mat: Real;
begin
  try
    Result := '0';
    Pat := StrToFloat(LocPat);
    Mat := StrToFloat(LocMat);
    if DomPat and DomMat then               //Homocigo dominate
      Result := FloatToStr((Pat + Mat) / 2)     //Codominancia
    else if DomPat and not DomMat then      //Heterocigo
      Result := FloatToStr(Pat)           //Dominancia paterna
    else if not DomPat and DomMat then      //Heterocigo
      Result := FloatToStr(Mat)           //Dominancia materna
    else if not DomPat and not DomMat then  //Homocigo dominate
      Result := FloatToStr((Pat + Mat) / 2);    //Codominancia
  except
  end;
end;

function ExpresadoDiscreto(LocPat, LocMat: string;
  DomPat, DomMat: Boolean): string;
{Regresa el valor expresado (en cadena) segun valores y cualidades de locus
pasados como parámetros}
var
  Pat, Mat: Integer;
begin
  try
    Result := '0';
    Pat := StrToInt(LocPat);
    Mat := StrToInt(LocMat);
    if DomPat and DomMat then                 //Homocigo dominate
      Result := IntToStr(Round((Pat + Mat) / 2))  //Codominancia
    else if DomPat and not DomMat then        //Heterocigo
      Result := IntToStr(Pat)               //Dominancia paterna
    else if not DomPat and DomMat then        //Heterocigo
      Result := IntToStr(Mat)               //Dominancia materna
    else if not DomPat and not DomMat then    //Homocigo dominate
      Result := IntToStr(Round((Pat + Mat) / 2)); //Codominancia
  except
  end;
end;

procedure TfrmEditarAgente.edtEdadKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmEditarAgente.GroupBox4Click(Sender: TObject);
begin

end;

procedure TfrmEditarAgente.TabSheet6ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmEditarAgente.TabSheet8ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmEditarAgente.edtLC1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtLD1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtAguaKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtAzucarKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtGrasaKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtProteinaKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtPaquetesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtHuevosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtFertilizadosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtPortadosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtAlamacenadosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.vleSustratosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '-', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.ActualizaValores;
var
  i: Integer;
begin
  with Agente do
  begin
    Nombre := edtNombre.Text;
    Direccion :=  NumADireccion(cmbDireccion.ItemIndex + 1);
    Inicializa(frmEditorEntornos.Entorno.Juego ,Agente.Padre, Agente.Madre,
               Estadio, Prototipo, StrToInt(edtEdad.Text), Sexo);
    Tiempo.EstadioActual := StrToInt(edtCiclosEstadio.Text);
    Tiempo.SustratoActual := StrToInt(edtCiclosSustrato.Text);
    Tiempo.InteraccionActual := StrToInt(edtCiclosInteraccion.Text);
    for i := 1 to 15 do
    begin
      Genotipo.PatContinuos[i].Valor := StrToFloat(edtLCP[i].Text);
      Genotipo.MatContinuos[i].Valor := StrToFloat(edtLCM[i].Text);
      if rdbLCDP[i].Checked then
        Genotipo.PatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.PatContinuos[i].Cualidad := cdRecesivo;
      if rdbLCDP[i].Checked then
        Genotipo.PatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.PatContinuos[i].Cualidad := cdRecesivo;
      if rdbLCDM[i].Checked then
        Genotipo.MatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.MatContinuos[i].Cualidad := cdRecesivo;
      Genotipo.PatDiscretos[i].Valor := StrToInt(edtLDP[i].Text);
      Genotipo.MatDiscretos[i].Valor := StrToInt(edtLDM[i].Text);
      if rdbLDDP[i].Checked then
        Genotipo.PatDiscretos[i].Cualidad := cdDominante
      else
        Genotipo.PatDiscretos[i].Cualidad := cdRecesivo;
      if rdbLDDM[i].Checked then
        Genotipo.MatDiscretos[i].Cualidad := cdDominante
      else
        Genotipo.MatDiscretos[i].Cualidad := cdRecesivo;
    end;
    Reservas.Agua := StrToInt(edtAgua.Text);
    Reservas.Azucar := StrToInt(edtAzucar.Text);
    Reservas.Grasa := StrToInt(edtGrasa.Text);
    Reservas.Proteina := StrToInt(edtProteina.Text);
    //Reproduccion.Paquetes := StrToInt(edtPaquetes.Text);
    //Reproduccion.Huevos := StrToInt(edtHuevos.Text);
    //Reproduccion.Fertilizados := StrToInt(edtFertilizados.Text);
    //Reproduccion.Acarreados := StrToInt(edtPortados.Text);
    //Reproduccion.Almacenados := StrToInt(edtAlamacenados.Text);
    {for i := 1 to 7 do  //Num Sutratos = 7
      Memoria.UltPerSust[i] := StrToInt(vleSustratos.Cells[1,i]);
    for i := 1 to 7 do
      Memoria.NumPerSust[i] := StrToInt(vleSustratos.Cells[1,i + 7]);
    Memoria.UltIntDin[1] := StrToInt(vleDinamicos.Cells[1,1]);
    Memoria.UltIntDin[2] := StrToInt(vleDinamicos.Cells[1,2]);
    Memoria.UltIntDin[3] := StrToInt(vleDinamicos.Cells[1,3]);
    Memoria.UltIntDin[4] := StrToInt(vleDinamicos.Cells[1,4]);
    Memoria.UltIntDin[5] := StrToInt(vleDinamicos.Cells[1,5]);
    Memoria.NumIntDin[1] := StrToInt(vleDinamicos.Cells[1,6]);
    Memoria.NumIntDin[2] := StrToInt(vleDinamicos.Cells[1,7]);
    Memoria.NumIntDin[3] := StrToInt(vleDinamicos.Cells[1,8]);
    Memoria.NumIntDin[4] := StrToInt(vleDinamicos.Cells[1,9]);
    Memoria.NumIntDin[5] := StrToInt(vleDinamicos.Cells[1,10]);
    Memoria.UltPerDin[1] := StrToInt(vleDinamicos.Cells[1,11]);
    Memoria.UltPerDin[2] := StrToInt(vleDinamicos.Cells[1,12]);
    Memoria.UltPerDin[3] := StrToInt(vleDinamicos.Cells[1,13]);
    Memoria.UltPerDin[4] := StrToInt(vleDinamicos.Cells[1,14]);
    Memoria.UltPerDin[5] := StrToInt(vleDinamicos.Cells[1,15]);
    Memoria.NumPerDin[1] := StrToInt(vleDinamicos.Cells[1,16]);
    Memoria.NumPerDin[2] := StrToInt(vleDinamicos.Cells[1,17]);
    Memoria.NumPerDin[3] := StrToInt(vleDinamicos.Cells[1,18]);
    Memoria.NumPerDin[4] := StrToInt(vleDinamicos.Cells[1,19]);
    Memoria.NumPerDin[5] := StrToInt(vleDinamicos.Cells[1,20]);
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
      Memoria.UltIntEstadios[i-1] := StrToInt(vleAgentes.Cells[1,i]);
    j := frmEditorEntornos.Entorno.Juego.NumEstadios;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
      Memoria.NumIntEstadios[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
      Memoria.UltPerEstadios[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
      Memoria.NumPerEstadios[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
      Memoria.UltIntMachos[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
      Memoria.NumIntMachos[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
      Memoria.UltPerMachos[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
      Memoria.NumPerMachos[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
      Memoria.UltIntHembras[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
      Memoria.NumIntHembras[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
      Memoria.UltPerHembras[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
      Memoria.NumPerHembras[i-1] := StrToInt(vleAgentes.Cells[1,i+j]);
    Memoria.UltConductas[1] := StrToInt(vleConductas.Cells[1,1]);
    Memoria.UltConductas[2] := StrToInt(vleConductas.Cells[1,2]);
    Memoria.UltConductas[3] := StrToInt(vleConductas.Cells[1,3]);
    Memoria.UltConductas[4] := StrToInt(vleConductas.Cells[1,4]);
    Memoria.UltConductas[5] := StrToInt(vleConductas.Cells[1,5]);
    Memoria.UltConductas[6] := StrToInt(vleConductas.Cells[1,6]);
    if Adulto then
    begin
      Memoria.UltConductas[7] := StrToInt(vleConductas.Cells[1,7]);
      Memoria.UltConductas[8] := StrToInt(vleConductas.Cells[1,8]);
      Memoria.UltConductas[9] := StrToInt(vleConductas.Cells[1,9]);
      Memoria.UltConductas[10] := StrToInt(vleConductas.Cells[1,10]);
      Memoria.UltConductas[11] := StrToInt(vleConductas.Cells[1,11]);
      Memoria.UltConductas[12] := StrToInt(vleConductas.Cells[1,12]);
      Memoria.UltConductas[13] := StrToInt(vleConductas.Cells[1,13]);
      Memoria.UltConductas[14] := StrToInt(vleConductas.Cells[1,14]);
      Memoria.UltConductas[15] := StrToInt(vleConductas.Cells[1,15]);
      Memoria.UltConductas[16] := StrToInt(vleConductas.Cells[1,16]);
    end;
    if Adulto then
    begin
      Memoria.NumConductas[1] := StrToInt(vleConductas.Cells[1,17]);
      Memoria.NumConductas[2] := StrToInt(vleConductas.Cells[1,18]);
      Memoria.NumConductas[3] := StrToInt(vleConductas.Cells[1,19]);
      Memoria.NumConductas[4] := StrToInt(vleConductas.Cells[1,20]);
      Memoria.NumConductas[5] := StrToInt(vleConductas.Cells[1,21]);
      Memoria.NumConductas[6] := StrToInt(vleConductas.Cells[1,22]);
      Memoria.NumConductas[7] := StrToInt(vleConductas.Cells[1,23]);
      Memoria.NumConductas[8] := StrToInt(vleConductas.Cells[1,24]);
      Memoria.NumConductas[9] := StrToInt(vleConductas.Cells[1,25]);
      Memoria.NumConductas[10] := StrToInt(vleConductas.Cells[1,26]);
      Memoria.NumConductas[11] := StrToInt(vleConductas.Cells[1,27]);
      Memoria.NumConductas[12] := StrToInt(vleConductas.Cells[1,28]);
      Memoria.NumConductas[13] := StrToInt(vleConductas.Cells[1,29]);
      Memoria.NumConductas[14] := StrToInt(vleConductas.Cells[1,30]);
      Memoria.NumConductas[15] := StrToInt(vleConductas.Cells[1,31]);
      Memoria.NumConductas[16] := StrToInt(vleConductas.Cells[1,32]);
    end
    else
    begin
      Memoria.NumConductas[1] := StrToInt(vleConductas.Cells[1,7]);
      Memoria.NumConductas[2] := StrToInt(vleConductas.Cells[1,8]);
      Memoria.NumConductas[3] := StrToInt(vleConductas.Cells[1,9]);
      Memoria.NumConductas[4] := StrToInt(vleConductas.Cells[1,10]);
      Memoria.NumConductas[5] := StrToInt(vleConductas.Cells[1,11]);
      Memoria.NumConductas[6] := StrToInt(vleConductas.Cells[1,12]);
    end;    }
  end;  //with Agente
end;

procedure TfrmEditarAgente.DespliegaValores;
var
  i, j: Integer;
  Mediador: TMediador;
begin
  with Agente do
  begin
    edtNombre.Text := Nombre;
    cmbDireccion.ItemIndex := DireccionANum(Direccion) - 1;
    edtEdad.Text := IntToStr(Edad);
    case Sexo of
      sxMacho: sttSexo.Caption := ML(mlMacho);
      sxHembra: sttSexo.Caption := ML(mlHembra);
      sxIndefinido: sttSexo.Caption := ML(mlIndefinido);
    end;
    sttPadre.Caption := Agente.Padre;
    sttMadre.Caption := Agente.Madre;
    edtCiclosEstadio.Text := IntToStr(Agente.Tiempo.EstadioActual);
    edtCiclosSustrato.Text := IntToStr(Agente.Tiempo.SustratoActual);
    edtCiclosInteraccion.Text := IntToStr(Agente.Tiempo.InteraccionActual);
    case Situacion of
      stInmaduro: sttSituacion.Caption := ML(mlInmaduro);
      stRegular: sttSituacion.Caption := 'Regular';
      stCombate: sttSituacion.Caption := ML(mlCombate);
      stCortejo: sttSituacion.Caption := ML(mlCortejo);
    end;
    if Assigned(Interactuante) then
    begin
      sttInteractuante.Caption := Interactuante.Nombre + ':';
      if (Interactuante is TDinamico) then
      	case (Interactuante as TDinamico).TipoED of
       		edFntAgua: sttInteractuante.Caption := sttInteractuante.Caption
         			+ ML(mlFntAgua);
          edFntGrasa: sttInteractuante.Caption := sttInteractuante.Caption
         			+ ML(mlFntGrasa);
          edFntAzucar: sttInteractuante.Caption := sttInteractuante.Caption
         			+ ML(mlFntAzucar);
          edFntProteina: sttInteractuante.Caption := sttInteractuante.Caption
         			+ ML(mlFntPrtn);
        end;
      if (Interactuante is TAgente) then
      begin
      	if (Interactuante as TAgente).Sexo = sxMacho then
      		sttInteractuante.Caption := sttInteractuante.Caption
       				+ frmEditorEntornos.Entorno.Juego.PrototiposM
           		[((Interactuante as TAgente).Prototipo)].Nombre
        else
          sttInteractuante.Caption := sttInteractuante.Caption
       				+ frmEditorEntornos.Entorno.Juego.PrototiposH
           		[((Interactuante as TAgente).Prototipo)].Nombre
      end;
    end
    else
      sttInteractuante.Caption := '--';
    Mediador := TMediador.Create(frmEditorEntornos.Entorno);
    Mediador.Agente := Agente;
    sttPrototipo.Caption := Mediador.NombrePrototipo;
    Mediador.Free;
    for i := 1 to 15 do
    begin
      edtLCP[i].Text := FloatToStr(Genotipo.PatContinuos[i].Valor);
      edtLCM[i].Text := FloatToStr(Genotipo.MatContinuos[i].Valor);
      rdbLCRP[i].Checked := Genotipo.PatContinuos[i].Cualidad = cdRecesivo;
      rdbLCRM[i].Checked := Genotipo.MatContinuos[i].Cualidad = cdRecesivo;
      edtLDP[i].Text := IntToStr(Genotipo.PatDiscretos[i].Valor);
      edtLDM[i].Text := IntToStr(Genotipo.MatDiscretos[i].Valor);
      rdbLDRP[i].Checked := Genotipo.PatDiscretos[i].Cualidad = cdRecesivo;
      rdbLDRM[i].Checked := Genotipo.MatDiscretos[i].Cualidad = cdRecesivo;
      sttLC[i].Caption := ExpresadoContinuo(edtLCP[i].Text, edtLCM[i].Text,
          rdbLCDP[i].Checked, rdbLCDM[i].Checked);
      sttLD[i].Caption := ExpresadoDiscreto(edtLDP[i].Text, edtLDM[i].Text,
          rdbLDDP[i].Checked, rdbLDDM[i].Checked);
    end;
    edtAgua.Text := IntToStr(Reservas.Agua);
    edtAzucar.Text := IntToStr(Reservas.Azucar);
    edtGrasa.Text := IntToStr(Reservas.Grasa);
    edtProteina.Text := IntToStr(Reservas.Proteina);
    if Sexo = sxMacho then
    begin
      sttPaquetes.Caption := IntToStr(Gonada.Contador);
      sttHuevos.Caption := '--';
    end
    else
    begin
      sttPaquetes.Caption := '--';
      sttHuevos.Caption := IntToStr(Gonada.Contador);
    end;
    if Sexo = sxMacho then
      sttFertilizados.Caption := '--'
    else
      sttFertilizados.Caption := IntToStr(Fertilizados.Contador);
    sttPortados.Caption := IntToStr(Acarreados);
    if Sexo = sxMacho then
      sttAlmacenados.Caption := '--'
    else
      sttAlmacenados.Caption := IntToStr(Espermateca.Contador);
    stgSustratos.ColWidths[0]:= 190;
    stgSustratos.ColWidths[1]:= 110;
    for i := 1 to 7 do  //Num Sutratos = 7
    begin
    	stgSustratos.Cells[0, i] := ML(mlUltPer)
     			+ frmEditorEntornos.Entorno.Juego.Sustratos[i];
    	stgSustratos.Cells[1,i] := IntToStr(Memoria.UltPerSust[i]);
    end;
    for i := 1 to 7 do  //Num Sutratos = 7
    begin
    	stgSustratos.Cells[0, 7 + i] := ML(mlNumPer)
          + frmEditorEntornos.Entorno.Juego.Sustratos[i];
      stgSustratos.Cells[1, 7 + i] := IntToStr(Memoria.NumPerSust[i]);
    end;
    stgDinamicos.ColWidths[0]:= 190;
    stgDinamicos.ColWidths[1]:= 110;
    stgDinamicos.Cells[0,1] := ML(mlUltInt) + ML(mlFntAgua);
  	stgDinamicos.Cells[1,1] := IntToStr(Memoria.UltIntDin[1]);
    stgDinamicos.Cells[0,2] := ML(mlUltInt) + ML(mlFntAzucar);
    stgDinamicos.Cells[1,2] := IntToStr(Memoria.UltIntDin[2]);
    stgDinamicos.Cells[0,3] := ML(mlUltInt) + ML(mlFntGrasa);
    stgDinamicos.Cells[1,3] := IntToStr(Memoria.UltIntDin[3]);
    stgDinamicos.Cells[0,4] := ML(mlUltInt) + ML(mlProteina);
  	stgDinamicos.Cells[1,4] := IntToStr(Memoria.UltIntDin[4]);
    stgDinamicos.Cells[0,5] := ML(mlUltInt) + ML(mlSitOvipo);
    stgDinamicos.Cells[1,5] := IntToStr(Memoria.UltIntDin[5]);
    stgDinamicos.Cells[0,6] := ML(mlNumInt) + ML(mlFntAgua);
  	stgDinamicos.Cells[1,6] := IntToStr(Memoria.NumIntDin[1]);
    stgDinamicos.Cells[0,7] := ML(mlNumInt) + ML(mlAzucar);
    stgDinamicos.Cells[1,7] := IntToStr(Memoria.NumIntDin[2]);
    stgDinamicos.Cells[0,8] := ML(mlNumInt) + ML(mlFntGrasa);
    stgDinamicos.Cells[1,8] := IntToStr(Memoria.NumIntDin[3]);
    stgDinamicos.Cells[0,9] := ML(mlNumInt) + ML(mlFntPrtn);
    stgDinamicos.Cells[1,9] := IntToStr(Memoria.NumIntDin[4]);
    stgDinamicos.Cells[0,10] := ML(mlNumInt) + ML(mlSitOvipo);
    stgDinamicos.Cells[1,10] := IntToStr(Memoria.NumIntDin[5]);
    stgDinamicos.Cells[0,11] := ML(mlUltPer) + ML(mlFntAgua);
    stgDinamicos.Cells[1,11] := IntToStr(Memoria.UltPerDin[1]);
    stgDinamicos.Cells[0,12] := ML(mlUltPer) + ML(mlFntAzucar);
    stgDinamicos.Cells[1,12] := IntToStr(Memoria.UltPerDin[2]);
    stgDinamicos.Cells[0,13] := ML(mlUltPer) + ML(mlFntGrasa);
    stgDinamicos.Cells[1,13] := IntToStr(Memoria.UltPerDin[3]);
    stgDinamicos.Cells[0,14] := ML(mlUltPer) + ML(mlProteina);
  	stgDinamicos.Cells[1,14] := IntToStr(Memoria.UltPerDin[4]);
    stgDinamicos.Cells[0,15] := ML(mlUltPer) + ML(mlSitOvipo);
  	stgDinamicos.Cells[1,15] := IntToStr(Memoria.UltPerDin[5]);
    stgDinamicos.Cells[0,16] := ML(mlNumPer) + ML(mlFntAgua);
    stgDinamicos.Cells[1,16] := IntToStr(Memoria.NumPerDin[1]);
    stgDinamicos.Cells[0,17] := ML(mlNumPer) + ML(mlAzucar);
    stgDinamicos.Cells[1,17] := IntToStr(Memoria.NumPerDin[2]);
    stgDinamicos.Cells[0,18] := ML(mlNumPer) + ML(mlFntGrasa);
    stgDinamicos.Cells[1,18] := IntToStr(Memoria.NumPerDin[3]);
    stgDinamicos.Cells[0,19] := ML(mlNumPer) + ML(mlFntPrtn);
    stgDinamicos.Cells[1,19] := IntToStr(Memoria.NumPerDin[4]);
    stgDinamicos.Cells[0,20] := ML(mlNumPer) + ML(mlSitOvipo);
    stgDinamicos.Cells[1,20] := IntToStr(Memoria.NumPerDin[5]);
    stgAgentes.ColWidths[0]:= 190;
    stgAgentes.ColWidths[1]:= 110;
    j := frmEditorEntornos.Entorno.Juego.NumEstadios;
    stgAgentes.RowCount := j + 1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
    begin
    	stgAgentes.Cells[0,i] := ML(mlUltInt) +
     			frmEditorEntornos.Entorno.Juego.Estadios[i].Nombre;
      stgAgentes.Cells[1,i] := IntToStr(Memoria.UltIntEstadios[i-1]);
    end;
    stgAgentes.RowCount:= j + frmEditorEntornos.Entorno.Juego.NumEstadios + 1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumInt) +
          frmEditorEntornos.Entorno.Juego.Estadios[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumIntEstadios[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    stgAgentes.RowCount:= j + frmEditorEntornos.Entorno.Juego.NumEstadios + 1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlUltPer) +
          frmEditorEntornos.Entorno.Juego.Estadios[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.UltPerEstadios[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    stgAgentes.RowCount:= j + frmEditorEntornos.Entorno.Juego.NumEstadios + 1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumEstadios do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumPer) +
          frmEditorEntornos.Entorno.Juego.Estadios[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumPerEstadios[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumEstadios;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposM+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlUltInt) +
          frmEditorEntornos.Entorno.Juego.PrototiposM[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.UltIntMachos[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposM+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumInt) +
          frmEditorEntornos.Entorno.Juego.PrototiposM[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumIntMachos[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposM+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlUltPer) +
          frmEditorEntornos.Entorno.Juego.PrototiposM[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.UltPerMachos[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposM+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposM do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumPer) +
          frmEditorEntornos.Entorno.Juego.PrototiposM[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumPerMachos[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposM;

    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposH+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlUltInt) +
          frmEditorEntornos.Entorno.Juego.PrototiposH[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.UltIntHembras[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposH+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumInt) +
          frmEditorEntornos.Entorno.Juego.PrototiposH[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumIntHembras[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposH+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlUltPer) +
          frmEditorEntornos.Entorno.Juego.PrototiposH[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.UltPerHembras[i-1]);
    end;
    j := j + frmEditorEntornos.Entorno.Juego.NumPrototiposH;
    stgAgentes.RowCount:= j+frmEditorEntornos.Entorno.Juego.NumPrototiposH+1;
    for i := 1 to frmEditorEntornos.Entorno.Juego.NumPrototiposH do
    begin
      stgAgentes.Cells[0,j+i] := ML(mlNumPer) +
          frmEditorEntornos.Entorno.Juego.PrototiposH[i].Nombre;
      stgAgentes.Cells[1,j+i] := IntToStr(Memoria.NumPerHembras[i-1]);
    end;
    stgConducta.ColWidths[0]:= 190;
    stgConducta.ColWidths[1]:= 110;
    if Adulto then
      stgConducta.RowCount:= 33
    else
    	stgConducta.RowCount:= 13;
    stgConducta.Cells[0,1] := ML(mlUltVz) + ML(mlMovimiento);
    stgConducta.Cells[1,1] := IntToStr(Memoria.UltConductas[1]);
    stgConducta.Cells[0,2] := ML(mlUltVz) + ML(mlEnReposo);
    stgConducta.Cells[1,2] := IntToStr(Memoria.UltConductas[2]);
    stgConducta.Cells[0,3] := ML(mlUltVz) + ML(mlBeber);
    stgConducta.Cells[1,3] := IntToStr(Memoria.UltConductas[3]);
    stgConducta.Cells[0,4] := ML(mlUltVz) + ML(mlCmrAzucar);
    stgConducta.Cells[1,4] := IntToStr(Memoria.UltConductas[4]);
    stgConducta.Cells[0,5] := ML(mlUltVz) + ML(mlCmrGrasa);
    stgConducta.Cells[1,5] := IntToStr(Memoria.UltConductas[5]);
    stgConducta.Cells[0,6] := ML(mlUltVz) + ML(mlCmrProteina);
    stgConducta.Cells[1,6] := IntToStr(Memoria.UltConductas[6]);
    if Adulto then
    begin
      stgConducta.Cells[0,7] :=  'Virginidad';
      if Virginidad then
      	stgConducta.Cells[1,7] := 'Virgen'
      else
        stgConducta.Cells[1,7] := 'No virgen'
    end;
    {

    if Adulto then
    begin
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlDesplegar),
          IntToStr(Memoria.UltConductas[7]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlEscalar),
          IntToStr(Memoria.UltConductas[8]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlRetirar),
          IntToStr(Memoria.UltConductas[9]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlIA),
          IntToStr(Memoria.UltConductas[10]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlIB),
          IntToStr(Memoria.UltConductas[11]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlAceptacion),
          IntToStr(Memoria.UltConductas[12]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlRechazar),
          IntToStr(Memoria.UltConductas[13]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlOvipositar),
          IntToStr(Memoria.UltConductas[14]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlPeleaGanada),
          IntToStr(Memoria.UltConductas[15]), True);
      vleConductas.InsertRow(ML(mlUltVz) + ML(mlCopular),
          IntToStr(Memoria.UltConductas[16]), True);
    end;
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlMovimiento),
        IntToStr(Memoria.NumConductas[1]), True);
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlEnReposo),
        IntToStr(Memoria.NumConductas[2]), True);
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlBeber),
        IntToStr(Memoria.NumConductas[3]), True);
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlCmrAzucar),
        IntToStr(Memoria.NumConductas[4]), True);
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlCmrGrasa),
        IntToStr(Memoria.NumConductas[5]), True);
    vleConductas.InsertRow(ML(mlNumVcs) + ML(mlCmrProteina),
        IntToStr(Memoria.NumConductas[6]), True);
    if Adulto then
    begin
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlDesplegar),
          IntToStr(Memoria.NumConductas[7]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlEscalar),
          IntToStr(Memoria.NumConductas[8]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlRetirar),
          IntToStr(Memoria.NumConductas[9]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlIA),
          IntToStr(Memoria.NumConductas[10]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlIB),
          IntToStr(Memoria.NumConductas[11]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlAceptacion),
          IntToStr(Memoria.NumConductas[12]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlRechazar),
          IntToStr(Memoria.NumConductas[13]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlOvipositar),
          IntToStr(Memoria.NumConductas[14]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlPeleaGanada),
          IntToStr(Memoria.NumConductas[15]), True);
      vleConductas.InsertRow(ML(mlNumVcs) + ML(mlCopular),
          IntToStr(Memoria.NumConductas[16]), True);
    end;   }
    if Adulto then
    begin
      with stgContinuos do
      begin
        Cells[0, 0] := ML(mlCaracter) + '\' + ML(mlGenetico);
        ColWidths[0] := 200;
        for i := 1 to 15 do
        begin
          Cells[0, i] := frmEditorEntornos.Entorno.Juego.Continuos[i].Nombre;
          Cells[1, i] := FloatToStr(ContinuosFijados[i]);
        end;
      end;
      with stgDiscretos do
      begin
        Cells[0, 0] :=  ML(mlCaracter) + '\' + ML(mlGenetico);;
        ColWidths[0] := 200;
        for i := 1 to 15 do
        begin
          Cells[0, i] := frmEditorEntornos.Entorno.Juego.Discretos[i].Nombre;
          Cells[1, i] := IntToStr(DiscretosFijados[i]);
        end;
      end;
    end;
  end;  //with Agente
end;  //proc DespliegaValores

procedure TfrmEditarAgente.FormCreate(Sender: TObject);
begin
  InsertaControles;
end;

procedure TfrmEditarAgente.btbAceptarClick(Sender: TObject);
begin
  ActualizaValores;
end;

procedure TfrmEditarAgente.edtLCP1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtLCM1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtLDP1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtLDM1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.rdbLCDP1Click(Sender: TObject);
var
  i: Integer;
begin                     //Obteniendo número del control
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCP[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Dominante);
end;

procedure TfrmEditarAgente.rdbLCDM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCM[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Dominante);
end;

procedure TfrmEditarAgente.rdbLCRP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCP[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Recesivo);
end;

procedure TfrmEditarAgente.rdbLCRM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCM[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Recesivo);
end;

procedure TfrmEditarAgente.rdbLDDP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDP[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Dominante);
end;

procedure TfrmEditarAgente.rdbLDDM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDM[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Dominante);
end;

procedure TfrmEditarAgente.rdbLDRP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDP[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Recesivo);
end;

procedure TfrmEditarAgente.rdbLDRM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDM[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Recesivo);
end;

procedure TfrmEditarAgente.edtLCP1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLC[i].Caption := ExpresadoContinuo(edtLCP[i].Text, edtLCM[i].Text,
      rdbLCDP[i].Checked, rdbLCDM[i].Checked);
end;

procedure TfrmEditarAgente.edtLCM1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLC[i].Caption := ExpresadoContinuo(edtLCP[i].Text, edtLCM[i].Text,
      rdbLCDP[i].Checked, rdbLCDM[i].Checked);
end;

procedure TfrmEditarAgente.edtLDP1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLD[i].Caption := ExpresadoDiscreto(edtLDP[i].Text, edtLDM[i].Text,
    rdbLDDP[i].Checked, rdbLDDM[i].Checked);
end;

procedure TfrmEditarAgente.edtLDM1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLD[i].Caption := ExpresadoDiscreto(edtLDP[i].Text, edtLDM[i].Text,
    rdbLDDP[i].Checked, rdbLDDM[i].Checked);
end;

procedure TfrmEditarAgente.InsertaControles;
begin
  grpLCP[1] := grpLCP1;
  rdbLCDP[1] := rdbLCDP1;
  rdbLCRP[1] := rdbLCRP1;
  edtLCP[1] := edtLCP1;
  grpLCM[1] := grpLCM1;
  rdbLCDM[1] := rdbLCDM1;
  rdbLCRM[1] := rdbLCRM1;
  edtLCM[1] := edtLCM1;
  grpLC[1] := grpLC1;
  sttLC[1] := sttLC1;
  grpLDP[1] := grpLDP1;
  rdbLDDP[1] := rdbLDDP1;
  rdbLDRP[1] := rdbLDRP1;
  edtLDP[1] := edtLDP1;
  grpLDM[1] := grpLDM1;
  rdbLDDM[1] := rdbLDDM1;
  rdbLDRM[1] := rdbLDRM1;
  edtLDM[1] := edtLDM1;
  grpLD[1] := grpLD1;
  sttLD[1] := sttLD1;
  InsertaCajas;
  InsertaRadios;
  InsertaCuadros;
  with cmbDireccion do
  begin
    Clear;
    Items.Add(ML(mlNO));
    Items.Add('N');
    Items.Add('NE');
    Items.Add(ML(mlW));
    Items.Add('E');
    Items.Add(ML(mlSO));
    Items.Add('S');
    Items.Add('SE');
  end;
end;  //proc InsertaControles

procedure TfrmEditarAgente.InsertaCajas;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    grpLCP[i] := TGroupBox.Create(Self);
    with grpLCP[i] do
    begin
      Name := 'grpLCP' + IntToStr(i);
      Caption := ML(mlLcsPtrn) + ' ' + IntToStr(i);
      Top := grpLCP[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLCP[i-1].Left;
      Height := grpLCP[i-1].Height;
      Width := grpLCP[i-1].Width;
      Parent := grpLCP1.Parent;
    end;
    grpLCM[i] := TGroupBox.Create(Self);
    with grpLCM[i] do
    begin
      Name := 'grpLCM' + IntToStr(i);
      Caption := ML(mlLcsMtrn) + ' ' + IntToStr(i);
      Top := grpLCM[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLCM[i-1].Left;
      Height := grpLCM[i-1].Height;
      Width := grpLCM[i-1].Width;
      Parent := grpLCM1.Parent;
    end;
    grpLC[i] := TGroupBox.Create(Self);
    with grpLC[i] do
    begin
      Name := 'grpLC' + IntToStr(i);
      Caption := ML(mlLcsExprsd) + ' ' + IntToStr(i);
      Top := grpLC[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLC[i-1].Left;
      Height := grpLC[i-1].Height;
      Width := grpLC[i-1].Width;
      Parent := grpLC1.Parent;
    end;
    grpLDP[i] := TGroupBox.Create(Self);
    with grpLDP[i] do
    begin
      Name := 'grpLDP' + IntToStr(i);
      Caption := ML(mlLcsPtrn) + ' ' + IntToStr(i);
      Top := grpLDP[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLDP[i-1].Left;
      Height := grpLDP[i-1].Height;
      Width := grpLDP[i-1].Width;
      Parent := grpLDP1.Parent;
    end;
    grpLDM[i] := TGroupBox.Create(Self);
    with grpLDM[i] do
    begin
      Name := 'grpLDM' + IntToStr(i);
      Caption := ML(mlLcsMtrn) + ' ' + IntToStr(i);
      Top := grpLDM[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLDM[i-1].Left;
      Height := grpLDM[i-1].Height;
      Width := grpLDM[i-1].Width;
      Parent := grpLDM1.Parent;
    end;
    grpLD[i] := TGroupBox.Create(Self);
    with grpLD[i] do
    begin
      Name := 'grpLD' + IntToStr(i);
      Caption := ML(mlLcsExprsd) + ' ' + IntToStr(i);
      Top := grpLD[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLD[i-1].Left;
      Height := grpLD[i-1].Height;
      Width := grpLD[i-1].Width;
      Parent := grpLD1.Parent;
    end;
  end;  //for
end;

procedure TfrmEditarAgente.InsertaCuadros;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    edtLCP[i] := TEdit.Create(Self);
    with edtLCP[i] do
    begin
      Name := 'edtLCP' + IntToStr(i);
      Top := edtLCP[i-1].Top;
      Left := edtLCP[i-1].Left;
      Width := edtLCP[i-1].Width;
      OnChange := edtLCP1Change;
      OnKeyPress := edtLCP1KeyPress;
      Parent := grpLCP[i];
    end;
    edtLCM[i] := TEdit.Create(Self);
    with edtLCM[i] do
    begin
      Name := 'edtLCM' + IntToStr(i);
      Top := edtLCM[i-1].Top;
      Left := edtLCM[i-1].Left;
      Width := edtLCM[i-1].Width;
      OnChange := edtLCM1Change;
      OnKeyPress := edtLCM1KeyPress;
      Parent := grpLCM[i];
    end;
    sttLC[i] := TStaticText.Create(Self);
    with sttLC[i] do
    begin
      Name := 'sttLC' + IntToStr(i);
      AutoSize := False;
      //BevelInner := bvLowered;
      //BevelKind := bkSoft;
      Top := sttLC[i-1].Top;
      Left := sttLC[i-1].Left;
      Width := sttLC[i-1].Width;
      Parent := grpLC[i];
    end;
    edtLDP[i] := TEdit.Create(Self);
    with edtLDP[i] do
    begin
      Name := 'edtLDP' + IntToStr(i);
      Top := edtLDP[i-1].Top;
      Left := edtLDP[i-1].Left;
      Width := edtLDP[i-1].Width;
      OnChange := edtLDP1Change;
      OnKeyPress := edtLDP1KeyPress;
      Parent := grpLDP[i];
    end;
    edtLDM[i] := TEdit.Create(Self);
    with edtLDM[i] do
    begin
      Name := 'edtLDM' + IntToStr(i);
      Top := edtLDM[i-1].Top;
      Left := edtLDM[i-1].Left;
      Width := edtLDM[i-1].Width;
      OnChange := edtLDM1Change;
      OnKeyPress := edtLDM1KeyPress;
      Parent := grpLDM[i];
    end;
    sttLD[i] := TStaticText.Create(Self);
    with sttLD[i] do
    begin
      Name := 'sttLD' + IntToStr(i);
      AutoSize := False;
      //BevelInner := bvLowered;
      //BevelKind := bkSoft;
      Top := sttLD[i-1].Top;
      Left := sttLD[i-1].Left;
      Width := sttLD[i-1].Width;
      Parent := grpLD[i];
    end;
  end;  //for
end;  //proc InsertaCuadros

procedure TfrmEditarAgente.InsertaRadios;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    rdbLCDP[i] := TRadioButton.Create(Self);
    with rdbLCDP[i] do
    begin
      Name := 'rdbLCDP' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLCDP[1].Top;
      Left := rdbLCDP[1].Left;
      Width := rdbLCDP[1].Width;
      Checked := True;
      OnClick := rdbLCDP1Click;
      Parent := grpLCP[i];
    end;
    rdbLCRP[i] := TRadioButton.Create(Self);
    with rdbLCRP[i] do
    begin
      Name := 'rdbLCRP' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLCRP[1].Top;
      Left := rdbLCRP[1].Left;
      Width := rdbLCRP[1].Width;
      OnClick := rdbLCRP1Click;
      Parent := grpLCP[i];
    end;
    rdbLCDM[i] := TRadioButton.Create(Self);
    with rdbLCDM[i] do
    begin
      Name := 'rdbLCDM' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLCDM[1].Top;
      Left := rdbLCDM[1].Left;
      Width := rdbLCDM[1].Width;
      Checked := True;
      OnClick := rdbLCDM1Click;
      Parent := grpLCM[i];
    end;
    rdbLCRM[i] := TRadioButton.Create(Self);
    with rdbLCRM[i] do
    begin
      Name := 'rdbLCRM' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLCRM[1].Top;
      Left := rdbLCRM[1].Left;
      Width := rdbLCRM[1].Width;
      OnClick := rdbLCRM1Click;
      Parent := grpLCM[i];
    end;
    rdbLDDP[i] := TRadioButton.Create(Self);
    with rdbLDDP[i] do
    begin
      Name := 'rdbLDDP' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLDDP[1].Top;
      Left := rdbLDDP[1].Left;
      Width := rdbLDDP[1].Width;
      Checked := True;
      OnClick := rdbLDDP1Click;
      Parent := grpLDP[i];
    end;
    rdbLDRP[i] := TRadioButton.Create(Self);
    with rdbLDRP[i] do
    begin
      Name := 'rdbLDRP' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLDRP[1].Top;
      Left := rdbLDRP[1].Left;
      Width := rdbLDRP[1].Width;
      OnClick := rdbLDRP1Click;
      Parent := grpLDP[i];
    end;
    rdbLDDM[i] := TRadioButton.Create(Self);
    with rdbLDDM[i] do
    begin
      Name := 'rdbLDDM' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLDDM[1].Top;
      Left := rdbLDDM[1].Left;
      Width := rdbLDDM[1].Width;
      Checked := True;
      OnClick := rdbLDDM1Click;
      Parent := grpLDM[i];
    end;
    rdbLDRM[i] := TRadioButton.Create(Self);
    with rdbLDRM[i] do
    begin
      Name := 'rdbLDRM' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLDRM[1].Top;
      Left := rdbLDRM[1].Left;
      Width := rdbLDRM[1].Width;
      OnClick := rdbLDRM1Click;
      Parent := grpLDM[i];
    end;
  end;  //for
end;  //proc InsertaRadios

procedure TfrmEditarAgente.edtCiclosEstadioKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtCiclosSustratoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarAgente.edtCiclosInteraccionKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

initialization
  {$i EditarAgente.lrs}
  {$i EditarAgente.lrs}

end.
