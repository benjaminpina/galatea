unit AnalizadorSalidas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, Menus, ActnList, ImgList, StdCtrls, ComCtrls, ToolWin,
  IniFiles, Comunes;

type
  TfrmAnalizadorSalidas = class(TForm)
    imlPrincipal: TImageList;
    aclPrincipal: TActionList;
    actAbrir: TAction;
    actCerrar: TAction;
    actSalir: TAction;
    actCortar: TAction;
    actCopiar: TAction;
    actPegar: TAction;
    actIncZoom: TAction;
    actDecZoom: TAction;
    actAyuda: TAction;
    actAcerca: TAction;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    OpenEnvironment1: TMenuItem;
    CloseEnvironment1: TMenuItem;
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
    Zoomin1: TMenuItem;
    Zooout1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    About1: TMenuItem;
    dlgAbrirSalida: TOpenDialog;
    ApplicationEvents1: TApplicationEvents;
    tlbPrincipal: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
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
    StatusBar1: TStatusBar;
    actReportes: TAction;
    actReports1: TMenuItem;
    actReports2: TMenuItem;
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure actSalirExecute(Sender: TObject);
    procedure actAbrirExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actCerrarExecute(Sender: TObject);
    procedure actReportesExecute(Sender: TObject);
  private
    { Private declarations }
    ArchivoInicio: TIniFile;
    FNombreArchivo: string;
    procedure BarraSoloNuevo;
    procedure BarraTotal;
    procedure SetNombreArchivo(const Value: string);
    procedure AbreArchivo(PNombreArchivo: string);
  public
    { Public declarations }
    InfoEntorno,
    InfoAgentes,
    InfoHuevos,
    InfoCiclos,
    InfoMorfo,
    InfoGraficas: TGuardable;
    Directorio: string;
    function NombreBase: string;
    property NombreArchivo: string
      read FNombreArchivo write SetNombreArchivo;
  end;

var
  frmAnalizadorSalidas: TfrmAnalizadorSalidas;

implementation

uses
  Multilenguaje, Dialogos, ReportesAgenteCiclo;

{$R *.dfm}

procedure TfrmAnalizadorSalidas.ApplicationEvents1Hint(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Application.Hint;
end;

procedure TfrmAnalizadorSalidas.actSalirExecute(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmAnalizadorSalidas.actAbrirExecute(Sender: TObject);
var
  RutaSalida : string;
  Respuesta: TRespuesta;
begin
  RutaSalida := ExtractFilePath(Application.ExeName) + ML(mlSalida) +'\';
  if DirectoryExists(RutaSalida) then
    dlgAbrirSalida.InitialDir := RutaSalida
  else
  begin
    Respuesta := PreguntaSN(ML(mlDirSalNE),ML(mlAnlzdrSlds));//no existe directorio
    if  Respuesta = rSI then            //de salidas ¿crearlo?
    begin
      CreateDirectory(PChar(RutaSalida), nil);
      CreateDir(RutaSalida);
      dlgAbrirSalida.InitialDir := RutaSalida;
    end;
  end;
  if dlgAbrirSalida.Execute then
  begin
    NombreArchivo := dlgAbrirSalida.FileName;
    AbreArchivo(NombreArchivo);
    Directorio := ExtractFilePath(dlgAbrirSalida.FileName);
    BarraTotal;
  end;
end;

procedure TfrmAnalizadorSalidas.FormCreate(Sender: TObject);
begin
  ArchivoInicio := TIniFile.Create('galatea.ini');
  BarraSoloNuevo;
end;

procedure TfrmAnalizadorSalidas.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ArchivoInicio.Free;
end;

procedure TfrmAnalizadorSalidas.SetNombreArchivo(const Value: string);
begin
  FNombreArchivo := Value;
  Self.Caption := ML(mlAnlzdrSlds) + ' [' + FNombreArchivo + ']';
end;

procedure TfrmAnalizadorSalidas.AbreArchivo(PNombreArchivo: string);
begin
  if Assigned(InfoEntorno) then
    actCerrar.Execute;
  InfoEntorno := TGuardable.Create;
  InfoAgentes := TGuardable.Create;
  InfoHuevos  := TGuardable.Create;
  InfoCiclos  := TGuardable.Create;
  InfoMorfo   := TGuardable.Create;
  InfoGraficas:= TGuardable.Create;
  InfoEntorno.Reestablece;
  InfoAgentes.Reestablece;
  InfoHuevos.Reestablece;
  InfoCiclos.Reestablece;
  InfoMorfo.Reestablece;
  InfoGraficas.Reestablece;
end;

procedure TfrmAnalizadorSalidas.actCerrarExecute(Sender: TObject);
begin
  NombreArchivo := '';
  InfoEntorno.Free;
  InfoAgentes.Free;
  InfoHuevos.Free;
  InfoCiclos.Free;
  InfoMorfo.Free;
  InfoGraficas.Free;
end;

procedure TfrmAnalizadorSalidas.actReportesExecute(Sender: TObject);
begin
  frmReportesAgenteCiclo := TfrmReportesAgenteCiclo.Create(Application);
  frmReportesAgenteCiclo.Directorio := Directorio;
  frmReportesAgenteCiclo.ShowModal;
  frmReportesAgenteCiclo.Release;
end;

procedure TfrmAnalizadorSalidas.BarraSoloNuevo;
begin
  actCerrar.Enabled := False;
  actReportes.Enabled := False;
end;

procedure TfrmAnalizadorSalidas.BarraTotal;
begin
  actCerrar.Enabled := True;
  actReportes.Enabled := True;
end;

function TfrmAnalizadorSalidas.NombreBase: string;
var
  s: string;
begin
  s := ExtractFileName(FNombreArchivo);
  s := ChangeFileExt(s, '');
  Result := s;
end;

end.
