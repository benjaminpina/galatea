unit MatricesInteraccion;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, Buttons, ActnList,
  Menus, LResources;

type

  { TfrmMatricesInteraccion }

  TfrmMatricesInteraccion = class(TForm)
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    stgSustratos: TStringGrid;
    stgDinamicos: TStringGrid;
    stgAgentes: TStringGrid;
    lblClicS: TLabel;
    lblClicD: TLabel;
    lblClicA: TLabel;
    btnImportar: TButton;
    ActionList1: TActionList;
    actCopiar: TAction;
    actPegar: TAction;
    ImageList1: TImageList;
    pumMatrices: TPopupMenu;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    actCopiarA: TAction;
    actPegarA: TAction;
    pumMatricesA: TPopupMenu;
    actCopiarA1: TMenuItem;
    actPegarA1: TMenuItem;
    stgSustratosA: TStringGrid;
    stgDinamicosA: TStringGrid;
    stgAgentesA: TStringGrid;
    GroupBox1: TGroupBox;
    rdbInteraccion: TRadioButton;
    rdbAtractividad: TRadioButton;
    rdbMemoria: TRadioButton;
    stgSustratosM: TStringGrid;
    stgDinamicosM: TStringGrid;
    stgAgentesM: TStringGrid;
    actCopiarM: TAction;
    actPegarM: TAction;
    pumMatricesM: TPopupMenu;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    spbNotas: TSpeedButton;
    btnInicializarS: TButton;
    btnInicializarD: TButton;
    btnInicializarA: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure stgSustratosDblClick(Sender: TObject);
    procedure stgDinamicosDblClick(Sender: TObject);
    procedure stgAgentesDblClick(Sender: TObject);
    procedure actCopiarExecute(Sender: TObject);
    procedure stgSustratosSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgDinamicosSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgAgentesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure actPegarExecute(Sender: TObject);
    procedure stgSustratosASelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgDinamicosASelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgAgentesASelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgSustratosADblClick(Sender: TObject);
    procedure stgDinamicosADblClick(Sender: TObject);
    procedure stgAgentesADblClick(Sender: TObject);
    procedure actCopiarAExecute(Sender: TObject);
    procedure actPegarAExecute(Sender: TObject);
    procedure rdbInteraccionClick(Sender: TObject);
    procedure rdbAtractividadClick(Sender: TObject);
    procedure rdbMemoriaClick(Sender: TObject);
    procedure actCopiarMExecute(Sender: TObject);
    procedure actPegarMExecute(Sender: TObject);
    procedure stgSustratosMSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgDinamicosMSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure stgSustratosMDblClick(Sender: TObject);
    procedure stgDinamicosMDblClick(Sender: TObject);
    procedure stgAgentesMDblClick(Sender: TObject);
    procedure stgAgentesMSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure btbAceptarClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure btnInicializarSClick(Sender: TObject);
    procedure btnInicializarDClick(Sender: TObject);
    procedure btnInicializarAClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Portapapeles,
    PortapapelesA,
    PortapapelesM: string;
    NumMatriz: Word;
    FMatrizVisible: Byte;  //Número de la matriz activa
    procedure Encabezados;
    procedure ImportaValores;
    procedure ExportaValores;
    procedure SetMatrizVisible(const Value: Byte);
  public
    { Public declarations }
    Columna,
    Renglon: Word;
    property MatrizVisible: Byte
      read FMatrizVisible write SetMatrizVisible;
  end;

var
  frmMatricesInteraccion: TfrmMatricesInteraccion;

implementation

uses
  Multilenguaje, EditorAgentes, SeleccionaJuego, Sustratos, LlenarCelda,
  Atractividad, EditorFormulas, EditorNotas, Comunes;


procedure TfrmMatricesInteraccion.Encabezados;
var
  i, NMachos,
  NEstadios, NumRenglones: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    NumRenglones := NumEstadios + NumPrototiposM + NumPrototiposH + 1;
    stgSustratos.RowCount := NumRenglones;
    stgDinamicos.RowCount := NumRenglones;
    stgAgentes.RowCount :=  NumRenglones;
    stgAgentes.ColCount :=  NumRenglones;
    stgSustratosA.RowCount := NumRenglones;
    stgDinamicosA.RowCount := NumRenglones;
    stgAgentesA.RowCount :=  NumRenglones;
    stgAgentesA.ColCount :=  NumRenglones;
    stgSustratosM.RowCount := NumRenglones;
    stgDinamicosM.RowCount := NumRenglones;
    stgAgentesM.RowCount := NumRenglones;
    stgAgentesM.ColCount := NumRenglones;
    stgSustratos.ColWidths[0] := 90;
    stgSustratosA.ColWidths[0] := 90;
    stgSustratosM.ColWidths[0] := 90;
    for i := 1 to 7 do
    begin
      stgSustratos.ColWidths[i] := 90;
      stgSustratosA.ColWidths[i] := 90;
      stgSustratosM.ColWidths[i] := 90;
    end;
    stgDinamicos.ColWidths[0] := 100;
    stgDinamicosA.ColWidths[0] := 100;
    stgDinamicosM.ColWidths[0] := 100;
    for i := 1 to 5 do
    begin
      stgDinamicos.ColWidths[i] := 125;
      stgDinamicosA.ColWidths[i] := 125;
      stgDinamicosM.ColWidths[i] := 125;
    end;
    stgAgentes.ColWidths[0] := 100;
    stgAgentesA.ColWidths[0] := 100;
    stgAgentesM.ColWidths[0] := 100;
    for i := 1 to NumRenglones - 1 do
    begin
      stgAgentes.ColWidths[i] := 110;
      stgAgentesA.ColWidths[i] := 110;
      stgAgentesM.ColWidths[i] := 110;
    end;
    stgSustratos.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlSustratos);
    stgDinamicos.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlDinamico);
    stgAgentes.Cells[0,0] := ML(mlPrototipo) + '\' + ML(mlContendiente);
    stgSustratosA.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlSustratos);
    stgDinamicosA.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlDinamico);
    stgAgentesA.Cells[0,0] := ML(mlPrototipo) + '\' + ML(mlContendiente);
    stgSustratosM.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlSustratos);
    stgDinamicosM.Cells[0,0] := ML(mlAgentes) + '\' + ML(mlDinamico);
    stgAgentesM.Cells[0,0] := ML(mlPrototipo) + '\' + ML(mlContendiente);
    for i := 1 to 7 do
    begin
      stgSustratos.Cells[i,0] := Sustratos[i];
      stgSustratosA.Cells[i,0] := Sustratos[i];
      stgSustratosM.Cells[i,0] := Sustratos[i];
    end;
    stgDinamicos.Cells[1,0] := ML(mlFntAgua);
    stgDinamicos.Cells[2,0] := ML(mlFntAzucar);
    stgDinamicos.Cells[3,0] := ML(mlFntGrasa);
    stgDinamicos.Cells[4,0] := ML(mlFntPrtn);
    stgDinamicos.Cells[5,0] := ML(mlSitOvipo);
    stgDinamicosA.Cells[1,0] := ML(mlFntAgua);
    stgDinamicosA.Cells[2,0] := ML(mlFntAzucar);
    stgDinamicosA.Cells[3,0] := ML(mlFntGrasa);
    stgDinamicosA.Cells[4,0] := ML(mlFntPrtn);
    stgDinamicosA.Cells[5,0] := ML(mlSitOvipo);
    stgDinamicosM.Cells[1,0] := ML(mlFntAgua);
    stgDinamicosM.Cells[2,0] := ML(mlFntAzucar);
    stgDinamicosM.Cells[3,0] := ML(mlFntGrasa);
    stgDinamicosM.Cells[4,0] := ML(mlFntPrtn);
    stgDinamicosM.Cells[5,0] := ML(mlSitOvipo);
    NMachos := NumPrototiposM;
    NEstadios := NumEstadios;
    for i := 1 to NEstadios do
    begin
      stgSustratos.Cells[0,i] := Estadios[i].Nombre;
      stgDinamicos.Cells[0,i] := Estadios[i].Nombre;
      stgAgentes.Cells[0,i] := Estadios[i].Nombre;
      stgAgentes.Cells[i,0] := Estadios[i].Nombre;
      stgSustratosA.Cells[0,i] := Estadios[i].Nombre;
      stgDinamicosA.Cells[0,i] := Estadios[i].Nombre;
      stgAgentesA.Cells[0,i] := Estadios[i].Nombre;
      stgAgentesA.Cells[i,0] := Estadios[i].Nombre;
      stgSustratosM.Cells[0,i] := Estadios[i].Nombre;
      stgDinamicosM.Cells[0,i] := Estadios[i].Nombre;
      stgAgentesM.Cells[0,i] := Estadios[i].Nombre;
      stgAgentesM.Cells[i,0] := Estadios[i].Nombre;
    end;
    for i := 1 to NumPrototiposM do
    begin
      stgSustratos.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgDinamicos.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentes.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentes.Cells[i+NEstadios,0] := PrototiposM[i].Nombre;
      stgSustratosA.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgDinamicosA.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentesA.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentesA.Cells[i+NEstadios,0] := PrototiposM[i].Nombre;
      stgSustratosM.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgDinamicosM.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentesM.Cells[0,i+NEstadios] := PrototiposM[i].Nombre;
      stgAgentesM.Cells[i+NEstadios,0] := PrototiposM[i].Nombre;
    end;
    for i := 1 to NumPrototiposH do
    begin
      stgSustratos.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgDinamicos.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentes.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentes.Cells[i+NMachos+NEstadios,0] := PrototiposH[i].Nombre;
      stgSustratosA.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgDinamicosA.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentesA.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentesA.Cells[i+NMachos+NEstadios,0] := PrototiposH[i].Nombre;
      stgSustratosM.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgDinamicosM.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentesM.Cells[0,i+NMachos+NEstadios] := PrototiposH[i].Nombre;
      stgAgentesM.Cells[i+NMachos+NEstadios,0] := PrototiposH[i].Nombre;
    end;
  end;  //with
end;  //proc Encabezados

procedure TfrmMatricesInteraccion.FormCreate(Sender: TObject);
begin
  Encabezados;
  ImportaValores;
  Portapapeles := '';
  PortapapelesA := '';
  PortapapelesM := '';
  actPegar.Enabled := False;
  actPegarA.Enabled := False;
  stgSustratosA.Top := stgSustratos.Top;
  stgDinamicosA.Top := stgDinamicos.Top;
  stgAgentesA.Top := stgAgentes.Top;
  stgSustratosM.Top := stgSustratos.Top;
  stgDinamicosM.Top := stgDinamicos.Top;
  stgAgentesM.Top := stgAgentes.Top;
  MatrizVisible := 1;
end;

procedure TfrmMatricesInteraccion.ImportaValores;
var
  i, j, k: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    k := NumPrototiposM + NumPrototiposH + NumEstadios;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to k do
      begin
        stgSustratos.Cells[i,j] := MatrizSustratos.Celda[i,j];
        stgSustratosA.Cells[i,j] := MatrizSustratosA.Celda[i,j];
        stgSustratosM.Cells[i,j] := MatrizSustratosM.Celda[i,j];
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to k do
      begin
        stgDinamicos.Cells[i,j] := MatrizDinamicos.Celda[i,j];
        stgDinamicosA.Cells[i,j] := MatrizDinamicosA.Celda[i,j];
        stgDinamicosM.Cells[i,j] := MatrizDinamicosM.Celda[i,j];
      end;
    for i := 1 to k do
      for j := 1 to k do
      begin
        stgAgentes.Cells[i,j] := MatrizAgentes.Celda[i,j];
        stgAgentesA.Cells[i,j] := MatrizAgentesA.Celda[i,j];
        stgAgentesM.Cells[i,j] := MatrizAgentesM.Celda[i,j];
      end;
  end; //with
end;

procedure TfrmMatricesInteraccion.ExportaValores;
var
  i, j, k: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    k := NumPrototiposM + NumPrototiposH + NumEstadios;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to k do
      begin
        MatrizSustratos.Celda[i,j] := stgSustratos.Cells[i,j];
        MatrizSustratosA.Celda[i,j] := stgSustratosA.Cells[i,j];
        MatrizSustratosM.Celda[i,j] := stgSustratosM.Cells[i,j];
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to k do
      begin
        MatrizDinamicos.Celda[i,j] := stgDinamicos.Cells[i,j];
        MatrizDinamicosA.Celda[i,j] := stgDinamicosA.Cells[i,j];
        MatrizDinamicosM.Celda[i,j] := stgDinamicosM.Cells[i,j];
      end;
    for i := 1 to k do
      for j := 1 to k do
      begin
        MatrizAgentes.Celda[i,j] := stgAgentes.Cells[i,j];
        MatrizAgentesA.Celda[i,j] := stgAgentesA.Cells[i,j];
        MatrizAgentesM.Celda[i,j] := stgAgentesM.Cells[i,j];
      end;
  end; //with
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmMatricesInteraccion.btnImportarClick(Sender: TObject);
var
  JuegoSustratos: TJuegoSustratos;
  NombreArchivo,
  RutaSustrato : string;
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
      stgSustratos.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      stgSustratosA.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      stgSustratosM.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
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
      stgSustratos.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      stgSustratosA.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
      stgSustratosM.Cells[i,0] := JuegoSustratos.SustratoSimple[i].Nombre;
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

procedure TfrmMatricesInteraccion.stgSustratosDblClick(Sender: TObject);
begin
  frmLlenarCelda := TfrmLlenarCelda.Create(Application);
  with stgSustratos do
  begin
    frmLlenarCelda.Celda := Cells[Col,Row];
    frmLlenarCelda.Huevo := Row = 1;
    frmLlenarCelda.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmLlenarCelda.Titulo := ML(mlMatrizInt) + '-' + ML(mlSustratos) + '-'
                              + Cells[0,Row] + '\' + Cells[Col,0];
    frmLlenarCelda.Despliega;
    if frmLlenarCelda.ShowModal = mrOK then
      Cells[Col,Row] := frmLlenarCelda.Celda;
    FreeAndNil(frmLlenarCelda);
  end;
end;

procedure TfrmMatricesInteraccion.stgDinamicosDblClick(Sender: TObject);
begin
  frmLlenarCelda := TfrmLlenarCelda.Create(Application);
  with stgDinamicos do
  begin
    frmLlenarCelda.Celda := Cells[Col,Row];
    frmLlenarCelda.Huevo := Row = 1;
    frmLlenarCelda.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmLlenarCelda.Titulo := ML(mlMatrizInt) + '-' + ML(mlDinamicos) + '-'
                              + Cells[0,Row] + '\' + Cells[Col,0];
    frmLlenarCelda.Dinamico := True;
    frmLlenarCelda.Despliega;
    if frmLlenarCelda.ShowModal = mrOK then
      Cells[Col,Row] := frmLlenarCelda.Celda;
    FreeAndNil(frmLlenarCelda);
  end;
end;

procedure TfrmMatricesInteraccion.stgAgentesDblClick(Sender: TObject);
begin
  frmLlenarCelda := TfrmLlenarCelda.Create(Application);
  frmLlenarCelda.InteraccionAgente := True;
  with stgAgentes do
  begin
    frmLlenarCelda.Celda := Cells[Col,Row];
    frmLlenarCelda.Huevo := Row = 1;
    frmLlenarCelda.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmLlenarCelda.Titulo := ML(mlMatrizInt) + '-' + ML(mlAgentes) + '-'
                              + Cells[0,Row] + '\' + Cells[Col,0];
    frmLlenarCelda.Despliega;
    if frmLlenarCelda.ShowModal = mrOK then
      Cells[Col,Row] := frmLlenarCelda.Celda;
    FreeAndNil(frmLlenarCelda);
  end;
end;

procedure TfrmMatricesInteraccion.actCopiarExecute(Sender: TObject);
begin
  case NumMatriz of
    1: Portapapeles := stgSustratos.Cells[Columna,Renglon];//Sustratos
    2: Portapapeles := stgDinamicos.Cells[Columna,Renglon];//Elementos dinámicos
    3: Portapapeles := stgAgentes.Cells[Columna,Renglon];  //Agentes
  end;
  actPegar.Enabled := True;
end;

procedure TfrmMatricesInteraccion.stgSustratosSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 1;
end;

procedure TfrmMatricesInteraccion.stgDinamicosSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 2;
end;

procedure TfrmMatricesInteraccion.stgAgentesSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 3;
end;

procedure TfrmMatricesInteraccion.actPegarExecute(Sender: TObject);
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    case NumMatriz of
      1:
      begin
        stgSustratos.Cells[Columna,Renglon] := Portapapeles;//Sustratos
        MatrizSustratos.Celda[Columna,Renglon] := Portapapeles;
      end;
      2:
      begin
        stgDinamicos.Cells[Columna,Renglon] := Portapapeles;//Elementos din.
        MatrizDinamicos.Celda[Columna,Renglon] := Portapapeles;
      end;
      3:
      begin
        stgAgentes.Cells[Columna,Renglon] := Portapapeles;  //Agentes
        MatrizAgentes.Celda[Columna,Renglon] := Portapapeles;
      end;
    end;  //case
    frmEditorAgentes.Salvado := False;
  end; //with
end;

procedure TfrmMatricesInteraccion.stgSustratosASelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 4;
end;

procedure TfrmMatricesInteraccion.stgDinamicosASelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 5;
end;

procedure TfrmMatricesInteraccion.stgAgentesASelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 6;
end;

procedure TfrmMatricesInteraccion.stgSustratosADblClick(Sender: TObject);
var
  i, j: Integer;
begin
  frmAtractividad := TfrmAtractividad.Create(Application);
  with stgSustratosA do
  begin
    frmAtractividad.Celda := Cells[Col,Row];
    frmAtractividad.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmAtractividad.Despliega;
    frmAtractividad.Titulo := ML(mlSustratos) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if frmAtractividad.ShowModal = mrOK then
    begin
      if frmAtractividad.chbInicializar.Checked then
        for i := 1 to ColCount - 1 do
          for j := 1 to RowCount - 1 do
            Cells[i,j] := frmAtractividad.Celda
      else
        Cells[Col,Row] := frmAtractividad.Celda;
    end;
    FreeAndNil(frmAtractividad);
  end;
end;

procedure TfrmMatricesInteraccion.stgDinamicosADblClick(Sender: TObject);
var
  i, j: Integer;
begin
  frmAtractividad := TfrmAtractividad.Create(Application);
  with stgDinamicosA do
  begin
    frmAtractividad.Celda := Cells[Col,Row];
    frmAtractividad.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmAtractividad.Despliega;
    frmAtractividad.Dinamico := True;
    frmAtractividad.Titulo := ML(mlDinamicos) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if frmAtractividad.ShowModal = mrOK then
    begin
      if frmAtractividad.chbInicializar.Checked then
        for i := 1 to ColCount - 1 do
          for j := 1 to RowCount - 1 do
            Cells[i,j] := frmAtractividad.Celda
      else
        Cells[Col,Row] := frmAtractividad.Celda;
    end;
    FreeAndNil(frmAtractividad);
  end;
end;

procedure TfrmMatricesInteraccion.stgAgentesADblClick(Sender: TObject);
var
  i, j: Integer;
begin
  frmAtractividad := TfrmAtractividad.Create(Application);
  frmAtractividad.InteraccionAgente := True;
  with stgAgentesA do
  begin
    frmAtractividad.Celda := Cells[Col,Row];
    frmAtractividad.Adulto := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmAtractividad.Despliega;
    frmAtractividad.Titulo := ML(mlAgentes) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if frmAtractividad.ShowModal = mrOK then
    begin
      if frmAtractividad.chbInicializar.Checked then
        for i := 1 to ColCount - 1 do
          for j := 1 to RowCount - 1 do
            Cells[i,j] := frmAtractividad.Celda
      else
        Cells[Col,Row] := frmAtractividad.Celda;
    end;
    FreeAndNil(frmAtractividad);
  end;
end;

procedure TfrmMatricesInteraccion.actCopiarAExecute(Sender: TObject);
begin
  case NumMatriz of
    4: PortapapelesA := stgSustratosA.Cells[Columna,Renglon];//Sustratos A.
    5: PortapapelesA := stgDinamicosA.Cells[Columna,Renglon];//Elementos din A.
    6: PortapapelesA := stgAgentesA.Cells[Columna,Renglon];  //Agentes A.
  end;
  actPegarA.Enabled := True;
end;

procedure TfrmMatricesInteraccion.actPegarAExecute(Sender: TObject);
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    case NumMatriz of
      4:
      begin
        stgSustratosA.Cells[Columna,Renglon] := PortapapelesA;//Sustratos A.
        MatrizSustratosA.Celda[Columna,Renglon] := PortapapelesA;
      end;
      5:
      begin
        stgDinamicosA.Cells[Columna,Renglon] := PortapapelesA;//Elementos di. a.
        MatrizDinamicosA.Celda[Columna,Renglon] := PortapapelesA;
      end;
      6:
      begin
        stgAgentesA.Cells[Columna,Renglon] := PortapapelesA;  //Agentes a.
        MatrizAgentesA.Celda[Columna,Renglon] := PortapapelesA;
      end;
    end;  //case
    frmEditorAgentes.Salvado := False;
  end; //with
end;

procedure TfrmMatricesInteraccion.SetMatrizVisible(const Value: Byte);
begin
{Intercambia la visualización entre matrices de interacción/atractividad/memoria}
  FMatrizVisible := Value;
  case FMatrizVisible of
    1:  //Matriz de interacción
      begin
        stgSustratos.Left := 8;
        stgDinamicos.Left := 8;
        stgAgentes.Left := 8;
        stgSustratosA.Left := 1000;
        stgDinamicosA.Left := 1000;
        stgAgentesA.Left := 1000;
        stgSustratosM.Left := 1000;
        stgDinamicosM.Left := 1000;
        stgAgentesM.Left := 1000;
        lblClicS.Caption := ML(mlDblClcEdCl); //Dobler clic para editar celda
        lblClicD.Caption := ML(mlDblClcEdCl);
        lblClicA.Caption := ML(mlDblClcEdCl);
        btnInicializarS.Visible := False;
        btnInicializarD.Visible := False;
        btnInicializarA.Visible := False;
      end;
    2: //Matriz de atractividad
      begin
        stgSustratos.Left := 1000;
        stgDinamicos.Left := 1000;
        stgAgentes.Left := 1000;
        stgSustratosA.Left := 8;
        stgDinamicosA.Left := 8;
        stgAgentesA.Left := 8;
        stgSustratosM.Left := 1000;
        stgDinamicosM.Left := 1000;
        stgAgentesM.Left := 1000;
        lblClicS.Caption := ML(mlDblClcEdCl);
        lblClicD.Caption := ML(mlDblClcEdCl);
        lblClicA.Caption := ML(mlDblClcEdCl);
        btnInicializarS.Visible := False;
        btnInicializarD.Visible := False;
        btnInicializarA.Visible := False;
      end;
    3: //Matriz de memoria
      begin
        stgSustratos.Left := 1000;
        stgDinamicos.Left := 1000;
        stgAgentes.Left := 1000;
        stgSustratosA.Left := 1000;
        stgDinamicosA.Left := 1000;
        stgAgentesA.Left := 1000;
        stgSustratosM.Left := 8;
        stgDinamicosM.Left := 8;
        stgAgentesM.Left := 8;
        lblClicS.Caption := ML(mlDblClcEdFr); //Doble clic abrir editor fórmulas
        lblClicD.Caption := ML(mlDblClcEdFr);
        lblClicA.Caption := ML(mlDblClcEdFr);
        btnInicializarS.Visible := True;
        btnInicializarD.Visible := True;
        btnInicializarA.Visible := True;
      end;
  end;  //case
end;

procedure TfrmMatricesInteraccion.rdbInteraccionClick(Sender: TObject);
begin
  if rdbInteraccion.Checked then
    MatrizVisible := 1;
end;

procedure TfrmMatricesInteraccion.rdbAtractividadClick(Sender: TObject);
begin
  if rdbAtractividad.Checked then
    MatrizVisible := 2;
end;

procedure TfrmMatricesInteraccion.rdbMemoriaClick(Sender: TObject);
begin
  if rdbMemoria.Checked then
    MatrizVisible := 3;
end;

procedure TfrmMatricesInteraccion.actCopiarMExecute(Sender: TObject);
begin
  case NumMatriz of
    7: PortapapelesM := stgSustratosM.Cells[Columna,Renglon];//Sustratos M.
    8: PortapapelesM := stgDinamicosM.Cells[Columna,Renglon];//Elementos din M.
    9: PortapapelesM := stgAgentesM.Cells[Columna,Renglon];  //Agentes M.
  end;
  actPegarA.Enabled := True;
end;

procedure TfrmMatricesInteraccion.actPegarMExecute(Sender: TObject);
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    case NumMatriz of
      7:
      begin
        stgSustratosM.Cells[Columna,Renglon] := PortapapelesM;//Sustratos M.
        MatrizSustratosM.Celda[Columna,Renglon] := PortapapelesM;
      end;
      8:
      begin
        stgDinamicosM.Cells[Columna,Renglon] := PortapapelesM;//Elementos di. M.
        MatrizDinamicosM.Celda[Columna,Renglon] := PortapapelesM;
      end;
      9:
      begin
        stgAgentesM.Cells[Columna,Renglon] := PortapapelesM;  //Agentes M.
        MatrizAgentesM.Celda[Columna,Renglon] := PortapapelesM;
      end;
    end;  //case
    frmEditorAgentes.Salvado := False;
  end; //with
end;

procedure TfrmMatricesInteraccion.stgSustratosMSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 7;
end;

procedure TfrmMatricesInteraccion.stgDinamicosMSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 8;
end;

procedure TfrmMatricesInteraccion.stgSustratosMDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgSustratosM do
  begin
    frmEditorFormulas.Adulto :=
                            (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlMatrizInt) + '-' + ML(mlMemoria) + '-'
                    + ML(mlSustratos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMatricesInteraccion.stgDinamicosMDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgDinamicosM do
  begin
    frmEditorFormulas.Adulto
                        := (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmEditorFormulas.Dinamico := True;
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlMatrizInt) + '-' + ML(mlMemoria) + '-'
                    + ML(mlDinamicos) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMatricesInteraccion.stgAgentesMDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.InteraccionAgente := True;
  with stgAgentesM do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Adulto :=
                            (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmEditorFormulas.Titulo := ML(mlMatrizInt) + '-' + ML(mlMemoria) + '-'
                    + ML(mlAgentes) + '-' + Cells[0,Row] + '\' + Cells[Col,0];
    if frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMatricesInteraccion.stgAgentesMSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  Columna := ACol;
  Renglon := ARow;
  NumMatriz := 9;
end;

procedure TfrmMatricesInteraccion.btbAceptarClick(Sender: TObject);
begin
  ExportaValores;
end;

procedure TfrmMatricesInteraccion.spbNotasClick(Sender: TObject);
var
  Apartados: TStringList;
  i: Integer;
begin
  Apartados := TStringList.Create;
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Interaccion';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  for i := 0 to PageControl1.PageCount - 1 do
    Apartados.Add(PageControl1.Pages[i].Caption);
  frmEditorNotas.CreaApartados(Apartados);
  frmEditorNotas.Show;
  FreeAndNil(Apartados);
end;

procedure TfrmMatricesInteraccion.btnInicializarSClick(Sender: TObject);
var
  s: string;
  i, j: Integer;
begin
  s := '0';
  if InputQuery(ML(mlEdAgntGlt), ML(mlIniTdsClds), s) then
    for i := 1 to stgSustratosM.ColCount - 1 do
      for j := 1 to stgSustratosM.RowCount - 1 do
        stgSustratosM.Cells[i,j] := s;
end;

procedure TfrmMatricesInteraccion.btnInicializarDClick(Sender: TObject);
var
  s: string;
  i, j: Integer;
begin
  s := '0';
  if InputQuery(ML(mlEdAgntGlt), ML(mlIniTdsClds), s) then
    for i := 1 to stgDinamicosM.ColCount - 1 do
      for j := 1 to stgDinamicosM.RowCount - 1 do
        stgDinamicosM.Cells[i,j] := s;
end;

procedure TfrmMatricesInteraccion.btnInicializarAClick(Sender: TObject);
var
  s: string;
  i, j: Integer;
begin
  s := '0';
  if InputQuery(ML(mlEdAgntGlt), ML(mlIniTdsClds), s) then
    for i := 1 to stgAgentesM.ColCount - 1 do
      for j := 1 to stgAgentesM.RowCount - 1 do
        stgAgentesM.Cells[i,j] := s;
end;

procedure TfrmMatricesInteraccion.FormClose(Sender: TObject;
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
  {$i MatricesInteraccion.lrs}

end.
