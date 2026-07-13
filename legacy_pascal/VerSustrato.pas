unit VerSustrato;

{$MODE Delphi}

{*******************************************************************************
Cuadro de diálogo para ver la composición del sustrato presente n el último
cuadro del escenario en que se hizo clic.
Proyecto: EdEsGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, LResources;

type

  { TfrmVerSustrato }

  TfrmVerSustrato = class(TForm)
    Label1: TLabel;
    lblXY: TLabel;
    Label2: TLabel;
    lblColor: TLabel;
    BitBtn1: TBitBtn;
    sttComposicion: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure lblColorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVerSustrato: TfrmVerSustrato;

implementation


{ TfrmVerSustrato }

procedure TfrmVerSustrato.FormCreate(Sender: TObject);
begin

end;

procedure TfrmVerSustrato.lblColorClick(Sender: TObject);
begin

end;

initialization
  {$i VerSustrato.lrs}
  {$i VerSustrato.lrs}

end.
