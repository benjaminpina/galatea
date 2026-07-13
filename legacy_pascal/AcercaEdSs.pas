unit AcercaEdSs;

{$MODE Delphi}

{*******************************************************************************
Ventana Acerca de del Editor de Sustratos de Galatea.
Proyecto: EdSustGlt 1.0
Paquete: Galatea 1.0
Autor: Benjamín Piña Altamirano
Verano del 2002
Derechos de autor en trámite
*******************************************************************************}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, LResources;

type

  { TfrmAcerca }

  TfrmAcerca = class(TForm)
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    procedure Image5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAcerca: TfrmAcerca;

implementation


{ TfrmAcerca }

procedure TfrmAcerca.Image5Click(Sender: TObject);
begin

end;

initialization
  {$i AcercaEdSs.lrs}

end.
