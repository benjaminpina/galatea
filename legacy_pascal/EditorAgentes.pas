unit EditorAgentes;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, ComCtrls, JuegoAgentes,
  IniFiles, Comunes, ExtCtrls, StdCtrls, LResources;

type
  TfrmEditorAgentes = class(TForm)
    ActionList1: TActionList;
    actNuevo: TAction;
    actAbrir: TAction;
    actGuardar: TAction;
    actGuardarComo: TAction;
    actCerrar: TAction;
    actSalir: TAction;
    actMorfologia: TAction;
    actFisiologia: TAction;
    actEstadios: TAction;
    actMatrices: TAction;
    actPrototipos: TAction;
    actAyuda: TAction;
    actAcerca: TAction;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    NewSetofAgents1: TMenuItem;
    OpenSetofAgents1: TMenuItem;
    SaveSetofAgents1: TMenuItem;
    SaveSetofAgentsas1: TMenuItem;
    CloseSetofAgents1: TMenuItem;
    N1: TMenuItem;
    R11: TMenuItem;
    R21: TMenuItem;
    R31: TMenuItem;
    R41: TMenuItem;
    R51: TMenuItem;
    N2: TMenuItem;
    ExitGalateaAgentEditor1: TMenuItem;
    Phenotype1: TMenuItem;
    Morphology1: TMenuItem;
    Physiology1: TMenuItem;
    Stagesoflife1: TMenuItem;
    Conducts1: TMenuItem;
    Interactionmatrixes1: TMenuItem;
    Prototypes1: TMenuItem;
    Editprototypelist1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    About1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    StatusBar1: TStatusBar;
    //ApplicationEvents1: TApplicationEvents;
    dlgAbrirAgentes: TOpenDialog;
    dlgGuardarAgentes: TSaveDialog;
    actPropiedades: TAction;
    SetofAgentsproperties1: TMenuItem;
    actGenerales: TAction;
    Generaloptions1: TMenuItem;
    Options1: TMenuItem;
    actMemoria: TAction;
    Conductsmemory1: TMenuItem;
    actGenetica: TAction;
    Genotype1: TMenuItem;
    Loci1: TMenuItem;
    actAsignacion: TAction;
    Prototypeallocation1: TMenuItem;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    actExportar: TAction;
    N3: TMenuItem;
    Exportdata1: TMenuItem;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton8: TToolButton;
    //XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure actSalirExecute(Sender: TObject);
    procedure actNuevoExecute(Sender: TObject);
    procedure actCerrarExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actGuardarExecute(Sender: TObject);
    procedure actGuardarComoExecute(Sender: TObject);
    procedure R11Click(Sender: TObject);
    procedure R21Click(Sender: TObject);
    procedure R31Click(Sender: TObject);
    procedure R41Click(Sender: TObject);
    procedure R51Click(Sender: TObject);
    procedure actPropiedadesExecute(Sender: TObject);
    procedure actMorfologiaExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actGeneralesExecute(Sender: TObject);
    procedure actPrototiposExecute(Sender: TObject);
    procedure actMatricesExecute(Sender: TObject);
    procedure actFisiologiaExecute(Sender: TObject);
    procedure actEstadiosExecute(Sender: TObject);
    procedure actAcercaExecute(Sender: TObject);
    procedure actMemoriaExecute(Sender: TObject);
    procedure actGeneticaExecute(Sender: TObject);
    procedure actAsignacionExecute(Sender: TObject);
    procedure actExportarExecute(Sender: TObject);
  private
    { Private declarations }
    function VerificaSalvado: Boolean;
    procedure BarraNoEditar;
    procedure BarraTotal;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure GuardaReciente(PNombreArchivo: string);
    procedure ActualizaMenuRecientes;
    procedure InicializaJuegoAgentes;
  public
    { Public declarations }
    NombreArchivo: string;
    ArchivoInicio: TIniFile;
    Salvado: Boolean;
    //Determina si el archivo ha sido guardado desde la última modificación
    JuegoAgentes: TJuegoAgentes;
    procedure InicializaEstadios(De, Al, Omision: Word; Nombres: Boolean);
    procedure InicializaPrototipos; overload;
    procedure InicializaPrototipos(De, Al: Word; Sexo: TSexo; Nombres: Boolean);
        overload;
    procedure CambiaNombreVariable(De, A: string);
    procedure CambiaNombreVariablePrefijos(De, A: string);
    procedure CambiaNombreVariableSufijos(De, A: string);
  end;

var
  frmEditorAgentes: TfrmEditorAgentes;

implementation

uses
  {ShlObj,} Dialogos, Multilenguaje, NuevoJuegoAgentes,
  PropiedadesJuegoAgentes, Morfologia, GeneralesAg,
  Prototipos, MatricesInteraccion, Fisiologia, Estadios, AcercaEdAg,
  MemoriaConducta, Genetica, Asignacion, ExportarAgentes;//, Candado;


function TfrmEditorAgentes.VerificaSalvado: Boolean;
{Verifica si el archivo ha sido guardado desde la última modificación, si el
archivo no ha sido guardado pregunta al usuario si desea guardarlo.
Regresa False si el usuario cancela la acción de cerrar archivo}
var
  Respuesta: TRespuesta;
begin
  Result := True;
  if Assigned(JuegoAgentes) then
  begin
    if not Salvado then
    begin
      Respuesta := PreguntaSNC(ML(mlGrdAgntCr), ML(mlEdAgntGlt));
      case Respuesta of                                   //¿guardar antes?
        rSi : actGuardar.Execute;
        rNo : Salvado := True;
        rCancelar :
        begin
          Result := False;
          Exit; //-->
        end;
      end;
    end;
    actCerrar.Execute;
  end;
end;

procedure TfrmEditorAgentes.FormCreate(Sender: TObject);
begin
  {Candado de seguridad
  if not Llave('galatea', '') then
  begin
    Fallo('Ilegal copy / copia ilegal', 'Galatea');
    Halt; //--->
  end;
  Candado de seguridad}
  BarraNoEditar;
  ArchivoInicio := TIniFile.Create('.galatea.ini');
  ActualizaMenuRecientes;
  if ParamCount <> 0 then
  begin
    NombreArchivo := ParamStr(1);
    if ExtractFileExt(NombreArchivo) = '.agl' then
      AbreArchivo(NombreArchivo)
    else
      Fallo(ML(mlErrExtNCEA), ML(mlEdAgntGlt));
  end;
end;

procedure TfrmEditorAgentes.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrmEditorAgentes.actSalirExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmEditorAgentes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := VerificaSalvado;
end;

procedure TfrmEditorAgentes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ArchivoInicio.Free;
end;

procedure TfrmEditorAgentes.InicializaPrototipos;
var
  Prototipo: TPrototipo;
  i, j: Integer;
begin
  with JuegoAgentes do
  begin
    for j := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[j];
      for i := 1 to 15 do
      begin
        Prototipo.Continuos[i].ValorGenetico := Continuos[i].Omision;
        Prototipo.Discretos[i].ValorGenetico := Discretos[i].Omision;
        Prototipo.Continuos[i].ValorAmbiental := '0';
        Prototipo.Discretos[i].ValorAmbiental := '0';
      end;
      PrototiposM[j] := Prototipo;
    end;
    for j := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[j];
      for i := 1 to 15 do
      begin
        Prototipo.Continuos[i].ValorGenetico := Continuos[i].Omision;
        Prototipo.Discretos[i].ValorGenetico := Discretos[i].Omision;
      end;
      PrototiposH[j] := Prototipo;
    end;
  end;
end;

procedure TfrmEditorAgentes.InicializaPrototipos(De, Al: Word;
  Sexo: TSexo; Nombres: Boolean);
{Inicaliza los prototipos en el arreglo de los mismos a partir del índice De y
hasta Al, utilizando los valores por omisión especificados en Morfología.
Si Nombres es True también se inicializan los nombres}
var
  Prototipo  : TPrototipo;
  i, j       : Integer;
  Omision    : Word;
  OmisionTend: string;
begin
  Omision := frmEditorAgentes.ArchivoInicio.ReadInteger
                              ('GeneralesEditorAgentes', 'OmisionDiscretas', 2);
  OmisionTend := ArchivoInicio.ReadString('GeneralesEditorAgentes',
                            'OmisionTendencias', '25,50,25,10,10,1,1,1,1');
  with JuegoAgentes do
  begin
    Prototipo.Color := clWhite;
    Prototipo.Longevidad := IntToStr(Omision * 100);
    Prototipo.RefractarioCombate := IntToStr(Omision * 10);
    Prototipo.RefractarioCortejo := IntToStr(Omision * 10);
    for i := 1 to 15 do
    begin
      Prototipo.Continuos[i].ValorGenetico := Continuos[i].Omision;
      Prototipo.Discretos[i].ValorGenetico := Discretos[i].Omision;
    end;
    for i := 1 to 3 do
      for j := 1 to 2 do
        Prototipo.Combate[i,j] := '0';
    for i := 1 to 4 do
      for j := 1 to 3 do
        Prototipo.Cortejo[i,j] := '0';
    for i := 1 to 8 do
      Prototipo.Tendencias[i] := ObtenNsimo(OmisionTend, i); 
    if Sexo = sxMacho then
    begin
      for i := De to Al do
      begin
        if Nombres then
          Prototipo.Nombre := ML(mlMacho) + IntToStr(i)
        else
          Prototipo.Nombre := PrototiposM[i].Nombre;
        PrototiposM[i] := Prototipo;
      end;
    end
    else
    begin
      for i := De to Al do
      begin
        if Nombres then
          Prototipo.Nombre := ML(mlHembra) + IntToStr(i)
        else
          Prototipo.Nombre := PrototiposH[i].Nombre;
        Prototipo.ProporcionMachos := '1';
        Prototipo.ProporcionHembras := '1';
        PrototiposH[i] := Prototipo;
      end;  //for
    end;  //else
  end;  //with
end;  //proc

procedure TfrmEditorAgentes.InicializaJuegoAgentes;
var
 i, j       : Integer;
 OmisionCont: Real;
 OmisionDisc: Word;
begin
  OmisionDisc := ArchivoInicio.ReadInteger
                            ('GeneralesEditorAgentes', 'OmisionDiscretas', 2);
  OmisionCont := ArchivoInicio.ReadFloat('GeneralesEditorAgentes',
                                'OmisionContinuas', 2);
  with JuegoAgentes do
  begin
    MaxHuevos := IntToStr(OmisionDisc);
    MaxPaquetes := IntToStr(OmisionDisc);
    PaquetesTransferidos := IntToStr(OmisionDisc);
    HuevosFertilizados := '1';
    Paternidad := IntToStr(OmisionDisc);
    MaxPaquetesH := IntToStr(OmisionDisc);
    TasaConsumo := '1';
    HuevosCiclo := '1';
    FraccionHuevo := '0';
    FraccionPaquete := '0';
    DegradacionEsperma := '0.1';
    JerarquiaM := '1,';
    JerarquiaH := '1,';
    for j := 0 to NumPrototiposM - 1 do
    begin
      CriteriosM[0,j] := '0';
      CriteriosM[1,j] := '=';
      CriteriosM[2,j] := '0';
    end;
    for j := 0 to NumPrototiposH - 1 do
    begin
      CriteriosH[0,j] := '0';
      CriteriosH[1,j] := '=';
      CriteriosH[2,j] := '0';
    end;
    for i := 1 to 4 do
      CostoHuevo[i] := IntToStr(OmisionDisc);
    for i := 1 to 4 do
      CostoPaquete[i] := IntToStr(OmisionDisc);
    for i := 1 to 7 do
      Sustratos[i] := ML(mlSustrato) + IntToStr(i);
    for i := 1 to 15 do
    begin
      Continuos[i].Nombre := ML(mlContinuo) + IntToStr(i);
      Continuos[i].Omision := FloatToStr(OmisionCont);
      Discretos[i].Nombre := ML(mlDiscreto) + IntToStr(i);
      Discretos[i].Omision := IntToStr(OmisionDisc);
    end;
    for i := 1 to 15 do
    begin
      LociContinuos[i].Dominante := 0;
      LociContinuos[i].Recesivo := 0;
      LociContinuos[i].MutacionD := 0;
      LociContinuos[i].MutacionR := 0;
      LociContinuos[i].RangoMutacionD := 0;
      LociContinuos[i].RangoMutacionR := 0;
      LociDiscretos[i].Dominante := 0;
      LociDiscretos[i].Recesivo := 0;
      LociContinuos[i].MutacionD := 0;
      LociContinuos[i].MutacionR := 0;
      LociContinuos[i].RangoMutacionD := 0;
      LociContinuos[i].RangoMutacionR := 0;
    end;
    for i := 1 to 4 do
    begin
      Movimiento.Costos[i,1] := IntToStr(OmisionDisc);
      Movimiento.Costos[i,2] := IntToStr(OmisionDisc);
    end;
    for i := 1 to 7 do  //Número de sustratos = 7
      Movimiento.Velocidad[i] := '1';
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j] := IntToStr(OmisionDisc);
    for i := 1 to 4 do
      Alimentacion.Ganancias[i] := IntToStr(OmisionDisc * 2);
    for i := 1 to 4 do
      for j := 1 to 3 do
        CostosCombate[i,j] := IntToStr(OmisionDisc);
    for i := 1 to 4 do
      for j := 1 to 6 do
        CostosCortejo[i,j] := IntToStr(OmisionDisc);
    for i := 1 to 7 do   //Número de sustratos = 7
    begin
      MatrizSustratos.Celda[i,1] := NVeces('0,', 12);
      for j := 2 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizSustratos.Celda[i,j] := '1,' + NVeces('0,', 11);
    end;  //for
    for i := 1 to 5 do   //Número de elementos dinámicos = 5
    begin
      MatrizDinamicos.Celda[i,1] := NVeces('0,', 12);
      for j := 2 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizDinamicos.Celda[i,j] := '1,' + NVeces('0,', 11);
    end;  //for
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
    begin
      MatrizAgentes.Celda[i,1] := NVeces('0,', 12);
      for j := 2 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizAgentes.Celda[i,j] := '1,' + NVeces('0,', 11);
    end;  //for
    for j := 1 to 4 do
    begin
      Metabolismo[1,j] := IntToStr(OmisionDisc);       //Mínimo
      Metabolismo[2,j] := IntToStr(OmisionDisc * 5);   //Crítico
      Metabolismo[3,j] := IntToStr(OmisionDisc * 10);  //Óptimo
      Metabolismo[4,j] := IntToStr(OmisionDisc * 20);  //Inicial
      Metabolismo[5,j] := IntToStr(OmisionDisc * 30);  //Máximo
    end;  //for
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratosA.Celda[i,j] := '0,1';
        MatrizSustratosM.Celda[i,j] := 'Age';
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicosA.Celda[i,j] := '0,1';
        MatrizDinamicosM.Celda[i,j] := 'Age';
      end;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentesA.Celda[i,j] := '0,1';
        MatrizAgentesM.Celda[i,j] := 'Age';
      end;
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j] := 'Age';
    InicializaEstadios(1, NumEstadios, OmisionDisc, True);
    InicializaPrototipos(1, NumPrototiposM, sxMacho, True);
    InicializaPrototipos(1, NumPrototiposH, sxHembra, True);
  end; //with
end;

procedure TfrmEditorAgentes.actNuevoExecute(Sender: TObject);
begin
  if not VerificaSalvado then
    Exit; //-->
  Salvado := True;
  JuegoAgentes := TJuegoAgentes.Create;
  frmNuevoJuegoAgentes := TfrmNuevoJuegoAgentes.Create(Application);
  if frmNuevoJuegoAgentes.ShowModal <> mrOK then
  begin
    FreeAndNil(JuegoAgentes);
    Exit; //-->
  end;
  JuegoAgentes.Titulo := frmNuevoJuegoAgentes.edtTitulo.Text;
  JuegoAgentes.Comentarios := frmNuevoJuegoAgentes.memComentarios.Text;
  InicializaJuegoAgentes;
  FreeAndNil(frmNuevoJuegoAgentes);
  Salvado := False;
  NombreArchivo := ML(mlJgoAgnts);
  Self.Caption := ML(mlEdAgntGlt) + ' [' + NombreArchivo + ']';
  BarraTotal;
end;

procedure TfrmEditorAgentes.BarraNoEditar;
begin
  actGuardar.Enabled := False;
  actGuardarComo.Enabled := False;
  actCerrar.Enabled := False;
  actExportar.Enabled := False;
  actGenetica.Enabled := False;
  actMorfologia.Enabled := False;
  actFisiologia.Enabled := False;
  actEstadios.Enabled := False;
  actMatrices.Enabled := False;
  actMemoria.Enabled := False;
  actPrototipos.Enabled := False;
  actAsignacion.Enabled := False;
  actPropiedades.Enabled := False;
end;

procedure TfrmEditorAgentes.BarraTotal;
begin
  actGuardar.Enabled := True;
  actGuardarComo.Enabled := True;
  actCerrar.Enabled := True;
  actExportar.Enabled := True;
  actGenetica.Enabled := True;
  actMorfologia.Enabled := True;
  actFisiologia.Enabled := True;
  actEstadios.Enabled := True;
  actMatrices.Enabled := True;
  actMemoria.Enabled := True;
  actPrototipos.Enabled := True;
  actAsignacion.Enabled := True;
  actPropiedades.Enabled := True;
end;

procedure TfrmEditorAgentes.actCerrarExecute(Sender: TObject);
var
  Respuesta : TRespuesta;
begin
  if (Assigned(JuegoAgentes)) and (not Salvado) then
  begin
    Respuesta := PreguntaSNC(ML(mlGrdAgntCr), ML(mlEdEsGl));//¿guardar antes?
    if Respuesta = rSi then
      actGuardar.Execute
    else if Respuesta = rCancelar then
      Exit; //-->
  end;
  FreeAndNil(JuegoAgentes);
  Self.Caption := ML(mlEdAgntGlt);
  BarraNoEditar;
end;

procedure TfrmEditorAgentes.actAbrirExecute(Sender: TObject);
var
  RutaAgentes : string;
  Respuesta   : TRespuesta;
begin
  if not VerificaSalvado then
    Exit; //-->
  RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes) + Diag;
  if DirectoryExists(RutaAgentes) then
    dlgAbrirAgentes.InitialDir := RutaAgentes
  else
  begin
    Respuesta := PreguntaSN(ML(mlDrAgntNE),ML(mlEdAgntGlt));
    if  Respuesta = rSI then        //no existe directorio de entornos ¿crearlo?
    begin
      CreateDir(RutaAgentes);
      dlgAbrirAgentes.InitialDir := RutaAgentes;
    end;
  end;
  if dlgAbrirAgentes.Execute then
  begin
    NombreArchivo := dlgAbrirAgentes.FileName;
    AbreArchivo(NombreArchivo);
  end;
end;

procedure TfrmEditorAgentes.AbreArchivo(PNombreArchivo: string);
begin
  if not VerificaSalvado then
    Exit; //-->
  if not FileExists(PNombreArchivo) then
  begin                                               //no existe el archivo
    Fallo(ML(mlErrArchvNE) + ': ' + PNombreArchivo, ML(mlEdAgntGlt));
    Exit; //-->
  end;
  NombreArchivo := PNombreArchivo;
  GuardaReciente(NombreArchivo);
  Self.Caption := ML(mlEdAgntGlt) + ' [' + NombreArchivo + ']';
  Salvado := True;
  JuegoAgentes := TJuegoAgentes.Create;
  JuegoAgentes.Carga(NombreArchivo);
  BarraTotal;
end;

procedure TfrmEditorAgentes.GuardaReciente(PNombreArchivo: string);
var
  ListaRecientes: array [1..5] of string;
  i, j          : Integer;
begin
  for i := 1 to 5 do
  begin
    ListaRecientes[i] := ArchivoInicio.ReadString('AgentesRecientes',
                          'Reciente' + IntToStr(i), '');
  end;
  for i := 1 to 5 do
    if ListaRecientes[i] = PNombreArchivo then
      ListaRecientes[i] := '';
  for i := 5 downto 2 do
    ListaRecientes[i] := ListaRecientes[i-1];
  ListaRecientes[1] := PNombreArchivo;
  j := 1;
  for i := 1 to 5 do
  begin
    if ListaRecientes[i] <> '' then
    begin
      ArchivoInicio.WriteString('AgentesRecientes', 'Reciente' + IntToStr(j),
                                  ListaRecientes[i]);
      Inc(j);
    end;
  end;
  ActualizaMenuRecientes;
  {$WARNINGS OFF}
  //SHAddToRecentDocs(SHARD_PATH, PChar(NombreArchivo));
  //Agregar archivo a la lista de recientes de Windows
  {$WARNINGS ON}
end;

procedure TfrmEditorAgentes.ActualizaMenuRecientes;
{Obtiene la lista de archivos recientemente abiertos del archivo de incio y
actuaiza el menú de Archivo}
var
  ListaRecientes: array [1..5] of string;
  i             : Integer;
begin
  for i := 1 to 5 do
    ListaRecientes[i] := ArchivoInicio.ReadString('AgentesRecientes',
                              'Reciente' + IntToStr(i), '');
  if ListaRecientes[1] <> '' then
  begin
    R11.Caption := '&1 ' + ListaRecientes[1];
    R11.Visible := True;
    N2.Visible := True;
  end
  else
    Exit; //-->
  if ListaRecientes[2] <> '' then
  begin
    R21.Caption := '&2 ' + ListaRecientes[2];
    R21.Visible := True;
  end
  else
    Exit; //-->
  if ListaRecientes[3] <> '' then
  begin
    R31.Caption := '&3 ' + ListaRecientes[3];
    R31.Visible := True;
  end
  else
    Exit; //-->
  if ListaRecientes[4] <> '' then
  begin
    R41.Caption := '&4 ' + ListaRecientes[4];
    R41.Visible := True;
  end
  else
    Exit; //-->
  if ListaRecientes[5] <> '' then
  begin
    R51.Caption := '&5 ' + ListaRecientes[5];
    R51.Visible := True;
  end;
end;

procedure TfrmEditorAgentes.actGuardarExecute(Sender: TObject);
begin
  if NombreArchivo = ML(mlJgoAgnts) then
    actGuardarComo.Execute
  else
  begin
    JuegoAgentes.Guarda(NombreArchivo);
    Salvado := True;
  end;
end;

procedure TfrmEditorAgentes.actGuardarComoExecute(Sender: TObject);
var
  RutaAgentes : string;
begin
  RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes)+ Diag;
  RutaAgentes :=
      ArchivoInicio.ReadString('Directorios', 'Agentes', RutaAgentes);
  if DirectoryExists(RutaAgentes) then
    dlgGuardarAgentes.InitialDir := RutaAgentes
  else
  begin
    if PreguntaSN(ML(mlDrAgntNE), ML(mlEdAgntGlt)) = rSi then //no existe
      begin                       //directorio de agentes, ¿crearlo?
        CreateDir(RutaAgentes);
        dlgGuardarAgentes.InitialDir := RutaAgentes
      end;
  end;
  dlgGuardarAgentes.FileName := JuegoAgentes.Titulo;
  if dlgGuardarAgentes.Execute then
  begin
    NombreArchivo := dlgGuardarAgentes.FileName;
    if ExtractFileExt(NombreArchivo) <> '.agl' then
      NombreArchivo := NombreArchivo + '.agl';
    Self.Caption := ML(mlEdAgntGlt) + ' [' + NombreArchivo + ']';
    JuegoAgentes.Guarda(NombreArchivo);
    GuardaReciente(NombreArchivo);
    Salvado := True;
    RutaAgentes := ExtractFilePath(dlgGuardarAgentes.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
      ArchivoInicio.WriteString('Directorios', 'Agentes', RutaAgentes);
  end;
end;

procedure TfrmEditorAgentes.R11Click(Sender: TObject);
begin
  NombreArchivo := Copy(R11.Caption, 4, Length(R11.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorAgentes.R21Click(Sender: TObject);
begin
  NombreArchivo := Copy(R21.Caption, 4, Length(R21.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorAgentes.R31Click(Sender: TObject);
begin
  NombreArchivo := Copy(R31.Caption, 4, Length(R31.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorAgentes.R41Click(Sender: TObject);
begin
  NombreArchivo := Copy(R41.Caption, 4, Length(R41.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorAgentes.R51Click(Sender: TObject);
begin
  NombreArchivo := Copy(R51.Caption, 4, Length(R51.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorAgentes.actPropiedadesExecute(Sender: TObject);
begin
  frmPropiedadesJuegoAgentes := TfrmPropiedadesJuegoAgentes.Create(Application);
  with frmPropiedadesJuegoAgentes do
  begin
    edtTitulo.Text := JuegoAgentes.Titulo;
    memComentarios.Text := JuegoAgentes.Comentarios;
    if ShowModal = mrOK then
    begin
      JuegoAgentes.Titulo := edtTitulo.Text;
      JuegoAgentes.Comentarios := memComentarios.Text;
    end;
  end;
  FreeAndNil(frmPropiedadesJuegoAgentes);
end;

procedure TfrmEditorAgentes.actMorfologiaExecute(Sender: TObject);
begin
  frmMorfologia := TfrmMorfologia.Create(Application);
  if frmMorfologia.ShowModal = mrOK then
  begin
    Salvado := False;
    if frmMorfologia.chbInicializar.Checked then
      InicializaPrototipos;           //¿Inicializar prototipos existentes?
  end;
  FreeAndNil(frmMorfologia);
end;

procedure TfrmEditorAgentes.actGeneralesExecute(Sender: TObject);
begin
  frmGeneralesAg := TfrmGeneralesAg.Create(Application);
  frmGeneralesAg.ShowModal;
  FreeAndNil(frmGeneralesAg);
end;

procedure TfrmEditorAgentes.actPrototiposExecute(Sender: TObject);
begin
  frmPrototipos := TfrmPrototipos.Create(Application);
  frmPrototipos.ShowModal;
  FreeAndNil(frmPrototipos);
end;

procedure TfrmEditorAgentes.actMatricesExecute(Sender: TObject);
begin
  frmMatricesInteraccion := TfrmMatricesInteraccion.Create(Application);
  frmMatricesInteraccion.ShowModal;
  FreeAndNil(frmMatricesInteraccion);
end;

procedure TfrmEditorAgentes.actFisiologiaExecute(Sender: TObject);
begin
  frmFisiologia := TfrmFisiologia.Create(Application);
  if frmFisiologia.ShowModal = mrOK then
    Salvado := False;
  FreeAndNil(frmFisiologia);
end;

procedure TfrmEditorAgentes.actEstadiosExecute(Sender: TObject);
begin
  frmEstadios := TfrmEstadios.Create(Application);
  frmEstadios.ShowModal;
  FreeAndNil(frmEstadios);
end;

procedure TfrmEditorAgentes.actAcercaExecute(Sender: TObject);
begin
  frmAcerca := TfrmAcerca.Create(Application);
  frmAcerca.ShowModal;
  FreeAndNil(frmAcerca);
end;

procedure TfrmEditorAgentes.InicializaEstadios(De, Al, Omision: Word;
  Nombres: Boolean);
{Inicaliza los estadios inmaduros en el arreglo de los mismos a partir del
índice De y hasta Al.
Si Nombres es True también se inicializan los nombres, 'Huevo' para el primero,
'Inmaduro' para el segundo}
var
  i      : Integer;
  Estadio: TEstadio;
  OmisionTend: string;
begin
  OmisionTend := ArchivoInicio.ReadString('GeneralesEditorAgentes',
                            'OmisionTendencias', '25,50,25,10,10,1,1,1,1');
  with JuegoAgentes do
  begin
    Estadio.Y_O := True;
    Estadio.Y_OR := True;
    Estadio.Y_OC1C2 := True;
    Estadio.Ciclos := '20';
    Estadio.Condicion1 := '0, =, 0';
    Estadio.Condicion2 := '0, =, 0';
    Estadio.Color := clWhite;
    Estadio.Prototipo := 0;
    for i := 1 to 4 do
    begin
      Estadio.Requiere[i] := '0';
      Estadio.Costos[i] := IntToStr(Omision);
    end;
    for i := 1 to 8 do
      Estadio.Tendencias[i] := ObtenNsimo(OmisionTend, i);
    for i := De to Al do
      Estadios[i] := Estadio;
    if Nombres then
    begin
      Estadio := Estadios[1];
      Estadio.Nombre := ML(mlHuevo);
      Estadios[1] := Estadio;
      Estadio := Estadios[2];
      Estadio.Nombre := ML(mlInmaduro);
      Estadios[2] := Estadio;
    end;
  end;
end;

procedure TfrmEditorAgentes.actMemoriaExecute(Sender: TObject);
begin
  frmMemoriaConducta := TfrmMemoriaConducta.Create(Application);
  if frmMemoriaConducta.ShowModal = mrOK then
    Salvado := False;
  FreeAndNil(frmMemoriaConducta);
end;

procedure TfrmEditorAgentes.CambiaNombreVariable(De, A: string);
{Actualiza todos los campos que puedan contener fórmulas. Sustituye los
nombres de variables de De a A dentro de todas las fórmulas}
var
  i, j, k  : Integer;
  Estadio  : TEstadio;
  Prototipo: TPrototipo;
begin
  with JuegoAgentes do
  begin
    MaxHuevos := Sustituye(De, A, MaxHuevos);
    MaxPaquetes := Sustituye(De, A, MaxPaquetes);
    PaquetesTransferidos := Sustituye(De, A, PaquetesTransferidos);
    HuevosFertilizados := Sustituye(De, A, HuevosFertilizados);
    Paternidad := Sustituye(De, A, Paternidad);
    MaxPaquetesH := Sustituye(De, A, MaxPaquetesH);
    TasaConsumo := Sustituye(De, A, TasaConsumo);
    HuevosCiclo := Sustituye(De, A, HuevosCiclo);
    FraccionHuevo := Sustituye(De, A, FraccionHuevo);
    FraccionPaquete := Sustituye(De, A, FraccionPaquete);
    for j := 1 to NumEstadios do
    begin
      Sustituye(De, A, Estadios[j].Condicion1);
      Sustituye(De, A, Estadios[j].Condicion2);
    end;
    for j := 0 to NumPrototiposM - 1 do
    begin
      CriteriosM[0,j] := Sustituye(De, A, CriteriosM[0,j]);
      CriteriosM[2,j] := Sustituye(De, A, CriteriosM[2,j]);
    end;
    for j := 0 to NumPrototiposH - 1 do
    begin
      CriteriosH[0,j] := Sustituye(De, A, CriteriosH[0,j]);
      CriteriosH[2,j] := Sustituye(De, A, CriteriosH[2,j]);
    end;
    for i := 1 to 15 do
      Continuos[i].Omision := Sustituye(De, A, Continuos[i].Omision);
    for i := 1 to 15 do
      Discretos[i].Omision := Sustituye(De, A, Discretos[i].Omision);
    for i := 1 to 7 do  //Num Sustratos = 7
      Movimiento.Velocidad[i] := Sustituye(De, A, Movimiento.Velocidad[i]);
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Ciclos := Sustituye(De, A, Estadio.Ciclos);
      for j := 1 to 4 do
      begin
        Estadio.Requiere[j]:= Sustituye(De, A, Estadio.Requiere[j]);
        Estadio.Costos[j] := Sustituye(De, A, Estadio.Costos[j]);
      end;
      Estadios[i] := Estadio;
    end;
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Longevidad := Sustituye(De, A, Prototipo.Longevidad);
      Prototipo.RefractarioCombate
                          := Sustituye(De, A, Prototipo.RefractarioCombate);
      Prototipo.RefractarioCortejo
                          := Sustituye(De, A, Prototipo.RefractarioCortejo);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico
            := Sustituye(De, A, Prototipo.Continuos[j].ValorGenetico);
        Prototipo.Continuos[j].ValorAmbiental
            := Sustituye(De, A, Prototipo.Continuos[j].ValorAmbiental);
        Prototipo.Discretos[j].ValorGenetico
            := Sustituye(De, A, Prototipo.Discretos[j].ValorGenetico);
        Prototipo.Discretos[j].ValorAmbiental
            := Sustituye(De, A, Prototipo.Discretos[j].ValorAmbiental);
      end;
      PrototiposM[i] := Prototipo;
    end;
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Longevidad := Sustituye(De, A, Prototipo.Longevidad);
      Prototipo.RefractarioCombate
                          := Sustituye(De, A, Prototipo.RefractarioCombate);
      Prototipo.RefractarioCortejo
                          := Sustituye(De, A, Prototipo.RefractarioCortejo);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico
            := Sustituye(De, A, Prototipo.Continuos[j].ValorGenetico);
        Prototipo.Continuos[j].ValorAmbiental
            := Sustituye(De, A, Prototipo.Continuos[j].ValorAmbiental);
        Prototipo.Discretos[j].ValorGenetico
            := Sustituye(De, A, Prototipo.Discretos[j].ValorGenetico);
        Prototipo.Discretos[j].ValorAmbiental
            := Sustituye(De, A, Prototipo.Discretos[j].ValorAmbiental);
      end;
      PrototiposH[i] := Prototipo;
    end;
    for i := 1 to 4 do
    begin
      CostoHuevo[i] := Sustituye(De, A, CostoHuevo[i]);
      CostoPaquete[i] := Sustituye(De, A, CostoPaquete[i]);
      Alimentacion.Ganancias[i]
                             := Sustituye(De, A, Alimentacion.Ganancias[i]);
    end;
    for j := 1 to 2 do
      for i := 1 to 4 do
        Movimiento.Costos[i,j] := Sustituye(De, A, Movimiento.Costos[i,j]);
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j]
                              := Sustituye(De, A, Alimentacion.Costos[i,j]);
    for j := 1 to 3 do
      for i := 1 to 4 do
        CostosCombate[i,j] := Sustituye(De, A, CostosCombate[i,j]);
    for j := 1 to 5 do
      for i := 1 to 4 do
        CostosCortejo[i,j] := Sustituye(De, A, CostosCortejo[i,j]);
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratos.Celda[i,j]
                           := Sustituye(De, A, MatrizSustratos.Celda[i,j]);
        MatrizSustratosA.Celda[i,j]
                           := Sustituye(De, A, MatrizSustratosA.Celda[i,j]);
        MatrizSustratosM.Celda[i,j]
                           := Sustituye(De, A, MatrizSustratosM.Celda[i,j]);
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicos.Celda[i,j]
                           := Sustituye(De, A, MatrizDinamicos.Celda[i,j]);
        MatrizDinamicosA.Celda[i,j]
                           := Sustituye(De, A, MatrizDinamicosA.Celda[i,j]);
        MatrizDinamicosM.Celda[i,j]
                           := Sustituye(De, A, MatrizDinamicosM.Celda[i,j]);
      end;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentes.Celda[i,j]
                             := Sustituye(De, A, MatrizAgentes.Celda[i,j]);
        MatrizAgentesA.Celda[i,j]
                             := Sustituye(De, A, MatrizAgentesA.Celda[i,j]);
        MatrizAgentesM.Celda[i,j]
                             := Sustituye(De, A, MatrizAgentesM.Celda[i,j]);
      end;
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j]
                           := Sustituye(De, A, MatrizConductasM.Celda[i,j]);
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
          Prototipo.Combate[i,j] := Sustituye(De, A, Prototipo.Combate[i,j]);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
          Prototipo.Cortejo[i,j]:= Sustituye(De, A, Prototipo.Cortejo[i,j]);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
          Prototipo.Combate[i,j]:= Sustituye(De, A, Prototipo.Combate[i,j]);
      PrototiposH[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
          Prototipo.Cortejo[i,j] :=Sustituye(De, A, Prototipo.Cortejo[i,j]);
      PrototiposH[k] := Prototipo;
    end;
    for j := 1 to 4 do
      for i := 1 to 5 do
        Metabolismo[i,j] := Sustituye(De, A, Metabolismo[i,j]);
  end; //with
end;

procedure TfrmEditorAgentes.actGeneticaExecute(Sender: TObject);
begin
  frmGenetica := TfrmGenetica.Create(Application);
  frmGenetica.ShowModal;
  FreeAndNil(frmGenetica);
end;

procedure TfrmEditorAgentes.actAsignacionExecute(Sender: TObject);
begin
  frmAsignacion := TfrmAsignacion.Create(Application);
  frmAsignacion.ShowModal;
  FreeAndNil(frmAsignacion);
end;

procedure TfrmEditorAgentes.CambiaNombreVariablePrefijos(De, A: string);
{Actualiza todos los campos que puedan contener fórmulas. Sustituye los
nombres de variables de De a A dentro de todas las fórmulas. Tambien sustituye
las variables cuyo nombre incluya los sufijos en Prefijos}
var
  i, j, k  : Integer;
  Estadio  : TEstadio;
  Prototipo: TPrototipo;
  Prefijos : array [1..4] of string;
begin
  Prefijos[1] := 'MemoryLastInt';
  Prefijos[2] := 'MemoryNumInt';
  Prefijos[3] := 'MemoryLastPer';
  Prefijos[4] := 'MemoryNumPer';
  with JuegoAgentes do
  begin
    MaxHuevos := SustituyeConPrefijos(De, A, MaxHuevos, Prefijos);
    MaxPaquetes := SustituyeConPrefijos(De, A, MaxPaquetes, Prefijos);
    PaquetesTransferidos := SustituyeConPrefijos(De, A, PaquetesTransferidos,
                                                                      Prefijos);
    HuevosFertilizados := SustituyeConPrefijos(De, A, HuevosFertilizados,
                                                                       Prefijos);
    Paternidad := SustituyeConPrefijos(De, A, Paternidad, Prefijos);
    MaxPaquetesH := SustituyeConPrefijos(De, A, MaxPaquetesH, Prefijos);
    TasaConsumo := SustituyeConPrefijos(De, A, TasaConsumo, Prefijos);
    HuevosCiclo := SustituyeConPrefijos(De, A, HuevosCiclo, Prefijos);
    FraccionHuevo := SustituyeConPrefijos(De, A, FraccionHuevo, Prefijos);
    FraccionPaquete := SustituyeConPrefijos(De, A, FraccionPaquete, Prefijos);
    for j := 0 to NumPrototiposM - 1 do
    begin
      CriteriosM[0,j] := SustituyeConPrefijos(De, A, CriteriosM[0,j], Prefijos);
      CriteriosM[2,j] := SustituyeConPrefijos(De, A, CriteriosM[2,j], Prefijos);
    end;
    for j := 0 to NumPrototiposH - 1 do
    begin
      CriteriosH[0,j] := SustituyeConPrefijos(De, A, CriteriosH[0,j], Prefijos);
      CriteriosH[2,j] := SustituyeConPrefijos(De, A, CriteriosH[2,j], Prefijos);
    end;
    for i := 1 to 15 do
      Continuos[i].Omision := SustituyeConPrefijos(De, A, Continuos[i].Omision,
                                                                      Prefijos);
    for i := 1 to 15 do
      Discretos[i].Omision := SustituyeConPrefijos(De, A, Discretos[i].Omision,
                                                                      Prefijos);
    for i := 1 to 7 do  //Num Sustratos = 7
      Movimiento.Velocidad[i] :=
                            SustituyeConPrefijos(De, A, Movimiento.Velocidad[i],
                                                                      Prefijos);
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Ciclos := SustituyeConPrefijos(De, A, Estadio.Ciclos, Prefijos);
      for j := 1 to 4 do
      begin
        Estadio.Requiere[j]:= SustituyeConPrefijos(De, A, Estadio.Requiere[j],
                                                                      Prefijos);
        Estadio.Costos[j] := SustituyeConPrefijos(De, A, Estadio.Costos[j],
                                                                      Prefijos);
      end;
      Estadios[i] := Estadio;
    end;
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Longevidad := SustituyeConPrefijos(De, A, Prototipo.Longevidad,
                                                                      Prefijos);
      Prototipo.RefractarioCombate
                    := SustituyeConPrefijos(De, A, Prototipo.RefractarioCombate,
                                                                      Prefijos);
      Prototipo.RefractarioCortejo
                    := SustituyeConPrefijos(De, A, Prototipo.RefractarioCortejo,
                                                                      Prefijos);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico :=
            SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Prefijos);
        Prototipo.Continuos[j].ValorAmbiental :=
            SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorAmbiental, Prefijos);
        Prototipo.Discretos[j].ValorGenetico :=
            SustituyeConPrefijos
            (De, A, Prototipo.Discretos[j].ValorGenetico, Prefijos);
        Prototipo.Discretos[j].ValorAmbiental :=
            SustituyeConPrefijos
            (De, A, Prototipo.Discretos[j].ValorAmbiental, Prefijos);
      end;
      PrototiposM[i] := Prototipo;
    end;
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Longevidad := SustituyeConPrefijos(De, A, Prototipo.Longevidad,
                                                                      Prefijos);
      Prototipo.RefractarioCombate
                    := SustituyeConPrefijos(De, A, Prototipo.RefractarioCombate,
                                                                      Prefijos);
      Prototipo.RefractarioCortejo
                    := SustituyeConPrefijos(De, A, Prototipo.RefractarioCortejo,
                                                                      Prefijos);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico := SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Prefijos);
        Prototipo.Continuos[j].ValorAmbiental := SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Prefijos);
        Prototipo.Discretos[j].ValorGenetico := SustituyeConPrefijos
            (De, A, Prototipo.Discretos[j].ValorGenetico, Prefijos);
        Prototipo.Discretos[j].ValorAmbiental := SustituyeConPrefijos
            (De, A, Prototipo.Discretos[j].ValorAmbiental, Prefijos);
      end;
      PrototiposH[i] := Prototipo;
    end;
    for i := 1 to 4 do
    begin
      CostoHuevo[i] := SustituyeConPrefijos(De, A, CostoHuevo[i], Prefijos);
      CostoPaquete[i] := SustituyeConPrefijos(De, A, CostoPaquete[i], Prefijos);
      Alimentacion.Ganancias[i]
                       := SustituyeConPrefijos(De, A, Alimentacion.Ganancias[i],
                                                                      Prefijos);
    end;
    for j := 1 to 2 do
      for i := 1 to 4 do
   Movimiento.Costos[i,j] := SustituyeConPrefijos(De, A, Movimiento.Costos[i,j],
                                                                      Prefijos);
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j]
                        := SustituyeConPrefijos(De, A, Alimentacion.Costos[i,j],
                                                                      Prefijos);
    for j := 1 to 3 do
      for i := 1 to 4 do
        CostosCombate[i,j] := SustituyeConPrefijos(De, A, CostosCombate[i,j],
                                                                      Prefijos);
    for j := 1 to 5 do
      for i := 1 to 4 do
        CostosCortejo[i,j] := SustituyeConPrefijos(De, A, CostosCortejo[i,j],
                                                                      Prefijos);
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratos.Celda[i,j]
                      := SustituyeConPrefijos(De, A, MatrizSustratos.Celda[i,j],
                                                                      Prefijos);
        MatrizSustratosA.Celda[i,j]
                     := SustituyeConPrefijos(De, A, MatrizSustratosA.Celda[i,j],
                                                                      Prefijos);
        MatrizSustratosM.Celda[i,j]
                     := SustituyeConPrefijos(De, A, MatrizSustratosM.Celda[i,j],
                                                                      Prefijos);
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicos.Celda[i,j]
                      := SustituyeConPrefijos(De, A, MatrizDinamicos.Celda[i,j],
                                                                      Prefijos);
        MatrizDinamicosA.Celda[i,j]
                     := SustituyeConPrefijos(De, A, MatrizDinamicosA.Celda[i,j],
                                                                    Prefijos);
        MatrizDinamicosM.Celda[i,j]
                     := SustituyeConPrefijos(De, A, MatrizDinamicosM.Celda[i,j],
                                                                    Prefijos);
      end;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentes.Celda[i,j]
                        := SustituyeConPrefijos(De, A, MatrizAgentes.Celda[i,j],
                                                                        Prefijos);
        MatrizAgentesA.Celda[i,j]
                       := SustituyeConPrefijos(De, A, MatrizAgentesA.Celda[i,j],
                                                                      Prefijos);
        MatrizAgentesM.Celda[i,j]
                       := SustituyeConPrefijos(De, A, MatrizAgentesM.Celda[i,j],
                                                                      Prefijos);
      end;
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j]
                     := SustituyeConPrefijos(De, A, MatrizConductasM.Celda[i,j],
                                                                    Prefijos);
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
   Prototipo.Combate[i,j] := SustituyeConPrefijos(De, A, Prototipo.Combate[i,j],
                                                  Prefijos);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
    Prototipo.Cortejo[i,j]:= SustituyeConPrefijos(De, A, Prototipo.Cortejo[i,j],
                                                    Prefijos);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
    Prototipo.Combate[i,j]:= SustituyeConPrefijos(De, A, Prototipo.Combate[i,j],
                                                    Prefijos);
      PrototiposH[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
    Prototipo.Cortejo[i,j] :=SustituyeConPrefijos(De, A, Prototipo.Cortejo[i,j],
                                                    Prefijos);
      PrototiposH[k] := Prototipo;
    end;
    for j := 1 to 4 do
      for i := 1 to 5 do
        Metabolismo[i,j] := SustituyeConPrefijos(De, A, Metabolismo[i,j],
                                                        Prefijos);
  end; //with
end;

procedure TfrmEditorAgentes.CambiaNombreVariableSufijos(De, A: string);
{Actualiza todos los campos que puedan contener fórmulas. Sustituye los
nombres de variables de De a A dentro de todas las fórmulas. Tambien sustituye
las variables cuyo nombre incluya los sufijos en Prefijos}
var
  i, j, k  : Integer;
  Estadio  : TEstadio;
  Prototipo: TPrototipo;
  Sufijos  : array [1..1] of string;
begin
  Sufijos[1] := 'Contender';
  with JuegoAgentes do
  begin
    MaxHuevos := SustituyeConSufijos(De, A, MaxHuevos, Sufijos);
    MaxPaquetes := SustituyeConSufijos(De, A, MaxPaquetes, Sufijos);
    PaquetesTransferidos := SustituyeConSufijos(De, A, PaquetesTransferidos,
                                                    Sufijos);
    HuevosFertilizados := SustituyeConSufijos(De, A, HuevosFertilizados,
                                                    Sufijos);
    Paternidad := SustituyeConSufijos(De, A, Paternidad, Sufijos);
    MaxPaquetesH := SustituyeConSufijos(De, A, MaxPaquetesH, Sufijos);
    TasaConsumo := SustituyeConSufijos(De, A, TasaConsumo, Sufijos);
    HuevosCiclo := SustituyeConSufijos(De, A, HuevosCiclo, Sufijos);
    FraccionHuevo := SustituyeConSufijos(De, A, FraccionHuevo, Sufijos);
    FraccionPaquete := SustituyeConSufijos(De, A, FraccionPaquete, Sufijos);
    for j := 0 to NumPrototiposM - 1 do
    begin
      CriteriosM[0,j] := SustituyeConSufijos(De, A, CriteriosM[0,j], Sufijos);
      CriteriosM[2,j] := SustituyeConSufijos(De, A, CriteriosM[2,j], Sufijos);
    end;
    for j := 0 to NumPrototiposH - 1 do
    begin
      CriteriosH[0,j] := SustituyeConSufijos(De, A, CriteriosH[0,j], Sufijos);
      CriteriosH[2,j] := SustituyeConSufijos(De, A, CriteriosH[2,j], Sufijos);
    end;
    for i := 1 to 15 do
      Continuos[i].Omision := SustituyeConSufijos(De, A, Continuos[i].Omision,
                                                      Sufijos);
    for i := 1 to 15 do
      Discretos[i].Omision := SustituyeConSufijos(De, A, Discretos[i].Omision,
                                                      Sufijos);
    for i := 1 to 7 do  //Num Sustratos = 7
      Movimiento.Velocidad[i] :=
                            SustituyeConSufijos(De, A, Movimiento.Velocidad[i],
                                                                       Sufijos);
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Ciclos := SustituyeConSufijos(De, A, Estadio.Ciclos, Sufijos);
      for j := 1 to 4 do
      begin
        Estadio.Requiere[j]:= SustituyeConSufijos(De, A, Estadio.Requiere[j],
                                                        Sufijos);
        Estadio.Costos[j] := SustituyeConSufijos(De, A, Estadio.Costos[j],
                                                        Sufijos);
      end;
      Estadios[i] := Estadio;
    end;
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Longevidad := SustituyeConSufijos(De, A, Prototipo.Longevidad,
                                                      Sufijos);
      Prototipo.RefractarioCombate
                    := SustituyeConSufijos(De, A, Prototipo.RefractarioCombate,
                                                                    Sufijos);
      Prototipo.RefractarioCortejo
                    := SustituyeConSufijos(De, A, Prototipo.RefractarioCortejo,
                                                                    Sufijos);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico := SustituyeConSufijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Sufijos);
        Prototipo.Continuos[j].ValorAmbiental := SustituyeConSufijos
            (De, A, Prototipo.Continuos[j].ValorAmbiental, Sufijos);
        Prototipo.Discretos[j].ValorGenetico := SustituyeConSufijos
            (De, A, Prototipo.Discretos[j].ValorGenetico, Sufijos);
        Prototipo.Discretos[j].ValorAmbiental := SustituyeConSufijos
            (De, A, Prototipo.Discretos[j].ValorAmbiental, Sufijos);
      end;
      PrototiposM[i] := Prototipo;
    end;
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Longevidad := SustituyeConSufijos(De, A, Prototipo.Longevidad,
                                                      Sufijos);
      Prototipo.RefractarioCombate
                    := SustituyeConSufijos(De, A, Prototipo.RefractarioCombate,
                                                                    Sufijos);
      Prototipo.RefractarioCortejo
                    := SustituyeConSufijos(De, A, Prototipo.RefractarioCortejo,
                                                                    Sufijos);
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico := SustituyeConSufijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Sufijos);
        Prototipo.Continuos[j].ValorAmbiental := SustituyeConSufijos
            (De, A, Prototipo.Continuos[j].ValorAmbiental, Sufijos);
        Prototipo.Discretos[j].ValorGenetico := SustituyeConSufijos
            (De, A, Prototipo.Discretos[j].ValorGenetico, Sufijos);
        Prototipo.Discretos[j].ValorAmbiental := SustituyeConSufijos
            (De, A, Prototipo.Discretos[j].ValorAmbiental, Sufijos);
      end;
      PrototiposH[i] := Prototipo;
    end;
    for i := 1 to 4 do
    begin
      CostoHuevo[i] := SustituyeConSufijos(De, A, CostoHuevo[i], Sufijos);
      CostoPaquete[i] := SustituyeConSufijos(De, A, CostoPaquete[i], Sufijos);
      Alimentacion.Ganancias[i]
                       := SustituyeConSufijos(De, A, Alimentacion.Ganancias[i],
                                                                      Sufijos);
    end;
    for j := 1 to 2 do
      for i := 1 to 4 do
   Movimiento.Costos[i,j] := SustituyeConSufijos(De, A, Movimiento.Costos[i,j],
                                                  Sufijos);
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j]
                        := SustituyeConSufijos(De, A, Alimentacion.Costos[i,j],
                                                                       Sufijos);
    for j := 1 to 3 do
      for i := 1 to 4 do
        CostosCombate[i,j] := SustituyeConSufijos(De, A, CostosCombate[i,j],
                                                                       Sufijos);
    for j := 1 to 5 do
      for i := 1 to 4 do
        CostosCortejo[i,j] := SustituyeConSufijos(De, A, CostosCortejo[i,j],
                                                                       Sufijos);
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratos.Celda[i,j]
                      := SustituyeConSufijos(De, A, MatrizSustratos.Celda[i,j],
                                                                      Sufijos);
        MatrizSustratosA.Celda[i,j]
                     := SustituyeConSufijos(De, A, MatrizSustratosA.Celda[i,j],
                                                                    Sufijos);
        MatrizSustratosM.Celda[i,j]
                     := SustituyeConSufijos(De, A, MatrizSustratosM.Celda[i,j],
                                                                    Sufijos);
      end;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicos.Celda[i,j]
                      := SustituyeConSufijos(De, A, MatrizDinamicos.Celda[i,j],
                                                                      Sufijos);
        MatrizDinamicosA.Celda[i,j]
                     := SustituyeConSufijos(De, A, MatrizDinamicosA.Celda[i,j],
                                                                    Sufijos);
        MatrizDinamicosM.Celda[i,j]
                     := SustituyeConSufijos(De, A, MatrizDinamicosM.Celda[i,j],
                                                                    Sufijos);
      end;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentes.Celda[i,j]
                        := SustituyeConSufijos(De, A, MatrizAgentes.Celda[i,j],
                                                                       Sufijos);
        MatrizAgentesA.Celda[i,j]
                       := SustituyeConSufijos(De, A, MatrizAgentesA.Celda[i,j],
                                                                      Sufijos);
        MatrizAgentesM.Celda[i,j]
                       := SustituyeConSufijos(De, A, MatrizAgentesM.Celda[i,j],
                                                                      Sufijos);
      end;
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j]
                     := SustituyeConSufijos(De, A, MatrizConductasM.Celda[i,j],
                                                                    Sufijos);
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
   Prototipo.Combate[i,j] := SustituyeConSufijos(De, A, Prototipo.Combate[i,j],
                                                  Sufijos);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
    Prototipo.Cortejo[i,j]:= SustituyeConSufijos(De, A, Prototipo.Cortejo[i,j],
                                                    Sufijos);
      PrototiposM[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 3 do
        for i := 1 to 3 do
    Prototipo.Combate[i,j]:= SustituyeConSufijos(De, A, Prototipo.Combate[i,j],
                                                    Sufijos);
      PrototiposH[k] := Prototipo;
    end;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 4 do
        for i := 1 to 4 do
    Prototipo.Cortejo[i,j] :=SustituyeConSufijos(De, A, Prototipo.Cortejo[i,j],
                                                    Sufijos);
      PrototiposH[k] := Prototipo;
    end;
    for j := 1 to 4 do
      for i := 1 to 5 do
        Metabolismo[i,j] := SustituyeConSufijos(De, A, Metabolismo[i,j], Sufijos);
  end; //with
end;

procedure TfrmEditorAgentes.actExportarExecute(Sender: TObject);
begin
  frmExportar := TfrmExportar.Create(Application);
  frmExportar.ShowModal;
  FreeAndNil(frmExportar);
end;

initialization
  {$i EditorAgentes.lrs}
  {$i EditorAgentes.lrs}

end.
