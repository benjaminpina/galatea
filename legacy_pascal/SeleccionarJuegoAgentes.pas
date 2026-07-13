unit SeleccionarJuegoAgentes;

{$MODE Delphi}

{$WARN UNIT_PLATFORM OFF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl, LResources;

type
  TfrmSeleccionarJuegoAgentes = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    //DriveComboBox1: TDriveComboBox;
    //DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    sttTitulo: TStaticText;
    sttComentarios: TStaticText;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lstEstadios: TListBox;
    lstMachos: TListBox;
    lstHembras: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    NombreArchivo: string;
  end;

var
  frmSeleccionarJuegoAgentes: TfrmSeleccionarJuegoAgentes;

implementation

uses
  Multilenguaje, JuegoAgentes, Comunes;

var
  Juego: TJuegoAgentes;


procedure TfrmSeleccionarJuegoAgentes.FormCreate(Sender: TObject);
//var
  //RutaAgentes: string;
begin
  //RutaAgentes := ExtractFilePath(Application.ExeName) + ML(mlAgentes)+ Diag;
  //if DirectoryExists(RutaAgentes) then
    //DirectoryListBox1.Directory := RutaAgentes;
  sttTitulo.Caption := '';
  sttComentarios.Caption := '';
end;

procedure TfrmSeleccionarJuegoAgentes.FileListBox1Change(Sender: TObject);
var
  i: Integer;
begin
  lstEstadios.Clear;
  lstMachos.Clear;
  lstHembras.Clear;
  if FileListBox1.FileName = '' then
    Exit; //-->
  if Assigned(Juego) then
    FreeAndNil(Juego);
  Juego := TJuegoAgentes.Create;
  Juego.Carga(FileListBox1.FileName);
  with Juego do
  begin
    sttTitulo.Caption := Titulo;
    sttComentarios.Caption := Comentarios;
    for i := 1 to NumEstadios do
      lstEstadios.Items.Add(Estadios[i].Nombre);
    for i := 1 to NumPrototiposM do
      lstMachos.Items.Add(PrototiposM[i].Nombre);
    for i := 1 to NumPrototiposH do
      lstHembras.Items.Add(PrototiposH[i].Nombre);
  end;
  NombreArchivo := FileListBox1.FileName;
end;

procedure TfrmSeleccionarJuegoAgentes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(Juego);
end;

initialization
  {$i SeleccionarJuegoAgentes.lrs}
  {$i SeleccionarJuegoAgentes.lrs}

end.
