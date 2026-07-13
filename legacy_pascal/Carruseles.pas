unit Carruseles;

{$MODE Delphi}

{*******************************************************************************
Contiene a la clase TCarrusel, cuyos objetos proveen números en secuencia
ordenada, permitiendo obtener un listado de números consecutivos, pero iniciando
en cualquier número de la serie, y continuando de forma ascendente, culminando
con el anterior a éste, o bien en forma descendente, culminado con el posterior.
Ejemplo:
Dada le serie: 1, 2, 3, 4, 5
Si al objeto carrusel se le indica que inicie en el 3, en sentido Derecha
(ascendente) la secuencia entregada será: 3, 4, 5, 1, 2
O bien si se le indica sentido Izquierda (descendente) la secuencia entregada
será: 3, 2, 1, 5, 4
*******************************************************************************}

interface

type
  TSentido = (snDerecha, snIzquierda);

  TCarrusel = class
  private
    FSentido: TSentido;
    FN: Integer;
    FMax: Integer;
    function GetFN: Integer;
  public
    constructor Create;
    procedure Inicializa(Max: Integer; PSentido: TSentido; Ini: Integer);
    property Sentido: TSentido
      read FSentido;
    property N: Integer
      read GetFN;
  end;

implementation

{ TCarrusel }

constructor TCarrusel.Create;
begin
  inherited Create;
  Inicializa(10, snDerecha, 1);
end;

function TCarrusel.GetFN: Integer;
begin
  if FSentido = snDerecha then
  begin
    if FN < FMax then
      Inc(FN)
    else
      FN := 1;
  end
  else
  begin
    if FN > 1 then
      Dec(FN)
    else
      FN := FMax;
  end;
  Result := FN;
end;

procedure TCarrusel.Inicializa(Max: Integer; PSentido: TSentido;
  Ini: Integer);
begin
  if Max < 1 then
    Max := 1;
  if Ini > Max then
    Ini := 1;
  case PSentido of
    snDerecha:
      if Ini = 1 then
        Ini := Max
      else
        Dec(Ini);
    snIzquierda:
      if Ini = Max then
        Ini := 1
      else
        Inc(Ini);
  end;
  FMax := Max;
  FSentido := PSentido;
  FN := Ini;
end;

end.
