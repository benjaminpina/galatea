unit NuevoMixto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls;

type
  TfrmNuevoMixto = class(TForm)
    grbComposicion: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtAgua: TEdit;
    edtArbol: TEdit;
    edtHierba: TEdit;
    edtHojarasca: TEdit;
    edtRoca: TEdit;
    edtSuelo: TEdit;
    grbColor: TGroupBox;
    lblColor: TLabel;
    btnColor: TButton;
    ColorDialog1: TColorDialog;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNuevoMixto: TfrmNuevoMixto;

implementation

{$R *.dfm}

end.
