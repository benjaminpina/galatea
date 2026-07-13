{*******************************************************************************
Sistema Simulador de Estrategias Reproductivas Galatea

© Derechos Reservados. Benjamín Piña Altamirano. 2005

Registro Instituto Nacional del Derecho de Autor número: xxxxx


*******************************************************************************}
unit Mediadores;

{$MODE Delphi}

{*******************************************************************************
Contiene la clase Mediador, el cual permite acceder a los valores del agente
que requieren consulta con el prototipo de agente a partir del cual fue creado
y con el entorno en que "vive" el agente.
En otras palabras, un objeto mediador proporciona información a apartir de un
objeto agente, un objeto juego de agentes y un objeto entorno, permitiendo
acceder a todos los datos relacionados con el agente que impliquen
interpretacioón de fórmulas o acceso a valores que en realidad no contiene el
objeto agente.
Y, en caso de ser especificados, un agente interactuante y/o un elemento
dinámico, permite acceder a valores que dependen de otros elementos del entorno.
*******************************************************************************}

interface

uses
  JuegoAgentes, Elementos, Agentes, Entornos, Calculate, Comunes;//, Graphics;

type

  TMediador = class
  private
    Calculadora: TCalculate;
    JuegoAgentes: TJuegoAgentes;
    Entorno: TEntorno;
    FAgente,
    FContendiente: TAgente;
    FDinamico: TDinamico;
    FHuevo: THuevo;
    function GetNombrePrototipo: string;
    function GetColor: TColor;
    procedure ObtenNombreVariable(Sender: TObject; Name: string;
                                    var Value: Extended);
    function GetValorEntero(Variable: string): Integer;
    function GetValorReal(Variable: string): Real;
    function GetAtractividadAgentes(X, Y, Z: Byte): Integer;
    function GetAtractividadDinamicos(X, Y, Z: Byte): Integer;
    function GetAtractividadSustratos(X, Y, Z: Byte): Integer;
    function GetCombate(X, Y: Byte): Integer;
    function GetCortejo(X, Y: Byte): Integer;
    function GetInteraccionAgentes(X, Y, Z: Byte): Integer;
    function GetInteraccionDinamicos(X, Y, Z: Byte): Integer;
    function GetInteraccionSustratos(X, Y, Z: Byte): Integer;
    function GetMemoriaAgentes(i: Byte): Integer;
    function GetMemoriaSustratos(i: Byte): Integer;
    function GetMemoriaDinamicos(i: Byte): Integer;
    function GetMemoriaConductas(i: Byte): Integer;
    function GetValor1_0(Variable: string): Real;
    function GetTendencias(Dir: Word): Integer;
    function VariablesTiempo(Variable: string): Integer;
    function VariablesGenetica(Variable: string): Extended;
    function VariablesMorfologia(Variable: string): Extended;
    function VariablesMorfologiaGeneticas(Variable: string): Extended;
    function VariablesMorfologiaAmbientales(Variable: string): Extended;
    function VariablesFisiologia(Variable: string): Integer;
    function VariablesReproduccion(Variable: string): Integer;
    function VariablesMemoria(Variable: string): Integer;
    function VariablesElemento(Variable: string): Integer;
    function VariablesContendiente(Variable: string): Extended;
    function VariablesJuegoAgentes(Variable: string): Extended;
  public
    function PrototipoListado: Integer;
    function PrototipoListadoContendiente: Integer;
    constructor Create(PEntorno: TEntorno);
    destructor Destroy; override;
    property NombrePrototipo: string
      read GetNombrePrototipo;
    property Color: TColor
      read GetColor;
    property Huevo: THuevo
      read FHuevo write FHuevo;
    property Agente: TAgente
      read FAgente write FAgente;
    property Dinamico: TDinamico
      read FDinamico write FDinamico;
    property Contendiente: TAgente
      read FContendiente write FContendiente;
    property ValorEntero[Variable: string]: Integer
      read GetValorEntero;
    property ValorReal[Variable: string]: Real
      read GetValorReal;
    property Valor1_0[Variable: string]: Real
      read GetValor1_0;
    property Tendencias[Dir: Word]: Integer
      read GetTendencias;
    property Combate[X, Y: Byte]: Integer
      read GetCombate;                        //X: columna, Y: renglón, Z: celda
    property Cortejo[X, Y: Byte]: Integer
      read GetCortejo;
    property InteraccionSustratos[X, Y, Z: Byte]: Integer
      read GetInteraccionSustratos;
    property InteraccionDinamicos[X, Y, Z: Byte]: Integer
      read GetInteraccionDinamicos;
    property InteraccionAgentes[X, Y, Z: Byte]: Integer
      read GetInteraccionAgentes;
    property AtractividadSustratos[X, Y, Z: Byte]: Integer
      read GetAtractividadSustratos;
    property AtractividadDinamicos[X, Y, Z: Byte]: Integer
      read GetAtractividadDinamicos;
    property AtractividadAgentes[X, Y, Z: Byte]: Integer
      read GetAtractividadAgentes;
    property MemoriaSustratos[i: Byte]: Integer
      read GetMemoriaSustratos;
    property MemoriaDinamicos[i: Byte]: Integer
      read GetMemoriaDinamicos;
    property MemoriaAgentes[i: Byte]: Integer
      read GetMemoriaAgentes;
    property MemoriaConductas[i: Byte]: Integer
      read GetMemoriaConductas;
  end;
  
const
  NombreNut: array [1..4] of string = ('Agua', 'Azucar', 'Grasa', 'Proteina');

implementation

uses
  SysUtils;


{ TMediador }

constructor TMediador.Create(PEntorno: TEntorno);
begin
  Entorno := PEntorno;
  JuegoAgentes := PEntorno.Juego;
  Calculadora := TCalculate.Create;
  Calculadora.OnFindVariable := ObtenNombreVariable;
end;

destructor TMediador.Destroy;
begin
  Calculadora.Free;
  inherited Destroy;
end;

function TMediador.GetAtractividadAgentes(X, Y, Z: Byte): Integer;
var
  Celda: string;
begin
  Celda := JuegoAgentes.MatrizAgentesA.Celda[X,Y];
  Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
end;

function TMediador.GetAtractividadDinamicos(X, Y, Z: Byte): Integer;
 var
  Celda: string;
begin
  Celda := JuegoAgentes.MatrizDinamicosA.Celda[X,Y];
  Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
end;

function TMediador.GetAtractividadSustratos(X, Y, Z: Byte): Integer;
var
  Celda: string;
  s: string;
begin
  if X <= 7 then
  begin
    Celda := JuegoAgentes.MatrizSustratosA.Celda[X,Y];
    Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
  end
  else
  begin
    s := '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[1,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[1]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[2,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[2]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[3,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[3]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[4,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[4]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[5,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[5]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[6,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[6]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratosA.Celda[7,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[7]) + '/100))';
    Result := Calculadora.GetInt(s)
  end;
end;

function TMediador.GetColor: TColor;
begin
  Result := $FFFFFF; //blanco 
  with Agente do
  begin
    if not Adulto then
      Result := JuegoAgentes.Estadios[Estadio].Color
    else
      case Sexo of
        sxMacho: Result := JuegoAgentes.PrototiposM[Prototipo].Color;
        sxHembra: Result := JuegoAgentes.PrototiposM[Prototipo].Color;
      end;
  end;
end;

function TMediador.GetCombate(X, Y: Byte): Integer;
begin
  if Agente.Sexo = sxMacho then
    Result := Calculadora.GetInt(
        JuegoAgentes.PrototiposM[Agente.Prototipo].Combate[X,Y])
  else
    Result := Calculadora.GetInt(
        JuegoAgentes.PrototiposH[Agente.Prototipo].Combate[X,Y]);
end;

function TMediador.GetCortejo(X, Y: Byte): Integer;
begin
  if Agente.Sexo = sxMacho then
    Result := Calculadora.GetInt(
        JuegoAgentes.PrototiposM[Agente.Prototipo].Cortejo[X,Y])
  else
    Result := Calculadora.GetInt(
        JuegoAgentes.PrototiposH[Agente.Prototipo].Cortejo[X,Y]);
end;

function TMediador.GetInteraccionAgentes(X, Y, Z: Byte): Integer;
var
  Celda: string;
begin
  Celda := JuegoAgentes.MatrizAgentes.Celda[X,Y];
  Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
end;

function TMediador.GetInteraccionDinamicos(X, Y, Z: Byte): Integer;
var
  Celda: string;
begin
  Celda := JuegoAgentes.MatrizDinamicos.Celda[X,Y];
  Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
end;

function TMediador.GetInteraccionSustratos(X, Y, Z: Byte): Integer;
var
  s,
  Celda: string;
begin
  if X <= 7 then
  begin
    Celda := JuegoAgentes.MatrizSustratos.Celda[X,Y];
    Result := Calculadora.GetInt(ObtenNsimo(Celda, Z));
  end
  else
  begin
    s := '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[1,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[1]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[2,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[2]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[3,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[3]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[4,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[4]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[5,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[5]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[6,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[6]) + '/100))+'
        + '(' + ObtenNsimo(JuegoAgentes.MatrizSustratos.Celda[7,Y], Z)
        + '*(' + IntToStr(Entorno.Mixtos[X-7].Porcentajes[7]) + '/100))';
    Result := Calculadora.GetInt(s)
  end;
end;

function TMediador.GetMemoriaAgentes(i: Byte): Integer;
begin
  Result := Calculadora.GetInt(
      JuegoAgentes.MatrizAgentesM.Celda[i,PrototipoListado])
end;

function TMediador.GetMemoriaConductas(i: Byte): Integer;
begin
  Result := Calculadora.GetInt(
      JuegoAgentes.MatrizConductasM.Celda[i,PrototipoListado])
end;

function TMediador.GetMemoriaDinamicos(i: Byte): Integer;
begin
  Result := Calculadora.GetInt(
      JuegoAgentes.MatrizDinamicosM.Celda[i,PrototipoListado])
end;

function TMediador.GetMemoriaSustratos(i: Byte): Integer;
begin
  Result := Calculadora.GetInt(
      JuegoAgentes.MatrizSustratosM.Celda[i,PrototipoListado])
end;

function TMediador.GetNombrePrototipo: string;
begin
  with Agente do
  begin
    if not Adulto then
      Result := JuegoAgentes.Estadios[Estadio].Nombre
    else
      case Sexo of
        sxMacho: Result := JuegoAgentes.PrototiposM[Prototipo].Nombre;
        sxHembra: Result := JuegoAgentes.PrototiposH[Prototipo].Nombre;
      end;
  end;
end;

function TMediador.GetTendencias(Dir: Word): Integer;
var
  i: Integer;
  Tendencias: array [1..8] of string;
begin
  with Agente do
  begin
    if not Adulto then
    begin
      for i := 1 to 8 do
        Tendencias[i] := JuegoAgentes.Estadios[Estadio].Tendencias[i];
    end
    else
      case Sexo of
        sxMacho:
          for i := 1 to 8 do
            Tendencias[i] := JuegoAgentes.PrototiposM[Prototipo].Tendencias[i];
        sxHembra:
          for i := 1 to 8 do
            Tendencias[i] := JuegoAgentes.PrototiposH[Prototipo].Tendencias[i];
      end;
  end;  //with Agente
  Result := Calculadora.GetInt(Tendencias[Dir]);
end;

function TMediador.GetValor1_0(Variable: string): Real;
{Regresa un valor real entre 0 y 1}
var
  Valor: Real;
begin
  Valor := StrToFloat(Calculadora.GetCustom(Variable, ''));
  if Valor > 1 then
    Result := 1
  else if Valor < 0 then
    Result := 0
  else
    Result := Valor;
end;

function TMediador.GetValorEntero(Variable: string): Integer;
begin
  Result := Calculadora.GetInt(Variable);
end;

function TMediador.GetValorReal(Variable: string): Real;
begin
  Result := StrToFloat(Calculadora.GetCustom(Variable, ''));
end;

procedure TMediador.ObtenNombreVariable(Sender: TObject; Name: string;
  var Value: Extended);
var
  i: Integer;
begin
  //Variables morfológicas
  for i := 1 to 15 do
    if ComienzaCon(Name, JuegoAgentes.Continuos[i].Nombre) or
        ComienzaCon(Name, JuegoAgentes.Discretos[i].Nombre) then
    begin
      if TerminaCon(Name, 'Genetico') then
        Value := VariablesMorfologiaGeneticas(Name)
      else if TerminaCon(Name, 'Ambiental') then
        Value := VariablesMorfologiaAmbientales(Name)
      else
        Value := VariablesMorfologia(Name);
      Exit; //-->
    end;
  //Variables de tiempo
  if (Name = 'Cycles') or (Name = 'Age') or (Name = 'NumLifeStage') or
      (Name = 'CyclesInCurrentLifeStage') or (Name = 'CyclesOnSubstrate') or
        (Name = 'CyclesInCurrentInteraction') then
    Value := VariablesTiempo(Name)
  //Variables genéticas
  else if (ComienzaCon(Name, 'CL')) or (ComienzaCon(Name, 'DL')) then
    Value := VariablesGenetica(Name)
  //Variables fisiológicas
  else if ComienzaCon(Name, 'Reserve') then
    Value := VariablesFisiologia(Name)
  //Variables reproducción
  else if (Name = 'QuantitySpermPacks') or (Name = 'QuantityEggs') or
      (Name = 'QuantityFertilizedEggs') or (Name = 'QuantityCarriedEggs') or
      (Name = 'QuantitySpermPacksStored') or (Name = 'Virginity') then
    Value := VariablesReproduccion(Name)
  //Variables de memoria
  else if ComienzaCon(Name, 'Memory') then
    Value := VariablesMemoria(Name)
  //Variables del elemento dinámico
  else if ComienzaCon(Name, 'DynamicElement') then
    Value := VariablesElemento(Name)
  //Variables del contendiente
  else if TerminaCon(Name, 'Contender') then
     Value := VariablesContendiente(Name)
  //Variables del juego de agentes
  else
    Value := VariablesJuegoAgentes(Name);
end;

function TMediador.PrototipoListado: Integer;
{Regresa la posición del prototipo de Agente dentro de un listado que incluye
a todos los estadios y prototipos de machos y hembras}
begin
  if not Agente.Adulto then
    Result := Agente.Estadio
  else if Agente.Sexo = sxMacho then
    Result := JuegoAgentes.NumEstadios + Agente.Prototipo
  else
    Result := JuegoAgentes.NumEstadios + JuegoAgentes.NumPrototiposM
        + Agente.Prototipo;
end;

function TMediador.PrototipoListadoContendiente: Integer;
begin
  if not FContendiente.Adulto then
    Result := FContendiente.Estadio
  else if FContendiente.Sexo = sxMacho then
    Result := JuegoAgentes.NumEstadios + FContendiente.Prototipo
  else
    Result := JuegoAgentes.NumEstadios + JuegoAgentes.NumPrototiposM
        + FContendiente.Prototipo;
end;

function TMediador.VariablesContendiente(Variable: string): Extended;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to 15 do
  begin
    if ComienzaCon(Variable, JuegoAgentes.Continuos[i].Nombre) then
    begin
      if Contendiente.Sexo = sxMacho then
        Result := Calculadora.GetMoney
            (JuegoAgentes.PrototiposM[Contendiente.Prototipo].Continuos[i].ValorGenetico)
      else
        Result := Calculadora.GetMoney
            (JuegoAgentes.PrototiposH[Contendiente.Prototipo].Continuos[i].ValorGenetico);
      Exit; //-->
    end;
    if Variable = JuegoAgentes.Discretos[i].Nombre then
    begin
      if Contendiente.Sexo = sxMacho then
        Result := Calculadora.GetInt
            (JuegoAgentes.PrototiposM[Contendiente.Prototipo].Discretos[i].ValorGenetico)
      else
        Result := Calculadora.GetInt
            (JuegoAgentes.PrototiposH[Contendiente.Prototipo].Discretos[i].ValorGenetico);
      Exit; //-->
    end;
  end;
end;

function TMediador.VariablesElemento(Variable: string): Integer;
begin
  if Variable = 'DynamicElementQuality' then
    Result :=  Dinamico.Calidad
  else if Variable = 'DynamicElementLevel' then
    Result := Dinamico.Nivel
  else
    Result := 0;
end;

function TMediador.VariablesFisiologia(Variable: string): Integer;
var
  s: string;
begin
  s := Variable;
  Delete(s, 1, 7);  //Obteniendo nombre de nutrimento
  if Assigned(Huevo) then
  begin
    if s = 'Water' then
      Result := Huevo.Reservas.Agua
    else if s = 'Carbohidrates' then
      Result := Huevo.Reservas.Azucar
    else if s = 'Lipids' then
      Result := Huevo.Reservas.Grasa
    else if s = 'Protein' then
      Result := Huevo.Reservas.Proteina
    else
      Result := 0;
    Exit; //-->
  end;
  if s = 'Water' then
    Result := Agente.Reservas.Agua
  else if s = 'Carbohidrates' then
    Result := Agente.Reservas.Azucar
  else if s = 'Lipids' then
    Result := Agente.Reservas.Grasa
  else if s = 'Protein' then
    Result := Agente.Reservas.Proteina
  else
    Result := 0;
end;

function TMediador.VariablesGenetica(Variable: string): Extended;
var
  i: Integer;
  s: string;
begin
  s := Variable;
  if Assigned(Huevo) then
  begin
     if ComienzaCon(Variable, 'CL') then
    begin
      Delete(s, 1, 2);  //Obteniendo número del locus
      i := StrToInt(s);
      Result := Huevo.LociContinuos[i];
    end
    else if ComienzaCon(Variable, 'DL') then
    begin
      Delete(s, 1, 2);  //Obteniendo número del locus
      i := StrToInt(s);
      Result := Huevo.LociDiscretos[i];
    end
    else
      Result := 0;
    Exit; //-->
  end;
  if ComienzaCon(Variable, 'CL') then
  begin
    Delete(s, 1, 2);  //Obteniendo número del locus
    i := StrToInt(s);
    Result := Agente.LociContinuos[i];
  end
  else if ComienzaCon(Variable, 'DL') then
  begin
    Delete(s, 1, 2);  //Obteniendo número del locus
    i := StrToInt(s);
    Result := Agente.LociDiscretos[i];
  end
  else
    Result := 0;
end;

function TMediador.VariablesJuegoAgentes(Variable: string): Extended;
var
  r   : Real;
  i, j: Integer;
  s   : string;
  c   : Char;
begin
  Result := 0;
  s := Variable;
  with JuegoAgentes do
  begin
    if ComienzaCon(Variable, 'CriterioAsignacionMacho') then
    begin
      Delete(s, 1, 23);  //Obteniendo número del prototipo
      i := StrToInt(s);
      Result := Calculadora.GetMoney(CriteriosM[0,i-1]);
      Exit; //-->
    end;
    if ComienzaCon(Variable, 'CriterioAsignacionHembra') then
    begin
      Delete(s, 1, 24);  //Obteniendo número del prototipo
      i := StrToInt(s);
      Result := Calculadora.GetMoney(CriteriosH[0,i-1]);
      Exit; //-->
    end;
    if ComienzaCon(Variable, 'CiclosEstadio') then
    begin
      Delete(s, 1, 13);  //Obteniendo número del estadio
      i := StrToInt(s);
      Result := Calculadora.GetInt(Estadios[i].Ciclos);
      Exit; //-->
    end;
    if ComienzaCon(Variable, 'Condicion1Estadio') then
    begin
      Delete(s, 1, 17);  //Obteniendo número del estadio
      i := StrToInt(s);
      Result := Calculadora.GetMoney(ObtenNsimo(Estadios[i].Condicion1, 1));
      Exit; //-->
    end;
    if ComienzaCon(Variable, 'Condicion2Estadio') then
    begin
      Delete(s, 1, 17);  //Obteniendo número del estadio
      i := StrToInt(s);
      Result := Calculadora.GetMoney(ObtenNsimo(Estadios[i].Condicion2, 1));
      Exit; //-->
    end;
    if ComienzaCon(Variable, 'Requerimiento') then
    begin
      for i := 1 to 4 do
        if ComienzaCon(Variable, 'Requerimiento' +  NombreNut[i]) then
        begin
          Delete(s, 1, 13 + Length(NombreNut[i])); //Obteniendo número estadio
          j := StrToInt(s);
          Result := Calculadora.GetInt(Estadios[j].Requiere[i]);
          Exit; //-->
        end;
    end;
    if ComienzaCon(Variable, 'Costo') then
    begin
      for i := 1 to 4 do
        if ComienzaCon(Variable, 'Costo' + NombreNut[i]) then
        begin
          Delete(s, 1, 5 + Length(NombreNut[i]));  //Obteniendo número estadio
          j := StrToInt(s);
          Result := Calculadora.GetInt(Estadios[j].Costos[i]);
          Exit; //-->
        end;
    end;
    for i := 1 to 4 do
      if TerminaCon(Variable, NombreNut[i]) then
      begin
        if ComienzaCon(Variable, 'Minimo') then
          Result := Calculadora.GetInt(Metabolismo[1,i])
        else if ComienzaCon(Variable, 'Critico') then
          Result := Calculadora.GetInt(Metabolismo[2,i])
        else if ComienzaCon(Variable, 'Optimo') then
          Result := Calculadora.GetInt(Metabolismo[3,i])
        else if ComienzaCon(Variable, 'Inicial') then
          Result := Calculadora.GetInt(Metabolismo[4,i])
        else if ComienzaCon(Variable, 'Maximo') then
          Result := Calculadora.GetInt(Metabolismo[5,i])
        else if ComienzaCon(Variable, 'CostoHuevo') then
          Result := Calculadora.GetInt(CostoHuevo[i])
        else if ComienzaCon(Variable, 'CostoPaquete') then
          Result := Calculadora.GetInt(CostoPaquete[i])
        else if ComienzaCon(Variable, 'CostoDesplegar') then
          Result := Calculadora.GetInt(CostosCombate[i,1])
        else if ComienzaCon(Variable, 'CostoEscalar') then
          Result := Calculadora.GetInt(CostosCombate[i,2])
        else if ComienzaCon(Variable, 'CostoRetirar') then
          Result := Calculadora.GetInt(CostosCombate[i,3])
        else if ComienzaCon(Variable, 'CostoIntentoDesplegado') then
          Result := Calculadora.GetInt(CostosCortejo[i,1])
        else if ComienzaCon(Variable, 'CostoIntentoEscalado') then
          Result := Calculadora.GetInt(CostosCortejo[i,2])
        else if ComienzaCon(Variable, 'CostoAceptar') then
          Result := Calculadora.GetInt(CostosCortejo[i,3])
        else if ComienzaCon(Variable, 'CostoRechazar') then
          Result := Calculadora.GetInt(CostosCortejo[i,4])
        else if ComienzaCon(Variable, 'CostoCopular') then
          Result := Calculadora.GetInt(CostosCortejo[i,5])
        else if ComienzaCon(Variable, 'CostoOvipositar') then
          Result := Calculadora.GetInt(CostosCortejo[i,6])
        else if ComienzaCon(Variable, 'CostoMover') then
          Result := Calculadora.GetInt(Movimiento.Costos[i,1])
        else if ComienzaCon(Variable, 'CostoReposar') then
          Result := Calculadora.GetInt(Movimiento.Costos[i,2])
        else if ComienzaCon(Variable, 'CostoBeber') then
          Result := Calculadora.GetInt(Alimentacion.Costos[i,1])
        else if ComienzaCon(Variable, 'CostoComerAzucar') then
          Result := Calculadora.GetInt(Alimentacion.Costos[i,2])
        else if ComienzaCon(Variable, 'CostoComerGrasa') then
          Result := Calculadora.GetInt(Alimentacion.Costos[i,3])
        else if ComienzaCon(Variable, 'CostoComerProteina') then
          Result := Calculadora.GetInt(Alimentacion.Costos[i,4])
        else if ComienzaCon(Variable, 'Ganancia') then
          Result := Calculadora.GetInt(Alimentacion.Ganancias[i]);
        Exit; //-->
      end;
    if ComienzaCon(Variable, 'VelocidadSustrato') then
    begin
      Delete(s, 1, 17);
      try
        i := StrToInt(s);
        Result := Calculadora.GetInt(Movimiento.Velocidad[i]); //Sustrato simple
      except on EConvertError do
      begin
        c := s[1];          //Sustrato mixto
        i := Ord(c) - 64;
        r := 0;
        for j := 1 to 7 do
          r := r + Calculadora.GetMoney('VelocidadSustrato' + IntToStr(j)
              + '*(' + IntToStr(Entorno.Mixtos[i].Porcentajes[j]) + ')/100');
        Result := Round(r);
      end;  //on except
      end;  //try
      Exit; //-->
    end;
    if Agente.Sexo = sxMacho then
    begin
      if Variable = 'RefractarioCombate' then
        Result := Calculadora.GetInt
            (PrototiposM[Agente.Prototipo].RefractarioCombate)
      else if Variable = 'RefractarioCortejo' then
        Result := Calculadora.GetInt
            (PrototiposM[Agente.Prototipo].RefractarioCortejo)
      else if Variable = 'Longevidad' then
        Result := Calculadora.GetInt
            (PrototiposM[Agente.Prototipo].Longevidad);
    end
    else if Agente.Sexo = sxHembra then
    begin
      if Variable = 'RefractarioCombate' then
        Result := Calculadora.GetInt
            (PrototiposH[Agente.Prototipo].RefractarioCombate)
      else if Variable = 'RefractarioCortejo' then
        Result := Calculadora.GetInt
            (PrototiposH[Agente.Prototipo].RefractarioCortejo)
      else if Variable = 'Longevidad' then
        Result := Calculadora.GetInt
            (PrototiposH[Agente.Prototipo].Longevidad)
      else if Variable = 'ProporcionMachos' then
        Result := Calculadora.GetInt
            (PrototiposH[Agente.Prototipo].ProporcionMachos)
      else if Variable = 'ProporcionHembras' then
        Result := Calculadora.GetInt
            (PrototiposH[Agente.Prototipo].ProporcionHembras);
    end;
    if Variable = 'MaximoHuevos' then
      Result := Calculadora.GetInt(MaxHuevos)
    else if Variable = 'MaximoPaquetes' then
      Result := Calculadora.GetInt(MaxPaquetes)
    else if Variable = 'TasaConsumoPaquete' then
      Result := Calculadora.GetInt(TasaConsumo)
    else if Variable = 'MaximoPaquetesAlmacenados' then
      Result := Calculadora.GetInt(MaxPaquetesH)
    else if Variable = 'OvipositadosCiclo' then
      Result := Calculadora.GetInt(HuevosCiclo)
    else if Variable = 'FraccionHuevo' then
      Result := Calculadora.GetMoney(FraccionHuevo)
    else if Variable = 'FraccionPaquete' then
      Result := Calculadora.GetMoney(FraccionPaquete)
    else if Variable = 'PaquetesTransferidos' then
      Result := Calculadora.GetInt(PaquetesTransferidos)
    else if Variable = 'FraccionFertilizados' then
      Result := Calculadora.GetMoney(HuevosFertilizados)
    else if Variable = 'Paternidad' then
      Result := Calculadora.GetInt(Paternidad)
    else if Variable = 'TasaDegradacionEsperma' then
      Result := Calculadora.GetMoney(DegradacionEsperma);
  end;  //with JuegoAgentes
end;  //proc VariablesJuegoAgentes

function TMediador.VariablesMemoria(Variable: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  if TerminaCon(Variable, 'WaterSource') then
  begin
    if ComienzaCon(Variable, 'MemoryLastPer') then
      Result := Agente.Memoria.UltPerDin[1]
    else if ComienzaCon(Variable, 'MemoryNumPer') then
      Result := Agente.Memoria.NumPerDin[1]
    else if ComienzaCon(Variable, 'MemoryLastInt') then
      Result := Agente.Memoria.UltIntDin[1]
    else if ComienzaCon(Variable, 'MemoryNumInt') then
      Result := Agente.Memoria.NumIntDin[1]
  end
  else if TerminaCon(Variable, 'SugarSource') then
  begin
    if ComienzaCon(Variable, 'MemoryLastPer') then
      Result := Agente.Memoria.UltPerDin[2]
    else if ComienzaCon(Variable, 'MemoryNumPer') then
      Result := Agente.Memoria.NumPerDin[2]
    else if ComienzaCon(Variable, 'MemoryLastInt') then
      Result := Agente.Memoria.UltIntDin[2]
    else if ComienzaCon(Variable, 'MemoryNumInt') then
      Result := Agente.Memoria.NumIntDin[2]
  end
  else if TerminaCon(Variable, 'FatSource') then
  begin
    if ComienzaCon(Variable, 'MemoryLastPer') then
      Result := Agente.Memoria.UltPerDin[3]
    else if ComienzaCon(Variable, 'MemoryNumPer') then
      Result := Agente.Memoria.NumPerDin[3]
    else if ComienzaCon(Variable, 'MemoryLastInt') then
      Result := Agente.Memoria.UltIntDin[3]
    else if ComienzaCon(Variable, 'MemoryNumInt') then
      Result := Agente.Memoria.NumIntDin[3]
  end
  else if TerminaCon(Variable, 'ProteinSource') then
  begin
    if ComienzaCon(Variable, 'MemoryLastPer') then
      Result := Agente.Memoria.UltPerDin[4]
    else if ComienzaCon(Variable, 'MemoryNumPer') then
      Result := Agente.Memoria.NumPerDin[4]
    else if ComienzaCon(Variable, 'MemoryLastInt') then
      Result := Agente.Memoria.UltIntDin[4]
    else if ComienzaCon(Variable, 'MemoryNumInt') then
      Result := Agente.Memoria.NumIntDin[4]
  end
  else if TerminaCon(Variable, 'OvipositionSite') then
  begin
    if ComienzaCon(Variable, 'MemoryLastPer') then
      Result := Agente.Memoria.UltPerDin[5]
    else if ComienzaCon(Variable, 'MemoryNumPer') then
      Result := Agente.Memoria.NumPerDin[5]
    else if ComienzaCon(Variable, 'MemoryLastInt') then
      Result := Agente.Memoria.UltIntDin[5]
    else if ComienzaCon(Variable, 'MemoryNumInt') then
      Result := Agente.Memoria.NumIntDin[5]
  end
  else
  begin
    for i := 1 to 7 do
      if TerminaCon(Variable, Entorno.NombreSustratos[i]) then
      begin
        if ComienzaCon(Variable, 'MemoryLastPer') then
          Result := Agente.Memoria.UltPerSust[i]
        else if ComienzaCon(Variable, 'MemoryNumPer') then
          Result := Agente.Memoria.NumPerSust[i]
      end;
    for i := 1 to JuegoAgentes.NumEstadios do
      if TerminaCon(Variable, JuegoAgentes.Estadios[i].Nombre) then
      begin
        if ComienzaCon(Variable, 'MemoryLastPer') then
          Result := Agente.Memoria.UltPerEstadios[i-1]
        else if ComienzaCon(Variable, 'MemoryNumPer') then
          Result := Agente.Memoria.NumPerEstadios[i-1]
        else if ComienzaCon(Variable, 'MemoryLastInt') then
          Result := Agente.Memoria.UltIntEstadios[i-1]
        else if ComienzaCon(Variable, 'MemoryNumInt') then
          Result := Agente.Memoria.NumIntEstadios[i-1]
      end;
      for i := 1 to JuegoAgentes.NumPrototiposM do
      if TerminaCon(Variable, JuegoAgentes.PrototiposM[i].Nombre) then
      begin
        if ComienzaCon(Variable, 'MemoryLastPer') then
          Result := Agente.Memoria.UltPerMachos[i-1]
        else if ComienzaCon(Variable, 'MemoryNumPer') then
          Result := Agente.Memoria.NumPerMachos[i-1]
        else if ComienzaCon(Variable, 'MemoryLastInt') then
          Result := Agente.Memoria.UltIntMachos[i-1]
        else if ComienzaCon(Variable, 'MemoryNumInt') then
          Result := Agente.Memoria.NumIntMachos[i-1]
      end;
      for i := 1 to JuegoAgentes.NumPrototiposH do
      if TerminaCon(Variable, JuegoAgentes.PrototiposH[i].Nombre) then
      begin
        if ComienzaCon(Variable, 'MemoryLastPer') then
          Result := Agente.Memoria.UltPerHembras[i-1]
        else if ComienzaCon(Variable, 'MemoryNumPer') then
          Result := Agente.Memoria.NumPerHembras[i-1]
        else if ComienzaCon(Variable, 'MemoryLastInt') then
          Result := Agente.Memoria.UltIntHembras[i-1]
        else if ComienzaCon(Variable, 'MemoryNumInt') then
          Result := Agente.Memoria.NumIntHembras[i-1]
      end;
      for i := 1 to 16 do
        if TerminaCon(Variable, NombreConductas[i]) then
        begin
          if ComienzaCon(Variable, 'MemoryLast') then
          Result := Agente.Memoria.UltConductas[i]
        else if ComienzaCon(Variable, 'MemoryNum') then
          Result := Agente.Memoria.NumConductas[i]
        end;
  end;
end;  //proc VariablesMemoria

function TMediador.VariablesMorfologia(Variable: string): Extended;
var
  i: Integer;
begin
  Result := 0;
  with JuegoAgentes do
  begin
    for i := 1 to 15 do
    begin
      if Variable = Continuos[i].Nombre then
      begin
        Result := Agente.ContinuosFijados[i];
        Result := Result + Calculadora.GetMoney(Variable + 'Ambiental');
        Exit; //-->
      end;
      if Variable = Discretos[i].Nombre then
      begin
        Result := Agente.DiscretosFijados[i];
        Result := Result + Calculadora.GetInt(Variable + 'Ambiental');
        Exit; //-->
      end;
    end;  //for
  end;  //with
end;

function TMediador.VariablesMorfologiaAmbientales(
  Variable: string): Extended;
var
  i: Integer;
  CalculaMorfo: TCalculate;
begin
  Result := 0;
  CalculaMorfo := TCalculate.Create;
  CalculaMorfo.OnFindVariable := ObtenNombreVariable;
  with JuegoAgentes do
  begin
    for i := 1 to 15 do
    begin
      if Variable = Continuos[i].Nombre then
      begin
        if Agente.Sexo = sxMacho then
        begin
          CalculaMorfo.Memory.Add(Variable + '=' +
              PrototiposM[Agente.Prototipo].Continuos[i].ValorAmbiental);
          Result := CalculaMorfo.GetMoney(Variable);
        end
        else
        begin
          CalculaMorfo.Memory.Add(Variable + '=' +
              PrototiposH[Agente.Prototipo].Continuos[i].ValorAmbiental);
          Result := CalculaMorfo.GetMoney(Variable);
        end;
        CalculaMorfo.Free;
        Exit; //-->
      end;
      if Variable = Discretos[i].Nombre then
      begin
        if Agente.Sexo = sxMacho then
        begin
          CalculaMorfo.Memory.Add(Variable + '=' +
              PrototiposM[Agente.Prototipo].Discretos[i].ValorAmbiental);
          Result := CalculaMorfo.GetInt(Variable);
        end
        else
        begin
          CalculaMorfo.Memory.Add(Variable + '=' +
              PrototiposH[Agente.Prototipo].Discretos[i].ValorAmbiental);
          Result := CalculaMorfo.GetInt(Variable);
        end;
        CalculaMorfo.Free;
        Exit; //-->
      end;
    end;
  end;  //with
  CalculaMorfo.Free;
end;

function TMediador.VariablesMorfologiaGeneticas(
  Variable: string): Extended;
var
  i: Integer;
  CalculaMorfo: TCalculate;
begin
  Result := 0;
  CalculaMorfo := TCalculate.Create;
  CalculaMorfo.OnFindVariable := ObtenNombreVariable;
  with JuegoAgentes do
  begin
    for i := 1 to 15 do
    begin
      if ComienzaCon(Variable, Continuos[i].Nombre) then
      begin
        if Agente.Sexo = sxMacho then
        begin
          // CalculaMorfo.Memory.Add(Variable + '=' +
            //  PrototiposM[Agente.Prototipo].Continuos[i].ValorGenetico);
         // Result := CalculaMorfo.GetMoney(Variable);
         Result := CalculaMorfo.GetMoney
                   (PrototiposM[Agente.Prototipo].Continuos[i].ValorGenetico);
        end
        else
        begin
          Result := CalculaMorfo.GetMoney
                    (PrototiposH[Agente.Prototipo].Continuos[i].ValorGenetico);
        end;
        CalculaMorfo.Free;
        Exit; //-->
      end;
      if ComienzaCon(Variable, Discretos[i].Nombre) then
      begin
        if Agente.Sexo = sxMacho then
        begin
          //CalculaMorfo.Memory.Add(Variable + '=' +
              //PrototiposM[Agente.Prototipo].Discretos[i].ValorGenetico);
          Result := CalculaMorfo.GetInt
                    (PrototiposM[Agente.Prototipo].Discretos[i].ValorGenetico);
        end
        else
        begin
          //CalculaMorfo.Memory.Add(Variable + '=' +
              //PrototiposH[Agente.Prototipo].Discretos[i].ValorGenetico);
          Result := CalculaMorfo.GetInt
                    (PrototiposH[Agente.Prototipo].Discretos[i].ValorGenetico);
        end;
        CalculaMorfo.Free;
        Exit; //-->
      end;
    end;
  end;  //with
  CalculaMorfo.Free;
end;

function TMediador.VariablesReproduccion(Variable: string): Integer;
begin
  if Variable = 'QuantitySpermPacks' then
    Result := Agente.Gonada.Contador
  else if Variable = 'QuantityEggs' then
    Result := Agente.Gonada.Contador
  else if Variable = 'QuantityFertilizedEggs' then
    Result := Agente.Fertilizados.Contador
  else if Variable = 'QuantityCarriedEggs' then
    Result := Agente.Acarreados
  else if Variable = 'QuantitySpermPacksStored' then
    Result := Agente.Espermateca.Contador
  else if Variable = 'Virginity' then
    if Agente.Virginidad then
      Result := 1
    else
      Result := 0
  else
    Result := 1;
end;

function TMediador.VariablesTiempo(Variable: string): Integer;
begin
  if Variable = 'Cycles' then
    Result := Entorno.Ciclos
  else if Variable = 'Age' then
    Result := Agente.Edad
  else if Variable = 'NumLifeStage' then
    Result := Agente.Estadio
  else if Variable = 'CyclesInCurrentLifeStage' then
    Result := Agente.Tiempo.EstadioActual
  else if Variable = 'CyclesOnSubstrate' then
    Result := Agente.Tiempo.SustratoActual
  else if Variable = 'CyclesInCurrentInteraction' then
    Result := Agente.Tiempo.InteraccionActual
  else
    Result := 0;
end;

end.
