unit MemoriaConducta;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, LResources;

type
  TfrmMemoriaConducta = class(TForm)
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    stgMemoria: TStringGrid;
    Label16: TLabel;
    Label1: TLabel;
    spbNotas: TSpeedButton;
    btnInicializar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure stgMemoriaDblClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure btnInicializarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure Encabezados;
    procedure ImportaValores;
    procedure ExportaValores;
  public
    { Public declarations }
  end;

var
  frmMemoriaConducta: TfrmMemoriaConducta;

implementation

uses
  EditorAgentes, EditorFormulas, Multilenguaje, EditorNotas;




{ TfrmMemoriaConducta }

procedure TfrmMemoriaConducta.Encabezados;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    stgMemoria.RowCount := NumEstadios + NumPrototiposM + NumPrototiposH + 1;
    stgMemoria.Cells[0,0] := ML(mlAgente) + '\' + ML(mlConducta);
    stgMemoria.Cells[1,0] := ML(mlMovimiento);
    stgMemoria.Cells[2,0] := ML(mlEnReposo);
    stgMemoria.Cells[3,0] := ML(mlBeber);
    stgMemoria.Cells[4,0] := ML(mlCmrAzucar);
    stgMemoria.Cells[5,0] := ML(mlCmrGrasa);
    stgMemoria.Cells[6,0] := ML(mlCmrProteina);
    stgMemoria.Cells[7,0] := '*' + ML(mlDesplegar);
    stgMemoria.Cells[8,0] := '*' + ML(mlEscalar);
    stgMemoria.Cells[9,0] := '*' + ML(mlRetirar);
    stgMemoria.Cells[10,0] := '*' + ML(mlIA);
    stgMemoria.Cells[11,0] := '*' + ML(mlIB);
    stgMemoria.Cells[12,0] := '*' + ML(mlRechazar);
    stgMemoria.Cells[13,0] := '*' + ML(mlCopular);
    stgMemoria.Cells[14,0] := '*' + ML(mlOvipositar);
    for i := 1 to NumEstadios do
      stgMemoria.Cells[0,i] := Estadios[i].Nombre;
    for i := 1 to NumPrototiposM do
      stgMemoria.Cells[0,i+NumEstadios] := PrototiposM[i].Nombre;
    for i := 1 to NumPrototiposH do
      stgMemoria.Cells[0,i+NumEstadios+NumPrototiposM] := PrototiposH[i].Nombre;
  end;
end;

procedure TfrmMemoriaConducta.ExportaValores;
var
  i, j: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j] := stgMemoria.Cells[i,j];
  end;
end;

procedure TfrmMemoriaConducta.ImportaValores;
var
  i, j: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        stgMemoria.Cells[i,j] := MatrizConductasM.Celda[i,j];
  end;
end;

procedure TfrmMemoriaConducta.FormCreate(Sender: TObject);
begin
  Encabezados;
  ImportaValores;
end;

procedure TfrmMemoriaConducta.btbAceptarClick(Sender: TObject);
begin
  ExportaValores;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmMemoriaConducta.stgMemoriaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgMemoria do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Adulto :=
                              (Row > frmEditorAgentes.JuegoAgentes.NumEstadios);
    frmEditorFormulas.Titulo := ML(mlMemoria) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMemoriaConducta.spbNotasClick(Sender: TObject);
begin
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Memoria';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  frmEditorNotas.Show;
  FreeAndNil(frmEditorNotas);
end;

procedure TfrmMemoriaConducta.btnInicializarClick(Sender: TObject);
var
  s: string;
  i, j: Integer;
begin
  s := '0';
  if InputQuery(ML(mlEdAgntGlt), ML(mlIniTdsClds), s) then
    for i := 1 to stgMemoria.ColCount - 1 do
      for j := 1 to stgMemoria.RowCount - 1 do
        stgMemoria.Cells[i,j] := s;
end;

procedure TfrmMemoriaConducta.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(frmEditorNotas) then
  begin
    frmEditorNotas.ExportaTexto;
    frmEditorNotas.Close;
    FreeAndNil(frmEditorNotas);
  end;
end;

initialization
  {$i MemoriaConducta.lrs}
  {$i MemoriaConducta.lrs}

end.
