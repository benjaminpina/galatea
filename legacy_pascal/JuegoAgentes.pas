{*******************************************************************************
Contiene la implementación de la clase TJuegoAgentes y tipos relacionados.

Sistema Galatea
Autor: Benjamín Piña Altamirano
2003
*******************************************************************************}
unit JuegoAgentes;

{$MODE Delphi}

interface

uses
  Comunes;//, Graphics;

type

  {Tipos}

  TContinuo = record
    Nombre: string[30];
    Omision: string;
  end;

  TDiscreto = record
    Nombre: string[30];
    Omision: string;
  end;

  TCaracterMorfologico = record
    ValorGenetico,
    ValorAmbiental: string;
  end;

  TGenContinuo = record
    Dominante,
    Recesivo,
    MutacionD,
    MutacionR,
    RangoMutacionD,
    RangoMutacionR: Real;
  end;

  TGenDiscreto = record
    Dominante,
    Recesivo,
    RangoMutacionD,
    RangoMutacionR: LongWord;
    MutacionD,
    MutacionR: Real;
  end;

  TMovimiento = record
    Costos: array [1..4, 1..2] of string;
    Velocidad: array [1..7] of string;
  end;

  TAlimentacion = record
    Costos: array [1..4, 1..4] of string;
    Ganancias: array [1..4] of string;
  end;

  TEstadio = record
    Nombre: string[30];
    Y_O: Boolean;     //Si Y_O, Y; no Y_O, O; Edad y requerimientos
    Y_OR: Boolean;    //Requerimientos y condiciones
    Y_OC1C2: Boolean; //Condición 1 y condición 2
    Condicion1,
    Condicion2: string;
    Prototipo: Word;  //Número de prototipo ligado
    Ciclos: string;
    Tendencias: array [1..8] of string;
    Requiere: array [1..4] of string;
    Costos: array [1..4] of string;
    Color: TColor;
  end;

  TPrototipo = record
    Nombre: string[30];
    Continuos: array [1..15] of TCaracterMorfologico;
    Discretos: array [1..15] of TCaracterMorfologico;
    Color: TColor;
    Tendencias: array [1..8] of string;
    Combate: array [1..3, 1..2] of string;
    Cortejo: array [1..4, 1..3] of string;
    RefractarioCombate: string;
    RefractarioCortejo: string;
    Longevidad: string;
    ProporcionMachos,   //Proporción sexual asociada a descendencia de prototipo
    ProporcionHembras: string; //_ aplicable sólo a hembras
  end;

  {Clases}

  TMatrizInteraccion = class
  private
    Matriz: array of array of string;
    FAncho: Word;
    FAlto: Word;
    function GetCelda(X, Y: Word): string;
    procedure SetCelda(X, Y: Word; const Value: string);
    procedure AgregaEstadio(NumE: Word); virtual;
    procedure Agrega(NumE, NumM, NumH: Word; Sexo: TSexo); virtual;
    procedure Retira(Num: Word); virtual;
  public
    constructor Create(Ancho, Alto: Word);
    property Celda[X,Y: Word]: string
      read GetCelda write SetCelda;
    property Ancho: Word
      read FAncho;
    property Alto: Word
      read FAlto;
  end;

  TMatrizInteraccionAgentes = class(TMatrizInteraccion)
  private
    procedure AgregaEstadio(NumE: Word); override;
    procedure Agrega(NumE, NumM, NumH: Word; Sexo: TSexo); override;
    procedure Retira(Num: Word); override;
  end;

  TJuegoAgentes = class(TGuardable)
  private
    FNumPrototiposM: Word;
    FNumPrototiposH: Word;
    FEstadios: array of TEstadio;
    FPrototiposM: array of TPrototipo;
    FPrototiposH: array of TPrototipo;
    FNumEstadios: Word;
    procedure SetNumPrototiposH(const Value: Word);
    procedure SetNumPrototiposM(const Value: Word);
    function GetPrototiposM(w: word): TPrototipo;
    procedure SetPrototiposM(w: word; const Value: TPrototipo);
    function GetPrototiposH(w: Word): TPrototipo;
    procedure SetPrototiposH(w: Word; const Value: TPrototipo);
    procedure SetNumEstadios(const Value: Word);
    function GetEstadios(w: Word): TEstadio;
    procedure SetEstadios(w: Word; const Value: TEstadio);
  public
    Titulo: string[80];
    Comentarios: string;
    Continuos: array [1..15] of TContinuo;
    Discretos: array [1..15] of TDiscreto;
    LociContinuos: array [1..15] of TGenContinuo;
    LociDiscretos: array [1..15] of TGenDiscreto;
    Sustratos: array [1..7] of string[15]; //Nombres de sustratos
    CostoHuevo: array [1..4] of string;
    CostoPaquete: array [1..4] of string;
    CostosCombate: array [1..4, 1..3] of string;
    CostosCortejo: array [1..4, 1..6] of string; //Incluye costos oviposición
    Metabolismo: array [1..5,1..4] of string;
    MatrizSustratos: TMatrizInteraccion;
    MatrizDinamicos: TMatrizInteraccion;
    MatrizAgentes: TMatrizInteraccionAgentes;
    MatrizSustratosA: TMatrizInteraccion;
    MatrizDinamicosA: TMatrizInteraccion;
    MatrizAgentesA: TMatrizInteraccionAgentes;
    MatrizSustratosM: TMatrizInteraccion;
    MatrizDinamicosM: TMatrizInteraccion;
    MatrizAgentesM: TMatrizInteraccionAgentes;
    MatrizConductasM: TMatrizInteraccion;
    CriteriosM,             //Criterios asignación prototipos
    CriteriosH: array of array of string;
    JerarquiaM: string;
    JerarquiaH: string;
    Movimiento: TMovimiento;
    Alimentacion: TAlimentacion;
    MaxHuevos: string;
    MaxPaquetes: string;
    PaquetesTransferidos: string; //Paquetes transferidos por cópula
    HuevosFertilizados: string;//Fracción de fertilizados justo desp de cópula
    Paternidad: string; //Probabilidad de paternidad
    MaxPaquetesH: string; //Máximo de paq esp alamacenado por hembra
    TasaConsumo: string;
    HuevosCiclo: string;
    FraccionHuevo: string;
    FraccionPaquete: string;
    DegradacionEsperma: string;
    function Ligado(Num: Word): string;
    function NumeroPrototipo(Num: Word): Word;
    function SexoPrototipo(Num: Word): TSexo;
    constructor Create;
    procedure Guarda(NombreArchivo: string); override;
    procedure Carga(NombreArchivo: string); override;
    procedure InsertaEstadio;
    procedure InsertaPrototipo(Sexo: TSexo);
    procedure BorraEstadio(Num: Word);
    procedure BorraPrototipo(Sexo: TSexo; Num: Word);
    property NumEstadios: Word
      read FNumEstadios write SetNumEstadios;
    property NumPrototiposM: Word
      read FNumPrototiposM write SetNumPrototiposM;
    property NumPrototiposH: Word
      read FNumPrototiposH write SetNumPrototiposH;
    property Estadios[w: Word]: TEstadio
      read GetEstadios write SetEstadios;
    property PrototiposM[w: Word]: TPrototipo
      read GetPrototiposM write SetPrototiposM;
    property PrototiposH[w: Word]: TPrototipo
      read GetPrototiposH write SetPrototiposH;
  end;

implementation

uses
  Classes, SysUtils{, Math};

{ TJuegoAgentes }

constructor TJuegoAgentes.Create;
begin
  Titulo := '';
  Comentarios := '';
  FNumEstadios := 2;
  FNumPrototiposM := 1;
  FNumPrototiposH := 1;
  SetLength(FEstadios, FNumEstadios);
  SetLength(FPrototiposM, FNumPrototiposM);
  SetLength(FPrototiposH, FNumPrototiposH);
  MatrizSustratos := TMatrizInteraccion.Create(7, FNumEstadios + FNumPrototiposM
                                                            + FNumPrototiposH);
  MatrizDinamicos := TMatrizInteraccion.Create(5, FNumEstadios + FNumPrototiposM
                                                            + FNumPrototiposH);
  MatrizAgentes := TMatrizInteraccionAgentes.Create(FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizSustratosA := TMatrizInteraccion.Create(7, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizDinamicosA := TMatrizInteraccion.Create(5, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizAgentesA := TMatrizInteraccionAgentes.Create(FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizSustratosM := TMatrizInteraccion.Create(7, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizDinamicosM := TMatrizInteraccion.Create(5, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizAgentesM := TMatrizInteraccionAgentes.Create(FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  MatrizConductasM := TMatrizInteraccion.Create(14, FNumEstadios
                              + FNumPrototiposM + FNumPrototiposH);
  SetLength(CriteriosM, 3, FNumPrototiposM);
  SetLength(CriteriosH, 3, FNumPrototiposH);
end;

procedure TJuegoAgentes.Carga(NombreArchivo: string);
var
  Lineas : TStringList;
  i, j,
  k, c   : Integer;
  r      : Real;
  s,
  Linea  : string;
begin
  inherited Carga(NombreArchivo);
  Titulo := LeeValor('Titulo');
  NumEstadios := LeeValorEntero('NumEstadios');
  NumPrototiposM := LeeValorEntero('NumPrototiposM');
  NumPrototiposH := LeeValorEntero('NumPrototiposH');
  Linea := LeeValor('Velocidad');
  for i := 1 to 7 do
    Movimiento.Velocidad[i] := ObtenNsimo(Linea,i);
  s := LeeValor('Y_OEstadios');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Y_O := (ObtenNsimo(s, i) = '1');
  s := LeeValor('Y_OEstadiosR');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Y_OR := (ObtenNsimo(s, i) = '1');
  s := LeeValor('Y_OEstadiosC1C2');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Y_OC1C2 := (ObtenNsimo(s, i) = '1');
  s := LeeValor('PrototiposLigados');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Prototipo := StrToInt(ObtenNsimo(s, i));
  s := LeeValor('CiclosEstadios');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Ciclos := ObtenNsimo(s,i);
  MaxHuevos := LeeValor('MaxHuevos');
  MaxPaquetes := LeeValor('MaxPaquetes');
  PaquetesTransferidos := LeeValor('PaquetesTransferidos');
  HuevosFertilizados := LeeValor('HuevosFertilizados');
  Paternidad := LeeValor('Paternidad');
  MaxPaquetesH := LeeValor('MaxPaquetesH');
  TasaConsumo :=  LeeValor('TasaConsumo');
  HuevosCiclo := LeeValor('HuevosCiclo');
  FraccionHuevo := LeeValor('FraccionHuevo');
  FraccionPaquete := LeeValor('FraccionPaquete');
  DegradacionEsperma := LeeValor('DegradacionEsperma');
  JerarquiaM := LeeValor('JerarquiaM');
  JerarquiaH := LeeValor('JerarquiaH');
  Lineas := LeeValorAmpliado('EstadiosCondiciones1');
  for i := 1 to FNumEstadios do
      FEstadios[i-1].Condicion1 := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('EstadiosCondiciones2');
  for i := 1 to FNumEstadios do
      FEstadios[i-1].Condicion2 := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('CriteriosM');
  SetLength(CriteriosM, 3, FNumPrototiposM);
  for j := 0 to FNumPrototiposM - 1 do
  begin
    Linea := Lineas.Strings[j];
    for i := 0 to 2 do
      CriteriosM[i,j] := ObtenNsimo(Linea, i+1);
  end;
  Lineas := LeeValorAmpliado('CriteriosH');
  SetLength(CriteriosH, 3, FNumPrototiposH);
  for j := 0 to FNumPrototiposH - 1 do
  begin
    Linea := Lineas.Strings[j];
    for i := 0 to 2 do
      CriteriosH[i,j] := ObtenNsimo(Linea, i+1);
  end;
  Linea := LeeValor('CostoHuevo');
  for i := 1 to 4 do
    CostoHuevo[i] := ObtenNsimo(Linea,i);
  Linea := LeeValor('CostoPaquete');
  for i := 1 to 4 do
    CostoPaquete[i] := ObtenNsimo(Linea,i);
  Lineas := LeeValorAmpliado('Comentarios');
  Comentarios := Lineas.Text;
  Lineas := LeeValorAmpliado('NombresContinuos');
  for i := 1 to 15 do
    Continuos[i].Nombre := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('NombresDiscretos');
  for i := 1 to 15 do
    Discretos[i].Nombre := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('OmisionContinuos');
  for i := 1 to 15 do
    Continuos[i].Omision := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('OmisionDiscretos');
  for i := 1 to 15 do
    Discretos[i].Omision := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('DominantesContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].Dominante := r;
  end;
  Lineas := LeeValorAmpliado('RecesivosContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].Recesivo := r;
  end;
  Lineas := LeeValorAmpliado('MutacionDominantesContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].MutacionD := r;
  end;
  Lineas := LeeValorAmpliado('MutacionRecesivosContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].MutacionR := r;
  end;
  Lineas := LeeValorAmpliado('RangoMutacionDominantesContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].RangoMutacionD := r;
  end;
  Lineas := LeeValorAmpliado('RangoMutacionRecesivosContinuos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociContinuos[i].RangoMutacionR := r;
  end;
  Lineas := LeeValorAmpliado('DominantesDiscretos');
  for i := 1 to 15 do
  begin
    k := StrToInt(Lineas.Strings[i-1]);
    LociDiscretos[i].Dominante := k;
  end;
  Lineas := LeeValorAmpliado('RecesivosDiscretos');
  for i := 1 to 15 do
  begin
    k := StrToInt(Lineas.Strings[i-1]);
    LociDiscretos[i].Recesivo := k;
  end;
  Lineas := LeeValorAmpliado('MutacionDominantesDiscretos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociDiscretos[i].MutacionD := r;
  end;
  Lineas := LeeValorAmpliado('MutacionRecesivosDiscretos');
  for i := 1 to 15 do
  begin
    r := StrToFloat(Lineas.Strings[i-1]);
    LociDiscretos[i].MutacionR := r;
  end;
  Lineas := LeeValorAmpliado('RangoMutacionDominantesDiscretos');
  for i := 1 to 15 do
  begin
    k := StrToInt(Lineas.Strings[i-1]);
    LociDiscretos[i].RangoMutacionD := k;
  end;
  Lineas := LeeValorAmpliado('RangoMutacionRecesivosDiscretos');
  for i := 1 to 15 do
  begin
    k := StrToInt(Lineas.Strings[i-1]);
    LociDiscretos[i].RangoMutacionR := k;
  end;
  Lineas := LeeValorAmpliado('NombresSustratos');
  for i := 1 to 7 do
    Sustratos[i] := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('CostosMovimiento');
  for j := 1 to 2 do
  begin
    Linea := Lineas.Strings[j-1];
    for i := 1 to 4 do
    begin
      Movimiento.Costos[i,j] := ObtenNsimo(Linea, i);
    end;
  end;
  Lineas := LeeValorAmpliado('CostosAlimentacion');
  for i := 1 to 4 do
    for j := 1 to 4 do
      Alimentacion.Costos[i,j] := ObtenNsimo(Lineas.Strings[i-1],j);
  Linea := LeeValor('GananciasAlimentacion');
  for i := 1 to 4 do
    Alimentacion.Ganancias[i] := ObtenNsimo(Linea,i);
  Lineas := LeeValorAmpliado('NombresEstadios');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Nombre := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('ColoresEstadios');
  for i := 1 to FNumEstadios do
    FEstadios[i-1].Color := StrToInt(Lineas.Strings[i-1]);
  Lineas := LeeValorAmpliado('NombresPrototiposM');
  for i := 1 to FNumPrototiposM do
    FPrototiposM[i-1].Nombre := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('ColoresPrototiposM');
  for i := 1 to FNumPrototiposM do
    FPrototiposM[i-1].Color := StrToInt(Lineas.Strings[i-1]);
  Lineas := LeeValorAmpliado('LongevidadesPrototiposM');
  for i := 1 to FNumPrototiposM do
    FPrototiposM[i-1].Longevidad := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('NombresPrototiposH');
  for i := 1 to FNumPrototiposH do
    FPrototiposH[i-1].Nombre := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('ColoresPrototiposH');
  for i := 1 to FNumPrototiposH do
    FPrototiposH[i-1].Color := StrToInt(Lineas.Strings[i-1]);
  Lineas := LeeValorAmpliado('LongevidadesPrototiposH');
  for i := 1 to FNumPrototiposH do
    FPrototiposH[i-1].Longevidad := Lineas.Strings[i-1];
  Lineas := LeeValorAmpliado('ProporcionesSexuales');
  for i := 1 to FNumPrototiposH do
  begin
    FPrototiposH[i-1].ProporcionMachos := ObtenNsimo(Lineas.Strings[i-1], 1);
    FPrototiposH[i-1].ProporcionHembras := ObtenNsimo(Lineas.Strings[i-1], 2);
  end;
  Lineas := LeeValorAmpliado('RequerimientosEstadios');
  for i := 1 to FNumEstadios do
  begin
    s := Lineas.Strings[i-1];
    for j := 1 to 4 do
      FEstadios[i-1].Requiere[j] := ObtenNsimo(s,j);
  end;
  Lineas := LeeValorAmpliado('CostosEstadios');
  for i := 1 to FNumEstadios do
  begin
    s := Lineas.Strings[i-1];
    for j := 1 to 4 do
      FEstadios[i-1].Costos[j] := ObtenNsimo(s,j);
  end;
  Lineas := LeeValorAmpliado('DiscretosPrototiposM');
  for i := 0 to FNumPrototiposM - 1 do
  begin
    Linea := Lineas.Strings[i];
    k := 1;
    for j := 1 to 15 do
    begin
      FPrototiposM[i].Discretos[j].ValorGenetico := ObtenNsimo(Linea,k);
      FPrototiposM[i].Discretos[j].ValorAmbiental := ObtenNsimo(Linea,k+1);
      Inc(k, 2);
    end;
  end;
  Lineas := LeeValorAmpliado('DiscretosPrototiposH');
  for i := 0 to FNumPrototiposH - 1 do
  begin
    Linea := Lineas.Strings[i];
    k := 1;
    for j := 1 to 15 do
    begin
      FPrototiposH[i].Discretos[j].ValorGenetico := ObtenNsimo(Linea,k);
      FPrototiposH[i].Discretos[j].ValorAmbiental := ObtenNsimo(Linea,k+1);
      Inc(k, 2);
    end;
  end;
  Lineas := LeeValorAmpliado('ContinuosPrototiposM');
  k := 0;
  for i := 1 to FNumPrototiposM do
  begin
    for j := 1 to 15 do
      begin
        FPrototiposM[i-1].Continuos[j].ValorGenetico := Lineas.Strings[k];
        FPrototiposM[i-1].Continuos[j].ValorAmbiental := Lineas.Strings[k+1];
        Inc(K,2);
      end;
  end;
  Lineas := LeeValorAmpliado('ContinuosPrototiposH');
  k := 0;
  for i := 1 to FNumPrototiposH do
  begin
    for j := 1 to 15 do
    begin
      FPrototiposH[i-1].Continuos[j].ValorGenetico := Lineas.Strings[k];
      FPrototiposH[i-1].Continuos[j].ValorAmbiental := Lineas.Strings[k+1];
      Inc(K,2);
    end;
  end;
  Linea := LeeValor('RefractariosCombateM');
  for i := 1 to FNumPrototiposM do
    FPrototiposM[i-1].RefractarioCombate := ObtenNsimo(Linea, i);
  Linea := LeeValor('RefractariosCombateH');
  for i := 1 to FNumPrototiposH do
    FPrototiposH[i-1].RefractarioCombate := ObtenNsimo(Linea, i);
  Linea := LeeValor('RefractariosCortejoM');
  for i := 1 to FNumPrototiposM do
    FPrototiposM[i-1].RefractarioCortejo := ObtenNsimo(Linea, i);
  Linea := LeeValor('RefractariosCortejoH');
  for i := 1 to FNumPrototiposH do
    FPrototiposH[i-1].RefractarioCortejo := ObtenNsimo(Linea, i);
  Lineas := LeeValorAmpliado('TendenciasEstadios');
  for i := 0 to FNumEstadios - 1 do
  begin
    Linea := Lineas.Strings[i];
    for j := 1 to 8 do
      FEstadios[i].Tendencias[j] := ObtenNsimo(Linea, j);
  end;
  Lineas := LeeValorAmpliado('TendenciasMachos');
  for i := 0 to FNumPrototiposM - 1 do
  begin
    Linea := Lineas.Strings[i];
    for j := 1 to 8 do
      FPrototiposM[i].Tendencias[j] := ObtenNsimo(Linea, j);
  end;
  Lineas := LeeValorAmpliado('TendenciasHembras');
  for i := 0 to FNumPrototiposH - 1 do
  begin
    Linea := Lineas.Strings[i];
    for j := 1 to 8 do
      FPrototiposH[i].Tendencias[j] := ObtenNsimo(Linea, j);
  end;
  Lineas := LeeValorAmpliado('CostosCombate');
  for j := 1 to 3 do
    for i := 1 to 4 do
      CostosCombate[i,j] := ObtenNsimo(Lineas.Strings[j-1], i);
  Lineas := LeeValorAmpliado('CostosCortejo');
  //****PARCHE
  if Lineas.Count < 6 then
    Lineas.Add('2,2,2,2');
  //**********
  for j := 1 to 6 do
    for i := 1 to 4 do
      CostosCortejo[i,j] := ObtenNsimo(Lineas.Strings[j-1], i);
  Lineas := LeeValorAmpliado('MatrizSustratos');
  MatrizSustratos.Free;
  MatrizSustratos := TMatrizInteraccion.Create(7, FNumEstadios +FNumPrototiposM
                                                            + FNumPrototiposH);
  k := 0;
  for i := 1 to 7 do  //Número de sustratos = 7
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      MatrizSustratos.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizDinamicos');
  MatrizDinamicos.Free;
  MatrizDinamicos := TMatrizInteraccion.Create(5, FNumEstadios +FNumPrototiposM
                                                            + FNumPrototiposH);
  k := 0;
  for i := 1 to 5 do  //Número de elementos dinámicos = 5
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      MatrizDinamicos.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizAgentes');
  MatrizAgentes.Free;
  MatrizAgentes := TMatrizInteraccionAgentes.Create
                  (FNumEstadios + FNumPrototiposM + FNumPrototiposH,
                    FNumEstadios + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      s := Lineas.Strings[k];
      MatrizAgentes.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizSustratosA');
  MatrizSustratosA.Free;
  MatrizSustratosA := TMatrizInteraccion.Create(7, FNumEstadios +FNumPrototiposM
                                                            + FNumPrototiposH);
  k := 0;
  for i := 1 to 7 do  //Número de sustratos = 7
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      MatrizSustratosA.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizDinamicosA');
  MatrizDinamicosA.Free;
  MatrizDinamicosA := TMatrizInteraccion.Create(5, FNumEstadios +FNumPrototiposM
                                                            + FNumPrototiposH);
  k := 0;
  for i := 1 to 5 do  //Número de elementos dinámicos = 5
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      MatrizDinamicosA.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizAgentesA');
  MatrizAgentesA.Free;
  MatrizAgentesA := TMatrizInteraccionAgentes.Create
                  (FNumEstadios + FNumPrototiposM + FNumPrototiposH,
                    FNumEstadios + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    begin
      MatrizAgentesA.Celda[i,j] := Lineas.Strings[k];
      Inc(k);
    end;
  Lineas := LeeValorAmpliado('MatrizSustratosM');
  MatrizSustratosM.Free;
  MatrizSustratosM := TMatrizInteraccion.Create(7, FNumEstadios
                                        + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to 7 do
  begin
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      MatrizSustratosM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
    Inc(k);
  end;
  Lineas := LeeValorAmpliado('MatrizDinamicosM');
  MatrizDinamicosM.Free;
  MatrizDinamicosM := TMatrizInteraccion.Create(5, FNumEstadios
                                        + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to 5 do
  begin
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      MatrizDinamicosM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
    Inc(k);
  end;
  Lineas := LeeValorAmpliado('MatrizAgentesM');
  MatrizAgentesM.Free;
  MatrizAgentesM := TMatrizInteraccionAgentes.Create(FNumEstadios
                    + FNumPrototiposM + FNumPrototiposH, FNumEstadios
                    + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
  begin
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      MatrizAgentesM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
    Inc(k);
  end;
  Lineas := LeeValorAmpliado('MatrizConductasM');
  MatrizConductasM.Free;
  MatrizConductasM := TMatrizInteraccion.Create(14, FNumEstadios
                                        + FNumPrototiposM + FNumPrototiposH);
  k := 0;
  for i := 1 to 14 do
  begin
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      MatrizConductasM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
    Inc(k);
  end;
  Lineas := LeeValorAmpliado('MatricesCombateM');
  c := 0;
  for k := 1 to NumPrototiposM do
  begin
    for j := 1 to 2 do
    begin
      Linea := Lineas.Strings[c];
      for i := 1 to 3 do
        FPrototiposM[k-1].Combate[i,j] := ObtenNsimo(Linea, i);
      Inc(c);
    end;
  end;
  Lineas := LeeValorAmpliado('MatricesCortejoM');
  c := 0;
  for k := 1 to NumPrototiposM do
  begin
    for j := 1 to 3 do
    begin
      Linea := Lineas.Strings[c];
      for i := 1 to 4 do
        FPrototiposM[k-1].Cortejo[i,j] := ObtenNsimo(Linea, i);
      Inc(c);
    end;
  end;
  Lineas := LeeValorAmpliado('MatricesCombateH');
  c := 0;
  for k := 1 to NumPrototiposH do
  begin
    for j := 1 to 2 do
    begin
      Linea := Lineas.Strings[c];
      for i := 1 to 3 do
        FPrototiposH[k-1].Combate[i,j] := ObtenNsimo(Linea, i);
      Inc(c);
    end;
  end;
  Lineas := LeeValorAmpliado('MatricesCortejoH');
  c := 0;
  for k := 1 to NumPrototiposH do
  begin
    for j := 1 to 3 do
    begin
      Linea := Lineas.Strings[c];
      for i := 1 to 4 do
        FPrototiposH[k-1].Cortejo[i,j] := ObtenNsimo(Linea, i);
      Inc(c);
    end;
  end;
  Lineas := LeeValorAmpliado('Metabolismo');
  for j := 1 to 4 do
    for i := 1 to 5 do
      Metabolismo[i,j] := ObtenNsimo(Lineas.Strings[j-1],i);
  Lineas.Free;
end; //proc Carga

procedure TJuegoAgentes.Guarda(NombreArchivo: string);
var
  Lineas : TStringList;
  Linea  : string;
  i, j, k: Integer;
begin
  Reestablece;
  Lineas := TStringList.Create;
  EscribeValor('Titulo', Titulo);
  EscribeValor('NumEstadios', FNumEstadios);
  EscribeValor('NumPrototiposM', FNumPrototiposM);
  EscribeValor('NumPrototiposH', FNumPrototiposH);
  Linea := '';
  for i := 1 to 7 do
    Linea := Linea + Movimiento.Velocidad[i] + ',';
  EscribeValor('Velocidad', Linea);
  Linea := '';
  for i := 1 to FNumEstadios do
  begin
    if FEstadios[i-1].Y_O then
      Linea := Linea + '1,'
    else
      Linea := Linea + '0,';
  end;
  EscribeValor('Y_OEstadios', Linea);
  Linea := '';
  for i := 1 to FNumEstadios do
  begin
    if FEstadios[i-1].Y_OR then
      Linea := Linea + '1,'
    else
      Linea := Linea + '0,';
  end;
  EscribeValor('Y_OEstadiosR', Linea);
  Linea := '';
  for i := 1 to FNumEstadios do
  begin
    if FEstadios[i-1].Y_OC1C2 then
      Linea := Linea + '1,'
    else
      Linea := Linea + '0,';
  end;
  EscribeValor('Y_OEstadiosC1C2', Linea);
  Linea := '';
  for i := 1 to FNumEstadios do
  begin
    if FEstadios[i-1].Prototipo <> 0 then
      Linea := Linea + IntToStr(FEstadios[i-1].Prototipo) + ','
    else
      Linea := Linea + '0,';
  end;
  EscribeValor('PrototiposLigados', Linea);
  Linea := '';
  for i := 1 to FNumEstadios do
    Linea := Linea + FEstadios[i-1].Ciclos + ',';
  EscribeValor('CiclosEstadios', Linea);
  EscribeValor('MaxHuevos', MaxHuevos);
  EscribeValor('MaxPaquetes', MaxPaquetes);
  EscribeValor('PaquetesTransferidos', PaquetesTransferidos);
  EscribeValor('HuevosFertilizados', HuevosFertilizados);
  EscribeValor('Paternidad', Paternidad);
  EscribeValor('MaxPaquetesH', MaxPaquetesH);
  EscribeValor('TasaConsumo', TasaConsumo);
  EscribeValor('HuevosCiclo', HuevosCiclo);
  EscribeValor('FraccionHuevo', FraccionHuevo);
  EscribeValor('FraccionPaquete', FraccionPaquete);
  EscribeValor('DegradacionEsperma', DegradacionEsperma);
  EscribeValor('JerarquiaM', JerarquiaM);
  EscribeValor('JerarquiaH', JerarquiaH);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
    Lineas.Add(Estadios[i].Condicion1);
  EscribeValor('EstadiosCondiciones1', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
    Lineas.Add(Estadios[i].Condicion2);
  EscribeValor('EstadiosCondiciones2', Lineas);
  Lineas.Clear;
  for j := 0 to FNumPrototiposM - 1 do
  begin
    Linea := '';
    for i := 0 to 2 do
      Linea := Linea + CriteriosM[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CriteriosM', Lineas);
  Lineas.Clear;
  for j := 0 to FNumPrototiposH - 1 do
  begin
    Linea := '';
    for i := 0 to 2 do
      Linea := Linea + CriteriosH[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CriteriosH', Lineas);
  Linea := '';
  for i := 1 to 4 do
    Linea := Linea + CostoHuevo[i] + ',';
  EscribeValor('CostoHuevo',Linea);
  Linea := '';
  for i := 1 to 4 do
    Linea := Linea + CostoPaquete[i] + ',';
  EscribeValor('CostoPaquete',Linea);
  Lineas.Clear;
  Lineas.Text := Comentarios;
  EscribeValor('Comentarios', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := Continuos[i].Nombre;
    Lineas.Add(Linea);
  end;
  EscribeValor('NombresContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := Discretos[i].Nombre;
    Lineas.Add(Linea);
  end;
  EscribeValor('NombresDiscretos', Lineas);
  Lineas.Clear;
  for j := 1 to 2 do
  begin
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + Movimiento.Costos[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CostosMovimiento', Lineas);
  Lineas.Clear;
  for i := 1 to 4 do
  begin
    Linea := '';
    for j := 1 to 4 do
      Linea := Linea + Alimentacion.Costos[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CostosAlimentacion', Lineas);
  Linea := '';
  for i := 1 to 4 do
    Linea := Linea + Alimentacion.Ganancias[i] + ',';
  EscribeValor('GananciasAlimentacion', Linea);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(Continuos[i].Omision);
  EscribeValor('OmisionContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := Discretos[i].Omision;
    Lineas.Add(Linea);
  end;
  EscribeValor('OmisionDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].Dominante));
  EscribeValor('DominantesContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].Recesivo));
  EscribeValor('RecesivosContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].MutacionD));
  EscribeValor('MutacionDominantesContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].MutacionR));
  EscribeValor('MutacionRecesivosContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].RangoMutacionD));
  EscribeValor('RangoMutacionDominantesContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
    Lineas.Add(FloatToStr(LociContinuos[i].RangoMutacionR));
  EscribeValor('RangoMutacionRecesivosContinuos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := IntToStr(LociDiscretos[i].Dominante);
    Lineas.Add(Linea);
  end;
  EscribeValor('DominantesDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := IntToStr(LociDiscretos[i].Recesivo);
    Lineas.Add(Linea);
  end;
  EscribeValor('RecesivosDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := FloatToStr(LociDiscretos[i].MutacionD);
    Lineas.Add(Linea);
  end;
  EscribeValor('MutacionDominantesDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := FloatToStr(LociDiscretos[i].MutacionR);
    Lineas.Add(Linea);
  end;
  EscribeValor('MutacionRecesivosDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := FloatToStr(LociDiscretos[i].RangoMutacionD);
    Lineas.Add(Linea);
  end;
  EscribeValor('RangoMutacionDominantesDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 15 do
  begin
    Linea := FloatToStr(LociDiscretos[i].RangoMutacionR);
    Lineas.Add(Linea);
  end;
  EscribeValor('RangoMutacionRecesivosDiscretos', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do
    Lineas.Add(Sustratos[i]);
  EscribeValor('NombresSustratos', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
    Lineas.Add(FEstadios[i-1].Nombre);
  EscribeValor('NombresEstadios', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
    Lineas.Add(IntAStr(FEstadios[i-1].Color, 8));
  EscribeValor('ColoresEstadios', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
    Lineas.Add(FPrototiposM[i-1].Nombre);
  EscribeValor('NombresPrototiposM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
    Lineas.Add(IntAStr(FPrototiposM[i-1].Color, 8));
  EscribeValor('ColoresPrototiposM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
    Lineas.Add(FPrototiposM[i-1].Longevidad);
  EscribeValor('LongevidadesPrototiposM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
    Lineas.Add(FPrototiposH[i-1].Nombre);
  EscribeValor('NombresPrototiposH', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
    Lineas.Add(IntAStr(FPrototiposH[i-1].Color, 8));
  EscribeValor('ColoresPrototiposH', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
    Lineas.Add(FPrototiposH[i-1].Longevidad);
  EscribeValor('LongevidadesPrototiposH', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
  begin
    Linea := FPrototiposH[i-1].ProporcionMachos + ','
              + FPrototiposH[i-1].ProporcionHembras;
    Lineas.Add(Linea);
  end;
  EscribeValor('ProporcionesSexuales', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
  begin
    Linea := '';
    for j := 1 to 4 do
      Linea := Linea + FEstadios[i-1].Requiere[j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('RequerimientosEstadios', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios do
  begin
    Linea := '';
    for j := 1 to 4 do
      Linea := Linea + FEstadios[i-1].Costos[j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CostosEstadios', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
  begin
    Linea := '';
    for j := 1 to 15 do
    begin
      Linea := Linea + (FPrototiposM[i-1].Discretos[j].ValorGenetico) + ',';
      Linea := Linea + (FPrototiposM[i-1].Discretos[j].ValorAmbiental) + ',';
    end;
    Lineas.Add(Linea);
  end;
  EscribeValor('DiscretosPrototiposM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
  begin
    Linea := '';
    for j := 1 to 15 do
    begin
      Linea := Linea + FPrototiposH[i-1].Discretos[j].ValorGenetico + ',';
      Linea := Linea + FPrototiposH[i-1].Discretos[j].ValorAmbiental + ',';
    end;
    Lineas.Add(Linea);
  end;
  EscribeValor('DiscretosPrototiposH', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
    for j := 1 to 15 do
    begin
      Lineas.Add(FPrototiposM[i-1].Continuos[j].ValorGenetico);
      Lineas.Add(FPrototiposM[i-1].Continuos[j].ValorAmbiental);
    end;
  EscribeValor('ContinuosPrototiposM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
    for j := 1 to 15 do
    begin
      Lineas.Add(FPrototiposH[i-1].Continuos[j].ValorGenetico);
      Lineas.Add(FPrototiposH[i-1].Continuos[j].ValorAmbiental);
    end;
  EscribeValor('ContinuosPrototiposH', Lineas);
  Linea := '';
  for i := 1 to FNumPrototiposM do
    Linea := Linea + PrototiposM[i].RefractarioCombate + ',';
  EscribeValor('RefractariosCombateM', Linea);
  Linea := '';
  for i := 1 to FNumPrototiposH do
    Linea := Linea + PrototiposH[i].RefractarioCombate + ',';
  EscribeValor('RefractariosCombateH', Linea);
  Linea := '';
  for i := 1 to FNumPrototiposM do
    Linea := Linea + PrototiposM[i].RefractarioCortejo + ',';
  EscribeValor('RefractariosCortejoM', Linea);
  Linea := '';
  for i := 1 to FNumPrototiposH do
    Linea := Linea + PrototiposH[i].RefractarioCortejo + ',';
  EscribeValor('RefractariosCortejoH', Linea);
  Lineas.Clear;
  Linea := '';
  for i := 1 to FNumEstadios do
  begin
    Linea := '';
    for j := 1 to 8 do
      Linea := Linea + Estadios[i].Tendencias[j] + ', ';
    Lineas.Add(Linea);
  end;
  EscribeValor('TendenciasEstadios', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposM do
  begin
    Linea := '';
    for j := 1 to 8 do
      Linea := Linea + PrototiposM[i].Tendencias[j] + ', ';
    Lineas.Add(Linea);
  end;
  EscribeValor('TendenciasMachos', Lineas);
  Lineas.Clear;
  for i := 1 to FNumPrototiposH do
  begin
    Linea := '';
    for j := 1 to 8 do
      Linea := Linea + PrototiposH[i].Tendencias[j] + ', ';
    Lineas.Add(Linea);
  end;
  EscribeValor('TendenciasHembras', Lineas);
  Lineas.Clear;
  for j := 1 to 3 do
  begin
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + CostosCombate[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CostosCombate', Lineas);
  Lineas.Clear;
  for j := 1 to 6 do
  begin
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + CostosCortejo[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('CostosCortejo', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do  //Número de sustratos = 7
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizSustratos.Celda[i,j]);
  EscribeValor('MatrizSustratos', Lineas);
  Lineas.Clear;
  for i := 1 to 5 do  //Número de elementos dinámicos = 5
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizDinamicos.Celda[i,j]);
  EscribeValor('MatrizDinamicos', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizAgentes.Celda[i,j]);
  EscribeValor('MatrizAgentes', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do  //Número de sustratos = 7
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizSustratosA.Celda[i,j]);
  EscribeValor('MatrizSustratosA', Lineas);
  Lineas.Clear;
  for i := 1 to 5 do  //Número de elementos dinámicos = 5
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizDinamicosA.Celda[i,j]);
  EscribeValor('MatrizDinamicosA', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Lineas.Add(MatrizAgentesA.Celda[i,j]);
  EscribeValor('MatrizAgentesA', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do  //Número de sustratos = 7
  begin
    Linea := '';
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Linea := Linea + MatrizSustratosM.Celda[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('MatrizSustratosM', Lineas);
  Lineas.Clear;
  for i := 1 to 5 do  //Número de elementos dinámicos = 5
  begin
    Linea := '';
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Linea := Linea + MatrizDinamicosM.Celda[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('MatrizDinamicosM', Lineas);
  Lineas.Clear;
  for i := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
  begin
    Linea := '';
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Linea := Linea + MatrizAgentesM.Celda[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('MatrizAgentesM', Lineas);
  Lineas.Clear;
  for i := 1 to 14 do  //Número de conductas = 14
  begin
    Linea := '';
    for j := 1 to FNumEstadios + FNumPrototiposM + FNumPrototiposH do
      Linea := Linea + MatrizConductasM.Celda[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('MatrizConductasM', Lineas);
  Lineas.Clear;
  for j := 1 to 4 do
  begin
    Linea := '';
    for i := 1 to 5 do
      Linea := Linea + Metabolismo[i,j] + ',';
    Lineas.Add(Linea);
  end;
  EscribeValor('Metabolismo', Lineas);
  Lineas.Clear;
  for k := 1 to NumPrototiposM do
  begin
    for j := 1 to 2 do
    begin
      Linea := '';
      for i := 1 to 3 do
        Linea := Linea + FPrototiposM[k-1].Combate[i,j] + ',';
      Lineas.Add(Linea);
     end;
  end;
  EscribeValor('MatricesCombateM', Lineas);
  Lineas.Clear;
  for k := 1 to NumPrototiposM do
  begin
    for j := 1 to 3 do
    begin
      Linea := '';
      for i := 1 to 4 do
        Linea := Linea + FPrototiposM[k-1].Cortejo[i,j] + ',';
      Lineas.Add(Linea);
     end;
  end;
  EscribeValor('MatricesCortejoM', Lineas);
  Lineas.Clear;
  for k := 1 to NumPrototiposH do
  begin
    for j := 1 to 2 do
    begin
      Linea := '';
      for i := 1 to 3 do
        Linea := Linea + FPrototiposH[k-1].Combate[i,j] + ',';
      Lineas.Add(Linea);
     end;
  end;
  EscribeValor('MatricesCombateH', Lineas);
  Lineas.Clear;
  for k := 1 to NumPrototiposH do
  begin
    for j := 1 to 3 do
    begin
      Linea := '';
      for i := 1 to 4 do
        Linea := Linea + FPrototiposH[k-1].Cortejo[i,j] + ',';
      Lineas.Add(Linea);
     end;
  end;
  EscribeValor('MatricesCortejoH', Lineas);
  Lineas.Free;
  inherited Guarda(NombreArchivo);
end; //proc Guarda

procedure TJuegoAgentes.SetNumPrototiposH(const Value: Word);
begin
  if Value >= 1 then
  begin
    FNumPrototiposH := Value;
    SetLength(FPrototiposH, Value);
  end
  else
    raise EValorInvalido.Create('El tamaño mínimo permitido para el '
              + ' arreglo de prototipos es 1');
end;

procedure TJuegoAgentes.SetNumPrototiposM(const Value: Word);
begin
  if Value >= 1 then
  begin
    FNumPrototiposM := Value;
    SetLength(FPrototiposM, Value);
  end
  else
    raise EValorInvalido.Create('El tamaño mínimo permitido para el '
              + ' arreglo de prototipos es 1');
end;

function TJuegoAgentes.GetPrototiposM(w: Word): TPrototipo;
begin
  if (w > 0) and (w <= FNumPrototiposM) then
    Result := FPrototiposM[w-1]
  else
    raise EFueraDeRango.Create('Indice de protoipo fuera de los limites de '
                                + 'los limites del arreglo '
                                + 'MACHOS:' + IntToStr(W));
end;

procedure TJuegoAgentes.SetPrototiposM(w: Word; const Value: TPrototipo);
begin
  if (w > 0) and (w <= FNumPrototiposM) then
    FPrototiposM[w-1] := Value
  else
    raise EFueraDeRango.Create('El índice de prototipo solicitado está fuera de'
                                +' los límites del arreglo'
                                + 'Hembras:' + IntToStr(w));
end;

function TJuegoAgentes.GetPrototiposH(w: Word): TPrototipo;
begin
  if (w > 0) and (w <= FNumPrototiposH) then
    Result := FPrototiposH[w-1]
  else
    raise EFueraDeRango.Create('El índice de prototipo solicitado está fuera de'
                                +' los límites del arreglo');
end;

procedure TJuegoAgentes.SetPrototiposH(w: Word; const Value: TPrototipo);
begin
  if (w > 0) and (w <= FNumPrototiposH) then
    FPrototiposH[w-1] := Value
  else
    raise EFueraDeRango.Create('El índice de prototipo solicitado está fuera de'
                                +' los límites del arreglo');
end;

procedure TJuegoAgentes.SetNumEstadios(const Value: Word);
begin
  if Value >= 1 then
  begin
    FNumEstadios := Value;
    SetLength(FEstadios, Value);
  end
  else
    raise EValorInvalido.Create('El número mínimo de estadios es 1'
                                + ' [SetNumEstadios]');
end;

procedure TJuegoAgentes.InsertaPrototipo(Sexo: TSexo);
var
  i: Integer;
begin
  if Sexo = sxMacho then
  begin
    i := NumPrototiposM;
    NumPrototiposM := i + 1;
    SetLength(CriteriosM, 3, FNumPrototiposM);
  end
  else
  begin
    i := NumPrototiposH;
    NumPrototiposH := i + 1;
    SetLength(CriteriosH, 3, FNumPrototiposH);
  end;
  MatrizSustratos.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizDinamicos.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizAgentes.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizSustratosA.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizDinamicosA.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizAgentesA.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizSustratosM.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizDinamicosM.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizAgentesM.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  MatrizConductasM.Agrega(FNumEstadios, FNumPrototiposM, FNumPrototiposH, Sexo);
  if Sexo = sxMacho then
    for i := 1 to NumEstadios do
      if FEstadios[i-1].Prototipo >= NumPrototiposM then
        FEstadios[i-1].Prototipo := FEstadios[i-1].Prototipo + 1;
end;

procedure TJuegoAgentes.BorraPrototipo(Sexo: TSexo; Num: Word);
var
  i, j, k: Integer;
begin
  if Sexo = sxMacho then
  begin
    if NumPrototiposM = 1 then
      raise EValorInvalido.Create('Debe haber al menos un prototipo' +
                                  ' en el arreglo de prototipos M');
    if (Num > NumPrototiposM) or (Num = 0) then
      raise EFueraDeRango.Create('El índice solicitado está fuera de los'
                                  + ' límites del arreglo de prototipos');
    i := NumPrototiposM;
    if Num < NumPrototiposM then
      for j := Num - 1 to NumPrototiposM - 2 do
      begin
        PrototiposM[j] := PrototiposM[j+1];
        for k := 0 to 2 do
          CriteriosM[j,k] := CriteriosM[j+1,k];
      end;
    NumPrototiposM := i - 1;
    SetLength(CriteriosM, 3, i-1);
    MatrizSustratos.Retira(NumEstadios+Num);
    MatrizDinamicos.Retira(NumEstadios+Num);
    MatrizAgentes.Retira(NumEstadios+Num);
    MatrizSustratosA.Retira(NumEstadios+Num);
    MatrizDinamicosA.Retira(NumEstadios+Num);
    MatrizAgentesA.Retira(NumEstadios+Num);
    MatrizSustratosM.Retira(NumEstadios+Num);
    MatrizDinamicosM.Retira(NumEstadios+Num);
    MatrizAgentesM.Retira(NumEstadios+Num);
    MatrizConductasM.Retira(NumEstadios+Num);
  end
  else
  begin
    if NumPrototiposH = 1 then
      raise EValorInvalido.Create('Debe haber al menos un prototipo' +
                                  ' en el arreglo de prototipos H');
    if (Num > NumPrototiposH) or (Num = 0) then
      raise EFueraDeRango.Create('El índice solicitado está fuera de los'
                                  + ' límites del arreglo de prototipos');
    i := NumPrototiposH;
    if Num < NumPrototiposH then
      for j := Num - 1 to NumPrototiposH - 2 do
      begin
        PrototiposH[j] := PrototiposH[j+1];
        for k := 0 to 2 do
          CriteriosH[j,k] := CriteriosH[j+1,k];
      end;
    NumPrototiposH := i - 1;
    MatrizSustratos.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizDinamicos.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizAgentes.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizSustratosA.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizDinamicosA.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizAgentesA.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizSustratosM.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizDinamicosM.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizAgentesM.Retira(NumEstadios+NumPrototiposM+Num);
    MatrizConductasM.Retira(NumEstadios+NumPrototiposM+Num);
    Num := NumPrototiposM+Num;
  end;
  for i := 1 to NumEstadios do
  begin
    if FEstadios[i-1].Prototipo = Num then
      FEstadios[i-1].Prototipo := 0;
    if FEstadios[i-1].Prototipo > Num then
      FEstadios[i-1].Prototipo := FEstadios[i-1].Prototipo - 1;
  end;
end;

function TJuegoAgentes.GetEstadios(w: Word): TEstadio;
begin
  if (w > 0) and (w <= FNumEstadios) then
    Result := FEstadios[w-1]
  else
    raise EFueraDeRango.Create('El índice de estadio solicitado está fuera de'
                                +' los límites del arreglo [GetEstadio]');
end;

procedure TJuegoAgentes.SetEstadios(w: Word; const Value: TEstadio);
begin
  if (w > 0) and (w <= FNumEstadios) then
    FEstadios[w-1] := Value
  else
    raise EFueraDeRango.Create('El índice de estadio solicitado está fuera de'
                                +' los límites del arreglo [SetEstadio]');
end;

procedure TJuegoAgentes.InsertaEstadio;
var
  i: Integer;
begin
  i := NumEstadios;
  NumEstadios := i + 1;
  MatrizSustratos.AgregaEstadio(NumEstadios);
  MatrizDinamicos.AgregaEstadio(NumEstadios);
  MatrizAgentes.AgregaEstadio(NumEstadios);
  MatrizSustratosA.AgregaEstadio(NumEstadios);
  MatrizDinamicosA.AgregaEstadio(NumEstadios);
  MatrizAgentesA.AgregaEstadio(NumEstadios);
  MatrizSustratosM.AgregaEstadio(NumEstadios);
  MatrizDinamicosM.AgregaEstadio(NumEstadios);
  MatrizAgentesM.AgregaEstadio(NumEstadios);
  MatrizConductasM.AgregaEstadio(NumEstadios);
end;

procedure TJuegoAgentes.BorraEstadio(Num: Word);
var
  i, j: Integer;
begin
  if NumEstadios = 1 then
    raise EValorInvalido.Create('Debe haber al menos un estadio' +
                                ' en el arreglo [BorraEstadio]');
  if (Num > NumEstadios) or (Num = 0) then
    raise EFueraDeRango.Create('El índice solicitado está fuera de los'
                           + ' límites del arreglo de estadios [BorraEstadio]');
  i := NumEstadios;
  if Num < NumEstadios then
    for j := Num to NumEstadios - 1 do
      Estadios[j] := Estadios[j+1];
  NumEstadios := i - 1;
  MatrizSustratos.Retira(Num);
  MatrizDinamicos.Retira(Num);
  MatrizAgentes.Retira(Num);
  MatrizSustratosA.Retira(Num);
  MatrizDinamicosA.Retira(Num);
  MatrizAgentesA.Retira(Num);
  MatrizSustratosM.Retira(Num);
  MatrizDinamicosM.Retira(Num);
  MatrizAgentesM.Retira(Num);
  MatrizConductasM.Retira(Num);
end;

function TJuegoAgentes.Ligado(Num: Word): string;
{Regresa el nombre del prototipo ligado al estadio número Num}
begin
  if FEstadios[Num-1].Prototipo = 0 then
    Result := ''
  else
  begin
    if FEstadios[Num-1].Prototipo <= FNumPrototiposM then
      Result := FPrototiposM[FEstadios[Num-1].Prototipo-1].Nombre
    else
      Result :=
              FPrototiposH[FEstadios[Num-1].Prototipo-NumPrototiposM-1].Nombre;
  end;
end;

function TJuegoAgentes.NumeroPrototipo(Num: Word): Word;
{Considerando Num como el índice del prototipo dentro del listado
Estadios+Machos+Hembras, regresa el número del prototipo dentro del listado
de prototipos del mismo sexo, o bien de inmaduros}
begin
  if Num <= FNumEstadios then
    Result := Num
  else if Num <= FNumEstadios + FNumPrototiposM then
    Result := Num - FNumEstadios
  else if Num <= FNumEstadios + FNumPrototiposM + FNumPrototiposH then
    Result := Num - FNumEstadios - FNumPrototiposM
  else
    raise EValorInvalido.Create('Número de prototipo fuera de rango ' +
                          ' [NumeroPrototipo]');
end;

function TJuegoAgentes.SexoPrototipo(Num: Word): TSexo;
{Considerando Num como el índice del prototipo dentro del listado
Estadios+Machos+Hembras, regresa el sexo del prototipo, en caso de ser un
prototipo de inmaduro no ligado, regresa sxIndefinido}
begin
  if Num <= FNumEstadios then
  begin
    if Ligado(Num) = '' then
      Result := sxIndefinido
    else
      Result := SexoPrototipo(Estadios[Num].Prototipo+FNumEstadios);
  end
  else if Num <= FNumEstadios + FNumPrototiposM then
    Result := sxMacho
  else if Num <= FNumEstadios + FNumPrototiposM + FNumPrototiposH then
    Result := sxHembra
  else
    raise EValorInvalido.Create('Número de prototipo fuera de rango ' +
                          ' [SexoPrototipo]');
end;

{ TMatrizInteraccion }

procedure TMatrizInteraccion.Agrega(NumE, NumM, NumH: Word;
  Sexo: TSexo);
{Inserta un nuevo renglón en la matriz, si el sexo es macho recorre los
renglones para insertar un nuevo prototipo en medio de la matriz.}
var
  i, j : Integer;
begin
  FAlto := FAlto + 1;
  SetLength(Matriz, FAncho, FAlto);
  if Sexo = sxMacho then
    for j := (FAlto - 1) downto (NumE + NumM) do
      for i := 0 to FAncho - 1 do         //Recorrer renglones
        Matriz[i,j] := Matriz[i,j-1];
end;

procedure TMatrizInteraccion.AgregaEstadio(NumE: Word);
{Inserta un nuevo renglón en la matriz para un nuevo estadio}
var
  i, j: Integer;
begin
  FAlto := FAlto + 1;
  SetLength(Matriz, FAncho, FAlto);
  for j := (FAlto - 1) downto NumE do
    for i := 0 to FAncho - 1 do         //Recorrer renglones
      Matriz[i,j] := Matriz[i,j-1];
end;

constructor TMatrizInteraccion.Create(Ancho, Alto: Word);
begin
  SetLength(Matriz, Ancho, Alto);
  FAncho := Ancho;
  FAlto := Alto;
end;

function TMatrizInteraccion.GetCelda(X, Y: Word): string;
begin
  if ((X <= Ancho) and (Y <= Alto)) and ((X > 0) and (Y > 0)) then
    Result := Matriz[X-1,Y-1]
  else
    raise EFueraDeRango.Create('La celda solicitada está fuera de la matriz');
end;

procedure TMatrizInteraccion.Retira(Num: Word);
{Elimina el renglón Num de la matriz}
var
  i, j: Integer;
begin
  if Num > FAlto then
    raise EValorInvalido.Create('El renglón especificado está fuera de la '
                                + 'matriz (TMatrizInteraccion.Retira)');
  FAlto := FAlto - 1;
  for j := (Num - 1) to (FAlto - 1) do
    for i := 0 to FAncho - 1 do       //Recorrer renglones
      Matriz[i,j] := Matriz[i,j+1];
  SetLength(Matriz, FAncho, FAlto);
end;

procedure TMatrizInteraccion.SetCelda(X, Y: Word; const Value: string);
begin
  if ((X <= Ancho) and (Y <= Alto)) and ((X > 0) and (Y > 0)) then
    Matriz[X-1,Y-1] := Value
  else
    raise EFueraDeRango.Create('La celda especificada está fuera de la matriz');
end;

{ TMatrizInteraccionAgentes }

procedure TMatrizInteraccionAgentes.Agrega(NumE, NumM, NumH: Word;
  Sexo: TSexo);
{Inserta una nueva columna en la matriz, si el sexo es macho recorre las
columnas para insertar un nuevo prototipo en medio de la matriz.}
var
  i, j : Integer;
begin
  inherited Agrega(NumE, NumM, NumH,Sexo);
  FAncho := FAncho + 1;
  SetLength(Matriz, FAncho, FAlto);
  if Sexo = sxMacho then
    for i := (FAncho - 1) downto (NumE + NumM) do
      for j := 0 to FAlto - 1 do         //Recorrer columnas
        Matriz[i,j] := Matriz[i-1,j];
end;

procedure TMatrizInteraccionAgentes.AgregaEstadio(NumE: Word);
var
  i,j : Integer;
begin
  inherited AgregaEstadio(NumE);
  FAncho := FAncho + 1;
  SetLength(Matriz, FAncho, FAlto);
  for i := (FAncho - 1) downto (NumE) do
    for j := 0 to FAlto - 1 do         //Recorrer columnas
      Matriz[i,j] := Matriz[i-1,j];
end;

procedure TMatrizInteraccionAgentes.Retira(Num: Word);
{Elimina la columna Num columna de la matriz}
var
  i, j: Integer;
begin
  inherited Retira(Num);
  if Num > FAncho then
    raise EValorInvalido.Create('La columna especificada está fuera de la '
                                + 'matriz (TMatrizInteraccionAgentes.Retira)');
  FAncho := FAncho - 1;
  for i := (Num - 1) to (FAncho - 1) do
    for j := 0 to FAlto - 1 do       //Recorrer columnas
      Matriz[i,j] := Matriz[i+1,j];
  SetLength(Matriz, FAncho, FAlto);
end;

end.
