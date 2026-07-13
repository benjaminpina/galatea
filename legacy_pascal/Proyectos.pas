unit Proyectos;

{$MODE Delphi}

interface

uses
  Comunes, Entornos, Agentes, Mediadores,
  Promediadores, Carruseles, Elementos, Classes;

type

  {Tipos}

  TStatus = (stEjecutando, stPausa, stParado);

  TEventoCiclo = procedure(Sender: TObject; Ciclo: Integer; Info: TStringList)
      of object;
  TEventoNuevoAgente = procedure (Sender: TObject; Agente: TAgente) of object;
  TEventoNuevoAdulto = procedure (Sender: TObject; Agente: TAgente) of object;
  TEventoNuevoHuevo = procedure (Sender: TObject; Huevo: THuevo) of object;

  {Clases}

  TProyecto = class (TGuardable)
  private
    //Plataforma: TPaintBox;
    Mediador: TMediador;
    FStatus: TStatus;
    FRetardo: Word;
    FEntorno: TEntorno;
    FOnCiclo: TEventoCiclo;
    Carrusel: TCarrusel;
    FOnNuevoAgente: TEventoNuevoAgente;
    FOnNuevoHuevo: TEventoNuevoHuevo;
    Info: TStringList;
    PromediaTendencias: array [1..8] of TPromediador;
    PromediaProbaDecision: array [1..13] of TPromediador;
    FOnNuevoAdulto: TEventoNuevoAdulto;
    function SiguienteEstadio(Agente: TAgente; PPrototipo: Word): Word;
    function PrototipoAsignado(Agente: TAgente): Word;
    procedure Itera;
    procedure ProveePercepciones(Huevo: THuevo); overload;
    procedure ProveePercepciones(Agente: TAgente); overload;
    procedure ProveePercepcionesSustratos(Agente: TAgente);
    procedure ProveePercepcionesDinamicos(Agente: TAgente);
    procedure ProveePercepcionesAgentes(Agente: TAgente);
    procedure EstableceInteracciones(Agente: TAgente);
    procedure EstableceInteraccionesConDinamicos(Agente: TAgente);
    procedure EstableceInteraccionesConAgentes(Agente: TAgente);
    procedure ActualizaMemoria(Agente: TAgente);
    procedure SetRetardo(const Value: Word);
    procedure SetEntorno(const Value: TEntorno);
    procedure CobraNutrimentos(Agente:TAgente);
    procedure ProveeValoresReferencia(Agente: TAgente);
    procedure EvaluaHuevo(Huevo: THuevo);
    procedure Eclosion(Huevo: THuevo);
    procedure EvaluaPasoEstadio(Agente: TAgente);
    procedure Copula(Agente: TAgente);
    procedure Oviposita(Agente: TAgente);
    procedure DinamicaCortejo(Agente: TAgente);
    procedure DinamicaCombate(Agente: TAgente);
    procedure EvitaSalida(Agente: TAgente);
    function SustratoListado(Sustrato: TCuadro): Word;
  public
    Titulo: string[80];
    Comentarios: string;
    ArchivoEntorno: string;
    Visualizar: Boolean;
    constructor Create{(PPlataforma: TPaintBox)};
    destructor Destroy; override;
    procedure Ejecutar;
    procedure Detener;
    procedure Pausa;
    procedure Paso;
    procedure Carga(NombreArchivo: string); override;
    procedure Guarda(NombreArchivo: string); override;
    property Entorno: TEntorno
      read FEntorno write SetEntorno;
    property Status: TStatus
      read FStatus write FStatus;
    property Retardo: Word
      read FRetardo write SetRetardo;
    property OnCiclo: TEventoCiclo
      read FOnCiclo write FOnCiclo;
    property OnNuevoAgente: TEventoNuevoAgente
      read FOnNuevoAgente write FOnNuevoAgente;
    property OnNuevoAdulto: TEventoNuevoAdulto
      read FOnNuevoAdulto write FOnNuevoAdulto;
    property OnNuevoHuevo: TEventoNuevoHuevo
      read FOnNuevoHuevo write FOnNuevoHuevo;
  end;

implementation

uses
  {$IFDEF LCL}Forms, {$ENDIF} SysUtils,
  	FuncElementosCadenas;

{ TProyecto }

constructor TProyecto.Create{(PPlataforma: TPaintBox)};
var
  i: Integer;
begin
  Titulo := '';
  Comentarios := '';
  //Plataforma := PPlataforma;
  FStatus := stParado;
  FRetardo := 0;
  Visualizar := True;
  Entorno := TEntorno.Create;//(PPlataforma);
  Carrusel := TCarrusel.Create;
  Info := TStringList.Create;
  for i := 1 to 8 do
    PromediaTendencias[i] := TPromediador.Create;
  for i := 1 to 13 do
    PromediaProbaDecision[i] := TPromediador.Create;
end;

procedure TProyecto.Carga(NombreArchivo: string);
//var
  //Lineas : TStringList;
begin
  inherited Carga(NombreArchivo);
  //Titulo := LeeValor('Titulo');
  //ArchivoEntorno := LeeValor('Entorno');
  ArchivoEntorno := NombreArchivo;
  //Lineas := LeeValorAmpliado('Comentarios');
  //Comentarios := Lineas.Text;
  //Lineas.Free;
end;

procedure TProyecto.Guarda(NombreArchivo: string);
var
  Lineas : TStringList;
begin
  Reestablece;
  EscribeValor('Titulo', Titulo);
  EscribeValor('Entorno', ArchivoEntorno);
  Lineas := TStringList.Create;
  Lineas.Text := Comentarios;
  EscribeValor('Comentarios', Lineas);
  Lineas.Free;
  inherited Guarda(NombreArchivo);
end;

destructor TProyecto.Destroy;
var
  i: Integer;
begin
  Entorno.Free;
  Mediador.Free;
  Info.Free;
  Carrusel.Free;
  for i := 1 to 8 do
    PromediaTendencias[i].Free;
  for i := 1 to 13 do
     PromediaProbaDecision[i].Free;
  inherited Destroy;
end;

procedure TProyecto.Itera;
var
  Ini,
  i, j, k: Integer;
  Linea: string;
  Sentido: TSentido;
  Agente: TAgente;
  Huevo: THuevo;
  ListaHuevosMuertos: array of THuevo;
  ListaMuertos,
  ListaCopulantes: array of TAgente;
  Cont: array of Integer;
begin
  with Entorno.Juego do
    SetLength(Cont, NumEstadios + NumPrototiposM + NumPrototiposH);
  Info.Clear;
  Info.Add('');
  with Entorno do
  begin
    Ini := Dado(ListaAgentes.Contador); //Sorteo primer agente
    if Volado then                      //Sorteo sentido del recorrido
      Sentido := snDerecha
    else
      Sentido := snIzquierda;
    Carrusel.Inicializa(ListaAgentes.Contador, Sentido, Ini);
    for i := 1 to ListaAgentes.Contador do
    begin
      j := Carrusel.N;
      Agente := ListaAgentes.Elementos[j];
      Agente.IncrementaEdad;
      Mediador.Agente := Agente;
      ProveeValoresReferencia(Agente);
      if Agente.Situacion = stCombate then
        DinamicaCombate(Agente)
      else if Agente.Situacion = stCortejo then
        DinamicaCortejo(Agente)
      else
        ProveePercepciones(Agente);
      ActualizaMemoria(ListaAgentes.Elementos[i]);
    end;
    for i := 1 to ListaAgentes.Contador do
    begin
      Agente := ListaAgentes.Elementos[i];
      Agente.Decide;
      EstableceInteracciones(Agente);
    end;
    j := 0;
    k := 0;
    for i := 1 to ListaAgentes.Contador do
    begin
      Agente := ListaAgentes.Elementos[i];
     	//ProveeValoresReferencia(Agente);
      Agente.Actua;
      CobraNutrimentos(Agente);
      Agente.Actualiza;
      if not Agente.Adulto then
        EvaluaPasoEstadio(Agente);
      if Agente.Situacion = stMuerto then
      begin
        j := Length(ListaMuertos) + 1;
        SetLength(ListaMuertos, j);
        ListaMuertos[j - 1] := Agente;
      end;  //if
      if (Agente.Situacion = stCortejo) and (Agente.Decision = 14) and
          (Agente.Memoria.UltAccionContendiente = 3) then
      begin
        k := Length(ListaCopulantes) + 1;
        SetLength(ListaCopulantes, k);
        ListaCopulantes[k - 1] := Agente;
      end;
      if Agente.Decision = 11 then //Ovipositar
        Oviposita(Agente);
      Mediador.Agente := Agente;
      Inc(Cont[Mediador.PrototipoListado - 1]);
      Linea := Agente.Nombre + '='
          + AgenteAStringVar(Agente, Entorno.Juego);
      Info.Add(Linea);
    end;  //for ListaAgentes
    for i := 1 to j do
      ListaAgentes.Retira(ListaMuertos[i-1]); //Eliminando muertos
    for i := 1 to k do
      if Assigned(ListaCopulantes[i-1]) then
        Copula(ListaCopulantes[i-1]);           //Realizando cópulas
    for i := 1 to ListaHuevos.Contador do
    begin
      Huevo := ListaHuevos.Elementos[i];
      ProveePercepciones(Huevo);
      Huevo.Decide;
      Huevo.Actualiza;
      EvaluaHuevo(Huevo);
    end;
    j := 0;
    for i := 1 to ListaHuevos.Contador do
    begin
      Huevo := ListaHuevos.Elementos[i];
      if Huevo.Decision = 2 then
      begin
        j := Length(ListaHuevosMuertos) + 1;
        SetLength(ListaHuevosMuertos, j);
        ListaHuevosMuertos[j-1] := Huevo;
      end;
    end;
    for i := 1 to j do
      ListaHuevos.Retira(ListaHuevosMuertos[i-1]);  //Elimina huevos muertos
    for i := 1 to ListaDinamicos.Contador do
      ListaDinamicos.Elementos[i].Actualiza;
    Cont[0] := ListaHuevos.Contador;
  end;  //with Entorno
  Linea := '';
  for i := 0 to Length(Cont) - 1 do
    Linea := Linea + IntToStr(Cont[i]) + ', ';
  Info.Strings[0] := Linea;
end;

procedure TProyecto.Detener;
begin
  FStatus := stParado;
end;

procedure TProyecto.Ejecutar;
begin
  FStatus := stEjecutando;
  while FStatus = stEjecutando do
  begin
    Inc(Entorno.Ciclos);
    Itera;
    if Visualizar then
       Entorno.Despliega;
    {$IFDEF LCL}
    Application.HandleMessage;
    Application.ProcessMessages;
    {$ENDIF} 
    if Assigned(FOnCiclo) then
      TEventoCiclo(FOnCiclo)(Self, Entorno.Ciclos, Info);
  end;
end;

procedure TProyecto.Paso;
begin
  FStatus := stEjecutando;
  Inc(Entorno.Ciclos);
  Itera;
  if Visualizar then
    Entorno.Despliega;
  if Assigned(FOnCiclo) then
    TEventoCiclo(FOnCiclo)(Self, Entorno.Ciclos, Info);
  FStatus := stPausa;
end;

procedure TProyecto.Pausa;
begin
  FStatus := stPausa;
end;

procedure TProyecto.SetRetardo(const Value: Word);
begin
  FRetardo := Value;
end;

procedure TProyecto.SetEntorno(const Value: TEntorno);
begin
  FEntorno := Value;
  if Assigned(Mediador) then
    Mediador.Free;
  Mediador := TMediador.Create(FEntorno);
end;

procedure TProyecto.CobraNutrimentos(Agente: TAgente);
var
  s: string;
begin
  Mediador.Agente := Agente;
  s := 'Costo';
  case Agente.Decision of
    1 : s := s + 'Mover';
    2 : s := s + 'Reposar';
    3 : s := s + 'Beber';
    4 : s := s + 'ComerAzucar';
    5 : s := s + 'ComerGrasa';
    6 : s := s + 'ComerProteina';
    7 : s := s + 'Desplegar';
    8 : s := s + 'Escalar';
    9 : s := s + 'IntentoDesplegado';
    10: s := s + 'IntentoEscalado';
    11: s := s + 'Ovipositar';
    12: Exit; //--> Morir
    13: s := s + 'Retirar';
    14: s := s + 'Aceptar';
    15: s := s + 'Rechazar';
    16: s := s + 'Reposar'; //Ganar pelea
    17: s := s + 'Copular';
  end;
  Agente.Reservas.Agua := RestaMin(Agente.Reservas.Agua,
      Mediador.ValorEntero[s+'Agua'], 0);
  Agente.Reservas.Azucar := RestaMin(Agente.Reservas.Azucar,
      Mediador.ValorEntero[s+'Azucar'], 0);
  Agente.Reservas.Grasa := RestaMin(Agente.Reservas.Grasa,
      Mediador.ValorEntero[s+'Grasa'], 0);
  Agente.Reservas.Proteina := RestaMin(Agente.Reservas.Proteina,
      Mediador.ValorEntero[s+'Proteina'], 0);
end;

procedure TProyecto.ProveeValoresReferencia(Agente: TAgente);
var
  i: Integer;
begin
  Mediador.Agente := Agente;
  with Agente.Referencia do
  begin
    for i := 1 to 4 do
    begin
      Minimos [i] := Mediador.ValorEntero['Minimo'+NombreNut[i]];
      Criticos[i] := Mediador.ValorEntero['Critico'+NombreNut[i]];
      Optimos [i] := Mediador.ValorEntero['Optimo'+NombreNut[i]];
      Maximos [i] := Mediador.ValorEntero['Maximo'+NombreNut[i]];
    end;
    if Agente.Adulto then
    begin
        Longevidad := Mediador.ValorEntero['Longevidad'];
        if Agente.Sexo = sxMacho then
          MaxGametos := Mediador.ValorEntero['MaximoPaquetes']
        else
          MaxGametos := Mediador.ValorEntero['MaximoHuevos'];
        for i := 1 to 4 do
          if Agente.Sexo = sxMacho then
            CostosGametos[i] :=
                Mediador.ValorEntero['CostoPaquete'+NombreNut[i]]
          else
            CostosGametos[i] := Mediador.ValorEntero['CostoHuevo'+NombreNut[i]];
        if Agente.Sexo = sxHembra then
        begin
          MaxPaqAlmacenados :=
              Mediador.ValorEntero['MaximoPaquetesAlmacenados'];
          TasaConsumoPaq := Mediador.Valor1_0['TasaConsumoPaquete'];
          OvipositadosCiclo := Mediador.ValorEntero['OvipositadosCiclo'];
          TasaDegradacion := Mediador.Valor1_0['TasaDegradacionEsperma'];
          FraccHuevo := Mediador.Valor1_0['FraccionHuevo'];
          PropMachos := Mediador.ValorEntero['ProporcionMachos'];
          PropHembras := Mediador.ValorEntero['ProporcionHembras'];
        end;
        if Agente.Situacion = stCortejo then
        begin
          Mediador.Contendiente := Agente.Interactuante as TAgente;
          if Agente.Sexo = sxMacho then
            PaqTransferidos := Mediador.ValorEntero['PaquetesTransferidos']
          else
          begin
            FraccPaquete := Mediador.Valor1_0['FraccionPaquete'];
            FraccFertilizados := Mediador.Valor1_0['FraccionFertilizados'];
            ProbPaternidad := Mediador.ValorEntero['Paternidad'];
          end;
        end;
    end;
  end;
end;

procedure TProyecto.ProveePercepciones(Huevo: THuevo);
begin
  Mediador.Huevo := Huevo;
  with Huevo do
  begin
    if Assigned(Portador) then
    begin
      try
        if Portador is TSitioOviposicion then
        begin
          Mediador.Dinamico := Portador as TSitioOviposicion;
          VDecision[1] := Mediador.InteraccionDinamicos[5,1,2];
          VDecision[2] := Mediador.InteraccionDinamicos[5,1,12];
        end
        else if Portador is TAgente then
        begin
          Mediador.Agente := Portador as TAgente;
          VDecision[1] :=
              Mediador.InteraccionAgentes[Mediador.PrototipoListado,1,2];
          VDecision[2] :=
              Mediador.InteraccionAgentes[Mediador.PrototipoListado,1,12];
        end
        else    //Portador desaparecido (agente muerto)
        begin   //Forzar muerte
          VDecision[1] := 0;
          VDecision[2] := 1;
        end;
      except
        VDecision[1] := 0;  //Error de verificación de tipo
        VDecision[2] := 1;  //Portador inexistente (agente muerto)
        Huerfano;     //Poniendo Portador a nil
      end;
    end;
    if (VDecision[1] = 0) and (VDecision[2] = 0) then
      VDecision[1] := 1;
  end;
end;

procedure TProyecto.EvaluaHuevo(Huevo: THuevo);
{Si el huevo debe pasar al siguiente estadio, realiza la conversión,
esto es, convertirlo en agente}
var
  Cond1, Val1,
  Cond2, Val2: Real;
  Op1, Op2: string;
  Condiciones,
  ReqCubiertos,
  CiclosSigEstadio,
  SigEstadio: Boolean;
begin
  SigEstadio := False;
  with Entorno.Juego.Estadios[1] do
  begin
    Mediador.Huevo := Huevo;
    CiclosSigEstadio := Huevo.Edad >= Mediador.ValorEntero['CiclosEstadio1'];
    ReqCubiertos :=
        (Huevo.Reservas.Agua
            >= Mediador.ValorEntero['RequerimientoAgua1']) and
        (Huevo.Reservas.Azucar
            >= Mediador.ValorEntero['RequerimientoAzucar1']) and
        (Huevo.Reservas.Grasa
            >= Mediador.ValorEntero['RequerimientoGrasa1']) and
        (Huevo.Reservas.Proteina
            >= Mediador.ValorEntero['RequerimientoProteina1']);
    Cond1 := Mediador.ValorReal['Condicion1Estadio1'];
    Cond2 := Mediador.ValorReal['Condicion2Estadio1'];
    Op1 := ObtenNsimo(Condicion1, 2);
    Op2 := ObtenNsimo(Condicion2, 2);
    Val1 := StrToFloat(ObtenNsimo(Condicion1, 3));
    Val2 := StrToFloat(ObtenNsimo(Condicion2, 3));
    if Y_OC1C2 then
      Condiciones := Logica(Cond1, Op1, Val1) and Logica(Cond2, Op2, Val2)
    else
      Condiciones := Logica(Cond1, Op1, Val1) or Logica(Cond2, Op2, Val2);
    if Y_O and Y_OR then
      SigEstadio := CiclosSigEstadio and ReqCubiertos and Condiciones
    else if (not Y_O) and Y_OR then
      SigEstadio := CiclosSigEstadio or ReqCubiertos and Condiciones
    else if Y_O and (not Y_OR) then
      SigEstadio := CiclosSigEstadio and ReqCubiertos or Condiciones
    else if (not Y_O ) and (not Y_OR) then
      SigEstadio := CiclosSigEstadio or ReqCubiertos or Condiciones;
    Mediador.Huevo := nil;
    if SigEstadio then
      Eclosion(Huevo);
  end;
end;

procedure TProyecto.Eclosion(Huevo: THuevo);
{Convierte un huevo en agente}
var
  Agente: TAgente;
  Prototipo,
  Estadio,
  i: Integer;
begin
  Huevo.Decision := 2;
  i := Entorno.ListaAgentes.Agrega(TAgente.Create{(Plataforma)});
  Agente := Entorno.ListaAgentes.Elementos[i];
  Mediador.Agente := Agente;
  Mediador.Huevo := Huevo;
  with Huevo.Reservas do
  begin     //Deducción de costos de cambio de estadio
    Agua := Agua - Mediador.ValorEntero['CostoAgua1'];
    Azucar := Azucar - Mediador.ValorEntero['CostoAzucar1'];
    Grasa := Grasa - Mediador.ValorEntero['CostoGrasa1'];
    Proteina := Proteina - Mediador.ValorEntero['CostoProteina1'];
  end;
  Mediador.Huevo := nil;
  Agente.Reservas := Huevo.Reservas;
  Agente.Genotipo := Huevo.Genotipo;
  Agente.Inicializa(Entorno.Juego, Huevo.Padre, Huevo.Madre, 1, 0,
      0, Huevo.Sexo);
  Prototipo :=  PrototipoAsignado(Agente);
  Estadio := SiguienteEstadio(Agente, Prototipo);
  Agente.Inicializa(Entorno.Juego, Huevo.Padre, Huevo.Madre, Estadio, Prototipo,
      0, Huevo.Sexo);
  Agente.Nombre := Huevo.Nombre;
  Agente.X := Huevo.Portador.X;
  Agente.Y := Huevo.Portador.Y;
  Agente.Color := Mediador.Color;
  if Assigned(FOnNuevoAgente) then
    TEventoNuevoAgente(FOnNuevoAgente)(Self, Agente);
end;

function TProyecto.SiguienteEstadio(Agente: TAgente; PPrototipo: Word): Word;
var
  i: Integer;
  Actual: Word;
begin
  Actual := Agente.Estadio;
  with Entorno.Juego do
  begin
    if Actual < NumEstadios then
    begin
      if (PPrototipo = 0) and (Estadios[Actual+1].Prototipo = 0) then
        Result := Actual + 1  //Sig estadio no ligado
      else
      begin
        Result := NumEstadios + 1;
        if Agente.Sexo = sxHembra then
          PPrototipo := PPrototipo + NumPrototiposM;
        for i := Actual + 1 to NumEstadios do
          if (Estadios[i].Prototipo = PPrototipo)
              or (Estadios[i].Prototipo = 0) then
            Result := i;  //Buscar sig estadio ligado al prototipo ligado actual
      end;
    end
    else
      Result := Actual + 1;
  end; //with
end;

function TProyecto.PrototipoAsignado(Agente: TAgente): Word;
var
  i, j: Integer;
  Estadio: Word;
  Cond, Val: Real;
  Op : string;
begin
  Result := 0;
  Estadio := Agente.Estadio;
  with Entorno.Juego do
  begin
    if Estadio < NumEstadios then
    begin
      if Estadios[Estadio + 1].Prototipo = 0 then  //Sig estadio no está ligado
      begin
        Result := Agente.Prototipo;
        Exit; //-->
      end;
    end;
    if (Agente.Sexo = sxMacho) and (NumPrototiposM = 1) then
    begin
      Result := 1;
      Exit;  //-->
    end;
    if (Agente.Sexo = sxHembra) and (NumPrototiposH = 1) then
    begin
      Result := 1;
      Exit; //-->
    end;
    case Agente.Sexo of
      sxMacho:
      begin
        Result := StrToInt(ObtenNsimo(JerarquiaM, 1));
        for i := 1 to NumPrototiposM do
        begin
          j := StrToInt(ObtenNsimo(JerarquiaM, i));
          Cond := Mediador.ValorReal['CriterioAsignacionMacho' + IntToStr(j)];
          Op := CriteriosM[1,j-1];
          Val := StrToFloat(CriteriosM[2,j-1]);
          if Logica(Cond, Op, Val) then
          begin
            Result := j;
            Exit; //-->
          end;
        end;
      end;
      sxHembra:
      begin
        Result := StrToInt(ObtenNsimo(JerarquiaH, 1));
        for i := 1 to NumPrototiposH do
        begin
          j := StrToInt(ObtenNsimo(JerarquiaH, i));
          Cond := Mediador.ValorReal['CriterioAsignacionHembra' + IntToStr(j)];
          Op := CriteriosH[1,j-1];
          Val := StrToFloat(CriteriosH[2,j-1]);
          if Logica(Cond, Op, Val) then
          begin
            Result := j;
            Exit; //-->;
          end;
        end;
      end;
    end;  //case Agente.Sexo
  end;  //with Entorno.Juego
end;

procedure TProyecto.EvaluaPasoEstadio(Agente: TAgente);
{Evalua si el agente debe pasar al siguiente estadio, y en su caso realiza
el cambio.}
var
  nPrototipo,
  nEstadio: Word;
  i, j: Integer;
  Cond1, Val1,
  Cond2, Val2: Real;
  Op1, Op2: string;
  Condiciones,
  ReqCubiertos,
  CiclosSigEstadio,
  SigEstadio: Boolean;
  MorfoGenCont: array [1..15] of Real;
  MorfoGenDisc: array [1..15] of Integer;
  s: string;
begin
  SigEstadio := False;
  i := Agente.Estadio;
  with Entorno.Juego.Estadios[i] do
  begin
    CiclosSigEstadio := Agente.Edad
        >= Mediador.ValorEntero['CiclosEstadio' + IntToStr(i)];
    ReqCubiertos :=
        (Agente.Reservas.Agua
            >= Mediador.ValorEntero['RequerimientoAgua' + IntToStr(i)]) and
        (Agente.Reservas.Azucar
            >= Mediador.ValorEntero['RequerimientoAzucar' + IntToStr(i)]) and
        (Agente.Reservas.Grasa
            >= Mediador.ValorEntero['RequerimientoGrasa' + IntToStr(i)]) and
        (Agente.Reservas.Proteina
            >= Mediador.ValorEntero['RequerimientoProteina' + IntToStr(i)]);
    Cond1 := Mediador.ValorReal['Condicion1Estadio' + IntToStr(i)];
    Cond2 := Mediador.ValorReal['Condicion2Estadio' + IntToStr(i)];
    Op1 := ObtenNsimo(Condicion1, 2);
    Op2 := ObtenNsimo(Condicion2, 2);
    Val1 := StrToFloat(ObtenNsimo(Condicion1, 3));
    Val2 := StrToFloat(ObtenNsimo(Condicion2, 3));
    if Y_OC1C2 then
      Condiciones := Logica(Cond1, Op1, Val1) and Logica(Cond2, Op2, Val2)
    else
      Condiciones := Logica(Cond1, Op1, Val1) or Logica(Cond2, Op2, Val2);
    if Y_O and Y_OR then
      SigEstadio := CiclosSigEstadio and ReqCubiertos and Condiciones
    else if (not Y_O) and Y_OR then
      SigEstadio := CiclosSigEstadio or ReqCubiertos and Condiciones
    else if Y_O and (not Y_OR) then
      SigEstadio := CiclosSigEstadio and ReqCubiertos or Condiciones
    else if (not Y_O ) and (not Y_OR) then
      SigEstadio := CiclosSigEstadio or ReqCubiertos or Condiciones;
  end;  //with
  with Entorno.Juego do
  begin
    if SigEstadio then
    begin
      nPrototipo := PrototipoAsignado(Agente);
      nEstadio := SiguienteEstadio(Agente, nPrototipo);
      with Agente do
      begin
        Inicializa(Entorno.Juego ,Padre, Madre, nEstadio, nPrototipo, Edad,
            Sexo);
        if Adulto then
        begin
          if Sexo = sxMacho then
            Color := PrototiposM[Prototipo].Color
          else
            Color := PrototiposH[Prototipo].Color;
        end
        else
          Color := Estadios[Estadio].Color;
        //Fijar valores morfológicos congénitos
        for j := 1 to 15 do
        begin
          s := Entorno.Juego.Continuos[j].Nombre;
          MorfoGenCont[j] := Mediador.ValorReal[s + 'Genetico'];
          s := Entorno.Juego.Discretos[j].Nombre;
          MorfoGenDisc[j] := Mediador.ValorEntero[s + 'Genetico'];
        end;
        FijaMorfologia(MorfoGenCont, MorfoGenDisc);
        for j := 1 to 12 do
         VDecision[j] := 0;
           VDecision[2] := 1;  //Obligar a reposar
        if Assigned(FOnNuevoAdulto) then
          TEventoNuevoAdulto(FOnNuevoAdulto)(Self, Agente);
      end;
      with Agente.Reservas do
      begin     //Deducción de costos de cambio de estadio
        Agua := Agua - Mediador.ValorEntero['CostoAgua' + IntToStr(i)];
        Azucar := Azucar - Mediador.ValorEntero['CostoAzucar' + IntToStr(i)];
        Grasa := Grasa - Mediador.ValorEntero['CostoGrasa' + IntToStr(i)];
        Proteina :=
            Proteina - Mediador.ValorEntero['CostoProteina' + IntToStr(i)];
      end;
    end;  //if
  end;  //with Entorno.Juego
end;

procedure TProyecto.ActualizaMemoria(Agente: TAgente);
var
  i: Integer;
begin
  with Agente do
  begin
    for i := 1 to 7 do            //Actualizar memorias de percepción
      if Percepciones.PerSustratos[i] then
      begin
        Memoria.UltPerSust[i] := 0;
        Inc(Memoria.NumPerSust[i]);
      end
      else if Memoria.UltPerSust[i] <> - 1 then
        Inc(Memoria.UltPerSust[i]);
    for i := 1 to 5 do
    begin
      if Percepciones.PerDinamicos[i] then
      begin
        Memoria.UltPerDin[i] := 0;
        Inc(Memoria.NumPerDin[i]);
      end
      else if Memoria.UltPerDin[i] <> - 1 then
        Inc(Memoria.UltPerDin[i]);
      if Memoria.UltIntDin[i] <> - 1 then
        Inc(Memoria.UltIntDin[i]);
    end;
    for i := 0 to Entorno.Juego.NumEstadios - 1 do
    begin
      if Percepciones.PerEstadios[i] then
      begin
        Memoria.UltPerEstadios[i] := 0;
        Inc(Memoria.NumPerEstadios[i]);
      end
      else if Memoria.UltPerEstadios[i] <> - 1 then
        Inc(Memoria.UltPerEstadios[i]);
      if Memoria.UltIntEstadios[i] <> - 1 then
        Inc(Memoria.UltIntEstadios[i]);
    end;
    for i := 0 to Entorno.Juego.NumPrototiposM - 1 do
    begin
      if Percepciones.PerMachos[i] then
      begin
        Memoria.UltPerMachos[i] := 0;
        Inc(Memoria.NumPerMachos[i]);
      end
      else if Memoria.UltPerMachos[i] <> - 1 then
        Inc(Memoria.UltPerMachos[i]);
      if  Memoria.UltIntMachos[i] <> - 1 then
        Inc(Memoria.UltIntMachos[i]);
    end;
    for i := 0 to Entorno.Juego.NumPrototiposH - 1 do
    begin
      if Percepciones.PerHembras[i] then
      begin
        Memoria.UltPerHembras[i] := 0;
        Inc(Memoria.NumPerHembras[i]);
      end
      else if Memoria.UltPerHembras[i] <> - 1 then
        Inc(Memoria.UltPerHembras[i]);
      if Memoria.UltIntHembras[i] <> - 1 then
        Inc(Memoria.UltIntHembras[i]);
    end;
  end;  //with Agente
end;

procedure TProyecto.EstableceInteracciones(Agente: TAgente);
begin
  with Agente do
  begin
    Inc(Tiempo.InteraccionActual);
    if Situacion in [stCombate, stCortejo] then
      Exit; //-->
    case Decision of
      1, 2: Tiempo.InteraccionActual := 0;              //Mover, reposar
      3..6: EstableceInteraccionesConDinamicos(Agente); //Alimentación
      7..10: EstableceInteraccionesConAgentes(Agente);  //Pelea y cortejo
      11:                                               //Ovipositar
        if Percepciones.HayDinamicos[5] then
          EstableceInteraccionesConDinamicos(Agente)
        else
          EstableceInteraccionesConAgentes(Agente);
    end;
  end;  //with Agente
end;

{$WARNINGS OFF}
procedure TProyecto.EstableceInteraccionesConDinamicos(Agente: TAgente);
var
  Dinamico: TDinamico;
begin
  with Agente do
  begin
    case Decision of
      3 : Dinamico := Entorno.DinamicoContiguo(Agente, 1);//Beber
      4 : Dinamico := Entorno.DinamicoContiguo(Agente, 2);//Comer azucar
      5 : Dinamico := Entorno.DinamicoContiguo(Agente, 3);//Comer grasa
      6 : Dinamico := Entorno.DinamicoContiguo(Agente, 4);//Comer proteinas
      11: Dinamico := Entorno.DinamicoContiguo(Agente, 5);//Ovipositar
    end;
    Interactuante := Dinamico;
    if Agente.Decision in [3..6] then //Conductas alimentarias
    begin
      Mediador.Dinamico := Dinamico;
      Referencia.UnidadesTomadas :=
          Mediador.ValorEntero['Ganancia'+NombreNut[Dinamico.ElementoListado]];
      Memoria.UltIntDin[Dinamico.ElementoListado] := 0;
      Inc(Memoria.NumIntDin[Dinamico.ElementoListado]);
    end;  //if
  end;  //with Agente
end;

procedure TProyecto.EstableceInteraccionesConAgentes(Agente: TAgente);
var
  //i: Integer;
  Contendiente: TAgente;
begin
  with Agente do
  begin
    case Decision of
      7, 8: Contendiente := Entorno.AgenteAdultoContiguo(Agente);//Iniciar pelea
      11  : Contendiente := Entorno.AgenteAdultoContiguo(Agente);//Ovipositar
      9,10: Contendiente := Entorno.AgenteAdultoSexoOpuestoContiguo(Agente);
    end;                                                   //Iniciar cortejo
    if not Assigned(Contendiente) then
    begin
      ForzarReposo;
      Exit; //-->
    end;
    Interactuante := Contendiente;
    if Decision in [7..11] then //Iniciar pelea o cortejo u ovipositar en agente
    begin
      case Contendiente.Sexo of
        sxMacho:
        begin
          Memoria.UltIntMachos[Contendiente.Prototipo - 1] := 0;
          Inc(Memoria.NumIntMachos[Contendiente.Prototipo - 1]);
        end;
        sxHembra:
        begin
          Memoria.UltIntHembras[Contendiente.Prototipo - 1] := 0;
          Inc(Memoria.NumIntHembras[Contendiente.Prototipo - 1]);
        end;
      end;
      case Sexo of
        sxMacho:
        begin
          Contendiente.Memoria.UltIntMachos[Prototipo - 1] := 0;
          Inc(Contendiente.Memoria.NumIntMachos[Prototipo - 1]);
        end;
        sxHembra:
        begin
          Contendiente.Memoria.UltIntHembras[Prototipo - 1] := 0;
          Inc(Contendiente.Memoria.NumIntHembras[Prototipo - 1]);
        end;
      end;
    end;  //if Decision 7..10
    if Decision in [7,8] then
      IniciarPelea
    else if Decision in [9,10] then
      IniciarCortejo;
  end;  //with Agente
end;
{$WARNINGS ON}

procedure TProyecto.Copula(Agente: TAgente);
var
  i,
  Transferidos: Integer;
  Macho,
  Hembra: TAgente;
  Paquete: TPaqEspermatico;
begin
  if not Assigned(Agente.Interactuante) then
  begin
    Agente.Rechazado;
    Exit; //-->
  end;
  if Agente.Sexo = sxMacho then
  begin
    Macho := Agente;
    Hembra := Agente.Interactuante as TAgente;
  end
  else
  begin
    Macho :=  Agente.Interactuante as TAgente;
    Hembra := Agente;
  end;
  if Macho.Gonada.Contador <= Macho.Referencia.PaqTransferidos then
    Transferidos := Macho.Gonada.Contador
  else
    Transferidos := Macho.Referencia.PaqTransferidos;
  if Hembra.Espermateca.Contador >= Hembra.Referencia.MaxPaqAlmacenados then
    Transferidos := 0
  else if Hembra.Espermateca.Contador + Transferidos
      > Hembra.Referencia.MaxPaqAlmacenados then
    Transferidos := Hembra.Referencia.MaxPaqAlmacenados
        - Hembra.Espermateca.Contador;
  Mediador.Agente := Hembra;
  Mediador.Contendiente := Macho;
  with Paquete do
    for i := 1 to Transferidos do
    begin
      Genotipo := Macho.Genotipo;
      Reservas := Macho.Gonada.Elementos[1];
      Donador := Macho.Nombre;
      Paternidad := Mediador.ValorEntero['Paternidad'];
      Reservas.Agua := Round(Reservas.Agua * Hembra.Referencia.FraccPaquete);
      Reservas.Azucar :=
          Round(Reservas.Azucar * Hembra.Referencia.FraccPaquete);
      Reservas.Grasa := Round(Reservas.Grasa * Hembra.Referencia.FraccPaquete);
      Reservas.Proteina :=
          Round(Reservas.Proteina * Hembra.Referencia.FraccPaquete);
      Hembra.Espermateca.Agrega(Paquete);
      Macho.Gonada.Retira(1);
    end;
  Macho.Memoria.UltConductas[16] := 0;
  Hembra.Memoria.UltConductas[16] := 0;
  Inc(Macho.Memoria.NumConductas[16]);
  Inc(Hembra.Memoria.NumConductas[16]);
  Macho.TerminarCortejoConCopula;
  Hembra.TerminarCortejoConCopula;
  CobraNutrimentos(Macho);
  CobraNutrimentos(Hembra);
  Hembra.FertilizaFraccion;
end;

procedure TProyecto.Oviposita(Agente: TAgente);
var
  i, j: Integer;
  Huevo: THuevo;
begin
  for i := 1 to Agente.Referencia.OvipositadosCiclo do
  begin
    j := Entorno.ListaHuevos.Agrega(THuevo.Create{(Plataforma)});
    Huevo := Agente.Fertilizados.Elementos[1];
    with Entorno.ListaHuevos.Elementos[j] do
    begin
      Inicializa(Huevo.Padre, Huevo.Madre, Agente.Interactuante, 0, Huevo.Sexo);
      Nombre := Huevo.Nombre;
      Reservas := Huevo.Reservas;
      Genotipo := Huevo.Genotipo;
    end;
    Agente.Fertilizados.Retira(Huevo);
    Huevo := Entorno.ListaHuevos.Elementos[j];
    if Assigned(FOnNuevoHuevo) then
      TEventoNuevoHuevo(FOnNuevoHuevo)(Self, Huevo);
  end;  //for OvipositadosCiclo
end;

procedure TProyecto.DinamicaCombate(Agente: TAgente);
var
  i, j: Integer;
begin
  with Agente do
  begin
    if Assigned(Interactuante) then
    begin
      j := Entorno.ListaAgentes.IndiceDe(Interactuante as TAgente);
      if (j = 0) or ((Interactuante as TAgente).Situacion <> stCombate) or
          ((Interactuante as TAgente).Interactuante <> Agente) then
      begin
        Ganador;
        Exit; //-->
      end;
      Mediador.Contendiente := Interactuante as TAgente;
      for i := 1 to 3 do
        VPeleas[i] := Mediador.Combate[i,Memoria.UltAccionContendiente];
    end
    else
      Ganador;
  end;  //with Agente
end;

procedure TProyecto.DinamicaCortejo(Agente: TAgente);
var
  i, j: Integer;
begin
  with Agente do
  begin
    if Assigned(Interactuante) then
    begin
      j := Entorno.ListaAgentes.IndiceDe(Interactuante as TAgente);
      if (j = 0) or ((Interactuante as TAgente).Situacion <> stCortejo) or
          ((Interactuante as TAgente).Interactuante <> Agente) then
      begin
        Rechazado;
        Exit; //-->
      end;
      Mediador.Contendiente := Interactuante as TAgente;
      for i := 1 to 4 do
        VCortejos[i] := Mediador.Cortejo[i,Memoria.UltAccionContendiente];
    end
    else
      Rechazado;
  end;  //with Agente
end;

procedure TProyecto.ProveePercepciones(Agente: TAgente);
var
  i: Integer;
  TodosCeros: Boolean;  //Indica si VDecisiones se queda en puros ceros
begin
  for i := 1 to 8 do
    PromediaTendencias[i].Reestablece;
  for i := 1 to 12 do
    PromediaProbaDecision[i].Reestablece;
  Mediador.Agente := Agente;
  with Agente do
  begin
    Sustrato := Entorno.Cuadro[X, Y];
    with Percepciones do
    begin
      for i := 1 to 7 do
        PerSustratos[i] := False;
      for i := 1 to 5 do
      begin
        PerDinamicos[i] := False;
        HayDinamicos[i] := False;
        DinamicosPercibidos[i] := '';
      end;
      for i := 0 to Entorno.Juego.NumEstadios - 1 do
      begin
        PerEstadios[i] := False;
        HayEstadios[i] := False;
        AgentesPercibidos[i] := '';
      end;
      for i := 0 to Entorno.Juego.NumPrototiposM - 1 do
      begin
        PerMachos[i] := False;
        HayMachos[i] := False;
        AgentesPercibidos[Entorno.Juego.NumEstadios + i] := '';
      end;
      for i := 0 to Entorno.Juego.NumPrototiposH - 1 do
      begin
        PerHembras[i] := False;
        HayHembras[i] := False;
        AgentesPercibidos[Entorno.Juego.NumEstadios
            + Entorno.Juego.NumPrototiposM + i] := '';
      end;
    end;  //with Percepciones
		ProveePercepcionesSustratos(Agente);
    ProveePercepcionesDinamicos(Agente);
    ProveePercepcionesAgentes(Agente);
    for i := 1 to 12 do
      VDecision[i] := PromediaProbaDecision[i].PromedioI;
    if (not Percepciones.HayDinamicos[1]) //No fuente de agua o agua maximo
    		or (Agente.Reservas.Agua = Agente.Referencia.Maximos[1]) then
      VDecision[3] := 0;                        //No beber
    if (not Percepciones.HayDinamicos[2])  //No fuente de azucar o azucar maximo
        or (Agente.Reservas.Azucar = Agente.Referencia.Maximos[2]) then
      VDecision[4] := 0;                        //No comer azucar
    if (not Percepciones.HayDinamicos[3])  //No fuente de grasa o grasa maximo
    		or (Agente.Reservas.Grasa = Agente.Referencia.Maximos[3]) then
      VDecision[5] := 0;                        //No comer grasa
    if (not Percepciones.HayDinamicos[4])  //No fuente de proteina o protein max
    		or (Agente.Reservas.Proteina = Agente.Referencia.Maximos[4]) then
      VDecision[6] := 0;                        //No comer proteina
    Percepciones.HayPareja := False;
    Percepciones.HayContrincante := False;
    for i := 0 to Entorno.Juego.NumPrototiposM - 1 do
      if Percepciones.HayMachos[i] then
      begin
        Percepciones.HayContrincante := True;
        if Agente.Sexo = sxHembra then
          Percepciones.HayPareja := True;
      end;
    for i := 0 to Entorno.Juego.NumPrototiposH - 1 do
      if Percepciones.HayHembras[i] then
      begin
        Percepciones.HayContrincante := True;
        if Agente.Sexo = sxMacho then
          Percepciones.HayPareja := True;
      end;
    with Memoria do
    begin
      if (not Percepciones.HayContrincante)
          or ((UltConductas[9] < Mediador.ValorEntero['RefractarioCombate'])
                and (UltConductas[9] <> - 1))   //Última rendición
          or ((UltConductas[15] < Mediador.ValorEntero['RefractarioCombate'])
                and (UltConductas[15] <> - 1)) then     //Última ganada
      begin
        VDecision[7] := 0;                        //No pelear
        VDecision[8] := 0;
      end;
      if (not Percepciones.HayPareja)
          or ((UltConductas[13] < Mediador.ValorEntero['RefractarioCortejo'])
                and (UltConductas[13] <> - 1)) then  //Última cópula
      begin
        VDecision[9] := 0;                        //No cortejar
        VDecision[10] := 0;
      end;
    end;  //with Memoria
    if NivelCritico then    //Algún nutrimento por debajo de nivel crítico
    begin
      VDecision[7] := 0;                        //No pelear
      VDecision[8] := 0;
      VDecision[9] := 0;                        //No cortejar
      VDecision[10] := 0;
    end;
    if (Fertilizados.Contador = 0)     //No tiene huevos fertilizados
    		and ((Gonada.Contador = 0)      //No tiene huevos sin fertilizar
      				or (Espermateca.Contador = 0)) then   //No tiene paquetes esperm.
    	VDecision[11] := 0;  //No ovipositar
    if (not Percepciones.HayDinamicos[5]) then  //No hay sitio de oviposicion
    	VDecision[11] := 0;  //No ovipositar
    {if (not Percepciones.HayDinamicos[5])  //No hay sitio de oviposicion
      or
        ((Gonada.Contador = 0)  //No tiene huevos sin fertilizar
         or (Espermateca.Contador = 0) //No hay paquetes espermáticos
        and
         (Fertilizados.Contador = 0)) //No tiene huevos fertilizados
        then
      VDecision[11] := 0;           //ENTONCES No ovipositar }
    for i := 1 to 8 do
    begin
      if Mediador.Tendencias[i] + PromediaTendencias[i].PromedioI < 0 then
        Tendencia[i] := 0
      else  
        Tendencia[i] :=
            Mediador.Tendencias[i] + PromediaTendencias[i].PromedioI;
    end;
    EvitaSalida(Agente);
    TodosCeros := True;
    for i := 1 to 12 do
      if VDecision[i] <> 0 then
        TodosCeros := False;
    if TodosCeros then
      VDecision[1] := 1;    //Forzar movimiento
  end;  //with Agente
end;

procedure TProyecto.ProveePercepcionesDinamicos(Agente: TAgente);
var
  Dinamico: TDinamico;
  SitOvipo: TSitioOviposicion;
  Atractividad,
  Rad,
  Dist,
  i, j: Integer;
begin
  with Agente do
  begin
    for i := 1 to Entorno.ListaDinamicos.Contador do  //Atractividades Dinamicos
    begin
      Dinamico := Entorno.ListaDinamicos.Elementos[i];
      Mediador.Dinamico := Dinamico;
      Dist := Distancia(X, Y, Dinamico.X, Dinamico.Y);
      if Dist > 0 then
        Atractividad := Mediador.AtractividadDinamicos
              [Dinamico.ElementoListado,Mediador.PrototipoListado,1] div Dist
      else
        Atractividad := Mediador.AtractividadDinamicos
              [Dinamico.ElementoListado,Mediador.PrototipoListado,1];
      Rad := Mediador.AtractividadDinamicos[Dinamico.ElementoListado,
          Mediador.PrototipoListado,2];
      if  Dist <= Rad then
      begin
        Percepciones.PerDinamicos[Dinamico.ElementoListado] := True;
        case DireccionRelativaA(Direccion, X, Y, Dinamico.X, Dinamico.Y) of
          drNO: PromediaTendencias[1].Agrega(Atractividad);
          drN : PromediaTendencias[2].Agrega(Atractividad);
          drNE: PromediaTendencias[3].Agrega(Atractividad);
          drO : PromediaTendencias[4].Agrega(Atractividad);
          drE : PromediaTendencias[5].Agrega(Atractividad);
          drSO: PromediaTendencias[6].Agrega(Atractividad);
          drS : PromediaTendencias[7].Agrega(Atractividad);
          drSE: PromediaTendencias[8].Agrega(Atractividad);
        end;  //case
        for j := 1 to 12 do
            PromediaProbaDecision[j].Agrega(Mediador.InteraccionDinamicos
                [Dinamico.ElementoListado, Mediador.PrototipoListado,j]);
      end;  //if Dist <= Rad
      if  Dist <= 1 then
      begin                  //Elemento contiguo
        Percepciones.HayDinamicos[Dinamico.ElementoListado] := True;
        Percepciones.DinamicosPercibidos[Dinamico.ElementoListado] :=
            Percepciones.DinamicosPercibidos[Dinamico.ElementoListado]
            + IntToStr(i) + ',';
      end;
    end;  //for ListaDinamicos
    for i := 1 to Entorno.ListaOviposicion.Contador do //Atract Oviposición
    begin
      SitOvipo := Entorno.ListaOviposicion.Elementos[i];
      Mediador.Dinamico := SitOvipo;
      Dist := Distancia(X, Y, SitOvipo.X, SitOvipo.Y);
      if Dist > 0 then
        Atractividad := Mediador.AtractividadDinamicos[SitOvipo.ElementoListado,
            Mediador.PrototipoListado,1] div Dist
      else
        Atractividad := Mediador.AtractividadDinamicos[SitOvipo.ElementoListado,
            Mediador.PrototipoListado,1];
      Rad := Mediador.AtractividadDinamicos[SitOvipo.ElementoListado,
          Mediador.PrototipoListado,2];
      if  Dist <= Rad then
      begin
        Percepciones.PerDinamicos[5] := True;
        case DireccionRelativaA(Direccion, X, Y, SitOvipo.X, SitOvipo.Y) of
          drNO: PromediaTendencias[1].Agrega(Atractividad);
          drN : PromediaTendencias[2].Agrega(Atractividad);
          drNE: PromediaTendencias[3].Agrega(Atractividad);
          drO : PromediaTendencias[4].Agrega(Atractividad);
          drE : PromediaTendencias[5].Agrega(Atractividad);
          drSO: PromediaTendencias[6].Agrega(Atractividad);
          drS : PromediaTendencias[7].Agrega(Atractividad);
          drSE: PromediaTendencias[8].Agrega(Atractividad);
        end;  //case
        for j := 1 to 12 do
            PromediaProbaDecision[j].Agrega(Mediador.InteraccionDinamicos
                [5, Mediador.PrototipoListado,j]);
      end;  //if Dist <= Rad
      if  Dist <= 1 then
      begin                  //Elemento contiguo
        Percepciones.HayDinamicos[5] := True;
        Percepciones.DinamicosPercibidos[5] :=
            Percepciones.DinamicosPercibidos[5] + IntToStr(i) + ',';
      end;
    end;  //for ListaOviposicion
  end;  //with Agente
end;

procedure TProyecto.ProveePercepcionesSustratos(Agente: TAgente);
var
  Atractividades,
  Radios: array of Integer;
  Influencias: array of array [1..12] of Integer;
  RadMax,
  Atractividad,
  Dist,
  i, j, k, l: Integer;
begin
  with Entorno do
  begin
    SetLength(Atractividades, 7 + NumSustratosMixtos);
    SetLength(Influencias, 7 + NumSustratosMixtos);
    SetLength(Radios, 7 + NumSustratosMixtos);
  end;
  with Agente do
  begin
    Velocidad := Mediador.ValorEntero['VelocidadSustrato'
        + Agente.Sustrato];
    RadMax := 0;
    for i := 0 to Length(Radios) - 1 do
    begin
      Radios[i] := Mediador.AtractividadSustratos[i+1,
            Mediador.PrototipoListado, 2];
      Atractividades[i] := Mediador.AtractividadSustratos
            [i+1, Mediador.PrototipoListado, 1];
      if Radios[i] > RadMax then
        RadMax := Radios[i];
    end;
    for i := 0 to Length(Radios) - 1 do
      for k := 1 to 12 do
        Influencias[i,k] :=
            Mediador.InteraccionSustratos[i+1, Mediador.PrototipoListado, k];
    for i := RestaMin(X, RadMax, 1) to SumaMax(X, RadMax, Entorno.Anchura) do
      for j := RestaMin(Y, RadMax, 1) to SumaMax(Y, RadMax, Entorno.Altura) do
      begin                 //Procesando atractividades sustratos
        Dist := Distancia(X, Y, i, j);
        if Dist <= Radios[SustratoListado(Entorno.Cuadro[i,j])-1] then
                                        //Se encuentra dentro del radio de perc.
        begin
          k := SustratoListado(Entorno.Cuadro[i,j]);
          if k <= 7 then
            Percepciones.PerSustratos[k] := True
          else
            for k := 1 to 7 do
              if Entorno.HaySustratoEn(i, j, Chr(k-96)) then
                Percepciones.PerSustratos[k] := True;
          if Dist > 0 then
            Atractividad := Atractividades
                [SustratoListado(Entorno.Cuadro[i,j])-1] div Dist
          else
            Atractividad := Atractividades
                [SustratoListado(Entorno.Cuadro[i,j])-1];
          case DireccionRelativaA(Direccion, X, Y, i, j) of
            drNO: PromediaTendencias[1].Agrega(Atractividad);
            drN : PromediaTendencias[2].Agrega(Atractividad);
            drNE: PromediaTendencias[3].Agrega(Atractividad);
            drO : PromediaTendencias[4].Agrega(Atractividad);
            drE : PromediaTendencias[5].Agrega(Atractividad);
            drSO: PromediaTendencias[6].Agrega(Atractividad);
            drS : PromediaTendencias[7].Agrega(Atractividad);
            drSE: PromediaTendencias[8].Agrega(Atractividad);
          end;  //case
          k := SustratoListado(Entorno.Cuadro[i,j]);
          for l := 1 to 12 do
            PromediaProbaDecision[l].Agrega(Influencias[k-1,l]);
        end;  //if Dist <= Radios
      end;  //for i,j
  end;  //with Agente
end;

procedure TProyecto.ProveePercepcionesAgentes(Agente: TAgente);
var
  Contendiente: TAgente;
  Atractividad,
  Rad,
  Dist,
  i, j: Integer;
begin
  with Agente do
  begin
    for i := 1 to Entorno.ListaAgentes.Contador do
    begin
      Contendiente := Entorno.ListaAgentes.Elementos[i];
      if Agente = Contendiente then
        Continue; //->
      Mediador.Contendiente := Contendiente;
      Dist := Distancia(X, Y, Contendiente.X, Contendiente.Y);
      if Dist > 0 then
        Atractividad :=
            Mediador.AtractividadAgentes[Mediador.PrototipoListadoContendiente,
                Mediador.PrototipoListado,1] div Dist
      else
        Atractividad :=
            Mediador.AtractividadAgentes[Mediador.PrototipoListadoContendiente,
                Mediador.PrototipoListado,1];
      Rad := Mediador.AtractividadAgentes[Mediador.PrototipoListadoContendiente,
          Mediador.PrototipoListado,2];
      if  Dist <= Rad then  //Se encuentra en radio de percepcion
      begin
        if Adulto then
          case Contendiente.Sexo of
            sxMacho:
                Percepciones.PerMachos[Contendiente.Prototipo - 1] := True;
            sxHembra:
                Percepciones.PerHembras[Contendiente.Prototipo - 1] := True;
          end
        else
          Percepciones.PerEstadios[Contendiente.Estadio - 1] := True;
        case DireccionRelativaA(Direccion, X, Y,
            Contendiente.X, Contendiente.Y) of
          drNO: PromediaTendencias[1].Agrega(Atractividad);
          drN : PromediaTendencias[2].Agrega(Atractividad);
          drNE: PromediaTendencias[3].Agrega(Atractividad);
          drO : PromediaTendencias[4].Agrega(Atractividad);
          drE : PromediaTendencias[5].Agrega(Atractividad);
          drSO: PromediaTendencias[6].Agrega(Atractividad);
          drS : PromediaTendencias[7].Agrega(Atractividad);
          drSE: PromediaTendencias[8].Agrega(Atractividad);
        end;  //case
        for j := 1 to 12 do
          PromediaProbaDecision[j].Agrega(Mediador.InteraccionAgentes
              [Mediador.PrototipoListadoContendiente,
                  Mediador.PrototipoListado,j]);
       end;  //if Dist <= Rad
      if  Dist <= 1 then
      begin
        if Adulto then
          case Contendiente.Sexo of
            sxMacho:
            begin
              Percepciones.HayMachos[Contendiente.Prototipo - 1] := True;
              Percepciones.AgentesPercibidos
                  [Entorno.Juego.NumEstadios + Contendiente.Prototipo - 1] :=
                  Percepciones.AgentesPercibidos
                  [Entorno.Juego.NumEstadios + Contendiente.Prototipo - 1]
                  + IntToStr(i) + ',';
            end;
            sxHembra:
            begin
              Percepciones.HayHembras[Contendiente.Prototipo - 1] := True;
              Percepciones.AgentesPercibidos
                  [Entorno.Juego.NumEstadios + Entorno.Juego.NumPrototiposM
                  + Contendiente.Prototipo - 1] :=
                  Percepciones.AgentesPercibidos
                  [Entorno.Juego.NumEstadios + Entorno.Juego.NumPrototiposM
                  + Contendiente.Prototipo - 1]
                  + IntToStr(i) + ',';
            end;
          end
        else
        begin
          Percepciones.HayEstadios[Contendiente.Estadio - 1] := True;
          Percepciones.AgentesPercibidos[Contendiente.Estadio - 1] :=
              Percepciones.AgentesPercibidos[Contendiente.Estadio - 1]
              + IntToStr(i) + ',';
        end;
      end;  //if Dist <= 1
    end;  //for ListaAgentes
  end;  //with Agente
end;

procedure TProyecto.EvitaSalida(Agente: TAgente);
{Verifica si el agente está a punto de salirse del entorno, y corrige sus
tendencias de movimiento para evitarlo
Al sumar 1 a cualquier tendencia, se evita que dicha tendencia quede en 0 }
var
  i: Integer;
begin
  with Agente do
  begin
    if (X <= Velocidad) or      //¿Se encuentra al borde izquierdo del entorno?
        (X >= (Entorno.Anchura - Velocidad)) or      //Borde derecho de entorno
        (Y <= Velocidad) or      //¿Se encuentra al borde superior del entorno?
        (Y >= (Entorno.Altura - Velocidad)) then    //Borde inferior de entorno
      for i := 1 to 8 do
        Tendencia[i] := Tendencia[i] + 1 //Eliminando ceros
    else
      Exit; //-->
    if X <= Velocidad then     //¿Se encuentra al borde izquierdo del entorno?
      case Direccion of
        drNO:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[4] := 0; //O
        end;
        drN:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
        end;
        drNE:
        begin
          Tendencia[4] := 0; //0
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
        end;
        drO:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
        end;
        drE:
        begin
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drSO:
        begin
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
        end;
        drS:
        begin
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
          Tendencia[8] := 0; //SE
        end;
        drSE:
        begin
          Tendencia[5] := 0; //E
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //NE
        end;
      end;  //case
    if X >= (Entorno.Anchura - Velocidad) then  //Borde derecho de entorno
      case Direccion of
        drNO:
        begin
          Tendencia[5] := 0; //E
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drN:
        begin
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
          Tendencia[8] := 0; //SE
        end;
        drNE:
        begin
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
        end;
        drO:
        begin
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drE:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
        end;
        drSO:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[4] := 0; //O
          Tendencia[7] := 0; //S
        end;
        drS:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
        end;
        drSE:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[4] := 0; //O
        end;
      end;  //case
    if Y <= Velocidad then      //¿Se encuentra al borde superior del entorno?
      case Direccion of
        drNO:
        begin
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
        end;
        drN:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
        end;
        drNE:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[4] := 0; //O
        end;
        drO:
        begin
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
          Tendencia[8] := 0; //SE
        end;
        drE:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
        end;
        drSO:
        begin
          Tendencia[5] := 0; //E
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drS:
        begin
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drSE:
        begin
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
        end;
      end;  //case
    if Y >= (Entorno.Altura - Velocidad) then    //Borde inferior de entorno
      case Direccion of
        drNO:
        begin
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
        end;
        drN:
        begin
          Tendencia[6] := 0; //SO
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drNE:
        begin
          Tendencia[5] := 0; //E
          Tendencia[7] := 0; //S
          Tendencia[8] := 0; //SE
        end;
        drO:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[4] := 0; //O
          Tendencia[6] := 0; //SO
        end;
        drE:
        begin
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
          Tendencia[8] := 0; //SE
        end;
        drSO:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[4] := 0; //O
        end;
        drS:
        begin
          Tendencia[1] := 0; //NO
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
        end;
        drSE:
        begin
          Tendencia[2] := 0; //N
          Tendencia[3] := 0; //NE
          Tendencia[5] := 0; //E
        end;
      end; //case
  end;  //with Agente
end;

function TProyecto.SustratoListado(Sustrato: TCuadro): Word;
{Regresa la posción del sustrato en el cuadro Sustrato, según listado que
contiene en orden a los 7 sustratos simples, y con el número 8 al primer
sustrato mixto, con 9 al segundo, y así sucesivamente}
begin
  Result := 0;
  case Sustrato of
    '1'..'7': Result := StrToInt(Sustrato);
    'A'..'Z': Result := Ord(Sustrato) - 57; //A = 8, B = 9, etc
  end;
end;

end.
