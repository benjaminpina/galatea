unit FuncElementosCadenas;

{$MODE Delphi}

{*******************************************************************************
Contiene funciones que convierten los datos de elmentos de Galatea a cadenas de
caracteres, así como las funciones complementarias que realizan al conversion
de cadenas de valores separados por comas a elementos de Galatea.
*******************************************************************************}
interface

uses
  JuegoAgentes, Elementos, Agentes, Comunes, SysUtils;

function GenotipoAString(Genotipo: TGenotipo): string;
function AgenteAString(Agente: TAgente; Juego: TJuegoAgentes): string;
function AgenteAStringConst(Agente: TAgente): string;
function AgenteAStringVar(Agente: TAgente;  Juego: TJuegoAgentes): string;
function AgenteAStringMorfo(Agente: TAgente): string;
function ReservasAString(Resevas: TReservas): string;
function PaqueteEspermaticoAString(Paquete: TPaqEspermatico): string;
function HuevoFertilizadoAString(Huevo: THuevo): string;
function HuevoOvipositadoAString(Huevo: THuevo): string;
function HuevoOvipositadoAStringConst(Huevo: THuevo): string;
function ElementoDinamicoAString(Dinamico: TDinamico): string;
function SitOviposicionAString(SitOviposicion: TSitioOviposicion): string;

implementation


function GenotipoAString(Genotipo: TGenotipo): string;
{Regresa una cadena de valores separados por comas, correspondientes a los datos
de Genotipo, se emplea para reducir el código en el procedimiento de guardado
de archivos de entorno}
var
  i: Integer;
begin
  Result := '';
  with Genotipo do
  begin
    for i := 1 to 15 do
    begin
      if PatContinuos[i].Cualidad = cdDominante then
        Result := Result + 'D, '
      else
        Result := Result + 'R, ';
      Result := Result + FloatToStr(PatContinuos[i].Valor) + ', ';
      if MatContinuos[i].Cualidad = cdDominante then
        Result := Result + 'D, '
      else
        Result := Result + 'R, ';
      Result := Result + FloatToStr(MatContinuos[i].Valor) + ', ';
    end;
    for i := 1 to 15 do
    begin
      if PatDiscretos[i].Cualidad = cdDominante then
        Result := Result + 'D, '
      else
        Result := Result + 'R, ';
      Result := Result + IntToStr(PatDiscretos[i].Valor) + ', ';
      if MatDiscretos[i].Cualidad = cdDominante then
        Result := Result + 'D, '
      else
        Result := Result + 'R, ';
      Result := Result + IntToStr(MatDiscretos[i].Valor) + ', ';
    end;
  end; //With Genotipo
end;  //funtion GenotipoAString

function AgenteAStringMorfo(Agente: TAgente): string;
var
  i: Integer;
  Linea: string;
begin
  Linea := '';
  with Agente do
  begin
    for i := 1 to 15 do
      Linea := Linea + FloatToStr(ContinuosFijados[i]) + ', ';
    for i := 1 to 15 do
      Linea := Linea + IntToStr(DiscretosFijados[i]) + ', ';
  end;
  Result := Linea;
end;

function AgenteAString(Agente: TAgente; Juego: TJuegoAgentes): string;
var
  i: Integer;
  Linea: string;
begin
  with Agente do
    begin
      Linea := Nombre + ', ' + Padre + ', ' + Madre + ', ' + IntToStr(X) + ', '
          + IntToStr(Y) + ', ' + IntToStr(Estadio) + ', ' + IntToStr(Prototipo)
          + ', ';
      case Sexo of
        sxIndefinido : Linea := Linea + 'I' + ', ';
        sxMacho      : Linea := Linea + 'M' + ', ';
        sxHembra     : Linea := Linea + 'H' + ', ';
      end;
      Linea := Linea + IntToStr(Tiempo.EstadioActual) + ', '
          + IntToStr(Tiempo.SustratoActual) + ', '
          + IntToStr(Tiempo.InteraccionActual) + ', ';
      Linea := Linea + IntToStr(Edad) + ', '
              + IntToStr(DireccionANum(Direccion)) + ', '
              + IntToStr(Reservas.Agua) + ', '
              + IntToStr(Reservas.Azucar) + ', '
              + IntToStr(Reservas.Grasa) + ', '
              + IntToStr(Reservas.Proteina) + ', '
              //+ IntToStr(Reproduccion.Paquetes) + ', '
              + IntToStr(Gonada.Contador) + ', '
              //+ IntToStr(Reproduccion.Huevos) + ', '
              + IntToStr(Gonada.Contador) + ', '
              + IntToStr(Fertilizados.Contador) + ', '
              + IntToStr(Acarreados) + ', '
              //+ IntToStr(Reproduccion.Almacenados) + ', ';
              + IntToStr(Espermateca.Contador) + ', ';
      Linea := Linea + GenotipoAString(Genotipo);
      for i := 1 to 16 do
      begin
        Linea := Linea + IntToStr(Memoria.UltConductas[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumConductas[i]) + ', ';
      end;
      for i := 1 to 7 do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerSust[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerSust[i]) + ', ';
      end;
      for i := 1 to 5 do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntDin[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntDin[i]) + ', ';
      end;
      for i := 1 to Juego.NumEstadios do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntEstadios[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntEstadios[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposM do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntMachos[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntMachos[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposH do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntHembras[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntHembras[i-1]) + ', ';
      end;
      for i := 1 to 5 do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerDin[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerDin[i]) + ', ';
      end;
      for i := 1 to Juego.NumEstadios do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerEstadios[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerEstadios[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposM do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerMachos[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerMachos[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposH do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerHembras[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerHembras[i-1]) + ', ';
      end;
      Linea := Linea + IntToStr(Memoria.UltAccionContendiente) + ',';
      if Assigned(Interactuante) then
      begin
        if Interactuante is TAgente then
          Linea := Linea + 'Ag, ' + Interactuante.Nombre + ', '
        else if Interactuante is TSitioOviposicion then
          Linea := Linea + 'SO, ' + Interactuante.Nombre + ', '
        else if Interactuante is TDinamico then
          Linea := Linea + 'ED, ' + Interactuante.Nombre + ', '
        else
          Linea := Linea + ', ';
      end
      else
        Linea := Linea + ', ,';
      case Situacion of
        stInmaduro: Linea := Linea + 'Inm, ';
        stRegular: Linea := Linea + 'Reg, ';
        stCombate: Linea := Linea + 'Com, ';
        stCortejo: Linea := Linea + 'Cor, ';
      end;
      if Fijados then
      begin
        Linea := Linea + 'F,';
        Linea := Linea + AgenteAStringMorfo(Agente);
      end
      else
        Linea := Linea + 'N,';
    end;  //with Agente
  Result := Linea;
end;

function AgenteAStringConst(Agente: TAgente): string;
{Convierte los datos inmutables (constantes) del agente, excepto el nombre, en
una cadena de valores separados por comas}
var
  Linea: string;
begin
  with Agente do
    begin
      Linea := Padre + ', ' + Madre + ', ';
      case Sexo of
        sxIndefinido : Linea := Linea + 'I' + ', ';
        sxMacho      : Linea := Linea + 'M' + ', ';
        sxHembra     : Linea := Linea + 'H' + ', ';
      end;
      Linea := Linea + GenotipoAString(Genotipo);
    end;  //with Agente
  Result := Linea;
end;

function AgenteAStringVar(Agente: TAgente;  Juego: TJuegoAgentes): string;
{Convierte los datos cambiantes (variables) del agente, en una cadena de
valores separados por comas}
var
  i: Integer;
  Linea: string;
begin
  with Agente do
    begin
      Linea := IntToStr(X) + ', ' + IntToStr(Y) + ', ' + IntToStr(Estadio)
      + ', ' + IntToStr(Prototipo) + ', ';
      Linea := Linea + IntToStr(Tiempo.EstadioActual) + ', '
          + IntToStr(Tiempo.SustratoActual) + ', '
          + IntToStr(Tiempo.InteraccionActual) + ', ';
      Linea := Linea + IntToStr(Edad) + ', '
              + IntToStr(DireccionANum(Direccion)) + ', '
              + IntToStr(Reservas.Agua) + ', '
              + IntToStr(Reservas.Azucar) + ', '
              + IntToStr(Reservas.Grasa) + ', '
              + IntToStr(Reservas.Proteina) + ', '
              //+ IntToStr(Reproduccion.Paquetes) + ', '
              + IntToStr(Gonada.Contador) + ', '
              //+ IntToStr(Reproduccion.Huevos) + ', '
              + IntToStr(Gonada.Contador) + ', '
              + IntToStr(Fertilizados.Contador) + ', '
              + IntToStr(Acarreados) + ', '
              //+ IntToStr(Reproduccion.Almacenados) + ', ';
              + IntToStr(Espermateca.Contador) + ', ';
      for i := 1 to 16 do
      begin
        Linea := Linea + IntToStr(Memoria.UltConductas[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumConductas[i]) + ', ';
      end;
      for i := 1 to 7 do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerSust[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerSust[i]) + ', ';
      end;
      for i := 1 to 5 do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntDin[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntDin[i]) + ', ';
      end;
      for i := 1 to Juego.NumEstadios do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntEstadios[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntEstadios[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposM do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntMachos[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntMachos[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposH do
      begin
        Linea := Linea + IntToStr(Memoria.UltIntHembras[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumIntHembras[i-1]) + ', ';
      end;
      for i := 1 to 5 do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerDin[i]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerDin[i]) + ', ';
      end;
      for i := 1 to Juego.NumEstadios do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerEstadios[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerEstadios[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposM do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerMachos[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerMachos[i-1]) + ', ';
      end;
      for i := 1 to Juego.NumPrototiposH do
      begin
        Linea := Linea + IntToStr(Memoria.UltPerHembras[i-1]) + ', ';
        Linea := Linea + IntToStr(Memoria.NumPerHembras[i-1]) + ', ';
      end;
      Linea := Linea + IntToStr(Memoria.UltAccionContendiente) + ',';
      if Assigned(Interactuante) then
      begin
        if Interactuante is TAgente then
          Linea := Linea + 'Ag, ' + Interactuante.Nombre + ', '
        else if Interactuante is TSitioOviposicion then
          Linea := Linea + 'SO, ' + Interactuante.Nombre + ', '
        else if Interactuante is TDinamico then
          Linea := Linea + 'ED, ' + Interactuante.Nombre + ', '
        else
          Linea := Linea + ', ';
      end
      else
        Linea := Linea + ', ,';
      case Situacion of
        stInmaduro: Linea := Linea + 'Inm, ';
        stRegular: Linea := Linea + 'Reg, ';
        stCombate: Linea := Linea + 'Com, ';
        stCortejo: Linea := Linea + 'Cor, ';
      end;
    end;  //with Agente
  Result := Linea;
end;

function ReservasAString(Resevas: TReservas): string;
begin
  with Resevas do
    Result := IntToStr(Agua) + ','
            + IntToStr(Azucar) + ','
            + IntToStr(Grasa) + ','
            + IntToStr(Proteina) + ',';
end;

function PaqueteEspermaticoAString(Paquete: TPaqEspermatico): string;
begin
  with Paquete do
  begin
    Result := Donador + ',' + IntToStr(Paternidad) + ',';
    Result := Result + ReservasAString(Reservas);
    Result := Result + GenotipoAString(Genotipo);
  end;
end;

function HuevoFertilizadoAString(Huevo: THuevo): string;
var
  Linea: string;
begin
  with Huevo do
  begin
    Linea := Nombre + ', ' + Padre + ', ' + Madre + ', ';
    case Sexo of
      sxIndefinido : Linea := Linea + 'I' + ', ';
      sxMacho      : Linea := Linea + 'M' + ', ';
      sxHembra     : Linea := Linea + 'H' + ', ';
    end;
    Linea := Linea + ReservasAString(Reservas);
    Linea := Linea + GenotipoAString(Genotipo);
  end;  //with Huevo
  Result := Linea;
end;

function HuevoOvipositadoAString(Huevo: THuevo): string;
var
  Linea: string;
begin
  with Huevo do
  begin
    Linea := Nombre + ', ' + Padre + ', ' + Madre + ', ';
    if Portador is TAgente then
      Linea := Linea + (Huevo.Portador as TAgente).Nombre + ', '
    else
      Linea := Linea + (Huevo.Portador as TSitioOviposicion).Nombre + ', ';
    case Sexo of
      sxIndefinido : Linea := Linea + 'I' + ', ';
      sxMacho      : Linea := Linea + 'M' + ', ';
      sxHembra     : Linea := Linea + 'H' + ', ';
    end;
    Linea := Linea + IntToStr(Edad) + ', ';
    Linea := Linea + ReservasAString(Reservas);
    Linea := Linea + GenotipoAString(Genotipo);
  end;  //with Huevo
  Result := Linea;
end;

function HuevoOvipositadoAStringConst(Huevo: THuevo): string;
{Convierte los datos inmutables (constantes) del huevo, excepto el nombre, en
una cadena de valores separados por comas}
var
  Linea: string;
begin
  with Huevo do
  begin
    Linea := Padre + ', ' + Madre + ', ';
    if Portador is TAgente then
      Linea := Linea + (Huevo.Portador as TAgente).Nombre + ', '
    else
      Linea := Linea + (Huevo.Portador as TSitioOviposicion).Nombre + ', ';
    case Sexo of
      sxIndefinido : Linea := Linea + 'I' + ', ';
      sxMacho      : Linea := Linea + 'M' + ', ';
      sxHembra     : Linea := Linea + 'H' + ', ';
    end;
    Linea := Linea + ReservasAString(Reservas);
    Linea := Linea + GenotipoAString(Genotipo);
  end;  //with Huevo
  Result := Linea;
end;

function ElementoDinamicoAString(Dinamico: TDinamico): string;
var
  Linea: string;
begin
  with Dinamico do
  begin
    case TipoED of
      edFntAgua    : Linea := 'FntAgua, ';
      edFntGrasa   : Linea := 'FntGrasa, ';
      edFntAzucar  : Linea := 'FntAzucar, ';
      edFntProteina: Linea := 'FntProteina, ';
    end;  //case
    Linea := Linea + Nombre + ', ' + IntToStr(X) + ', ' + IntToStr(Y) + ', '
                     + IntToStr(Calidad) + ', ' + IntToStr(Nivel) + ', '
                     + IntToStr(Maximo) + ', ' + FloatToStr(Tasa);
  end;  //with
  Result := Linea;
end;

function SitOviposicionAString(SitOviposicion: TSitioOviposicion): string;
begin
  with SitOviposicion do
    Result := Nombre + ', ' + IntToStr(X) + ', ' + IntToStr(Y) + ', '
                     + IntToStr(Calidad) + ', ' + IntToStr(Nivel) + ', '
                     + IntToStr(Maximo) + ', ' + FloatToStr(Tasa);
end;

end.
