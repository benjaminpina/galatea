unit EditorSustratos;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, ComCtrls, StdCtrls,
  Buttons, Comunes, Sustratos, Dialogos, EditarSimple,
  EditarMixto, AcercaEdSs, IniFiles, ExtCtrls, LResources;

type

  { TfrmEditorSustratos }

  TfrmEditorSustratos = class(TForm)
    ActionList1: TActionList;
    actNuevo: TAction;
    actAbrir: TAction;
    actGuardar: TAction;
    actGuardarComo: TAction;
    actSalir: TAction;
    actAyuda: TAction;
    actAcerca: TAction;
    MainMenu1: TMainMenu;
    ImageList1: TImageList;
    Archivo1: TMenuItem;
    Nuevo1: TMenuItem;
    Abrir1: TMenuItem;
    Guardar1: TMenuItem;
    N1: TMenuItem;
    Salir1: TMenuItem;
    Ayuda1: TMenuItem;
    Contenido1: TMenuItem;
    Acercade1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    //ApplicationEvents1: TApplicationEvents;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    pgcJuegoSustrato: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label1: TLabel;
    edtTitulo: TEdit;
    Label2: TLabel;
    memComentarios: TMemo;
    lstSimples: TListBox;
    sbtModificarSimple: TSpeedButton;
    Label3: TLabel;
    lstMixtos: TListBox;
    sbtAgregar: TSpeedButton;
    sbtEliminar: TSpeedButton;
    sbtModificarMixto: TSpeedButton;
    Label4: TLabel;
    Saveas1: TMenuItem;
    //XPManifest1: TXPManifest;
    shpColorSimple: TShape;
    shpColorMixto: TShape;
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure ToolBar1Click(Sender: TObject);
    procedure actSalirExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actNuevoExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure sbtModificarSimpleClick(Sender: TObject);
    procedure lstSimplesClick(Sender: TObject);
    procedure sbtAgregarClick(Sender: TObject);
    procedure sbtModificarMixtoClick(Sender: TObject);
    procedure lstMixtosClick(Sender: TObject);
    procedure sbtEliminarClick(Sender: TObject);
    procedure actGuardarComoExecute(Sender: TObject);
    procedure actGuardarExecute(Sender: TObject);
    procedure pgcJuegoSustratoChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actAcercaExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lstSimplesDblClick(Sender: TObject);
    procedure lstMixtosDblClick(Sender: TObject);
  private
    { Private declarations }
    ArchivoInicio: TIniFile;
    function ObtenValoresMixto: TSustratoMixto;
    function VerificaSalvado: Boolean;
    procedure LimpiaControles;
    procedure DespliegaDatos;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure EnviaValoresSimple;
    procedure EnviaValoresMixto(Mixto: TSustratoMixto);
    procedure EditarSimple;
    procedure EditarMixto;
  public
    { Public declarations }
    JuegoSustratos: TJuegoSustratos;
    Salvado: Boolean;
    NombreArchivo: string;
  end;

var
  frmEditorSustratos: TfrmEditorSustratos;

implementation


uses
  {ShlObj,} Multilenguaje;

function TfrmEditorSustratos.VerificaSalvado: Boolean;
{Verifica si el archivo ha sido guardado desde la última modificación, si el
archivo no ha sido guardado pregunta al usuario si desea guardarlo.
Regresa False si el usuario cancela la acción de cerrar archivo}
var
  Respuesta: TRespuesta;
begin
  Result := True;
  if Assigned(JuegoSustratos) then
  begin
    if not Salvado then
    begin
      Respuesta := PreguntaSNC(ML(mlGrdSustCr), ML(mlEdSustGl));
      case Respuesta of
        rSi       : actGuardar.Execute;
        rNo       :
        begin
          FreeAndNil(JuegoSustratos);
          Salvado := True;
        end;
        rCancelar :
        begin
          Result := False;
          Exit; //-->
        end;
      end; //case
    end; //if
  end;  //if
end;

procedure TfrmEditorSustratos.FormCreate(Sender: TObject);
var
  Idioma: string;
begin
  {Candado de seguridad
  if not Llave('galatea', '') then
  begin
    Fallo('Ilegal copy / copia ilegal', 'Galatea');
    Halt; //--->
  end;        }
  {Candado de seguridad}
  Salvado := False;
  ArchivoInicio := TIniFile.Create('.galatea.ini');
  Idioma := ArchivoInicio.ReadString('Generales', 'Idioma', 'English');
  if Idioma = 'English' then
    Lenguaje := lEnglish
  else if Idioma = 'Spanish' then
    Lenguaje := lEspanol;
  pgcJuegoSustrato.ActivePageIndex := 0;
  if ParamCount <> 0 then
  begin
    NombreArchivo := ParamStr(1);
    if ExtractFileExt(NombreArchivo) = '.sgl' then
      AbreArchivo(NombreArchivo)
    else
      Fallo(ML(mlErrExtNCES), ML(mlEdSustGl));
    DespliegaDatos;
  end
  else
    actNuevo.Execute;
end;

procedure TfrmEditorSustratos.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.SimpleText := Application.Hint;
end;

procedure TfrmEditorSustratos.TabSheet1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmEditorSustratos.ToolBar1Click(Sender: TObject);
begin

end;

procedure TfrmEditorSustratos.actSalirExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmEditorSustratos.LimpiaControles;
begin
  edtTitulo.Text := ML(mlSnTtl); //Sin título
  memComentarios.Text := '';
  lstSimples.Clear;
  lstMixtos.Clear;
end;


procedure TfrmEditorSustratos.actNuevoExecute(Sender: TObject);
var
  i        : Integer;
  Simple   : TSustratoSimple;
begin
  if not VerificaSalvado then
    Exit; //-->
  Simple.Color := clWhite;
  JuegoSustratos := TJuegoSustratos.Create;
  JuegoSustratos.Titulo := ML(mlSnTtl);
  for i := 1 to 7 do
  begin
    Simple.Nombre := ML(mlSustrato) +  IntAStr(i, 1);
    JuegoSustratos.SustratoSimple[i] := Simple;
  end;
  NombreArchivo := ML(mlJgoSustrs);
  Salvado := True;
  Self.Caption := ML(mlEdSustGl) + ' [' + ML(mlJgoSustrs) + ']';
  DespliegaDatos;
end;

procedure TfrmEditorSustratos.DespliegaDatos;
var
  i, j  : Integer;
  Simple: TSustratoSimple;
  Mixto : TSustratoMixto;
  s     : string;
begin
  LimpiaControles;
  with JuegoSustratos do
  begin
    edtTitulo.Text := Titulo;
    memComentarios.Text := Comentarios;
    for i := 1 to 7 do
    begin
      Simple := SustratoSimple[i];
      lstSimples.Items.Add(Simple.Nombre);
    end;
    lstSimples.ItemIndex := 0;
    Simple := SustratoSimple[1];
    shpColorSimple.Brush.Color := Simple.Color;
    for i := 1 to NumMixtos do
    begin
      Mixto := SustratoMixto[i];
      s := ML(mlSustrVc); //Sustrato vacío
      for j := 1 to 7 do
      begin
        Simple := SustratoSimple[j];
        if Mixto.Porcentajes[j] <> 0 then
        begin
          if s = ML(mlSustrVc) then
            s := '';
          s :=  s + Simple.Nombre + ':' + IntToStr(Mixto.Porcentajes[j]) + '; ';
        end; //if
      end;  //for
      lstMixtos.Items.Add(s);
    end; //for
  end; //with
  if lstMixtos.Count = 1 then
    sbtEliminar.Enabled := False
  else
    sbtEliminar.Enabled := True;
  if lstMixtos.Count = 26 then
    sbtAgregar.Enabled := False
  else
    sbtAgregar.Enabled := True;
  lstMixtos.ItemIndex := 0;
  Mixto := JuegoSustratos.SustratoMixto[1];
  shpColorMixto.Brush.Color := Mixto.Color;
end;

procedure TfrmEditorSustratos.actAbrirExecute(Sender: TObject);
var
  RutaSustrato : string;
  Respuesta : TRespuesta;
begin
  if not VerificaSalvado then
    Exit; //-->
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    OpenDialog1.InitialDir := RutaSustrato
  else  //no existe directorio de sustratos
  begin
    Respuesta := PreguntaSN(ML(mlDrSustrNE), ML(mlEdSustGl)); //¿Desea crearlo?
    if  Respuesta = rSI then
      begin
        //CreateDirectory(PChar(RutaSustrato), nil);
        CreateDir(RutaSustrato);
        OpenDialog1.InitialDir := RutaSustrato
      end;
  end;
  if OpenDialog1.Execute then
  begin
    NombreArchivo := OpenDialog1.FileName;
    AbreArchivo(NombreArchivo);
  end;
  DespliegaDatos;
end;

procedure TfrmEditorSustratos.AbreArchivo(PNombreArchivo: string);
begin
  if not FileExists(PNombreArchivo) then
  begin
    Fallo(ML(mlErrArchvNE), ML(mlEdSustGl));
    Exit; //-->
  end;
  NombreArchivo := PNombreArchivo;
  Self.Caption := ML(mlEdSustGl) + ' [' + NombreArchivo + ']';
  Salvado := True;
  JuegoSustratos := TJuegoSustratos.Create;
  JuegoSustratos.Carga(NombreArchivo);
  {$WARNINGS OFF}
  //SHAddToRecentDocs(SHARD_PATH, PChar(NombreArchivo));
  {$WARNINGS ON}
  //Agregar archivo a la lista de recientes de Windows
end;

procedure TfrmEditorSustratos.sbtModificarSimpleClick(Sender: TObject);
begin
  EditarSimple;
end;

procedure TfrmEditorSustratos.lstSimplesClick(Sender: TObject);
var
  Simple: TSustratoSimple;
begin
  if lstSimples.ItemIndex = -1 then
    lstSimples.ItemIndex := 0;
  Simple := JuegoSustratos.SustratoSimple[lstSimples.ItemIndex+1];
  shpColorSimple.Brush.Color := Simple.Color;
end;

procedure TfrmEditorSustratos.sbtAgregarClick(Sender: TObject);
var
  i     : Integer;
begin
  i := JuegoSustratos.NumMixtos + 1;
  frmEditarMixto := TfrmEditarMixto.Create(Self);
  with frmEditarMixto do
  begin
    EnviaValoresSimple;
    if ShowModal = mrOK then
    begin
      JuegoSustratos.NumMixtos := i;
      JuegoSustratos.SustratoMixto[i] := ObtenValoresMixto;
      Salvado := False;
    end;
  end; //with
  FreeAndNil(frmEditarMixto);
  DespliegaDatos;
  lstMixtos.ItemIndex := i - 1;
  shpColorMixto.Brush.Color := JuegoSustratos.SustratoMixto[i].Color;
end;  //sbtAgregarClick

function TfrmEditorSustratos.ObtenValoresMixto: TSustratoMixto;
var
  i       : Integer;
  Rojo,
  Verde,
  Azul    : Byte;
  Rojos,
  Verdes,
  Azules  : array [1..7] of Byte;
  P       : array [1..7] of Word; //Porcentajes
begin
  Rojo := 0;
  Verde := 0;
  Azul := 0;
  with JuegoSustratos do
  begin
    for i := 1 to 7 do
    begin
      Rojos[i] := Red(SustratoSimple[i].Color);
      Verdes[i] := Green(SustratoSimple[i].Color);
      Azules[i] := Blue(SustratoSimple[i].Color);
    end;
  end;
  with frmEditarMixto do
  begin
    P[1] := StrToInt(edt1.Text);
    P[2] := StrToInt(edt2.Text);
    P[3] := StrToInt(edt3.Text);
    P[4] := StrToInt(edt4.Text);
    P[5] := StrToInt(edt5.Text);
    P[6] := StrToInt(edt6.Text);
    P[7] := StrToInt(edt7.Text);
    if chbMezclar.Checked then
    begin
      for i := 1 to 7 do
      begin
        Rojo := Rojo + Round(Rojos[i] * (P[i] / 100));
        Verde := Verde + Round(Verdes[i] * (P[i] / 100));
        Azul := Azul + Round(Azules[i] * (P[i] / 100));
      end;
      Result.Color := RGBToColor(Rojo, Verde, Azul);
    end
    else
      Result.Color := shpColor.Brush.Color;
  end; //with
  for i := 1 to 7 do
    Result.Porcentajes[i] := P[i];
end;

procedure TfrmEditorSustratos.EnviaValoresSimple;
var
  Simple: TSustratoSimple;
begin
  with frmEditarMixto do
  begin
    edt1.Text := '0';
    edt2.Text := '0';
    edt3.Text := '0';
    edt4.Text := '0';
    edt5.Text := '0';
    edt6.Text := '0';
    edt7.Text := '0';
    Simple := JuegoSustratos.SustratoSimple[1];
    lbl1.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[2];
    lbl2.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[3];
    lbl3.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[4];
    lbl4.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[5];
    lbl5.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[6];
    lbl6.Caption := Simple.Nombre;
    Simple := JuegoSustratos.SustratoSimple[7];
    lbl7.Caption := Simple.Nombre;
  end;
end;

procedure TfrmEditorSustratos.EnviaValoresMixto(Mixto: TSustratoMixto);
begin
  with frmEditarMixto do
  begin
    edt1.Text := IntToStr(Mixto.Porcentajes[1]);
    edt2.Text := IntToStr(Mixto.Porcentajes[2]);
    edt3.Text := IntToStr(Mixto.Porcentajes[3]);
    edt4.Text := IntToStr(Mixto.Porcentajes[4]);
    edt5.Text := IntToStr(Mixto.Porcentajes[5]);
    edt6.Text := IntToStr(Mixto.Porcentajes[6]);
    edt7.Text := IntToStr(Mixto.Porcentajes[7]);
    shpColor.Brush.Color := Mixto.Color;
    ColorDialog1.Color := Mixto.Color;
  end;
end;

procedure TfrmEditorSustratos.sbtModificarMixtoClick(Sender: TObject);
begin
  EditarMixto;
end;

procedure TfrmEditorSustratos.lstMixtosClick(Sender: TObject);
var
  Mixto: TSustratoMixto;
begin
  if lstMixtos.ItemIndex = - 1 then
    lstMixtos.ItemIndex := 0;
  Mixto := JuegoSustratos.SustratoMixto[lstMixtos.ItemIndex+1];
  shpColorMixto.Brush.Color := Mixto.Color;
end;

procedure TfrmEditorSustratos.sbtEliminarClick(Sender: TObject);
var
  i: Integer;
  Respuesta: TRespuesta;
begin
  i := lstMixtos.ItemIndex + 1;
  Respuesta := PreguntaSN(ML(mlSgrElmSustr), ML(mlEdSustGl));//¿Está seguro?
  if Respuesta = rSi then
  begin
    JuegoSustratos.EliminaMixto(i);
    Salvado := False;
  end;
  DespliegaDatos;
  lstMixtos.ItemIndex := i - 1;
end;

procedure TfrmEditorSustratos.actGuardarComoExecute(Sender: TObject);
var
  RutaSustrato : string;
begin
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  RutaSustrato :=
      ArchivoInicio.ReadString('Directorios', 'Sustratos', RutaSustrato);
  if DirectoryExists(RutaSustrato) then
    SaveDialog1.InitialDir := RutaSustrato
  else
  begin
    if PreguntaSN(ML(mlDrSustrNE), ML(mlEdSustGl)) = rSi then //No existe
      begin                                    // directorio, ¿crearlo?
        CreateDir(RutaSustrato);
        SaveDialog1.InitialDir := RutaSustrato
      end;
  end;
  SaveDialog1.FileName := JuegoSustratos.Titulo;
  if SaveDialog1.Execute then
  begin
    NombreArchivo := SaveDialog1.FileName;
    if ExtractFileExt(NombreArchivo) <> '.sgl' then
      NombreArchivo := NombreArchivo + '.sgl';
    Self.Caption := ML(mlEdSustGl) + ' [' + NombreArchivo + ']';
    JuegoSustratos.Titulo:= edtTitulo.Text;
    JuegoSustratos.Comentarios:= memComentarios.Text;
    JuegoSustratos.Guarda(NombreArchivo);
    Salvado := True;
    RutaSustrato := ExtractFilePath(SaveDialog1.FileName);
    if ArchivoInicio.ReadBool('General', 'Recordar', True) then
       ArchivoInicio.WriteString('Directorios', 'Sustratos', RutaSustrato);
  end;
end;

procedure TfrmEditorSustratos.actGuardarExecute(Sender: TObject);
begin
  if NombreArchivo = ML(mlJgoSustrs) then
    actGuardarComo.Execute
  else
  begin
    JuegoSustratos.Titulo:= edtTitulo.Text;
    JuegoSustratos.Comentarios:= memComentarios.Text;
    JuegoSustratos.Guarda(NombreArchivo);
    Salvado := True;
  end;
end;

procedure TfrmEditorSustratos.pgcJuegoSustratoChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  JuegoSustratos.Titulo := edtTitulo.Text;
  JuegoSustratos.Comentarios := memComentarios.Text;
end;

procedure TfrmEditorSustratos.actAcercaExecute(Sender: TObject);
begin
  frmAcerca := TfrmAcerca.Create(Self);
  frmAcerca.ShowModal;
  FreeAndNil(frmAcerca);
end;

procedure TfrmEditorSustratos.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := VerificaSalvado;
end;

procedure TfrmEditorSustratos.lstSimplesDblClick(Sender: TObject);
begin
  EditarSimple;
end;

procedure TfrmEditorSustratos.EditarSimple;
var
  Simple: TSustratoSimple;
  i     : Integer;
begin
  i := lstSimples.ItemIndex + 1;
  Simple := JuegoSustratos.SustratoSimple[i];
  with frmEditarSimple do
  begin
    frmEditarSimple := TfrmEditarSimple.Create(Self);
    Indice := lstSimples.ItemIndex + 1;
    lblNumero.Caption := ML(mlNum) + ': ' + IntToStr(Indice);
    edtNombre.Text := Simple.Nombre;
    shpColor.Brush.Color := Simple.Color;
    if ShowModal = mrOK then
      Salvado := False;
  end;
  FreeAndNil(frmEditarSimple);
  DespliegaDatos;
  lstSimples.ItemIndex := i - 1;
  shpColorSimple.Brush.Color := JuegoSustratos.SustratoSimple[i].Color;
end;

procedure TfrmEditorSustratos.EditarMixto;
var
  i     : Integer;
  Mixto : TSustratoMixto;
begin
  frmEditarMixto := TfrmEditarMixto.Create(Self);
  i := lstMixtos.ItemIndex + 1;
  Mixto := JuegoSustratos.SustratoMixto[i];
  with frmEditarMixto do
  begin
    EnviaValoresSimple;
    EnviaValoresMixto(Mixto);
    if ShowModal = mrOK then
    begin
      JuegoSustratos.SustratoMixto[i] := ObtenValoresMixto;
      Salvado := False;
    end;
  end; //with
  FreeAndNil(frmEditarMixto);
  DespliegaDatos;
  lstMixtos.ItemIndex := i - 1;
  shpColorMixto.Brush.Color := JuegoSustratos.SustratoMixto[i].Color;
end;

procedure TfrmEditorSustratos.lstMixtosDblClick(Sender: TObject);
begin
  EditarMixto;
end;

initialization
  {$i EditorSustratos.lrs}

end.
