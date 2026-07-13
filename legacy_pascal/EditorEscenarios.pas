unit EditorEscenarios;

{$MODE Delphi}

{*******************************************************************************
Formulario principal del Editor de Escenarios Galatea
Proyecto: EdEsGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, {AppEvnts,} ComCtrls, StdCtrls,
  ExtCtrls, IniFiles, {ShlObj,} Comunes, Dialogos, Escenarios, NuevoEscenario,
  PropiedadesEscenario, SeleccionarMixto, VerSustrato, AcercaEdEs, ExtDlgs,
  {XPMan,} Dibujo, LResources;

type
  TAccion = (ac1Punto, ac5Puntos, ac13Puntos, ac41Puntos, ac145Puntos,
            acRectangulo, acRectanguloRelleno, acNada);
  //Acciones de dibujo

  { TfrmEditorEscenarios }

  TfrmEditorEscenarios = class(TForm)
    aclPrincipal: TActionList;
    actAbrir: TAction;
    actGuardar: TAction;
    actGuardarComo: TAction;
    actCerrar: TAction;
    actSalir: TAction;
    actCortar: TAction;
    actCopiar: TAction;
    actPegar: TAction;
    actIncZoom: TAction;
    actDecZoom: TAction;
    actAyuda: TAction;
    actNuevo: TAction;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Nuevo1: TMenuItem;
    Abrir1: TMenuItem;
    Guardar1: TMenuItem;
    Guardarcomo1: TMenuItem;
    Cerrar1: TMenuItem;
    dlgAbrirSuatratos: TOpenDialog;
    R1: TMenuItem;
    R21: TMenuItem;
    R31: TMenuItem;
    R41: TMenuItem;
    R51: TMenuItem;
    N2: TMenuItem;
    Salir1: TMenuItem;
    Edicion1: TMenuItem;
    Cortar1: TMenuItem;
    Copiar1: TMenuItem;
    Pegar1: TMenuItem;
    Ver1: TMenuItem;
    AumentarZoom1: TMenuItem;
    DisminuirZoom1: TMenuItem;
    Ayuda1: TMenuItem;
    Contenido1: TMenuItem;
    StatusBar1: TStatusBar;
    //ApplicationEvents1: TApplicationEvents;
    dlgAbrirEscenario: TOpenDialog;
    dlgGuardarEscenario: TSaveDialog;
    imlPrincipal: TImageList;
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
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    cmbEscala: TComboBox;
    tlbDibujo: TToolBar;
    tbt1Punto: TToolButton;
    tbt5Puntos: TToolButton;
    tbt13Puntos: TToolButton;
    tbt41Puntos: TToolButton;
    tbt145Puntos: TToolButton;
    tlbSustratos: TToolBar;
    scbHorizontal: TScrollBar;
    scbVertical: TScrollBar;
    aclDibujo: TActionList;
    imlDibujo: TImageList;
    act1Punto: TAction;
    act5Puntos: TAction;
    act13Punto: TAction;
    act41Puntos: TAction;
    act145Puntos: TAction;
    ToolButton29: TToolButton;
    imlSustrato: TImageList;
    actRectangulo: TAction;
    ToolButton28: TToolButton;
    tbtRectangulo: TToolButton;
    ToolButton32: TToolButton;
    tbtMixto: TToolButton;
    PropiedadesdelEscenario1: TMenuItem;
    actPropiedades: TAction;
    actPuntero: TAction;
    tbtPuntero: TToolButton;
    ToolButton27: TToolButton;
    actRectanguloRelleno: TAction;
    tbtRectanguloRelleno: TToolButton;
    actAccercade: TAction;
    actAccercade1: TMenuItem;
    Sustrato1: TMenuItem;
    actVerSustrato: TAction;
    Seleccionarsustratomixto1: TMenuItem;
    Monitorearsustrato1: TMenuItem;
    actSustrato: TActionList;
    actSustrato1: TAction;
    actSustrato2: TAction;
    actSustrato3: TAction;
    actSustrato4: TAction;
    actSustrato5: TAction;
    actSustrato6: TAction;
    actSustrato7: TAction;
    actMixto: TAction;
    actGuardarJuego: TAction;
    N4: TMenuItem;
    Savesetofsubstrata1: TMenuItem;
    dlgGuardarJuego: TSaveDialog;
    actObtenerJuego: TAction;
    Loadsetofsubstrata1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Options1: TMenuItem;
    actPantalla: TAction;
    N3: TMenuItem;
    N5: TMenuItem;
    Fullscreen1: TMenuItem;
    ToolButton16: TToolButton;
    ptbEscenario: TPaintBox;
    //XPManifest1: TXPManifest;
    ToolButton17: TToolButton;
    btnSustrato1: TButton;
    btnSustrato2: TButton;
    btnSustrato3: TButton;
    btnSustrato4: TButton;
    btnSustrato5: TButton;
    btnSustrato6: TButton;
    btnSustrato7: TButton;
    shpSustrato: TShape;
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure actSalirExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure actGuardarComoExecute(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure scbVerticalChange(Sender: TObject);
    procedure scbHorizontalChange(Sender: TObject);
    procedure cmbEscalaChange(Sender: TObject);
    procedure actIncZoomExecute(Sender: TObject);
    procedure actDecZoomExecute(Sender: TObject);
    procedure actMixtoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actNuevoExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCerrarExecute(Sender: TObject);
    procedure actGuardarExecute(Sender: TObject);
    procedure actPropiedadesExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ptbEscenarioMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure act1PuntoExecute(Sender: TObject);
    procedure actPunteroExecute(Sender: TObject);
    procedure ptbEscenarioMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure R1Click(Sender: TObject);
    procedure R21Click(Sender: TObject);
    procedure R31Click(Sender: TObject);
    procedure R41Click(Sender: TObject);
    procedure R51Click(Sender: TObject);
    procedure act5PuntosExecute(Sender: TObject);
    procedure act13PuntoExecute(Sender: TObject);
    procedure act41PuntosExecute(Sender: TObject);
    procedure act145PuntosExecute(Sender: TObject);
    procedure actRectanguloExecute(Sender: TObject);
    procedure actRectanguloRellenoExecute(Sender: TObject);
    procedure ptbEscenarioMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actCortarExecute(Sender: TObject);
    procedure actCopiarExecute(Sender: TObject);
    procedure actPegarExecute(Sender: TObject);
    procedure actVerSustratoExecute(Sender: TObject);
    procedure actAccercadeExecute(Sender: TObject);
    procedure actObtenerJuegoExecute(Sender: TObject);
    procedure actGuardarJuegoExecute(Sender: TObject);
    procedure sbxEscenarioConstrainedResize(Sender: TObject; var MinWidth,
      MinHeight, MaxWidth, MaxHeight: Integer);
    procedure actPantallaExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure btnSustrato1Click(Sender: TObject);
    procedure btnSustrato2Click(Sender: TObject);
    procedure btnSustrato3Click(Sender: TObject);
    procedure btnSustrato4Click(Sender: TObject);
    procedure btnSustrato5Click(Sender: TObject);
    procedure btnSustrato6Click(Sender: TObject);
    procedure btnSustrato7Click(Sender: TObject);
  private
    { Private declarations }
    NombreArchivo: string; //Archivo del escenario actual
    ArchivoInicio: TIniFile;
    Accion: TAccion;
    SustratoActual: TCuadro;
    Trazando: Boolean;
    //Determina si actualmente está activa una acción de dibujo
    X1, X2,
    Y1, Y2: Integer;
    //Coordenadas absolutas actuales de elementos trazados
    //X1 y Y1 se actualizan cada vez que se hace clic sobre el escenario
    Marco: TMarco;  //Marco de zona marcada
    PortaPapeles: array of array of TCuadro;
    AltoPortapapeles,
    AnchoPortapapeles: Integer;
    function VerificaSalvado: Boolean;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure AjustaTamano;
    procedure BarraNoEditar;
    procedure BarraTotal;
    procedure GuardaReciente(PNombreArchivo: string);
    procedure ActualizaMenuRecientes;
    procedure Dibuja5Puntos(X, Y: Integer);
    procedure Dibuja13Puntos(X, Y: Integer);
    procedure Dibuja41Puntos(X, Y: Integer);
    procedure Dibuja145Puntos(X, Y: Integer);
    procedure ActualizaBarraSustratos;
    procedure Dibuja(Sender: TObject);
  public
    { Public declarations }
    Salvado: Boolean;
    //Determina si el archivo ha sido guardado desde la última modificación
    SustratoBase: TCuadro;
    Escenario : TEscenario;
  end;

var
  frmEditorEscenarios: TfrmEditorEscenarios;

implementation


uses
  Sustratos, Multilenguaje, SeleccionaJuego, PantallaEscenario;

function TfrmEditorEscenarios.VerificaSalvado: Boolean;
{Verifica si el archivo ha sido guardado desde la última modificación, si el
archivo no ha sido guardado pregunta al usuario si desea guardarlo
Regresa False si el usuario cancela la acción de cerrar archivo}
var
  Respuesta: TRespuesta;
begin
  Result := True;
  if Assigned(Escenario) then
  begin
    if not Salvado then
    begin
      Respuesta := PreguntaSNC(ML(mlGrdEsCr), ML(mlEdEsGl));
      case Respuesta of
        rSi : actGuardar.Execute;
        rNo : Salvado := True;
        rCancelar:
        begin
          Result := False;
          Exit; //-->
        end;
      end;
    end;
    actCerrar.Execute;
  end;
end;

procedure TfrmEditorEscenarios.FormCreate(Sender: TObject);
var
  EstadoVentana,
  Idioma: string;
begin
  {Candado de seguridad
  if not Llave('galatea', '') then
  begin
    Fallo('Ilegal copy / copia ilegal', 'Galatea');
    Halt; //--->
  end;     }
  {Candado de seguridad}
  Plataforma := ptbEscenario.Canvas;
  BarraNoEditar;
  ArchivoInicio := TIniFile.Create('.galatea.ini');
  Idioma := ArchivoInicio.ReadString('Generales', 'Idioma', 'English');
  if Idioma = 'English' then
    Lenguaje := lEnglish
  else if Idioma = 'Spanish' then
    Lenguaje := lEspanol;
  Accion := acNada;
  Trazando := False;
  Marco.X1 := 0;
  Marco.Y1 := 0;
  Marco.X2 := 0;
  Marco.Y2 := 0;
  ActualizaMenuRecientes;
  EstadoVentana := ArchivoInicio.ReadString('Ventanas', 'EditorEscenarios',
      'Normal');
  if EstadoVentana = 'Maximizada' then
    WindowState := wsMaximized
  else
    WindowState := wsNormal;
  if ParamCount <> 0 then
  begin
    NombreArchivo := ParamStr(1);
    if ExtractFileExt(NombreArchivo) = '.egl' then
      AbreArchivo(NombreArchivo)
    else            //Extensión de archivo no corresponde
      Fallo(ML(mlErrExtNCEE), ML(mlEdEsGl));
  end;
end;

procedure TfrmEditorEscenarios.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := VerificaSalvado;
end;

procedure TfrmEditorEscenarios.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrmEditorEscenarios.actSalirExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmEditorEscenarios.scbVerticalChange(Sender: TObject);
begin
  if scbVertical.Position <= (Escenario.AlturaFisica
                              -  ptbEscenario.Height) then
  begin
   Escenario.DesplazamientoY := scbVertical.Position;
   Escenario.Despliega;
   with ptbEscenario.Canvas do
    begin                //Dibujar rectángulo de marcado
      Pen.Style := psDash;
      Pen.Color := clWhite;
      Brush.Style := bsClear;
      Rectangle(Escenario.XFisica(Marco.X1), Escenario.YFisica(Marco.Y1),
                Escenario.XFisica(Marco.X2), Escenario.YFisica(Marco.Y2));
    end;
  end;
end;

procedure TfrmEditorEscenarios.scbHorizontalChange(Sender: TObject);
begin
  if scbHorizontal.Position <= (Escenario.AnchuraFisica
                                - ptbEscenario.Width) then
  begin
    Escenario.DesplazamientoX := scbHorizontal.Position;
    Escenario.Despliega;
    with ptbEscenario.Canvas do
    begin                //Dibujar rectángulo de marcado
      Pen.Style := psDash;
      Pen.Color := clWhite;
      Brush.Style := bsClear;
      Rectangle(Escenario.XFisica(Marco.X1), Escenario.YFisica(Marco.Y1),
                Escenario.XFisica(Marco.X2), Escenario.YFisica(Marco.Y2));
    end;
  end;
end;

procedure TfrmEditorEscenarios.cmbEscalaChange(Sender: TObject);
begin
  Escenario.Porcentaje := (cmbEscala.ItemIndex + 1) * 20;
  if Escenario.Porcentaje < 60 then
    Escenario.Cuadricula := False
  else
    Escenario.Cuadricula := True;
  AjustaTamano;
  if Escenario.Porcentaje = 200 then
    actIncZoom.Enabled := False
  else
    actIncZoom.Enabled := True;
  if Escenario.Porcentaje = 20 then
    actDecZoom.Enabled := False
  else
    actDecZoom.Enabled := True;
end;

procedure TfrmEditorEscenarios.actAbrirExecute(Sender: TObject);
var
  RutaEscenario : string;
  Respuesta     : TRespuesta;
begin
  if not VerificaSalvado then
    Exit; //-->
  RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios) + Diag;
  if DirectoryExists(RutaEscenario) then
    dlgAbrirEscenario.InitialDir := RutaEscenario
  else
  begin
    Respuesta := PreguntaSN(ML(mlDrEsNE), ML(mlEdEsGl));//no existe directorio
    if  Respuesta = rSI then            //de escenarios ¿crearlo?
      begin
        //CreateDirectory(PChar(RutaEscenario), nil);
        CreateDir(RutaEscenario);
        dlgAbrirEscenario.InitialDir := RutaEscenario
      end;
  end;
  if dlgAbrirEscenario.Execute then
  begin
    NombreArchivo := dlgAbrirEscenario.FileName;
    AbreArchivo(NombreArchivo);
  end;
end;

procedure TfrmEditorEscenarios.actGuardarComoExecute(Sender: TObject);
var
  RutaEscenario : string;
begin
  RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios)+ Diag;
  RutaEscenario :=
      ArchivoInicio.ReadString('Directorios', 'Escenarios', RutaEscenario);
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
  dlgGuardarEscenario.FileName := Escenario.Titulo;
  if dlgGuardarEscenario.Execute then
  begin
    NombreArchivo := dlgGuardarEscenario.FileName;
    if ExtractFileExt(NombreArchivo) <> '.egl' then
      NombreArchivo := NombreArchivo + '.egl';
    Self.Caption := ML(mlEdEsGl) + ' [' + NombreArchivo + ']';
    Escenario.Guarda(NombreArchivo);
    GuardaReciente(NombreArchivo);
    Salvado := True;
    RutaEscenario := ExtractFilePath(dlgGuardarEscenario.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
      ArchivoInicio.WriteString('Directorios', 'Escenarios', RutaEscenario);
  end;
end;

procedure TfrmEditorEscenarios.FormWindowStateChange(Sender: TObject);
begin
  if (WindowState =  wsMaximized) and (Assigned(Escenario)) then
  	AjustaTamano;
end;
 
procedure TfrmEditorEscenarios.ActualizaBarraSustratos;
begin
  with Escenario.JuegoSustratos do
  begin
    btnSustrato1.Caption := SustratoSimple[1].Nombre;
    btnSustrato1.Hint := SustratoSimple[1].Nombre;
    btnSustrato2.Caption := SustratoSimple[2].Nombre;
    btnSustrato2.Hint := SustratoSimple[2].Nombre;
    btnSustrato3.Caption := SustratoSimple[3].Nombre;
    btnSustrato3.Hint := SustratoSimple[3].Nombre;
    btnSustrato4.Caption := SustratoSimple[4].Nombre;
    btnSustrato4.Hint := SustratoSimple[4].Nombre;
    btnSustrato5.Caption := SustratoSimple[5].Nombre;
    btnSustrato5.Hint := SustratoSimple[5].Nombre;
    btnSustrato6.Caption := SustratoSimple[6].Nombre;
    btnSustrato6.Hint := SustratoSimple[6].Nombre;
    btnSustrato7.Caption := SustratoSimple[7].Nombre;
    btnSustrato7.Hint := SustratoSimple[7].Nombre;
  end;
end;

procedure TfrmEditorEscenarios.actNuevoExecute(Sender: TObject);
begin
  if not VerificaSalvado then
    Exit; //-->
  frmNuevoEscenario := TfrmNuevoEscenario.Create(Self);
  if frmNuevoEscenario.ShowModal <> mrOk then
  begin
    FreeAndNil(frmNuevoEscenario);
    Exit; //-->
  end
  else
  begin
    Escenario := TEscenario.Create;//(ptbEscenario);
    Escenario.OnDibuja :=  Dibuja;
    frmNuevoEscenario.ExportaValores;
  end;
  FreeAndNil(frmNuevoEscenario);
  Salvado := True;
  Escenario.Rellena(SustratoBase);
  Escenario.Cuadricula := True;
  cmbEscala.ItemIndex := 4;
  ActualizaBarraSustratos;
  ptbEscenario.Visible := True;
  AjustaTamano;
  Salvado := False;
  NombreArchivo := ML(mlEscenario);
  Self.Caption := ML(mlEdEsGl) + ' [' + NombreArchivo + ']';
  actPuntero.Execute;
  BarraTotal;
end;


procedure TfrmEditorEscenarios.actCerrarExecute(Sender: TObject);
var
  Respuesta : TRespuesta;
begin
  if (Assigned(Escenario)) and (not Salvado) then
  begin
    Respuesta := PreguntaSNC(ML(mlGrdEsCr), ML(mlEdEsGl));//¿guardar antes?
    if Respuesta = rSi then
      actGuardar.Execute
    else if Respuesta = rCancelar then
      Exit; //-->
  end;
  FreeAndNil(Escenario);
  Self.Caption := ML(mlEdEsGl);
  ptbEscenario.Visible := False;
  scbHorizontal.Visible := False;
  scbVertical.Visible := False;
  BarraNoEditar;
end;

procedure TfrmEditorEscenarios.actGuardarExecute(Sender: TObject);
begin
  if NombreArchivo = ML(mlEscenario) then
    actGuardarComo.Execute
  else
  begin
    Escenario.Guarda(NombreArchivo);
    Salvado := True;
  end;
end;

procedure TfrmEditorEscenarios.AjustaTamano;
{Comprueba los tamaños físicos y lógicos del escenario, mantiene la relación
entre tamaños y escalas con el escenario físico, las barras de desplazamiento
y las acciones de aumentar y disminuir zoom}
begin
  with ptbEscenario do
  begin
    if Escenario.AlturaFisica > tlbDibujo.Height - scbHorizontal.Height then
    begin
      //Height := tlbDibujo.Height - scbHorizontal.Height;
      scbVertical.Visible := True;
    end
    else
    begin
      //Height := Escenario.AnchuraFisica;
      scbVertical.Visible := False;
    end;
    if Escenario.AnchuraFisica
        > tlbPrincipal.Width - (tlbDibujo.Width + scbVertical.Width) then
    begin
      //Width := tlbPrincipal.Width - (tlbDibujo.Width + scbVertical.Width);
      scbHorizontal.Visible := True;
    end
    else
    begin
      //Width := Escenario.AnchuraFisica;
      scbHorizontal.Visible := False;
    end;
    if scbHorizontal.Visible then
    begin
      scbHorizontal.Top := Top + Height;
      scbHorizontal.Width := Width;
      scbHorizontal.Max := Escenario.AnchuraFisica;
      scbHorizontal.PageSize := Width;
    end;
    if scbHorizontal.Position > (Escenario.AnchuraFisica - Width) then
        scbHorizontal.Position := Escenario.AnchuraFisica - Width;
    if scbVertical.Visible then
    begin
      scbVertical.Left := Left + Width;
      scbVertical.Height := Height;
      scbVertical.Max := Escenario.AlturaFisica;
      scbVertical.PageSize := Height;
    end;
    if scbVertical.Position > (Escenario.AlturaFisica - Height) then
        scbVertical.Position := Escenario.AlturaFisica - Height;
  end; //with
  Escenario.Despliega;
  if Accion = acNada then
  begin
    with ptbEscenario.Canvas do
    begin                //Dibujar rectángulo de marcado
      Pen.Style := psDash;
      Pen.Color := clWhite;
      Brush.Style := bsClear;
      Rectangle(Escenario.XFisica(Marco.X1), Escenario.YFisica(Marco.Y1),
                Escenario.XFisica(Marco.X2), Escenario.YFisica(Marco.Y2));
    end;
   // shpFigura.Repaint;
  end;
end;

procedure TfrmEditorEscenarios.AbreArchivo(PNombreArchivo: string);
begin
  if not VerificaSalvado then
    Exit; //-->
  if not FileExists(PNombreArchivo) then
  begin                                               //no existe el archivo
    Fallo(ML(mlErrArchvNE) + ': ' + PNombreArchivo, ML(mlEdEsGl));
    Exit; //-->
  end;
  NombreArchivo := PNombreArchivo;
  GuardaReciente(NombreArchivo);
  Self.Caption := ML(mlEdEsGl) + ' [' + NombreArchivo + ']';
  Salvado := True;
  Escenario := TEscenario.Create;//(ptbEscenario);
  Escenario.OnDibuja :=  Dibuja;
  Escenario.Carga(NombreArchivo);
  Escenario.Cuadricula := True;
  cmbEscala.ItemIndex := 4;
  with Escenario.JuegoSustratos do
  begin
    btnSustrato1.Caption := SustratoSimple[1].Nombre;
    btnSustrato1.Hint := SustratoSimple[1].Nombre;
    btnSustrato2.Caption := SustratoSimple[2].Nombre;
    btnSustrato2.Hint := SustratoSimple[2].Nombre;
    btnSustrato3.Caption := SustratoSimple[3].Nombre;
    btnSustrato3.Hint := SustratoSimple[3].Nombre;
    btnSustrato4.Caption := SustratoSimple[4].Nombre;
    btnSustrato4.Hint := SustratoSimple[4].Nombre;
    btnSustrato5.Caption := SustratoSimple[5].Nombre;
    btnSustrato5.Hint := SustratoSimple[5].Nombre;
    btnSustrato6.Caption := SustratoSimple[6].Nombre;
    btnSustrato6.Hint := SustratoSimple[6].Nombre;
    btnSustrato7.Caption := SustratoSimple[7].Nombre;
    btnSustrato7.Hint := SustratoSimple[7].Nombre;
  end;
  ptbEscenario.Visible := True;
  AjustaTamano;
  actPuntero.Execute;
  BarraTotal;
end;

procedure TfrmEditorEscenarios.R1Click(Sender: TObject);
begin
  NombreArchivo := Copy(R1.Caption, 4, Length(R1.Caption) - 2);
  AbreArchivo(NombreArchivo);
end;

procedure TfrmEditorEscenarios.R21Click(Sender: TObject);
begin
  NombreArchivo := Copy(R21.Caption, 4, Length(R21.Caption) - 2);
  AbreArchivo(NombreArchivo)
end;

procedure TfrmEditorEscenarios.R31Click(Sender: TObject);
begin
  NombreArchivo := Copy(R31.Caption, 4, Length(R31.Caption) - 2);
  AbreArchivo(NombreArchivo)
end;

procedure TfrmEditorEscenarios.R41Click(Sender: TObject);
begin
  NombreArchivo := Copy(R41.Caption, 4, Length(R41.Caption) - 2);
  AbreArchivo(NombreArchivo)
end;

procedure TfrmEditorEscenarios.R51Click(Sender: TObject);
begin
  NombreArchivo := Copy(R51.Caption, 4, Length(R51.Caption) - 2);
  AbreArchivo(NombreArchivo)
end;

procedure TfrmEditorEscenarios.actIncZoomExecute(Sender: TObject);
begin
  Escenario.Porcentaje := Escenario.Porcentaje + 20;
  cmbEscala.ItemIndex := cmbEscala.ItemIndex + 1;
  if Escenario.Porcentaje = 200 then
    actIncZoom.Enabled := False;
  actDecZoom.Enabled := True;
  if Escenario.Porcentaje < 60 then
    Escenario.Cuadricula := False
  else
    Escenario.Cuadricula := True;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.actDecZoomExecute(Sender: TObject);
begin
  Escenario.Porcentaje := Escenario.Porcentaje - 20;
  cmbEscala.ItemIndex := cmbEscala.ItemIndex - 1;
  if Escenario.Porcentaje = 20 then
    actDecZoom.Enabled := False;
  actIncZoom.Enabled := True;
  if Escenario.Porcentaje < 60 then
    Escenario.Cuadricula := False
  else
    Escenario.Cuadricula := True;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.BarraNoEditar;
{Actualiza los controles disponibles cuando no hay ningún escenario abierto}
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
  actIncZoom.Enabled := False;
  actDecZoom.Enabled := False;
  actPantalla.Enabled := False;
  actMixto.Enabled := False;
  actVerSustrato.Enabled := False;
  cmbEscala.Enabled := False;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
  begin
    tlbDibujo.Buttons[i].Enabled := False;
    tlbDibujo.Buttons[i].Down := False;
  end;
  btnSustrato1.Enabled := False;
  btnSustrato2.Enabled := False;
  btnSustrato3.Enabled := False;
  btnSustrato4.Enabled := False;
  btnSustrato5.Enabled := False;
  btnSustrato6.Enabled := False;
  btnSustrato7.Enabled := False;
  btnSustrato1.Caption := '';
  btnSustrato2.Caption := '';
  btnSustrato3.Caption := '';
  btnSustrato4.Caption := '';
  btnSustrato5.Caption := '';
  btnSustrato6.Caption := '';
  btnSustrato7.Caption := '';
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ';
  shpSustrato.Visible := False;
end;

procedure TfrmEditorEscenarios.BarraTotal;
{Hace disponibles todos los controles}
var
  i : Integer;
begin
  actGuardar.Enabled := True;
  actGuardarComo.Enabled := True;
  actCerrar.Enabled := True;
  actPropiedades.Enabled := True;
  actIncZoom.Enabled := True;
  actDecZoom.Enabled := True;
  actPantalla.Enabled := True;
  actMixto.Enabled := True;
  actVerSustrato.Enabled := True;
  cmbEscala.Enabled := True;
  tlbDibujo.Enabled := True;
  tlbSustratos.Enabled := True;
   for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Enabled := True;
  btnSustrato1.Enabled := True;
  btnSustrato2.Enabled := True;
  btnSustrato3.Enabled := True;
  btnSustrato4.Enabled := True;
  btnSustrato5.Enabled := True;
  btnSustrato6.Enabled := True;
  btnSustrato7.Enabled := True;
  if Length(PortaPapeles) <> 0 then
  begin
    actPegar.Enabled := True;
    X1 := 1;
    Y1 := 1;
  end;
  shpSustrato.Visible := True;
end;

procedure TfrmEditorEscenarios.actPropiedadesExecute(Sender: TObject);
var
  i : Integer;
  AnchuraAnterior,
  AlturaAnterior : Integer;
begin
  AnchuraAnterior := Escenario.Anchura;
  AlturaAnterior := Escenario.Altura;
  frmPropiedadesEscenario := TfrmPropiedadesEscenario.Create(Self);
  frmPropiedadesEscenario.cmbSustrato.Clear;
  for i := 1 to 7 do
    frmPropiedadesEscenario.cmbSustrato.Items.Add
                            (Escenario.JuegoSustratos.SustratoSimple[i].Nombre);
  frmPropiedadesEscenario.cmbSustrato.ItemIndex := 0;
  if frmPropiedadesEscenario.ShowModal <> mrOK then
  begin
    FreeAndNil(frmPropiedadesEscenario);
    Exit; //-->
  end;
  if AnchuraAnterior < Escenario.Anchura then
    Escenario.Rellena(AnchuraAnterior + 1, 1,
                      Escenario.Anchura, Escenario.Altura, SustratoBase);
  if AlturaAnterior < Escenario.Altura then
    Escenario.Rellena(1, AlturaAnterior + 1, Escenario.Anchura,
                      Escenario.Altura, SustratoBase);
  FreeAndNil(frmPropiedadesEscenario);
  Salvado := False;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if WindowState = wsMaximized then
    ArchivoInicio.WriteString('Ventanas', 'EditorEscenarios', 'Maximizada')
  else
    ArchivoInicio.WriteString('Ventanas', 'EditorEscenarios', 'Normal');
  ArchivoInicio.Free;
end;

procedure TfrmEditorEscenarios.GuardaReciente(PNombreArchivo: string);
{Actualiza la lista de archivos recientemente abiertos en el archivo de inicio}
var
  ListaRecientes: array [1..5] of string;
  i, j          : Integer;
begin
  for i := 1 to 5 do
  begin
    ListaRecientes[i] := ArchivoInicio.ReadString('EscenariosRecientes',
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
      ArchivoInicio.WriteString('EscenariosRecientes', 'Reciente' + IntToStr(j),
                                  ListaRecientes[i]);
      Inc(j);
    end;
  end;
  ActualizaMenuRecientes;
  {$WARNINGS OFF}
  //SHAddToRecentDocs(SHARD_PATH, PChar(NombreArchivo));
  {$WARNINGS ON}
  //Agregar archivo a la lista de recientes de Windows
end;

procedure TfrmEditorEscenarios.ActualizaMenuRecientes;
{Obtiene la lista de archivos recientemente abiertos del archivo de incio y
actuaiza el menú de Archivo}
var
  ListaRecientes: array [1..5] of string;
  i             : Integer;
begin
  for i := 1 to 5 do
    ListaRecientes[i] := ArchivoInicio.ReadString('EscenariosRecientes',
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

procedure TfrmEditorEscenarios.actMixtoExecute(Sender: TObject);
begin
  frmSeleccionarMixto := TfrmSeleccionarMixto.Create(Self);
  if frmSeleccionarMixto.ShowModal = mrOK then
  begin
    SustratoActual := Chr(frmSeleccionarMixto.Seleccion + 64);
    shpSustrato.Brush.Color := Escenario.ObtenColorSustrato(SustratoActual);
    StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' + ML(mlSustMixto);
  end;
  FreeAndNil(frmSeleccionarMixto);
end;

procedure TfrmEditorEscenarios.ptbEscenarioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  XLogica,
  YLogica : Integer;
begin
  if not Assigned(Escenario) then
    Exit; //-->
  XLogica := Escenario.XLogica(X);
  YLogica := Escenario.YLogica(Y);
  if ((XLogica >= Marco.X1) and (XLogica <= Marco.X2))      //Si clic derecho
      and ((YLogica >= Marco.Y1) and (YLogica <= Marco.Y2)) //en zona marcada
      and (Button = mbRight) then
    Exit; //-->
  case Accion of
    ac1Punto   : Escenario.Cuadro[XLogica,YLogica] := SustratoActual;
    ac5Puntos  : Dibuja5Puntos(XLogica, YLogica);
    ac13Puntos : Dibuja13Puntos(XLogica, YLogica);
    ac41Puntos : Dibuja41Puntos(XLogica, YLogica);
    ac145Puntos: Dibuja145Puntos(XLogica, YLogica);
    acRectangulo, acRectanguloRelleno, acNada:
    begin
      X1 := Escenario.XFisica(XLogica);
      X2 := X1 + Escenario.CuadroFisico;
      Y1 := Escenario.YFisica(YLogica);
      Y2 := Y1 + Escenario.CuadroFisico;
      Marco.X1 := XLogica;
      Marco.Y1 := YLogica;
      Marco.X2 := XLogica;
      Marco.Y2 := YLogica;
      {shpFigura.Top := ptbEscenario.Top + Y1;
      shpFigura.Left := ptbEscenario.Left + X1;
      shpFigura.Height := 0;
      shpFigura.Width := 0;}
      Trazando := True;
    end;
  end;
  if Accion <> acNada then
  begin
    Salvado := False;
    actCortar.Enabled := False;
    actCopiar.Enabled := False;
  end;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.ptbEscenarioMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  XLogica,
  YLogica: Integer;
begin
  if not Assigned(Escenario) then
    Exit; //-->
  XLogica := Escenario.XLogica(X);
  YLogica := Escenario.YLogica(Y);
  StatusBar1.Panels[1].Text := ML(mlEO) + ': ' + IntAStr(XLogica, 3);
  StatusBar1.Panels[2].Text := ML(mlNS) + ': ' + IntAStr(YLogica, 3);
  if Trazando then
  begin
    X2 := Escenario.XFisica(XLogica) + Escenario.CuadroFisico;
    Y2 := Escenario.YFisica(YLogica) + Escenario.CuadroFisico;
    {Marco.X2 := XLogica;
    Marco.Y2 := YLogica;
    shpFigura.Width := Abs(X2 - X1);
    shpFigura.Height := Abs(Y2 - Y1);}
     if X1 < X2 then
     begin
       Marco.X1 := Escenario.XLogica(X1);
       Marco.X2 := Escenario.XLogica(X2);
     end
     else if X1 > X2 then
     begin
       Marco.X1 := Escenario.XLogica(X2);
       Marco.X2 := Escenario.XLogica(X1);
     end;
     if Y1 < Y2 then
     begin
       Marco.Y1 := Escenario.YLogica(Y1);
       Marco.Y2 := Escenario.YLogica(Y2);
     end
     else if Y1 > Y2 then
     begin
       Marco.Y1 := Escenario.YLogica(Y2);
       Marco.Y2 := Escenario.YLogica(Y1);
     end;
    with ptbEscenario.Canvas do
    begin
      Pen.Style := psDash;
      Pen.Color := clWhite;
      Brush.Style := bsClear;
      Rectangle(Escenario.XFisica(Marco.X1), Escenario.YFisica(Marco.Y1),
                Escenario.XFisica(Marco.X2), Escenario.YFisica(Marco.Y2));
    end;

  end;
end;

procedure TfrmEditorEscenarios.ptbEscenarioMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i,
  X1Logica,
  X2Logica,
  Y1Logica,
  Y2Logica: Integer;
begin
  if not Trazando then
    Exit; //-->
  if X1 <= X2 then
  begin
    X1Logica := Escenario.XLogica(X1);
    X2Logica := Escenario.XLogica(X2) - 1;
  end
  else
  begin
    X1Logica := Escenario.XLogica(X2);
    X2Logica := Escenario.XLogica(X1) - 1;
  end;
  if Y1 <= Y2 then
  begin
    Y1Logica := Escenario.YLogica(Y1);
    Y2Logica := Escenario.YLogica(Y2) - 1;
  end
  else
  begin
    Y1Logica := Escenario.YLogica(Y2);
    Y2Logica := Escenario.YLogica(Y1) - 1;
  end;
  Trazando := False;
  case Accion of
    acRectangulo:
    begin
      for i := X1Logica to X2Logica do
      begin
        Escenario.Cuadro[i,Y1Logica] := SustratoActual;
        Escenario.Cuadro[i,Y2Logica] := SustratoActual;
      end;
      for i := Y1Logica to Y2Logica do
      begin
        Escenario.Cuadro[X1Logica,i] := SustratoActual;
        Escenario.Cuadro[X2Logica,i] := SustratoActual;
      end;
    end;
    acRectanguloRelleno: Escenario.Rellena(X1Logica, Y1Logica, X2Logica,
                                              Y2Logica, SustratoACtual);
    acNada:
    begin
     { if (shpFigura.Height <> 0) and (shpFigura.Width  <> 0) then
      begin }
      if (Marco.X1 <> Marco.X2) and (Marco.Y1 <> Marco.Y2) then
      begin
        actCortar.Enabled := True;
        actCopiar.Enabled := True;
      end
      else
      begin
        actCortar.Enabled := False;
        actCopiar.Enabled := False;
      end;
    end;
  end; //case
  if Accion <> acNada then
  begin
    Marco.X2  := Marco.X1;
    Marco.Y2  := Marco.Y2;
    {shpFigura.Height := 0;
    shpFigura.Width := 0;}
  end;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.actPunteroExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := acNada;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbtPuntero.Down := True;
end;

procedure TfrmEditorEscenarios.act1PuntoExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := ac1Punto;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbt1Punto.Down := True;
end;

procedure TfrmEditorEscenarios.act5PuntosExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := ac5Puntos;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbt5Puntos.Down := True;
end;

procedure TfrmEditorEscenarios.act13PuntoExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := ac13Puntos;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbt13Puntos.Down := True;
  
end;

procedure TfrmEditorEscenarios.act41PuntosExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := ac41Puntos;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbt41Puntos.Down := True;
end;

procedure TfrmEditorEscenarios.act145PuntosExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := ac145Puntos;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbt145Puntos.Down := True;
end;

procedure TfrmEditorEscenarios.actRectanguloExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := acRectangulo;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbtRectangulo.Down := True;
end;

procedure TfrmEditorEscenarios.actRectanguloRellenoExecute(Sender: TObject);
var
  i : Integer;
begin
  Accion := acRectanguloRelleno;
  for i := 0 to tlbDibujo.ButtonCount - 1 do
    tlbDibujo.Buttons[i].Down := False;
  tbtRectanguloRelleno.Down := True;
end;

procedure TfrmEditorEscenarios.Dibuja5Puntos(X, Y: Integer);
begin
  with Escenario do
  begin
    Cuadro[X,Y] := SustratoActual;
    Cuadro[X,Y-1] := SustratoActual;
    Cuadro[X+1,Y] := SustratoActual;
    Cuadro[X,Y+1] := SustratoActual;
    Cuadro[X-1,Y] := SustratoActual;
  end;
end;

procedure TfrmEditorEscenarios.Dibuja13Puntos(X, Y: Integer);
var
  i, j: Integer;
begin
  with Escenario do
  begin
    for j := 0 to 2 do
      for i := 0 to 2 do
        Cuadro[(X-1)+i,(Y-1)+j] := SustratoActual;
    Cuadro[X,Y-2] := SustratoActual;
    Cuadro[X+2,Y] := SustratoActual;
    Cuadro[X,Y+2] := SustratoActual;
    Cuadro[X-2,Y] := SustratoActual;
  end;
end;

procedure TfrmEditorEscenarios.Dibuja41Puntos(X, Y: Integer);
var
  i, j: Integer;
begin
  with Escenario do
  begin
    for j := 0 to 4 do
      for i := 0 to 4 do
        Cuadro[(X-2)+i,(Y-2)+j] := SustratoActual;
    for i := -1 to 1 do
    begin
      Cuadro[X+i,Y-3] := SustratoActual;
      Cuadro[X+3,Y+i] := SustratoActual;
      Cuadro[X+i,Y+3] := SustratoActual;
      Cuadro[X-3,Y+i] := SustratoActual;
    end;
    Cuadro[X,Y-4] := SustratoActual;
    Cuadro[X+4,Y] := SustratoActual;
    Cuadro[X,Y+4] := SustratoActual;
    Cuadro[X-4,Y] := SustratoActual;
  end;
end;

procedure TfrmEditorEscenarios.Dibuja145Puntos(X, Y: Integer);
var
  i, j: Integer;
begin
  with Escenario do
  begin
    for j := 0 to 8 do
      for i := 0 to 8 do
        Cuadro[(X-4)+i,(Y-4)+j] := SustratoActual;
    for i := -3 to 3 do
    begin
      Cuadro[X+i,Y-5] := SustratoActual;
      Cuadro[X+5,Y+i] := SustratoActual;
      Cuadro[X+i,Y+5] := SustratoActual;
      Cuadro[X-5,Y+i] := SustratoActual;
    end;
    for i := -2 to 2 do
    begin
      Cuadro[X+i,Y-6] := SustratoActual;
      Cuadro[X+6,Y+i] := SustratoActual;
      Cuadro[X+i,Y+6] := SustratoActual;
      Cuadro[X-6,Y+i] := SustratoActual;
    end;
    for i := -1 to 1 do
    begin
      Cuadro[X+i,Y-7] := SustratoActual;
      Cuadro[X+7,Y+i] := SustratoActual;
      Cuadro[X+i,Y+7] := SustratoActual;
      Cuadro[X-7,Y+i] := SustratoActual;
    end;
    Cuadro[X,Y-8] := SustratoActual;
    Cuadro[X+8,Y] := SustratoActual;
    Cuadro[X,Y+8] := SustratoActual;
    Cuadro[X-8,Y] := SustratoActual;
  end;
end;

procedure TfrmEditorEscenarios.actCortarExecute(Sender: TObject);
var
  i, j :Integer;
begin
  AltoPortapapeles := Marco.Y2 - Marco.Y1;
  AnchoPortapapeles := Marco.X2 - Marco.X1;
  SetLength(PortaPapeles, AnchoPortapapeles, AltoPortapapeles);
  for i := 0 to AnchoPortapapeles - 1 do
    for j := 0 to AltoPortapapeles - 1 do
      PortaPapeles[i,j] := Escenario.Cuadro[i+Marco.X1,j+Marco.Y1];
  for i := Marco.X1 to Marco.X2 - 1 do
    for j := Marco.Y1 to Marco.Y2 - 1 do
      Escenario.Cuadro[i,j] := CuadroVacio;
  Salvado := False;
  Marco.X2 := Marco.X1;
  Marco.Y2 := Marco.Y1;
  AjustaTamano;
  {shpFigura.Height := 0;
  shpFigura.Width := 0;}
  actCortar.Enabled := False;
  actCopiar.Enabled := False;
  actPegar.Enabled := True;
end;

procedure TfrmEditorEscenarios.actCopiarExecute(Sender: TObject);
var
  i, j: Integer;
begin
  AltoPortapapeles := Marco.Y2 - Marco.Y1;
  AnchoPortapapeles := Marco.X2 - Marco.X1;
  SetLength(PortaPapeles, AnchoPortapapeles, AltoPortapapeles);
  for i := 0 to AnchoPortapapeles - 1 do
    for j := 0 to AltoPortapapeles - 1 do
      PortaPapeles[i,j] := Escenario.Cuadro[i+Marco.X1,j+Marco.Y1];
  Marco.X2 := Marco.X1;
  Marco.Y2 := Marco.Y1;
  {shpFigura.Height := 0;
  shpFigura.Width := 0;}
  actCortar.Enabled := False;
  actCopiar.Enabled := False;
  actPegar.Enabled := True;
end;

procedure TfrmEditorEscenarios.actPegarExecute(Sender: TObject);
var
  i, j,
  X1Logica,
  Y1Logica: Integer;
begin
  X1Logica := Escenario.XLogica(X1);
  Y1Logica := Escenario.YLogica(Y1);
  for i := 0 to AnchoPortapapeles - 1 do
    for j := 0 to AltoPortapapeles - 1 do
      Escenario.Cuadro[i+X1Logica,j+Y1Logica] := PortaPapeles[i,j];
  Salvado := False;
  AjustaTamano;
end;

procedure TfrmEditorEscenarios.actVerSustratoExecute(Sender: TObject);
var
  Sustrato: TCuadro;
  XLogica,
  YLogica: Integer;
  Mixto: TSustratoMixto;
begin
  XLogica := Escenario.XLogica(X1);
  YLogica := Escenario.YLogica(Y1);
  Sustrato := Escenario.Cuadro[XLogica,YLogica];
  frmVerSustrato := TfrmVerSustrato.Create(Self);
  frmVerSustrato.lblXY.Caption := 'X:' + IntAStr(XLogica, 3) + ','
                                  + 'Y:' + IntAStr(YLogica, 3);
  with Escenario.JuegoSustratos do
  begin
    if Sustrato in ['1'..'7'] then
      frmVerSustrato.sttComposicion.Caption :=
                                    SustratoSimple[Ord(Sustrato)-48].Nombre
    else if Sustrato in ['A'..'Z'] then
    begin
      Mixto := SustratoMixto[Ord(Sustrato)-64];
      frmVerSustrato.sttComposicion.Caption :=
        SustratoSimple[1].Nombre + ':' + IntToStr(Mixto.Porcentajes[1]) + '%; '
        + SustratoSimple[2].Nombre + ':' + IntToStr(Mixto.Porcentajes[2]) + '%; '
        + SustratoSimple[3].Nombre + ':' + IntToStr(Mixto.Porcentajes[3]) + '%; '
        + SustratoSimple[4].Nombre + ':' + IntToStr(Mixto.Porcentajes[4]) + '%; '
        + SustratoSimple[5].Nombre + ':' + IntToStr(Mixto.Porcentajes[5]) + '%; '
        + SustratoSimple[6].Nombre + ':' + IntToStr(Mixto.Porcentajes[6]) + '%; '
        + SustratoSimple[7].Nombre + ':' + IntToStr(Mixto.Porcentajes[7]) + '%; '
    end
    else
      frmVerSustrato.sttComposicion.Caption := ML(mlSustrVc);
  end;
  frmVerSustrato.lblColor.Color := Escenario.ObtenColorSustrato(Sustrato);
  frmVerSustrato.ShowModal;
  FreeAndNil(frmVerSustrato);
end;

procedure TfrmEditorEscenarios.actAccercadeExecute(Sender: TObject);
begin
  frmAcerca := TfrmAcerca.Create(Self);
  frmAcerca.ShowModal;
  FreeAndNil(frmAcerca);
end;

procedure TfrmEditorEscenarios.actObtenerJuegoExecute(Sender: TObject);
var
  RutaSustrato: string;
begin
  {frmSeleccionaJuego := TfrmSeleccionaJuego.Create(Self);
  if frmSeleccionaJuego.ShowModal = mrOK then
  begin
    Escenario.JuegoSustratos.Carga(frmSeleccionaJuego.NombreArchivo);
    ActualizaBarraSustratos;
    AjustaTamano;
    Salvado := False;
  end;
  FreeAndNil(frmSeleccionaJuego);}
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    dlgAbrirSuatratos.InitialDir := RutaSustrato;
  if dlgAbrirSuatratos.Execute then
  begin
    Escenario.JuegoSustratos.Carga(dlgAbrirSuatratos.FileName);
    ActualizaBarraSustratos;
    AjustaTamano;
    Salvado := False;
  end;
end;

procedure TfrmEditorEscenarios.actGuardarJuegoExecute(Sender: TObject);
var
  RutaSustrato,
  ArchivoJuego: string;
begin
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    dlgGuardarJuego.InitialDir := RutaSustrato
  else
  begin
    if PreguntaSN(ML(mlDrSustrNE), ML(mlEdSustGl)) = rSi then //No existe
      begin                                    // directorio, ¿crearlo?
        //CreateDirectory(PChar(RutaSustrato), nil);
        CreateDir(RutaSustrato);
        dlgGuardarJuego.InitialDir := RutaSustrato
      end;
  end;
  dlgGuardarJuego.FileName := ML(mlJgoSustrs);  //Juego de Sustratos
  if dlgGuardarJuego.Execute then
  begin
    ArchivoJuego := dlgGuardarJuego.FileName;
    if ExtractFileExt(ArchivoJuego) <> '.sgl' then
      ArchivoJuego := ArchivoJuego + '.sgl';
    Escenario.JuegoSustratos.Guarda(ArchivoJuego);
    Salvado := True;
  end;
end;

procedure TfrmEditorEscenarios.sbxEscenarioConstrainedResize(Sender: TObject;
  var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
begin
  if Assigned(Escenario) then
    Escenario.Despliega;
end;

procedure TfrmEditorEscenarios.actPantallaExecute(Sender: TObject);
begin
  frmPantallaEscenario := TfrmPantallaEscenario.Create(Self);
  frmPantallaEscenario.ShowModal;
  FreeAndNil(frmPantallaEscenario);
end;

procedure TfrmEditorEscenarios.FormResize(Sender: TObject);
begin
  if Assigned(Escenario) then
    AjustaTamano;
  //Redibujar := False;
end;

procedure TfrmEditorEscenarios.FormPaint(Sender: TObject);
begin
  //if Assigned(Escenario) then
    //AjustaTamano;
end;

procedure TfrmEditorEscenarios.btnSustrato1Click(Sender: TObject);
begin
  SustratoActual := '1';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[1].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[1].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato2Click(Sender: TObject);
begin
  SustratoActual := '2';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[2].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[2].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato3Click(Sender: TObject);
begin
  SustratoActual := '3';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[3].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[3].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato4Click(Sender: TObject);
begin
  SustratoActual := '4';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[4].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[4].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato5Click(Sender: TObject);
begin
  SustratoActual := '5';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[5].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[5].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato6Click(Sender: TObject);
begin
  SustratoActual := '6';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[6].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[6].Nombre;
end;

procedure TfrmEditorEscenarios.btnSustrato7Click(Sender: TObject);
begin
  SustratoActual := '7';
  shpSustrato.Brush.Color := Escenario.JuegoSustratos.SustratoSimple[7].Color;
  StatusBar1.Panels[3].Text := ML(mlSustActual) + ': ' +
                              Escenario.JuegoSustratos.SustratoSimple[7].Nombre;
end;

procedure TfrmEditorEscenarios.Dibuja(Sender: TObject);
begin
   DibujaEscenario(Sender as TEscenario);
end;

initialization
  {$i EditorEscenarios.lrs}
  {$i EditorEscenarios.lrs}

end.
