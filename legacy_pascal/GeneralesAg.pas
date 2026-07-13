unit GeneralesAg;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, LResources;

type

  { TfrmGeneralesAg }

  TfrmGeneralesAg = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edtContinuas: TEdit;
    edtDiscretas: TEdit;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    edtNO: TEdit;
    Label4: TLabel;
    edtN: TEdit;
    Label5: TLabel;
    edtNE: TEdit;
    edtO: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label6: TLabel;
    edtE: TEdit;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Label7: TLabel;
    edtSO: TEdit;
    Label8: TLabel;
    edtS: TEdit;
    Label9: TLabel;
    edtSE: TEdit;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure edtContinuasChange(Sender: TObject);
    procedure edtContinuasKeyPress(Sender: TObject; var Key: Char);
    procedure edtDiscretasKeyPress(Sender: TObject; var Key: Char);
    procedure edtNOKeyPress(Sender: TObject; var Key: Char);
    procedure edtNKeyPress(Sender: TObject; var Key: Char);
    procedure edtNEKeyPress(Sender: TObject; var Key: Char);
    procedure edtOKeyPress(Sender: TObject; var Key: Char);
    procedure edtEKeyPress(Sender: TObject; var Key: Char);
    procedure edtSOKeyPress(Sender: TObject; var Key: Char);
    procedure edtSKeyPress(Sender: TObject; var Key: Char);
    procedure edtSEKeyPress(Sender: TObject; var Key: Char);
    procedure edtRKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure ExportaValores;
  public
    { Public declarations }
  end;

var
  frmGeneralesAg: TfrmGeneralesAg;

implementation

uses
  IniFiles, Comunes;


procedure TfrmGeneralesAg.FormCreate(Sender: TObject);
begin
  ImportaValores;
end;

procedure TfrmGeneralesAg.btbAceptarClick(Sender: TObject);
begin
  ExportaValores;
end;

procedure TfrmGeneralesAg.edtContinuasChange(Sender: TObject);
begin

end;

procedure TfrmGeneralesAg.ExportaValores;
var
  ArchivoInicio: TIniFile;
  r            : Real;
  i            : Integer;
  s            : string;
begin
  ArchivoInicio := TIniFile.Create('Galatea.ini');
  with ArchivoInicio do
  begin
    r := StrToFloat(edtContinuas.Text);
    WriteFloat('GeneralesEditorAgentes', 'OmisionContinuas', r);
    i := StrToInt(edtDiscretas.Text);
    WriteInteger('GeneralesEditorAgentes', 'OmisionDiscretas', i);
    s := edtNO.Text + ',' + edtN.Text + ',' + edtNE.Text + ',' + edtO.Text + ',' +
       edtE.Text + ',' + edtSO.Text + ',' + edtS.Text + ',' + edtSE.Text + ',';
    WriteString('GeneralesEditorAgentes', 'OmisionTendencias', s);
    Free;
  end; //with
end;

procedure TfrmGeneralesAg.ImportaValores;
var
  ArchivoInicio: TIniFile;
  r            : Real;
  i            : Integer;
  s            : string;
begin
  ArchivoInicio := TIniFile.Create('Galatea.ini');
  with ArchivoInicio do
  begin
    r := ReadFloat('GeneralesEditorAgentes', 'OmisionContinuas', 2.0);
    edtContinuas.Text := FloatToStr(r);
    i := ReadInteger('GeneralesEditorAgentes', 'OmisionDiscretas', 2);
    edtDiscretas.Text := IntToStr(i);
    s := ReadString('GeneralesEditorAgentes',
                                'OmisionTendencias', '25,50,25,10,10,1,1,1,1');
    edtNO.Text := ObtenNsimo(s, 1);
    edtN.Text := ObtenNsimo(s, 2);
    edtNE.Text := ObtenNsimo(s, 3);
    edtO.Text := ObtenNsimo(s, 4);
    edtE.Text := ObtenNsimo(s, 5);
    edtSO.Text := ObtenNsimo(s, 6);
    edtS.Text := ObtenNsimo(s, 7);
    edtSE.Text := ObtenNsimo(s, 8);
    Free;
  end; //with
end;

procedure TfrmGeneralesAg.edtContinuasKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtDiscretasKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtNOKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtNKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtNEKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtOKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtEKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtSOKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtSKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtSEKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmGeneralesAg.edtRKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

initialization
  {$i GeneralesAg.lrs}
  {$i GeneralesAg.lrs}

end.
