unit SeleccionarMixto;

{$MODE Delphi}

{*******************************************************************************
Cuadro de diálogo para seleccionar un sustrato mixto como sustrato actual.
Proyecto: EdEsGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  {Windows,} Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, LResources;

type

  { TfrmSeleccionarMixto }

  TfrmSeleccionarMixto = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    grbSustratos: TGroupBox;
    lstMixtos: TListBox;
    Label1: TLabel;
    lblColor: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure grbSustratosClick(Sender: TObject);
    procedure lstMixtosClick(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure lstMixtosDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure LlenaLista;
  public
    { Public declarations }
    Seleccion: Integer;
  end;

var
  frmSeleccionarMixto: TfrmSeleccionarMixto;

implementation


uses
  EditorEscenarios, EditarMixto, Multilenguaje;


procedure TfrmSeleccionarMixto.FormCreate(Sender: TObject);
begin
  LlenaLista;
end;

procedure TfrmSeleccionarMixto.grbSustratosClick(Sender: TObject);
begin

end;

procedure TfrmSeleccionarMixto.LlenaLista;
var
  i, j: Integer;
  s   : string;
begin
  lstMixtos.Clear;
  with frmEditorEscenarios.Escenario.JuegoSustratos do
  begin
    for i := 1 to NumMixtos do
    begin
      s := '';
      for j := 1 to 7 do
        if SustratoMixto[i].Porcentajes[j] <> 0 then
        begin
          s := s + SustratoSimple[j].Nombre + ':'
                  + IntToStr(SustratoMixto[i].Porcentajes[j]) + '%; ';
        end;
      if s = '' then
        s := ML(mlSustrVc); //sustrato vacío
      lstMixtos.Items.Add(s);
    end;
    lstMixtos.ItemIndex := 0;
    lblColor.Color := SustratoMixto[1].Color;
  end;
end;

procedure TfrmSeleccionarMixto.lstMixtosClick(Sender: TObject);
begin
  lblColor.Color :=
frmEditorEscenarios.Escenario.JuegoSustratos.SustratoMixto[lstMixtos.ItemIndex+1].Color;
end;

procedure TfrmSeleccionarMixto.btbAceptarClick(Sender: TObject);
begin
  Seleccion := lstMixtos.ItemIndex + 1;
end;

procedure TfrmSeleccionarMixto.lstMixtosDblClick(Sender: TObject);
begin
  Seleccion := lstMixtos.ItemIndex + 1;
  ModalResult := mrOk;
end;

initialization
  {$i SeleccionarMixto.lrs}
  {$i SeleccionarMixto.lrs}

end.
