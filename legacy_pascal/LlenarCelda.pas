unit LlenarCelda;

{$MODE Delphi}

interface

uses
  {Windows,} Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, LResources;

type

  { TfrmLlenarCelda }

  TfrmLlenarCelda = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    GroupBox2: TGroupBox;
    Label10: TLabel;
    edtAgua: TEdit;
    Label11: TLabel;
    edtAzucar: TEdit;
    Label12: TLabel;
    edtGrasa: TEdit;
    Label13: TLabel;
    edtProteina: TEdit;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    edtOviposicion: TEdit;
    Label15: TLabel;
    Label14: TLabel;
    edtMorir: TEdit;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    edtCombateD: TEdit;
    edtCombateE: TEdit;
    Label19: TLabel;
    Label20: TLabel;
    edtCortejoD: TEdit;
    edtCortejoE: TEdit;
    GroupBox1: TGroupBox;
    edtR: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtMoverse: TEdit;
    procedure btbAceptarClick(Sender: TObject);
    procedure edtAguaDblClick(Sender: TObject);
    procedure edtAguaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAzucarDblClick(Sender: TObject);
    procedure edtAzucarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtCombateDDblClick(Sender: TObject);
    procedure edtCombateDMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtCombateEDblClick(Sender: TObject);
    procedure edtCombateEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtCortejoDDblClick(Sender: TObject);
    procedure edtCortejoDMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtCortejoEDblClick(Sender: TObject);
    procedure edtCortejoEMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtGrasaDblClick(Sender: TObject);
    procedure edtGrasaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMorirDblClick(Sender: TObject);
    procedure edtMorirMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMoverseDblClick(Sender: TObject);
    procedure edtMoverseMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtOviposicionDblClick(Sender: TObject);
    procedure edtOviposicionMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtProteinaDblClick(Sender: TObject);
    procedure edtRDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtProteinaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtRMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FTitulo: string;
    { Private declarations }
    procedure ConstruyeCelda;
    procedure SetTitulo(const Value: string);
  public
    { Public declarations }
    Celda: string;
    InteraccionAgente: Boolean;
    Adulto: Boolean;
    Dinamico: Boolean;
    Huevo: Boolean;
    procedure Despliega;
    property Titulo: string
      read FTitulo write SetTitulo;
  end;

var
  frmLlenarCelda: TfrmLlenarCelda;

implementation

uses
  Comunes, EditorFormulas, Multilenguaje;


procedure TfrmLlenarCelda.btbAceptarClick(Sender: TObject);
begin
  ConstruyeCelda;
end;

procedure TfrmLlenarCelda.edtAguaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAgua.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlBeber);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAgua.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.ConstruyeCelda;
begin
  if Huevo then
  begin
    Celda := '0,' + edtR.Text + ',0,0,0,0,0,0,0,0,0,' + edtMorir.Text;
    Exit; //-->
  end;
  Celda := edtMoverse.Text + ',' + edtR.Text + ','  + edtAgua.Text + ','
            + edtAzucar.Text  + ',' + edtGrasa.Text + ',' + edtProteina.Text;
  if Adulto then
  begin
    Celda := Celda + ',' + edtCombateD.Text + ',' + edtCombateE.Text + ','
            + edtCortejoD.Text + ',' + edtCortejoE.Text + ','
            + edtOviposicion.Text;
  end
  else
    Celda := Celda + ',0,0,0,0,0';
  Celda := Celda  + ',' + edtMorir.Text;
end;

procedure TfrmLlenarCelda.Despliega;
begin
  edtMoverse.Text := ObtenNsimo(Celda, 1);
  edtR.Text := ObtenNsimo(Celda, 2);
  edtAgua.Text := ObtenNsimo(Celda, 3);
  edtAzucar.Text := ObtenNsimo(Celda, 4);
  edtGrasa.Text := ObtenNsimo(Celda, 5);
  edtProteina.Text := ObtenNsimo(Celda, 6);
  edtMorir.Text := ObtenNsimo(Celda, 12);
  if Adulto then
  begin
    edtCombateD.Text := ObtenNsimo(Celda, 7);
    edtCombateE.Text := ObtenNsimo(Celda, 8);
    edtCortejoD.Text := ObtenNsimo(Celda, 9);
    edtCortejoE.Text := ObtenNsimo(Celda, 10);
    edtOviposicion.Text := ObtenNsimo(Celda, 11);
  end
  else
  begin
    edtCombateD.Enabled := False;
    edtCombateE.Enabled := False;
    edtCortejoD.Enabled := False;
    edtCortejoE.Enabled := False;
    edtOviposicion.Enabled := False;
    edtCombateD.Text := '';
    edtCombateE.Text := '';
    edtCortejoD.Text := '';
    edtCortejoE.Text := '';
    edtOviposicion.Text := '';
  end;
  if Huevo then
  begin
    edtMoverse.Enabled := False;
    edtAgua.Enabled := False;
    edtAzucar.Enabled := False;
    edtGrasa.Enabled := False;
    edtProteina.Enabled := False;
    edtMoverse.Text := '';
    edtAgua.Text := '';
    edtAzucar.Text := '';
    edtGrasa.Text := '';
    edtProteina.Text := '';
  end;
end;

procedure TfrmLlenarCelda.edtAguaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAgua.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlBeber);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAgua.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtAzucarDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucar.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucar.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtAzucarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtAzucar.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrAzucar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtAzucar.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtCombateDDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCombateD.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlDesplegar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCombateD.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtCombateDMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCombateD.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlDesplegar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCombateD.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtCombateEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCombateE.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlEscalar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCombateE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtCombateEMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCombateE.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlEscalar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCombateE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtCortejoDDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCortejoD.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlIA);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCortejoD.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtCortejoDMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCortejoD.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlIA);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCortejoD.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtCortejoEDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCortejoE.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlIB);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCortejoE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtCortejoEMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtCortejoE.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlIB);
  if frmEditorFormulas.ShowModal = mrOK then
    edtCortejoE.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtGrasaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasa.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasa.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtGrasaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtGrasa.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrGrasa);
  if frmEditorFormulas.ShowModal = mrOK then
    edtGrasa.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtMorirDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMorir.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMorir);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMorir.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtMorirMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMorir.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMorir);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMorir.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtMoverseDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMoverse.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMovimiento);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMoverse.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtMoverseMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtMoverse.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMovimiento);
  if frmEditorFormulas.ShowModal = mrOK then
    edtMoverse.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtOviposicionDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtOviposicion.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlOvipositar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtOviposicion.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtOviposicionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtOviposicion.Text;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlOvipositar);
  if frmEditorFormulas.ShowModal = mrOK then
    edtOviposicion.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtProteinaDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteina.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteina.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.edtRDblClick(Sender: TObject);
begin
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtR.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMovimiento);
  if frmEditorFormulas.ShowModal = mrOK then
    edtR.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);
end;

procedure TfrmLlenarCelda.FormCreate(Sender: TObject);
begin
  InteraccionAgente := False;
  Adulto := True;
  Dinamico := False;
end;

procedure TfrmLlenarCelda.SetTitulo(const Value: string);
begin
  FTitulo := Value;
  Self.Caption := ML(mlLlnrCld) + ' [' + FTitulo + ']';
end;

procedure TfrmLlenarCelda.edtProteinaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtProteina.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlCmrProteina);
  if frmEditorFormulas.ShowModal = mrOK then
    edtProteina.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

procedure TfrmLlenarCelda.edtRMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {if Button <> mbRight then
  	Exit; //-->
  frmEditorFormulas := TfrmEditorFormulas.Create(Application);
  frmEditorFormulas.Formula := edtR.Text;
  frmEditorFormulas.Adulto := Adulto;
  frmEditorFormulas.InteraccionAgente := InteraccionAgente;
  frmEditorFormulas.Dinamico := Dinamico;
  frmEditorFormulas.Titulo := Self.Titulo + '-' + ML(mlMovimiento);
  if frmEditorFormulas.ShowModal = mrOK then
    edtR.Text := frmEditorFormulas.Formula;
  FreeAndNil(frmEditorFormulas);}
end;

initialization
  {$i LlenarCelda.lrs}

end.
