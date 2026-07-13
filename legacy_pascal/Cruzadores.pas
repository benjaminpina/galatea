unit Cruzadores;

{$MODE Delphi}

{Contiene la clase TCruzador, la cual permite obtener un genotipo producto de la
cruza de dos agentes}

interface

uses
  Agentes, JuegoAgentes, Comunes;

type

  TCruzador = class
  private
    Juego: TJuegoAgentes;
    GenoPat,
    GenoMat: TGenotipo;
  public
    function Genotipo: TGenotipo;
    function CalculaMutacionContinua(Valor, Tasa, Rango: Real): Real;
    function CalculaMutacionDiscreta(Valor: Integer; Tasa: Real;
        Rango: Integer): Integer;
    constructor Create(PJuego: TJuegoAgentes; PGenotipoPaterno,
        PGenotipoMaterno: TGenotipo);
  end;

implementation

{ TCruzador }

function TCruzador.CalculaMutacionContinua(Valor, Tasa, Rango: Real): Real;
{Con una probabilidad igual a Tasa(0-1) regresa Valor +/- Rango,
y con probabilidad 1 - Tasa regresa Valor}
var
  r: Real;
begin
  r := Random;
  if r <= Tasa then         //Muta
  begin
    if Volado then
      Result := Valor + Rango
    else
      Result := Valor - Rango;
  end
  else                      //No muta
    Result := Valor;
end;

function TCruzador.CalculaMutacionDiscreta(Valor: Integer; Tasa: Real;
  Rango: Integer): Integer;
var
  r: Real;
begin
  r := Random;
  if r <= Tasa then         //Muta
  begin
    if Volado then
      Result := Valor + Rango
    else
      Result := Valor - Rango;
  end
  else                      //No muta
    Result := Valor;
end;



constructor TCruzador.Create(PJuego: TJuegoAgentes; PGenotipoPaterno,
  PGenotipoMaterno: TGenotipo);
begin
  Juego := PJuego;
  GenoPat := PGenotipoPaterno;
  GenoMat := PGenotipoMaterno;
end;

function TCruzador.Genotipo: TGenotipo;
var
  i: Integer;
begin
  for i := 1 to 15 do
  begin
    if Volado then    //Hereda genes continuos abuelo paterno
    begin
      Result.PatContinuos[i].Cualidad :=GenoPat.PatContinuos[i].Cualidad;
      if Result.PatContinuos[i].Cualidad = cdDominante then
        Result.PatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoPat.PatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionD,
                    Juego.LociContinuos[i].RangoMutacionD)
      else
        Result.PatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoPat.PatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionR,
                    Juego.LociContinuos[i].RangoMutacionR);
    end
    else
    begin             //Hereda genes continuos abuela paterna
      Result.PatContinuos[i].Cualidad :=
          GenoPat.MatContinuos[i].Cualidad;
      if Result.PatContinuos[i].Cualidad = cdDominante then
        Result.PatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoPat.MatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionD,
                    Juego.LociContinuos[i].RangoMutacionD)
      else
        Result.PatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoPat.MatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionR,
                    Juego.LociContinuos[i].RangoMutacionR);
    end;
    if Volado then    //Hereda genes discretos abuelo paterno
    begin
      Result.PatDiscretos[i].Cualidad :=
          GenoPat.PatDiscretos[i].Cualidad;
      if Result.PatDiscretos[i].Cualidad = cdDominante then
        Result.PatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoPat.PatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionD,
                    Juego.LociDiscretos[i].RangoMutacionD)
      else
        Result.PatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoPat.PatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionR,
                    Juego.LociDiscretos[i].RangoMutacionR);
    end
    else
    begin             //Hereda genes discretos abuela paterna
      Result.PatDiscretos[i].Cualidad :=
          GenoPat.MatDiscretos[i].Cualidad;
      if Result.PatDiscretos[i].Cualidad = cdDominante then
        Result.PatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoPat.MatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionD,
                    Juego.LociDiscretos[i].RangoMutacionD)
      else
        Result.PatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoPat.MatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionR,
                    Juego.LociDiscretos[i].RangoMutacionR);
    end;
    if Volado then    //Hereda genes continuos abuelo materno
    begin
      Result.MatContinuos[i].Cualidad :=
          GenoMat.PatContinuos[i].Cualidad;
      if Result.MatContinuos[i].Cualidad = cdDominante then
        Result.MatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoMat.PatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionD,
                    Juego.LociContinuos[i].RangoMutacionD)
      else
        Result.MatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoMat.PatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionR,
                    Juego.LociContinuos[i].RangoMutacionR);
    end
    else
    begin             //Hereda genes continuos abuela materna
      Result.MatContinuos[i].Cualidad :=
          GenoMat.MatContinuos[i].Cualidad;
      if Result.MatContinuos[i].Cualidad = cdDominante then
        Result.MatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoMat.MatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionD,
                    Juego.LociContinuos[i].RangoMutacionD)
      else
        Result.MatContinuos[i].Valor :=
            CalculaMutacionContinua(GenoMat.MatContinuos[i].Valor,
                Juego.LociContinuos[i].MutacionR,
                    Juego.LociContinuos[i].RangoMutacionR);
    end;
    if Volado then    //Hereda genes discretos abuelo materno
    begin
      Result.MatDiscretos[i].Cualidad :=
          GenoMat.PatDiscretos[i].Cualidad;
      if Result.MatDiscretos[i].Cualidad = cdDominante then
        Result.MatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoMat.PatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionD,
                    Juego.LociDiscretos[i].RangoMutacionD)
      else
        Result.MatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoMat.PatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionR,
                    Juego.LociDiscretos[i].RangoMutacionR);
    end
    else
    begin             //Hereda genes discretos abuela materna
      Result.MatDiscretos[i].Cualidad :=
          GenoMat.MatDiscretos[i].Cualidad;
      if Result.MatDiscretos[i].Cualidad = cdDominante then
        Result.MatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoMat.MatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionD,
                    Juego.LociDiscretos[i].RangoMutacionD)
      else
        Result.MatDiscretos[i].Valor :=
            CalculaMutacionDiscreta(GenoMat.MatDiscretos[i].Valor,
                Juego.LociDiscretos[i].MutacionR,
                    Juego.LociDiscretos[i].RangoMutacionR);
    end;
  end;  //for
end;  //func Genotipo

end.
