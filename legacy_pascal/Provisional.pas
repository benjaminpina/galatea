unit Provisional;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Comunes;

type

  TNotas = class(TGuardable);

  TfrmProvisional = class(TForm)
    memNotas: TMemo;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure btbCancelarClick(Sender: TObject);
  private
    { Private declarations }
    Notas: TNotas;
    Archivo: TextFile;
    Asignacion,
    Fisiologia,
    Genetica,
    Interaccion,
    Memoria,
    Morfologia,
    Lineas: TStringList;
    Estadios,
    PrototiposM,
    PrototiposH: array of TStringList;
    function EliminaApersAnd(s: string): string;
  public
    { Public declarations }
    Indice: string;
    NombreArchivo: TFileName;
    procedure ImportaTexto;
    procedure ExportaTexto;
    procedure CreaApartados(Apartados: TStringList);
  end;

var
  frmProvisional: TfrmProvisional;

implementation

{$R *.dfm}

procedure TfrmProvisional.CreaApartados(Apartados: TStringList);
begin

end;

function TfrmProvisional.EliminaApersAnd(s: string): string;
begin

end;

procedure TfrmProvisional.ExportaTexto;
begin

end;

procedure TfrmProvisional.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmProvisional.ImportaTexto;
begin

end;

procedure TfrmProvisional.btbAceptarClick(Sender: TObject);
begin
  //
end;

procedure TfrmProvisional.btbCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

end.
