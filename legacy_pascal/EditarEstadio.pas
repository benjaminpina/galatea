unit EditarEstadio;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, ComCtrls, LResources, Menus;

type

  { TfrmEditarEstadio }

  TfrmEditarEstadio = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    dlgColor: TColorDialog;
    Label16: TLabel;
    spbNotas: TSpeedButton;
    PageControl1: TPageControl;
    StaticText2: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tbsMoviemiento: TTabSheet;
    Label1: TLabel;
    edtNombre: TEdit;
    grbLigar: TGroupBox;
    Label6: TLabel;
    cmbPrototipos: TComboBox;
    grbColor: TGroupBox;
    shpColor: TShape;
    btnColor: TButton;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edtCiclos: TEdit;
    cmbY_O: TComboBox;
    cmbY_OR: TComboBox;
    cmbY_OC1C2: TComboBox;
    GroupBox1: TGroupBox;
    stgCostos: TStringGrid;
    GroupBox5: TGroupBox;
    stgCondiciones: TStringGrid;
    grbMovimiento: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label12: TLabel;
    Image4: TImage;
    Image5: TImage;
    Label13: TLabel;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Label14: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    edtNO: TEdit;
    edtN: TEdit;
    edtNE: TEdit;
    edtO: TEdit;
    edtE: TEdit;
    edtSO: TEdit;
    edtS: TEdit;
    edtSE: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure edtCiclosChange(Sender: TObject);
    procedure edtCiclosDblClick(Sender: TObject);
    procedure edtCiclosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure menEditorFormuasClick(Sender: TObject);
    procedure stgCostosDblClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure stgCondicionesDblClick(Sender: TObject);
    procedure stgCondicionesKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtNODblClick(Sender: TObject);
    procedure edtNDblClick(Sender: TObject);
    procedure edtNEDblClick(Sender: TObject);
    procedure edtODblClick(Sender: TObject);
    procedure edtEDblClick(Sender: TObject);
    procedure edtSODblClick(Sender: TObject);
    procedure edtSDblClick(Sender: TObject);
    procedure edtSEDblClick(Sender: TObject);
  private
    FIndice: Word;
    { Private declarations }
    procedure Encabezados;
    procedure SetIndice(const Value: Word);
  public
    { Public declarations }
    procedure ImportaValores;
    procedure ExportaValores;
    property Indice: Word read FIndice write SetIndice;
  end;

var
  frmEditarEstadio: TfrmEditarEstadio;

implementation

uses
  Multilenguaje, EditorAgentes, JuegoAgentes, EditorFormulas, EditorNotas,
  Comunes;


procedure TfrmEditarEstadio.Encabezados;
begin
  with stgCostos do
  begin
    Cells[0,0] := ML(mlValor) + '\' + ML(mlNutrimentos);
    Cells[1,0] := ML(mlAgua);
    Cells[2,0] := ML(mlAzucar);
    Cells[3,0] := ML(mlGrasa);
    Cells[4,0] := ML(mlProteina);
    Cells[0,1] := ML(mlRqrmnts);
    Cells[0,2] := ML(mlCostos);
  end;
  with stgCondiciones do
  begin
    Cells[0,0] := ML(mlCondicion) + '\' + ML(mlValores);
    Cells[1,0] := ML(mlFormula);
    Cells[2,0] := ML(mlOperador);
    Cells[3,0] := ML(mlValor);
    Cells[0,1] := ML(mlCondicion) + ' 1';
    Cells[0,2] := ML(mlCondicion) + ' 2';
  end;
end;

procedure TfrmEditarEstadio.ExportaValores;
var
  Estadio: TEstadio;
  i      : Integer;
begin
  Estadio.Nombre := edtNombre.Text;
  Estadio.Ciclos := edtCiclos.Text;
  Estadio.Y_O := (cmbY_O.ItemIndex = 0);
  Estadio.Y_OR := (cmbY_OR.ItemIndex = 0);
  Estadio.Y_OC1C2 := (cmbY_OC1C2.ItemIndex = 0);
  for i := 1 to 4 do
  begin
    Estadio.Requiere[i] := stgCostos.Cells[i,1];
    Estadio.Costos[i] := stgCostos.Cells[i,2];
  end;
  Estadio.Condicion1 := stgCondiciones.Cells[1,1] + ', '
                        + stgCondiciones.Cells[2,1] + ', '
                        + stgCondiciones.Cells[3,1];
  Estadio.Condicion2 := stgCondiciones.Cells[1,2] + ', '
                        + stgCondiciones.Cells[2,2] + ', '
                        + stgCondiciones.Cells[3,2];
  Estadio.Prototipo := cmbPrototipos.ItemIndex;
  Estadio.Color := shpColor.Brush.Color;
  Estadio.Tendencias[1] := edtNO.Text;
  Estadio.Tendencias[2] := edtN.Text;
  Estadio.Tendencias[3] := edtNE.Text;
  Estadio.Tendencias[4] := edtO.Text;
  Estadio.Tendencias[5] := edtE.Text;
  Estadio.Tendencias[6] := edtSO.Text;
  Estadio.Tendencias[7] := edtS.Text;
  Estadio.Tendencias[8] := edtSE.Text;
  with frmEditorAgentes.JuegoAgentes do
  begin
    frmEditorAgentes.CambiaNombreVariablePrefijos
                                      (Estadios[Indice].Nombre, Estadio.Nombre);
    Estadios[Indice] := Estadio;
  end;
end;

procedure TfrmEditarEstadio.FormCreate(Sender: TObject);
begin
  Encabezados;
end;

procedure TfrmEditarEstadio.ImportaValores;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    edtNombre.Text := Estadios[Indice].Nombre;
    edtCiclos.Text := Estadios[Indice].Ciclos;
    if Estadios[Indice].Y_O then
      cmbY_O.ItemIndex := 0 //Y
    else
      cmbY_O.ItemIndex := 1;  //O
    if Estadios[Indice].Y_OR then
      cmbY_OR.ItemIndex := 0 //Y
    else
      cmbY_OR.ItemIndex := 1;  //O
    if Estadios[Indice].Y_OC1C2 then
      cmbY_OC1C2.ItemIndex := 0 //Y
    else
      cmbY_OC1C2.ItemIndex := 1;  //O
    for i := 1 to 4 do
    begin
      stgCostos.Cells[i,1] := Estadios[Indice].Requiere[i];
      stgCostos.Cells[i,2] := Estadios[Indice].Costos[i];
    end;
    stgCondiciones.Cells[1,1] := ObtenNsimo(Estadios[Indice].Condicion1, 1);
    stgCondiciones.Cells[2,1] := ObtenNsimo(Estadios[Indice].Condicion1, 2);
    stgCondiciones.Cells[3,1] := ObtenNsimo(Estadios[Indice].Condicion1, 3);
    stgCondiciones.Cells[1,2] := ObtenNsimo(Estadios[Indice].Condicion2, 1);
    stgCondiciones.Cells[2,2] := ObtenNsimo(Estadios[Indice].Condicion2, 2);
    stgCondiciones.Cells[3,2] := ObtenNsimo(Estadios[Indice].Condicion2, 3);
    cmbPrototipos.Items.Add(ML(mlNinguno));
    for i := 1 to (NumPrototiposM) do
      cmbPrototipos.Items.Add(PrototiposM[i].Nombre + '(' + ML(mlMacho) + ')');
    for i := 1 to (NumPrototiposH) do
      cmbPrototipos.Items.Add(PrototiposH[i].Nombre + '(' + ML(mlHembra) + ')');
    cmbPrototipos.ItemIndex := Estadios[Indice].Prototipo;
    shpColor.Brush.Color := Estadios[Indice].Color;
    edtNO.Text := Estadios[Indice].Tendencias[1];
    edtN.Text := Estadios[Indice].Tendencias[2];
    edtNE.Text := Estadios[Indice].Tendencias[3];
    edtO.Text := Estadios[Indice].Tendencias[4];
    edtE.Text := Estadios[Indice].Tendencias[5];
    edtSO.Text := Estadios[Indice].Tendencias[6];
    edtS.Text := Estadios[Indice].Tendencias[7];
    edtSE.Text := Estadios[Indice].Tendencias[8];
  end;  //with JuegoAgentes
end;

procedure TfrmEditarEstadio.btnColorClick(Sender: TObject);
begin
  dlgColor.Color := shpColor.Brush.Color;
  if dlgColor.Execute then
    shpColor.Brush.Color := dlgColor.Color;
end;

procedure TfrmEditarEstadio.edtCiclosChange(Sender: TObject);
begin

end;



procedure TfrmEditarEstadio.edtCiclosDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCiclos.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlCambrEst);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCiclos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtCiclosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  		Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCiclos.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlCambrEst);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCiclos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarEstadio.menEditorFormuasClick(Sender: TObject);
begin

end;

procedure TfrmEditarEstadio.stgCostosDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Adulto := False;
  with stgCostos do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlRqrmnts) + '-'
                                            + Cells[0,Row] + '\' + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarEstadio.spbNotasClick(Sender: TObject);
begin
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  frmEditorNotas.Indice := 'Estadio' + IntToStr(Indice);
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  {frmEditorNotas.ShowModal;
  FreeAndNil(frmEditorNotas); }
  frmEditorNotas.Show;
end;

procedure TfrmEditarEstadio.stgCondicionesDblClick(Sender: TObject);
begin
  with stgCondiciones do
  begin
    if Col <> 1 then
      Exit; //-->
    frmEditorFormulas := TfrmEditorFormulas.Create(Application);
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Adulto := False;
    frmEditorFormulas.Titulo := edtNombre.Text + '-' + Cells[0,Row] + '\'
                                                                + Cells[Col,0];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarEstadio.stgCondicionesKeyPress(Sender: TObject;
  var Key: Char);
begin
  case stgCondiciones.Col of
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

procedure TfrmEditarEstadio.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(frmEditorNotas) then
  begin
    frmEditorNotas.ExportaTexto;
    frmEditorNotas.Close;
    FreeAndNil(frmEditorNotas);
  end;
end;

procedure TfrmEditarEstadio.edtNODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNO.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlNO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtNO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtNDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtN.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- N';
  if frmEditorFormulas.ShowModal = mrOK then
    edtN.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtNEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNE.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- NE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtNE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtO.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtE.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- E';
  if frmEditorFormulas.ShowModal = mrOK then
    edtE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtSODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSO.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlSO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtSO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtSDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtS.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- S';
  if frmEditorFormulas.ShowModal = mrOK then
    edtS.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.edtSEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSE.Text;
  frmEditorFormulas.Adulto := False;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- SE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtSE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarEstadio.SetIndice(const Value: Word);
begin
  FIndice := Value;
  if FIndice = 1 then   //Estadio huevo
  begin
    grbLigar.Visible := False;
    grbColor.Visible := False;
    grbMovimiento.Visible := False;
    tbsMoviemiento.Enabled := False;
  end;
end;

initialization
  {$i EditarEstadio.lrs}
  {$i EditarEstadio.lrs}

end.
