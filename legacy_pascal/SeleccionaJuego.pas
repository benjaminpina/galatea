unit SeleccionaJuego;

{$MODE Delphi}

{$WARN UNIT_PLATFORM OFF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Buttons, Sustratos, LResources;

type

  { TfrmSeleccionaJuego }

  TfrmSeleccionaJuego = class(TForm)
   // DriveComboBox1: TDriveComboBox;
   // DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    sttTitulo: TStaticText;
    sttComentarios: TStaticText;
    lstSustratos: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    NombreArchivo: string;
    JuegoSustratos: TJuegoSustratos;
  end;

var
  frmSeleccionaJuego: TfrmSeleccionaJuego;

implementation


uses
  Multilenguaje, Comunes;

procedure TfrmSeleccionaJuego.FormCreate(Sender: TObject);
var
  RutaSustrato: string;
begin
  RutaSustrato := ExtractFilePath(Application.ExeName) + ML(mlSustratos) + Diag;
  if DirectoryExists(RutaSustrato) then
    FileListBox1.Directory := RutaSustrato;
  sttTitulo.Caption := '';
  sttComentarios.Caption := '';
  NombreArchivo := '';
end;

procedure TfrmSeleccionaJuego.FileListBox1Change(Sender: TObject);
var
  i     : Integer;
  Simple: TSustratoSimple;
begin
  if FileListBox1.FileName = '' then
    Exit; //-->
  if Assigned(JuegoSustratos) then
    FreeAndNil(JuegoSustratos);
  NombreArchivo := FileListBox1.FileName;
  JuegoSustratos := TJuegoSustratos.Create;
  JuegoSustratos.Carga(NombreArchivo);
  sttTitulo.Caption := JuegoSustratos.Titulo;
  sttComentarios.Caption := JuegoSustratos.Comentarios;
  lstSustratos.Clear;
  for i := 1 to 7 do
  begin
    Simple := JuegoSustratos.SustratoSimple[i];
    lstSustratos.Items.Add(Simple.Nombre);
  end;
end;

procedure TfrmSeleccionaJuego.BitBtn1Click(Sender: TObject);
begin
  if not FileExists(NombreArchivo) then
    ModalResult := mrCancel;
end;

procedure TfrmSeleccionaJuego.FileListBox1DblClick(Sender: TObject);
begin
  if FileExists(NombreArchivo) then
    ModalResult := mrOK;
end;

initialization
  {$i SeleccionaJuego.lrs}

end.
