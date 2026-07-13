unit Instalador;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmInstalador = class(TForm)
    grbIdioma: TGroupBox;
    rbtEnglish: TRadioButton;
    rbtEspanol: TRadioButton;
    btbAceptar: TBitBtn;
    procedure rbtEspanolClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInstalador: TfrmInstalador;

implementation

{$R *.dfm}

procedure TfrmInstalador.rbtEspanolClick(Sender: TObject);
begin
  Self.Caption := 'Instalación de Galatea';
  grbIdioma.Caption := 'Elija idioma';
  btbAceptar.Caption := 'Aceptar';
end;

end.
