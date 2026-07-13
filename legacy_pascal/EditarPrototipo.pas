unit EditarPrototipo;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, Buttons, Comunes, ExtCtrls, LResources;

type

  { TfrmEditarPrototipo }

  TfrmEditarPrototipo = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    dlgColor: TColorDialog;
    Label12: TLabel;
    Label16: TLabel;
    spbNotas: TSpeedButton;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    grbProporcion: TGroupBox;
    Label24: TLabel;
    Label25: TLabel;
    edtMachos: TEdit;
    edtHembras: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    edtNombre: TEdit;
    edtLongevidad: TEdit;
    GroupBox3: TGroupBox;
    shpColor: TShape;
    btnColor: TButton;
    TabSheet4: TTabSheet;
    GroupBox2: TGroupBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    stgContinuos: TStringGrid;
    TabSheet2: TTabSheet;
    stgDiscretos: TStringGrid;
    TabSheet5: TTabSheet;
    GroupBox4: TGroupBox;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    stgCombate: TStringGrid;
    GroupBox5: TGroupBox;
    Label21: TLabel;
    edtRefractarioCombate: TEdit;
    TabSheet6: TTabSheet;
    GroupBox6: TGroupBox;
    Label31: TLabel;
    Label30: TLabel;
    Label29: TLabel;
    stgCortejo: TStringGrid;
    GroupBox7: TGroupBox;
    Label23: TLabel;
    edtRefractarioCortejo: TEdit;
    TabSheet7: TTabSheet;
    GroupBox8: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label7: TLabel;
    Image4: TImage;
    Image5: TImage;
    Label8: TLabel;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    edtNO: TEdit;
    edtN: TEdit;
    edtNE: TEdit;
    edtO: TEdit;
    edtE: TEdit;
    edtSO: TEdit;
    edtS: TEdit;
    edtSE: TEdit;
    procedure edtEDblClick(Sender: TObject);
    procedure edtHembrasDblClick(Sender: TObject);
    procedure edtLongevidadDblClick(Sender: TObject);
    procedure edtMachosDblClick(Sender: TObject);
    procedure edtNDblClick(Sender: TObject);
    procedure edtNEDblClick(Sender: TObject);
    procedure edtNODblClick(Sender: TObject);
    procedure edtODblClick(Sender: TObject);
    procedure edtRefractarioCombateDblClick(Sender: TObject);
    procedure edtRefractarioCortejoDblClick(Sender: TObject);
    procedure edtSDblClick(Sender: TObject);
    procedure edtSEDblClick(Sender: TObject);
    procedure edtSODblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure edtEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtHembrasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtLongevidadMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMachosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtNEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtNMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtNOMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtOMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtRefractarioCombateMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure edtRefractarioCortejoMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure edtSEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtSMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtSOMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PageControl2Change(Sender: TObject);
    procedure stgCombateDblClick(Sender: TObject);
    procedure stgCortejoDblClick(Sender: TObject);
    procedure stgContinuosDblClick(Sender: TObject);
    procedure stgDiscretosDblClick(Sender: TObject);
    procedure spbNotasClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure Encabezados;
  public
    { Public declarations }
    Indice: Word;
    Sexo: TSexo;
    procedure ImportaValores;
    procedure ExportaValores;
  end;

var
  frmEditarPrototipo: TfrmEditarPrototipo;

implementation

uses
  EditorAgentes, Multilenguaje, JuegoAgentes, EditorFormulas, EditorNotas;


procedure TfrmEditarPrototipo.FormCreate(Sender: TObject);
begin
  Encabezados;
end;

procedure TfrmEditarPrototipo.edtLongevidadDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtLongevidad.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlLongevidad);
  if frmEditorFormulas.ShowModal = mrOK then
    edtLongevidad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtHembrasDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtHembras.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlAsgncnSx)
                              + '-' + ML(mlHembras);
  if frmEditorFormulas.ShowModal = mrOK then
    edtHembras.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- E';
  if frmEditorFormulas.ShowModal = mrOK then
    edtE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtMachosDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMachos.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlAsgncnSx)
                              + '-' + ML(mlMachos);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMachos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtNDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtN.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- N';
  if frmEditorFormulas.ShowModal = mrOK then
    edtN.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtNEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- NE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtNE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtNODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlNO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtNO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtRefractarioCombateDblClick(Sender: TObject);
begin
   frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRefractarioCombate.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlRefractario)
                              + '-' + ML(mlCombate);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRefractarioCombate.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtRefractarioCortejoDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRefractarioCortejo.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlRefractario)
                              + '-' + ML(mlCortejo);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRefractarioCortejo.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtSDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtS.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- S';
  if frmEditorFormulas.ShowModal = mrOK then
    edtS.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtSEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- SE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtSE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.edtSODblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlSO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtSO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmEditarPrototipo.ImportaValores;
var
  i, j     : Integer;
  Prototipo: TPrototipo;
begin
  if Sexo = sxMacho then
  begin
    Prototipo := frmEditorAgentes.JuegoAgentes.PrototiposM[Indice];
    grbProporcion.Visible := False;
  end
  else
  begin
    Prototipo := frmEditorAgentes.JuegoAgentes.PrototiposH[Indice];
    edtMachos.Text :=
          frmEditorAgentes.JuegoAgentes.PrototiposH[Indice].ProporcionMachos;
    edtHembras.Text :=
          frmEditorAgentes.JuegoAgentes.PrototiposH[Indice].ProporcionHembras;
  end;
  edtNombre.Text := Prototipo.Nombre;
  for i := 1 to 15 do
  begin
    stgContinuos.Cells[1,i] := Prototipo.Continuos[i].ValorGenetico;
    stgContinuos.Cells[2,i] := Prototipo.Continuos[i].ValorAmbiental;
    stgDiscretos.Cells[1,i] := Prototipo.Discretos[i].ValorGenetico;
    stgDiscretos.Cells[2,i] := Prototipo.Discretos[i].ValorAmbiental;
  end;
  shpColor.Brush.Color := Prototipo.Color;
  edtLongevidad.Text := Prototipo.Longevidad;
  edtRefractarioCombate.Text := Prototipo.RefractarioCombate;
  edtRefractarioCortejo.Text := Prototipo.RefractarioCortejo;
  for i := 1 to 3 do
    for j := 1 to 2 do
      stgCombate.Cells[i,j] := Prototipo.Combate[i,j];
  for i := 1 to 4 do
    for j := 1 to 3 do
      stgCortejo.Cells[i,j] := Prototipo.Cortejo[i,j];
  edtNO.Text := Prototipo.Tendencias[1];
  edtN.Text := Prototipo.Tendencias[2];
  edtNE.Text := Prototipo.Tendencias[3];
  edtE.Text := Prototipo.Tendencias[4];
  edtO.Text := Prototipo.Tendencias[5];
  edtSO.Text := Prototipo.Tendencias[6];
  edtS.Text := Prototipo.Tendencias[7];
  edtSE.Text := Prototipo.Tendencias[8];
end;

procedure TfrmEditarPrototipo.ExportaValores;
var
  i, j: Integer;
  Prototipo: TPrototipo;
begin
  Prototipo.Nombre := edtNombre.Text;
  for i := 1 to 15 do
  begin
    Prototipo.Continuos[i].ValorGenetico := stgContinuos.Cells[1,i];
    Prototipo.Continuos[i].ValorAmbiental := stgContinuos.Cells[2,i];
    Prototipo.Discretos[i].ValorGenetico := stgDiscretos.Cells[1,i];
    Prototipo.Discretos[i].ValorAmbiental := stgDiscretos.Cells[2,i];
  end;
  Prototipo.Color := shpColor.Brush.Color;
  Prototipo.Longevidad := edtLongevidad.Text;
  Prototipo.RefractarioCombate := edtRefractarioCombate.Text;
  Prototipo.RefractarioCortejo := edtRefractarioCortejo.Text;
  for i := 1 to 3 do
    for j := 1 to 2 do
      Prototipo.Combate[i,j] := stgCombate.Cells[i,j];
  for i := 1 to 4 do
    for j := 1 to 3 do
      Prototipo.Cortejo[i,j] := stgCortejo.Cells[i,j];
  Prototipo.Tendencias[1] := edtNO.Text;
  Prototipo.Tendencias[2] := edtN.Text;
  Prototipo.Tendencias[3] := edtNE.Text;
  Prototipo.Tendencias[4] := edtE.Text;
  Prototipo.Tendencias[5] := edtO.Text;
  Prototipo.Tendencias[6] := edtSO.Text;
  Prototipo.Tendencias[7] := edtS.Text;
  Prototipo.Tendencias[8] := edtSE.Text;
  with frmEditorAgentes.JuegoAgentes do
  begin
    if Sexo = sxMacho then
    begin
      frmEditorAgentes.CambiaNombreVariablePrefijos(PrototiposM[Indice].Nombre,
                                                            Prototipo.Nombre);
      PrototiposM[Indice] := Prototipo;
    end
    else
    begin
      frmEditorAgentes.CambiaNombreVariablePrefijos(PrototiposH[Indice].Nombre,
                                                            Prototipo.Nombre);
      Prototipo.ProporcionMachos := edtMachos.Text;
      Prototipo.ProporcionHembras := edtHembras.Text;
      PrototiposH[Indice] := Prototipo;
    end;
  end;
end;

procedure TfrmEditarPrototipo.btnColorClick(Sender: TObject);
begin
  dlgColor.Color := shpColor.Brush.Color;
  if dlgColor.Execute then
    shpColor.Brush.Color := dlgColor.Color;
end;

procedure TfrmEditarPrototipo.edtEMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- E';
  if frmEditorFormulas.ShowModal = mrOK then
    edtE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtHembrasMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtHembras.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlAsgncnSx)
                              + '-' + ML(mlHembras);
  if frmEditorFormulas.ShowModal = mrOK then
    edtHembras.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.edtLongevidadMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtLongevidad.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlLongevidad);
  if frmEditorFormulas.ShowModal = mrOK then
    edtLongevidad.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtMachosMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMachos.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlAsgncnSx)
                              + '-' + ML(mlMachos);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMachos.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtNEMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- NE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtNE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.edtNMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtN.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- N';
  if frmEditorFormulas.ShowModal = mrOK then
    edtN.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.edtNOMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtNO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlNO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtNO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtOMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtRefractarioCombateMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRefractarioCombate.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlRefractario)
                              + '-' + ML(mlCombate);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRefractarioCombate.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.edtRefractarioCortejoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtRefractarioCortejo.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlRefractario)
                              + '-' + ML(mlCortejo);
  if frmEditorFormulas.ShowModal = mrOK then
    edtRefractarioCortejo.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);  }
end;

procedure TfrmEditarPrototipo.edtSEMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSE.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- SE';
  if frmEditorFormulas.ShowModal = mrOK then
    edtSE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.edtSMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtS.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '- S';
  if frmEditorFormulas.ShowModal = mrOK then
    edtS.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmEditarPrototipo.edtSOMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtSO.Text;
  frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlTndncsMvmnt)
      + '-' + ML(mlSO);
  if frmEditorFormulas.ShowModal = mrOK then
    edtSO.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas); }
end;

procedure TfrmEditarPrototipo.PageControl2Change(Sender: TObject);
begin

end;

procedure TfrmEditarPrototipo.Encabezados;
var
  i: Integer;
begin
  stgContinuos.Cells[0,0] := ML(mlCaracter);
  stgContinuos.Cells[1,0] := ML(mlGenetico);
  stgContinuos.Cells[2,0] := ML(mlAmbiental);
  stgContinuos.ColWidths[0] := 100;
  //stgContinuos.ColWidths[1] := 250;
  stgDiscretos.Cells[0,0] := ML(mlCaracter);
  stgDiscretos.Cells[1,0] := ML(mlGenetico);
  stgDiscretos.Cells[2,0] := ML(mlAmbiental);
  stgDiscretos.ColWidths[0] := 100;
  //stgDiscretos.ColWidths[1] := 250;
  for i := 1 to 15 do
  begin
    stgContinuos.Cells[0,i] :=
                            frmEditorAgentes.JuegoAgentes.Continuos[i].Nombre;
    stgDiscretos.Cells[0,i] :=
                            frmEditorAgentes.JuegoAgentes.Discretos[i].Nombre;
  end;
  with stgCombate do
  begin
    ColWidths[0] := 75;
    ColWidths[1] := 105;
    ColWidths[2] := 105;
    ColWidths[3] := 105;
    Cells[0,0] := ML(mlContendiente) + '\' + ML(mlPrototipo);
    Cells[1,0] := ML(mlDesplegar);
    Cells[2,0] := ML(mlEscalar);
    Cells[3,0] := ML(mlRetirar);
    Cells[0,1] := ML(mlDesplegar);
    Cells[0,2] := ML(mlEscalar);
  end;  //with
  with stgCortejo do
  begin
    ColWidths[0] := 75;
    ColWidths[1] := 80;
    ColWidths[2] := 80;
    ColWidths[3] := 80;
    ColWidths[4] := 80;
    Cells[0,0] := ML(mlContendiente) + '\' + ML(mlPrototipo);
    Cells[3,0] := ML(mlAceptacion);
    Cells[4,0] := ML(mlRechazar);
    Cells[0,3] := ML(mlAceptacion);
    //Cells[0,4] := ML(mlRechazar);
    Cells[1,0] := ML(mlIA);
    Cells[2,0] := ML(mlIB);
    Cells[0,1] := ML(mlIA);
    Cells[0,2] := ML(mlIB);
  end;  //with
end;

procedure TfrmEditarPrototipo.stgCombateDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.InteraccionAgente := True;
  with stgCombate do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlCombate) + '-'
                                + Cells[Col,0] + '\' + Cells[0,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarPrototipo.stgCortejoDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.InteraccionAgente := True;
  with stgCortejo do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := edtNombre.Text + '-' + ML(mlCortejo) + '-' 
                                + Cells[Col,0] + '\' + Cells[0,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarPrototipo.stgContinuosDblClick(Sender: TObject);
begin
 frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgContinuos do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    frmEditorFormulas.Titulo := edtNombre.Text + '-' + Cells[0,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarPrototipo.stgDiscretosDblClick(Sender: TObject);
begin
 frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  with stgDiscretos do
  begin
    frmEditorFormulas.Formula := Cells[Col,Row];
    if  frmEditorFormulas.ShowModal = mrOK then
      Cells[Col,Row] := frmEditorFormulas.Formula;
    FreeAndNil(frmEditorFormulas);
  end;
end;

procedure TfrmEditarPrototipo.spbNotasClick(Sender: TObject);
var
  Apartados: TStringList;
  i: Integer;
begin
  Apartados := TStringList.Create;
  if frmEditorAgentes.NombreArchivo = ML(mlJgoAgnts) then
    frmEditorAgentes.actGuardarComo.Execute;
  frmEditorNotas := TfrmEditorNotas.Create(Application);
  if Sexo = sxMacho then
    frmEditorNotas.Indice := 'PrototipoM' + IntToStr(Indice)
  else
    frmEditorNotas.Indice := 'PrototipoH' + IntToStr(Indice);
  frmEditorNotas.NombreArchivo := frmEditorAgentes.NombreArchivo;
  frmEditorNotas.ImportaTexto;
  for i := 0 to PageControl1.PageCount - 1 do
    Apartados.Add(PageControl1.Pages[i].Caption);
  frmEditorNotas.CreaApartados(Apartados);
  frmEditorNotas.Show;
  FreeAndNil(Apartados);
end;

procedure TfrmEditarPrototipo.FormClose(Sender: TObject;
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
  {$i EditarPrototipo.lrs}

end.
