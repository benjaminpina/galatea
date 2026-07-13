unit Estadios;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Grids, ExtCtrls, LResources;

type
  TfrmEstadios = class(TForm)
    GroupBox1: TGroupBox;
    lstEstadios: TListBox;
    sbtAgregar: TSpeedButton;
    sbtEliminar: TSpeedButton;
    sbtModificar: TSpeedButton;
    btbAceptar: TBitBtn;
    Label3: TLabel;
    spbSube: TSpeedButton;
    spbBaja: TSpeedButton;
    shpColor: TShape;
    procedure FormCreate(Sender: TObject);
    procedure sbtModificarClick(Sender: TObject);
    procedure lstEstadiosDblClick(Sender: TObject);
    procedure sbtAgregarClick(Sender: TObject);
    procedure sbtEliminarClick(Sender: TObject);
    procedure lstEstadiosClick(Sender: TObject);
    procedure spbSubeClick(Sender: TObject);
    procedure spbBajaClick(Sender: TObject);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure EditarEstadio;
  public
    { Public declarations }
  end;

var
  frmEstadios: TfrmEstadios;

implementation

uses
  EditorAgentes, EditarEstadio, JuegoAgentes, Multilenguaje, Dialogos, Comunes;


procedure TfrmEstadios.EditarEstadio;
var
  i: Integer;
begin
  frmEditarEstadio := TfrmEditarEstadio.Create(Application);
  i := lstEstadios.ItemIndex + 1;
  frmEditarEstadio.Indice := i;
  frmEditarEstadio.ImportaValores;
  if frmEditarEstadio.ShowModal = mrOk then
  begin
    frmEditarEstadio.ExportaValores;
    frmEditorAgentes.Salvado := False;
  end;
  ImportaValores;
  lstEstadios.ItemIndex := i - 1;
  shpColor.Brush.Color := frmEditorAgentes.JuegoAgentes.Estadios[i].Color;
  FreeAndNil(frmEditarEstadio);
end;

procedure TfrmEstadios.FormCreate(Sender: TObject);
begin
  ImportaValores;
  if frmEditorAgentes.JuegoAgentes.NumEstadios = 1 then
    sbtEliminar.Enabled := False;
  spbSube.Enabled := False;
end;

procedure TfrmEstadios.ImportaValores;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    lstEstadios.Clear;
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Prototipo = 0 then
        lstEstadios.Items.Add(Estadios[i].Nombre)
      else
      begin
        lstEstadios.Items.Add(Estadios[i].Nombre + '[' + Ligado(i) + ']')
      end;
    end;
    lstEstadios.ItemIndex := 0;
    shpColor.Brush.Color := Estadios[1].Color;
  end;
end;

procedure TfrmEstadios.sbtModificarClick(Sender: TObject);
begin
  EditarEstadio;
  shpColor.Brush.Color :=
          frmEditorAgentes.JuegoAgentes.Estadios[lstEstadios.ItemIndex+1].Color;
end;

procedure TfrmEstadios.lstEstadiosDblClick(Sender: TObject);
begin
  EditarEstadio;
end;

procedure TfrmEstadios.sbtAgregarClick(Sender: TObject);
var
  Estadio    : TEstadio;
  i, j       : Integer;
  OmisionDisc: Word;
begin
  OmisionDisc :=
      frmEditorAgentes.ArchivoInicio.ReadInteger
      ('GeneralesEditorAgentes', 'OmisionDiscretas', 2);
  with frmEditorAgentes.JuegoAgentes do
  begin
    i := NumEstadios;
    InsertaEstadio;
    frmEditorAgentes.InicializaEstadios(i + 1, i + 1, OmisionDisc, False);
    Estadio := Estadios[i+1];
    Estadio.Nombre := ML(mlInmaduro) + IntToStr(i);
    Estadios[i+1] := Estadio;
    ImportaValores;
    for j := 1 to 7 do  //Número de sustratos = 7
      MatrizSustratos.Celda[j,NumEstadios] := '1,' + NVeces('0,', 11);
    for j := 1 to 5 do  //Número de elementos dinámicos = 5
      MatrizDinamicos.Celda[j, NumEstadios] := '1,' + NVeces('0,', 11);
    for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
    begin
      MatrizAgentes.Celda[j, NumEstadios] := '1,' + NVeces('0,', 11);
      MatrizAgentes.Celda[NumEstadios, j] := '1,' + NVeces('0,', 11);
    end;
    MatrizAgentes.Celda[NumEstadios,1] := NVeces('0,', 12);
    for j := NumEstadios + 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      MatrizAgentes.Celda[NumEstadios,j] := '1,' + NVeces('0,', 11);
  end;
  lstEstadios.ItemIndex := i;
  shpColor.Brush.Color := clWhite;
  sbtEliminar.Enabled := True;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmEstadios.sbtEliminarClick(Sender: TObject);
var
  Num: Integer;
begin
  Num := lstEstadios.ItemIndex + 1;
  if PreguntaSN(ML(mlElmnrEstd), ML(mlEdAgntGlt))= rSi then
          //¿seguro de eliminar?
    frmEditorAgentes.JuegoAgentes.BorraEstadio(Num)
  else
    Exit; //-->
  ImportaValores;
  if Num > 1 then
    lstEstadios.ItemIndex := Num - 2
  else
    lstEstadios.ItemIndex := 0;
  if frmEditorAgentes.JuegoAgentes.NumEstadios = 1 then
    sbtEliminar.Enabled := False;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmEstadios.lstEstadiosClick(Sender: TObject);
begin
  if lstEstadios.ItemIndex = -1 then
  	lstEstadios.ItemIndex := 0;
  with frmEditorAgentes.JuegoAgentes do
  begin
    shpColor.Brush.Color := Estadios[lstEstadios.ItemIndex + 1].Color;
    spbSube.Enabled := lstEstadios.ItemIndex > 0;
    spbBaja.Enabled := lstEstadios.ItemIndex < NumEstadios - 1;
  end;
end;

procedure TfrmEstadios.spbSubeClick(Sender: TObject);
var
  Estadio: TEstadio;
  i:       Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    i :=  lstEstadios.ItemIndex + 1;
    Estadio :=  Estadios[i];
    Estadios[i] := Estadios[i-1];
    Estadios[i-1] := Estadio;
    ImportaValores;
    lstEstadios.ItemIndex := i-2;
    shpColor.Brush.Color := Estadios[i-1].Color;
    if lstEstadios.ItemIndex = 0 then
      spbSube.Enabled := False;
    spbBaja.Enabled := True;
    frmEditorAgentes.Salvado := False;
  end;
end;

procedure TfrmEstadios.spbBajaClick(Sender: TObject);
var
  Estadio: TEstadio;
  i:       Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    i :=  lstEstadios.ItemIndex + 1;
    Estadio :=  Estadios[i];
    Estadios[i] := Estadios[i+1];
    Estadios[i+1] := Estadio;
    ImportaValores;
    lstEstadios.ItemIndex := i;
    shpColor.Brush.Color := Estadios[i+1].Color;
    if lstEstadios.ItemIndex = NumEstadios - 1 then
      spbBaja.Enabled := False;
    spbSube.Enabled := True;
    frmEditorAgentes.Salvado := False;
  end;
end;

initialization
  {$i Estadios.lrs}
  {$i Estadios.lrs}

end.
