unit Morfologia;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ComCtrls, LResources;

type
  TfrmMorfologia = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    stgContinuos: TStringGrid;
    stgDiscretos: TStringGrid;
    chbInicializar: TCheckBox;
    StaticText1: TStaticText;
    spbNotas: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure stgContinuosDblClick(Sender: TObject);
    procedure stgDiscretosDblClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure stgContinuosKeyPress(Sender: TObject; var Key: Char);
    procedure stgDiscretosKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure ExportaValores;
  public
    { Public declarations }
  end;

var
  frmMorfologia: TfrmMorfologia;

implementation

uses
  Multilenguaje, EditorAgentes, EditorFormulas, EditorNotas;


procedure TfrmMorfologia.FormCreate(Sender: TObject);
begin
  ImportaValores;
end;

procedure TfrmMorfologia.ExportaValores;
var
  i : Integer;
begin
  with stgContinuos do
  begin
    for i := 1 to 15 do
    begin
      frmEditorAgentes.CambiaNombreVariable
            (frmEditorAgentes.JuegoAgentes.Continuos[i].Nombre, Cells[1,i]);
      frmEditorAgentes.CambiaNombreVariableSufijos
            (frmEditorAgentes.JuegoAgentes.Continuos[i].Nombre, Cells[1,i]);
      frmEditorAgentes.JuegoAgentes.Continuos[i].Nombre := Cells[1,i];
      frmEditorAgentes.JuegoAgentes.Continuos[i].Omision := Cells[2,i];
    end;
  end;  //with
  with stgDiscretos do
  begin
    for i := 1 to 15 do
    begin
      frmEditorAgentes.CambiaNombreVariable
            (frmEditorAgentes.JuegoAgentes.Discretos[i].Nombre, Cells[1,i]);
      frmEditorAgentes.CambiaNombreVariableSufijos
            (frmEditorAgentes.JuegoAgentes.Discretos[i].Nombre, Cells[1,i]);
      frmEditorAgentes.JuegoAgentes.Discretos[i].Nombre := Cells[1,i];
      frmEditorAgentes.JuegoAgentes.Discretos[i].Omision := Cells[2,i];
    end;
  end; //with
end;

procedure TfrmMorfologia.ImportaValores;
var
  i: Integer;
begin
  with stgContinuos do
  begin
    Cells[0,0] := '#/' + ML(mlPropiedades);
    for i := 1 to 15 do
      Cells[0,i] := IntToStr(i);
    Cells[1,0] := ML(mlNombre);
    Cells[2,0] := ML(mlDefecto);
    for i := 1 to RowCount - 1 do
    begin
      Cells[1,i] := frmEditorAgentes.JuegoAgentes.Continuos[i].Nombre;
      Cells[2,i] := frmEditorAgentes.JuegoAgentes.Continuos[i].Omision;;
    end;
  end;
  with stgDiscretos do
  begin
    Cells[0,0] := '#/' + ML(mlPropiedades);
    for i := 1 to 15 do
      Cells[0,i] := IntToStr(i);
    Cells[1,0] := ML(mlNombre);
    Cells[2,0] := ML(mlDefecto);
    for i := 1 to RowCount - 1 do
    begin
      Cells[1,i] := frmEditorAgentes.JuegoAgentes.Discretos[i].Nombre;
      Cells[2,i] := frmEditorAgentes.JuegoAgentes.Discretos[i].Omision;
    end;
  end; //with
end;

procedure TfrmMorfologia.BitBtn1Click(Sender: TObject);
begin
  ExportaValores;
end;

procedure TfrmMorfologia.stgContinuosDblClick(Sender: TObject);
begin
  with stgContinuos do
  begin
    if Col <> 2 then
      Exit; //-->
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlMorfologia) + '-' + Cells[1,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMorfologia.stgDiscretosDblClick(Sender: TObject);
begin
  with stgDiscretos do
  begin
    if Col <> 2 then
      Exit; //-->
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlMorfologia) + '-' + Cells[1,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmMorfologia.spbNotasClick(Sender: TObject);
var
  Apartados: TStringList;
  i: Integer;
begin
  Apartados := TStringList.Create;
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Morfologia';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  for i := 0 to PageControl1.PageCount - 1 do
    Apartados.Add(PageControl1.Pages[i].Caption);
  frmEditorNotas.CreaApartados(Apartados);
  frmEditorNotas.Show;
  FreeAndNil(Apartados);
end;

procedure TfrmMorfologia.stgContinuosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if stgContinuos.Col = 1 then
    if not (Key in ['0'..'9', 'a'..'z', 'A'..'Z', '_', #8]) then
      Key := #0;
end;

procedure TfrmMorfologia.stgDiscretosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if stgDiscretos.Col = 1 then
    if not (Key in ['0'..'9', 'a'..'z', 'A'..'Z', '_', #8]) then
      Key := #0;
end;

procedure TfrmMorfologia.FormClose(Sender: TObject;
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
  {$i Morfologia.lrs}
  {$i Morfologia.lrs}

end.
