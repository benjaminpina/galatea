unit Asignacion;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ComCtrls, LResources;

type
  TfrmAsignacion = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    stgValoresM: TStringGrid;
    GroupBox2: TGroupBox;
    spbSubirM: TSpeedButton;
    spbBajarM: TSpeedButton;
    lstJerarquiaM: TListBox;
    GroupBox3: TGroupBox;
    stgValoresH: TStringGrid;
    GroupBox4: TGroupBox;
    spbSubirH: TSpeedButton;
    spbBajarH: TSpeedButton;
    lstJerarquiaH: TListBox;
    StaticText1: TStaticText;
    spbNotas: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure stgValoresMDblClick(Sender: TObject);
    procedure stgValoresHDblClick(Sender: TObject);
    procedure stgValoresMKeyPress(Sender: TObject; var Key: Char);
    procedure stgValoresHKeyPress(Sender: TObject; var Key: Char);
    procedure lstJerarquiaMClick(Sender: TObject);
    procedure lstJerarquiaHClick(Sender: TObject);
    procedure spbSubirHClick(Sender: TObject);
    procedure spbSubirMClick(Sender: TObject);
    procedure spbBajarHClick(Sender: TObject);
    procedure spbBajarMClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure ExportaValores;
  public
    { Public declarations }
  end;

var
  frmAsignacion: TfrmAsignacion;

implementation

uses
  Multilenguaje, Comunes, EditorAgentes, EditorFormulas,
  EditorNotas;


procedure TfrmAsignacion.ExportaValores;
var
  i, j: Integer;
  s   : string;
begin
  with stgValoresM do
  begin
    for i := 0 to 2 do
      for j := 0 to frmEditorAgentes.JuegoAgentes.NumPrototiposM - 1 do
        frmEditorAgentes.JuegoAgentes.CriteriosM[i,j] := Cells[i+1,j+1];
  end;  //with
  with stgValoresH do
  begin
    for i := 0 to 2 do
      for j := 0 to frmEditorAgentes.JuegoAgentes.NumPrototiposH - 1 do
        frmEditorAgentes.JuegoAgentes.CriteriosH[i,j] := Cells[i+1,j+1];
  end;  //with
  with frmEditorAgentes.JuegoAgentes do
  begin
    s := '';
    for i := 1 to NumPrototiposM do
      s := s + lstJerarquiaM.Items.Strings[i-1][1] + ',';
    JerarquiaM := s;
    s := '';
    for i := 1 to NumPrototiposH do
      s := s + lstJerarquiaH.Items.Strings[i-1][1] + ',';
    JerarquiaH := s;
  end; //with
end;

procedure TfrmAsignacion.FormCreate(Sender: TObject);
begin
  ImportaValores;
  with stgValoresM do
  begin
    ColWidths[0] := 80;
    ColWidths[1] := 150;
    ColWidths[2] := 50;
    ColWidths[3] := 150;
  end;
  with stgValoresH do
  begin
    ColWidths[0] := 80;
    ColWidths[1] := 150;
    ColWidths[2] := 50;
    ColWidths[3] := 150;
  end;
  lstJerarquiaM.ItemIndex := 0;
  lstJerarquiaH.ItemIndex := 0;
  spbSubirM.Enabled := False;
  spbSubirH.Enabled := False;
end;

procedure TfrmAsignacion.ImportaValores;
var
  i, j, k: Integer;            s: string;
begin
  with stgValoresM do
  begin
    RowCount := frmEditorAgentes.JuegoAgentes.NumPrototiposM + 1;
    Cells[0,0] := ML(mlPrototipos) + '\' + ML(mlValores);
    Cells[1,0] := ML(mlFormula);
    Cells[2,0] := ML(mlOperador);
    Cells[3,0] := ML(mlValor);
    for j := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposM do
      Cells[0,j] := frmEditorAgentes.JuegoAgentes.PrototiposM[j].Nombre;
    for i := 0 to 2 do
      for j := 0 to frmEditorAgentes.JuegoAgentes.NumPrototiposM - 1 do
        Cells[i+1,j+1] := frmEditorAgentes.JuegoAgentes.CriteriosM[i,j];
  end;  //with
  with stgValoresH do
  begin
    RowCount := frmEditorAgentes.JuegoAgentes.NumPrototiposH + 1;
    Cells[0,0] := ML(mlPrototipos) + '\' + ML(mlValores);
    Cells[1,0] := ML(mlFormula);
    Cells[2,0] := ML(mlOperador);
    Cells[3,0] := ML(mlValor);
    for j := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposH do
      Cells[0,j] := frmEditorAgentes.JuegoAgentes.PrototiposH[j].Nombre;
    for i := 0 to 2 do
      for j := 0 to frmEditorAgentes.JuegoAgentes.NumPrototiposH - 1 do
        Cells[i+1,j+1] := frmEditorAgentes.JuegoAgentes.CriteriosH[i,j];
  end;  //with
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to NumPrototiposM do
    begin
      k := StrToInt(ObtenNsimo(JerarquiaM,i));
      s := PrototiposM[k].Nombre;
      if s = '' then ;
      lstJerarquiaM.Items.Add(ObtenNsimo(JerarquiaM, i) + ' ' +
                                                        PrototiposM[k].Nombre);
    end;
    for i := 1 to NumPrototiposH do
    begin
      k := StrToInt(ObtenNsimo(JerarquiaH,i));
      lstJerarquiaH.Items.Add(ObtenNsimo(JerarquiaH, i) + ' ' +
                                                        PrototiposH[k].Nombre);
    end;
    if NumPrototiposM = 1 then
      spbBajarM.Enabled := False;
    if NumPrototiposH = 1 then
      spbBajarH.Enabled := False;
  end; //with
end;

procedure TfrmAsignacion.BitBtn1Click(Sender: TObject);
begin
  ExportaValores;
end;

procedure TfrmAsignacion.stgValoresMDblClick(Sender: TObject);
begin
  with stgValoresM do
  begin
    if Col <> 1 then
      Exit; //-->
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlCrtrsAsgnc) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmAsignacion.stgValoresHDblClick(Sender: TObject);
begin
  with stgValoresH do
  begin
    if Col <> 1 then
      Exit; //-->
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := ML(mlCrtrsAsgnc) + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmAsignacion.stgValoresMKeyPress(Sender: TObject;
  var Key: Char);
begin
  case stgValoresM.Col of
    2:
    begin
      if not (Key in ['=', '<', '>', #8]) then
        Key := #0;
    end;
    3:
    begin
      if not (Key in ['0'..'9', '.', #8]) then
        Key := #0;
    end;
  end;
end;

procedure TfrmAsignacion.stgValoresHKeyPress(Sender: TObject;
  var Key: Char);
begin
  case stgValoresH.Col of
    2:
    begin
      if not (Key in ['=', '<', '>', #8]) then
        Key := #0;
    end;
    3:
    begin
      if not (Key in ['0'..'9', '.', #8]) then
        Key := #0;
    end;
  end;
end;

procedure TfrmAsignacion.lstJerarquiaMClick(Sender: TObject);
begin
  spbSubirM.Enabled := True;
  spbBajarM.Enabled := True;
  if lstJerarquiaM.ItemIndex = 0 then
    spbSubirM.Enabled := False;
  if lstJerarquiaM.ItemIndex = lstJerarquiaM.Count - 1 then
    spbBajarM.Enabled := False;
end;

procedure TfrmAsignacion.lstJerarquiaHClick(Sender: TObject);
begin
  spbSubirH.Enabled := True;
  spbBajarH.Enabled := True;
  if lstJerarquiaH.ItemIndex = 0 then
    spbSubirH.Enabled := False;
  if lstJerarquiaH.ItemIndex = lstJerarquiaH.Count - 1 then
    spbBajarH.Enabled := False;
end;

procedure TfrmAsignacion.spbSubirHClick(Sender: TObject);
var
  s: string;
begin
  with lstJerarquiaH do
  begin
    s := Items.Strings[ItemIndex];
    Items.Strings[ItemIndex] := Items.Strings[ItemIndex-1];
    Items.Strings[ItemIndex-1] := s;
    ItemIndex := ItemIndex - 1;
    spbSubirH.Enabled := True;
    spbBajarH.Enabled := True;
    if ItemIndex = 0 then
      spbSubirH.Enabled := False;
  end;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmAsignacion.spbSubirMClick(Sender: TObject);
var
  s: string;
begin
  with lstJerarquiaM do
  begin
    s := Items.Strings[ItemIndex];
    Items.Strings[ItemIndex] := Items.Strings[ItemIndex-1];
    Items.Strings[ItemIndex-1] := s;
    ItemIndex := ItemIndex - 1;
    spbSubirM.Enabled := True;
    spbBajarM.Enabled := True;
    if ItemIndex = 0 then
      spbSubirM.Enabled := False;
  end;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmAsignacion.spbBajarHClick(Sender: TObject);
var
  s: string;
begin
  with lstJerarquiaH do
  begin
    s := Items.Strings[ItemIndex];
    Items.Strings[ItemIndex] := Items.Strings[ItemIndex+1];
    Items.Strings[ItemIndex+1] := s;
    ItemIndex := ItemIndex + 1;
    spbSubirH.Enabled := True;
    spbBajarH.Enabled := True;
    if ItemIndex = Count - 1 then
      spbBajarH.Enabled := False;
  end;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmAsignacion.spbBajarMClick(Sender: TObject);
var
  s: string;
begin
  with lstJerarquiaM do
  begin
    s := Items.Strings[ItemIndex];
    Items.Strings[ItemIndex] := Items.Strings[ItemIndex+1];
    Items.Strings[ItemIndex+1] := s;
    ItemIndex := ItemIndex + 1;
    spbSubirM.Enabled := True;
    spbBajarM.Enabled := True;
    if ItemIndex = Count - 1 then
      spbBajarM.Enabled := False;
  end;
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmAsignacion.spbNotasClick(Sender: TObject);
begin
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Asignacion';
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  //frmEditorNotas.ShowModal;
  //FreeAndNil(frmEditorNotas);
  frmEditorNotas.Show;
end;

procedure TfrmAsignacion.FormClose(Sender: TObject;
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
  {$i Asignacion.lrs}
  {$i Asignacion.lrs}

end.
