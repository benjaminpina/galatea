unit SeleccionarEscenario;

{$MODE Delphi}

{$WARN UNIT_PLATFORM OFF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl, ExtCtrls, LResources;

type
  TfrmSeleccionarEscenario = class(TForm)
    //DriveComboBox1: TDriveComboBox;
    //DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    sttTitulo: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    sttComentarios: TStaticText;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    ptbVistaPrevia: TPaintBox;
    procedure FileListBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure Dibuja(Sender: TObject);
  public
    { Public declarations }
    NombreArchivo: string;
  end;

var
  frmSeleccionarEscenario: TfrmSeleccionarEscenario;

implementation

uses
  EditorEntornos, Escenarios, Multilenguaje, Dibujo, Comunes;

var
  Escenario: TEscenario;


procedure TfrmSeleccionarEscenario.FileListBox1Change(Sender: TObject);
begin
  if FileListBox1.FileName = '' then
    Exit; //-->
  if Assigned(Escenario) then
    FreeAndNil(Escenario);
  ptbVistaPrevia.Canvas.Brush.Color := clBtnFace;
  ptbVistaPrevia.Canvas.Rectangle
                            (0, 0, ptbVistaPrevia.Width, ptbVistaPrevia.Height);
  Escenario := TEscenario.Create;//(ptbVistaPrevia);
  Escenario.OnDibuja := Dibuja;
  Escenario.Carga(FileListBox1.FileName);
  Escenario.Porcentaje := 20;
  sttTitulo.Caption := Escenario.Titulo;
  sttComentarios.Caption := Escenario.Comentarios;
  Escenario.Despliega;
  NombreArchivo := FileListBox1.FileName;
end;

procedure TfrmSeleccionarEscenario.FormCreate(Sender: TObject);
//var
  //RutaEscenario: string;
begin
  //RutaEscenario := ExtractFilePath(Application.ExeName) + ML(mlEscenarios)+ Diag;
  //if DirectoryExists(RutaEscenario) then
    //DirectoryListBox1.Directory := RutaEscenario;
  sttTitulo.Caption := '';
  sttComentarios.Caption := '';
end;

procedure TfrmSeleccionarEscenario.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(Escenario);
end;

procedure TfrmSeleccionarEscenario.Dibuja(Sender: TObject);
begin
  Plataforma := ptbVistaPrevia.Canvas;
  DibujaEscenario(Sender as TEscenario);
  Plataforma := frmEditorEntornos.ptbEntorno.Canvas;
end;

initialization
  {$i SeleccionarEscenario.lrs}
  {$i SeleccionarEscenario.lrs}

end.
