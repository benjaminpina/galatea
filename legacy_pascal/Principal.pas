unit Principal;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, ComCtrls, Comunes, Dialogos,
  IniFiles,Proyectos, StdCtrls,
  ExtCtrls, Buttons, ArchivosSalida, Agentes, LResources, Process;

type
  TTemporizadores = record
    Autoguardado,
    Informar,
    Detener: Boolean;
    IntervaloAutoGuardado,
    IntervaloInformar,
    IntervaloSalida,
    Detencion: Integer;
  end;

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    ActionList1: TActionList;
    actNuevo: TAction;
    actAbrir: TAction;
    actGuardar: TAction;
    actGuardarComo: TAction;
    actCerrar: TAction;
    actSalir: TAction;
    actIniciar: TAction;
    actPausa: TAction;
    actPaso: TAction;
    actDetener: TAction;
    actEditor: TAction;
    actAgentes: TAction;
    actOpcionesProyecto: TAction;
    actGenerales: TAction;
    actAyuda: TAction;
    MainMenu1: TMainMenu;
    memInfo: TMemo;
    Proyecto1: TMenuItem;
    Nuevo1: TMenuItem;
    Abrirproyecto1: TMenuItem;
    GuardarProyecto1: TMenuItem;
    GuardarProyectocomo1: TMenuItem;
    CerrarProyecto1: TMenuItem;
    N1: TMenuItem;
    R1: TMenuItem;
    R21: TMenuItem;
    R31: TMenuItem;
    R41: TMenuItem;
    R51: TMenuItem;
    N2: TMenuItem;
    Salir1: TMenuItem;
    Ejecucin1: TMenuItem;
    Iniciar1: TMenuItem;
    Pausa1: TMenuItem;
    Pasosiguiente1: TMenuItem;
    Detener1: TMenuItem;
    Opciones1: TMenuItem;
    DelProyecto1: TMenuItem;
    Generales1: TMenuItem;
    Ayuda1: TMenuItem;
    Contenido1: TMenuItem;
    AcercadeGalatea1: TMenuItem;
    actAcerca: TAction;
    Herramientas1: TMenuItem;
    EditordeEscenarios1: TMenuItem;
    StatusBar1: TStatusBar;
    //ApplicationEvents1: TApplicationEvents;
    dlgAbreProyecto: TOpenDialog;
    dlgGuardarProyecto: TSaveDialog;
    N3: TMenuItem;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    tlbInicio: TToolButton;
    tlbPausa: TToolButton;
    tlbPaso: TToolButton;
    tlbAlto: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton13: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    actSustratos: TAction;
    ToolButton1: TToolButton;
    SubstratumEditor1: TMenuItem;
    ToolButton14: TToolButton;
    ToolButton5: TToolButton;
    actEntornos: TAction;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    EnvironmentEditor1: TMenuItem;
    Agentstypes1: TMenuItem;
    //XPManifest1: TXPManifest;
    ToolButton8: TToolButton;
    updRetardo: TUpDown;
    edtRetardo: TEdit;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    cmbEscala: TComboBox;
    ToolButton21: TToolButton;
    actDecZoom: TAction;
    actIncZoom: TAction;
    View1: TMenuItem;
    Zoomin1: TMenuItem;
    Zoomout1: TMenuItem;
    ToolButton23: TToolButton;
    tlbVisualizar: TToolButton;
    actNoDesplegar: TAction;
    ptbEntorno: TPaintBox;
    scbHorizontal: TScrollBar;
    scbVertical: TScrollBar;
    pnlStatus: TPanel;
    //redInformacion: TRichEdit;
    N4: TMenuItem;
    Exporttoenvironmentfile1: TMenuItem;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    dlgGuardarEntorno: TSaveDialog;
    btnInformar: TBitBtn;
    actAnalizador: TAction;
    actExpEntorno: TAction;
    Outputfilesanalizer1: TMenuItem;
    N5: TMenuItem;
    Exporttoenvironmentfile2: TMenuItem;
    actInformar: TAction;
    procedure actSalirExecute(Sender: TObject);
    procedure actEditorExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure actGuardarComoExecute(Sender: TObject);
    procedure actGuardarExecute(Sender: TObject);
    procedure actCerrarExecute(Sender: TObject);
    procedure actSustratosExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actIniciarExecute(Sender: TObject);
    procedure actDetenerExecute(Sender: TObject);
    procedure actNuevoExecute(Sender: TObject);
    procedure actPausaExecute(Sender: TObject);
    procedure actAgentesExecute(Sender: TObject);
    procedure actEntornosExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure R1Click(Sender: TObject);
    procedure R21Click(Sender: TObject);
    procedure R31Click(Sender: TObject);
    procedure R41Click(Sender: TObject);
    procedure R51Click(Sender: TObject);
    procedure actPasoExecute(Sender: TObject);
    procedure edtRetardoKeyPress(Sender: TObject; var Key: Char);
    procedure edtRetardoChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actDecZoomExecute(Sender: TObject);
    procedure actIncZoomExecute(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure scbVerticalChange(Sender: TObject);
    procedure scbHorizontalChange(Sender: TObject);
    procedure cmbEscalaChange(Sender: TObject);
    procedure actNoDesplegarExecute(Sender: TObject);
    procedure actInformarExecute(Sender: TObject);
    procedure actOpcionesProyectoExecute(Sender: TObject);
    procedure actExpEntornoExecute(Sender: TObject);
    procedure actGeneralesExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actAnalizadorExecute(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
  private
    { Private declarations }
    Proyecto: TProyecto;
    Salvado: Boolean;
    NombreArchivo: string;
    Ejecutable: TProcess;
    Traslapados: array of array of Boolean;
    Inicio,
    Fin: TDateTime; //Fechas y horas de incio y fin de ejecución
    Salida: TSalida;
    function VerificaSalvado:Boolean;
    procedure BarraSoloNuevo;
    procedure BarraTotal;
    procedure BarraEjecucion;
    procedure BarraPausa;
    procedure GuardaReciente(PNombreArchivo: string);
    procedure ActualizaMenuRecientes;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure AjustaTamano;
    procedure MarcaTraslapados;
    procedure InformaEstado;
    procedure LimpiaInformacion;
    procedure DespliegaValorDe(Variable: string; Valor: Integer;
        PColor: TColor); overload;
    procedure DespliegaValorDe(Variable, Valor: string;
        PColor: TColor); overload;
    procedure Ciclo(Sender: TObject; Ciclo: Integer; Info: TStringList);
    procedure NuevoAgente(Sender: TObject; Agente: TAgente);
    procedure NuevoHuevo(Sender: TObject; Huevo: THuevo);
    procedure NuevoAdulto(Sender: TObject; Agente: TAgente);
    procedure CreaArchivosDeSalida;
    procedure EnviaInfoCiclo(Info: TStringList);
    procedure DibujaEscnr(Sender: TObject);
    procedure DibujaED(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
    procedure DibujaAgnt(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
  public
    { Public declarations }
    Temporizadores: TTemporizadores;
    ArchivoInicio: TIniFile;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  Multilenguaje, NuevoProyecto, OpcionesProyecto, Escenarios, Elementos,
  Entornos, Mediadores, DateUtils, Generales, Dibujo;


function TfrmPrincipal.VerificaSalvado: Boolean;
{Verifica si el archivo ha sido guardado desde la última modificación, si el
archivo no ha sido guardado pregunta al usuario si desea guardarlo.
Regresa False si el usuario cancela la acción de cerrar archivo}
var
  Respuesta: TRespuesta;
begin
  Result := True;
  if Assigned(Proyecto) then
  begin
    if not Salvado then
    begin
      Respuesta := PreguntaSNC(ML(mlGrdProyCr), 'Galatea');//¿guardar antes?
      case Respuesta of
        rSi       : actGuardar.Execute;
        rNo       : Salvado := True;
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

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  EstadoVentana,
  Idioma: string;
begin
  {Candado de seguridad
  if not Llave('galatea', '') then
  begin
    Fallo('Ilegal copy / copia ilegal', 'Galatea');
    Halt; //--->
  end;
  Candado de seguridad}
  Plataforma := ptbEntorno.Canvas;
  BarraSoloNuevo;
  Salvado := True;
  NombreArchivo := ML(mlProyecto);
  ArchivoInicio := TIniFile.Create('.galatea.ini');
  with ArchivoInicio do
  begin
    Idioma := ReadString('General', 'Idioma', 'English');
    if Idioma = 'English' then
      Lenguaje := lEnglish
    else if Idioma = 'Spanish' then
      Lenguaje  := lEspanol;
    Temporizadores.Autoguardado := ReadBool('General', 'Autoguardado', False);
    Temporizadores.Informar := ReadBool('General', 'Informar', False);
    Temporizadores.Detener := ReadBool('General', 'Detener', False); 
    Temporizadores.IntervaloAutoGuardado :=
        ReadInteger('General', 'IntervaloAutoguardado', 100);
    Temporizadores.IntervaloInformar :=
        ReadInteger('General', 'IntervaloInformar', 100);
    Temporizadores.Detencion :=
        ReadInteger('General', 'Detencion', 1000);
    Temporizadores.IntervaloSalida :=
        ReadInteger('General', 'IntervaloSalida', 100);
    EstadoVentana := ReadString('Ventanas', 'Galatea', 'Normal');
  end;
  if EstadoVentana = 'Maximizada' then
    WindowState := wsMaximized
  else
    WindowState := wsNormal;
  ActualizaMenuRecientes;
  if ParamCount <> 0 then
  begin
    NombreArchivo := ParamStr(1);
    if ExtractFileExt(NombreArchivo) = '.pgl' then
      AbreArchivo(NombreArchivo)
    else            //Extensión de archivo no corresponde
      Fallo(ML(mlErrExtNCGL), 'Galatea');
  end;
  Ejecutable := TProcess.Create(nil);
  LimpiaInformacion;
  Randomize;
end;

procedure TfrmPrincipal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := VerificaSalvado;
end;

procedure TfrmPrincipal.actSalirExecute(Sender: TObject);
begin
  Self.Close;
  //Application.Terminate
end;

procedure TfrmPrincipal.actEditorExecute(Sender: TObject);
var
  RutaEditor: string;
begin
  {$IFDEF LINUX}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdEsGlt';
  {$ENDIF}
  {$IFDEF WIN32}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdEsGlt.exe';
  {$ENDIF}
  Ejecutable.CommandLine := RutaEditor;
  if FileExists(RutaEditor) then
    Ejecutable.Execute
  else
    Fallo(ML(mlErrFltEdEs), 'Galatea');//Falta editor de escenarios
end;

procedure TfrmPrincipal.actSustratosExecute(Sender: TObject);
var
  RutaEditor: string;
begin
  {$IFDEF LINUX}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdSustGlt';
  {$ENDIF}
  {$IFDEF WIN32}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdSustGlt.exe';
  {$ENDIF}
  Ejecutable.CommandLine := RutaEditor;
  if FileExists(RutaEditor) then
  	Ejecutable.Execute
  else
    Fallo(ML(mlErrFltEdSu), 'Galatea');//Falta editor de sustratos
end;

procedure TfrmPrincipal.actAgentesExecute(Sender: TObject);
var
  RutaEditor: string;
begin
  {$IFDEF LINUX}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdAgnGlt';
  {$ENDIF}
  {$IFDEF WIN32}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdAgnGlt.exe';
  {$ENDIF}
  Ejecutable.CommandLine := RutaEditor;
  if FileExists(RutaEditor) then
    Ejecutable.Execute
  else
    Fallo(ML(mlErrFltEdAg), 'Galatea');//Falta editor de agentes
end;

procedure TfrmPrincipal.actEntornosExecute(Sender: TObject);
var
  RutaEditor: string;
begin
  {$IFDEF LINUX}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdEntGlt';
  {$ENDIF}
  {$IFDEF WIN32}
  RutaEditor := ExtractFilePath(Application.ExeName) + 'EdEntGlt.exe';
  {$ENDIF}
  Ejecutable.CommandLine := RutaEditor;
  if FileExists(RutaEditor) then
    Ejecutable.Execute
  else
    Fallo(ML(mlErrFltEdEn), 'Galatea');//Falta editor de entornos
end;

procedure TfrmPrincipal.AbreArchivo(PNombreArchivo: string);
begin
  if not VerificaSalvado then
    Exit; //-->
  if not FileExists(PNombreArchivo) then
  begin                                               //no existe el archivo
    Fallo(ML(mlErrArchvNE) + ': ' + PNombreArchivo, 'Galatea');
    Exit; //-->
  end;
  if not VerificaSalvado then
    Exit; //-->
  NombreArchivo := PNombreArchivo;
  GuardaReciente(NombreArchivo);
  Self.Caption := 'Galatea [' + NombreArchivo + ']';
  cmbEscala.ItemIndex := 4;
  edtRetardo.Text := '0';
  Salvado := True;
  Proyecto := TProyecto.Create;//(ptbEntorno);
  Proyecto.Carga(NombreArchivo);
  if FileExists(Proyecto.ArchivoEntorno) then
  begin
    Proyecto.Entorno.OnDibujaEscenario := DibujaEscnr;
    Proyecto.Entorno.OnDibujaDinamico := DibujaED;
    Proyecto.Entorno.OnDibujaAgente := DibujaAgnt;
    Proyecto.Entorno.Carga(Proyecto.ArchivoEntorno);
    Proyecto.Entorno.Cuadricula := False;
    Proyecto.OnCiclo := Ciclo;
    Proyecto.OnNuevoAgente := NuevoAgente;
    Proyecto.OnNuevoHuevo := NuevoHuevo;
    Proyecto.OnNuevoAdulto := NuevoAdulto;
    SetLength(Traslapados, Proyecto.Entorno.Anchura, Proyecto.Entorno.Altura);
    AjustaTamano;
    BarraTotal;
  end
  else
  begin
    Fallo(ML(mlFltArchEntrn), 'Galatea');
    actCerrarExecute(Application);
  end;
  InformaEstado;
end;

procedure TfrmPrincipal.actAbrirExecute(Sender: TObject);
var
  RutaEntornos: string;
begin
  if not VerificaSalvado then
    Exit; //-->
  RutaEntornos := ExtractFilePath(Application.ExeName) + ML(mlEntornos) + Diag;
  if DirectoryExists(RutaEntornos) then
    dlgAbreProyecto.InitialDir := RutaEntornos
  else
  begin
    if PreguntaSN(ML(mlDrEntNE), 'Galatea') = rSi then
      begin
        CreateDir(RutaEntornos);
        dlgAbreProyecto.InitialDir := RutaEntornos;
      end;
  end;
  if dlgAbreProyecto.Execute then
  begin
    NombreArchivo := dlgAbreProyecto.FileName;
    AbreArchivo(NombreArchivo);
  end;
end;

procedure TfrmPrincipal.actGuardarComoExecute(Sender: TObject);
var
  RutaProyectos: string;
begin
  {$IFDEF MSWINDOWS}
  RutaProyectos := ExtractFilePath(Application.ExeName) + ML(mlProyectos) + '\';
  {$ENDIF}
  {$IFDEF LINUX}
  RutaProyectos := ExtractFilePath(Application.ExeName) + ML(mlProyectos) + '/';
  {$ENDIF}
  RutaProyectos :=
    ArchivoInicio.ReadString('Directorios', 'Proyectos', RutaProyectos);
  if DirectoryExists(RutaProyectos) then
    dlgGuardarProyecto.InitialDir := RutaProyectos
  else
  begin
    if PreguntaSN(ML(mlDrProyNe), 'Galatea') = rSi then
      begin
        CreateDir(RutaProyectos);
        dlgGuardarProyecto.InitialDir := RutaProyectos;
      end;
  end;
  dlgGuardarProyecto.FileName := Proyecto.Titulo;
  if dlgGuardarProyecto.Execute then
  begin
    NombreArchivo := dlgGuardarProyecto.FileName;
    if ExtractFileExt(NombreArchivo) <> '.pgl' then
      NombreArchivo := NombreArchivo + '.pgl';
    Proyecto.Guarda(NombreArchivo);
    GuardaReciente(NombreArchivo);
    Self.Caption := 'Galatea [' + NombreArchivo + ']';
    Salvado := True;
    RutaProyectos := ExtractFilePath(dlgGuardarProyecto.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
      ArchivoInicio.WriteString('Directorios', 'Proyectos', RutaProyectos);
    ArchivoInicio.UpdateFile;
  end;
end;

procedure TfrmPrincipal.actGuardarExecute(Sender: TObject);
begin
   if NombreArchivo = ML(mlProyecto) then
    actGuardarComo.Execute
  else
  begin
    Proyecto.Guarda(NombreArchivo);
    Salvado := True;
  end;
end;

procedure TfrmPrincipal.actCerrarExecute(Sender: TObject);
var
  Respuesta : TRespuesta;
begin
  if (Assigned(Proyecto)) and (not Salvado) then
  begin
    Respuesta := PreguntaSNC(ML(mlGrdProyCr), 'Galatea');//¿guardar antes?
    if Respuesta = rSi then
      actGuardar.Execute
    else if Respuesta = rCancelar then
      Exit; //-->
  end;
  FreeAndNil(Proyecto);
  ptbEntorno.Refresh;
  ptbEntorno.Visible := False;
  scbHorizontal.Visible := False;
  scbVertical.Visible := False;
  Self.Caption := 'Galatea';
  LimpiaInformacion;
  BarraSoloNuevo;
end;

procedure TfrmPrincipal.BarraEjecucion;
begin
  actNuevo.Enabled := False;
  actAbrir.Enabled := False;
  actGuardar.Enabled := False;
  actGuardarComo.Enabled := False;
  actCerrar.Enabled := False;
  actSalir.Enabled := False;
  actIniciar.Enabled := False;
  actPausa.Enabled := True;
  actPaso.Enabled := False;
  actDetener.Enabled := True;
  actOpcionesProyecto.Enabled := False;
  actIncZoom.Enabled := True;
  actDecZoom.Enabled := True;
  actNoDesplegar.Enabled := True;
  actInformar.Enabled := True;
  actExpEntorno.Enabled := False;
  edtRetardo.Enabled := True;
  cmbEscala.Enabled := True;
  tlbInicio.Down := True;
  tlbPausa.Down := False;
  R1.Enabled := False;
  R21.Enabled := False;
  R31.Enabled := False;
  R41.Enabled := False;
  R51.Enabled := False;
end;

procedure TfrmPrincipal.BarraPausa;
begin
  actNuevo.Enabled := False;
  actAbrir.Enabled := False;
  actGuardar.Enabled := False;
  actGuardarComo.Enabled := False;
  actCerrar.Enabled := False;
  actSalir.Enabled := False;
  actIniciar.Enabled := True;
  actPausa.Enabled := True;
  actPaso.Enabled := True;
  actDetener.Enabled := True;
  actOpcionesProyecto.Enabled := False;
  actIncZoom.Enabled := True;
  actDecZoom.Enabled := True;
  actNoDesplegar.Enabled := True;
  actExpEntorno.Enabled := True;
  edtRetardo.Enabled := True;
  actInformar.Enabled := True;
  cmbEscala.Enabled := True;
  tlbInicio.Down := False;
  tlbPausa.Down := True;
  R1.Enabled := False;
  R21.Enabled := False;
  R31.Enabled := False;
  R41.Enabled := False;
  R51.Enabled := False;
end;

procedure TfrmPrincipal.BarraSoloNuevo;
begin
  actNuevo.Enabled := True;
  actAbrir.Enabled := True;
  actGuardar.Enabled := False;
  actGuardarComo.Enabled := False;
  actCerrar.Enabled := False;
  actSalir.Enabled := True;
  actIniciar.Enabled := False;
  actPausa.Enabled := False;
  actPaso.Enabled := False;
  actDetener.Enabled := False;
  actIncZoom.Enabled := False;
  actDecZoom.Enabled := False;
  actNoDesplegar.Enabled := False;
  edtRetardo.Enabled := False;
  actInformar.Enabled := False;
  actExpEntorno.Enabled := False;
  cmbEscala.Enabled := False;
  actOpcionesProyecto.Enabled := False;
  R1.Enabled := True;
  R21.Enabled := True;
  R31.Enabled := True;
  R41.Enabled := True;
  R51.Enabled := True;
end;

procedure TfrmPrincipal.BarraTotal;
begin
  actNuevo.Enabled := True;
  actAbrir.Enabled := True;
  actGuardar.Enabled := True;
  actGuardarComo.Enabled := True;
  actCerrar.Enabled := True;
  actSalir.Enabled := True;
  actIniciar.Enabled := True;
  actPausa.Enabled := False;
  actPaso.Enabled := True;
  actDetener.Enabled := False;
  actOpcionesProyecto.Enabled := True;
  actIncZoom.Enabled := True;
  actDecZoom.Enabled := True;
  actNoDesplegar.Enabled := True;
  actInformar.Enabled := True;
  actExpEntorno.Enabled := True;
  edtRetardo.Enabled := True;
  cmbEscala.Enabled := True;
  tlbInicio.Down := False;
  tlbPausa.Down := False;
  R1.Enabled := True;
  R21.Enabled := True;
  R31.Enabled := True;
  R41.Enabled := True;
  R51.Enabled := True;
end;

procedure TfrmPrincipal.ActualizaMenuRecientes;
{Obtiene la lista de archivos recientemente abiertos del archivo de incio y
actuaiza el menú de Archivo}
var
  ListaRecientes: array [1..5] of string;
  i             : Integer;
begin
  for i := 1 to 5 do
    ListaRecientes[i] := ArchivoInicio.ReadString('ProyectosRecientes',
                              'Reciente' + IntToStr(i), '');
  if ListaRecientes[1] <> '' then
  begin
    R1.Caption := '&1 ' + ListaRecientes[1];
    R1.Visible := True;
    N2.Visible := True;
    N3.Visible := True;
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
  {$WARNINGS OFF}
  //SHAddToRecentDocs(SHARD_PATH, PChar(NombreArchivo));
  {$WARNINGS ON}
  //Agregar archivo a la lista de recientes de Windows
end;

procedure TfrmPrincipal.GuardaReciente(PNombreArchivo: string);
{Actualiza la lista de archivos recientemente abiertos en el archivo de inicio}
var
  ListaRecientes: array [1..5] of string;
  i, j          : Integer;
begin
  for i := 1 to 5 do
  begin
    ListaRecientes[i] := ArchivoInicio.ReadString('ProyectosRecientes',
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
      ArchivoInicio.WriteString('ProyectosRecientes', 'Reciente' + IntToStr(j),
                                  ListaRecientes[i]);
      Inc(j);
    end;
  end;
  ArchivoInicio.UpdateFile;
  ActualizaMenuRecientes;
end;

procedure TfrmPrincipal.actNuevoExecute(Sender: TObject);
begin
  if not VerificaSalvado then
    Exit; //-->
  frmNuevoProyecto := TfrmNuevoProyecto.Create(Application);
  if frmNuevoProyecto.ShowModal = mrOK then
  begin
    Proyecto := TProyecto.Create;//(ptbEntorno);
    with Proyecto do
    begin
      Titulo := frmNuevoProyecto.edtTitulo.Text;
      Comentarios := frmNuevoProyecto.memComentarios.Text;
      ArchivoEntorno := frmNuevoProyecto.edtEntorno.Text;
      Entorno.OnDibujaEscenario := DibujaEscnr;
      Entorno.OnDibujaDinamico := DibujaED;
      Entorno.OnDibujaAgente := DibujaAgnt;
      Entorno.Cuadricula := False;
      Entorno.Carga(frmNuevoProyecto.edtEntorno.Text);
      OnCiclo := Ciclo;
      OnNuevoAgente := NuevoAgente;
      OnNuevoHuevo := NuevoHuevo;
      OnNuevoAdulto := NuevoAdulto;
      SetLength(Traslapados, Proyecto.Entorno.Anchura, Proyecto.Entorno.Altura);
    end;
    NombreArchivo := ML(mlProyecto);
    Self.Caption := 'Galatea [' + NombreArchivo + ']';
    AjustaTamano;
    BarraTotal;
    InformaEstado;
  end;
  FreeAndNil(frmNuevoProyecto);
end;

procedure TfrmPrincipal.actIniciarExecute(Sender: TObject);
begin
  CreaArchivosDeSalida;
  Inicio := Now;
  BarraEjecucion;
  Proyecto.Ejecutar;
end;

procedure TfrmPrincipal.actDetenerExecute(Sender: TObject);
begin
  if PreguntaSN(ML(mlPregDetener), 'Galatea') = rSi then
  begin
    Proyecto.Detener;
    AbreArchivo(NombreArchivo);
    BarraTotal;
    AjustaTamano;
    if Assigned(Salida) then
      Salida.Cierra;
    FreeAndNil(Salida);
  end;
end;

procedure TfrmPrincipal.actPausaExecute(Sender: TObject);
begin
  Proyecto.Pausa;
  BarraPausa;
end;

procedure TfrmPrincipal.R1Click(Sender: TObject);
begin
  NombreArchivo := Copy(R1.Caption, 4, Length(R1.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmPrincipal.R21Click(Sender: TObject);
begin
  NombreArchivo := Copy(R21.Caption, 4, Length(R21.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmPrincipal.R31Click(Sender: TObject);
begin
  NombreArchivo := Copy(R31.Caption, 4, Length(R31.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmPrincipal.R41Click(Sender: TObject);
begin
  NombreArchivo := Copy(R41.Caption, 4, Length(R41.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmPrincipal.R51Click(Sender: TObject);
begin
  NombreArchivo := Copy(R51.Caption, 4, Length(R51.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmPrincipal.actPasoExecute(Sender: TObject);
begin
  CreaArchivosDeSalida;
  Proyecto.Paso;
  InformaEstado;
end;

procedure TfrmPrincipal.edtRetardoKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmPrincipal.edtRetardoChange(Sender: TObject);
var
  w: Word;
begin
  if not Assigned(Proyecto) then
    Exit;   //-->
  try
    w := StrToInt(edtRetardo.Text);
    Proyecto.Retardo := w;
  finally

  end;
end;

procedure TfrmPrincipal.AjustaTamano;
{Comprueba los tamaños físicos y lógicos del entorno, mantiene la
relación entre tamaños y escalas con el escenario físico, las barras de
desplazamiento y las acciones de aumentar y disminuir zoom}
begin
  with ptbEntorno do
  begin
    if Proyecto.Entorno.AlturaFisica >
        pnlStatus.Height - scbHorizontal.Height then
    begin
      Height := pnlStatus.Height - scbHorizontal.Height;
      scbVertical.Visible := True;
    end
    else
    begin
      Height := Proyecto.Entorno.AnchuraFisica;
      scbVertical.Visible := False;
    end;
    if Proyecto.Entorno.AnchuraFisica
        > ToolBar1.Width - (pnlStatus.Width + scbVertical.Width) then
    begin
      Width := ToolBar1.Width - (pnlStatus.Width + scbVertical.Width);
      scbHorizontal.Visible := True;
    end
    else
    begin
      Width := Proyecto.Entorno.AnchuraFisica;
      scbHorizontal.Visible := False;
    end;
    if scbHorizontal.Visible then
    begin
      scbHorizontal.Top := Top + Height;
      scbHorizontal.Width := Width;
      scbHorizontal.Max := Proyecto.Entorno.AnchuraFisica;
      //scbHorizontal.PageSize := Width;
    end;
    if scbHorizontal.Position > (Proyecto.Entorno.AnchuraFisica - Width) then
        scbHorizontal.Position := Proyecto.Entorno.AnchuraFisica - Width;
    if scbVertical.Visible then
    begin
      scbVertical.Left := Left + Width;
      scbVertical.Height := Height;
      scbVertical.Max := Proyecto.Entorno.AlturaFisica;
      //scbVertical.PageSize := Height;
    end;
    if scbVertical.Position > (Proyecto.Entorno.AlturaFisica - Height) then
        scbVertical.Position := Proyecto.Entorno.AlturaFisica - Height;
  end;
  Proyecto.Entorno.Despliega;
  MarcaTraslapados;
end;

procedure TfrmPrincipal.MarcaTraslapados;
var
  i, j: Integer;
begin
  for i := 1 to Proyecto.Entorno.Anchura do
        for j := 1 to Proyecto.Entorno.Altura do
          Traslapados[i - 1,j - 1] := Proyecto.Entorno.NumElementosEn(i,j) > 1;
  for i := 1 to Proyecto.Entorno.Anchura do
    for j := 1 to Proyecto.Entorno.Altura do
      if Traslapados[i-1,j-1] then
        with ptbEntorno.Canvas do
        begin
          Pen.Color := clWhite;
          Pen.Style := psSolid;
          Brush.Style := bsClear;
          Rectangle(Proyecto.Entorno.XFisica(i), Proyecto.Entorno.YFisica(j),
              Proyecto.Entorno.XFisica(i) + Proyecto.Entorno.CuadroFisico,
              Proyecto.Entorno.YFisica(j) + Proyecto.Entorno.CuadroFisico);
        end;
end;

procedure TfrmPrincipal.FormResize(Sender: TObject);
begin
  with pnlStatus do
  begin
    Left := Self.Width - Width;
  end;
  if Assigned(Proyecto) then
    AjustaTamano;
end;

procedure TfrmPrincipal.actDecZoomExecute(Sender: TObject);
begin
  with Proyecto.Entorno do
  begin
    Porcentaje := Porcentaje - 20;
    cmbEscala.ItemIndex := cmbEscala.ItemIndex - 1;
    if Porcentaje = 20 then
      actDecZoom.Enabled := False;
    actIncZoom.Enabled := True;
  end;
  AjustaTamano;
end;

procedure TfrmPrincipal.actIncZoomExecute(Sender: TObject);
begin
  with Proyecto.Entorno do
  begin
    Porcentaje := Porcentaje + 20;
    cmbEscala.ItemIndex := cmbEscala.ItemIndex + 1;
    if Porcentaje = 200 then
      actIncZoom.Enabled := False;
    actDecZoom.Enabled := True;
  end;
  AjustaTamano;
end;

procedure TfrmPrincipal.FormPaint(Sender: TObject);
begin
  if Assigned(Proyecto) then
  begin
    Proyecto.Entorno.Despliega;
    MarcaTraslapados;
  end;
end;

procedure TfrmPrincipal.scbVerticalChange(Sender: TObject);
begin
  if scbVertical.Position <= (Proyecto.Entorno.AlturaFisica -
      ptbEntorno.Height) then
  begin
   Proyecto.Entorno.DesplazamientoY := scbVertical.Position;
   Proyecto.Entorno.Despliega;
   MarcaTraslapados;
  end;
end;

procedure TfrmPrincipal.scbHorizontalChange(Sender: TObject);
begin
  if scbHorizontal.Position <= (Proyecto.Entorno.AnchuraFisica
      - ptbEntorno.Width) then
  begin
    Proyecto.Entorno.DesplazamientoX := scbHorizontal.Position;
    Proyecto.Entorno.Despliega;
    MarcaTraslapados;
  end;
end;

procedure TfrmPrincipal.cmbEscalaChange(Sender: TObject);
begin
  Proyecto.Entorno.Porcentaje := (cmbEscala.ItemIndex + 1) * 20;
  AjustaTamano;
  if Proyecto.Entorno.Porcentaje = 200 then
    actIncZoom.Enabled := False
  else
    actIncZoom.Enabled := True;
  if Proyecto.Entorno.Porcentaje = 20 then
    actDecZoom.Enabled := False
  else
    actDecZoom.Enabled := True;
end;

procedure TfrmPrincipal.actNoDesplegarExecute(Sender: TObject);
begin
  if Proyecto.Visualizar then
  begin
    Proyecto.Visualizar := False;
    tlbVisualizar.Down := True;
  end
  else
  begin
    Proyecto.Visualizar := True;
    tlbVisualizar.Down := False;
  end;
end;

procedure TfrmPrincipal.InformaEstado;
var
  Duracion: Real;
  IAnio, IMes, IDia, IHora, IMinuto, ISegundo, //Fecha y hora de inicio
  FAnio, FMes, FDia, FHora, FMinuto, FSegundo, //Fecha y hora de fin
  w: Word;
  Horas,
  Minutos,
  Segundos,
  Totales,  //Segundos totales
  i, j: Integer;
  Cont: array of Word;
  sFInicio,
  sFFin,
  sHInicio,
  sHFin,
  sTiempoTotal,
  sDuracion: string;
  Mediador: TMediador;
begin
  LimpiaInformacion;
  Mediador := TMediador.Create(Proyecto.Entorno);
  DespliegaValorDe(ML(mlCiclos), Proyecto.Entorno.Ciclos, clBlack);
  with Proyecto.Entorno.Juego do
    SetLength(Cont, NumEstadios + NumPrototiposM + NumPrototiposH);
  with Proyecto.Entorno.ListaAgentes do
  begin
    for i := 1 to Contador do
    begin
      Mediador.Agente := Elementos[i];
      Inc(Cont[Mediador.PrototipoListado - 1]);
    end;
  end;
  with Proyecto.Entorno.Juego do
  begin
    Cont[0] := Proyecto.Entorno.ListaHuevos.Contador;
    DespliegaValorDe(Estadios[1].Nombre , Cont[0], Estadios[1].Color);
    j := 1;
    for i := 2 to NumEstadios do
    begin
      DespliegaValorDe(Estadios[i].Nombre, Cont[j], Estadios[i].Color);
      Inc(j);
    end;
    for i := 1 to NumPrototiposM do
    begin
      DespliegaValorDe(PrototiposM[i].Nombre, Cont[j], PrototiposM[i].Color);
      Inc(j);
    end;
    for i := 1 to NumPrototiposH do
    begin
      DespliegaValorDe(PrototiposH[i].Nombre, Cont[j], PrototiposH[i].Color);
      Inc(j);
    end;
    j := 0;
    for i := 0 to Length(Cont) - 1 do
      j := j + Cont[i];
    DespliegaValorDe('Total' , j, clBlack);
  end;
  Mediador.Free;
  if not (Proyecto.Status = stEjecutando) then
    Exit; //-->
  Fin := Now;
  Totales := SecondsBetween(Inicio, Fin);
  Horas := Totales div 3600;
  Minutos := (Totales mod 3600) div 60;
  Segundos := (Totales mod 3600) mod 60;
  Duracion := Totales / Proyecto.Entorno.Ciclos;
  sDuracion := FloatToStrF(Duracion, ffFixed, 7, 8);
  DecodeDate(Inicio, IAnio, IMes, IDia);
  DecodeDate(Fin, FAnio, FMes, FDia);
  DecodeTime(Inicio, IHora, IMinuto, ISegundo, w);
  DecodeTime(Fin, FHora, FMinuto, FSegundo, w);
  sFInicio := IntAStr(IDia, 2) + '/' + IntAStr(IMes, 2) + '/' + IntToStr(IAnio);
  sFFin := IntAStr(FDia, 2) + '/' + IntAStr(FMes, 2) + '/' + IntToStr(FAnio);
  sHInicio := IntAStr(IHora, 2) + ':' + IntAStr(IMinuto, 2)
      + ':' + IntAStr(ISegundo, 2);
  sHFin := IntAStr(FHora, 2) + ':' + IntAStr(FMinuto, 2)
      + ':' + IntAStr(FSegundo, 2);
  sTiempoTotal := IntToStr(Horas) + ':' + IntAStr(Minutos, 2) + ':'
      + IntAStr(Segundos, 2);
  DespliegaValorDe(ML(mlFechaInicio), sFInicio, clGreen);
  DespliegaValorDe(ML(mlHoraInicio), sHInicio, clGreen);
  DespliegaValorDe(ML(mlFechaFin), sFFin, clBlue);
  DespliegaValorDe(ML(mlHoraFin), sHFin, clBlue);
  DespliegaValorDe(ML(mlTiempoTotal), sTiempoTotal, clRed);
  DespliegaValorDe(ML(mlDuracCiclo), sDuracion, clBlack);
  j := 0;
  for i := 0 to Length(Cont) - 1 do
    j := j + Cont[i];
  if j = 0 then       //Todos los agentes han muerto
  begin
    actPausa.Execute;
    Informa(ML(mlTodosMuertos), 'Galatea');
  end;
end;

procedure TfrmPrincipal.actInformarExecute(Sender: TObject);
begin
  InformaEstado;
end;

procedure TfrmPrincipal.LimpiaInformacion;
begin
  memInfo.Clear;
end;

procedure TfrmPrincipal.actOpcionesProyectoExecute(Sender: TObject);
begin
  frmOpcionesProyecto := TfrmOpcionesProyecto.Create(Application);
  frmOpcionesProyecto.edtTitulo.Text := Proyecto.Titulo;
  frmOpcionesProyecto.memComentarios.Text := Proyecto.Comentarios;
  if frmOpcionesProyecto.ShowModal = mrOK then
  with Proyecto do
    begin
      Titulo := frmOpcionesProyecto.edtTitulo.Text;
      Comentarios := frmOpcionesProyecto.memComentarios.Text;
    end;
  FreeAndNil(frmOpcionesProyecto);
end;

procedure TfrmPrincipal.DespliegaValorDe(Variable: string; Valor: Integer;
    PColor: TColor);
//var
  //Long  : Word;
  //sValor: string;
begin
  {with redInformacion do
  begin
    sValor := IntToStr(Valor);
    Variable := CadenaLong(Variable, 13);
    Long := 14 + Length(sValor);
    Lines.Add(Variable + ':' + sValor);
    SelStart := SelStart - Long - 2;
    SelLength := Long + 1;
    SelAttributes.Color := PColor;
    SelAttributes.Size := 8;
    SelLength := 0;
  end; }
  memInfo.Lines.Add(Variable + ': ' + IntToStr(Valor));
end;

procedure TfrmPrincipal.DespliegaValorDe(Variable, Valor: string;
  PColor: TColor);
//var
  //Long: Word;
begin
  {with redInformacion do
  begin
    Variable := CadenaLong(Variable, 13);
    Long := 14 + Length(Valor);
    Lines.Add(Variable + ':' + Valor);
    SelStart := SelStart - Long - 2;
    SelLength := Long + 1;
    SelAttributes.Color := PColor;
    SelAttributes.Size := 8;
    SelLength := 0;
  end; }
  memInfo.Lines.Add(Variable + ': ' + Valor);
end;

procedure TfrmPrincipal.actExpEntornoExecute(Sender: TObject);
var
  NombreArchivoEnt,
  RutaEntorno : string;
begin
  {$IFDEF MSWINDOWS}
  RutaEntorno := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ '\';
  {$ENDIF}
  {$IFDEF LINUX}
  RutaEntorno := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ '/';
  {$ENDIF}
  RutaEntorno :=
      ArchivoInicio.ReadString('Directorios', 'Entornos', RutaEntorno);
  if DirectoryExists(RutaEntorno) then
    dlgGuardarEntorno.InitialDir := RutaEntorno
  else
  begin
    if PreguntaSN(ML(mlDrEntNE), ML(mlEdEntGlt)) = rSi then //no existe
      begin                       //directorio de entornos, ¿crearlo?
        CreateDir(RutaEntorno);
        dlgGuardarEntorno.InitialDir := RutaEntorno
      end;
  end;
  dlgGuardarEntorno.FileName := Proyecto.Titulo + '_'
      + IntToStr(Proyecto.Entorno.Ciclos);
  if dlgGuardarEntorno.Execute then
  begin
    NombreArchivoEnt := dlgGuardarEntorno.FileName;
    if ExtractFileExt(NombreArchivoEnt) <> '.ngl' then
      NombreArchivoEnt := NombreArchivoEnt + '.ngl';
    Proyecto.Entorno.Guarda(NombreArchivoEnt);
    Salvado := True;
    RutaEntorno := ExtractFilePath(dlgGuardarEntorno.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
      ArchivoInicio.WriteString('Directorios', 'Entornos', RutaEntorno);
  end;
  ArchivoInicio.UpdateFile;
end;

procedure TfrmPrincipal.actGeneralesExecute(Sender: TObject);
begin
  frmGenerales := TfrmGenerales.Create(Application);
  frmGenerales.ShowModal;
  FreeAndNil(frmGenerales);
end;

procedure TfrmPrincipal.Ciclo(Sender: TObject; Ciclo: Integer;
    Info: TStringList);
 var
  NombreArchivoEnt,
  RutaEntorno : string;
begin
  if Proyecto.Status = stParado then
    Exit;
  if Temporizadores.Autoguardado then
    if (Ciclo mod Temporizadores.IntervaloAutoGuardado) = 0 then
    begin
      RutaEntorno := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ Diag;
      RutaEntorno :=
        ArchivoInicio.ReadString('Directorios', 'Entornos', RutaEntorno);
      if DirectoryExists(RutaEntorno) then
      begin
        NombreArchivoEnt := Proyecto.Titulo + '_'
            + IntToStr(Proyecto.Entorno.Ciclos);
        NombreArchivoEnt := NombreArchivoEnt + '.ngl';
        NombreArchivoEnt := RutaEntorno + NombreArchivoEnt;
        Proyecto.Entorno.Guarda(NombreArchivoEnt);
      end
      else
        actExpEntorno.Execute;
    end;
  if Temporizadores.Informar then
    if (Ciclo mod Temporizadores.IntervaloInformar) = 0 then
      InformaEstado;
  if Temporizadores.Detener then
    if (Ciclo mod Temporizadores.Detencion) = 0 then
      actDetener.Execute;
  EnviaInfoCiclo(Info);
  if (Ciclo mod Temporizadores.IntervaloSalida) = 0 then
    Salida.ActualizaArchivos;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  with ArchivoInicio do
  begin
    WriteBool('General', 'Autoguardado', Temporizadores.Autoguardado);
    WriteBool('General', 'Informar', Temporizadores.Informar);
    WriteBool('General', 'Detener', Temporizadores.Detener);
    WriteInteger('General', 'IntervaloAutoguardado',
        Temporizadores.IntervaloAutoGuardado);
    WriteInteger('General', 'IntervaloInformar',
        Temporizadores.IntervaloInformar);
    WriteInteger('General', 'Detencion',
        Temporizadores.Detencion);
    WriteInteger('General', 'IntervaloSalida', Temporizadores.IntervaloSalida);
    if WindowState = wsMaximized then
      WriteString('Ventanas', 'Galatea', 'Maximizada')
    else
      ArchivoInicio.WriteString('Ventanas', 'Galatea', 'Normal');
  end;
  ArchivoInicio.UpdateFile;
  ArchivoInicio.Free;
  Ejecutable.Free;
end;

procedure TfrmPrincipal.CreaArchivosDeSalida;
var
  i: Integer;
  Exito: Boolean;
  Nombre,
  DirectorioSalida: string;
begin
  if Assigned(Salida) then
    Exit; //-->
  DirectorioSalida := ArchivoInicio.ReadString('Directorios', 'Salida',
  ExtractFilePath(Application.ExeName) + ML(mlSalida) + Diag);
  if not DirectoryExists(DirectorioSalida) then
    if PreguntaSN(ML(mlDirSalNE), 'Galatea') = rSi then  //No existe directorio
      CreateDir(DirectorioSalida);
  Nombre := ExtractFileName(NombreArchivo);
  Nombre := ChangeFileExt(Nombre, '');
  Salida := TSalida.Create(DirectorioSalida, Nombre, Proyecto.Entorno);
  Exito := Salida.ResultadoCreacion;
  if not Exito then
  begin
    Fallo(ML(mlErrDirSalNC), 'Galatea');
    Exit; //-->
  end;
  Salida.GuardaInfoEntorno;
  with Proyecto.Entorno.ListaAgentes do
    for i := 1 to Contador do
      Salida.AgregaAgente(Elementos[i]);
  with Proyecto.Entorno.ListaHuevos do
    for i := 1 to Contador do
      Salida.AgregaHuevo(Elementos[i]);
end;

procedure TfrmPrincipal.NuevoAgente(Sender: TObject; Agente: TAgente);
begin
  Salida.AgregaAgente(Agente);
  Agente.OnDibuja := DibujaAgnt;
end;

procedure TfrmPrincipal.NuevoHuevo(Sender: TObject; Huevo: THuevo);
begin
  Salida.AgregaHuevo(Huevo);
end;

procedure TfrmPrincipal.actAnalizadorExecute(Sender: TObject);
var
  RutaAnalizador: string;
begin
  {$IFDEF LINUX}
  RutaAnalizador := ExtractFilePath(Application.ExeName) + 'AnlzdrSldsGlt';
  {$ENDIF}
  {$IFDEF WIN32}
  RutaAnalizador := ExtractFilePath(Application.ExeName) + 'AnlzdrSldsGlt.exe';
  {$ENDIF}
  Ejecutable.CommandLine := RutaAnalizador;
  if FileExists(RutaAnalizador) then
    Ejecutable.Execute
  else
    Fallo(ML(mlErrFltAnlzdr), 'Galatea');//Falta analizador de salidas
end;

procedure TfrmPrincipal.EnviaInfoCiclo(Info: TStringList);
begin
  Salida.AgregaCiclo(Proyecto.Entorno.Ciclos, Info);
  Salida.AgregaGrafica(Info[0]);
end;

procedure TfrmPrincipal.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrmPrincipal.NuevoAdulto(Sender: TObject; Agente: TAgente);
begin
  Salida.AgregaAdulto(Agente);
end;

procedure TfrmPrincipal.DibujaAgnt(Sender: TObject; XFisica, YFisica,
  CuadroFisico: Word);
begin
  DibujaAgente(Sender as TAgente, XFisica, YFisica, CuadroFisico);
end;

procedure TfrmPrincipal.DibujaED(Sender: TObject; XFisica, YFisica,
  CuadroFisico: Word);
begin
  DibujaElementoDinamico(Sender as TDinamico, XFisica, YFisica, CuadroFisico);
end;

procedure TfrmPrincipal.DibujaEscnr(Sender: TObject);
begin
  DibujaEscenario(Sender as TEscenario);
end;

initialization
  {$i Principal.lrs}

end.
