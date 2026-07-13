unit BuscarCarpeta;

{$MODE Delphi}

interface

{$WARN UNIT_PLATFORM OFF}
uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources;
{$WARN UNIT_PLATFORM ON}

type
  TfrmBuscarCarpeta = class(TForm)
   // DriveComboBox1: TDriveComboBox;
    //DirectoryListBox1: TDirectoryListBox;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    lblTitulo: TLabel;
    procedure DirectoryListBox1Change(Sender: TObject);
  private
    FTitulo: string;
    FDirectorio: string;
    procedure SetTitulo(const Value: string);
    procedure SetDirectorio(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    property Titulo: string
      read FTitulo write SetTitulo;
    property Directorio: string
      read FDirectorio write SetDirectorio;
  end;

var
  frmBuscarCarpeta: TfrmBuscarCarpeta;

implementation


procedure TfrmBuscarCarpeta.SetDirectorio(const Value: string);
begin
  FDirectorio := Value;
  //DirectoryListBox1.Directory := Value;
end;

procedure TfrmBuscarCarpeta.SetTitulo(const Value: string);
begin
  FTitulo := Value;
  lblTitulo.Caption := Value + ':';
end;

procedure TfrmBuscarCarpeta.DirectoryListBox1Change(Sender: TObject);
begin
  //FDirectorio := DirectoryListBox1.Directory;
end;

initialization
  {$i BuscarCarpeta.lrs}
  {$i BuscarCarpeta.lrs}

end.
