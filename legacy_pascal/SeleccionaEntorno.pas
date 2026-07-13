unit SeleccionaEntorno;

{$MODE Delphi}

{$WARN UNIT_PLATFORM OFF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl, ExtCtrls, LResources;

type
  TfrmSeleccionaEntorno = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    //DriveComboBox1: TDriveComboBox;
    //DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    sttTitulo: TStaticText;
    sttComentarios: TStaticText;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    ptbVistaPrevia: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure DibujaEscnr(Sender: TObject);
    procedure DibujaED(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
    procedure DibujaAgnt(Sender: TObject; XFisica, YFisica,
        CuadroFisico: Word);
  public
    { Public declarations }
    NombreArchivo: string;
  end;

var
  frmSeleccionaEntorno: TfrmSeleccionaEntorno;

implementation

uses
  Principal, Multilenguaje, Escenarios, Elementos, Agentes, Entornos, Dibujo,
  Comunes;

var
  Entorno: TEntorno;


procedure TfrmSeleccionaEntorno.FormCreate(Sender: TObject);
var
  RutaEntornos: string;
begin
  RutaEntornos := ExtractFilePath(Application.ExeName) + ML(mlEntornos)+ Diag;
  {if DirectoryExists(RutaEntornos) then
    DirectoryListBox1.Directory := RutaEntornos;
  sttTitulo.Caption := '';
  sttComentarios.Caption := '';
  Plataforma := ptbVistaPrevia.Canvas; }
end;

procedure TfrmSeleccionaEntorno.FileListBox1Change(Sender: TObject);
begin
  if FileListBox1.FileName = '' then
    Exit; //-->
  if Assigned(Entorno) then
    FreeAndNil(Entorno);
  Entorno := TEntorno.Create;//(ptbVistaPrevia);
  Entorno.OnDibujaEscenario := DibujaEscnr;
  Entorno.OnDibujaDinamico := DibujaED;
  Entorno.OnDibujaAgente := DibujaAgnt;
  Entorno.Carga(FileListBox1.FileName);
  Entorno.Porcentaje := 20;
  Entorno.Cuadricula := False;
  sttTitulo.Caption := Entorno.Titulo;
  sttComentarios.Caption := Entorno.Comentarios;
  Entorno.Despliega;
  NombreArchivo := FileListBox1.FileName;
end;

procedure TfrmSeleccionaEntorno.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(Entorno);
  Plataforma := frmPrincipal.ptbEntorno.Canvas;
end;

procedure TfrmSeleccionaEntorno.DibujaAgnt(Sender: TObject; XFisica,
  YFisica, CuadroFisico: Word);
begin
  DibujaAgente(Sender as TAgente, XFisica, YFisica, CuadroFisico);
end;

procedure TfrmSeleccionaEntorno.DibujaED(Sender: TObject; XFisica, YFisica,
  CuadroFisico: Word);
begin
  DibujaElementoDinamico(Sender as TDinamico, XFisica, YFisica, CuadroFisico);
end;

procedure TfrmSeleccionaEntorno.DibujaEscnr(Sender: TObject);
begin
  DibujaEscenario(Sender as TEscenario);
end;

initialization
  {$i SeleccionaEntorno.lrs}
  {$i SeleccionaEntorno.lrs}

end.
