unit Genetica;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ComCtrls, LResources;

type
  TfrmGenetica = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    stgContinuos: TStringGrid;
    stgDiscretos: TStringGrid;
    spbNotas: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure stgContinuosKeyPress(Sender: TObject; var Key: Char);
    procedure stgDiscretosKeyPress(Sender: TObject; var Key: Char);
    procedure spbNotasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    function Valida: Boolean;
    procedure ImportaValores;
    procedure ExportaValores;
  public
    { Public declarations }
  end;

var
  frmGenetica: TfrmGenetica;

implementation

uses
  Multilenguaje, EditorAgentes, Dialogos, EditorNotas;



procedure TfrmGenetica.FormCreate(Sender: TObject);
begin
  ImportaValores;
  PuedeCerrar := True;
end;

procedure TfrmGenetica.ExportaValores;
var
  i : Integer;
begin
  with stgContinuos do
  begin
    for i := 1 to RowCount - 1 do
    begin
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].Dominante :=
                                                        StrToFloat(Cells[1,i]);
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].Recesivo :=
                                                        StrToFloat(Cells[2,i]);
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].MutacionD :=
                                                        StrToFloat(Cells[3,i]);
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].MutacionR :=
                                                        StrToFloat(Cells[4,i]);
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].RangoMutacionD :=
                                                        StrToFloat(Cells[5,i]);
      frmEditorAgentes.JuegoAgentes.LociContinuos[i].RangoMutacionR :=
                                                        StrToFloat(Cells[6,i]);
    end;
  end;
  with stgDiscretos do
  begin
    for i := 1 to RowCount - 1 do
    begin
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].Dominante :=
                                                        StrToInt(Cells[1,i]);
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].Recesivo :=
                                                        StrToInt(Cells[2,i]);
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].MutacionD
                                                      := StrToFloat(Cells[3,i]);
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].MutacionR
                                                      := StrToFloat(Cells[4,i]);
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].RangoMutacionD
                                                      := StrToInt(Cells[5,i]);
      frmEditorAgentes.JuegoAgentes.LociDiscretos[i].RangoMutacionR
                                                      := StrToInt(Cells[6,i]);
    end;
  end; //with
end;

procedure TfrmGenetica.ImportaValores;
var
  i: Integer;
  s: string;
begin
  with stgContinuos do
  begin
    Cells[0,0] := '#\' + ML(mlValores);
    for i := 1 to 15 do
      Cells[0,i] := 'CL' + IntToStr(i);
    Cells[1,0] := ML(mlDominante);
    Cells[2,0] := ML(mlRecesivo);
    Cells[3,0] := ML(mlTasaMutacion) + ' ' + ML(mlDominante);
    Cells[4,0] := ML(mlTasaMutacion) + ' ' +  ML(mlRecesivo);
    Cells[5,0] := ML(mlRangoMut) + ' ' +  ML(mlDominante);
    Cells[6,0] := ML(mlRangoMut) + ' ' +  ML(mlRecesivo);
    for i := 1 to 6 do
      ColWidths[i] := 110;
    for i := 1 to RowCount - 1 do
    begin
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].Dominante);
      Cells[1,i] := s;
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].Recesivo);
      Cells[2,i] := s;
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].MutacionD);
      Cells[3,i] := s;
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].MutacionR);
      Cells[4,i] := s;
      s :=
      FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].RangoMutacionD);
      Cells[5,i] := s;
      s :=
      FloatToStr(frmEditorAgentes.JuegoAgentes.LociContinuos[i].RangoMutacionR);
      Cells[6,i] := s;
    end;
  end;
  with stgDiscretos do
  begin
    Cells[0,0] := '#\' + ML(mlValores);
    for i := 1 to 15 do
      Cells[0,i] := 'DL' + IntToStr(i);
    Cells[1,0] := ML(mlDominante);
    Cells[2,0] := ML(mlRecesivo);
    Cells[3,0] := ML(mlTasaMutacion) + ' ' + ML(mlDominante);
    Cells[4,0] := ML(mlTasaMutacion) + ' ' + ML(mlRecesivo);
    Cells[5,0] := ML(mlRangoMut) + ' ' + ML(mlDominante);
    Cells[6,0] := ML(mlRangoMut) + ' ' + ML(mlRecesivo);
    for i := 1 to 6 do
      ColWidths[i] := 110;
    for i := 1 to RowCount - 1 do
    begin
      s := IntToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].Dominante);
      Cells[1,i] := s;
      s := IntToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].Recesivo);
      Cells[2,i] := s;
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].MutacionD);
      Cells[3,i] := s;
      s := FloatToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].MutacionR);
      Cells[4,i] := s;
      s :=
      FloatToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].RangoMutacionD);
      Cells[5,i] := s;
      s :=
      FloatToStr(frmEditorAgentes.JuegoAgentes.LociDiscretos[i].RangoMutacionR);
      Cells[6,i] := s;
    end;
  end; //with
end;

procedure TfrmGenetica.BitBtn1Click(Sender: TObject);
begin
  if Valida then
  begin
    ExportaValores;
    PuedeCerrar := True;
  end
  else
    PuedeCerrar := False;
end;

function TfrmGenetica.Valida: Boolean;
var
  i, j: Integer;
  r: Real;
begin
  with stgContinuos do
  begin
    for j := 1 to 4 do
      for i := 3 to 4 do
      begin
        r := StrToFloat(Cells[i,j]);
        if r > 1 then
        begin
          Fallo(ML(mlErrMtcnMnr1), ML(mlEdAgntGlt));
          Col := i;
          Row := j;
          Result := False;
          Exit; //-->
        end;  //if
      end;  // for
  end;  //with
  with stgDiscretos do
  begin
    for j := 1 to 15 do
      for i := 3 to 4 do
      begin
        r := StrToFloat(Cells[i,j]);
        if r > 1 then
        begin
          Fallo(ML(mlErrMtcnMnr1), ML(mlEdAgntGlt));
          Col := i;
          Row := j;
          Result := False;
          Exit; //-->
        end;  //if
      end;  // for
  end;  //with
  Result := True;
end;

procedure TfrmGenetica.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmGenetica.stgContinuosKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #13, #8]) then
    Key := #0;
end;

procedure TfrmGenetica.stgDiscretosKeyPress(Sender: TObject;
  var Key: Char);
begin
  case stgDiscretos.Col of
    1,2,5,6:
    if not (Key in ['0'..'9', #13, #8]) then
      Key := #0;
  else
    if not (Key in ['0'..'9', '.', #13, #8]) then
      Key := #0;
  end;
end;

procedure TfrmGenetica.spbNotasClick(Sender: TObject);
var
  Apartados: TStringList;
  i: Integer;
begin
  Apartados := TStringList.Create;
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Genetica';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  for i := 0 to PageControl1.PageCount - 1 do
    Apartados.Add(PageControl1.Pages[i].Caption);
  frmEditorNotas.CreaApartados(Apartados);
  frmEditorNotas.ShowModal;
  //frmEditorNotas.Show;
  FreeAndNil(Apartados);
  FreeAndNil(frmEditorNotas);
end;

procedure TfrmGenetica.FormClose(Sender: TObject;
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
  {$i Genetica.lrs}
  {$i Genetica.lrs}

end.
