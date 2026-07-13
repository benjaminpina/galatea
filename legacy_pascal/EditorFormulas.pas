unit EditorFormulas;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, {ValEdit,} Clipbrd, ComCtrls, JuegoAgentes,
  LResources;

type

  { TfrmEditorFormulas }

  TfrmEditorFormulas = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    GroupBox2: TGroupBox;
    edtFormula: TEdit;
    spbEvaluar: TSpeedButton;
    spbBorrar: TSpeedButton;
    btnSuma: TButton;
    btnResta: TButton;
    btnMultiplicacion: TButton;
    btnDivision: TButton;
    btnModulo: TButton;
    btnExponente: TButton;
    btnAleatoria: TButton;
    btnAbreParentesis: TButton;
    btnCierraParentesis: TButton;
    Label1: TLabel;
    PageControl1: TPageControl;
    tbsTiempo: TTabSheet;
    tbsGenetica: TTabSheet;
    tbsMorfologia: TTabSheet;
    tbsFisiologia: TTabSheet;
    tbsReproduccion: TTabSheet;
    tbsMemoria: TTabSheet;
    tbsDinamicos: TTabSheet;
    GroupBox3: TGroupBox;
    stgTiempo: TStringGrid;
    GroupBox1: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    stgGenetica: TStringGrid;
    stgMorfologia: TStringGrid;
    stgFisiologia: TStringGrid;
    stgReproduccion: TStringGrid;
    stgMemoria: TStringGrid;
    stgElementos: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure spbEvaluarClick(Sender: TObject);
    procedure spbBorrarClick(Sender: TObject);
    procedure btnSumaClick(Sender: TObject);
    procedure btnRestaClick(Sender: TObject);
    procedure btnMultiplicacionClick(Sender: TObject);
    procedure btnDivisionClick(Sender: TObject);
    procedure btnModuloClick(Sender: TObject);
    procedure btnExponenteClick(Sender: TObject);
    procedure btnAleatoriaClick(Sender: TObject);
    procedure btnAbreParentesisClick(Sender: TObject);
    procedure btnCierraParentesisClick(Sender: TObject);
    procedure stgTiempoDblClick(Sender: TObject);
    procedure stgGeneticaDblClick(Sender: TObject);
    procedure stgMorfologiaDblClick(Sender: TObject);
    procedure stgFisiologiaDblClick(Sender: TObject);
    procedure stgReproduccionDblClick(Sender: TObject);
    procedure stgMemoriaDblClick(Sender: TObject);
    procedure stgElementosDblClick(Sender: TObject);
    procedure stgTiempoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    JuegoAgentes: TJuegoAgentes;
    Portapapeles: TClipboard;
    FTitulo: string;
    procedure LlenaListas;
    procedure Evalua;
    procedure SetTitulo(const Value: string);
    procedure LLenaListaTiempo;
    procedure LLenaListaGenetica;
    procedure LLenaListaMorfologia;
    procedure LLenaListaFisiologia;
    procedure LLenaListaReproduccion;
    procedure LlenaListaMemoria;
    procedure LLenaListaElemento;
  public
    { Public declarations }
    InteraccionAgente: Boolean;
    Huevo: Boolean;
    Adulto: Boolean;
    Dinamico: Boolean;
    Formula: string;
    property Titulo: string
      read FTitulo write SetTitulo;
  end;

var
  frmEditorFormulas: TfrmEditorFormulas;

implementation

uses
  EditorAgentes, Calculate, Dialogos, Multilenguaje, {TypInfo,} DateUtils;


procedure TfrmEditorFormulas.FormCreate(Sender: TObject);
begin
  Randomize;
  Formula := '';
  InteraccionAgente := False;
  Dinamico := False;
  Adulto := True;
  FTitulo := '';
  Portapapeles := TClipboard.Create;
  JuegoAgentes := frmEditorAgentes.JuegoAgentes;
end;

procedure TfrmEditorFormulas.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Formula := edtFormula.Text;
  Portapapeles.Free;
end;

procedure TfrmEditorFormulas.LlenaListas;
begin
  LLenaListaTiempo;
  LLenaListaGenetica;
  LLenaListaMorfologia;
  LLenaListaFisiologia;
  LLenaListaReproduccion;
  LlenaListaMemoria;
  LLenaListaElemento;
  Beep;
end;

procedure TfrmEditorFormulas.FormShow(Sender: TObject);
begin
  edtFormula.Text := Formula;
  LlenaListas;
  tbsReproduccion.Visible := False;
end;

procedure TfrmEditorFormulas.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmEditorFormulas.Evalua;
var
  Calculadora: TCalculate;
  i: Integer;
  s: string;
begin
  Calculadora := TCalculate.Create;
  with stgTiempo do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgGenetica do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgMorfologia do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgFisiologia do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgReproduccion do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgMemoria do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  with stgElementos do
    for i := 1 to RowCount - 1 do
      Calculadora.Memory.Add(Cells[0,i] + '=' + Cells[1,i]);
  s := Calculadora.GetCustom(edtFormula.Text, '');
  Informa(ML(mlRsltFrml) + ' ' + s, ML(mlEdAgntGlt));
  Calculadora.Free;
end;

procedure TfrmEditorFormulas.spbEvaluarClick(Sender: TObject);
begin
  Evalua;
end;

procedure TfrmEditorFormulas.spbBorrarClick(Sender: TObject);
begin
  edtFormula.Text := '';
end;

procedure TfrmEditorFormulas.btnSumaClick(Sender: TObject);
begin
  Portapapeles.AsText := '+';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnRestaClick(Sender: TObject);
begin
  Portapapeles.AsText := '-';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnMultiplicacionClick(Sender: TObject);
begin
  Portapapeles.AsText := '*';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnDivisionClick(Sender: TObject);
begin
  Portapapeles.AsText := '/';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnModuloClick(Sender: TObject);
begin
  Portapapeles.AsText := '%';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnExponenteClick(Sender: TObject);
begin
  Portapapeles.AsText := '^';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnAleatoriaClick(Sender: TObject);
begin
  Portapapeles.AsText := '#';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnAbreParentesisClick(Sender: TObject);
begin
  Portapapeles.AsText := '(';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.btnCierraParentesisClick(Sender: TObject);
begin
  Portapapeles.AsText := ')';
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.SetTitulo(const Value: string);
begin
  FTitulo := Value;
  Self.Caption := ML(mlEdFormls) + ' [' + FTitulo + ']';
end;

procedure TfrmEditorFormulas.LLenaListaElemento;
var
  i,j: Integer;
begin
  {Variables de elemento dinámico}
  with stgElementos do
  begin
    j := 0;
    RowCount := 3;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    if Dinamico then
    begin
      Cells[0,1] := 'DynamicElementQuality';
      Cells[1,1] := IntToStr(Random(200));
      Cells[0,2] := 'DynamicElementLevel';
      Cells[1,2] := IntToStr(Random(200));
    end;
  {Variables de contendiente}
    if InteraccionAgente then
    begin
      RowCount:= 32;
      Cells[0,j+1] := 'NumLifeStageContender';
      Cells[1,j+1] := IntToStr(3);
      j := j + 1;
      for i := 1 to 15 do
      begin
        Cells[0,j+i] := JuegoAgentes.Continuos[i].Nombre + 'Contender';
        Cells[1,j+i] := JuegoAgentes.Continuos[i].Omision;
        Cells[0,j+i+15] := JuegoAgentes.Discretos[i].Nombre + 'Contender';
        Cells[1,j+i+15] := JuegoAgentes.Discretos[i].Omision;
      end;
      j := j + 30;
      Cells[0,j] := 'VirginityContender';
      Cells[1,j] := IntToStr(Random(2));
      j := j + 1;
    end;
  end;  //with
end;

procedure TfrmEditorFormulas.LLenaListaFisiologia;
begin
  {Variables fisiológicas}
  with stgFisiologia do
  begin
    RowCount := 5;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    Cells[0,1] := 'ReserveWater';
    Cells[1,1] := IntToStr(Random(200));
    Cells[0,2] := 'ReserveCarbohidrates';
    Cells[1,2] := IntToStr(Random(200));
    Cells[0,3] := 'ReserveLipids';
    Cells[1,3] := IntToStr(Random(200));
    Cells[0,4] := 'ReserveProtein';
    Cells[1,4] := IntToStr(Random(200));
  end;
end;

procedure TfrmEditorFormulas.LLenaListaGenetica;
var
  j: Integer;
begin
  {Variables geneticas}
  with stgGenetica do
  begin
    RowCount := 31;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    for j := 1 to 15 do
    begin
      Cells[0,j] := 'CL' + IntToStr(j);
      Cells[1,j] := FloatToStr(JuegoAgentes.LociContinuos[j].Dominante);
      Cells[0,15+j] := 'DL' + IntToStr(j);
      Cells[1,15+j] := IntToStr(JuegoAgentes.LociDiscretos[j].Dominante);
    end;
  end;
end;

procedure TfrmEditorFormulas.LLenaListaMorfologia;
var
  j: Integer;
begin
  {Variables morfológicas}
  with stgMorfologia do
  begin
    RowCount := 31;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    for j := 1 to 15 do
    begin
      Cells[0,j] := JuegoAgentes.Continuos[j].Nombre;
      Cells[1,j] := JuegoAgentes.Continuos[j].Omision;
      Cells[0,j+15] := JuegoAgentes.Discretos[j].Nombre;
      Cells[1,j+15] := JuegoAgentes.Discretos[j].Omision;
    end;
  end;
end;

procedure TfrmEditorFormulas.LLenaListaReproduccion;
begin
  {Variables reproductivas}
  with stgReproduccion do
  begin
    RowCount := 7;
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    Cells[0,1] := 'QuantitySpermPacks';
    Cells[1,1] := IntToStr(Random(50));
    Cells[0,2] := 'QuantityEggs';
    Cells[1,2] := IntToStr(Random(50));
    Cells[0,3] := 'QuantityFertilizedEggs';
    Cells[1,3] := IntToStr(Random(50));
    Cells[0,4] := 'QuantityCarriedEggs';
    Cells[1,4] := IntToStr(Random(50));
    Cells[0,5] := 'QuantitySpermPacksStored';
    Cells[1,5] := IntToStr(Random(50));
    Cells[0,6] := 'Virginity';
    Cells[1,6] := IntToStr(Random(2));
  end;
end;

procedure TfrmEditorFormulas.LLenaListaTiempo;
begin
  {Variables de tiempo}
  with stgTiempo do
  begin
    RowCount := 7;
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    Cells[0,1] := 'Cycles';
    Cells[1,1] := IntToStr(Random(500));
    Cells[0,2] := 'Age';
    Cells[1,2] :=  IntToStr(Random(500));
    Cells[0,3] := 'NumLifeStage';
    Cells[1,3] := IntToStr(3);
    Cells[0,4] := 'CyclesInCurrentLifeStage';
    Cells[1,4] := IntToStr(200);
    Cells[0,5] := 'CyclesOnSubstrate';
    Cells[1,5] := IntToStr(100);
    Cells[0,6] := 'CyclesInCurrentInteraction';
    Cells[1,6] := IntToStr(200);
  end;
end;

procedure TfrmEditorFormulas.stgTiempoDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgTiempo.Cells[0,stgTiempo.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgGeneticaDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgGenetica.Cells[0,stgGenetica.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgMorfologiaDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgMorfologia.Cells[0,stgMorfologia.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgFisiologiaDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgFisiologia.Cells[0,stgFisiologia.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgReproduccionDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgReproduccion.Cells[0,stgReproduccion.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgMemoriaDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgMemoria.Cells[0,stgMemoria.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.stgElementosDblClick(Sender: TObject);
begin
  Portapapeles.AsText := stgElementos.Cells[0,stgElementos.Row];
  edtFormula.PasteFromClipboard;
end;

procedure TfrmEditorFormulas.LlenaListaMemoria;
var
  i, j: Integer;
begin
  {Variables de memoria}
  with stgMemoria do
  begin
    RowCount := 100;
    ColWidths[0] := 200;
    ColWidths[1] := 400;
    Cells[0,0] := 'Variables';
    Cells[1,0] := ML(mlValores);
    for i := 1 to 7 do  //Num Sutratos = 7
    begin
      Cells[0,i] := 'MemoryLastPer' + JuegoAgentes.Sustratos[i];
      Cells[1,i] := '-1';
    end;
    j := 7;
    Cells[0,j+1] := 'MemoryLastIntWaterSource';
    Cells[1,j+1] := '-1';
    Cells[0,j+2] := 'MemoryLastIntSugarSource';
    Cells[1,j+2] := '-1';
    Cells[0,j+3] := 'MemoryLastIntFatSource';
    Cells[1,j+3] := '-1';
    Cells[0,j+4] := 'MemoryLastIntProteinSource';
    Cells[1,j+4] := '-1';
    Cells[0,j+5] := 'MemoryLastIntOvipositionSite';
    Cells[1,j+5] := '-1';
    j := j + 5;
    for i := 1 to JuegoAgentes.NumEstadios do
    begin
      Cells[0,j+i] := 'MemoryLastInt' + JuegoAgentes.Estadios[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumEstadios;
    for i := 1 to JuegoAgentes.NumPrototiposM do
    begin
      Cells[0,j+i] := 'MemoryLastInt' + JuegoAgentes.PrototiposM[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumPrototiposM;
    for i := 1 to JuegoAgentes.NumPrototiposH do
    begin
      Cells[0,j+i] := 'MemoryLastInt' + JuegoAgentes.PrototiposH[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumPrototiposH;
    for i := 1 to 7 do  //Num Sutratos = 7
    begin
      Cells[0,j+i] := 'MemoryNumPer' + JuegoAgentes.Sustratos[i];
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + 7;
    Cells[0,j+1] := 'MemoryNumIntWaterSource';
    Cells[1,j+1] := IntToStr(Random(100));
    Cells[0,j+2] := 'MemoryNumIntSugarSource';
    Cells[1,j+2] := IntToStr(Random(100));
    Cells[0,j+3] := 'MemoryNumIntFatSource';
    Cells[1,j+3] := IntToStr(Random(100));
    Cells[0,j+4] := 'MemoryNumIntProteinSource';
    Cells[1,j+4] := IntToStr(Random(100));
    Cells[0,j+5] := 'MemoryNumIntOvipositionSite';
    Cells[1,j+5] := IntToStr(Random(100));
    j := j + 5;
    for i := 1 to JuegoAgentes.NumEstadios do
    begin
      Cells[0,j+i] := 'MemoryNumInt' + JuegoAgentes.Estadios[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumEstadios;
    for i := 1 to JuegoAgentes.NumPrototiposM do
    begin
      Cells[0,j+i] := 'MemoryNumInt' + JuegoAgentes.PrototiposM[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumPrototiposM;
    for i := 1 to JuegoAgentes.NumPrototiposH do
    begin
      Cells[0,j+i] := 'MemoryNumInt' + JuegoAgentes.PrototiposH[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumPrototiposH;
    Cells[0,j+1] := 'MemoryLastPerWaterSource';
    Cells[1,j+1] := '-1';
    Cells[0,j+2] := 'MemoryLastPerSugarSource';
    Cells[1,j+2] := '-1';
    Cells[0,j+3] := 'MemoryLastPerFatSource';
    Cells[1,j+3] := '-1';
    Cells[0,j+4] := 'MemoryLastPerProteinSource';
    Cells[1,j+4] := '-1';
    Cells[0,j+5] := 'MemoryLastPerOvipositionSite';
    Cells[1,j+5] := '-1';
    j := j + 5;
    for i := 1 to JuegoAgentes.NumEstadios do
    begin
      Cells[0,j+i] := 'MemoryLastPer' + JuegoAgentes.Estadios[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumEstadios;
    for i := 1 to JuegoAgentes.NumPrototiposM do
    begin
      Cells[0,j+i] := 'MemoryLastPer' + JuegoAgentes.PrototiposM[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumPrototiposM;
    for i := 1 to JuegoAgentes.NumPrototiposH do
    begin
      Cells[0,j+i] := 'MemoryLastPer' + JuegoAgentes.PrototiposH[i].Nombre;
      Cells[1,j+i] := '-1';
    end;
    j := j + JuegoAgentes.NumPrototiposH;
    Cells[0,j+1] := 'MemoryNumPerWaterSource';
    Cells[1,j+1] := IntToStr(Random(100));
    Cells[0,j+2] := 'MemoryNumPerSugarSource';
    Cells[1,j+2] := IntToStr(Random(100));
    Cells[0,j+3] := 'MemoryNumPerFatSource';
    Cells[1,j+3] := IntToStr(Random(100));
    Cells[0,j+4] := 'MemoryNumPerProteinSource';
    Cells[1,j+4] := IntToStr(Random(100));
    Cells[0,j+5] := 'MemoryNumPerOvipositionSite';
    Cells[1,j+5] := IntToStr(Random(100));
    j := j + 5;
    for i := 1 to JuegoAgentes.NumEstadios do
    begin
      Cells[0,j+i] := 'MemoryNumPer' + JuegoAgentes.Estadios[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumEstadios;
    for i := 1 to JuegoAgentes.NumPrototiposM do
    begin
      Cells[0,j+i] := 'MemoryNumPer' + JuegoAgentes.PrototiposM[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumPrototiposM;
    for i := 1 to JuegoAgentes.NumPrototiposH do
    begin
      Cells[0,j+i] := 'MemoryNumPer' + JuegoAgentes.PrototiposH[i].Nombre;
      Cells[1,j+i] := IntToStr(Random(100));
    end;
    j := j + JuegoAgentes.NumPrototiposH;
    Cells[0,j+1] := 'MemoryLastMovement';
    Cells[1,j+1] := '-1';
    Cells[0,j+2] := 'MemoryLastRest';
    Cells[1,j+2] := '-1';
    Cells[0,j+3] := 'MemoryLastDrink';
    Cells[1,j+3] := '-1';
    Cells[0,j+4] := 'MemoryLastEatSugar';
    Cells[1,j+4] := '-1';
    Cells[0,j+5] := 'MemoryLastEatFat';
    Cells[1,j+5] := '-1';
    Cells[0,j+6] := 'MemoryLastEatProtein';
    Cells[1,j+6] := '-1';
    j := j + 6;
    if Adulto then
    begin
      Cells[0,j+1] := 'MemoryLastDisplay';
      Cells[1,j+1] := '-1';
      Cells[0,j+2] := 'MemoryLastEscalate';
      Cells[1,j+2] := '-1';
      Cells[0,j+3] := 'MemoryLastRetreat';
      Cells[1,j+3] := '-1';
      Cells[0,j+4] := 'MemoryLastWonFight';
      Cells[1,j+4] := '-1';
      Cells[0,j+5] := 'MemoryLastLostFight';
      Cells[1,j+5] := '-1';
      Cells[0,j+6] := 'MemoryLastDisplayAttemp';
      Cells[1,j+6] := '-1';
      Cells[0,j+7] := 'MemoryLastEscalateAttemp';
      Cells[1,j+7] := '-1';
      Cells[0,j+8] := 'MemoryLastReject';
      Cells[1,j+8] := '-1';
      Cells[0,j+9] := 'MemoryLastCopulate';
      Cells[1,j+9] := '-1';
      Cells[0,j+10] := 'MemoryLastOviposition';
      Cells[1,j+10] := '-1';
      j := j + 10;
    end;
    Cells[0,j+1] := 'MemoryNumMovement';
    Cells[1,j+1] := IntToStr(Random(100));
    Cells[0,j+2] := 'MemoryNumRest';
    Cells[1,j+2] := IntToStr(Random(100));
    Cells[0,j+3] := 'MemoryNumDrink';
    Cells[1,j+3] := IntToStr(Random(100));
    Cells[0,j+4] := 'MemoryNumEatSugar';
    Cells[1,j+4] := IntToStr(Random(100));
    Cells[0,j+5] := 'MemoryNumEatFat';
    Cells[1,j+5] := IntToStr(Random(100));
    Cells[0,j+6] := 'MemoryNumEatProtein';
    Cells[1,j+6] := IntToStr(Random(100));
    j := j + 6;
    if Adulto then
    begin
      Cells[0,j+1] := 'MemoryNumDisplay';
      Cells[1,j+1] := IntToStr(Random(100));
      Cells[0,j+2] := 'MemoryNumEscalate';
      Cells[1,j+2] := IntToStr(Random(100));
      Cells[0,j+3] := 'MemoryNumRetreat';
      Cells[1,j+3] := IntToStr(Random(100));
      Cells[0,j+4] := 'MemoryNumWonFight';
      Cells[1,j+4] := IntToStr(Random(100));
      Cells[0,j+5] := 'MemoryNumLostFight';
      Cells[1,j+5] := IntToStr(Random(100));
      Cells[0,j+6] := 'MemoryNumDisplayAttemp';
      Cells[1,j+6] := IntToStr(Random(100));
      Cells[0,j+7] := 'MemoryNumEscalateAttemp';
      Cells[1,j+7] := IntToStr(Random(100));
      Cells[0,j+8] := 'MemoryNumReject';
      Cells[1,j+8] := IntToStr(Random(100));
      Cells[0,j+9] := 'MemoryNumCopulate';
      Cells[1,j+9] := IntToStr(Random(100));
      Cells[0,j+10] := 'MemoryNumOviposition';
      Cells[1,j+10] := IntToStr(Random(100));
      j := j + 10;
    end;
    RowCount := j + 1;
  end;  //with
end;

procedure TfrmEditorFormulas.stgTiempoKeyPress(Sender: TObject;
  var Key: Char);
begin
  with Sender as TStringGrid do
  begin
    if (Name = 'stgGenetica') or (Name = 'stgMorfologia') then
    begin
      if not (Key in ['0'..'9', '.', #13, #8]) then
        Key := #0;
    end
    else
      if not (Key in ['0'..'9', #13, #8]) then
        Key := #0;
  end;
end;

initialization
  {$i EditorFormulas.lrs}

end.

