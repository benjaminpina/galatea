unit AcercaEdAg;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, LResources;

type
  TfrmAcerca = class(TForm)
    btbAceptar: TBitBtn;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAcerca: TfrmAcerca;

implementation


initialization
  {$i AcercaEdAg.lrs}

end.
