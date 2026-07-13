unit Entornos;

{$MODE Delphi}

interface

uses
  {ExtCtrls, Graphics,} Classes, Comunes, Escenarios, Sustratos, JuegoAgentes,
  SysUtils, Elementos, Agentes;

type

  TEventoDibujaEscenario = procedure (Sender: TObject) of object;
  TEventoDibujaElemento = procedure (Sender: TObject; XFisica, YFisica,
      CuadroFisico: Word) of object;


   {Clases}

  TEntorno = class(TGuardable)
  protected
    //Plataforma: TPaintBox;
  private
    Escenario: TEscenario;
    FAnchura: Word;
    FAltura: Word;
    FOnDibujaAgente: TEventoDibujaElemento;
    FOnDibujaDinamico: TEventoDibujaElemento;
    FOnDibujaEscenario: TEventoDibujaEscenario;
    function GetCuadricula: Boolean;
    function GetDesplazamientoX: Integer;
    function GetDesplazamientoY: Integer;
    function GetPorcentaje: Word;
    function GetCuadro(X, Y: Word): TCuadro;
    function GetNombreSustratos(i: Word): string;
    function GetMixtos(i: Integer): TSustratoMixto;
    procedure CargaEscenario;
    procedure CargaJuego;
    procedure GuardaEscenario;
    procedure GuardaJuego;
    procedure SetCuadricula(const Value: Boolean);
    procedure SetDesplazamientoX(const Value: Integer);
    procedure SetDesplazamientoY(const Value: Integer);
    procedure SetPorcentaje(const Value: Word);
    function GetSimples(i: Word): TSustratoSimple;
  public
    Juego: TJuegoAgentes;
    Titulo: string[80];
    Comentarios: string;
    Ciclos: Integer;
    ListaAgentes: TListaAgentes;
    ListaDinamicos: TListaDinamicos;
    ListaOviposicion: TListaOviposicion;
    ListaHuevos: TListaHuevos;
    function AlturaFisica: Word;
    function AnchuraFisica: Word;
    function XLogica(X: Integer): Integer;
    function YLogica(Y: Integer): Integer;
    function XFisica(X: Integer): Integer;
    function YFisica(Y: Integer): Integer;
    function CuadroFisico: Word;
    function NumAgentesEn(X, Y: Word): Word; overload;
    function NumDinamicosEn(X, Y: Word): Word; overload;
    function NumOviposicionEn(X, Y: Word): Word; overload;
    function NumAgentesEn(X1, Y1, X2, Y2: Word): Word; overload;
    function NumDinamicosEn(X1, Y1, X2, Y2: Word): Word; overload;
    function NumOviposicionEn(X1, Y1, X2,  Y2: Word): Word; overload;
    function NumElementosEn(X, Y: Word): Word;
    function HaySustratoEn(X, Y: Word; Sustrato: TCuadro): Boolean;
    function NumSustratosMixtos: Word;
    function DinamicoContiguo(Agente: TAgente; TipoED: Word): TDinamico;
    function AgenteAdultoContiguo(Agente: TAgente): TAgente;
    function AgenteAdultoSexoOpuestoContiguo(Agente: TAgente): TAgente;
    constructor Create;//(PPlataforma: TPaintBox);
    destructor Destroy; override;
    procedure Guarda(NombreArchivo: string); override;
    procedure Carga(NombreArchivo: string); override;
    procedure Despliega;
    procedure DespliegaEscenario;
    procedure ImportaEscenario(NombreArchivo: string);
    procedure ImportaJuego(NombreArchivo: string);
    procedure ExportaEscenario(NombreArchivo: string);
    procedure ExportaJuego(NombreArchivo: string);
    procedure ElementosEn(X, Y: Word;
                          var Agentes: array of TAgente;
                          var Dinamicos: array of TDinamico;
                          var Oviposicion: array of TSitioOviposicion);overload;
    procedure ElementosEn(X1, Y1, X2, Y2: Word;
                          var Agentes: array of TAgente;
                          var Dinamicos: array of TDinamico;
                          var Oviposicion: array of TSitioOviposicion);overload;
    property Cuadricula: Boolean
      read GetCuadricula write SetCuadricula;
    property DesplazamientoX: Integer
      read GetDesplazamientoX write SetDesplazamientoX;
    property DesplazamientoY: Integer
      read GetDesplazamientoY write SetDesplazamientoY;
    property Porcentaje: Word
      read GetPorcentaje write SetPorcentaje;
    property Altura: Word
      read FAltura;
    property Anchura: Word
      read FAnchura;
    property Cuadro[X, Y: Word]: TCuadro
      read GetCuadro;
    property NombreSustratos[i: Word]: string
      read GetNombreSustratos;
    property Simples[i: Word]: TSustratoSimple
      read GetSimples;
    property Mixtos[i: Integer]: TSustratoMixto
      read GetMixtos;
    property OnDibujaEscenario: TEventoDibujaEscenario
        read FOnDibujaEscenario write FOnDibujaEscenario;
    property OnDibujaDinamico: TEventoDibujaElemento
        read FOnDibujaDinamico write FOnDibujaDinamico;
    property OnDibujaAgente: TEventoDibujaElemento
        read FOnDibujaAgente write FOnDibujaAgente;
  end;

const
  NombreConductas: array [1..16] of string = ('Movement', 'Rest', 'Drink',
      'EatSugar', 'EatFat', 'EatProtein', 'Display', 'Escalate', 'Retreat',
      'DisplayAttemp', 'EscalateAttemp', 'Receptiveness', 'Reject', 'Copulate',
      'Oviposition', 'WonFight');

implementation

uses
  FuncElementosCadenas;

{ TEntorno }

constructor TEntorno.Create;//(PPlataforma: TPaintBox);
begin
  //Plataforma := PPlataforma;
  Escenario := TEscenario.Create;//(PPlataforma);
  Juego := TJuegoAgentes.Create;
  ListaAgentes := TListaAgentes.Create;
  ListaDinamicos := TListaDinamicos.Create;
  ListaOviposicion := TListaOviposicion.Create;
  ListaHuevos := TListaHuevos.Create;
  Cuadricula := True;
end;

procedure TEntorno.Carga(NombreArchivo: string);
var
  ListaAgentesConGametos,
  ListaHembrasConPaquetes,
  ListaHembrasConHuevos,
  Lineas : TStringList;
  s,
  sPadre,
  sMadre,
  sPortador,
  Linea  : string;
  i, j, k, l: Integer;
  vReservas: TReservas;
  Paquete: TPaqEspermatico;
  Oviposicion: TSitioOviposicion;
  Dinamico: TDinamico;
  Agente: TAgente;
  Huevo: THuevo;
  PEstadio,
  PPrototipo,
  PEdad: Word;
  PSexo: TSexo;
  ListaInteracciones: array of string;
  MorfoGenCont: array [1..15] of Real;
  MorfoGenDisc: array [1..15] of Integer;
begin
  inherited Carga(NombreArchivo);
  ListaAgentesConGametos := TStringList.Create;
  ListaHembrasConPaquetes := TStringList.Create;
  ListaHembrasConHuevos := TStringList.Create;
  Titulo := LeeValor('Titulo');
  Lineas := LeeValorAmpliado('Comentarios');
  Ciclos := LeeValorEntero('Ciclos');
  Comentarios := Lineas.Text;
  CargaEscenario;
  CargaJuego;
  for i := 1 to 7 do  //Num sustratos = 7
    Juego.Sustratos[i] := Escenario.JuegoSustratos.SustratoSimple[i].Nombre;
  Lineas := LeeValorAmpliado('Agentes');
  for i := 1 to LeeValorEntero('NumAgentes')  do
  begin
    Agente := TAgente.Create;//(Plataforma);
    Agente.OnDibuja := FOnDibujaAgente;
    Linea := Lineas.Strings[i-1];
    with Agente do
    begin
      Nombre := ObtenNsimo(Linea, 1);
      sPadre := ObtenNsimo(Linea, 2);
      sMadre := ObtenNsimo(Linea, 3);
      X := StrToInt(ObtenNsimo(Linea, 4));
      Y :=  StrToInt(ObtenNsimo(Linea, 5));
      PEstadio := StrToInt(ObtenNsimo(Linea, 6));
      PPrototipo := StrToInt(ObtenNsimo(Linea, 7));
      if ObtenNsimo(Linea, 8) = 'M' then
        PSexo := sxMacho
      else if ObtenNsimo(Linea, 8) = 'H' then
        PSexo := sxHembra
      else
        PSexo := sxIndefinido;
      Tiempo.EstadioActual := StrToInt(ObtenNsimo(Linea, 9));
      Tiempo.SustratoActual := StrToInt(ObtenNsimo(Linea, 10));
      Tiempo.InteraccionActual := StrToInt(ObtenNsimo(Linea, 11));
      PEdad := StrToInt(ObtenNsimo(Linea, 12));
      Inicializa(Juego, sPadre, sMadre, PEstadio, PPrototipo, PEdad, PSexo);
      if Adulto then
      begin
        case Sexo of
          sxMacho : Color := Juego.PrototiposM[Prototipo].Color;
          sxHembra: Color := Juego.PrototiposH[Prototipo].Color;
        end
      end
      else
        Color := Juego.Estadios[Estadio].Color;
      Direccion := NumADireccion(StrToInt(ObtenNsimo(Linea, 13)));
      Reservas.Agua := StrToInt(ObtenNsimo(Linea, 14));
      Reservas.Azucar := StrToInt(ObtenNsimo(Linea, 15));
      Reservas.Grasa := StrToInt(ObtenNsimo(Linea, 16));
      Reservas.Proteina := StrToInt(ObtenNsimo(Linea, 17));
      if StrToInt(ObtenNsimo(Linea, 18)) > 0 then //Cantidad de gametos
        ListaAgentesConGametos.Add(Nombre);
      if StrToInt(ObtenNsimo(Linea, 20)) > 0 then //Cantidad de huevos
        ListaHembrasConHuevos.Add(Nombre);
      if StrToInt(ObtenNsimo(Linea, 22)) > 0 then //Cant de paquetes almacenados
        ListaHembrasConPaquetes.Add(Nombre);
      k := 23;  //Apuntador de lectura sobre Linea
      j := 1;
      repeat
        if ObtenNsimo(Linea, k) = 'D' then
          Genotipo.PatContinuos[j].Cualidad := cdDominante
        else
          Genotipo.PatContinuos[j].Cualidad := cdRecesivo;
        Genotipo.PatContinuos[j].Valor := StrToFloat(ObtenNsimo(Linea, k + 1));
        if ObtenNsimo(Linea, k + 2) = 'D' then
          Genotipo.MatContinuos[j].Cualidad := cdDominante
        else
          Genotipo.MatContinuos[j].Cualidad := cdRecesivo;
        Genotipo.MatContinuos[j].Valor := StrToFloat(ObtenNsimo(Linea, k + 3));
        Inc(k, 4);
        Inc(j);
      until j = 16;
      j := 1;
      repeat
        if ObtenNsimo(Linea, k) = 'D' then
          Genotipo.PatDiscretos[j].Cualidad := cdDominante
        else
          Genotipo.PatDiscretos[j].Cualidad := cdRecesivo;
        Genotipo.PatDiscretos[j].Valor := StrToInt(ObtenNsimo(Linea, k + 1));
        if ObtenNsimo(Linea, k + 2) = 'D' then
          Genotipo.MatDiscretos[j].Cualidad := cdDominante
        else
          Genotipo.MatDiscretos[j].Cualidad := cdRecesivo;
        Genotipo.MatDiscretos[j].Valor := StrToInt(ObtenNsimo(Linea, k + 3));
        Inc(k, 4);
        Inc(j);
      until j = 16;
      j := 1;
      repeat
        Memoria.UltConductas[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumConductas[j] := StrToInt(ObtenNsimo(Linea, k + 1));
        Inc(k, 2);
        Inc(j);
      until j = 17;
      j := 1;
      repeat
        Memoria.UltPerSust[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumPerSust[j] := StrToInt(ObtenNsimo(Linea, k + 1));
        Inc(k, 2);
        Inc(j);
      until j = 8;
      j := 1;
      repeat
        Memoria.UltIntDin[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumIntDin[j] := StrToInt(ObtenNsimo(Linea, k + 1));
        Inc(k, 2);
        Inc(j);
      until j = 6;
      j := 0;
      repeat
        Memoria.UltIntEstadios[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumIntEstadios[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumEstadios;
      j := 0;
      repeat
        Memoria.UltIntMachos[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumIntMachos[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumPrototiposM;
      j := 0;
      repeat
        Memoria.UltIntHembras[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumIntHembras[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumPrototiposH;
      j := 1;
      repeat
        Memoria.UltPerDin[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumPerDin[j] := StrToInt(ObtenNsimo(Linea, k + 1));
        Inc(k, 2);
        Inc(j);
      until j = 6;
      j := 0;
      repeat
        Memoria.UltPerEstadios[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumPerEstadios[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumEstadios;
      j := 0;
      repeat
        Memoria.UltPerMachos[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumPerMachos[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumPrototiposM;
      j := 0;
      repeat
        Memoria.UltPerHembras[j] := StrToInt(ObtenNsimo(Linea, k));
        Memoria.NumPerHembras[j] := StrToInt(ObtenNsimo(Linea, k +1));
        Inc(k, 2);
        Inc(j);
      until j = Juego.NumPrototiposH;
      Memoria.UltAccionContendiente := StrToInt(ObtenNsimo(Linea,k));
      if ObtenNsimo(Linea, k+1) <> '' then
      begin
        SetLength(ListaInteracciones, Length(ListaInteracciones) + 1);
        ListaInteracciones[Length(ListaInteracciones)-1] :=
          Nombre + ',' + ObtenNsimo(Linea, k+1)
          + ', '  + ObtenNsimo(Linea, k+2);
      end;
      if  ObtenNsimo(Linea, k+3) = 'Reg' then
        ForzarSituacion(stRegular)
      else if  ObtenNsimo(Linea, k+3) = 'Com' then
        ForzarSituacion(stCombate)
      else if  ObtenNsimo(Linea, k+3) = 'Cor' then
        ForzarSituacion(stCortejo);
      k := k + 4;
      if ObtenNsimo(Linea, k) = 'F' then //Valores congénitos fijados
      begin
        for j := 1 to 15 do
          MorfoGenCont[j] := StrToFloat(ObtenNsimo(Linea, k + j));
        k := k + 15;
        for j := 1 to 15 do
          MorfoGenDisc[j] := StrToInt(ObtenNsimo(Linea, k + j));
        FijaMorfologia(MorfoGenCont, MorfoGenDisc);
      end;
    end;  //with agente
    ListaAgentes.Agrega(Agente);
  end;  //for Agentes
  for i := 0 to ListaAgentesConGametos.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaAgentesConGametos[i]];
    Lineas  := LeeValorAmpliado('Gametos:' + Agente.Nombre);
    for j := 1 to Lineas.Count do
    begin
      Linea := Lineas.Strings[j-1];
      vReservas.Agua     := StrToInt(ObtenNsimo(Linea, 1));
      vReservas.Azucar   := StrToInt(ObtenNsimo(Linea, 2));
      vReservas.Grasa    := StrToInt(ObtenNsimo(Linea, 3));
      vReservas.Proteina := StrToInt(ObtenNsimo(Linea, 4));
      Agente.Gonada.Agrega(vReservas);
    end;
  end;
  for i := 0 to ListaHembrasConPaquetes.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaHembrasConPaquetes[i]];
    Lineas  :=
        LeeValorAmpliado('PaquetesEspermaticos:' + Agente.Nombre);
    for j := 1 to Lineas.Count do
    begin
      Linea := Lineas.Strings[j-1];
      with Paquete do
      begin
        Donador    :=          ObtenNsimo(Linea, 1);
        Paternidad := StrToInt(ObtenNsimo(Linea, 2));
        Reservas.Agua     := StrToInt(ObtenNsimo(Linea, 3));
        Reservas.Azucar   := StrToInt(ObtenNsimo(Linea, 4));
        Reservas.Grasa    := StrToInt(ObtenNsimo(Linea, 5));
        Reservas.Proteina := StrToInt(ObtenNsimo(Linea, 6));
        k := 7;  //Apuntador de lectura sobre Linea
        l := 1;
        repeat
          if ObtenNsimo(Linea, k) = 'D' then
            Genotipo.PatContinuos[l].Cualidad := cdDominante
          else
            Genotipo.PatContinuos[l].Cualidad := cdRecesivo;
          Genotipo.PatContinuos[l].Valor :=
              StrToFloat(ObtenNsimo(Linea, k + 1));
          if ObtenNsimo(Linea, k + 2) = 'D' then
            Genotipo.MatContinuos[l].Cualidad := cdDominante
          else
            Genotipo.MatContinuos[l].Cualidad := cdRecesivo;
          Genotipo.MatContinuos[l].Valor :=
            StrToFloat(ObtenNsimo(Linea, k + 3));
          Inc(k, 4);
          Inc(l);
          until l = 16;
          l := 1;
          repeat
          if ObtenNsimo(Linea, k) = 'D' then
           Genotipo.PatDiscretos[l].Cualidad := cdDominante
          else
            Genotipo.PatDiscretos[l].Cualidad := cdRecesivo;
          Genotipo.PatDiscretos[l].Valor :=
             StrToInt(ObtenNsimo(Linea, k + 1));
          if ObtenNsimo(Linea, k + 2) = 'D' then
            Genotipo.MatDiscretos[l].Cualidad := cdDominante
          else
            Genotipo.MatDiscretos[l].Cualidad := cdRecesivo;
          Genotipo.MatDiscretos[l].Valor :=
            StrToInt(ObtenNsimo(Linea, k + 3));
          Inc(k, 4);
          Inc(l);
        until l = 16;
      end;  //with Paquete
      Agente.Espermateca.Agrega(Paquete);
    end;
  end;  //for ListahembrasConPaquetes
  for i := 0 to ListaHembrasConHuevos.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaHembrasConHuevos[i]];
    Lineas  :=
        LeeValorAmpliado('HuevosFertilizados:' + Agente.Nombre);
    for j := 1 to Lineas.Count do
    begin
      Linea := Lineas.Strings[j-1];
      Huevo := THuevo.Create;//(Plataforma);
      with Huevo do
      begin
        Nombre := ObtenNsimo(Linea, 1);
        sPadre := ObtenNsimo(Linea, 2);
        sMadre := ObtenNsimo(Linea, 3);
        if ObtenNsimo(Linea, 4) = 'M' then
          PSexo := sxMacho
        else if ObtenNsimo(Linea, 4) = 'H' then
          PSexo := sxHembra
        else
          PSexo := sxIndefinido;
        Inicializa(sPadre, sMadre, PSexo);
        Reservas.Agua := StrToInt(ObtenNsimo(Linea, 5));
        Reservas.Azucar := StrToInt(ObtenNsimo(Linea, 6));
        Reservas.Grasa := StrToInt(ObtenNsimo(Linea, 7));
        Reservas.Proteina := StrToInt(ObtenNsimo(Linea, 8));
        k := 9;  //Apuntador de lectura sobre Linea
        l := 1;
        repeat
          if ObtenNsimo(Linea, k) = 'D' then
            Genotipo.PatContinuos[l].Cualidad := cdDominante
          else
            Genotipo.PatContinuos[l].Cualidad := cdRecesivo;
          Genotipo.PatContinuos[l].Valor := StrToFloat(ObtenNsimo(Linea, k + 1));
          if ObtenNsimo(Linea, k + 2) = 'D' then
            Genotipo.MatContinuos[l].Cualidad := cdDominante
          else
            Genotipo.MatContinuos[l].Cualidad := cdRecesivo;
          Genotipo.MatContinuos[l].Valor := StrToFloat(ObtenNsimo(Linea, k + 3));
          Inc(k, 4);
          Inc(l);
        until l = 16;
        l := 1;
        repeat
          if ObtenNsimo(Linea, k) = 'D' then
            Genotipo.PatDiscretos[l].Cualidad := cdDominante
          else
            Genotipo.PatDiscretos[l].Cualidad := cdRecesivo;
          Genotipo.PatDiscretos[l].Valor := StrToInt(ObtenNsimo(Linea, k + 1));
          if ObtenNsimo(Linea, k + 2) = 'D' then
            Genotipo.MatDiscretos[l].Cualidad := cdDominante
          else
            Genotipo.MatDiscretos[l].Cualidad := cdRecesivo;
          Genotipo.MatDiscretos[l].Valor := StrToInt(ObtenNsimo(Linea, k + 3));
          Inc(k, 4);
          Inc(l);
        until l = 16;
      end;  //with Huevo
      Agente.Fertilizados.Agrega(Huevo);
    end;
  end;  //for ListahembrasConHuevos
  Lineas := LeeValorAmpliado('ElementosDinamicos');
  for i := 1 to LeeValorEntero('NumElementosDinamicos') do
  begin
    Dinamico := TDinamico.Create;//(Plataforma);
    Dinamico.OnDibuja := FOnDibujaDinamico;
    with Dinamico do
    begin
      Linea := Lineas.Strings[i-1];
      s := ObtenNsimo(Linea, 1);
      if s = 'FntAgua' then
        TipoED := edFntAgua
      else if s = 'FntGrasa' then
        TipoED := edFntGrasa
      else if s = 'FntAzucar' then
        TipoED := edFntAzucar
      else if s = 'FntProteina' then
        TipoED := edFntProteina;
      Nombre := ObtenNsimo(Linea, 2);
      X := StrToInt(ObtenNsimo(Linea, 3));
      Y := StrToInt(ObtenNsimo(Linea, 4));
      Calidad := StrToInt(ObtenNsimo(Linea, 5));
      Maximo := StrToInt(ObtenNsimo(Linea, 7));
      Nivel := StrToInt(ObtenNsimo(Linea, 6));
      Tasa := StrToFloat(ObtenNsimo(Linea, 8));
    end;  //with
    ListaDinamicos.Agrega(Dinamico);
  end;  //for
  Lineas := LeeValorAmpliado('SitiosOviposicion');
  for i := 1 to LeeValorEntero('NumSitiosOviposicion') do
  begin
    Oviposicion := TSitioOviposicion.Create;//(Plataforma);
    Oviposicion.OnDibuja := FOnDibujaDinamico;
    with Oviposicion do
    begin
      Linea := Lineas.Strings[i-1];
      Nombre := ObtenNsimo(Linea, 1);
      X := StrToInt(ObtenNsimo(Linea, 2));
      Y := StrToInt(ObtenNsimo(Linea, 3));
      Calidad := StrToInt(ObtenNsimo(Linea, 4));
      //Nivel := StrToInt(ObtenNsimo(Linea, 5));
      Maximo := StrToInt(ObtenNsimo(Linea, 6));
    end;  //with
    ListaOviposicion.Agrega(Oviposicion);
  end;  //for
  Lineas := LeeValorAmpliado('Huevos');
  for i := 1 to LeeValorEntero('NumHuevos')  do
  begin
    Huevo := THuevo.Create;//(Plataforma);
    Linea := Lineas.Strings[i-1];
    with Huevo do
    begin
      Nombre := ObtenNsimo(Linea, 1);
      sPadre := ObtenNsimo(Linea, 2);
      sMadre := ObtenNsimo(Linea, 3);
      sPortador := ObtenNsimo(Linea, 4);
      if ObtenNsimo(Linea, 5) = 'M' then
        PSexo := sxMacho
      else if ObtenNsimo(Linea, 5) = 'H' then
        PSexo := sxHembra
      else
        PSexo := sxIndefinido;
      PEdad := StrToInt(ObtenNsimo(Linea, 6));
      Agente := ListaAgentes.ElementosPorNombre[sPortador];
      if Assigned(Agente) then
        Inicializa(sPadre, sMadre, Agente, PEdad, PSexo)
      else
      begin
        Oviposicion := ListaOviposicion.ElementosPorNombre[sPortador];
        Inicializa(sPadre, sMadre, Oviposicion, PEdad, PSexo);
      end;
      Reservas.Agua := StrToInt(ObtenNsimo(Linea, 7));
      Reservas.Azucar := StrToInt(ObtenNsimo(Linea, 8));
      Reservas.Grasa := StrToInt(ObtenNsimo(Linea, 9));
      Reservas.Proteina := StrToInt(ObtenNsimo(Linea, 10));
      k := 11;  //Apuntador de lectura sobre Linea
      j := 1;
      repeat
        if ObtenNsimo(Linea, k) = 'D' then
          Genotipo.PatContinuos[j].Cualidad := cdDominante
        else
          Genotipo.PatContinuos[j].Cualidad := cdRecesivo;
        Genotipo.PatContinuos[j].Valor := StrToFloat(ObtenNsimo(Linea, k + 1));
        if ObtenNsimo(Linea, k + 2) = 'D' then
          Genotipo.MatContinuos[j].Cualidad := cdDominante
        else
          Genotipo.MatContinuos[j].Cualidad := cdRecesivo;
        Genotipo.MatContinuos[j].Valor := StrToFloat(ObtenNsimo(Linea, k + 3));
        Inc(k, 4);
        Inc(j);
      until j = 16;
      j := 1;
      repeat
        if ObtenNsimo(Linea, k) = 'D' then
          Genotipo.PatDiscretos[j].Cualidad := cdDominante
        else
          Genotipo.PatDiscretos[j].Cualidad := cdRecesivo;
        Genotipo.PatDiscretos[j].Valor := StrToInt(ObtenNsimo(Linea, k + 1));
        if ObtenNsimo(Linea, k + 2) = 'D' then
          Genotipo.MatDiscretos[j].Cualidad := cdDominante
        else
          Genotipo.MatDiscretos[j].Cualidad := cdRecesivo;
        Genotipo.MatDiscretos[j].Valor := StrToInt(ObtenNsimo(Linea, k + 3));
        Inc(k, 4);
        Inc(j);
      until j = 16;
    end;  //with Huevo
    ListaHuevos.Agrega(Huevo);
  end;  //for
  Lineas.Free;
  for i := 0 to Length(ListaInteracciones) - 1 do
  begin
    Agente :=
        ListaAgentes.ElementosPorNombre[ObtenNsimo(ListaInteracciones[i], 1)];
    if ObtenNsimo(ListaInteracciones[i],2) = 'Ag' then
      Agente.Interactuante :=
          ListaAgentes.ElementosPorNombre[ObtenNsimo(ListaInteracciones[i], 3)]
    else if ObtenNsimo(ListaInteracciones[i],2) = 'SO' then
      Agente.Interactuante := ListaOviposicion.ElementosPorNombre
          [ObtenNsimo(ListaInteracciones[i], 3)]
    else if ObtenNsimo(ListaInteracciones[i],2) = 'ED' then
      Agente.Interactuante := ListaDinamicos.ElementosPorNombre
          [ObtenNsimo(ListaInteracciones[i], 3)];
  end;
  ListaAgentesConGametos.Free;
  ListaHembrasConPaquetes.Free;
  ListaHembrasConHuevos.Free;
end;

procedure TEntorno.Guarda(NombreArchivo: string);
var
  ListaAgentesConGametos,
  ListaHembrasConPaquetes,
  ListaHembrasConHuevos,
  Lineas : TStringList;
  i, j   : Integer;
  Agente : TAgente;
begin
  ListaAgentesConGametos := TStringList.Create;
  ListaHembrasConPaquetes := TStringList.Create;
  ListaHembrasConHuevos := TStringList.Create;
  Lineas := TStringList.Create;
  Reestablece;
  EscribeValor('Titulo', Titulo);
  EscribeValor('Ciclos', Ciclos);
  EscribeValor('NumAgentes', ListaAgentes.Contador);
  EscribeValor('NumElementosDinamicos', ListaDinamicos.Contador);
  EscribeValor('NumSitiosOviposicion', ListaOviposicion.Contador);
  EscribeValor('NumHuevos', ListaHuevos.Contador);
  Lineas.Text := Comentarios;
  EscribeValor('Comentarios', Lineas);
  GuardaEscenario;
  GuardaJuego;
  Lineas.Clear;
  for i := 1 to ListaAgentes.Contador do
  begin
    Agente := ListaAgentes.Elementos[i];
    with Agente do
    begin
      if Gonada.Contador > 0 then
        ListaAgentesCongametos.Add(Nombre);
      if Espermateca.Contador > 0 then
        ListaHembrasConPaquetes.Add(Nombre);
      if Fertilizados.Contador > 0 then
        ListaHembrasConHuevos.Add(Nombre);
    end;  //with Agente
    Lineas.Add(AgenteAString(Agente, Juego));
  end;  //for ListaAgentes.Contador
  EscribeValor('Agentes', Lineas);
  Lineas.Clear;
  for i := 0 to ListaAgentesCongametos.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaAgentesConGametos[i]];
    Lineas.Clear;
    for j := 1 to Agente.Gonada.Contador do
      Lineas.Add(ReservasAString(Agente.Gonada.Elementos[j]));
    EscribeValor('Gametos:' + Agente.Nombre, Lineas);
  end;
  for i := 0 to ListaHembrasConPaquetes.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaHembrasConPaquetes[i]];
    Lineas.Clear;
    for j := 1 to Agente.Espermateca.Contador do
      Lineas.Add(PaqueteEspermaticoAString(Agente.Espermateca.Elementos[j]));
    EscribeValor('PaquetesEspermaticos:' + Agente.Nombre, Lineas);
  end;
  for i := 0 to ListaHembrasConHuevos.Count - 1 do
  begin
    Agente := ListaAgentes.ElementosPorNombre[ListaHembrasConHuevos[i]];
    Lineas.Clear;
    for j := 1 to Agente.Fertilizados.Contador do
      Lineas.Add(HuevoFertilizadoAString(Agente.Fertilizados.Elementos[j]));
    EscribeValor('HuevosFertilizados:' + Agente.Nombre, Lineas);
  end;
  Lineas.Clear;
  for i := 1 to ListaDinamicos.Contador do
    Lineas.Add(ElementoDinamicoAString(ListaDinamicos.Elementos[i]));
  EscribeValor('ElementosDinamicos', Lineas);
  Lineas.Clear;
  for i := 1 to ListaOviposicion.Contador do
    Lineas.Add(SitOviposicionAString(ListaOviposicion.Elementos[i]));
  EscribeValor('SitiosOviposicion', Lineas);
  Lineas.Clear;
  for i := 1 to ListaHuevos.Contador do
    Lineas.Add(HuevoOvipositadoAString(ListaHuevos.Elementos[i]));
  EscribeValor('Huevos', Lineas);
  Lineas.Free;
  ListaAgentesConGametos.Free;
  ListaHembrasConPaquetes.Free;
  ListaHembrasConHuevos.Free;
  inherited Guarda(NombreArchivo);
end;  //proc Guarda

procedure TEntorno.Despliega;
var
  i: Integer;
begin
  //Escenario.OnDibuja := FOnDibujaEscenario;
  Escenario.Despliega;
  for i := 1 to ListaAgentes.Contador do
    with ListaAgentes.Elementos[i] do
      Dibuja(XFisica(X), YFisica(Y), CuadroFisico);
  for i := 1 to ListaDinamicos.Contador do
    with ListaDinamicos.Elementos[i] do
      Dibuja(XFisica(X), YFisica(Y), CuadroFisico);
  for i := 1 to ListaOviposicion.Contador do
    with ListaOviposicion.Elementos[i] do
      Dibuja(XFisica(X), YFisica(Y), CuadroFisico);
end;

function TEntorno.AlturaFisica: Word;
begin
  Result := Escenario.AlturaFisica;
end;

function TEntorno.AnchuraFisica: Word;
begin
  Result := Escenario.AnchuraFisica;
end;

procedure TEntorno.CargaEscenario;
var
  Lineas     : TStringList;
  i, j       : Integer;
  s,
  Linea,
  Caracter   : string;
  Simple     : TSustratoSimple;
  Mixto      : TSustratoMixto;
begin
  with Escenario do
  begin
    OnDibuja := FOnDibujaEscenario;
    Anchura := Self.LeeValorEntero('Anchura');
    Altura := Self.LeeValorEntero('Altura');
    JuegoSustratos.NumMixtos := Self.LeeValorEntero('NumSustratosMixtos');
    Lineas := Self.LeeValorAmpliado('SustratosSimples');
    i := 0;
    repeat
      Inc(i);
      j := i * 2;
      Simple.Nombre := Lineas.Strings[j-2];
      s := Lineas.Strings[j-1];
      Simple.Color := StrToInt(s);
      JuegoSustratos.SustratoSimple[i] := Simple;
    until i = 7;
    Lineas := Self.LeeValorAmpliado('SustratosMixtos');
    for i := 1 to JuegoSustratos.NumMixtos do
    begin
      Linea := Lineas.Strings[i-1];
      s := Copy(Linea, 1, 3);
      Mixto.Porcentajes[1] := StrToInt(s);
      s := Copy(Linea, 4, 3);
      Mixto.Porcentajes[2] := StrToInt(s);
      s := Copy(Linea, 7, 3);
      Mixto.Porcentajes[3] := StrToInt(s);
      s := Copy(Linea, 10, 3);
      Mixto.Porcentajes[4] := StrToInt(s);
      s := Copy(Linea, 13, 3);
      Mixto.Porcentajes[5] := StrToInt(s);
      s := Copy(Linea, 16, 3);
      Mixto.Porcentajes[6] := StrToInt(s);
      s := Copy(Linea, 19, 3);
      Mixto.Porcentajes[7] := StrToInt(s);
      s := Copy(Linea, 22, 8);
      Mixto.Color := StrToInt(s);
      JuegoSustratos.SustratoMixto[i] := Mixto;
    end;
    Lineas := Self.LeeValorAmpliado('MapaEscenario');
    for j := 1 to Altura do
    begin
      s := Lineas.Strings[j-1];
      for i := 1 to Anchura do
      begin
        Caracter :=  Copy(s, i, 1);
        Cuadro[i,j] := Caracter[1];
      end;
    end;
    FAltura := Altura;
    FAnchura := Anchura;
   end; //with Escenario
end;

function TEntorno.CuadroFisico: Word;
begin
  Result := Escenario.CuadroFisico;
end;

function TEntorno.GetCuadricula: Boolean;
begin
  Result := Escenario.Cuadricula;
end;

function TEntorno.GetDesplazamientoX: Integer;
begin
  Result := Escenario.DesplazamientoX;
end;

function TEntorno.GetDesplazamientoY: Integer;
begin
  Result := Escenario.DesplazamientoY;
end;

function TEntorno.GetPorcentaje: Word;
begin
  Result := Escenario.Porcentaje;
end;

procedure TEntorno.SetCuadricula(const Value: Boolean);
begin
  Escenario.Cuadricula := Value;
end;

procedure TEntorno.SetDesplazamientoX(const Value: Integer);
begin
  Escenario.DesplazamientoX := Value;
end;

procedure TEntorno.SetDesplazamientoY(const Value: Integer);
begin
  Escenario.DesplazamientoY := Value;
end;

procedure TEntorno.SetPorcentaje(const Value: Word);
begin
  Escenario.Porcentaje := Value;
end;

function TEntorno.XLogica(X: Integer): Integer;
begin
  Result := Escenario.XLogica(X);
end;

function TEntorno.YLogica(Y: Integer): Integer;
begin
  Result := Escenario.YLogica(Y);
end;

function TEntorno.XFisica(X: Integer): Integer;
begin
  Result := Escenario.XFisica(X);
end;

function TEntorno.YFisica(Y: Integer): Integer;
begin
  Result := Escenario.YFisica(Y);
end;

procedure TEntorno.CargaJuego;
var
  Lineas   : TStringList;
  i, j,
  k, c     : Integer;
  r        : Real;
  s,
  Linea    : string;
  Estadio  : TEstadio;
  Prototipo: TPrototipo;
begin
  with Juego do
  begin
    NumEstadios := Self.LeeValorEntero('NumEstadios');
    NumPrototiposM := Self.LeeValorEntero('NumPrototiposM');
    NumPrototiposH := Self.LeeValorEntero('NumPrototiposH');
    Linea := Self.LeeValor('Velocidad');
    for i := 1 to 7 do
      Movimiento.Velocidad[i] := ObtenNsimo(Linea,i);
    s := Self.LeeValor('Y_OEstadios');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Y_O := (ObtenNsimo(s, i) = '1');
      Estadios[i] := Estadio;
    end;
    s := Self.LeeValor('Y_OEstadiosR');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Y_OR := (ObtenNsimo(s, i) = '1');
      Estadios[i] := Estadio;
    end;
    s := Self.LeeValor('Y_OEstadiosC1C2');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Y_OC1C2 := (ObtenNsimo(s, i) = '1');
      Estadios[i] := Estadio;
    end;
    s := Self.LeeValor('PrototiposLigados');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Prototipo := StrToInt(ObtenNsimo(s, i));
      Estadios[i] := Estadio;
    end;
    s := Self.LeeValor('CiclosEstadios');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Ciclos := ObtenNsimo(s,i);
      Estadios[i] := Estadio;
    end;
    MaxHuevos := Self.LeeValor('MaxHuevos');
    MaxPaquetes := Self.LeeValor('MaxPaquetes');
    PaquetesTransferidos := Self.LeeValor('PaquetesTransferidos');
    HuevosFertilizados := Self.LeeValor('HuevosFertilizados');
    Paternidad := Self.LeeValor('Paternidad');
    MaxPaquetesH := Self.LeeValor('MaxPaquetesH');
    TasaConsumo :=  Self.LeeValor('TasaConsumo');
    HuevosCiclo := Self.LeeValor('HuevosCiclo');
    FraccionHuevo := Self.LeeValor('FraccionHuevo');
    FraccionPaquete := Self.LeeValor('FraccionPaquete');
    DegradacionEsperma := Self.LeeValor('DegradacionEsperma');
    JerarquiaM := Self.LeeValor('JerarquiaM');
    JerarquiaH := Self.LeeValor('JerarquiaH');
    Lineas := Self.LeeValorAmpliado('EstadiosCondiciones1');
      for i := 1 to NumEstadios do
      begin
        Estadio := Estadios[i];
        Estadio.Condicion1 := Lineas.Strings[i-1];
        Estadios[i] := Estadio;
      end;
    Lineas := Self.LeeValorAmpliado('EstadiosCondiciones2');
      for i := 1 to NumEstadios do
      begin
        Estadio := Estadios[i];
        Estadio.Condicion2 := Lineas.Strings[i-1];
        Estadios[i] := Estadio;
      end;
    Lineas := Self.LeeValorAmpliado('CriteriosM');
    SetLength(CriteriosM, 3, NumPrototiposM);
    for j := 0 to NumPrototiposM - 1 do
    begin
      Linea := Lineas.Strings[j];
      for i := 0 to 2 do
        CriteriosM[i,j] := ObtenNsimo(Linea, i+1);
    end;
    Lineas := Self.LeeValorAmpliado('CriteriosH');
    SetLength(CriteriosH, 3, NumPrototiposH);
    for j := 0 to NumPrototiposH - 1 do
    begin
      Linea := Lineas.Strings[j];
      for i := 0 to 2 do
        CriteriosH[i,j] := ObtenNsimo(Linea, i+1);
    end;
    Linea := Self.LeeValor('CostoHuevo');
    for i := 1 to 4 do
      CostoHuevo[i] := ObtenNsimo(Linea,i);
    Linea := Self.LeeValor('CostoPaquete');
    for i := 1 to 4 do
      CostoPaquete[i] := ObtenNsimo(Linea,i);
    Lineas := Self.LeeValorAmpliado('NombresContinuos');
    for i := 1 to 15 do
      Continuos[i].Nombre := Lineas.Strings[i-1];
    Lineas := Self.LeeValorAmpliado('NombresDiscretos');
    for i := 1 to 15 do
      Discretos[i].Nombre := Lineas.Strings[i-1];
    Lineas := Self.LeeValorAmpliado('OmisionContinuos');
    for i := 1 to 15 do
      Continuos[i].Omision := Lineas.Strings[i-1];
    Lineas := Self.LeeValorAmpliado('OmisionDiscretos');
    for i := 1 to 15 do
      Discretos[i].Omision := Lineas.Strings[i-1];
    Lineas := Self.LeeValorAmpliado('DominantesContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].Dominante := r;
    end;
    Lineas := Self.LeeValorAmpliado('RecesivosContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].Recesivo := r;
    end;
    Lineas := Self.LeeValorAmpliado('MutacionDominantesContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].MutacionD := r;
    end;
    Lineas := Self.LeeValorAmpliado('MutacionRecesivosContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].MutacionR := r;
    end;
    Lineas := Self.LeeValorAmpliado('RangoMutacionDominantesContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].RangoMutacionD := r;
    end;
    Lineas := Self.LeeValorAmpliado('RangoMutacionRecesivosContinuos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociContinuos[i].RangoMutacionR := r;
    end;
    Lineas := Self.LeeValorAmpliado('DominantesDiscretos');
    for i := 1 to 15 do
    begin
      k := StrToInt(Lineas.Strings[i-1]);
      LociDiscretos[i].Dominante := k;
    end;
    Lineas := Self.LeeValorAmpliado('RecesivosDiscretos');
    for i := 1 to 15 do
    begin
      k := StrToInt(Lineas.Strings[i-1]);
      LociDiscretos[i].Recesivo := k;
    end;
    Lineas := Self.LeeValorAmpliado('MutacionDominantesDiscretos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociDiscretos[i].MutacionD := r;
    end;
    Lineas := Self.LeeValorAmpliado('MutacionRecesivosDiscretos');
    for i := 1 to 15 do
    begin
      r := StrToFloat(Lineas.Strings[i-1]);
      LociDiscretos[i].MutacionR := r;
    end;
    Lineas := Self.LeeValorAmpliado('RangoMutacionDominantesDiscretos');
    for i := 1 to 15 do
    begin
      k := StrToInt(Lineas.Strings[i-1]);
      LociDiscretos[i].RangoMutacionD := k;
    end;
    Lineas := Self.LeeValorAmpliado('RangoMutacionRecesivosDiscretos');
    for i := 1 to 15 do
    begin
      k := StrToInt(Lineas.Strings[i-1]);
      LociDiscretos[i].RangoMutacionR := k;
    end;
    Lineas := Self.LeeValorAmpliado('CostosMovimiento');
    for j := 1 to 2 do
    begin
      Linea := Lineas.Strings[j-1];
      for i := 1 to 4 do
      begin
        Movimiento.Costos[i,j] := ObtenNsimo(Linea, i);
      end;
    end;
    Lineas := Self.LeeValorAmpliado('CostosAlimentacion');
    for i := 1 to 4 do
      for j := 1 to 4 do
        Alimentacion.Costos[i,j] := ObtenNsimo(Lineas.Strings[i-1],j);
    Linea := Self.LeeValor('GananciasAlimentacion');
    for i := 1 to 4 do
      Alimentacion.Ganancias[i] := ObtenNsimo(Linea,i);
    Lineas := Self.LeeValorAmpliado('NombresEstadios');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Nombre := Lineas.Strings[i-1];
      Estadios[i] := Estadio;
    end;
    Lineas := Self.LeeValorAmpliado('ColoresEstadios');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Estadio.Color := StrToInt(Lineas.Strings[i-1]);
      Estadios[i] := Estadio;
    end;
    Lineas := Self.LeeValorAmpliado('NombresPrototiposM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Nombre := Lineas.Strings[i-1];
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('ColoresPrototiposM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Color := StrToInt(Lineas.Strings[i-1]);
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('LongevidadesPrototiposM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.Longevidad := Lineas.Strings[i-1];
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('NombresPrototiposH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Nombre := Lineas.Strings[i-1];
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('ColoresPrototiposH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Color := StrToInt(Lineas.Strings[i-1]);
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('LongevidadesPrototiposH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.Longevidad := Lineas.Strings[i-1];
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('ProporcionesSexuales');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.ProporcionMachos := ObtenNsimo(Lineas.Strings[i-1], 1);
      Prototipo.ProporcionHembras := ObtenNsimo(Lineas.Strings[i-1], 2);
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('RequerimientosEstadios');
    for i := 1 to NumEstadios do
    begin
      s := Lineas.Strings[i-1];
      for j := 1 to 4 do
      begin
        Estadio := Estadios[i];
        Estadio.Requiere[j] := ObtenNsimo(s,j);
        Estadios[i] := Estadio;
      end;
    end;
    Lineas := Self.LeeValorAmpliado('CostosEstadios');
    for i := 1 to NumEstadios do
    begin
      s := Lineas.Strings[i-1];
      for j := 1 to 4 do
      begin
        Estadio := Estadios[i];
        Estadio.Costos[j] := ObtenNsimo(s,j);
        Estadios[i] := Estadio;
      end;
    end;
    Lineas := Self.LeeValorAmpliado('DiscretosPrototiposM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Linea := Lineas.Strings[i-1];
      k := 1;
      for j := 1 to 15 do
      begin
        Prototipo.Discretos[j].ValorGenetico := ObtenNsimo(Linea,k);
        Prototipo.Discretos[j].ValorAmbiental := ObtenNsimo(Linea,k+1);
        Inc(k,2);
      end;
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('DiscretosPrototiposH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Linea := Lineas.Strings[i-1];
      k := 1;
      for j := 1 to 15 do
      begin
        Prototipo.Discretos[j].ValorGenetico := ObtenNsimo(Linea,k);
        Prototipo.Discretos[j].ValorAmbiental := ObtenNsimo(Linea,k+1);
        Inc(k,2);
      end;
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('ContinuosPrototiposM');
    k := 0;
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico := Lineas.Strings[k];
        Prototipo.Continuos[j].ValorAmbiental := Lineas.Strings[k+1];
        Inc(K,2);
      end;
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('ContinuosPrototiposH');
    k := 0;
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      for j := 1 to 15 do
      begin
        Prototipo.Continuos[j].ValorGenetico := Lineas.Strings[k];
        Prototipo.Continuos[j].ValorAmbiental := Lineas.Strings[k+1];
        Inc(K,2);
      end;
      PrototiposH[i] := Prototipo;
    end;
    Linea := Self.LeeValor('RefractariosCombateM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.RefractarioCombate := ObtenNsimo(Linea, i);
      PrototiposM[i] := Prototipo;
    end;
    Linea := Self.LeeValor('RefractariosCombateH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.RefractarioCombate := ObtenNsimo(Linea, i);
      PrototiposH[i] := Prototipo;
    end;
    Linea := Self.LeeValor('RefractariosCortejoM');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Prototipo.RefractarioCortejo := ObtenNsimo(Linea, i);
      PrototiposM[i] := Prototipo;
    end;
    Linea := Self.LeeValor('RefractariosCortejoH');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Prototipo.RefractarioCortejo := ObtenNsimo(Linea, i);
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('TendenciasEstadios');
    for i := 1 to NumEstadios do
    begin
      Estadio := Estadios[i];
      Linea := Lineas.Strings[i-1];
      for j := 1 to 8 do
        Estadio.Tendencias[j] := ObtenNsimo(Linea, j);
      Estadios[i] := Estadio;
    end;
    Lineas := Self.LeeValorAmpliado('TendenciasMachos');
    for i := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[i];
      Linea := Lineas.Strings[i-1];
      for j := 1 to 8 do
        Prototipo.Tendencias[j] := ObtenNsimo(Linea, j);
      PrototiposM[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('TendenciasHembras');
    for i := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[i];
      Linea := Lineas.Strings[i-1];
      for j := 1 to 8 do
        Prototipo.Tendencias[j] := ObtenNsimo(Linea, j);
      PrototiposH[i] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('CostosCombate');
    for j := 1 to 3 do
      for i := 1 to 4 do
        CostosCombate[i,j] := ObtenNsimo(Lineas.Strings[j-1], i);
    Lineas := Self.LeeValorAmpliado('CostosCortejo');
    for j := 1 to 6 do
      for i := 1 to 4 do
        CostosCortejo[i,j] := ObtenNsimo(Lineas.Strings[j-1], i);
    Lineas := Self.LeeValorAmpliado('MatrizSustratos');
    MatrizSustratos.Free;
    MatrizSustratos := TMatrizInteraccion.Create(7, NumEstadios +NumPrototiposM
                                                              + NumPrototiposH);
    k := 0;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratos.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizDinamicos');
    MatrizDinamicos.Free;
    MatrizDinamicos := TMatrizInteraccion.Create(5, NumEstadios +NumPrototiposM
                                                              + NumPrototiposH);
    k := 0;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicos.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizAgentes');
    MatrizAgentes.Free;
    MatrizAgentes := TMatrizInteraccionAgentes.Create
                    (NumEstadios + NumPrototiposM + NumPrototiposH,
                      NumEstadios + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        s := Lineas.Strings[k];
        MatrizAgentes.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizSustratosA');
    MatrizSustratosA.Free;
    MatrizSustratosA := TMatrizInteraccion.Create(7, NumEstadios +NumPrototiposM
                                                              + NumPrototiposH);
    k := 0;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizSustratosA.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizDinamicosA');
    MatrizDinamicosA.Free;
    MatrizDinamicosA := TMatrizInteraccion.Create(5, NumEstadios +NumPrototiposM
                                                              + NumPrototiposH);
    k := 0;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizDinamicosA.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizAgentesA');
    MatrizAgentesA.Free;
    MatrizAgentesA := TMatrizInteraccionAgentes.Create
                    (NumEstadios + NumPrototiposM + NumPrototiposH,
                      NumEstadios + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentesA.Celda[i,j] := Lineas.Strings[k];
        Inc(k);
      end;
    Lineas := Self.LeeValorAmpliado('MatrizSustratosM');
    MatrizSustratosM.Free;
    MatrizSustratosM := TMatrizInteraccion.Create(7, NumEstadios
                                          + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to 7 do
    begin
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizSustratosM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
      Inc(k);
    end;
    Lineas := Self.LeeValorAmpliado('MatrizDinamicosM');
    MatrizDinamicosM.Free;
    MatrizDinamicosM := TMatrizInteraccion.Create(5, NumEstadios
                                          + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to 5 do
    begin
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizDinamicosM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
      Inc(k);
    end;
    Lineas := Self.LeeValorAmpliado('MatrizAgentesM');
    MatrizAgentesM.Free;
    MatrizAgentesM := TMatrizInteraccionAgentes.Create(NumEstadios
                      + NumPrototiposM + NumPrototiposH, NumEstadios
                      + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
    begin
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizAgentesM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
      Inc(k);
    end;
    Lineas := Self.LeeValorAmpliado('MatrizConductasM');
    MatrizConductasM.Free;
    MatrizConductasM := TMatrizInteraccion.Create(14, NumEstadios
                                          + NumPrototiposM + NumPrototiposH);
    k := 0;
    for i := 1 to 14 do
    begin
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        MatrizConductasM.Celda[i,j] := ObtenNsimo(Lineas.Strings[k], j);
      Inc(k);
    end;
    Lineas := Self.LeeValorAmpliado('MatricesCombateM');
    c := 0;
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 2 do
      begin
        Linea := Lineas.Strings[c];
        for i := 1 to 3 do
          Prototipo.Combate[i,j] := ObtenNsimo(Linea, i);
        Inc(c);
      end;
      PrototiposM[k] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('MatricesCortejoM');
    c := 0;
    for k := 1 to NumPrototiposM do
    begin
      Prototipo := PrototiposM[k];
      for j := 1 to 3 do
      begin
        Linea := Lineas.Strings[c];
        for i := 1 to 4 do
          Prototipo.Cortejo[i,j] := ObtenNsimo(Linea, i);
        Inc(c);
      end;
      PrototiposM[k] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('MatricesCombateH');
    c := 0;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 2 do
      begin
        Linea := Lineas.Strings[c];
        for i := 1 to 3 do
          Prototipo.Combate[i,j] := ObtenNsimo(Linea, i);
        Inc(c);
      end;
      PrototiposH[k] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('MatricesCortejoH');
    c := 0;
    for k := 1 to NumPrototiposH do
    begin
      Prototipo := PrototiposH[k];
      for j := 1 to 3 do
      begin
        Linea := Lineas.Strings[c];
        for i := 1 to 4 do
          Prototipo.Cortejo[i,j] := ObtenNsimo(Linea, i);
        Inc(c);
      end;
      PrototiposH[k] := Prototipo;
    end;
    Lineas := Self.LeeValorAmpliado('Metabolismo');
    for j := 1 to 4 do
      for i := 1 to 5 do
        Metabolismo[i,j] := ObtenNsimo(Lineas.Strings[j-1],i);
    Lineas.Free;
  end;  //with
end;  //proc CargaJuego

procedure TEntorno.DespliegaEscenario;
begin
  //Escenario.OnDibuja := FOnDibujaEscenario;
  Escenario.Despliega;
end;

procedure TEntorno.GuardaEscenario;
var
  Linea  : string;
  Lineas : TStringList;
  i, j   : Integer;
  Simple : TSustratoSimple;
  Mixto  : TSustratoMixto;
begin
  with Escenario do
  begin
    Lineas := TStringList.Create;
    Self.EscribeValor('Anchura', Anchura);
    Self.EscribeValor('Altura', Altura);
    Self.EscribeValor('NumSustratosMixtos', JuegoSustratos.NumMixtos);
    Lineas.Clear;
    for i := 1 to 7 do
    begin
      Simple := JuegoSustratos.SustratoSimple[i];
      Lineas.Add(Simple.Nombre);
      Lineas.Add(IntAStr(Simple.Color, 8));
    end;
    Self.EscribeValor('SustratosSimples', Lineas);
    Lineas.Clear;
    for i := 1 to JuegoSustratos.NumMixtos do
    begin
      Linea := '';
      Mixto := JuegoSustratos.SustratoMixto[i];
      Linea := IntAStr(Mixto.Porcentajes[1],3)
                + IntAStr(Mixto.Porcentajes[2],3)
                + IntAStr(Mixto.Porcentajes[3],3)
                + IntAStr(Mixto.Porcentajes[4],3)
                + IntAStr(Mixto.Porcentajes[5],3)
                + IntAStr(Mixto.Porcentajes[6],3)
                + IntAStr(Mixto.Porcentajes[7],3)
                + IntAStr(Mixto.Color,8);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('SustratosMixtos', Lineas);
    Lineas.Clear;
    for j := 1 to Altura do
    begin
      Linea := '';
      for i := 1 to Anchura do
        Linea := Linea + Cuadro[i,j];
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MapaEscenario', Lineas);
    Lineas.Free;
  end;  //with
end;

procedure TEntorno.GuardaJuego;
var
  Lineas : TStringList;
  Linea  : string;
  i, j, k: Integer;
begin
  with Juego do
  begin
    Lineas := TStringList.Create;
    Self.EscribeValor('NumEstadios', NumEstadios);
    Self.EscribeValor('NumPrototiposM', NumPrototiposM);
    Self.EscribeValor('NumPrototiposH', NumPrototiposH);
    Linea := '';
    for i := 1 to 7 do
      Linea := Linea + Movimiento.Velocidad[i] + ',';
    Self.EscribeValor('Velocidad', Linea);
    Linea := '';
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Y_O then
        Linea := Linea + '1,'
      else
        Linea := Linea + '0,';
    end;
    Self.EscribeValor('Y_OEstadios', Linea);
    Linea := '';
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Y_OR then
        Linea := Linea + '1,'
      else
        Linea := Linea + '0,';
    end;
    Self.EscribeValor('Y_OEstadiosR', Linea);
    Linea := '';
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Y_OC1C2 then
        Linea := Linea + '1,'
      else
        Linea := Linea + '0,';
    end;
    Self.EscribeValor('Y_OEstadiosC1C2', Linea);
    Linea := '';
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Prototipo <> 0 then
        Linea := Linea + IntToStr(Estadios[i].Prototipo) + ','
      else
        Linea := Linea + '0,';
    end;
    Self.EscribeValor('PrototiposLigados', Linea);
    Linea := '';
    for i := 1 to NumEstadios do
      Linea := Linea + Estadios[i].Ciclos + ',';
    Self.EscribeValor('CiclosEstadios', Linea);
    Self.EscribeValor('MaxHuevos', MaxHuevos);
    Self.EscribeValor('MaxPaquetes', MaxPaquetes);
    Self.EscribeValor('PaquetesTransferidos', PaquetesTransferidos);
    Self.EscribeValor('HuevosFertilizados', HuevosFertilizados);
    Self.EscribeValor('Paternidad', Paternidad);
    Self.EscribeValor('MaxPaquetesH', MaxPaquetesH);
    Self.EscribeValor('TasaConsumo', TasaConsumo);
    Self.EscribeValor('HuevosCiclo', HuevosCiclo);
    Self.EscribeValor('FraccionHuevo', FraccionHuevo);
    Self.EscribeValor('FraccionPaquete', FraccionPaquete);
    Self.EscribeValor('DegradacionEsperma', DegradacionEsperma);
    Self.EscribeValor('JerarquiaM', JerarquiaM);
    Self.EscribeValor('JerarquiaH', JerarquiaH);
    Lineas.Clear;
    for i := 1 to NumEstadios do
      Lineas.Add(Estadios[i].Condicion1);
    Self.EscribeValor('EstadiosCondiciones1', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios do
      Lineas.Add(Estadios[i].Condicion2);
    Self.EscribeValor('EstadiosCondiciones2', Lineas);
    Lineas.Clear;
    for j := 0 to NumPrototiposM - 1 do
    begin
      Linea := '';
      for i := 0 to 2 do
        Linea := Linea + CriteriosM[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CriteriosM', Lineas);
    Lineas.Clear;
    for j := 0 to NumPrototiposH - 1 do
    begin
      Linea := '';
      for i := 0 to 2 do
        Linea := Linea + CriteriosH[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CriteriosH', Lineas);
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + CostoHuevo[i] + ',';
    Self.EscribeValor('CostoHuevo',Linea);
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + CostoPaquete[i] + ',';
    Self.EscribeValor('CostoPaquete',Linea);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := Continuos[i].Nombre;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('NombresContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := Discretos[i].Nombre;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('NombresDiscretos', Lineas);
    Lineas.Clear;
    for j := 1 to 2 do
    begin
      Linea := '';
      for i := 1 to 4 do
        Linea := Linea + Movimiento.Costos[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CostosMovimiento', Lineas);
    Lineas.Clear;
    for i := 1 to 4 do
    begin
      Linea := '';
      for j := 1 to 4 do
        Linea := Linea + Alimentacion.Costos[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CostosAlimentacion', Lineas);
    Linea := '';
    for i := 1 to 4 do
      Linea := Linea + Alimentacion.Ganancias[i] + ',';
    Self.EscribeValor('GananciasAlimentacion', Linea);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(Continuos[i].Omision);
    Self.EscribeValor('OmisionContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := Discretos[i].Omision;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('OmisionDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].Dominante));
    Self.EscribeValor('DominantesContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].Recesivo));
    Self.EscribeValor('RecesivosContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].MutacionD));
    Self.EscribeValor('MutacionDominantesContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].MutacionR));
    Self.EscribeValor('MutacionRecesivosContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].RangoMutacionD));
    Self.EscribeValor('RangoMutacionDominantesContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
      Lineas.Add(FloatToStr(LociContinuos[i].RangoMutacionR));
    Self.EscribeValor('RangoMutacionRecesivosContinuos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := IntToStr(LociDiscretos[i].Dominante);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('DominantesDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := IntToStr(LociDiscretos[i].Recesivo);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('RecesivosDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := FloatToStr(LociDiscretos[i].MutacionD);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MutacionDominantesDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := FloatToStr(LociDiscretos[i].MutacionR);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MutacionRecesivosDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := FloatToStr(LociDiscretos[i].RangoMutacionD);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('RangoMutacionDominantesDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to 15 do
    begin
      Linea := FloatToStr(LociDiscretos[i].RangoMutacionR);
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('RangoMutacionRecesivosDiscretos', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios do
      Lineas.Add(Estadios[i].Nombre);
    Self.EscribeValor('NombresEstadios', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios do
      Lineas.Add(IntAStr(Estadios[i].Color, 8));
    Self.EscribeValor('ColoresEstadios', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
      Lineas.Add(PrototiposM[i].Nombre);
    Self.EscribeValor('NombresPrototiposM', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
      Lineas.Add(IntAStr(PrototiposM[i].Color, 8));
    Self.EscribeValor('ColoresPrototiposM', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
      Lineas.Add(PrototiposM[i].Longevidad);
    Self.EscribeValor('LongevidadesPrototiposM', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
      Lineas.Add(PrototiposH[i].Nombre);
    Self.EscribeValor('NombresPrototiposH', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
      Lineas.Add(IntAStr(PrototiposH[i].Color, 8));
    Self.EscribeValor('ColoresPrototiposH', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
      Lineas.Add(PrototiposH[i].Longevidad);
    Self.EscribeValor('LongevidadesPrototiposH', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
    begin
      Linea := PrototiposH[i].ProporcionMachos + ','
                + PrototiposH[i].ProporcionHembras;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('ProporcionesSexuales', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios do
    begin
      Linea := '';
      for j := 1 to 4 do
        Linea := Linea + Estadios[i].Requiere[j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('RequerimientosEstadios', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios do
    begin
      Linea := '';
      for j := 1 to 4 do
        Linea := Linea + Estadios[i].Costos[j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CostosEstadios', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
    begin
      Linea := '';
      for j := 1 to 15 do
      begin
        Linea := Linea + (PrototiposM[i].Discretos[j].ValorGenetico) + ',';
        Linea := Linea + (PrototiposM[i].Discretos[j].ValorAmbiental) + ',';
      end;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('DiscretosPrototiposM', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
    begin
      Linea := '';
      for j := 1 to 15 do
      begin
        Linea := Linea + PrototiposH[i].Discretos[j].ValorGenetico + ',';
        Linea := Linea + PrototiposH[i].Discretos[j].ValorAmbiental + ',';
      end;
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('DiscretosPrototiposH', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
      for j := 1 to 15 do
      begin
        Lineas.Add(PrototiposM[i].Continuos[j].ValorGenetico);
        Lineas.Add(PrototiposM[i].Continuos[j].ValorAmbiental);
      end;
    Self.EscribeValor('ContinuosPrototiposM', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
      for j := 1 to 15 do
      begin
        Lineas.Add(PrototiposH[i].Continuos[j].ValorGenetico);
        Lineas.Add(PrototiposH[i].Continuos[j].ValorAmbiental);
      end;
    Self.EscribeValor('ContinuosPrototiposH', Lineas);
    Linea := '';
    for i := 1 to NumPrototiposM do
      Linea := Linea + PrototiposM[i].RefractarioCombate + ',';
    Self.EscribeValor('RefractariosCombateM', Linea);
    Linea := '';
    for i := 1 to NumPrototiposH do
      Linea := Linea + PrototiposH[i].RefractarioCombate + ',';
    Self.EscribeValor('RefractariosCombateH', Linea);
    Linea := '';
    for i := 1 to NumPrototiposM do
      Linea := Linea + PrototiposM[i].RefractarioCortejo + ',';
    Self.EscribeValor('RefractariosCortejoM', Linea);
    Linea := '';
    for i := 1 to NumPrototiposH do
      Linea := Linea + PrototiposH[i].RefractarioCortejo + ',';
    Self.EscribeValor('RefractariosCortejoH', Linea);
    Lineas.Clear;
    Linea := '';
    for i := 1 to NumEstadios do
    begin
      Linea := '';
      for j := 1 to 8 do
        Linea := Linea + Estadios[i].Tendencias[j] + ', ';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('TendenciasEstadios', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposM do
    begin
      Linea := '';
      for j := 1 to 8 do
        Linea := Linea + PrototiposM[i].Tendencias[j] + ', ';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('TendenciasMachos', Lineas);
    Lineas.Clear;
    for i := 1 to NumPrototiposH do
    begin
      Linea := '';
      for j := 1 to 8 do
        Linea := Linea + PrototiposH[i].Tendencias[j] + ', ';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('TendenciasHembras', Lineas);
    Lineas.Clear;
    for j := 1 to 3 do
    begin
      Linea := '';
      for i := 1 to 4 do
        Linea := Linea + CostosCombate[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CostosCombate', Lineas);
    Lineas.Clear;
    for j := 1 to 6 do
    begin
      Linea := '';
      for i := 1 to 4 do
        Linea := Linea + CostosCortejo[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('CostosCortejo', Lineas);
    Lineas.Clear;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizSustratos.Celda[i,j]);
    Self.EscribeValor('MatrizSustratos', Lineas);
    Lineas.Clear;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizDinamicos.Celda[i,j]);
    Self.EscribeValor('MatrizDinamicos', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizAgentes.Celda[i,j]);
    Self.EscribeValor('MatrizAgentes', Lineas);
    Lineas.Clear;
    for i := 1 to 7 do  //Número de sustratos = 7
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizSustratosA.Celda[i,j]);
    Self.EscribeValor('MatrizSustratosA', Lineas);
    Lineas.Clear;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizDinamicosA.Celda[i,j]);
    Self.EscribeValor('MatrizDinamicosA', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Lineas.Add(MatrizAgentesA.Celda[i,j]);
    Self.EscribeValor('MatrizAgentesA', Lineas);
    Lineas.Clear;
    for i := 1 to 7 do  //Número de sustratos = 7
    begin
      Linea := '';
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Linea := Linea + MatrizSustratosM.Celda[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MatrizSustratosM', Lineas);
    Lineas.Clear;
    for i := 1 to 5 do  //Número de elementos dinámicos = 5
    begin
      Linea := '';
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Linea := Linea + MatrizDinamicosM.Celda[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MatrizDinamicosM', Lineas);
    Lineas.Clear;
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
    begin
      Linea := '';
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Linea := Linea + MatrizAgentesM.Celda[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MatrizAgentesM', Lineas);
    Lineas.Clear;
    for i := 1 to 14 do  //Número de conductas = 14
    begin
      Linea := '';
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Linea := Linea + MatrizConductasM.Celda[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('MatrizConductasM', Lineas);
    Lineas.Clear;
    for j := 1 to 4 do
    begin
      Linea := '';
      for i := 1 to 5 do
        Linea := Linea + Metabolismo[i,j] + ',';
      Lineas.Add(Linea);
    end;
    Self.EscribeValor('Metabolismo', Lineas);
    Lineas.Clear;
    for k := 1 to NumPrototiposM do
    begin
      for j := 1 to 2 do
      begin
        Linea := '';
        for i := 1 to 3 do
          Linea := Linea + PrototiposM[k].Combate[i,j] + ',';
        Lineas.Add(Linea);
       end;
    end;
    Self.EscribeValor('MatricesCombateM', Lineas);
    Lineas.Clear;
    for k := 1 to NumPrototiposM do
    begin
      for j := 1 to 3 do
      begin
        Linea := '';
        for i := 1 to 4 do
          Linea := Linea + PrototiposM[k].Cortejo[i,j] + ',';
        Lineas.Add(Linea);
       end;
    end;
    Self.EscribeValor('MatricesCortejoM', Lineas);
    Lineas.Clear;
    for k := 1 to NumPrototiposH do
    begin
      for j := 1 to 2 do
      begin
        Linea := '';
        for i := 1 to 3 do
          Linea := Linea + PrototiposH[k].Combate[i,j] + ',';
        Lineas.Add(Linea);
       end;
    end;
    Self.EscribeValor('MatricesCombateH', Lineas);
    Lineas.Clear;
    for k := 1 to NumPrototiposH do
    begin
      for j := 1 to 3 do
      begin
        Linea := '';
        for i := 1 to 4 do
          Linea := Linea + PrototiposH[k].Cortejo[i,j] + ',';
        Lineas.Add(Linea);
       end;
    end;
    Self.EscribeValor('MatricesCortejoH', Lineas);
  end;  //with
  Lineas.Free;
end;  //proc GuardaJuego

procedure TEntorno.ImportaEscenario(NombreArchivo: string);
var
  AlturaAnt,
  AnchuraAnt: Integer; //Altura y anchura anteriores
begin
  AlturaAnt := Escenario.Altura;
  AnchuraAnt := Escenario.Anchura;
  Escenario.Free;
  Escenario := TEscenario.Create;//(Plataforma);
  Escenario.OnDibuja := FOnDibujaEscenario;
  Escenario.Carga(NombreArchivo);
  FAltura := Escenario.Altura;
  FAnchura := Escenario.Anchura;
  if (AlturaAnt>Escenario.Altura) or (AnchuraAnt>Escenario.Anchura) then
    raise EIncompatibilidad.Create('Las dimensiones del nuevo escenario son '
          + 'menores a las requeridas por el entorno [ImportaEscenario]');
end;

procedure TEntorno.ImportaJuego(NombreArchivo: string);
var
  i: Integer;
  EstadiosAnt,
  MachosAnt,
  HembrasAnt: Word; //Número de prototipos en juego anterior
begin
  EstadiosAnt := Juego.NumEstadios;
  MachosAnt := Juego.NumPrototiposM;
  HembrasAnt := Juego.NumPrototiposH;
  Juego.Free;
  Juego := TJuegoAgentes.Create;
  Juego.Carga(NombreArchivo);
  if (EstadiosAnt>Juego.NumEstadios)
        or (MachosAnt>Juego.NumPrototiposM)
        or (HembrasAnt>Juego.NumPrototiposH) then
    raise EIncompatibilidad.Create('El juego a agentes indicado contiene menos '
                + 'prototipos de los requeridos por el entorno [ImportaJuego]')
  else
  if Self.ListaAgentes.Contador > 0 then
    for i := 1 to Self.ListaAgentes.Contador do
      with Self.ListaAgentes.Elementos[i] do
      begin
        if Adulto then
        begin
          case Sexo of
            sxMacho : Color := Juego.PrototiposM[Prototipo].Color;
            sxHembra: Color := Juego.PrototiposH[Prototipo].Color;
          end;
        end
        else
          Color := Juego.Estadios[Estadio].Color;
      end;
end;

destructor TEntorno.Destroy;
begin
  Escenario.Free;
  Juego.Free;
  ListaHuevos.Free;
  ListaAgentes.Free;
  ListaDinamicos.Free;
  ListaOviposicion.Free;
  inherited Destroy;
end;

procedure TEntorno.ElementosEn(X, Y: Word; var Agentes: array of TAgente;
  var Dinamicos: array of TDinamico;
  var Oviposicion: array of TSitioOviposicion);
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to ListaAgentes.Contador do
  begin
    if (ListaAgentes.Elementos[i].X = X)
        and (ListaAgentes.Elementos[i].Y = Y) then
    begin
      if (j <= Length(Agentes) - 1) then
      begin
        Agentes[j] := ListaAgentes.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
  j := 0;
  for i := 1 to ListaDinamicos.Contador do
  begin
    if (ListaDinamicos.Elementos[i].X = X)
        and (ListaDinamicos.Elementos[i].Y = Y) then
    begin
      if (j <= Length(Dinamicos) - 1) then
      begin
        Dinamicos[j] := ListaDinamicos.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
  j := 0;
  for i := 1 to ListaOviposicion.Contador do
  begin
    if (ListaOviposicion.Elementos[i].X = X)
        and (ListaOviposicion.Elementos[i].Y = Y) then
    begin
      if (j <= Length(Oviposicion) - 1) then
      begin
        Oviposicion[j] := ListaOviposicion.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
end;

function TEntorno.NumAgentesEn(X, Y: Word): Word;
var
  i,
  cont: Integer;
begin
  cont := 0;
  for i := 1 to ListaAgentes.Contador do
  begin
    if (ListaAgentes.Elementos[i].X = X)
        and (ListaAgentes.Elementos[i].Y = Y) then
      Inc(cont);
  end;
  Result := cont;
end;

function TEntorno.NumDinamicosEn(X, Y: Word): Word;
var
  i,
  cont: Integer;
begin
  cont := 0;
  for i := 1 to ListaDinamicos.Contador do
  begin
    if (ListaDinamicos.Elementos[i].X = X)
        and (ListaDinamicos.Elementos[i].Y = Y) then
      Inc(cont);
  end;
  Result := cont;
end;

function TEntorno.NumOviposicionEn(X, Y: Word): Word;
var
  i,
  cont: Integer;
begin
  cont := 0;
  for i := 1 to ListaOviposicion.Contador do
  begin
    if (ListaOviposicion.Elementos[i].X = X)
        and (ListaOviposicion.Elementos[i].Y = Y) then
      Inc(cont);
  end;
  Result := cont;
end;

function TEntorno.NumElementosEn(X, Y: Word): Word;
begin
  Result := NumAgentesEn(X, Y) + NumDinamicosEn(X, Y) + NumOviposicionEn(X, Y);
end;

procedure TEntorno.ExportaEscenario(NombreArchivo: string);
begin
  Escenario.Guarda(NombreArchivo);
end;

procedure TEntorno.ExportaJuego(NombreArchivo: string);
begin
  Juego.Guarda(NombreArchivo);
end;

function TEntorno.HaySustratoEn(X, Y: Word; Sustrato: TCuadro): Boolean;
{Regresa True sí el sustrato simple Sustrato ['1'..'7'] se encuentra en el
escenario en X,Y, o bien si el sustrato cmpuesto ['a'..] en X,Y] contiene
a Sustrato}
begin
  Result := False;
  if Sustrato in ['1'..'7'] then
  begin
    if Escenario.Cuadro[X, Y] in ['1'..'7'] then //Sustrato simple en XY de esce
      Result := Sustrato = Escenario.Cuadro[X, Y]
    else                                   //Sustrato mixto en X,Y del escenario
      Result := Escenario.JuegoSustratos.SustratoMixto
          [Ord(Escenario.Cuadro[X,Y])-64].Porcentajes[StrToInt(Sustrato)] <> 0;
  end;
end;

function TEntorno.GetCuadro(X, Y: Word): TCuadro;
begin
  Result := Escenario.Cuadro[X,Y];
end;

function TEntorno.GetNombreSustratos(i: Word): string;
begin
  Result := Escenario.JuegoSustratos.SustratoSimple[i].Nombre;
end;

procedure TEntorno.ElementosEn(X1, Y1, X2, Y2: Word;
  var Agentes: array of TAgente; var Dinamicos: array of TDinamico;
  var Oviposicion: array of TSitioOviposicion);
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to ListaAgentes.Contador do
  begin
    if (ListaAgentes.Elementos[i].X >= X1)
      and (ListaAgentes.Elementos[i].X <= X2)
        and (ListaAgentes.Elementos[i].Y >= Y1)
          and (ListaAgentes.Elementos[i].Y <= Y2) then
    begin
      if (j <= Length(Agentes) - 1) then
      begin
        Agentes[j] := ListaAgentes.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
  j := 0;
  for i := 1 to ListaDinamicos.Contador do
  begin
    if (ListaDinamicos.Elementos[i].X >= X1)
      and (ListaDinamicos.Elementos[i].X <= X2)
        and (ListaDinamicos.Elementos[i].Y >= Y1)
          and (ListaDinamicos.Elementos[i].Y <= Y2) then
    begin
      if (j <= Length(Dinamicos) - 1) then
      begin
        Dinamicos[j] := ListaDinamicos.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
  j := 0;
  for i := 1 to ListaOviposicion.Contador do
  begin
    if (ListaOviposicion.Elementos[i].X >= X1)
      and (ListaOviposicion.Elementos[i].X <= X2)
        and (ListaOviposicion.Elementos[i].Y >= Y1)
          and (ListaOviposicion.Elementos[i].Y <= Y2) then
    begin
      if (j <= Length(Oviposicion) - 1) then
      begin
        Oviposicion[j] := ListaOviposicion.Elementos[i];
        Inc(j);
      end
      else
        Break; //->
    end;  //if
  end;  //for
end;

function TEntorno.NumAgentesEn(X1, Y1, X2, Y2: Word): Word;
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to ListaAgentes.Contador do
  begin
    if (ListaAgentes.Elementos[i].X >= X1)
      and (ListaAgentes.Elementos[i].X <= X2)
        and (ListaAgentes.Elementos[i].Y >= Y1)
          and (ListaAgentes.Elementos[i].Y <= Y2) then
      Inc(j);
  end;  //for
  Result := j;
end;

function TEntorno.NumDinamicosEn(X1, Y1, X2, Y2: Word): Word;
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to ListaDinamicos.Contador do
  begin
    if (ListaDinamicos.Elementos[i].X >= X1)
      and (ListaDinamicos.Elementos[i].X <= X2)
        and (ListaDinamicos.Elementos[i].Y >= Y1)
          and (ListaDinamicos.Elementos[i].Y <= Y2) then
    Inc(j);
  end;
  Result := j;
end;

function TEntorno.NumOviposicionEn(X1, Y1, X2, Y2: Word): Word;
var
  i, j: Integer;
begin
   j := 0;
  for i := 1 to ListaOviposicion.Contador do
  begin
    if (ListaOviposicion.Elementos[i].X >= X1)
      and (ListaOviposicion.Elementos[i].X <= X2)
        and (ListaOviposicion.Elementos[i].Y >= Y1)
          and (ListaOviposicion.Elementos[i].Y <= Y2) then
    Inc(j);
  end;
  Result := j;
end;

function TEntorno.NumSustratosMixtos: Word;
begin
  Result := Escenario.JuegoSustratos.NumMixtos;
end;

function TEntorno.GetMixtos(i: Integer): TSustratoMixto;
begin
  if i <= Escenario.JuegoSustratos.NumMixtos then
    Result := Escenario.JuegoSustratos.SustratoMixto[i]
  else
    raise EFueraDeRango.Create('El índice solicitado esta fuera del arreglo'
        + ' de sustratos mixtos. [Entorno.GetMixtos]');
end;

function TEntorno.DinamicoContiguo(Agente: TAgente;
  TipoED: Word): TDinamico;
{Regresa el elemento dinámico del tipo TipoED (1 al 5 según tipo de elemento)
al agente Agente, la prioridad para elegir el elemento regresado es:
5, 2, 1, 3, 4, 6, 7, 9, 8 según el siguiente esquema:
1 2 3
4 5 6
7 8 9
en donde 5 es el cuadro que ocupa un agente con dirección norte.
En caso de haber elementos traslapados del mismo tipo en el cuadro de máxima
prioridad, se realiza un sorteo para elegir el elemento devuelto.}
type
  TPrioridad = record
    N: Integer;
    Prioridad: Byte;
  end;
var
  i, j,
  nElementos,
  nEmpatados: Integer;
  sElementos: string;
  Dinamico: TDinamico;
  Prioridades: array of TPrioridad;
  Prioridad: TPrioridad;
  Bandera: Boolean;
  MaxPrioridad: Byte;
begin
  with Agente do
  begin
    sElementos := Percepciones.DinamicosPercibidos[TipoED];
    nElementos := NElementosEn(sElementos) - 1;
    SetLength(Prioridades, nElementos);
    for i := 0 to nElementos - 1 do
    begin
      j := StrToInt(ObtenNsimo(sElementos, i+1));
      if TipoED = 5 then  //Sitio de oviposicion
        Dinamico := ListaOviposicion.Elementos[j]
      else                //Cualquier otro tipo de elemento dinámico
        Dinamico := ListaDinamicos.Elementos[j];
      if nElementos = 1 then
      begin
        Result := Dinamico;
        Exit; //-->
      end;
      Prioridades[i].N := i + 1;
      case DireccionRelativaA(Direccion, X, Y, Dinamico.X, Dinamico.Y) of
        drNO: Prioridades[i].Prioridad := 3;
        drN : Prioridades[i].Prioridad := 2;
        drNE: Prioridades[i].Prioridad := 4;
        drO : Prioridades[i].Prioridad := 5;
        drE : Prioridades[i].Prioridad := 6;
        drSO: Prioridades[i].Prioridad := 7;
        drS : Prioridades[i].Prioridad := 9;
        drSE: Prioridades[i].Prioridad := 8;
        drT : Prioridades[i].Prioridad := 1;
      end;  //case
    end;  //for
  end;  //with Agente
  repeat
    Bandera := False;     //Ordenación por prioridades
    for i := 0 to Length(Prioridades) - 2 do
    begin
      if Prioridades[i].Prioridad > Prioridades[i+1].Prioridad then
      begin
        Prioridad := Prioridades[i];
        Prioridades[i] := Prioridades[i+1];
        Prioridades[i+1] := Prioridad;
        Bandera := True;
      end;
    end;
  until not Bandera;
  MaxPrioridad := Prioridades[0].Prioridad;
  nEmpatados := 0;
  for i := 1 to Length(Prioridades) - 1 do
    if Prioridades[i].Prioridad = MaxPrioridad then
      Inc(nEmpatados);
  if TipoED = 5 then
  begin
    if nEmpatados = 0 then
      Result := ListaOviposicion.Elementos[Prioridades[0].N]
    else
      Result := ListaOviposicion.Elementos[Prioridades[Dado(nEmpatados+1)-1].N];
  end
  else
  begin
    if nEmpatados = 0 then
      Result := ListaDinamicos.Elementos[Prioridades[0].N]
    else
      Result := ListaDinamicos.Elementos[Prioridades[Dado(nEmpatados+1)-1].N];
  end;
end;

function TEntorno.AgenteAdultoContiguo(Agente: TAgente): TAgente;
{Regresa el adulto contiguo al agente Agente, la prioridad para elegir el
agente regresado es:
5, 2, 1, 3, 4, 6, 7, 9, 8 según el siguiente esquema:
1 2 3
4 5 6
7 8 9
en donde 5 es el cuadro que ocupa un agente con dirección norte.
En caso de haber agentes traslapados en el cuadro de máxima prioridad, se
realiza un sorteo para elegir al agente devuelto. Si el agente elegido no se
encuentra en estado esIndeciso, se regresa nil}
type
  TPrioridad = record
    N: Integer;
    Prioridad: Byte;
  end;
var
  i, j,
  nAgentes,
  nEmpatados: Integer;
  sAgentes: string;
  Contendiente: TAgente;
  Prioridades: array of TPrioridad;
  Prioridad: TPrioridad;
  Bandera: Boolean;
  MaxPrioridad: Byte;
begin
  with Agente do
  begin
    sAgentes := '';
    for i := 0 to Juego.NumPrototiposM - 1 do
      if Percepciones.AgentesPercibidos[Juego.NumEstadios + i] <> '' then
        sAgentes := sAgentes
            + Percepciones.AgentesPercibidos[Juego.NumEstadios + i];
    for i := 0 to Juego.NumPrototiposH - 1 do
      if Percepciones.AgentesPercibidos
          [Juego.NumEstadios + Juego.NumPrototiposM + i] <> '' then
        sAgentes := sAgentes
            + Percepciones.AgentesPercibidos
                [Juego.NumEstadios + Juego.NumPrototiposM + i];
    nAgentes := NElementosEn(sAgentes) - 1;
    SetLength(Prioridades, nAgentes);
    for i := 0 to nAgentes - 1 do
    begin
      j := StrToInt(ObtenNsimo(sAgentes, i+1));
      Contendiente := ListaAgentes.Elementos[j];
      if nAgentes = 1 then
      begin
        Result := Contendiente;
        Exit; //-->
      end;
      Prioridades[i].N := i + 1;
      case
          DireccionRelativaA(Direccion, X, Y, Contendiente.X, Contendiente.Y) of
        drNO: Prioridades[i].Prioridad := 3;
        drN : Prioridades[i].Prioridad := 2;
        drNE: Prioridades[i].Prioridad := 4;
        drO : Prioridades[i].Prioridad := 5;
        drE : Prioridades[i].Prioridad := 6;
        drSO: Prioridades[i].Prioridad := 7;
        drS : Prioridades[i].Prioridad := 9;
        drSE: Prioridades[i].Prioridad := 8;
        drT : Prioridades[i].Prioridad := 1;
      end;  //case
    end;  //for
  end;  //with Agente
  repeat
    Bandera := False;     //Ordenación por prioridades
    for i := 0 to Length(Prioridades) - 2 do
    begin
      if Prioridades[i].Prioridad > Prioridades[i+1].Prioridad then
      begin
        Prioridad := Prioridades[i];
        Prioridades[i] := Prioridades[i+1];
        Prioridades[i+1] := Prioridad;
        Bandera := True;
      end;
    end;
  until not Bandera;
  MaxPrioridad := Prioridades[0].Prioridad;
  nEmpatados := 0;
  for i := 1 to Length(Prioridades) - 1 do
    if Prioridades[i].Prioridad = MaxPrioridad then
      Inc(nEmpatados);
  if nEmpatados = 0 then
    Result := ListaAgentes.Elementos[Prioridades[0].N]
  else
    Result := ListaAgentes.Elementos[Prioridades[Dado(nEmpatados+1)-1].N];
  if (Result.Estado <> esIndeciso) or (Result.Situacion <> stRegular) then
    Result := nil;
end;

function TEntorno.AgenteAdultoSexoOpuestoContiguo(
  Agente: TAgente): TAgente;
{Regresa el adulto de sexo opuesto contiguo al agente Agente, la prioridad para
elegir el agente regresado es:
5, 2, 1, 3, 4, 6, 7, 9, 8 según el siguiente esquema:
1 2 3
4 5 6
7 8 9
en donde 5 es el cuadro que ocupa un agente con dirección norte.
En caso de haber agentes traslapados en el cuadro de máxima prioridad, se
realiza un sorteo para elegir al agente devuelto. Si el agente elegido no se
encuentra en estado esIndeciso, se regresa nil}
type
  TPrioridad = record
    N: Integer;
    Prioridad: Byte;
  end;
var
  i, j,
  nAgentes,
  nEmpatados: Integer;
  sAgentes: string;
  Contendiente: TAgente;
  Prioridades: array of TPrioridad;
  Prioridad: TPrioridad;
  Bandera: Boolean;
  MaxPrioridad: Byte;
begin
  with Agente do
  begin
    sAgentes := '';
    case Sexo of
      sxMacho:
        for i := 0 to Juego.NumPrototiposH - 1 do
          if Percepciones.AgentesPercibidos
              [Juego.NumEstadios + Juego.NumPrototiposM + i] <> '' then
            sAgentes := sAgentes
                + Percepciones.AgentesPercibidos
                    [Juego.NumEstadios + Juego.NumPrototiposM + i];
      sxHembra:
        for i := 0 to Juego.NumPrototiposM - 1 do
          if Percepciones.AgentesPercibidos[Juego.NumEstadios + i] <> '' then
            sAgentes := sAgentes
                + Percepciones.AgentesPercibidos[Juego.NumEstadios + i];
    end;
    nAgentes := NElementosEn(sAgentes) - 1;
    SetLength(Prioridades, nAgentes);
    for i := 0 to nAgentes - 1 do
    begin
      j := StrToInt(ObtenNsimo(sAgentes, i+1));
      Contendiente := ListaAgentes.Elementos[j];
      if nAgentes = 1 then
      begin
        Result := Contendiente;
        Exit; //-->
      end;
      Prioridades[i].N := j;
      case
          DireccionRelativaA(Direccion, X, Y, Contendiente.X, Contendiente.Y) of
        drNO: Prioridades[i].Prioridad := 3;
        drN : Prioridades[i].Prioridad := 2;
        drNE: Prioridades[i].Prioridad := 4;
        drO : Prioridades[i].Prioridad := 5;
        drE : Prioridades[i].Prioridad := 6;
        drSO: Prioridades[i].Prioridad := 7;
        drS : Prioridades[i].Prioridad := 9;
        drSE: Prioridades[i].Prioridad := 8;
        drT : Prioridades[i].Prioridad := 1;
      end;  //case
    end;  //for
  end;  //with Agente
  repeat
    Bandera := False;     //Ordenación por prioridades
    for i := 0 to Length(Prioridades) - 2 do
    begin
      if Prioridades[i].Prioridad > Prioridades[i+1].Prioridad then
      begin
        Prioridad := Prioridades[i];
        Prioridades[i] := Prioridades[i+1];
        Prioridades[i+1] := Prioridad;
        Bandera := True;
      end;
    end;
  until not Bandera;
  MaxPrioridad := Prioridades[0].Prioridad;
  nEmpatados := 0;
  for i := 1 to Length(Prioridades) - 1 do
    if Prioridades[i].Prioridad = MaxPrioridad then
      Inc(nEmpatados);
  if nEmpatados = 0 then
    Result := ListaAgentes.Elementos[Prioridades[0].N]
  else
    Result := ListaAgentes.Elementos[Prioridades[Dado(nEmpatados+1)-1].N];
  if (Result.Estado <> esIndeciso) or (Result.Situacion <> stRegular) then
    Result := nil;
end;

function TEntorno.GetSimples(i: Word): TSustratoSimple;
begin
  if i <= 7 then
    Result := Escenario.JuegoSustratos.SustratoSimple[i]
  else
    raise EFueraDeRango.Create('El índice solicitado esta fuera del arreglo'
        + ' de sustratos mixtos. [Entorno.GetSimples]');
end;

end.
