unit Promediadores;

{$MODE Delphi}

{*******************************************************************************
Contiene a la clase TPromediador, que facilita la obtención del promedio de una
serie de números.
EL PROMEDIO SE CALCULA SIN TOMAR EN CUENTA LOS VALORES IGUALES A CERO O
NEGATIVOS
*******************************************************************************}

interface

type

  TPromediador = class
  private
    Lista: array of Real;
    FN: Integer;
  public
    function PromedioR: Real;
    function PromedioI: Integer;
    constructor Create;
    procedure Agrega(r: Real);
    procedure Reestablece;
    property N: Integer
      read FN;
  end;

implementation

{ TPromediador }

procedure TPromediador.Agrega(r: Real);
begin
  Inc(FN);
  SetLength(Lista, FN);
  Lista[FN-1] := r;
end;

constructor TPromediador.Create;
begin
  FN := 0;
end;

function TPromediador.PromedioI: Integer;
begin
  Result := Round(PromedioR);
end;

function TPromediador.PromedioR: Real;
var
  Suma: Real;
  Nparcial,
  i: Integer;
begin
  Suma := 0;
  NParcial := 0;
  for i := 0 to FN - 1 do
    if Lista[i] <> 0 then
    begin
      Inc(Nparcial);
      Suma := Suma + Lista[i];
    end;
  if Nparcial > 0 then
    Result := Suma / Nparcial
  else
    Result := 0;
end;

procedure TPromediador.Reestablece;
begin
  FN := 0;
  SetLength(Lista, 0);
end;

end.
