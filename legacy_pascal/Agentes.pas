unit Agentes;

{$MODE Delphi}

interface

uses                              
  {ExtCtrls,} Contnrs, {Graphics,} Elementos, Comunes, JuegoAgentes;

type

  {Tipos}

  TCualidad = (cdDominante, cdRecesivo);
  TDireccion = (drNO, drN, drNE, drO, drE, drSO, drS, drSE, drT);
      //drT implica traslape, o dirección cenit
  TEstado = (esIndeciso, esDecidido, esActuando);
  TSituacion = (stInmaduro, stRegular, stCombate, stCortejo, stMuerto);
  TDirIndice = 0..8;
  TEventoDibuja = procedure (Sender: TObject; XFisica, YFisica,
      CuadroFisico: Word) of object;

  TReservas = record
    Agua,
    Azucar,
    Grasa,
    Proteina: Integer;
  end;

  TLocusContinuo = record
    Cualidad: TCualidad;
    Valor: Real;
  end;

  TLocusDiscreto = record
    Cualidad: TCualidad;
    Valor: Integer;
  end;

  TGenotipo = record
    PatContinuos,
    MatContinuos: array [1..15] of TLocusContinuo;
    PatDiscretos,
    MatDiscretos: array [1..15] of TLocusDiscreto;
  end;

  TMemoria = record
    UltPerSust: array [1..7] of Integer;
    NumPerSust: array [1..7] of Integer;
    UltIntDin: array [1..5] of Integer;
    NumIntDin: array [1..5] of Integer;
    UltPerDin: array [1..5] of Integer;
    NumPerDin: array [1..5] of Integer;
    UltConductas: array [1..16] of Integer;
    NumConductas: array [1..16] of Integer;
    UltIntEstadios: array of Integer;
    NumIntEstadios: array of Integer;
    UltIntMachos: array of Integer;
    NumIntMachos: array of Integer;
    UltIntHembras: array of Integer;
    NumIntHembras: array of Integer;
    UltPerEstadios: array of Integer;
    NumPerEstadios: array of Integer;
    UltPerMachos: array of Integer;
    NumPerMachos: array of Integer;
    UltPerHembras: array of Integer;
    NumPerHembras: array of Integer;
    UltAccionContendiente: Word;
  end;

  TTiempo = record
    EstadioActual,
    SustratoActual,
    InteraccionActual: Integer;
  end;

  TReferencia = record  //Contiene valores proporcionados por el entorno en
                        //tiempo de ejecución
    Minimos,
    Criticos,
    Optimos,
    Maximos,
    CostosGametos: array [1..4] of Integer;
    Longevidad,
    UnidadesTomadas,
    MaxGametos,
    PaqTransferidos,
    MaxPaqAlmacenados,
    ProbPaternidad,
    OvipositadosCiclo,
    PropMachos,
    PropHembras: Integer;
    TasaConsumoPaq,
    TasaDegradacion,
    FraccFertilizados,
    FraccPaquete,
    FraccHuevo: Real;
  end;

  TPercepciones = record
    PerSustratos: array [1..7] of Boolean;
    PerDinamicos: array [1..5] of Boolean;
    HayDinamicos: array [1..5] of Boolean;
    PerEstadios: array of Boolean;
    HayEstadios: array of Boolean;
    PerMachos: array of Boolean;
    HayMachos: array of Boolean;
    PerHembras: array of Boolean;
    HayHembras: array of Boolean;
    HayPareja,
    HayContrincante: Boolean;
    DinamicosPercibidos: array [1..5] of string;
    AgentesPercibidos: array of string;
                              //Contienen los nombres de los elementos contiguos
                              //percibidos, separados por comas.
  end;

  TPaqEspermatico = record
    Genotipo: TGenotipo;
    Reservas: TReservas;
    Paternidad: Integer;
    Donador: string;
  end;

  {Clases}

  TEspermateca = class
  private
    FLista: array of TPaqEspermatico;
    function GetElemento (Index: Integer): TPaqEspermatico;
    function GetContador: Integer;
  public
    function Agrega (PaqEspermatico: TPaqEspermatico): Integer;
    procedure Retira (Index: Integer);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: TPaqEspermatico
      read GetElemento;
  end;

  TGonada = class
  private
    FLista: array of TReservas;
    function GetElemento (Index: Integer): TReservas;
    function GetContador: Integer;
  public
    function Agrega (Reservas: TReservas): Integer;
    procedure Retira (Index: Integer);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: TReservas
      read GetElemento;
  end;

  THuevo = class(TElemento)
  private
    FPortador: TElemento;
    FEdad: Integer;
    FSexo: TSexo;
    FPadre: string;
    FMadre: string;
    function GetLociContinuos(i: Word): Real;
    function GetLociDiscretos(i: Word): Integer;
  public
    Nombre: string;
    Reservas: TReservas;
    Genotipo: TGenotipo;
    Decision: Word;
    VDecision: array [1..2] of Integer;
    constructor Create{(PPlataforma: TPaintBox)}; override;
    destructor Destroy; override;
    procedure Dibuja(XFisica, YFisica, CuadroFisico: Word); override;
    procedure Inicializa(Padre, Madre: string; Portador: TElemento; Edad: Word;
        Sexo: TSexo); overload;
    procedure Inicializa(Padre, Madre: string; Sexo: TSexo); overload;
    procedure Actualiza; override;
    procedure Decide;
    procedure Huerfano;
    property Portador: TElemento
      read FPortador;
    property Sexo: TSexo
      read FSexo;
    property Edad: Integer
      read FEdad;
    property Padre: string
      read FPAdre;
    property Madre: string
      read FMadre;
    property LociContinuos[i: Word]: Real
      read GetLociContinuos;
    property LociDiscretos[i: Word]: Integer
      read GetLociDiscretos;
  end;

  TListaHuevos = class
  private
    FLista: TObjectList;
    procedure SetElemento (Index: Integer; Obj: THuevo);
    function GetElemento (Index: Integer): THuevo;
    function GetContador: Integer;
    function GetElementoPorNombre(PNombre: string): THuevo;
  public
    procedure HuevosPortador(Portador: TElemento; var Huevos: array of THuevo);
    constructor Create;
    destructor Destroy; override;
    function Agrega (Obj: THuevo): Integer;
    function Retira (Obj: THuevo): Integer;
    function IndiceDe (Obj: THuevo): Integer;
    procedure Inserta(Index: Integer; Obj: THuevo);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: THuevo
      read GetElemento write SetElemento;
    property ElementosPorNombre [PNombre: string]: THuevo
      read GetElementoPorNombre;
  end;

  TAgente = class(TElemento)
  protected
    //Plataforma: TPaintBox;
  private
    FJuego: TJuegoAgentes;
    FAdulto: Boolean;
    FDireccion: TDireccion;
    FSexo: TSexo;
    FPrototipo: Word;
    FEstadio: Word;
    FEdad: Integer;
    FPadre: string;
    FMadre: string;
    FEstado: TEstado;
    FDecision: Word;
    FSituacion: TSituacion;
    FSustrato: TCuadro;
    FContinuosFijados: array [1..15] of Real;
    FDiscretosFijados: array [1..15] of Integer;
    FFijados: Boolean;
    FOnDibuja: TEventoDibuja;
    function GetLociContinuos(i: Word): Real;
    function GetLociDiscretos(i: Word): Integer;
    function GetVirginidad: Boolean;
    procedure SetDireccion(const Value: TDireccion);
    procedure Moverse;
    procedure Morirse;
    procedure Comer;
    procedure Ovipositar;
    procedure Pelear;
    procedure Cortejar;
    procedure Reto(Retador: TAgente);
    procedure Pretencion(Pretendiente: TAgente);
    procedure SetSustrato(const Value: TCuadro);
    procedure DinamicaGametos;
    procedure ConsumoPaquetesEspermaticos;
    function GetDiscretosFijados(i: Integer): Integer;
    function GetContinuosFijados(i: Integer): Real;
  public
    Color: TColor; //Este campo no se guarda
    Genotipo: TGenotipo;
    Reservas: TReservas;
    Memoria: TMemoria;
    Tiempo: TTiempo;
    Referencia: TReferencia;
    Percepciones: TPercepciones;
    Tendencia: array [1..8] of Integer;
    VDecision: array [1..12] of Integer;
    VPeleas: array [1..3] of Integer;
    VCortejos: array [1..4] of Integer;
    Velocidad: Integer;
    Interactuante: TElemento;
    Espermateca: TEspermateca;
    Gonada: TGonada;
    Fertilizados: TListaHuevos;
    Acarreados: Integer;
    function Adulto: Boolean;
    function NivelMinimo: Boolean;
    function NivelOptimo: Boolean;
    function NivelCritico: Boolean;
    constructor Create{(PPlataforma: TPaintBox)}; override;
    destructor Destroy; override;
    procedure Inicializa(PJuego: TJuegoAgentes;Padre, Madre: string; PEstadio,
        PPrototipo, PEdad: Integer; PSexo: TSexo);
    procedure Dibuja(XFisica, YFisica, CuadroFisico: Word); override;
    procedure Actualiza; override;
    procedure Decide;
    procedure Actua;
    procedure IniciarPelea;
    procedure IniciarCortejo;
    procedure Ganador;
    procedure Rechazado;
    procedure Regular;
    procedure ForzarReposo;
    procedure ForzarSituacion(SituacionNueva: TSituacion);
    procedure TerminarCortejoConCopula;
    procedure FertilizaFraccion;
    procedure FertilizaCantidad(n: Integer);
    procedure IncrementaEdad;
    procedure FijaMorfologia(ValoresContinuos: array of Real;
        ValoresDiscretos: array of Integer);
    property Estado: TEstado
      read FEstado;
    property Sustrato: TCuadro
      read FSustrato write SetSustrato;
    property Situacion: TSituacion
      read FSituacion;
    property Decision: Word
      read FDecision;
    property Direccion: TDireccion
      read FDireccion write SetDireccion;
    property Sexo: TSexo
      read FSexo;
    property Estadio: Word
      read FEstadio;
    property Prototipo: Word
      read FPrototipo;
    property Edad: Integer
      read FEdad;
    property LociContinuos[i: Word]: Real
      read GetLociContinuos;
    property LociDiscretos[i: Word]: Integer
      read GetLociDiscretos;
    property ContinuosFijados[i: Integer]: Real
      read GetContinuosFijados;
    property DiscretosFijados[i: Integer]: Integer
      read GetDiscretosFijados;
    property Fijados: Boolean
      read FFijados;
    property Padre: string
      read FPadre;
    property Madre: string
      read FMadre;
    property Virginidad: Boolean
      read GetVirginidad;
    property OnDibuja: TEventoDibuja
      read FOnDibuja write FOndibuja;
  end;

  TListaAgentes = class
  private
    FLista: TObjectList;
    procedure SetElemento (Index: Integer; Obj: TAgente);
    function GetElemento (Index: Integer): TAgente;
    function GetContador: Integer;
    function GetElementoPorNombre(PNombre: string): TAgente;
  public
    constructor Create;
    destructor Destroy; override;
    function Agrega (Obj: TAgente): Integer;
    function Retira (Obj: TAgente): Integer;
    function IndiceDe (Obj: TAgente): Integer;
    procedure Inserta(Index: Integer; Obj: TAgente);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: TAgente
      read GetElemento write SetElemento;
    property ElementosPorNombre [PNombre: string]: TAgente
      read GetElementoPorNombre;
  end;

  {Funciones}

function NumADireccion(Ind: TDirIndice): TDireccion;
function DireccionANum(Dir: TDireccion): TDirIndice;
function DireccionRelativa(Dir1, Dir2: TDireccion): TDireccion;
function DireccionAbsoluta(Dir1, Dir2: TDireccion): TDireccion;
function DireccionRelativaA(DirRef: TDireccion;
    X1, Y1, X2, Y2: Word): TDireccion;
//function Distancia(X1, Y1, X2, Y2: Integer): Integer;

implementation

uses
  Mediadores, SysUtils, Cruzadores;

function NumADireccion(Ind: TDirIndice): TDireccion;
begin
  case Ind of
    0: Result := drT;
    1: Result := drNO;
    2: Result := drN;
    3: Result := drNE;
    4: Result := drO;
    5: Result := drE;
    6: Result := drSO;
    7: Result := drS;
    8: Result := drSE;
  else
    Result := drN;
  end
end;

function DireccionANum(Dir: TDireccion): TDirIndice;
begin
  case Dir of
    drT   : Result := 0;
    drNO  : Result := 1;
    drN   : Result := 2;
    drNE  : Result := 3;
    drO   : Result := 4;
    drE   : Result := 5;
    drSO  : Result := 6;
    drS   : Result := 7;
    drSE  : Result := 8;
  else
    Result := 1;
  end;
end;

function DireccionRelativa(Dir1, Dir2: TDireccion): TDireccion;
{Dada la direcciones absolutas Dir1 y Dir2, regresa la dirección relativa
de la ubicación de
un punto en Dir2 con respecto a Dir1.
Por ejemplo: si Dir1 = drS y Dir2 = drS, el resultado será = drN, ya que un
punto que se encuentre al sur de un agente que "mira" hacia el sur, estará
ubicado en la dirección relativa norte del agente.}
begin
  Result := drN;
  case Dir1 of
    drNO:
      case Dir2 of
        drNO: Result := drN;
        drN: Result := drNE;
        drNE: Result := drE;
        drO: Result := drNO;
        drE: Result := drSE;
        drSO: Result := drO;
        drS: Result := drSO;
        drSE: Result := drS;
      end;
    drN:
      case Dir2 of
        drNO: Result := drNO;
        drN: Result := drN;
        drNE: Result := drNE;
        drO: Result := drO;
        drE: Result := drE;
        drSO: Result := drSO;
        drS: Result := drS;
        drSE: Result := drSE;
      end;
    drNE:
      case Dir2 of
        drNO: Result := drO;
        drN: Result := drNO;
        drNE: Result := drN;
        drO: Result := drSO;
        drE: Result := drNE;
        drSO: Result := drS;
        drS: Result := drSE;
        drSE: Result := drE;
      end;
    drO:
      case Dir2 of
        drNO: Result := drNE;
        drN: Result := drE;
        drNE: Result := drSE;
        drO: Result := drN;
        drE: Result := drS;
        drSO: Result := drNO;
        drS: Result := drO;
        drSE: Result := drSO;
      end;
    drE:
      case Dir2 of
        drNO: Result := drSO;
        drN: Result := drO;
        drNE: Result := drNO;
        drO: Result := drS;
        drE: Result := drN;
        drSO: Result := drSE;
        drS: Result := drE;
        drSE: Result := drNE;
      end;
    drSO:
      case Dir2 of
        drNO: Result := drE;
        drN: Result := drSE;
        drNE: Result := drS;
        drO: Result := drNE;
        drE: Result := drSO;
        drSO: Result := drN;
        drS: Result := drNO;
        drSE: Result := drO;
      end;
    drS:
      case Dir2 of
        drNO: Result := drSE;
        drN: Result := drS;
        drNE: Result := drSO;
        drO: Result := drE;
        drE: Result := drO;
        drSO: Result := drNE;
        drS: Result := drN;
        drSE: Result := drNO;
      end;
    drSE:
      case Dir2 of
        drNO: Result := drS;
        drN: Result := drSO;
        drNE: Result := drO;
        drO: Result := drSE;
        drE: Result := drNO;
        drSO: Result := drE;
        drS: Result := drNE;
        drSE: Result := drN;
      end;
  end; //case
end; //RelativaDireccion

function DireccionAbsoluta(Dir1, Dir2: TDireccion): TDireccion;
{Dada la dirección absoluta Dir1, regresa la dirección absoluta corres-
pondiente a la dirección relativa Dir2.
Ejemplo: Si Dir1 = drE, y Dir2 = S, regresa drO}
begin
  Result := drN;
  case Dir1 of
    drN:
      case Dir2 of
        drN: Result := drN;
        drNE: Result := drNE;
        drE: Result := drE;
        drSE: Result := drSE;
        drS: Result := drS;
        drSO: Result := drSO;
        drO: Result := drO;
        drNO: Result := drNO;
      end;
    drNE:
      case Dir2 of
        drN: Result := drNE;
        drNE: Result := drE;
        drE: Result := drSE;
        drSE: Result := drS;
        drS: Result := drSO;
        drSO: Result := drO;
        drO: Result := drNO;
        drNO: Result := drN;
      end;
    drE:
      case Dir2 of
        drN: Result := drE;
        drNE: Result := drSE;
        drE: Result := drS;
        drSE: Result := drSO;
        drS: Result := drO;
        drSO: Result := drNO;
        drO: Result := drN;
        drNO: Result := drNE;
      end;
    drSE:
      case Dir2 of
        drN: Result := drSE;
        drNE: Result := drS;
        drE: Result := drSO;
        drSE: Result := drO;
        drS: Result := drNO;
        drSO: Result := drN;
        drO: Result := drNE;
        drNO: Result := drE;
      end;
    drS:
      case Dir2 of
        drN: Result := drS;
        drNE: Result := drSO;
        drE: Result := drO;
        drSE: Result := drNO;
        drS: Result := drN;
        drSO: Result := drNE;
        drO: Result := drE;
        drNO: Result := drSE;
      end;
    drSO:
      case Dir2 of
        drN: Result := drSO;
        drNE: Result := drO;
        drE: Result := drNO;
        drSE: Result := drN;
        drS: Result := drNE;
        drSO: Result := drE;
        drO: Result := drSE;
        drNO: Result := drS;
      end;
    drO:
      case Dir2 of
        drN: Result := drO;
        drNE: Result := drNO;
        drE: Result := drN;
        drSE: Result := drNE;
        drS: Result := drE;
        drSO: Result := drE;
        drO: Result := drSE;
        drNO: Result := drS;
      end;
    drNO:
      case Dir2 of
        drN: Result := drNO;
        drNE: Result := drN;
        drE: Result := drNE;
        drSE: Result := drE;
        drS: Result := drSE;
        drSO: Result := drS;
        drO: Result := drSO;
        drNO: Result := drO;
      end;
  end; //case
end; //DireccionAbsoluta

function DireccionRelativaA(DirRef: TDireccion;
    X1, Y1, X2, Y2: Word): TDireccion;
{Regresa la ubicación relativa del punto X2, Y2 con respecto a un agente que
esté ubicado en el punto X1, Y1 con la dirección absoluta DirRef.
Por ejemplo: si DirRef = drS, X1 = 1, Y1 = 1, X2 = 1 y Y2 = 20, entonces el
resultado será drN, ya que el punto 1,20 se ubica al frente de un agente que
estando en 1,1 "mira" hacia el sur}
var
  Cuadrante: Byte; //I al IV, siendo NO = I y SO = IV
  Absoluta: TDireccion;
  DX, DY : Integer;
begin
  Result := drT;
  Cuadrante := 1;
  Absoluta := drN;
  DX := Abs(X2 - X1);
  DY := Abs(Y2 - Y1);
  if (X1 = X2) and (Y1 = Y2) then //Traslape
    Exit;   //-->
  if (X1 < X2) and (Y1 < Y2) then //Determinación del cuadrante
    Cuadrante := 3
  else if (X1 < X2) and (Y1 > Y2) then
    Cuadrante := 2
  else if (X1 > X2) and (Y1 > Y2) then
    Cuadrante := 1
  else if (X1 > X2) and (Y1 < Y2) then
    Cuadrante := 4;
  if DY >= (2 * DX) + 1 then
  begin
    case Cuadrante of
      1, 2: Absoluta := drN;
      3, 4: Absoluta := drS;
    end;
  end
  else if (DY >= (DX div 2) + (DX mod 2)) and (DY <= 2 * DX) then
  begin
    case Cuadrante of
      1: Absoluta := drNO;
      2: Absoluta := drNE;
      3: Absoluta := drSE;
      4: Absoluta := drSO;
    end;
  end
  else if DY <= (DX div 2) + (DX mod 2) then
  begin
    case Cuadrante of
      1, 4: Absoluta := drO;
      2, 3: Absoluta := drE;
    end;
  end;
  if DY = 0 then
  begin
    if X1 < X2 then
      Absoluta := drE
    else
      Absoluta := drO;
  end;
  if DX = 0 then
  begin
    if Y1 < Y2 then
      Absoluta := drS
    else
      Absoluta := drN;
  end;
  Result := DireccionRelativa(DirRef, Absoluta);
end;

{function Distancia(X1, Y1, X2, Y2: Integer): Integer;
{Regresa la distancia entre los puntos X1,Y1 y X2,Y2 aplicando el teorema de
Pitágoras
begin
  Result := Round(Sqrt((Sqr(X1 - X2)) + (Sqr(Y1 - Y2))))
end;}

{ TAgente }

procedure TAgente.Actua;
var
  i: Integer;
begin
  FEstado := esActuando;
  case Decision of
    1     : Moverse;
    3..6  : Comer;
    11    : Ovipositar;
    7,8,13: Pelear;
    9,10,
    14,15 : Cortejar;
    12    : Morirse;
  end;
  for i := 1 to 15 do
    if Memoria.UltConductas[i] <> - 1 then
      Inc(Memoria.UltConductas[i]);
  i := 0;
  case Decision of      //Ajuste de índices de conductas decisión/memoria
    1..8: i := Decision;  //Movimiento, alimentación y combate
    9 : i := 10;          //Intento desplegado
    10: i := 11;          //Intento escalado
    11: i := 14;          //Ovipositar
    12: i := 2;           //Morir
    13: i := 9;           //Retirarse
    14: i := 12;          //Aceptar
    15: i := 13;          //Rechazar
    16: i := 15;          //Ganar Pelea
    17: i := 16;          //Copular
  end;
  Inc(Memoria.NumConductas[i]);
  Memoria.UltConductas[i] := 0;
end;

procedure TAgente.Actualiza;
begin
  FEstado := esIndeciso;
  if Adulto and NivelOptimo then
    DinamicaGametos
  else if NivelMinimo then
    Morirse;
  if (Sexo = sxHembra) and Adulto then
    ConsumoPaquetesEspermaticos;
  //Inc(FEdad); Accion delegada a otro metodo
  Inc(Tiempo.EstadioActual);
  if FAdulto and (FEdad > Referencia.Longevidad) then
    Morirse;
end;

function TAgente.Adulto: Boolean;
begin
  Result := FAdulto;
end;

procedure TAgente.Comer;
var
  Fuente: TDinamico;
  CantTomada: Integer;
begin
  if not Assigned(Interactuante) then
    Exit; //-->
  if not (Interactuante is TDinamico) then
    Exit; //-->
  Fuente := Interactuante as TDinamico;
  with Referencia do
  begin
    CantTomada := UnidadesTomadas;
    case Fuente.ElementoListado of
      1: if Reservas.Agua + CantTomada > Maximos[1] then
        CantTomada := Maximos[1] - Reservas.Agua;
      2: if Reservas.Azucar + CantTomada > Maximos[2] then
        CantTomada := Maximos[2] - Reservas.Azucar;
      3: if Reservas.Grasa + CantTomada > Maximos[3] then
        CantTomada := Maximos[3] - Reservas.Grasa;
      4: if Reservas.Proteina + CantTomada > Maximos[4] then
        CantTomada := Maximos[4] - Reservas.Proteina;
    end;
  end;
  if CantTomada > Fuente.Nivel then
    CantTomada := Fuente.Nivel;
  with Reservas do
  begin
    case Fuente.ElementoListado of
      1: Agua     := Agua + CantTomada;
      2: Azucar   := Azucar + CantTomada;
      3: Grasa    := Grasa + CantTomada;
      4: Proteina := Proteina + CantTomada;
    end;
  end;
  Fuente.Nivel := Fuente.Nivel - CantTomada;
end;

procedure TAgente.ConsumoPaquetesEspermaticos;
var
  i: Integer;
  Ganancias: TReservas;
begin
  for i := 1 to Espermateca.Contador do
  begin
    with Espermateca.Elementos[i] do
    begin
      Ganancias.Agua :=  Round(Reservas.Agua * Referencia.TasaConsumoPaq);
      Ganancias.Azucar :=  Round(Reservas.Azucar * Referencia.TasaConsumoPaq);
      Ganancias.Grasa :=  Round(Reservas.Grasa * Referencia.TasaConsumoPaq);
      Ganancias.Proteina:=Round(Reservas.Proteina * Referencia.TasaConsumoPaq);
      Reservas.Agua := RestaMin(Reservas.Agua, Ganancias.Agua, 0);
      Reservas.Azucar := RestaMin(Reservas.Azucar, Ganancias.Azucar, 0);
      Reservas.Grasa := RestaMin(Reservas.Grasa, Ganancias.Grasa, 0);
      Reservas.Proteina := RestaMin(Reservas.Proteina, Ganancias.Proteina, 0);
      Paternidad :=
        RestaMin(Paternidad, Round(Paternidad * Referencia.TasaDegradacion), 0);
    end;
    Reservas.Agua :=
        SumaMax(Reservas.Agua, Ganancias.Agua, Referencia.Maximos[1]);
    Reservas.Azucar :=
        SumaMax(Reservas.Azucar, Ganancias.Azucar, Referencia.Maximos[2]);
    Reservas.Grasa :=
        SumaMax(Reservas.Grasa, Ganancias.Grasa, Referencia.Maximos[3]);
    Reservas.Proteina :=
        SumaMax(Reservas.Proteina, Ganancias.Proteina, Referencia.Maximos[4]);
    if (Espermateca.Elementos[i].Reservas.Agua = 0)
      and (Espermateca.Elementos[i].Reservas.Azucar = 0)  //Consumo y
      and (Espermateca.Elementos[i].Reservas.Grasa = 0)   //degradación totales
      and (Espermateca.Elementos[i].Reservas.Proteina = 0)
      and (Espermateca.Elementos[i].Paternidad = 0) then
      Espermateca.Retira(i);                              //Eliminar paquete
  end;
end;

procedure TAgente.Cortejar;
begin
  case FDecision of
    9 : (Interactuante as TAgente).Memoria.UltAccionContendiente := 1;//Despl
    10: (Interactuante as TAgente).Memoria.UltAccionContendiente := 2;//Esc
    14:                                                               //Aceptar
    //begin
      (Interactuante as TAgente).Memoria.UltAccionContendiente := 3;
     // if Memoria.UltAccionContendiente = 3 then
      //  Copular;
    //end;
    15:                                                               //Rechazar
    begin
      (Interactuante as TAgente).Rechazado;
      FSituacion := stRegular;
      Interactuante := nil;
    end;
  end;
end;

constructor TAgente.Create;//(PPlataforma: TPaintBox);
var
  w: Word;
begin
  inherited Create;//(PPlataforma);
  Nombre := NombreAzarozo;
  //Plataforma := PPlataforma;
  FPadre := 'Pigmalión';
  FMadre := 'Galatea';
  FAdulto := False;
  w := Dado(8);
  FDireccion := NumADireccion(w);
  FSexo := sxIndefinido;
  FEstadio := 1;
  FPrototipo := 0;
  FEstado := esIndeciso;
  FSituacion := stRegular;
  FDecision := 0;
  Sustrato := '1';
  Velocidad := 1;
  Espermateca := TEspermateca.Create;
  Gonada := TGonada.Create;
  Fertilizados := TListaHuevos.Create;
  with Memoria do
  begin
    SetLength(UltIntEstadios, 2);
    SetLength(NumIntEstadios, 2);
    SetLength(UltIntMachos, 2);
    SetLength(NumIntMachos, 2);
    SetLength(UltIntHembras, 2);
    SetLength(NumIntHembras, 2);
    SetLength(UltPerEstadios, 2);
    SetLength(NumPerEstadios, 2);
    SetLength(UltPerMachos, 2);
    SetLength(NumPerMachos, 2);
    SetLength(UltPerHembras, 2);
    SetLength(NumPerHembras, 2);
    UltAccionContendiente := 0;
  end;
  with Percepciones do
  begin
    SetLength(PerEstadios, 2);
    SetLength(HayEstadios, 2);
    SetLength(PerMachos, 2);
    SetLength(HayMachos, 2);
    SetLength(PerHembras, 2);
    SetLength(HayHembras, 2);
    SetLength(AgentesPercibidos, 2);
  end;
end;

procedure TAgente.Decide;
var
  V: TListaV;
  i: Integer;
begin
  if FEstado = esDecidido then
    Exit; //-->
  case FSituacion of
    stInmaduro, stRegular:
    begin
      SetLength(V, 12);
      for i := 1 to 12 do
        V[i-1] := VDecision[i];
      FDecision := Ruleta(V);
    end;
    stCombate:
    begin
      SetLength(V, 3);
      for i := 1 to 3 do
        V[i-1] := VPeleas[i];
      i := Ruleta(V);
      case i of
        1: FDecision := 7;  //Desplegar
        2: FDecision := 8;  //Escalar
        3: FDecision := 13; //Retirarse
      end;
    end;
    stCortejo:
    begin
      SetLength(V, 4);
      for i := 1 to 4 do
        V[i-1] := VCortejos[i];
      i := Ruleta(V);
      case i of
        1: FDecision := 9;  //Desplegar
        2: FDecision := 10; //Escalar
        3: FDecision := 14; //Aceptar
        4: FDecision := 15; //Rechazar
      end;
    end;
  end; //case FSituacion
  FEstado := esDecidido;
end;

destructor TAgente.Destroy;
begin
  Espermateca.Free;
  Gonada.Free;
  Fertilizados.Free;
  inherited Destroy;
end;

procedure TAgente.Dibuja(XFisica, YFisica, CuadroFisico: Word);
{var
  CabezaX, CabezaY,
  AbdomenX, AbdomenY,
  ColaX, ColaY        : Word;}
begin
  if Assigned(FOnDibuja) then
    TEventoDibuja(FOnDibuja)(Self, XFisica, YFisica, CuadroFisico);
  {if not Adulto then  //¿Es inmaduro?
  begin
    with Plataforma.Canvas do
    begin
      Brush.Style := bsSolid;
      Pen.Color := clBlack;
      Pen.Style := psDot;
      Brush.Color := Color;
      Ellipse(XFisica, YFisica, XFisica + CuadroFisico, YFisica + CuadroFisico);
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      case Sexo of
        sxMacho : Brush.Color := clBlue;
        sxHembra: Brush.Color := clFuchsia;
      end;
      Ellipse((XFisica + (CuadroFisico div 2)) - 2,
              (YFisica + (CuadroFisico div 2)) - 2,
              (XFisica + (CuadroFisico div 2)) + 2,
              (YFisica + (CuadroFisico div 2)) + 2);
    end;
    Exit; //-->
  end;
  AbdomenX := XFisica + Round(CuadroFisico / 2);
  AbdomenY := YFisica + Round(CuadroFisico / 2);
  CabezaX := XFisica + Round(CuadroFisico / 5);
  CabezaY := YFisica + Round(CuadroFisico / 5);
  ColaX := XFisica + Round(CuadroFisico * 0.8);
  ColaY := YFisica + Round(CuadroFisico * 0.8);
  case FDireccion of
    drNO:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 5);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico * 0.8);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drN:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 2);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 2);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drNE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drO:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 5);
      CabezaY := YFisica + Round(CuadroFisico / 2);
      ColaX := XFisica + Round(CuadroFisico * 0.8);
      ColaY := YFisica + Round(CuadroFisico / 2);
    end;
    drE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 2);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico / 2);
    end;
    drSO:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drS:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 2);
      CabezaY := YFisica + Round(CuadroFisico * 0.8);
      ColaX := XFisica + Round(CuadroFisico / 2);
      ColaY := YFisica + Round(CuadroFisico / 5);
    end;
    drSE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico * 0.8);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico / 5);
    end;
  end; //case
  with Plataforma.Canvas do
  begin
    Brush.Style := bsSolid;
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    if Sexo = sxMacho then
      Brush.Color := clBlue
    else
      Brush.Color := clFuchsia;
    Ellipse(CabezaX - Round(CuadroFisico / 5),
            CabezaY - Round(CuadroFisico / 5),
            CabezaX + Round(CuadroFisico / 5),
            CabezaY + Round(CuadroFisico / 5));
    Ellipse(AbdomenX - Round(CuadroFisico / 3),
            AbdomenY - Round(CuadroFisico / 3),
            AbdomenX + Round(CuadroFisico / 3),
            AbdomenY + Round(CuadroFisico / 3));
    Brush.Color := Color;
    Ellipse(ColaX - Round(CuadroFisico / 3),
            ColaY - Round(CuadroFisico / 3),
            ColaX + Round(CuadroFisico / 3),
            ColaY + Round(CuadroFisico / 3));
    if Acarreados > 0 then //Marcar agente como portador de huevos
    begin
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      Brush.Color := clYellow;
      Ellipse((XFisica + (CuadroFisico div 2)) - 1,
              (YFisica + (CuadroFisico div 2)) - 1,
              (XFisica + (CuadroFisico div 2)) + 1,
              (YFisica + (CuadroFisico div 2)) + 1);
    end;
  end; }
end;

procedure TAgente.DinamicaGametos;
var
  i,
  CanHuevos,
  CanPosible: Integer;
  NutDisponibles: array [1..4] of Integer;
  CostosGameto: TReservas;
begin
  NutDisponibles[1] := Reservas.Agua;
  NutDisponibles[2] := Reservas.Azucar;
  NutDisponibles[3] := Reservas.Grasa;
  NutDisponibles[4] := Reservas.Proteina;
  with Referencia do
  begin
    CostosGameto.Agua := CostosGametos[1];
    CostosGameto.Azucar := CostosGametos[2];
    CostosGameto.Grasa := CostosGametos[3];
    CostosGameto.Proteina := CostosGametos[4];
  end;
  i := 1;
  with Referencia do
    while (CostosGameto.Agua * i <= NutDisponibles[1])
        and (CostosGameto.Azucar * i <= NutDisponibles[2])
            and (CostosGameto.Grasa * i <= NutDisponibles[3])
                and (CostosGameto.Proteina * i <= NutDisponibles[4])
                  and (i <= MaxGametos) do
      Inc(i);
  CanPosible := i;
  CanHuevos := Gonada.Contador + Fertilizados.Contador;
  if Gonada.Contador + Fertilizados.Contador + CanPosible
      > Referencia.MaxGametos then
    CanPosible := Referencia.MaxGametos - CanHuevos;
  for i := 1 to CanPosible do
    Gonada.Agrega(CostosGameto);
  with Reservas do
  begin
    Agua := Agua - (CanPosible * CostosGameto.Agua);
    Azucar := Azucar - (CanPosible * CostosGameto.Azucar);
    Grasa := Grasa - (CanPosible * CostosGameto.Grasa);
    Proteina := Proteina - (CanPosible * CostosGameto.Proteina);
  end;
end;

procedure TAgente.FertilizaCantidad(n: Integer);
var
  i, j, k: Integer;
  Proporciones,
  VPaternidad: TListaV;
  Cruzador: TCruzador;
begin
  if Espermateca.Contador = 0 then
    Exit; //-->
  if n > Gonada.Contador then
    n := Gonada.Contador;
  SetLength(VPaternidad, Espermateca.Contador);
  SetLength(Proporciones, 2);
  Proporciones[0] := Referencia.PropMachos;
  Proporciones[1] := Referencia.PropHembras;
  for i := 1 to Espermateca.Contador do
    VPaternidad[i-1] := Espermateca.Elementos[i].Paternidad;
  for i := 1 to n do
  begin
    j := Ruleta(VPaternidad);
    Cruzador :=
        TCruzador.Create(FJuego, Espermateca.Elementos[j].Genotipo, Genotipo);
    k := Fertilizados.Agrega(THuevo.Create{(Plataforma)});
    with Fertilizados.Elementos[k] do
    begin
      FPadre := Espermateca.Elementos[j].Donador;
      FMadre := Self.Nombre;
      if Ruleta(Proporciones) = 1 then
        FSexo := sxMacho
      else
        FSexo := sxHembra;
      Reservas.Agua :=
          Round(Gonada.Elementos[1].Agua * (1 - Referencia.FraccHuevo));
      Reservas.Azucar :=
          Round(Gonada.Elementos[1].Azucar * (1 -Referencia.FraccHuevo));
      Reservas.Grasa :=
          Round(Gonada.Elementos[1].Grasa * (1 - Referencia.FraccHuevo));
      Reservas.Proteina :=
          Round(Gonada.Elementos[1].Proteina *(1-Referencia.FraccHuevo));
      Genotipo := Cruzador.Genotipo;

    end;
    Gonada.Retira(1);
    Cruzador.Free;
  end;
end;

procedure TAgente.FertilizaFraccion;
var
  i, j, k,
  Cantidad: Integer;
  Proporciones,
  VPaternidad: TListaV;
  Cruzador: TCruzador;
begin
  if not ((Referencia.FraccFertilizados >= 0)
          and (Referencia.FraccFertilizados <= 1)) then
    Exit; //-->
  if Espermateca.Contador = 0 then
    Exit; //-->
  Cantidad := Round(Referencia.FraccFertilizados * Gonada.Contador);
  SetLength(VPaternidad, Espermateca.Contador);
  SetLength(Proporciones, 2);
  Proporciones[0] := Referencia.PropMachos;
  Proporciones[1] := Referencia.PropHembras;
  for i := 1 to Espermateca.Contador do
    VPaternidad[i-1] := Espermateca.Elementos[i].Paternidad;
  for i := 1 to Cantidad do
  begin
    j := Ruleta(VPaternidad);
    Cruzador :=
        TCruzador.Create(FJuego, Espermateca.Elementos[j].Genotipo, Genotipo);
    k := Fertilizados.Agrega(THuevo.Create{(Plataforma)});
    with Fertilizados.Elementos[k] do
    begin
      FPadre := Espermateca.Elementos[j].Donador;
      FMadre := Self.Nombre;
      if Ruleta(Proporciones) = 1 then
        FSexo := sxMacho
      else
        FSexo := sxHembra;
      Reservas.Agua :=
          Round(Gonada.Elementos[1].Agua * (1 - Referencia.FraccHuevo));
      Reservas.Azucar :=
          Round(Gonada.Elementos[1].Azucar * (1 -Referencia.FraccHuevo));
      Reservas.Grasa :=
          Round(Gonada.Elementos[1].Grasa * (1 - Referencia.FraccHuevo));
      Reservas.Proteina :=
          Round(Gonada.Elementos[1].Proteina *(1-Referencia.FraccHuevo));
      Genotipo := Cruzador.Genotipo;
    end;
    Gonada.Retira(1);
    Cruzador.Free;
  end;
end;

procedure TAgente.FijaMorfologia(ValoresContinuos: array of Real;
  ValoresDiscretos: array of Integer);
var
  i: Integer;
begin
  for i := 1 to 15 do
  begin
    FContinuosFijados[i] := ValoresContinuos[i-1];
    FDiscretosFijados[i] := ValoresDiscretos[i-1];
  end;
  FFijados := True;
end;

procedure TAgente.ForzarReposo;
begin
  FDecision := 2;
  FEstado := esDecidido;
  if FAdulto then
    FSituacion := stRegular
end;

procedure TAgente.ForzarSituacion(SituacionNueva: TSituacion);
{Solo se permite forzar las situaciones, Regular, Combate y Cortejo}
begin
  if SituacionNueva in [stRegular, stCombate, stCortejo] then
    FSituacion := SituacionNueva
  else
    raise EValorInvalido.Create('Sólo se permite forzar las situaciones, '
        +'Regular, Combate y Cortejo');
end;

procedure TAgente.Ganador;
begin
  FEstado := esDecidido;
  FSituacion := stRegular;
  Interactuante := nil;
  FDecision := 16;
  Tiempo.InteraccionActual := 0;
end;

function TAgente.GetContinuosFijados(i: Integer): Real;
begin
  Result := FContinuosFijados[i];
end;

function TAgente.GetDiscretosFijados(i: Integer): Integer;
begin
  Result := FDiscretosFijados[i];
end;

function TAgente.GetLociContinuos(i: Word): Real;
{Regresa los loci expresados según el genotipo}
begin
  Result := 0;
  if i > 15 then
  begin
    raise EFueraDeRango.Create('El índice solicitado está fuera de los límites'
                                + ' del arreglo [GetLociContinuo]');
    Exit; //-->
  end;
  with Genotipo do
  begin
    if (PatContinuos[i].Cualidad = cdDominante) and  //Homocigo dominate
        (MatContinuos[i].Cualidad = cdDominante) then //Codominancia
    begin
      Result := (PatContinuos[i].Valor + MatContinuos[i].Valor) / 2
    end
    else  if (PatContinuos[i].Cualidad = cdDominante) and  //Heterocigo
        (MatContinuos[i].Cualidad = cdRecesivo) then
      Result := PatContinuos[i].Valor //Dominancia paterna
    else  if (PatContinuos[i].Cualidad = cdRecesivo) and  //Heterocigo
        (MatContinuos[i].Cualidad = cdDominante) then
      Result := MatContinuos[i].Valor //Dominancia materna
    else  if (PatContinuos[i].Cualidad = cdRecesivo) and  //Homocigo recesivo
        (MatContinuos[i].Cualidad = cdRecesivo) then  //Codominancia
      Result := (PatContinuos[i].Valor + MatContinuos[i].Valor) / 2;
  end;  //with
end;

function TAgente.GetLociDiscretos(i: Word): Integer;
{Regresa los loci expresados según el genotipo}
begin
  Result := 0;
  if i > 15 then
  begin
    raise EFueraDeRango.Create('El índice solicitado está fuera de los límites'
                                + ' del arreglo [GetLociContinuo]');
    Exit; //-->
  end;
  with Genotipo do
  begin
    if (PatDiscretos[i].Cualidad = cdDominante) and  //Homocigo dominate
        (MatDiscretos[i].Cualidad = cdDominante) then //Codominancia
      Result := Round((PatDiscretos[i].Valor+MatDiscretos[i].Valor) / 2)
    else  if (PatDiscretos[i].Cualidad = cdDominante) and  //Heterocigo
        (MatDiscretos[i].Cualidad = cdRecesivo) then
      Result := PatDiscretos[i].Valor //Dominancia paterna
    else  if (PatDiscretos[i].Cualidad = cdRecesivo) and  //Heterocigo
        (MatDiscretos[i].Cualidad = cdDominante) then
      Result := MatDiscretos[i].Valor //Dominancia materna
    else  if (PatDiscretos[i].Cualidad = cdRecesivo) and  //Homocigo recesivo
        (MatDiscretos[i].Cualidad = cdRecesivo) then  //Codominancia
      Result := Round((PatDiscretos[i].Valor+MatDiscretos[i].Valor) / 2);
  end;  //with
end;

function TAgente.GetVirginidad: Boolean;
begin
  //Result := Memoria.NumConductas[13] < 1;
  Result := Memoria.NumConductas[16] < 1;
end;

procedure TAgente.IncrementaEdad;
begin
  Inc(FEdad);
end;

procedure TAgente.Inicializa(PJuego: TJuegoAgentes;Padre, Madre: string;
    PEstadio, PPrototipo, PEdad: Integer; PSexo: TSexo);
var
  i: Integer;
begin
  FJuego := PJuego;
  FSexo := PSexo;
  FEstadio := PEstadio;
  FPrototipo := PPrototipo;
  FEdad := PEdad;
  FSituacion := stInmaduro;
  FFijados := False;
  FPadre := Padre;
  FMadre := Madre;
  if PEstadio > FJuego.NumEstadios then  //¿Es adulto?
  begin
    FAdulto := True;
    FSituacion := stRegular;
    if Sexo = sxIndefinido then
      raise EValorInvalido.Create('No se puede asignar sexo indefinido a '
                                    + 'agente adulto.');
    if (Sexo = sxMacho) and (PPrototipo > PJuego.NumPrototiposM) then
        raise EValorInvalido.Create('Número de prototipo asignado a agente '
                          + 'supera número de prototipos machos disponibles');
    if (Sexo = sxHembra) and (PPrototipo > PJuego.NumPrototiposH) then
        raise EValorInvalido.Create('Número de prototipo asignado a agente '
                          + 'supera número de prototipos hembras disponibles');
  end;
  with Memoria do
  begin
    SetLength(UltIntEstadios, PJuego.NumEstadios);
    SetLength(NumIntEstadios, PJuego.NumEstadios);
    SetLength(UltIntMachos, PJuego.NumPrototiposM);
    SetLength(NumIntMachos, PJuego.NumPrototiposM);
    SetLength(UltIntHembras, PJuego.NumPrototiposH);
    SetLength(NumIntHembras, PJuego.NumPrototiposH);
    SetLength(UltPerEstadios, PJuego.NumEstadios);
    SetLength(NumPerEstadios, PJuego.NumEstadios);
    SetLength(UltPerMachos, PJuego.NumPrototiposM);
    SetLength(NumPerMachos, PJuego.NumPrototiposM);
    SetLength(UltPerHembras, PJuego.NumPrototiposH);
    SetLength(NumPerHembras, PJuego.NumPrototiposH);
    UltAccionContendiente := 0;
    for i := 1 to 7 do
      UltPerSust[i] := - 1;
    for i := 1 to 5 do
    begin
      UltIntDin[i] := - 1;
      UltPerDin[i] := - 1;
    end;
    for i := 0 to PJuego.NumEstadios - 1 do
    begin
      UltIntEstadios[i] := - 1;
      UltPerEstadios[i] := - 1;
    end;
    for i := 0 to PJuego.NumPrototiposM - 1 do
    begin
      UltIntMachos[i] := - 1;
      UltPerMachos[i] := - 1;
    end;
    for i := 0 to PJuego.NumPrototiposH - 1 do
    begin
      UltIntHembras[i] := - 1;
      UltPerHembras[i] := - 1;
    end;
    for i := 1 to 16 do
      UltConductas[i] := - 1;
  end;
  with Percepciones do
  begin
    SetLength(PerEstadios, PJuego.NumEstadios);
    SetLength(HayEstadios, PJuego.NumEstadios);
    SetLength(PerMachos, PJuego.NumPrototiposM);
    SetLength(HayMachos, PJuego.NumPrototiposM);
    SetLength(PerHembras, PJuego.NumPrototiposH);
    SetLength(HayHembras, PJuego.NumPrototiposH);
    SetLength(AgentesPercibidos, PJuego.NumEstadios + PJuego.NumPrototiposM +
        PJuego.NumPrototiposH);
  end;
end;

procedure TAgente.IniciarCortejo;
begin
  FSituacion := stCortejo;
  (Interactuante as TAgente).Pretencion(Self); //Enviar aviso a interactuante
end;

procedure TAgente.IniciarPelea;
begin
  FSituacion := stCombate;
  (Interactuante as TAgente).Reto(Self);        //Enviar reto a interactuante
end;

procedure TAgente.Morirse;
begin
  if FSituacion = stCombate then
    (Interactuante as TAgente).Ganador
  else if FSituacion = stCortejo then
    (Interactuante as TAgente).Rechazado;
  FSituacion := stMuerto;
end;

procedure TAgente.Moverse;
var
  i: Integer;
  NDir: Word;
  V: TListaV;
  NuevaDir: TDireccion;
begin
  SetLength(V, 8);
  for i := 1 to 8 do
    V[i-1] := Tendencia[i];
  NDir := Ruleta(V);
  NuevaDir := NumADireccion(NDir);
  Direccion := DireccionAbsoluta(Direccion, NuevaDir);
  case Direccion of
    drNO:
    begin
      X := X - Velocidad;
      Y := Y - Velocidad;
    end;
    drN:  Y := Y - Velocidad;
    drNE:
    begin
      X := X + Velocidad;
      Y := Y - Velocidad;
    end;
    drO: X := X - Velocidad;
    drE: X := X + Velocidad;
    drSO:
    begin
      X := X - Velocidad;
      Y := Y + Velocidad;
    end;
    drS: Y := Y + Velocidad;
    drSE:
    begin
      X := X + Velocidad;
      Y := Y + Velocidad;
    end;
  end;
end;

function TAgente.NivelCritico: Boolean;
begin
  with Reservas do
  begin
    Result := (Agua < Referencia.Criticos[1]) or
                (Azucar < Referencia.Criticos[2]) or
                  (Grasa < Referencia.Criticos[3]) or
                    (Proteina < Referencia.Criticos[4]);
  end;
end;

function TAgente.NivelMinimo: Boolean;
begin
  with Reservas do
  begin
    Result := (Agua < Referencia.Minimos[1]) or
                (Azucar < Referencia.Minimos[2]) or
                  (Grasa < Referencia.Minimos[3]) or
                    (Proteina < Referencia.Minimos[4]);
  end;
end;

function TAgente.NivelOptimo: Boolean;
begin
  with Reservas do
  begin
    Result := (Agua >= Referencia.Optimos[1]) and
                (Azucar >= Referencia.Optimos[2]) and
                  (Grasa >= Referencia.Optimos[3]) and
                    (Proteina >= Referencia.Optimos[4]);
  end;
end;

procedure TAgente.Ovipositar;
var
  Maximo,
  Nivel,
  Faltantes,
  CantOvipositada: Integer;
begin
  if not Assigned(Interactuante) then
  begin
    Referencia.OvipositadosCiclo := 0;
    Exit; //-->
  end;
 // if not ((Interactuante is TAgente) or (Interactuante is TSitioOviposicion))
 if not (Interactuante is TSitioOviposicion) then
  begin
    Referencia.OvipositadosCiclo := 0;
    Exit; //-->
  end;
  CantOvipositada := Referencia.OvipositadosCiclo;
  if Interactuante is TSitioOviposicion then
  begin
    Maximo := (Interactuante as TSitioOviposicion).Maximo;
    Nivel := (Interactuante as TSitioOviposicion).Nivel;
    if Maximo < Nivel + CantOvipositada then
      CantOvipositada := Maximo - Nivel;
  end;
  if Fertilizados.Contador < CantOvipositada then
  begin
    Faltantes := CantOvipositada - Fertilizados.Contador;
    if Espermateca.Contador = 0 then
      Faltantes := 0
    else if Gonada.Contador < Faltantes then
    begin
      Faltantes := Gonada.Contador;
      CantOvipositada := Fertilizados.Contador + Faltantes;
    end;
    FertilizaCantidad(Faltantes);
  end;
  if Fertilizados.Contador < CantOvipositada then
    CantOvipositada := Fertilizados.Contador;
  Referencia.OvipositadosCiclo := CantOvipositada;
end;

procedure TAgente.Pelear;
begin
  case FDecision of
    7 : (Interactuante as TAgente).Memoria.UltAccionContendiente := 1;//Despl
    8 : (Interactuante as TAgente).Memoria.UltAccionContendiente := 2;//Esc
    13:
    begin
      (Interactuante as TAgente).Ganador;    //Rendirse
      FSituacion := stRegular;
      Interactuante := nil;
    end;
  end;
end;

procedure TAgente.Pretencion(Pretendiente: TAgente);
begin
  FSituacion := stCortejo;
  Interactuante := Pretendiente;
  Memoria.UltAccionContendiente := Pretendiente.Decision - 8; //1 = Desp, 2 = Esc
end;

procedure TAgente.Rechazado;
begin
  FEstado := esDecidido;
  FSituacion := stRegular;
  Interactuante := nil;
  FDecision := 2;
  Tiempo.InteraccionActual := 0;
end;

procedure TAgente.Regular;
begin
  FEstado := esIndeciso;
  FSituacion := stRegular;
  Interactuante := nil;
  FDecision := 2;
end;

procedure TAgente.Reto(Retador: TAgente);
begin
  FSituacion := stCombate;
  Interactuante := Retador;
  Memoria.UltAccionContendiente := Retador.Decision - 6; //1 = Desp, 2 = Esc
end;

procedure TAgente.SetDireccion(const Value: TDireccion);
begin
  FDireccion := Value;
end;

procedure TAgente.SetSustrato(const Value: TCuadro);
begin
  if (FSustrato = Value) then
    Inc(Tiempo.SustratoActual)
  else
  begin
    FSustrato := Value;
    Tiempo.SustratoActual := 0;
  end;
end;

procedure TAgente.TerminarCortejoConCopula;
begin
  FEstado := esIndeciso;
  FSituacion := stRegular;
  Interactuante := nil;
  FDecision := 17;
  Tiempo.InteraccionActual := 0;
end;

{ TListaAgentes }

function TListaAgentes.Agrega(Obj: TAgente): Integer;
begin
  Result := FLista.Add(Obj) + 1;
end;

constructor TListaAgentes.Create;
begin
  inherited Create;
  FLista := TObjectList.Create;
end;

destructor TListaAgentes.Destroy;
begin
  FLista.Free;
  inherited Destroy;
end;

function TListaAgentes.GetContador: Integer;
begin
  Result := FLista.Count;
end;

function TListaAgentes.GetElemento(Index: Integer): TAgente;
begin
  Result := FLista[Index - 1] as TAgente;
end;

function TListaAgentes.GetElementoPorNombre(PNombre: string): TAgente;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to Contador do
    if Elementos[i].Nombre = PNombre then
      Result := Elementos[i];
end;

function TListaAgentes.IndiceDe(Obj: TAgente): Integer;
begin
  Result := FLista.IndexOf(Obj) + 1;
end;

procedure TListaAgentes.Inserta(Index: Integer; Obj: TAgente);
begin
  FLista.Insert(Index - 1, Obj);
end;

function TListaAgentes.Retira(Obj: TAgente): Integer;
begin
  Result := FLista.Remove(Obj) + 1;
end;

procedure TListaAgentes.SetElemento(Index: Integer; Obj: TAgente);
begin
  FLista[Index - 1] := Obj;
end;

{ THuevo }

procedure THuevo.Actualiza;
begin
  Inc(FEdad);
end;

constructor THuevo.Create;//(PPlataforma: TPaintBox);
begin
  inherited Create;//(PPlataforma);
  Nombre := NombreAzarozo;
  FPadre := 'Pigmalión';
  FMadre := 'Galatea';
  FEdad := 0;
  FSexo := sxIndefinido;
  Decision := 0;
end;

procedure THuevo.Decide;
var
  V: TListaV;
  i: Integer;
begin
  SetLength(V, 2);
  for i := 1 to 2 do
    V[i-1] := VDecision[i];
  Decision := Ruleta(V);
end;

destructor THuevo.Destroy;
begin
  if Assigned(Portador) then
  begin
    if Portador.Nombre = '' then
      Exit;
    if Portador is TAgente then //Disminuir número de accareados o alamacenados
      Dec((Portador as TAgente).Acarreados)  //en el portador
    else
    begin
      (Portador as TSitioOviposicion).Nivel :=
        (Portador as TSitioOviposicion).Nivel - 1;
    end;
  end;
  inherited Destroy;
end;

procedure THuevo.Dibuja(XFisica, YFisica, CuadroFisico: Word);
begin
  {Este elemento no es visible, por lo tanto no se dibuja.
   Se implemneta este procedimiento para evitar warnings de falta de implemen-
   tación de métodos abstractos heredados.}
end;

function THuevo.GetLociContinuos(i: Word): Real;
{Regresa los loci expresados según el genotipo}
begin
  Result := 0;
  if i > 15 then
  begin
    raise EFueraDeRango.Create('El índice solicitado está fuera de los límites'
                                + ' del arreglo [GetLociContinuo]');
    Exit; //-->
  end;
  with Genotipo do
  begin
    if (PatContinuos[i].Cualidad = cdDominante) and  //Homocigo dominate
        (MatContinuos[i].Cualidad = cdDominante) then //Codominancia
      Result := (PatContinuos[i].Valor + MatContinuos[i].Valor) / 2
    else  if (PatContinuos[i].Cualidad = cdDominante) and  //Heterocigo
        (MatContinuos[i].Cualidad = cdRecesivo) then
      Result := PatContinuos[i].Valor //Dominancia paterna
    else  if (PatContinuos[i].Cualidad = cdRecesivo) and  //Heterocigo
        (MatContinuos[i].Cualidad = cdDominante) then
      Result := MatContinuos[i].Valor //Dominancia materna
    else  if (PatContinuos[i].Cualidad = cdRecesivo) and  //Homocigo recesivo
        (MatContinuos[i].Cualidad = cdRecesivo) then  //Codominancia
      Result := (PatContinuos[i].Valor + MatContinuos[i].Valor) / 2;
  end;  //with
end;

function THuevo.GetLociDiscretos(i: Word): Integer;
{Regresa los loci expresados según el genotipo}
begin
  Result := 0;
  if i > 15 then
  begin
    raise EFueraDeRango.Create('El índice solicitado está fuera de los límites'
                                + ' del arreglo [GetLociContinuo]');
    Exit; //-->
  end;
  with Genotipo do
  begin
    if (PatDiscretos[i].Cualidad = cdDominante) and  //Homocigo dominate
        (MatDiscretos[i].Cualidad = cdDominante) then //Codominancia
      Result := Round((PatDiscretos[i].Valor+MatDiscretos[i].Valor) / 2)
    else  if (PatDiscretos[i].Cualidad = cdDominante) and  //Heterocigo
        (MatDiscretos[i].Cualidad = cdRecesivo) then
      Result := PatDiscretos[i].Valor //Dominancia paterna
    else  if (PatDiscretos[i].Cualidad = cdRecesivo) and  //Heterocigo
        (MatDiscretos[i].Cualidad = cdDominante) then
      Result := MatDiscretos[i].Valor //Dominancia materna
    else  if (PatDiscretos[i].Cualidad = cdRecesivo) and  //Homocigo recesivo
        (MatDiscretos[i].Cualidad = cdRecesivo) then  //Codominancia
      Result := Round((PatDiscretos[i].Valor+MatDiscretos[i].Valor) / 2);
  end;  //with
end;

procedure THuevo.Inicializa(Padre, Madre: string; Portador: TElemento;
    Edad: Word; Sexo: TSexo);
begin
  FPortador := Portador;
  FEdad := Edad;
  FPadre := Padre;
  FMadre := Madre;
  FSexo := Sexo;
  if Portador is TAgente then   //Aumentar número de acarreados o almacenados
    (Portador as TAgente).Acarreados :=  //en el portador
      (Portador as TAgente).Acarreados + 1
  else
    (Portador as TSitioOviposicion).Nivel :=
        (Portador as TSitioOviposicion).Nivel + 1;
end;

procedure THuevo.Huerfano;
{Convierte al Portador en nil, el huevo se queda sin portador.
Este procedimiento será llamado antes de que el huevo muera, cuando previamente
su portador ah muerto. El propósito de este procedimiento es evitar problemas
con punteros, al momento de intentar disminuir la cantidad de huevos acarreados
por el portador en el procedimiento THuevo.Destroy}
begin
  FPortador := nil;
end;

procedure THuevo.Inicializa(Padre, Madre: string; Sexo: TSexo);
begin
  FPadre := Padre;
  FMadre := Madre;
  FSexo := Sexo;
end;

{ TListaHuevos }

function TListaHuevos.Agrega(Obj: THuevo): Integer;
begin
  Result := FLista.Add(Obj) + 1;
end;

constructor TListaHuevos.Create;
begin
  inherited Create;
  FLista := TObjectList.Create;
end;

destructor TListaHuevos.Destroy;
begin
  FLista.Free;
  inherited Destroy;
end;

function TListaHuevos.GetContador: Integer;
begin
  Result := FLista.Count;
end;

function TListaHuevos.GetElemento(Index: Integer): THuevo;
begin
  Result := FLista[Index - 1] as THuevo;
end;

function TListaHuevos.GetElementoPorNombre(PNombre: string): THuevo;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to Self.Contador do
    if Self.Elementos[i].Nombre = PNombre then
      Result := Self.Elementos[i];
end;

procedure TListaHuevos.HuevosPortador(Portador: TElemento;
  var Huevos: array of THuevo);
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Contador do
    if Elementos[i].Portador = Portador then
    begin
      Huevos[j] := Elementos[i];
      Inc(j);
    end;
end;

function TListaHuevos.IndiceDe(Obj: THuevo): Integer;
begin
  Result := FLista.IndexOf(Obj) + 1;
end;

procedure TListaHuevos.Inserta(Index: Integer; Obj: THuevo);
begin
  FLista.Insert(Index - 1, Obj);
end;

function TListaHuevos.Retira(Obj: THuevo): Integer;
begin
  Result := FLista.Remove(Obj) + 1;
end;

procedure TListaHuevos.SetElemento(Index: Integer; Obj: THuevo);
begin
  FLista[Index - 1] := Obj;
end;

{ TEspermateca }

function TEspermateca.Agrega(PaqEspermatico: TPaqEspermatico): Integer;
begin
  SetLength(FLista, Contador + 1);
  FLista[Contador - 1] := PaqEspermatico;
  Result := Contador;
end;

function TEspermateca.GetContador: Integer;
begin
  Result := Length(FLista);
end;

function TEspermateca.GetElemento(Index: Integer): TPaqEspermatico;
begin
  Result := FLista[Index - 1];
end;

procedure TEspermateca.Retira(Index: Integer);
var
  i: Integer;
begin
  if Contador = 1 then
    SetLength(FLista, 0)
  else
  begin
    for i := Index - 1 to Length(FLista) - 2 do
      FLista[i] := FLista[i+1];
    SetLength(FLista, Contador - 1);
  end;
end;

{ TOvoteca }

function TGonada.Agrega(Reservas: TReservas): Integer;
begin
  SetLength(FLista, Contador + 1);
  FLista[Contador - 1] := Reservas;
  Result := Contador;
end;

function TGonada.GetContador: Integer;
begin
  Result := Length(FLista);
end;

function TGonada.GetElemento(Index: Integer): TReservas;
begin
  Result := FLista[Index - 1];
end;

procedure TGonada.Retira(Index: Integer);
var
  i: Integer;
begin
  if Contador = 1 then
    SetLength(FLista, 0)
  else
  begin
    for i := Index - 1 to Length(FLista) - 2 do
      FLista[i] := FLista[i+1];
    SetLength(FLista, Contador - 1);
  end;
end;

end.
