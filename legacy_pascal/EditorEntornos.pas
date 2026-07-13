unit EditorEntornos;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ActnList, Menus, StdCtrls,
  ExtCtrls, IniFiles, Entornos, Elementos, Agentes, ElementoDinamico,
  Comunes, LResources;

type

  TAccion = (acAgentes, acAgua, acAzucar, acGrasa, acProteinas, acOviposicion,
              acHuevo, acNada);
  TTipoElemento = (elAgente, elHuevo, elAgua, elAzucar, elGrasa, elProteinas,
                elOviposicion);
 // TCuadro = '0'..'Z';

  TPortaPapeles = class
   private
    Agentes: array of TAgente;
    //Huevos: array of THuevo;
    Dinamicos: array of TDinamico;
    Oviposicion: array of TSitioOviposicion;
    Cortado: Boolean; //Indica si se ejecutó Cortar antes de pegar
    function GetAltura: Word;
    function GetAnchura: Word;
    function NuevaX(Xref, Xelemento: Word): Word;
    function NuevaY(Yref, Yelemento: Word): Word;
    procedure Carga;  //Carga los elementos seleccionados a portapapeles
   public
    X1, Y1,
    X2, Y2: Word;
    function Vacio: Boolean;
    constructor Create;
    procedure Dibuja;
    procedure Corta;
    procedure Copia;
    procedure Pega(X, Y: Word);
    property Altura: Word
      read GetAltura;
    property Anchura: Word
      read GetAnchura;
   end;

  { TfrmEditorEntornos }

  TfrmEditorEntornos = class(TForm)
    aclPrincipal: TActionList;
    actNuevo: TAction;
    actAbrir: TAction;
    actGuardar: TAction;
    actCerrar: TAction;
    actGuardarComo: TAction;
    actSalir: TAction;
    actCortar: TAction;
    actCopiar: TAction;
    actPegar: TAction;
    actImportaEscenario: TAction;
    actExportaEscenario: TAction;
    actIncZoom: TAction;
    actDecZoom: TAction;
    actAyuda: TAction;
    actPropiedades: TAction;
    actAcerca: TAction;
    imlPrincipal: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    NewEnvironment1: TMenuItem;
    odlAgentes: TOpenDialog;
    odlEscenario: TOpenDialog;
    OpenEnvironment1: TMenuItem;
    SaveEnvironment1: TMenuItem;
    SaveEnviromentas1: TMenuItem;
    Enviromentproperties1: TMenuItem;
    N2: TMenuItem;
    R1: TMenuItem;
    R21: TMenuItem;
    R31: TMenuItem;
    R41: TMenuItem;
    R51: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    View1: TMenuItem;
    Agents1: TMenuItem;
    Stages1: TMenuItem;
    Help1: TMenuItem;
    Zoomin1: TMenuItem;
    Zooout1: TMenuItem;
    LoadStage1: TMenuItem;
    SaveStage1: TMenuItem;
    Createprototype1: TMenuItem;
    Addprototype1: TMenuItem;
    Contents1: TMenuItem;
    About1: TMenuItem;
    tlbPrincipal: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    cmbEscala: TComboBox;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    //ApplicationEvents1: TApplicationEvents;
    StatusBar1: TStatusBar;
    aclElementos: TActionList;
    actAgentes: TAction;
    actAgua: TAction;
    actGrasas: TAction;
    actAzucares: TAction;
    actProteinas: TAction;
    actOviposicion: TAction;
    imlElementos: TImageList;
    actPuntero: TAction;
    tlbElementos: TToolBar;
    ToolButton16: TToolButton;
    tbtApuntador: TToolButton;
    tbtAgentes: TToolButton;
    tbtAgua: TToolButton;
    tbtGrasa: TToolButton;
    tbtAzucar: TToolButton;
    tbtProteina: TToolButton;
    tbtOviposicion: TToolButton;
    ptbEntorno: TPaintBox;
    scbHorizontal: TScrollBar;
    scbVertical: TScrollBar;
    dlgAbrirEntorno: TOpenDialog;
    dlgGuardarEntorno: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Cut2: TMenuItem;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    Options1: TMenuItem;
    CloseEnvironment1: TMenuItem;
    actImportaJuego: TAction;
    actExportaJuego: TAction;
    actEditarElemento: TAction;
    N1: TMenuItem;
    Editelement1: TMenuItem;
    actHuevos: TAction;
    tbtHuevo: TToolButton;
    N4: TMenuItem;
    Editelement2: TMenuItem;
    actEliminar: TAction;
    Deleteelement1: TMenuItem;
    Deleteelement2: TMenuItem;
    //XPManifest1: TXPManifest;
    dlgGuardarEscenario: TSaveDialog;
    dlgGuardarAgentes: TSaveDialog;
    actCopiarNVeces: TAction;
    N5: TMenuItem;
    CopyNtimes1: TMenuItem;
    N6: TMenuItem;
    CopyNtimes2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure actSalirExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNuevoExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure actGuardarExecute(Sender: TObject);
    procedure actGuardarComoExecute(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure scbVerticalChange(Sender: TObject);
    procedure scbHorizontalChange(Sender: TObject);
    procedure ptbEntornoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ptbEntornoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ptbEntornoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actCortarExecute(Sender: TObject);
    procedure actCopiarExecute(Sender: TObject);
    procedure actPegarExecute(Sender: TObject);
    procedure actIncZoomExecute(Sender: TObject);
    procedure actDecZoomExecute(Sender: TObject);
    procedure cmbEscalaChange(Sender: TObject);
    procedure actPropiedadesExecute(Sender: TObject);
    procedure R1Click(Sender: TObject);
    procedure R21Click(Sender: TObject);
    procedure R31Click(Sender: TObject);
    procedure R41Click(Sender: TObject);
    procedure R51Click(Sender: TObject);
    procedure actAgentesExecute(Sender: TObject);
    procedure actPunteroExecute(Sender: TObject);
    procedure actCerrarExecute(Sender: TObject);
    procedure actAguaExecute(Sender: TObject);
    procedure actGrasasExecute(Sender: TObject);
    procedure actAzucaresExecute(Sender: TObject);
    procedure actProteinasExecute(Sender: TObject);
    procedure actEditarElementoExecute(Sender: TObject);
    procedure actEliminarExecute(Sender: TObject);
    procedure actExportaEscenarioExecute(Sender: TObject);
    procedure actExportaJuegoExecute(Sender: TObject);
    procedure actImportaEscenarioExecute(Sender: TObject);
    procedure actImportaJuegoExecute(Sender: TObject);
    procedure actOviposicionExecute(Sender: TObject);
    procedure actHuevosExecute(Sender: TObject);
    procedure actCopiarNVecesExecute(Sender: TObject);
  private
    { Private declarations }
    ArchivoInicio: TIniFile;
    Accion: TAccion;
    Marcando: Boolean;
    X, Y : Integer; //Coordenadas absolutas actuales
    //X y Y se actualizan cada vez que se hace clic sobre el entorno
    //PortaPapeles: array of array of TCuadro;
    Traslapados: array of array of Boolean;
{    AltoPortapapeles,
    AnchoPortapapeles: Integer; }
    NombreArchivo: string;
    NumeroPrototipo: Word; //Número de prototipo seleccionado para insertar
    SexoPrototipo: TSexo;  //Sexo de prototipo seleccionado para insertar
    Pigmalion,
    Galatea: TAgente; //Agentes con genotipos por omisión
    PortaPapeles: TPortaPapeles;
    function VerificaSalvado:Boolean;
    function CopiaAgente(Indice, PX, PY: Word): Word;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure AjustaTamano;
    procedure MarcaTraslapados;
    procedure BarraNoEditar;
    procedure BarraTotal;
    procedure GuardaReciente(PNombreArchivo: string);
    procedure ActualizaMenuRecientes;
    procedure InsertaAgente(PX, PY: Word);
    procedure InsertaDinamico(Tipo: TTipoElemento; PX, PY: Word);
    procedure InsertaOviposicion(Tipo: TTipoElemento; PX, PY: Word);
    procedure InsertaHuevos(PX, PY: Word);
    procedure ComparaNombresSustratos(ArchivoEscenario, ArchivoAgentes: string);
    procedure CambiaNombreVariablePrefijos(De, A: string);
    procedure EditaElemento(X, Y: Word);
    procedure EliminaElemento(X, Y: Word);
    procedure CopiaNVecesElemento(X, Y: Word);
    procedure CopiaDinamico(Indice, PX, PY: Word);
    procedure CopiaOviposicion(Indice, PX, PY: Word);
    procedure CrearPigmalionGalatea;
    procedure DibujaEscnr(Sender: TObject);
    procedure DibujaED(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
    procedure DibujaAgnt(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
  public
    { Public declarations }
    Salvado: Boolean;
      //Determina si el archivo ha sido guardado desde la última modificación
    Entorno: TEntorno;
    procedure CopiaNVecesAgente(Indice, Veces: Word;
        Permitidos: array of Boolean);
    procedure CopiaNVecesDinamico(Indice, Veces: Word;
         Permitidos: array of Boolean);
    procedure CopiaNVecesOviposicion(Indice, Veces: Word;
         Permitidos: array of Boolean);
    procedure CreaPuestaHuevos(sPadre, sMadre: string; Portador: TElemento;
        Edad, Cantidad: Word);
  end;

var
  frmEditorEntornos: TfrmEditorEntornos;

implementation

uses
  Multilenguaje, Dialogos, NuevoEntorno, PropiedadesEntorno,
  Escenarios, SeleccionarPrototipo, SeleccionaElemento, EditarAgente,
  JuegoAgentes, SeleccionarEscenario, SeleccionarJuegoAgentes, SitioOviposicion,
  CopiarNVeces, Mediadores, EditarPuesta, Cruzadores, Dibujo;


function TfrmEditorEntornos.VerificaSalvado: Boolean;
{Verifica si el archivo ha sido guardado desde la última modificación, si el
archivo no ha sido guardado pregunta al usuario si desea guardarlo.
Regresa False si el usuario cancela la acción de cerrar archivo}
var
  Respuesta: TRespuesta;
begin
  Result := True;
  if Assigned(Entorno) then
  begin
    if not Salvado then
    begin
      Respuesta := PreguntaSNC(ML(mlGrdEntCr), ML(mlEdEntGlt));//¿guardar antes?
      case Respuesta of
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

procedure TfrmEditorEntornos.FormCreate(Sender: TObject);
var
  EstadoVentana: string;
begin
  {Candado de seguridad
  if not Llave('galatea', '') then
  begin
    Fallo('Ilegal copy / copia ilegal', 'Galatea');
    Halt; //--->
  end;
  Candado de seguridad}
  Plataforma := ptbEntorno.Canvas;
  BarraNoEditar;
  ArchivoInicio := TIniFile.Create('.galatea.ini');
  Accion := acNada;
  Marcando := False;
  ActualizaMenuRecientes;
  EstadoVentana := ArchivoInicio.ReadString('Ventanas', 'EditorEntornos',
      'Normal');
  if EstadoVentana = 'Maximizada' then
    WindowState := wsMaximized
  else
    WindowState := wsNormal;
  if ParamCount <> 0 then
  begin
    NombreArchivo := ParamStr(1);
    if ExtractFileExt(NombreArchivo) = '.ngl' then
    begin
      AbreArchivo(NombreArchivo);
      CrearPigmalionGalatea;
    end
    else
      Fallo(ML(mlErrExtNCEEN), ML(mlEdEntGlt));
  end;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ';
  PortaPapeles := TPortaPapeles.Create;
  Randomize;
end;

procedure TfrmEditorEntornos.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := VerificaSalvado;
end;

procedure TfrmEditorEntornos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if WindowState = wsMaximized then
    ArchivoInicio.WriteString('Ventanas', 'EditorEntornos', 'Maximizada')
  else
    ArchivoInicio.WriteString('Ventanas', 'EditorEntornos', 'Normal');
  ArchivoInicio.Free;
  Pigmalion.Free;
  Galatea.Free;
  PortaPapeles.Free;
end;

procedure TfrmEditorEntornos.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrmEditorEntornos.actSalirExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmEditorEntornos.BarraNoEditar;
{Actualiza los controles disponibles cuando no hay ningún entorno abierto}
var
  i : Integer;
begin
  actGuardar.Enabled := False;
  actGuardarComo.Enabled := False;
  actCerrar.Enabled := False;
  actPropiedades.Enabled := False;
  actCortar.Enabled := False;
  actCopiar.Enabled := False;
  actPegar.Enabled := False;
  actEditarElemento.Enabled := False;
  actEliminar.Enabled := False;
  actIncZoom.Enabled := False;
  actDecZoom.Enabled := False;
  actImportaEscenario.Enabled := False;
  actImportaJuego.Enabled := False;
  actExportaEscenario.Enabled := False;
  actExportaJuego.Enabled := False;
  cmbEscala.Enabled := False;
  for i := 0 to tlbElementos.ButtonCount - 1 do
  begin
    tlbElementos.Buttons[i].Enabled := False;
    tlbElementos.Buttons[i].Down := False;
  end;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ';
  //****
  //actAcerca.Enabled := True;
end;

procedure TfrmEditorEntornos.ActualizaMenuRecientes;
{Obtiene la lista de archivos recientemente abiertos del archivo de incio y
actuaiza el menú de Archivo}
var
  ListaRecientes: array [1..5] of string;
  i             : Integer;
begin
  for i := 1 to 5 do
    ListaRecientes[i] := ArchivoInicio.ReadString('EntornosRecientes',
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
end;

procedure TfrmEditorEntornos.BarraTotal;
{Hace disponibles todos los controles}
var
  i : Integer;
begin
  actGuardar.Enabled := True;
  actGuardarComo.Enabled := True;
  actCerrar.Enabled := True;
  actPropiedades.Enabled := True;
  actEditarElemento.Enabled := True;
  actEliminar.Enabled := True;
  actIncZoom.Enabled := True;
  actDecZoom.Enabled := True;
  actImportaEscenario.Enabled := True;
  actImportaJuego.Enabled := True;
  actExportaEscenario.Enabled := True;
  actExportaJuego.Enabled := True;
  cmbEscala.Enabled := True;
   for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Enabled := True;
  {if Length(PortaPapeles) <> 0 then
  begin
    actPegar.Enabled := True;
    X := 1;
    Y := 1;
  end;} 
end;

procedure TfrmEditorEntornos.GuardaReciente(PNombreArchivo: string);
{Actualiza la lista de archivos recientemente abiertos en el archivo de inicio}
var
  ListaRecientes: array [1..5] of string;
  i, j          : Integer;
begin
  for i := 1 to 5 do
  begin
    ListaRecientes[i] := ArchivoInicio.ReadString('EntornosRecientes',
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
      ArchivoInicio.WriteString('EntornosRecientes', 'Reciente' + IntToStr(j),
                                  ListaRecientes[i]);
      Inc(j);
    end;
  end;
  ActualizaMenuRecientes;
  {$WARNINGS OFF}
  //SHAddToRecentDocs(SHARD_PATH, PChar(NombreArchivo));
  {$WARNINGS ON}
  //Agregar archivo a la lista de recientes de Windows PENDIENTE
end;

procedure TfrmEditorEntornos.actNuevoExecute(Sender: TObject);
var
  i, j: Integer;
begin
  if not VerificaSalvado then
    Exit; //-->
  frmNuevoEntorno := TfrmNuevoEntorno.Create(Application);
  if frmNuevoEntorno.ShowModal <> mrOK then
  begin
    FreeAndNil(frmNuevoEntorno);
    Exit; //-->
  end;
  Entorno := TEntorno.Create;//(ptbEntorno);
  Entorno.OnDibujaEscenario := DibujaEscnr;
  Entorno.OnDibujaDinamico := DibujaED;
  Entorno.OnDibujaAgente := DibujaAgnt;
  Salvado := True;
  with Entorno do
  begin
    ImportaEscenario(frmNuevoEntorno.edtEscenario.Text);
    SetLength(Traslapados, Anchura, Altura);
    for i := 1 to Anchura do
      for j := 1 to Altura do
        Traslapados[i-1,j-1] := False;
    ImportaJuego(frmNuevoEntorno.edtAgentes.Text);
    Titulo := frmNuevoEntorno.edtTitulo.Text;
    Ciclos := StrToInt(frmNuevoEntorno.edtCiclos.Text);
    Comentarios := frmNuevoEntorno.memComentarios.Text;
    Cuadricula := True;
  end;
  cmbEscala.ItemIndex := 4;
  ptbEntorno.Visible := True;
  AjustaTamano;
  Salvado := False;
  NombreArchivo := ML(mlEntorno);
  Self.Caption := ML(mlEdEntGlt) + ' [' + NombreArchivo + ']';
  actPuntero.Execute;
  BarraTotal;
  ComparaNombresSustratos(frmNuevoEntorno.edtEscenario.Text,
                            frmNuevoEntorno.edtAgentes.Text);
  FreeAndNil(frmNuevoEntorno);
  CrearPigmalionGalatea;
end;

procedure TfrmEditorEntornos.actAbrirExecute(Sender: TObject);
var
  RutaEntorno : string;
  Respuesta   : TRespuesta;
begin
  if not VerificaSalvado then
    Exit; //-->
  RutaEntorno := ExtractFilePath(Application.ExeName) + ML(mlEntornos) + Diag;
  if DirectoryExists(RutaEntorno) then
    dlgAbrirEntorno.InitialDir := RutaEntorno
  else
  begin
    Respuesta := PreguntaSN(ML(mlDrEntNE),ML(mlEdEntGlt));//no existe directorio
    if  Respuesta = rSI then            //de entornos ¿crearlo?
    begin
      //CreateDirectory(PChar(RutaEntorno), nil);
      CreateDir(RutaEntorno);
      dlgAbrirEntorno.InitialDir := RutaEntorno;
    end;
  end;
  if dlgAbrirEntorno.Execute then
  begin
    NombreArchivo := dlgAbrirEntorno.FileName;
    AbreArchivo(NombreArchivo);
  end;
end;

procedure TfrmEditorEntornos.AbreArchivo(PNombreArchivo: string);
var
  i, j: Integer;
begin
  if not VerificaSalvado then
    Exit; //-->
  if not FileExists(PNombreArchivo) then
  begin                                               //no existe el archivo
    Fallo(ML(mlErrArchvNE) + ': ' + PNombreArchivo, ML(mlEdEntGlt));
    Exit; //-->
  end;
  NombreArchivo := PNombreArchivo;
  GuardaReciente(NombreArchivo);
  Self.Caption := ML(mlEdEntGlt) + ' [' + NombreArchivo + ']';
  Salvado := True;
  Entorno := TEntorno.Create;//(ptbEntorno);
  Entorno.OnDibujaEscenario := DibujaEscnr;
  Entorno.OnDibujaDinamico := DibujaED;
  Entorno.OnDibujaAgente := DibujaAgnt;
  with Entorno do
  begin
    Carga(NombreArchivo);
    SetLength(Traslapados, Anchura, Altura);
    for i := 1 to Anchura do
      for j := 1 to Altura do
        Traslapados[i-1,j-1] := NumElementosEn(i,j) > 1;
  end;
  ptbEntorno.Visible := True;
  cmbEscala.ItemIndex := 4;
  AjustaTamano;
  actPuntero.Execute;
  BarraTotal;
  CrearPigmalionGalatea;
end;

procedure TfrmEditorEntornos.actGuardarExecute(Sender: TObject);
begin
  if NombreArchivo = ML(mlEntorno) then
    actGuardarComo.Execute
  else
  begin
    Entorno.Guarda(NombreArchivo);
    Salvado := True;
  end;
end;

procedure TfrmEditorEntornos.actGuardarComoExecute(Sender: TObject);
var
  RutaEntorno : string;
begin
  RutaEntorno := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ Diag;
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
  dlgGuardarEntorno.FileName := Entorno.Titulo;
  if dlgGuardarEntorno.Execute then
  begin
    NombreArchivo := dlgGuardarEntorno.FileName;
    if ExtractFileExt(NombreArchivo) <> '.ngl' then
      NombreArchivo := NombreArchivo + '.ngl';
    Self.Caption := ML(mlEdEntGlt) + ' [' + NombreArchivo + ']';
    Entorno.Guarda(NombreArchivo);
    GuardaReciente(NombreArchivo);
    Salvado := True;
    RutaEntorno := ExtractFilePath(dlgGuardarEntorno.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
      ArchivoInicio.WriteString('Directorios', 'Entornos', RutaEntorno);
  end;
end;

procedure TfrmEditorEntornos.AjustaTamano;
{Comprueba los tamaños físicos y lógicos del entorno, mantiene la
relación entre tamaños y escalas con el escenario físico, las barras de
desplazamiento y las acciones de aumentar y disminuir zoom}
begin
  with ptbEntorno do
  begin
    if Entorno.AlturaFisica > tlbElementos.Height - scbHorizontal.Height then
    begin
      //Height := tlbElementos.Height - scbHorizontal.Height;
      scbVertical.Visible := True;
    end
    else
    begin
      //Height := Entorno.AnchuraFisica;
      scbVertical.Visible := False;
    end;
    if Entorno.AnchuraFisica
        > tlbPrincipal.Width - (tlbElementos.Width + scbVertical.Width) then
    begin
      //Width := tlbPrincipal.Width - (tlbElementos.Width + scbVertical.Width);
      scbHorizontal.Visible := True;
    end
    else
    begin
      //Width := Entorno.AnchuraFisica;
      scbHorizontal.Visible := False;
    end;
    if scbHorizontal.Visible then
    begin
      scbHorizontal.Top := Top + Height;
      scbHorizontal.Width := Width;
      scbHorizontal.Max := Entorno.AnchuraFisica;
      scbHorizontal.PageSize := Width;
    end;
    if scbHorizontal.Position > (Entorno.AnchuraFisica - Width) then
        scbHorizontal.Position := Entorno.AnchuraFisica - Width;
    if scbVertical.Visible then
    begin
      scbVertical.Left := Left + Width;
      scbVertical.Height := Height;
      scbVertical.Max := Entorno.AlturaFisica;
      scbVertical.PageSize := Height;
    end;
    if scbVertical.Position > (Entorno.AlturaFisica - Height) then
        scbVertical.Position := Entorno.AlturaFisica - Height;
  end;
  Entorno.Despliega;
  MarcaTraslapados;
  if Assigned(Portapapeles) then
    PortaPapeles.Dibuja;
end;

procedure TfrmEditorEntornos.FormPaint(Sender: TObject);
begin
  if Assigned(Entorno) then
  begin
    Entorno.Despliega;
    MarcaTraslapados;
    if Assigned(Portapapeles) then
      PortaPapeles.Dibuja;
  end;
end;

procedure TfrmEditorEntornos.FormResize(Sender: TObject);
begin
  if Assigned(Entorno) then
    AjustaTamano;
end;

procedure TfrmEditorEntornos.FormWindowStateChange(Sender: TObject);
begin
  if (WindowState = wsMaximized) and (Assigned(Entorno)) then
  	AjustaTamano;
end;

procedure TfrmEditorEntornos.scbVerticalChange(Sender: TObject);
begin
  if scbVertical.Position <= (Entorno.AlturaFisica -  ptbEntorno.Height) then
  begin
   Entorno.DesplazamientoY := scbVertical.Position;
   Entorno.Despliega;
   MarcaTraslapados;
   PortaPapeles.Dibuja;
  end;
end;

procedure TfrmEditorEntornos.scbHorizontalChange(Sender: TObject);
begin
  if scbHorizontal.Position <= (Entorno.AnchuraFisica - ptbEntorno.Width) then
  begin
    Entorno.DesplazamientoX := scbHorizontal.Position;
    Entorno.Despliega;
    MarcaTraslapados;
    PortaPapeles.Dibuja;
  end;
end;

procedure TfrmEditorEntornos.ptbEntornoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  XLogica,
  YLogica: Integer;
begin
  if not Assigned(Entorno) then
    Exit; //-->
  XLogica := Entorno.XLogica(X);
  YLogica := Entorno.YLogica(Y);
  Self.X := X;
  Self.Y := Y;
  StatusBar1.Panels[1].Text := ML(mlEO) + ': ' + IntAStr(XLogica, 3);
  StatusBar1.Panels[2].Text := ML(mlNS) + ': ' + IntAStr(YLogica, 3);
  if Marcando then
  begin
    Self.X := Entorno.XFisica(XLogica) + Entorno.CuadroFisico;
    Self.Y := Entorno.YFisica(YLogica) + Entorno.CuadroFisico;
    with PortaPapeles do
    begin
      X2 := XLogica;
      Y2 := YLogica;
      Dibuja;
    end;
    //shpFigura.Width := Abs(X2 - X1);
    //shpFigura.Height := Abs(Y2 - Y1);
   { if X1 < X2 then
      shpFigura.Left := ptbEntorno.Left + X1
    else if X1 > X2 then
      shpFigura.Left := ptbEntorno.Left + X2;
    if Y1 < Y2 then
      shpFigura.Top := ptbEntorno.Top + Y1
    else if Y1 > Y2 then
      shpFigura.Top := ptbEntorno.Top + Y2; }
  end;
end;

procedure TfrmEditorEntornos.ptbEntornoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  XLogica,
  YLogica : Integer;
begin
  if not Assigned(Entorno) then
    Exit; //-->
  XLogica := Entorno.XLogica(X);
  YLogica := Entorno.YLogica(Y);
  if Button = mbRight then
    Exit; //-->
  case Accion of
    acAgentes    : InsertaAgente(XLogica, YLogica);
    acAgua       : InsertaDinamico(elAgua, XLogica, YLogica);
    acAzucar     : InsertaDinamico(elAzucar, XLogica, YLogica);
    acGrasa      : InsertaDinamico(elGrasa, XLogica, YLogica);
    acProteinas  : InsertaDinamico(elProteinas, XLogica, YLogica);
    acOviposicion: InsertaOviposicion(elOviposicion, XLogica, YLogica);
    acHuevo      : InsertaHuevos(XLogica, YLogica);
    acNada:
    begin
      Self.X := Entorno.XFisica(XLogica);
      Self.Y := Entorno.YFisica(YLogica);
      with PortaPapeles do
      begin
        X1 := XLogica;
        X2 := XLogica;
        Y1 := YLogica;
        Y2 := YLogica;
      end;
      {shpFigura.Top := ptbEntorno.Top + Y1;
      shpFigura.Left := ptbEntorno.Left + X1;
      shpFigura.Height := 0;
      shpFigura.Width := 0;}
      Marcando := True;
    end;
  end;
  if Accion <> acNada then
  begin
    Salvado := False;
    actCortar.Enabled := False;
    actCopiar.Enabled := False;
    Entorno.Despliega;
  end;
end;

procedure TfrmEditorEntornos.ptbEntornoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  XLogica,
  YLogica: Integer;
begin
  if not Assigned(Entorno) then
    Exit; //-->
  XLogica := Entorno.XLogica(X);
  YLogica := Entorno.YLogica(Y);
  Self.X := Entorno.XFisica(XLogica);
  Self.Y := Entorno.YFisica(YLogica);
  if not Marcando then
    Exit //-->
  else
  begin
    Marcando := False;
  {if not PortaPapeles.Vacio then
  begin  }
    actCortar.Enabled := True;
    actCopiar.Enabled := True;
  end;
  {end
  else
  begin
    actCortar.Enabled := False;
    actCopiar.Enabled := False;
  end; }
  {if (shpFigura.Height <> 0) and (shpFigura.Width  <> 0) then
  begin
    actCortar.Enabled := True;
    actCopiar.Enabled := True;
  end
  else
  begin
    actCortar.Enabled := False;
    actCopiar.Enabled := False;
  end;
  if Accion <> acNada then
  begin
    shpFigura.Height := 0;
    shpFigura.Width := 0;
  end;}
  Entorno.Despliega;
  PortaPapeles.Dibuja;
end;

procedure TfrmEditorEntornos.actCortarExecute(Sender: TObject);
begin
  PortaPapeles.Corta;
  actCortar.Enabled := False;
  actCopiar.Enabled := False;
  actPegar.Enabled := True;
  Salvado := False;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actCopiarExecute(Sender: TObject);
begin
  PortaPapeles.Copia;
  actCortar.Enabled := False;
  actCopiar.Enabled := False;
  actPegar.Enabled := True;
end;

procedure TfrmEditorEntornos.actPegarExecute(Sender: TObject);
begin
  PortaPapeles.Pega(Entorno.XLogica(X), Entorno.YLogica(Y));
  Salvado := False;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actIncZoomExecute(Sender: TObject);
begin
  Entorno.Porcentaje := Entorno.Porcentaje + 20;
  cmbEscala.ItemIndex := cmbEscala.ItemIndex + 1;
  if Entorno.Porcentaje = 200 then
    actIncZoom.Enabled := False;
  actDecZoom.Enabled := True;
  if Entorno.Porcentaje < 60 then
    Entorno.Cuadricula := False
  else
    Entorno.Cuadricula := True;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actDecZoomExecute(Sender: TObject);
begin
  Entorno.Porcentaje := Entorno.Porcentaje - 20;
  cmbEscala.ItemIndex := cmbEscala.ItemIndex - 1;
  if Entorno.Porcentaje = 20 then
    actDecZoom.Enabled := False;
  actIncZoom.Enabled := True;
  if Entorno.Porcentaje < 60 then
    Entorno.Cuadricula := False
  else
    Entorno.Cuadricula := True;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.cmbEscalaChange(Sender: TObject);
begin
  Entorno.Porcentaje := (cmbEscala.ItemIndex + 1) * 20;
  if Entorno.Porcentaje < 60 then
    Entorno.Cuadricula := False
  else
    Entorno.Cuadricula := True;
  AjustaTamano;
  if Entorno.Porcentaje = 200 then
    actIncZoom.Enabled := False
  else
    actIncZoom.Enabled := True;
  if Entorno.Porcentaje = 20 then
    actDecZoom.Enabled := False
  else
    actDecZoom.Enabled := True;
end;

procedure TfrmEditorEntornos.actPropiedadesExecute(Sender: TObject);
begin
  frmPropiedadesEntorno := TfrmPropiedadesEntorno.Create(Application);
  frmPropiedadesEntorno.ShowModal;
  FreeAndNil(frmPropiedadesEntorno);
end;

procedure TfrmEditorEntornos.R1Click(Sender: TObject);
begin
  NombreArchivo := Copy(R1.Caption, 4, Length(R1.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEntornos.R21Click(Sender: TObject);
begin
  NombreArchivo := Copy(R21.Caption, 4, Length(R21.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEntornos.R31Click(Sender: TObject);
begin
  NombreArchivo := Copy(R31.Caption, 4, Length(R31.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEntornos.R41Click(Sender: TObject);
begin
  NombreArchivo := Copy(R41.Caption, 4, Length(R41.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEntornos.R51Click(Sender: TObject);
begin
  NombreArchivo := Copy(R51.Caption, 4, Length(R51.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEntornos.actAgentesExecute(Sender: TObject);
var
  i        : Integer;
  Resultado: TModalResult;
begin
  frmSeleccionaPrototipo := TfrmSeleccionaPrototipo.Create(Application);
  Resultado := frmSeleccionaPrototipo.ShowModal;
  if (Resultado = mrOK) or
     ((Resultado = mrCancel)
       and (frmSeleccionaPrototipo.NumeroPrototipo <> 0)) then
  begin
    Accion := acAgentes;
    for i := 0 to tlbElementos.ButtonCount - 1 do
      tlbElementos.Buttons[i].Down := False;
    tbtAgentes.Down := True;
    StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': '
                                      + frmSeleccionaPrototipo.NombrePrototipo;
    NumeroPrototipo := frmSeleccionaPrototipo.NumeroPrototipo;
    SexoPrototipo := frmSeleccionaPrototipo.SexoPrototipo;
  end;
  FreeAndNil(frmSeleccionaPrototipo);
end;

procedure TfrmEditorEntornos.actPunteroExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acNada;
  //ElementoActual := '0';
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtApuntador.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ':';
end;

procedure TfrmEditorEntornos.actCerrarExecute(Sender: TObject);
var
  Respuesta : TRespuesta;
begin
  if (Assigned(Entorno)) and (not Salvado) then
  begin
    Respuesta := PreguntaSNC(ML(mlGrdEntCr), ML(mlEdEntGlt));//¿guardar antes?
    if Respuesta = rSi then
      actGuardar.Execute
    else if Respuesta = rCancelar then
      Exit; //-->
  end;
  FreeAndNil(Entorno);
  Self.Caption := ML(mlEdEntGlt);
  ptbEntorno.Visible := False;
  scbHorizontal.Visible := False;
  scbVertical.Visible := False;
  BarraNoEditar;
end;

procedure TfrmEditorEntornos.InsertaDinamico(Tipo: TTipoElemento; PX, PY: Word);
var
  i: Integer;
begin
  with Entorno.ListaDinamicos do
  begin
    i := Agrega(TDinamico.Create{(ptbEntorno)});
    Elementos[i].OnDibuja := DibujaED;
    Elementos[i].X := PX;
    Elementos[i].Y := PY;
    case Tipo of
      elAgua      : Elementos[i].TipoED := edFntAgua;
      elAzucar    : Elementos[i].TipoED := edFntAzucar;
      elGrasa     : Elementos[i].TipoED := edFntGrasa;
      elProteinas : Elementos[i].TipoED := edFntProteina;
    end;  //case
  end;  //with
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX,PY) > 1;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actAguaExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acAgua;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtAgua.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlFntAgua);
end;

procedure TfrmEditorEntornos.actGrasasExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acGrasa;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtGrasa.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlFntGrasa);
end;

procedure TfrmEditorEntornos.actAzucaresExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acAzucar;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtAzucar.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlFntAzucar);
end;

procedure TfrmEditorEntornos.actProteinasExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acProteinas;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtProteina.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlFntPrtn);
end;

procedure TfrmEditorEntornos.EditaElemento(X, Y: Word);
var
  Agentes    : array of TAgente;
  Dinamicos  : array of TDinamico;
  Oviposicion: array of TSitioOviposicion;
  i,
  contA,
  contD,
  contO: Integer;
begin
  with Entorno do
  begin
    contA := NumAgentesEn(X, Y);
    contD := NumDinamicosEn(X, Y);
    contO := NumOviposicionEn(X, Y);
    SetLength(Agentes, contA);
    SetLength(Dinamicos, contD);
    SetLength(Oviposicion, contO);
    ElementosEn(X, Y, Agentes, Dinamicos, Oviposicion);
  end;
  if (contA = 0) and (contD = 0) and (contO = 0) then
  begin //No hay elementos en cuadro
    Fallo(ML(mlNoElmntEdt), ML(mlEdEntGlt));
    Exit; //-->
  end;
  if (contA = 1) and (contD = 0) and (contO = 0) then
  begin //Un solo agente
    if Agentes[0].Acarreados > 0 then  //¿Porta huevos?
    begin
      frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
      SetLength(frmSeleccionarElemento.Agentes, 1);
      frmSeleccionarElemento.Agentes[0] := Agentes[0];
      frmSeleccionarElemento.DespliegaListas;
      frmSeleccionarElemento.ShowModal;
      FreeAndNil(frmSeleccionarElemento);
      Exit; //-->
    end;
    frmEditarAgente := TfrmEditarAgente.Create(Application);
    frmEditarAgente.Agente := Agentes[0];
    frmEditarAgente.DespliegaValores;
    if frmEditarAgente.ShowModal = mrOK then
      Salvado := False;
    FreeAndNil(frmEditarAgente);
    Exit; //-->
  end;
  if (contA = 0) and (contD = 1) and (contO = 0) then
  begin //Un solo elemento dinámico
    frmElementoDinamico := TfrmElementoDinamico.Create(Application);
    frmElementoDinamico.Dinamico := Dinamicos[0];
    frmElementoDinamico.DespliegaValores;
    if frmElementoDinamico.ShowModal = mrOK then
      Salvado := False;
    FreeAndNil(frmElementoDinamico);
    Exit; //-->
  end;
  if (contA = 0) and (contD = 0) and (contO = 1) then
  begin //Un solo sitio de oviposición
    if Oviposicion[0].Nivel > 0 then  //¿Contiene huevos?
    begin
      frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
      SetLength(frmSeleccionarElemento.Oviposicion, 1);
      frmSeleccionarElemento.Oviposicion[0] := Oviposicion[0];
      frmSeleccionarElemento.DespliegaListas;
      frmSeleccionarElemento.ShowModal;
      FreeAndNil(frmSeleccionarElemento);
      Exit; //-->
    end;
    frmSitioOviposicion := TfrmSitioOviposicion.Create(Application);
    frmSitioOviposicion.Oviposicion := Oviposicion[0];
    frmSitioOviposicion.DespliegaValores;
    if frmSitioOviposicion.ShowModal = mrOK then
      Salvado := False;
    FreeAndNil(frmSitioOviposicion);
    Exit; //-->
  end;
  frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
  SetLength(frmSeleccionarElemento.Agentes, contA);
  for i := 1 to contA do
    frmSeleccionarElemento.Agentes[i-1] := Agentes[i-1];
  SetLength(frmSeleccionarElemento.Dinamicos, contD);
  for i := 1 to contD do
    frmSeleccionarElemento.Dinamicos[i-1] := Dinamicos[i-1];
  SetLength(frmSeleccionarElemento.Oviposicion, contO);
  for i := 1 to contO do
    frmSeleccionarElemento.Oviposicion[i-1] := Oviposicion[i-1];
  frmSeleccionarElemento.DespliegaListas;
  frmSeleccionarElemento.ShowModal;
  FreeAndNil(frmSeleccionarElemento);
end;

procedure TfrmEditorEntornos.actEditarElementoExecute(Sender: TObject);
begin
  EditaElemento(Entorno.XLogica(X), Entorno.YLogica(Y));
  Entorno.Despliega;
  MarcaTraslapados;
end;

procedure TfrmEditorEntornos.InsertaAgente(PX, PY: Word);
var
  i, j: Integer;
  Mediador: TMediador;
  MorfoGenCont: array [1..15] of Real;
  MorfoGenDisc: array [1..15] of Integer;
  s: string;
begin
  with Entorno.ListaAgentes do
  begin
    i := Agrega(TAgente.Create{(ptbEntorno)});
    Elementos[i].OnDibuja := DibujaAgnt;
    Elementos[i].X := PX;
    Elementos[i].Y := PY;
    if NumeroPrototipo <= Entorno.Juego.NumEstadios then  //Es inmaduro
    begin
      Elementos[i].Inicializa(Entorno.Juego, Elementos[i].Padre,
          Elementos[i].Madre, NumeroPrototipo,
          Entorno.Juego.Estadios[NumeroPrototipo].Prototipo,
                            0, SexoPrototipo);
      Elementos[i].Color := Entorno.Juego.Estadios[NumeroPrototipo].Color;
    end
    else
    begin
      if NumeroPrototipo <= Entorno.Juego.NumEstadios
                            + Entorno.Juego.NumPrototiposM then //Es macho
      begin
        Elementos[i].Inicializa(Entorno.Juego, Elementos[i].Padre,
            Elementos[i].Madre, Entorno.Juego.NumEstadios + 1,
            NumeroPrototipo - Entorno.Juego.NumEstadios, 0, SexoPrototipo);
        Elementos[i].Color :=
                      Entorno.Juego.PrototiposM[Elementos[i].Prototipo].Color;
      end
      else  //Es hembra
      begin
        Elementos[i].Inicializa(Entorno.Juego, Elementos[i].Padre,
          Elementos[i].Madre, Entorno.Juego.NumEstadios + 1,
          NumeroPrototipo - Entorno.Juego.NumEstadios
          - Entorno.Juego.NumPrototiposM, 0, SexoPrototipo);
        Elementos[i].Color :=
                      Entorno.Juego.PrototiposH[Elementos[i].Prototipo].Color;
      end;
    end;
    for j := 1 to 15 do
    begin
      Elementos[i].Genotipo.PatContinuos[j].Valor :=
                                  Entorno.Juego.LociContinuos[j].Dominante;
      Elementos[i].Genotipo.MatContinuos[j].Valor :=
                                  Entorno.Juego.LociContinuos[j].Dominante;
    end;
    for j := 1 to 15 do
    begin
      Elementos[i].Genotipo.PatDiscretos[j].Valor :=
                                  Entorno.Juego.LociDiscretos[j].Dominante;
      Elementos[i].Genotipo.MatDiscretos[j].Valor :=
                                  Entorno.Juego.LociDiscretos[j].Dominante;
    end;
    Mediador := TMediador.Create(Entorno);
    Mediador.Agente := Elementos[i];
    Elementos[i].Reservas.Agua := Mediador.ValorEntero['InicialAgua'];
    Elementos[i].Reservas.Azucar := Mediador.ValorEntero['InicialAzucar'];
    Elementos[i].Reservas.Grasa := Mediador.ValorEntero['InicialGrasa'];
    Elementos[i].Reservas.Proteina := Mediador.ValorEntero['InicialProteina'];
    //Fijar valores morfológicos congénitos
    if Elementos[i].Adulto then
    begin
       for j := 1 to 15 do
       begin
          s := Entorno.Juego.Continuos[j].Nombre;
          MorfoGenCont[j] := Mediador.ValorReal[s + 'Genetico'];
          s := Entorno.Juego.Discretos[j].Nombre;
          MorfoGenDisc[j] := Mediador.ValorEntero[s + 'Genetico'];
       end;
      Elementos[i].FijaMorfologia(MorfoGenCont, MorfoGenDisc);
    end;
    Mediador.Free;
  end;  //with Entorno.ListaAgentes
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX,PY) > 1;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actEliminarExecute(Sender: TObject);
begin
  EliminaElemento(Entorno.XLogica(X), Entorno.YLogica(Y));
  Entorno.Despliega;
  MarcaTraslapados;
end;

procedure TfrmEditorEntornos.EliminaElemento(X, Y: Word);
var
  Agentes    : array of TAgente;
  Dinamicos  : array of TDinamico;
  Oviposicion: array of TSitioOviposicion;
  i,
  contA,
  contD,
  contO: Integer;
begin
  with Entorno do
  begin
    contA := NumAgentesEn(X, Y);
    contD := NumDinamicosEn(X, Y);
    contO := NumOviposicionEn(X, Y);
    SetLength(Agentes, contA);
    SetLength(Dinamicos, contD);
    SetLength(Oviposicion, contO);
    ElementosEn(X, Y, Agentes, Dinamicos, Oviposicion);
  end;
  if (contA = 0) and (contD = 0) and (contO = 0) then
  begin //No hay elementos en cuadro
    Informa(ML(mlNoElmntEdt), ML(mlEdEntGlt));
    Exit; //-->
  end;
  if (contA = 1) and (contD = 0) and (contO = 0) then
  begin //Un solo agente
    if Agentes[0].Acarreados > 0 then  //¿Porta huevos?
    begin
      frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
      SetLength(frmSeleccionarElemento.Agentes, 1);
      frmSeleccionarElemento.Agentes[0] := Agentes[0];
      frmSeleccionarElemento.Accion := acEliminar;
      frmSeleccionarElemento.DespliegaListas;
      frmSeleccionarElemento.ShowModal;
      FreeAndNil(frmSeleccionarElemento);
      Exit; //-->
    end;
    Entorno.ListaAgentes.Retira(Agentes[0]);
    Salvado := False;
    Exit; //-->
  end;
  if (contA = 0) and (contD = 1) and (contO = 0) then
  begin //Un solo elemento dinámico
    Entorno.ListaDinamicos.Retira(Dinamicos[0]);
    Salvado := False;
    Exit; //-->
  end;
  if (contA = 0) and (contD = 0) and (contO = 1) then
  begin //Un solo sitio de oviposición
  if Oviposicion[0].Nivel > 0 then  //¿Contiene huevos?
    begin
      frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
      SetLength(frmSeleccionarElemento.Oviposicion, 1);
      frmSeleccionarElemento.Oviposicion[0] := Oviposicion[0];
      frmSeleccionarElemento.Accion := acEliminar;
      frmSeleccionarElemento.DespliegaListas;
      frmSeleccionarElemento.ShowModal;
      FreeAndNil(frmSeleccionarElemento);
      Exit; //-->
    end;
    Entorno.ListaOviposicion.Retira(Oviposicion[0]);
    Salvado := False;
    Exit; //-->
  end;
  frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
  SetLength(frmSeleccionarElemento.Agentes, contA);
  for i := 1 to contA do
    frmSeleccionarElemento.Agentes[i-1] := Agentes[i-1];
  SetLength(frmSeleccionarElemento.Dinamicos, contD);
  for i := 1 to contD do
    frmSeleccionarElemento.Dinamicos[i-1] := Dinamicos[i-1];
  SetLength(frmSeleccionarElemento.Oviposicion, contO);
  for i := 1 to contO do
    frmSeleccionarElemento.Oviposicion[i-1] := Oviposicion[i-1];
  frmSeleccionarElemento.DespliegaListas;
  frmSeleccionarElemento.Accion := acEliminar;
  if frmSeleccionarElemento.ShowModal = mrOK then
  begin
    Traslapados[X-1,Y-1] := Entorno.NumAgentesEn(X,Y) > 1;
    Salvado := False;
  end;
  FreeAndNil(frmSeleccionarElemento);
end;

procedure TfrmEditorEntornos.MarcaTraslapados;
var
  i, j: Integer;
begin
  for i := 1 to Entorno.Anchura do
    for j := 1 to Entorno.Altura do
      if Traslapados[i-1,j-1] then
        with ptbEntorno.Canvas do
        begin
          Pen.Color := clWhite;
          Pen.Style := psSolid;
          Brush.Style := bsClear;
          Rectangle(Entorno.XFisica(i), Entorno.YFisica(j),
                    Entorno.XFisica(i) + Entorno.CuadroFisico,
                    Entorno.YFisica(j) + Entorno.CuadroFisico);
        end;
end;

procedure TfrmEditorEntornos.ComparaNombresSustratos(ArchivoEscenario,
  ArchivoAgentes: string);
var
  i: Integer;
  Escenario: TEscenario;
  Agentes  : TJuegoAgentes;
  Bandera  : Boolean;
begin
  Bandera := False;
  Escenario := TEscenario.Create;//(ptbEntorno);
  Escenario.OnDibuja := DibujaEscnr;
  Agentes := TJuegoAgentes.Create;
  Escenario.Carga(ArchivoEscenario);
  Agentes.Carga(ArchivoAgentes);
  for i := 1 to 7 do
    if Escenario.JuegoSustratos.SustratoSimple[i].Nombre <> Agentes.Sustratos[i]
                                                                            then
    begin
      Bandera := True;
      Break; //->
    end;
  if Bandera then
  begin
    Informa(ML(mlNoCncdStrts), ML(mlEdEntGlt));//No coinden nombres de sustratos
    for i := 1 to 7 do
      CambiaNombreVariablePrefijos(Agentes.Sustratos[i],
                            Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
  end;
  FreeAndNil(Escenario);
  FreeAndNil(Agentes);
end;

procedure TfrmEditorEntornos.CambiaNombreVariablePrefijos(De, A: string);
{Actualiza todos los campos que puedan contener fórmulas. Sustituye los
nombres de variables de De a A dentro de todas las fórmulas. Tambien sustituye
las variables cuyo nombre incluya los sufijos en Prefijos}
var
  i, j, k  : Integer;
  s        : string;
  Estadio  : TEstadio;
  Prototipo: TPrototipo;
  Prefijos : array [1..4] of string;
begin
  Prefijos[1] := 'MemoryLastInt';
  Prefijos[2] := 'MemoryNumInt';
  Prefijos[3] := 'MemoryLastPer';
  Prefijos[4] := 'MemoryNumPer';
  with Entorno.Juego do
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
    for i := 1 to 4 do
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
        Prototipo.Continuos[j].ValorGenetico := SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorGenetico, Prefijos);
        Prototipo.Continuos[j].ValorAmbiental := SustituyeConPrefijos
            (De, A, Prototipo.Continuos[j].ValorAmbiental, Prefijos);
        Prototipo.Discretos[j].ValorGenetico := SustituyeConPrefijos
            (De, A, Prototipo.Discretos[j].ValorGenetico, Prefijos);
        Prototipo.Discretos[j].ValorAmbiental := SustituyeConPrefijos
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
            (De, A, Prototipo.Continuos[j].ValorAmbiental, Prefijos);
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

procedure TfrmEditorEntornos.actExportaEscenarioExecute(Sender: TObject);
var
  RutaEscenario : string;
  NombreArchivoEscenario: string;
begin
  RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios)+ Diag;
  if DirectoryExists(RutaEscenario) then
    dlgGuardarEscenario.InitialDir := RutaEscenario
  else
  begin
    if PreguntaSN(ML(mlDrEsNE), ML(mlEdEsGl)) = rSi then //no existe directorio
      begin                       //de escenarios, ¿crearlo?
        CreateDir(RutaEscenario);
        dlgGuardarEscenario.InitialDir := RutaEscenario
      end;
  end;
  dlgGuardarEscenario.FileName := Entorno.Titulo;
  if dlgGuardarEscenario.Execute then
  begin
    NombreArchivoEscenario := dlgGuardarEscenario.FileName;
    if ExtractFileExt(NombreArchivoEscenario) <> '.egl' then
      NombreArchivoEscenario := NombreArchivoEscenario + '.egl';
    Entorno.ExportaEscenario(NombreArchivoEscenario);
  end;
end;

procedure TfrmEditorEntornos.actExportaJuegoExecute(Sender: TObject);
var
  RutaAgentes : string;
  NombreArchivoAgentes: string;
begin
  RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes)+ Diag;
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
  dlgGuardarAgentes.FileName := Entorno.Titulo;
  if dlgGuardarAgentes.Execute then
  begin
    NombreArchivoAgentes := dlgGuardarAgentes.FileName;
    if ExtractFileExt(NombreArchivoAgentes) <> '.agl' then
      NombreArchivoAgentes := NombreArchivoAgentes + '.agl';
    Entorno.ExportaJuego(NombreArchivoAgentes);
  end;
end;

procedure TfrmEditorEntornos.actImportaEscenarioExecute(Sender: TObject);
var
  RutaEscenario: string;
  Escenario: TEscenario;
begin
  RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios)+ Diag;
  if DirectoryExists(RutaEscenario) then
    odlEscenario.InitialDir := RutaEscenario;
  if odlEscenario.Execute then
	begin
    Escenario := TEscenario.Create;
    Escenario.Carga(odlEscenario.FileName);
    if (Escenario.Altura < Entorno.Altura)
                                  or (Escenario.Anchura < Entorno.Anchura) then
      Fallo(ML(mlTmnEscnrMnr), ML(mlEdEntGlt)) //Tamaño de escenario menor
    else
    begin
      Entorno.ImportaEscenario(odlEscenario.FileName);
      Entorno.Cuadricula := True;
      SetLength(Traslapados, Escenario.Anchura, Escenario.Altura);
      AjustaTamano;
      Salvado := False;
    end;
    Escenario.Free;
  end;
end;

procedure TfrmEditorEntornos.actImportaJuegoExecute(Sender: TObject);
var
  Juego: TJuegoAgentes;
  RutaAgentes: string;
begin 
  {frmSeleccionarJuegoAgentes := TfrmSeleccionarJuegoAgentes.Create(Application);
  if (frmSeleccionarJuegoAgentes.ShowModal = mrOK) and
                (frmSeleccionarJuegoAgentes.NombreArchivo<>'') then}
  RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes)+ Diag;
  if DirectoryExists(RutaAgentes) then
    odlAgentes.InitialDir := RutaAgentes;
  if odlAgentes.Execute then
  begin
    Juego := TJuegoAgentes.Create;
    Juego.Carga(odlAgentes.FileName);
    if (Juego.NumEstadios<Entorno.Juego.NumEstadios) or
        (Juego.NumPrototiposM<Entorno.Juego.NumPrototiposM) or
        (Juego.NumPrototiposH<Entorno.Juego.NumPrototiposH) then
      Fallo(ML(mlNmrPrttMnr), ML(mlEdEntGlt))//No coinciden num de prototipos
    else
    begin  
      Entorno.ImportaJuego(odlAgentes.FileName);
      AjustaTamano;
  end;
    Juego.Free;
  end;
end;

procedure TfrmEditorEntornos.actOviposicionExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acOviposicion;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtOviposicion.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlSitOvipo);
end;

procedure TfrmEditorEntornos.InsertaOviposicion(Tipo: TTipoElemento; PX,
  PY: Word);
var
  i: Integer;
begin
  with Entorno.ListaOviposicion do
  begin
    i := Agrega(TSitioOviposicion.Create{(ptbEntorno)});
    Elementos[i].OnDibuja := DibujaED;
    Elementos[i].OnDibuja := DibujaED;
    Elementos[i].X := PX;
    Elementos[i].Y := PY;
  end;  //with
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX,PY) > 1;
  AjustaTamano;
end;

procedure TfrmEditorEntornos.actHuevosExecute(Sender: TObject);
var
  i: Integer;
begin
  Accion := acHuevo;
  for i := 0 to tlbElementos.ButtonCount - 1 do
    tlbElementos.Buttons[i].Down := False;
  tbtHuevo.Down := True;
  StatusBar1.Panels[3].Text := ML(mlElmntActl) + ': ' + ML(mlHuevo);
end;

procedure TfrmEditorEntornos.actCopiarNVecesExecute(Sender: TObject);
begin
  CopiaNVecesElemento(Entorno.XLogica(X), Entorno.YLogica(Y));
end;

procedure TfrmEditorEntornos.CopiaNVecesElemento(X, Y: Word);
var
  Agentes    : array of TAgente;
  Dinamicos  : array of TDinamico;
  Oviposicion: array of TSitioOviposicion;
  Permitidos : array [1..7] of Boolean;
  Mediador   : TMediador;
  Veces,
  Indice,
  i,
  contA,
  contD,
  contO: Integer;
begin
  with Entorno do
  begin
    contA := NumAgentesEn(X, Y);
    contD := NumDinamicosEn(X, Y);
    contO := NumOviposicionEn(X, Y);
    SetLength(Agentes, contA);
    SetLength(Dinamicos, contD);
    SetLength(Oviposicion, contO);
    ElementosEn(X, Y, Agentes, Dinamicos, Oviposicion);
  end;
  if (contA = 0) and (contD = 0) and (contO = 0) then
  begin //No hay elementos en cuadro
    Informa(ML(mlNoElmntEdt), ML(mlEdEntGlt));
    Exit; //-->
  end;
  if (contA = 1) and (contD = 0) and (contO = 0) then
  begin //Un solo agente
    Mediador := TMediador.Create(Entorno);
    Mediador.Agente := Agentes[0];
    frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
    frmCopiarNVeces.NombreElemento := Agentes[0].Nombre
        + '[' + Mediador.NombrePrototipo + ']';
    Mediador.Free;
    if frmCopiarNVeces.ShowModal = mrOK then
    begin
      Veces := frmCopiarNVeces.Veces;
      Indice := Entorno.ListaAgentes.IndiceDe(Agentes[0]);
      for i := 1 to 7 do
        Permitidos[i] := frmCopiarNVeces.Palomeados[i];
      CopiaNVecesAgente(Indice, Veces, Permitidos);
      Salvado := False;
    end;
    FreeAndNil(frmCopiarNVeces);
    AjustaTamano;
    Exit; //-->
  end;
  if (contA = 0) and (contD = 1) and (contO = 0) then
  begin //Un solo elemento dinámico
    frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
    case Dinamicos[0].TipoED of
      edFntAgua : frmCopiarNVeces.NombreElemento := ML(mlFntAgua);
      edFntGrasa : frmCopiarNVeces.NombreElemento := ML(mlFntAzucar);
      edFntAzucar : frmCopiarNVeces.NombreElemento := ML(mlFntGrasa);
      edFntProteina : frmCopiarNVeces.NombreElemento := ML(mlFntPrtn);
    end;
    if frmCopiarNVeces.ShowModal = mrOK then
    begin
      Veces := frmCopiarNVeces.Veces;
      Indice :=  Entorno.ListaDinamicos.IndiceDe(Dinamicos[0]);
      for i := 1 to 7 do
        Permitidos[i] := frmCopiarNVeces.Palomeados[i];
      CopiaNVecesDinamico(Indice, Veces, Permitidos);
      Salvado := False;
    end;
    FreeAndNil(frmCopiarNVeces);
    AjustaTamano;
    Exit; //-->
  end;
  if (contA = 0) and (contD = 0) and (contO = 1) then
  begin //Un solo sitio de oviposición
    frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
    frmCopiarNVeces.NombreElemento := ML(mlSitOvipo);
    if frmCopiarNVeces.ShowModal = mrOK then
    begin
      Veces := frmCopiarNVeces.Veces;
      Indice :=  Entorno.ListaOviposicion.IndiceDe(Oviposicion[0]);
      for i := 1 to 7 do
        Permitidos[i] := frmCopiarNVeces.Palomeados[i];
      CopiaNVecesOviposicion(Indice, Veces, Permitidos);
      Salvado := False;
    end;
    FreeAndNil(frmCopiarNVeces);
    AjustaTamano;
    Exit; //-->}
  end;
  frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
  SetLength(frmSeleccionarElemento.Agentes, contA);
  for i := 1 to contA do
    frmSeleccionarElemento.Agentes[i-1] := Agentes[i-1];
  SetLength(frmSeleccionarElemento.Dinamicos, contD);
  for i := 1 to contD do
    frmSeleccionarElemento.Dinamicos[i-1] := Dinamicos[i-1];
  SetLength(frmSeleccionarElemento.Oviposicion, contO);
  for i := 1 to contO do
    frmSeleccionarElemento.Oviposicion[i-1] := Oviposicion[i-1];
  frmSeleccionarElemento.Accion := acCopiarNveces;
  frmSeleccionarElemento.DespliegaListas;
  frmSeleccionarElemento.ShowModal;
  FreeAndNil(frmSeleccionarElemento);
  AjustaTamano;
end;

procedure TfrmEditorEntornos.CopiaNVecesAgente(Indice, Veces: Word;
Permitidos: array of Boolean);
var
  Coordenadas: array of TCoordenadas;
  Cuadros: array [1..7] of Char;
  Bandera: Boolean; //Indica que el cuadro elegido es permitido
  i, j: Integer;
begin
  for i := 1 to 7 do
    Cuadros[i] := Chr(i + 48);
  SetLength(Coordenadas, Veces);
  for i := 0 to Veces - 1 do
  begin
    repeat
      Bandera := False;
      Coordenadas[i].X := Random(Entorno.Anchura) + 1;
      Coordenadas[i].Y := Random(Entorno.Altura) + 1;
      for j := 1 to 7 do
        if Permitidos[j-1] and
           Entorno.HaySustratoEn(Coordenadas[i].X, Coordenadas[i].Y, Cuadros[j])
              then
            Bandera := True;
    until Bandera;
  end;
  for i := 0 to Veces - 1 do
    CopiaAgente(Indice, Coordenadas[i].X, Coordenadas[i].Y);
end;

function TfrmEditorEntornos.CopiaAgente(Indice, PX, PY: Word): Word;
{Copia el agente cuyo índice sea igual a Indice, el nuevo agente resultado
de la copia se colocará en la posición lógica PX, PY, el valor devuelto es
el índice del nuevo agente}
var
  //i, j,
  Nuevo: Integer;
  //Huevos: array of THuevo;
begin
  Nuevo := Entorno.ListaAgentes.Agrega(TAgente.Create{(ptbEntorno)});
  with Entorno.ListaAgentes do
  begin
    Elementos[Nuevo].OnDibuja := DibujaAgnt;
    Elementos[Nuevo].X := PX;
    Elementos[Nuevo].Y := PY;
    Elementos[Nuevo].Direccion := Elementos[Indice].Direccion;
    Elementos[Nuevo].Inicializa(Entorno.Juego, Elementos[Indice].Padre,
        Elementos[Indice].Madre, Elementos[Indice].Estadio,
        Elementos[Indice].Prototipo, Elementos[Indice].Edad,
        Elementos[Indice].Sexo);
    Elementos[Nuevo].Color := Elementos[Indice].Color;
    Elementos[Nuevo].Genotipo := Elementos[Indice].Genotipo;
    Elementos[Nuevo].Tiempo := Elementos[Indice].Tiempo;
    Elementos[Nuevo].Reservas := Elementos[Indice].Reservas;
    //Elementos[Nuevo].Reproduccion := Elementos[Indice].Reproduccion;
    Elementos[Nuevo].Memoria := Elementos[Indice].Memoria;
   { if Elementos[Indice].Acarreados > 0 then  //¿Porta huevos?
    begin //Copia huevos
      SetLength(Huevos, Elementos[Indice].Reproduccion.Acarreados);
      Entorno.ListaHuevos.HuevosPortador(Elementos[Indice], Huevos);
      for i := 0 to Elementos[Indice].Reproduccion.Acarreados - 1 do
      begin
        j := Entorno.ListaHuevos.Agrega(THuevo.Create(ptbEntorno));
        Entorno.ListaHuevos.Elementos[j].Inicializa(Huevos[i].Padre,
           Huevos[i].Madre, Elementos[Nuevo], Huevos[i].Edad, Huevos[i].Sexo);
        Entorno.ListaHuevos.Elementos[j].Genotipo := Huevos[i].Genotipo;
        Entorno.ListaHuevos.Elementos[j].Reservas := Huevos[i].Reservas;
      end;
    end; }
  end;  //with Entorno.ListaAgentes
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX, PY) > 1;
  Result := Nuevo;
end;

procedure TfrmEditorEntornos.CopiaDinamico(Indice, PX, PY: Word);
var
  Nuevo: Integer;
begin
  Nuevo := Entorno.ListaDinamicos.Agrega(TDinamico.Create{(ptbEntorno)});
  with Entorno.ListaDinamicos do
  begin
    Elementos[Nuevo].OnDibuja := DibujaED;
    Elementos[Nuevo].X := PX;
    Elementos[Nuevo].Y := PY;
    Elementos[Nuevo].TipoED := Elementos[Indice].TipoED;
    Elementos[Nuevo].Calidad := Elementos[Indice].Calidad;
    Elementos[Nuevo].Nivel := Elementos[Indice].Nivel;
    Elementos[Nuevo].Maximo := Elementos[Indice].Maximo;
    Elementos[Nuevo].Tasa := Elementos[Indice].Tasa;
  end;
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX, PY) > 1;
end;

procedure TfrmEditorEntornos.CopiaNVecesDinamico(Indice, Veces: Word;
  Permitidos: array of Boolean);
var
  Coordenadas: array of TCoordenadas;
  Cuadros: array [1..7] of Char;
  Bandera: Boolean; //Indica que el cuadro elegido es permitido
  i, j: Integer;
begin
  for i := 1 to 7 do
    Cuadros[i] := Chr(i + 48);
  SetLength(Coordenadas, Veces);
  for i := 0 to Veces - 1 do
  begin
    repeat
      Bandera := False;
      Coordenadas[i].X := Random(Entorno.Anchura) + 1;
      Coordenadas[i].Y := Random(Entorno.Altura) + 1;
      for j := 1 to 7 do
        if Permitidos[j-1] and
           Entorno.HaySustratoEn(Coordenadas[i].X, Coordenadas[i].Y, Cuadros[j])
              then
            Bandera := True;
    until Bandera;
  end;
  for i := 0 to Veces - 1 do
    CopiaDinamico(Indice, Coordenadas[i].X, Coordenadas[i].Y)
end;

procedure TfrmEditorEntornos.CopiaNVecesOviposicion(Indice, Veces: Word;
  Permitidos: array of Boolean);
 var
  Coordenadas: array of TCoordenadas;
  Cuadros: array [1..7] of Char;
  Bandera: Boolean; //Indica que el cuadro elegido es permitido
  i, j: Integer;
begin
  for i := 1 to 7 do
    Cuadros[i] := Chr(i + 48);
  SetLength(Coordenadas, Veces);
  for i := 0 to Veces - 1 do
  begin
    repeat
      Bandera := False;
      Coordenadas[i].X := Random(Entorno.Anchura) + 1;
      Coordenadas[i].Y := Random(Entorno.Altura) + 1;
      for j := 1 to 7 do
        if Permitidos[j-1] and
           Entorno.HaySustratoEn(Coordenadas[i].X, Coordenadas[i].Y, Cuadros[j])
              then
            Bandera := True;
    until Bandera;
  end;
  for i := 0 to Veces - 1 do
    CopiaOviposicion(Indice, Coordenadas[i].X, Coordenadas[i].Y);
end;

procedure TfrmEditorEntornos.CopiaOviposicion(Indice, PX, PY: Word);
var
  i, j,
  Nuevo: Integer;
  Huevos: array of THuevo;
begin
  Nuevo :=
    Entorno.ListaOviposicion.Agrega(TSitioOviposicion.Create{(ptbEntorno)});
  with Entorno.ListaOviposicion do
  begin
    Elementos[Nuevo].OnDibuja := DibujaED;
    Elementos[Nuevo].X := PX;
    Elementos[Nuevo].Y := PY;
    Elementos[Nuevo].TipoED := Elementos[Indice].TipoED;
    Elementos[Nuevo].Calidad := Elementos[Indice].Calidad;
    Elementos[Nuevo].Nivel := Elementos[Indice].Nivel;
    Elementos[Nuevo].Maximo := Elementos[Indice].Maximo;
    Elementos[Nuevo].Tasa := Elementos[Indice].Tasa;
    if Elementos[Indice].Nivel > 0 then  //¿Contiene huevos?
    begin //Copia huevos
      SetLength(Huevos, Elementos[Indice].Nivel);
      Entorno.ListaHuevos.HuevosPortador(Elementos[Indice], Huevos);
      for i := 0 to Elementos[Indice].Nivel - 1 do
      begin
        j := Entorno.ListaHuevos.Agrega(THuevo.Create{(ptbEntorno)});
        Entorno.ListaHuevos.Elementos[j].Inicializa(Huevos[i].Padre,
           Huevos[i].Madre, Elementos[Nuevo], Huevos[i].Edad, Huevos[i].Sexo);
        Entorno.ListaHuevos.Elementos[j].Genotipo := Huevos[i].Genotipo;
        Entorno.ListaHuevos.Elementos[j].Reservas.Agua :=
            Huevos[i].Reservas.Agua;
        Entorno.ListaHuevos.Elementos[j].Reservas.Azucar :=
            Huevos[i].Reservas.Azucar;
        Entorno.ListaHuevos.Elementos[j].Reservas.Grasa :=
            Huevos[i].Reservas.Grasa;
        Entorno.ListaHuevos.Elementos[j].Reservas.Proteina :=
            Huevos[i].Reservas.Proteina;
      end;
    end;
  end;
  Traslapados[PX-1,PY-1] := Entorno.NumElementosEn(PX, PY) > 1;
end;

procedure TfrmEditorEntornos.InsertaHuevos(PX, PY: Word);
var
  Agentes    : array of TAgente;
  Dinamicos  : array of TDinamico;
  Oviposicion: array of TSitioOviposicion;
  i,
  contA,
  contD,
  contO,
  OmisionTamano: Integer;
begin
  OmisionTamano := ArchivoInicio.ReadInteger('Generales',
      'TamanoOmisionPuesta', 10);
  with Entorno do
  begin
    contA := NumAgentesEn(PX, PY);
    contD := NumDinamicosEn(PX, PY);
    contO := NumOviposicionEn(PX, PY);
    SetLength(Agentes, contA);
    SetLength(Dinamicos, contD);
    SetLength(Oviposicion, contO);
    ElementosEn(PX, PY, Agentes, Dinamicos, Oviposicion);
  end;
  if (contA = 0) and (contO = 0) then
  begin //No hay elementos en cuadro
    Fallo(ML(mlNoElmntOvps), ML(mlEdEntGlt));
    Exit; //-->
  end;
  if (contA = 1) and (contO = 0) then
  begin //Un solo agente
    frmEditarPuesta := TfrmEditarPuesta.Create(Application);
    frmEditarPuesta.Titulo := Agentes[0].Nombre;
    frmEditarPuesta.TamanoOmision := OmisionTamano;
    if frmEditarPuesta.ShowModal = mrOK then
    begin
      CreaPuestaHuevos(frmEditarPuesta.Padre, frmEditarPuesta.Madre,
          Agentes[0], frmEditarPuesta.Edad, frmEditarPuesta.Veces);
    end;
    ArchivoInicio.WriteInteger('Generales', 'TamanoOmisionPuesta',
        frmEditarPuesta.TamanoOmision);
    FreeAndNil(frmEditarPuesta);
    Exit; //-->
  end;
  if (contA = 0) and (contO = 1) then
  begin //Un solo sitio de oviposición
    frmEditarPuesta := TfrmEditarPuesta.Create(Application);
    frmEditarPuesta.TamanoOmision := OmisionTamano;
    frmEditarPuesta.Titulo := Oviposicion[0].Nombre;
    if frmEditarPuesta.ShowModal = mrOK then
    begin
      CreaPuestaHuevos(frmEditarPuesta.Padre, frmEditarPuesta.Madre,
          Oviposicion[0], frmEditarPuesta.Edad, frmEditarPuesta.Veces);
      ArchivoInicio.WriteInteger('Generales', 'TamanoOmisionPuesta',
        frmEditarPuesta.TamanoOmision);
    end;
    FreeAndNil(frmEditarPuesta);
    Exit; //-->
  end;
  frmSeleccionarElemento := TfrmSeleccionarElemento.Create(Application);
  frmEditarPuesta.TamanoOmision := OmisionTamano;
  frmSeleccionarElemento.Accion := acHuevos;
  SetLength(frmSeleccionarElemento.Agentes, contA);
  for i := 1 to contA do
    frmSeleccionarElemento.Agentes[i-1] := Agentes[i-1];
  SetLength(frmSeleccionarElemento.Oviposicion, contO);
  for i := 1 to contO do
    frmSeleccionarElemento.Oviposicion[i-1] := Oviposicion[i-1];
  frmSeleccionarElemento.DespliegaListas;
  frmSeleccionarElemento.ShowModal;
  ArchivoInicio.WriteInteger('Generales', 'TamanoOmisionPuesta',
        frmEditarPuesta.TamanoOmision);
  FreeAndNil(frmSeleccionarElemento);
end;

procedure TfrmEditorEntornos.CreaPuestaHuevos(sPadre, sMadre: string;
  Portador: TElemento; Edad, Cantidad: Word);
var
  i,
  Indice  : Integer;
  Cruzador: TCruzador;
  Mediador: TMediador;
  Sexo    : TSexo;
  Padre,
  Madre   : TAgente;
  Proporciones: TListaV;
  Fraccion: Real;
  Niveles: array [1..4] of Integer; //Niveles iniciales de nutrimentos
begin
  SetLength(Proporciones, 2);
  if sPadre = 'Pigmalion' then
    Padre := Pigmalion
  else
    Padre := Entorno.ListaAgentes.ElementosPorNombre[sPadre];
  if sMadre = 'Galatea' then
    Madre := Galatea
  else
    Madre := Entorno.ListaAgentes.ElementosPorNombre[sMadre];
  if Madre = Galatea then
  begin
    Proporciones[0] := 1;
    Proporciones[1] := 1;
    Niveles[1] := 100;
    Niveles[2] := 100;
    Niveles[3] := 100;
    Niveles[4] := 100;
  end
  else
  begin
    Mediador := TMediador.Create(Entorno);
    Mediador.Agente := Madre;
    Proporciones[0] := Mediador.ValorEntero['ProporcionMachos'];
    Proporciones[1] := Mediador.ValorEntero['ProporcionHembras'];
    Fraccion := Mediador.Valor1_0['FraccionHuevo'];
    Niveles[1] :=
        Round(Mediador.ValorEntero['CostoHuevoAgua'] * (1 - Fraccion));
    Niveles[2] :=
        Round(Mediador.ValorEntero['CostoHuevoAzucar'] * (1 - Fraccion));
    Niveles[3] :=
        Round(Mediador.ValorEntero['CostoHuevoGrasa'] * (1 - Fraccion));
    Niveles[4] :=
        Round(Mediador.ValorEntero['CostoHuevoProteina'] * (1 - Fraccion));
    Mediador.Free;
  end;
  if Portador is TSitioOviposicion then
    if ((Portador as TSitioOviposicion).Nivel + Cantidad)
        > (Portador as TSitioOviposicion).Maximo then
    begin
      Fallo(ML(mlNvlMxHvs), ML(mlEdEntGlt));
      Exit; //-->
    end;
  Cruzador := TCruzador.Create(Entorno.Juego, Padre.Genotipo, Madre.Genotipo);
  with Entorno.ListaHuevos do
  begin
    for i := 1 to Cantidad do
    begin
      Indice := Agrega(THuevo.Create{(ptbEntorno)});
      if Ruleta(Proporciones) = 1 then
        Sexo := sxMacho
      else
        Sexo := sxHembra;
      Elementos[Indice].Inicializa(sPadre, sMadre, Portador, Edad,
      Sexo);
      Elementos[Indice].Genotipo := Cruzador.Genotipo;
      Elementos[Indice].Reservas.Agua := Niveles[1];
      Elementos[Indice].Reservas.Azucar := Niveles[2];
      Elementos[Indice].Reservas.Grasa := Niveles[3];
      Elementos[Indice].Reservas.Proteina := Niveles[4];
      {if Portador is TAgente then
        Inc((Portador as TAgente).Acarreados)
      else
        (Portador as TSitioOviposicion).Nivel :=
            (Portador as TSitioOviposicion).Nivel + 1;}
    end; 
  end;
  Cruzador.Free;
end;

procedure TfrmEditorEntornos.CrearPigmalionGalatea;
var
  i: Integer;
begin
  if Assigned(Pigmalion) then
    FreeAndNil(Pigmalion);
  if Assigned(Galatea) then
    FreeAndNil(Galatea);
  Pigmalion := TAgente.Create;//(ptbEntorno);
  Pigmalion.OnDibuja := DibujaAgnt;
  Galatea := TAgente.Create;//(ptbEntorno);
  Galatea.OnDibuja := DibujaAgnt;
  with Entorno.Juego do
  begin
    for i := 1 to 15 do
    begin
      Pigmalion.Genotipo.PatContinuos[i].Valor := LociContinuos[i].Dominante;
      Pigmalion.Genotipo.MatContinuos[i].Valor := LociContinuos[i].Dominante;
      Pigmalion.Genotipo.PatDiscretos[i].Valor := LociDiscretos[i].Dominante;
      Pigmalion.Genotipo.MatDiscretos[i].Valor := LociDiscretos[i].Dominante;
    end;
    Galatea.Genotipo := Pigmalion.Genotipo;
    Pigmalion.Inicializa(Entorno.Juego, 'Pigmalion', 'Galatea', NumEstadios + 1,
        0, 0, sxMacho);
    Galatea.Inicializa(Entorno.Juego, 'Pigmalion', 'Galatea', NumEstadios + 1,
        0, 0, sxHembra);
  end;
end;

{ TPortaPapeles }

procedure TPortaPapeles.Carga;
var
  OrigenX,
  OrigenY: Integer;
begin
  if X1 < X2 then
    OrigenX := X1
  else
    OrigenX := X2;
  if Y1 < Y2 then
    OrigenY := Y1
  else
    OrigenY := Y2;
  with frmEditorEntornos.Entorno do
  begin
    SetLength(Agentes, NumAgentesEn(OrigenX, OrigenY, OrigenX + Self.Anchura,
        OrigenY + Self.Altura));
    SetLength(Dinamicos, NumDinamicosEn(OrigenX, OrigenY,
        OrigenX + Self.Anchura, OrigenY + Self.Altura));
    SetLength(Oviposicion, NumOviposicionEn(OrigenX, OrigenY,
        OrigenX + Self.Anchura, OrigenY + Self.Altura));
    SetLength(Agentes, NumAgentesEn(OrigenX, OrigenY, OrigenX + Self.Anchura,
        OrigenY + Self.Altura));
    ElementosEn(OrigenX, OrigenY, OrigenX + Self.Anchura, OrigenY + Self.Altura,
        Agentes, Dinamicos, Oviposicion);
  end;
end;  //proc TPortaPapeles.Carga

procedure TPortaPapeles.Copia;
begin
  Carga;
  Cortado := False;
end;

procedure TPortaPapeles.Corta;
begin
  Carga;
  Cortado := True;
end;

constructor TPortaPapeles.Create;
begin
  X1 := 0;
  X2 := 0;
  Y1 := 0;
  Y2 := 0;
  Cortado := False;
end;

procedure TPortaPapeles.Dibuja;
begin
  with frmEditorEntornos.ptbEntorno.Canvas do
  begin
    Pen.Style := psDash;
    Pen.Color := clWhite;
    Brush.Style := bsClear;
  end;
  with frmEditorEntornos.Entorno do
  begin
    frmEditorEntornos.ptbEntorno.Canvas.Rectangle(XFisica(X1), YFisica(Y1),
              XFisica(X2), YFisica(Y2));
  end;
end;

function TPortaPapeles.GetAltura: Word;
begin
  Result := Abs(Y1 - Y2);
end;

function TPortaPapeles.GetAnchura: Word;
begin
  Result := Abs(X1 - X2);
end;

function TPortaPapeles.NuevaX(Xref, Xelemento: Word): Word;
begin
  if Xref + (Xelemento - X1) < frmEditorEntornos.Entorno.Anchura then
    Result := Xref + (Xelemento - X1)
  else
    Result := frmEditorEntornos.Entorno.Anchura;
end;

function TPortaPapeles.NuevaY(Yref, Yelemento: Word): Word;
begin
  if Yref + (Yelemento - Y1) < frmEditorEntornos.Entorno.Altura then
    Result := Yref + (Yelemento - Y1)
  else
    Result := frmEditorEntornos.Entorno.Altura;
end;

procedure TPortaPapeles.Pega(X, Y: Word);
var
  Indice,
  Nuevo,
  i: Integer;
  XNueva,
  YNueva: Word;
  Nombre: string;
begin
  with frmEditorEntornos.Entorno do
  begin
    for i := 0 to Length(Agentes) - 1 do
    begin
      Indice := ListaAgentes.IndiceDe(Agentes[i]);
      XNueva := NuevaX(X, Agentes[i].X);
      YNueva := NuevaY(Y, Agentes[i].Y);
      Nuevo := frmEditorEntornos.CopiaAgente(Indice, XNueva, YNueva);
      if Cortado then
      begin
        Nombre := Agentes[i].Nombre;
        ListaAgentes.Elementos[Nuevo].Nombre := Nombre;
        frmEditorEntornos.actPegar.Enabled := False;
        ListaAgentes.Retira(Agentes[i]);
      end;
    end;
    Despliega;
  end;
  Cortado := False;
end;

function TPortaPapeles.Vacio: Boolean;
begin
  Result := (Length(Agentes) = 0) and (Length(Dinamicos) = 0)
      and (Length(Oviposicion) = 0);
end;

procedure TfrmEditorEntornos.DibujaEscnr(Sender: TObject);
begin
  DibujaEscenario(Sender as TEscenario);
end;

procedure TfrmEditorEntornos.DibujaED(Sender: TObject;
  XFisica, YFisica, CuadroFisico: Word);
begin
  DibujaElementoDinamico(Sender as TDinamico, XFisica, YFisica, CuadroFisico);
end;

procedure TfrmEditorEntornos.DibujaAgnt(Sender: TObject; XFisica, YFisica,
  CuadroFisico: Word);
begin
  DibujaAgente(Sender as TAgente, XFisica, YFisica, CuadroFisico);
end;

initialization
  {$i EditorEntornos.lrs}

end.
