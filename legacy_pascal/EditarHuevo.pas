unit EditarHuevo;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, Agentes, LResources;

type
  TfrmEditarHuevo = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox60: TGroupBox;
    Label12: TLabel;
    Label2: TLabel;
    edtNombre: TEdit;
    edtEdad: TEdit;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    sttSexo: TStaticText;
    sttPadre: TStaticText;
    sttMadre: TStaticText;
    GroupBox20: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtAgua: TEdit;
    edtAzucar: TEdit;
    edtGrasa: TEdit;
    edtProteina: TEdit;
    sbxLC: TScrollBox;
    grpLCP1: TGroupBox;
    rdbLCDP1: TRadioButton;
    rdbLCRP1: TRadioButton;
    edtLCP1: TEdit;
    grpLCM1: TGroupBox;
    rdbLCDM1: TRadioButton;
    rdbLCRM1: TRadioButton;
    edtLCM1: TEdit;
    grpLC1: TGroupBox;
    sttLC1: TStaticText;
    sbxLD: TScrollBox;
    grpLDP1: TGroupBox;
    rdbLDDP1: TRadioButton;
    rdbLDRP1: TRadioButton;
    edtLDP1: TEdit;
    grpLDM1: TGroupBox;
    rdbLDDM1: TRadioButton;
    rdbLDRM1: TRadioButton;
    edtLDM1: TEdit;
    grpLD1: TGroupBox;
    sttLD1: TStaticText;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    procedure edtEdadKeyPress(Sender: TObject; var Key: Char);
    procedure rdbLCDP1Click(Sender: TObject);
    procedure rdbLCRP1Click(Sender: TObject);
    procedure edtLCP1Change(Sender: TObject);
    procedure rdbLCDM1Click(Sender: TObject);
    procedure rdbLCRM1Click(Sender: TObject);
    procedure edtLCM1Change(Sender: TObject);
    procedure edtLCM1KeyPress(Sender: TObject; var Key: Char);
    procedure edtLCP1KeyPress(Sender: TObject; var Key: Char);
    procedure rdbLDDP1Click(Sender: TObject);
    procedure rdbLDRP1Click(Sender: TObject);
    procedure edtLDP1Change(Sender: TObject);
    procedure edtLDP1KeyPress(Sender: TObject; var Key: Char);
    procedure rdbLDDM1Click(Sender: TObject);
    procedure rdbLDRM1Click(Sender: TObject);
    procedure edtLDM1Change(Sender: TObject);
    procedure edtLDM1KeyPress(Sender: TObject; var Key: Char);
    procedure btbAceptarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    {Controles creados en tiempo de ejecución}
    grpLCP: array [1..15] of TGroupBox;
    rdbLCDP: array [1..15] of TRadioButton;
    rdbLCRP: array [1..15] of TRadioButton;
    edtLCP: array [1..15] of TEdit;
    grpLCM: array [1..15] of TGroupBox;
    rdbLCDM: array [1..15] of TRadioButton;
    rdbLCRM: array [1..15] of TRadioButton;
    edtLCM: array [1..15] of TEdit;
    grpLC: array [1..15] of TGroupBox;
    sttLC: array [1..15] of TStaticText;
    grpLDP: array [1..15] of TGroupBox;
    rdbLDDP: array [1..15] of TRadioButton;
    rdbLDRP: array [1..15] of TRadioButton;
    edtLDP: array [1..15] of TEdit;
    grpLDM: array [1..15] of TGroupBox;
    rdbLDDM: array [1..15] of TRadioButton;
    rdbLDRM: array [1..15] of TRadioButton;
    edtLDM: array [1..15] of TEdit;
    grpLD: array [1..15] of TGroupBox;
    sttLD: array [1..15] of TStaticText;
    procedure InsertaControles;
    procedure InsertaCajas;
    procedure InsertaRadios;
    procedure InsertaCuadros;
    procedure ActualizaValores;
  public
    { Public declarations }
    Huevo: THuevo;
    procedure DespliegaValores;
  end;

var
  frmEditarHuevo: TfrmEditarHuevo;

implementation

uses
  Multilenguaje, EditorEntornos, Comunes;


function ExpresadoContinuo(LocPat, LocMat: string;
  DomPat, DomMat: Boolean): string;
{Regresa el valor expresado (en cadena) segun valores y cualidades de locus
pasados como parámetros}
var
  Pat, Mat: Real;
begin
  try
    Result := '0';
    Pat := StrToFloat(LocPat);
    Mat := StrToFloat(LocMat);
    if DomPat and DomMat then               //Homocigo dominate
      Result := FloatToStr((Pat + Mat) / 2)     //Codominancia
    else if DomPat and not DomMat then      //Heterocigo
      Result := FloatToStr(Pat)           //Dominancia paterna
    else if not DomPat and DomMat then      //Heterocigo
      Result := FloatToStr(Mat)           //Dominancia materna
    else if not DomPat and not DomMat then  //Homocigo dominate
      Result := FloatToStr((Pat + Mat) / 2);    //Codominancia
  except
  end;
end;

function ExpresadoDiscreto(LocPat, LocMat: string;
  DomPat, DomMat: Boolean): string;
{Regresa el valor expresado (en cadena) segun valores y cualidades de locus
pasados como parámetros}
var
  Pat, Mat: Integer;
begin
  try
    Result := '0';
    Pat := StrToInt(LocPat);
    Mat := StrToInt(LocMat);
    if DomPat and DomMat then                 //Homocigo dominate
      Result := IntToStr(Round((Pat + Mat) / 2))  //Codominancia
    else if DomPat and not DomMat then        //Heterocigo
      Result := IntToStr(Pat)               //Dominancia paterna
    else if not DomPat and DomMat then        //Heterocigo
      Result := IntToStr(Mat)               //Dominancia materna
    else if not DomPat and not DomMat then    //Homocigo dominate
      Result := IntToStr(Round((Pat + Mat) / 2)); //Codominancia
  except
  end;
end;

procedure TfrmEditarHuevo.edtEdadKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarHuevo.rdbLCDP1Click(Sender: TObject);
var
  i: Integer;
begin                     //Obteniendo número del control
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCP[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Dominante);
end;

procedure TfrmEditarHuevo.rdbLCRP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCP[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Recesivo);
end;

procedure TfrmEditarHuevo.edtLCP1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLC[i].Caption := ExpresadoContinuo(edtLCP[i].Text, edtLCM[i].Text,
      rdbLCDP[i].Checked, rdbLCDM[i].Checked);
end;

procedure TfrmEditarHuevo.rdbLCDM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCM[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Dominante);
end;

procedure TfrmEditarHuevo.rdbLCRM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLCM[i].Text :=
      FloatToStr(frmEditorEntornos.Entorno.Juego.LociContinuos[i].Recesivo);
end;

procedure TfrmEditarHuevo.edtLCM1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLC[i].Caption := ExpresadoContinuo(edtLCP[i].Text, edtLCM[i].Text,
      rdbLCDP[i].Checked, rdbLCDM[i].Checked);
end;

procedure TfrmEditarHuevo.edtLCM1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TfrmEditarHuevo.edtLCP1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarHuevo.rdbLDDP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDP[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Dominante);
end;

procedure TfrmEditarHuevo.rdbLDRP1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDP[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Recesivo);
end;

procedure TfrmEditarHuevo.edtLDP1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLD[i].Caption := ExpresadoDiscreto(edtLDP[i].Text, edtLDM[i].Text,
    rdbLDDP[i].Checked, rdbLDDM[i].Checked);
end;

procedure TfrmEditarHuevo.edtLDP1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarHuevo.rdbLDDM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDM[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Dominante);
end;

procedure TfrmEditarHuevo.rdbLDRM1Click(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TRadioButton).Name, 8, 2));
  edtLDM[i].Text :=
      IntToStr(frmEditorEntornos.Entorno.Juego.LociDiscretos[i].Recesivo);
end;

procedure TfrmEditarHuevo.edtLDM1Change(Sender: TObject);
var
  i: Integer;
begin
  i := StrToInt(Copy((Sender as TEdit).Name, 7, 2));
  sttLD[i].Caption := ExpresadoDiscreto(edtLDP[i].Text, edtLDM[i].Text,
    rdbLDDP[i].Checked, rdbLDDM[i].Checked);
end;

procedure TfrmEditarHuevo.edtLDM1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmEditarHuevo.ActualizaValores;
var
  i: Integer;
begin
  with Huevo do
  begin
    Nombre := edtNombre.Text;
    //Inicializa(Padre, Madre, Portador, StrToInt(edtEdad.Text), Sexo);
    for i := 1 to 15 do
    begin
      Genotipo.PatContinuos[i].Valor := StrToFloat(edtLCP[i].Text);
      if rdbLCDP[i].Checked then
        Genotipo.PatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.PatContinuos[i].Cualidad := cdRecesivo;
      if rdbLCDP[i].Checked then
        Genotipo.PatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.PatContinuos[i].Cualidad := cdRecesivo;
      if rdbLCDM[i].Checked then
        Genotipo.MatContinuos[i].Cualidad := cdDominante
      else
        Genotipo.MatContinuos[i].Cualidad := cdRecesivo;
      Genotipo.PatDiscretos[i].Valor := StrToInt(edtLDP[i].Text);
      Genotipo.MatDiscretos[i].Valor := StrToInt(edtLDM[i].Text);
      if rdbLDDP[i].Checked then
        Genotipo.PatDiscretos[i].Cualidad := cdDominante
      else
        Genotipo.PatDiscretos[i].Cualidad := cdRecesivo;
      if rdbLDDM[i].Checked then
        Genotipo.MatDiscretos[i].Cualidad := cdDominante
      else
        Genotipo.MatDiscretos[i].Cualidad := cdRecesivo;
    end;
    Reservas.Agua := StrToInt(edtAgua.Text);
    Reservas.Azucar := StrToInt(edtAzucar.Text);
    Reservas.Grasa := StrToInt(edtGrasa.Text);
    Reservas.Proteina := StrToInt(edtProteina.Text);
  end;  //with Huevo
end;

procedure TfrmEditarHuevo.DespliegaValores;
var
  i: Integer;
begin
  with Huevo do
  begin
    edtNombre.Text := Nombre;
    edtEdad.Text := IntToStr(Edad);
    case Sexo of
      sxMacho: sttSexo.Caption := ML(mlMacho);
      sxHembra: sttSexo.Caption := ML(mlHembra);
      sxIndefinido: sttSexo.Caption := ML(mlIndefinido);
    end;
    sttPadre.Caption := Padre;
    sttMadre.Caption := Madre;
    for i := 1 to 15 do
    begin
      edtLCP[i].Text := FloatToStr(Genotipo.PatContinuos[i].Valor);
      edtLCM[i].Text := FloatToStr(Genotipo.MatContinuos[i].Valor);
      rdbLCRP[i].Checked := Genotipo.PatContinuos[i].Cualidad = cdRecesivo;
      rdbLCRM[i].Checked := Genotipo.MatContinuos[i].Cualidad = cdRecesivo;
      edtLDP[i].Text := IntToStr(Genotipo.PatDiscretos[i].Valor);
      edtLDM[i].Text := IntToStr(Genotipo.MatDiscretos[i].Valor);
      rdbLDRP[i].Checked := Genotipo.PatDiscretos[i].Cualidad = cdRecesivo;
      rdbLDRM[i].Checked := Genotipo.MatDiscretos[i].Cualidad = cdRecesivo;
    end;
    edtAgua.Text := IntToStr(Reservas.Agua);
    edtAzucar.Text := IntToStr(Reservas.Azucar);
    edtGrasa.Text := IntToStr(Reservas.Grasa);
    edtProteina.Text := IntToStr(Reservas.Proteina);
  end;  //with Huevo
end;

procedure TfrmEditarHuevo.InsertaCajas;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    grpLCP[i] := TGroupBox.Create(Self);
    with grpLCP[i] do
    begin
      Name := 'grpLCP' + IntToStr(i);
      Caption := ML(mlLcsPtrn) + ' ' + IntToStr(i);
      Top := grpLCP[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLCP[i-1].Left;
      Height := grpLCP[i-1].Height;
      Width := grpLCP[i-1].Width;
      Parent := grpLCP1.Parent;
    end;
    grpLCM[i] := TGroupBox.Create(Self);
    with grpLCM[i] do
    begin
      Name := 'grpLCM' + IntToStr(i);
      Caption := ML(mlLcsMtrn) + ' ' + IntToStr(i);
      Top := grpLCM[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLCM[i-1].Left;
      Height := grpLCM[i-1].Height;
      Width := grpLCM[i-1].Width;
      Parent := grpLCM1.Parent;
    end;
    grpLC[i] := TGroupBox.Create(Self);
    with grpLC[i] do
    begin
      Name := 'grpLC' + IntToStr(i);
      Caption := ML(mlLcsExprsd) + ' ' + IntToStr(i);
      Top := grpLC[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLC[i-1].Left;
      Height := grpLC[i-1].Height;
      Width := grpLC[i-1].Width;
      Parent := grpLC1.Parent;
    end;
    grpLDP[i] := TGroupBox.Create(Self);
    with grpLDP[i] do
    begin
      Name := 'grpLDP' + IntToStr(i);
      Caption := ML(mlLcsPtrn) + ' ' + IntToStr(i);
      Top := grpLDP[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLDP[i-1].Left;
      Height := grpLDP[i-1].Height;
      Width := grpLDP[i-1].Width;
      Parent := grpLDP1.Parent;
    end;
    grpLDM[i] := TGroupBox.Create(Self);
    with grpLDM[i] do
    begin
      Name := 'grpLDM' + IntToStr(i);
      Caption := ML(mlLcsMtrn) + ' ' + IntToStr(i);
      Top := grpLDM[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLDM[i-1].Left;
      Height := grpLDM[i-1].Height;
      Width := grpLDM[i-1].Width;
      Parent := grpLDM1.Parent;
    end;
    grpLD[i] := TGroupBox.Create(Self);
    with grpLD[i] do
    begin
      Name := 'grpLD' + IntToStr(i);
      Caption := ML(mlLcsExprsd) + ' ' + IntToStr(i);
      Top := grpLD[i-1].Top + grpLCP[i-1].Height + 1;
      Left := grpLD[i-1].Left;
      Height := grpLD[i-1].Height;
      Width := grpLD[i-1].Width;
      Parent := grpLD1.Parent;
    end;
  end;  //for
end;

procedure TfrmEditarHuevo.InsertaControles;
begin
grpLCP[1] := grpLCP1;
  rdbLCDP[1] := rdbLCDP1;
  rdbLCRP[1] := rdbLCRP1;
  edtLCP[1] := edtLCP1;
  grpLCM[1] := grpLCM1;
  rdbLCDM[1] := rdbLCDM1;
  rdbLCRM[1] := rdbLCRM1;
  edtLCM[1] := edtLCM1;
  grpLC[1] := grpLC1;
  sttLC[1] := sttLC1;
  grpLDP[1] := grpLDP1;
  rdbLDDP[1] := rdbLDDP1;
  rdbLDRP[1] := rdbLDRP1;
  edtLDP[1] := edtLDP1;
  grpLDM[1] := grpLDM1;
  rdbLDDM[1] := rdbLDDM1;
  rdbLDRM[1] := rdbLDRM1;
  edtLDM[1] := edtLDM1;
  grpLD[1] := grpLD1;
  sttLD[1] := sttLD1;
  InsertaCajas;
  InsertaRadios;
  InsertaCuadros;
end;

procedure TfrmEditarHuevo.InsertaCuadros;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    edtLCP[i] := TEdit.Create(Self);
    with edtLCP[i] do
    begin
      Name := 'edtLCP' + IntToStr(i);
      Top := edtLCP[i-1].Top;
      Left := edtLCP[i-1].Left;
      Width := edtLCP[i-1].Width;
      OnChange := edtLCP1Change;
      OnKeyPress := edtLCP1KeyPress;
      Parent := grpLCP[i];
    end;
    edtLCM[i] := TEdit.Create(Self);
    with edtLCM[i] do
    begin
      Name := 'edtLCM' + IntToStr(i);
      Top := edtLCM[i-1].Top;
      Left := edtLCM[i-1].Left;
      Width := edtLCM[i-1].Width;
      OnChange := edtLCM1Change;
      OnKeyPress := edtLCM1KeyPress;
      Parent := grpLCM[i];
    end;
    sttLC[i] := TStaticText.Create(Self);
    with sttLC[i] do
    begin
      Name := 'sttLC' + IntToStr(i);
      AutoSize := False;
      //BevelInner := bvLowered;
      //BevelKind := bkSoft;
      Top := sttLC[i-1].Top;
      Left := sttLC[i-1].Left;
      Width := sttLC[i-1].Width;
      Parent := grpLC[i];
    end;
    edtLDP[i] := TEdit.Create(Self);
    with edtLDP[i] do
    begin
      Name := 'edtLDP' + IntToStr(i);
      Top := edtLDP[i-1].Top;
      Left := edtLDP[i-1].Left;
      Width := edtLDP[i-1].Width;
      OnChange := edtLDP1Change;
      OnKeyPress := edtLDP1KeyPress;
      Parent := grpLDP[i];
    end;
    edtLDM[i] := TEdit.Create(Self);
    with edtLDM[i] do
    begin
      Name := 'edtLDM' + IntToStr(i);
      Top := edtLDM[i-1].Top;
      Left := edtLDM[i-1].Left;
      Width := edtLDM[i-1].Width;
      OnChange := edtLDM1Change;
      OnKeyPress := edtLDM1KeyPress;
      Parent := grpLDM[i];
    end;
    sttLD[i] := TStaticText.Create(Self);
    with sttLD[i] do
    begin
      Name := 'sttLD' + IntToStr(i);
      AutoSize := False;
      //BevelInner := bvLowered;
      //BevelKind := bkSoft;
      Top := sttLD[i-1].Top;
      Left := sttLD[i-1].Left;
      Width := sttLD[i-1].Width;
      Parent := grpLD[i];
    end;
  end;  //for
end;

procedure TfrmEditarHuevo.InsertaRadios;
var
  i: Integer;
begin
  for i := 2 to 15 do
  begin
    rdbLCDP[i] := TRadioButton.Create(Self);
    with rdbLCDP[i] do
    begin
      Name := 'rdbLCDP' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLCDP[1].Top;
      Left := rdbLCDP[1].Left;
      Width := rdbLCDP[1].Width;
      Checked := True;
      OnClick := rdbLCDP1Click;
      Parent := grpLCP[i];
    end;
    rdbLCRP[i] := TRadioButton.Create(Self);
    with rdbLCRP[i] do
    begin
      Name := 'rdbLCRP' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLCRP[1].Top;
      Left := rdbLCRP[1].Left;
      Width := rdbLCRP[1].Width;
      OnClick := rdbLCRP1Click;
      Parent := grpLCP[i];
    end;
    rdbLCDM[i] := TRadioButton.Create(Self);
    with rdbLCDM[i] do
    begin
      Name := 'rdbLCDM' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLCDM[1].Top;
      Left := rdbLCDM[1].Left;
      Width := rdbLCDM[1].Width;
      Checked := True;
      OnClick := rdbLCDM1Click;
      Parent := grpLCM[i];
    end;
    rdbLCRM[i] := TRadioButton.Create(Self);
    with rdbLCRM[i] do
    begin
      Name := 'rdbLCRM' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLCRM[1].Top;
      Left := rdbLCRM[1].Left;
      Width := rdbLCRM[1].Width;
      OnClick := rdbLCRM1Click;
      Parent := grpLCM[i];
    end;
    rdbLDDP[i] := TRadioButton.Create(Self);
    with rdbLDDP[i] do
    begin
      Name := 'rdbLDDP' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLDDP[1].Top;
      Left := rdbLDDP[1].Left;
      Width := rdbLDDP[1].Width;
      Checked := True;
      OnClick := rdbLDDP1Click;
      Parent := grpLDP[i];
    end;
    rdbLDRP[i] := TRadioButton.Create(Self);
    with rdbLDRP[i] do
    begin
      Name := 'rdbLDRP' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLDRP[1].Top;
      Left := rdbLDRP[1].Left;
      Width := rdbLDRP[1].Width;
      OnClick := rdbLDRP1Click;
      Parent := grpLDP[i];
    end;
    rdbLDDM[i] := TRadioButton.Create(Self);
    with rdbLDDM[i] do
    begin
      Name := 'rdbLDDM' + IntToStr(i);
      Caption := ML(mlDominante);
      Top := rdbLDDM[1].Top;
      Left := rdbLDDM[1].Left;
      Width := rdbLDDM[1].Width;
      Checked := True;
      OnClick := rdbLDDM1Click;
      Parent := grpLDM[i];
    end;
    rdbLDRM[i] := TRadioButton.Create(Self);
    with rdbLDRM[i] do
    begin
      Name := 'rdbLDRM' + IntToStr(i);
      Caption := ML(mlRecesivo);
      Top := rdbLDRM[1].Top;
      Left := rdbLDRM[1].Left;
      Width := rdbLDRM[1].Width;
      OnClick := rdbLDRM1Click;
      Parent := grpLDM[i];
    end;
  end;  //for
end;

procedure TfrmEditarHuevo.btbAceptarClick(Sender: TObject);
begin
  ActualizaValores;
end;

procedure TfrmEditarHuevo.FormCreate(Sender: TObject);
begin
  InsertaControles;
end;

initialization
  {$i EditarHuevo.lrs}

end.
