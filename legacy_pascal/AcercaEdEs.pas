unit AcercaEdEs;

{$MODE Delphi}

{*******************************************************************************
Ventana Acerca de del Editor de Escenario de Galatea.    
Proyecto: EdEsGlt 1.0
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
  TfrmAcerca = class(TForm)
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAcerca: TfrmAcerca;

implementation


initialization
  {$i AcercaEdEs.lrs}

end.
