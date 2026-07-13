unit ArchivosSalida;

{$MODE Delphi}

{*******************************************************************************
Contiene la implemenatción de la clase TSalida, encargada de gestionar los
archivos de salida de las simulaciones de Galatea. 
*******************************************************************************}

interface

uses
  Classes, Entornos, Sustratos, Comunes, Agentes;

type
  TSalida = class
  private
    FDirectorio,
    FNombre: string;
    FResultado: Boolean;
    InfoEntorno,
    InfoAgentes,
    InfoHuevos,
    InfoCiclos,
    InfoMorfo,
    InfoGraficas: TGuardable;
    Entorno: TEntorno;
    procedure GuardaCabecera;
    procedure GuardaEscenario;
    procedure GuardaJuego;
  public
    constructor Create(DirSalida, Nombre: string; PEntorno: TEntorno);
    destructor Destroy; override;
    procedure AgregaAdulto(Agente: TAgente);
    procedure AgregaAgente(Agente: TAgente);
    procedure AgregaHuevo(Huevo: THuevo);
    procedure AgregaCiclo(n: Integer; ss: TStringList);
    procedure AgregaGrafica(s: string);
    procedure Cierra;
    procedure GuardaInfoEntorno;
    procedure ActualizaArchivos;
    property Directorio: string
      read FDirectorio;
    property Nombre: string
      read FNombre;
    property ResultadoCreacion: Boolean
      read FResultado;
  end;

implementation

uses
  SysUtils, FuncElementosCadenas;

{ TSalida }

procedure TSalida.ActualizaArchivos;
begin
  InfoAgentes.Actualiza(Directorio + Nombre + '.agn');
  InfoHuevos.Actualiza(Directorio + Nombre + '.hvs');
  InfoCiclos.Actualiza(Directorio + Nombre + '.cls');
  InfoGraficas.Actualiza(Directorio + Nombre + '.csv');
  InfoMorfo.Actualiza(Directorio + Nombre + '.mrf');
end;

procedure TSalida.AgregaAdulto(Agente: TAgente);
begin
  InfoMorfo.EscribeValor(Agente.Nombre, AgenteAStringMorfo(Agente));
end;

procedure TSalida.AgregaAgente(Agente: TAgente);
begin
  InfoAgentes.EscribeValor(Agente.Nombre, AgenteAStringConst(Agente));
end;

procedure TSalida.AgregaCiclo(n: Integer; ss: TStringList);
begin
  InfoCiclos.EscribeValor(IntToStr(n), ss);
end;

procedure TSalida.AgregaGrafica(s: string);
begin
  InfoGraficas.EscribeValor(s);
end;

procedure TSalida.AgregaHuevo(Huevo: THuevo);
begin
  InfoHuevos.EscribeValor(Huevo.Nombre, HuevoOvipositadoAStringConst(Huevo));
end;

procedure TSalida.Cierra;
begin
  ActualizaArchivos;
end;

constructor TSalida.Create(DirSalida, Nombre: string; PEntorno: TEntorno);
var
  s,
  NombreCompleto: string;
  i: Integer;
  Bandera: Boolean;
begin
  Entorno := PEntorno;
  FNombre := Nombre;
  FResultado := False;
  i := 1;
  Bandera := False;
  repeat
    if not (DirectoryExists(DirSalida + Nombre + IntAStr(i,4))) then
    begin
      NombreCompleto := Nombre + IntAStr(i, 4);
      FResultado := CreateDir(DirSalida + NombreCompleto);
      FDirectorio := DirSalida + NombreCompleto + Diag;
      Bandera := True;
    end
    else
      Inc(i);
  until Bandera or (i = 9999);
  InfoEntorno := TGuardable.Create;
  InfoMorfo := TGuardable.Create;
  InfoAgentes := TGuardable.Create;
  InfoHuevos := TGuardable.Create;
  InfoCiclos := TGuardable.Create;
  InfoGraficas := TGuardable.Create;
  InfoEntorno.Reestablece;
  InfoMorfo.Reestablece;
  InfoAgentes.Reestablece;
  InfoHuevos.Reestablece;
  InfoCiclos.Reestablece;
  InfoGraficas.Reestablece;
  s := '';
  with Entorno.Juego do
  begin
    for i := 1 to NumEstadios do
      s := s + Estadios[i].Nombre + ',';
    for i := 1 to NumPrototiposM do
      s := s + PrototiposM[i].Nombre + ',';
    for i := 1 to NumPrototiposH do
      s := s + PrototiposH[i].Nombre + ',';
  end;
  InfoGraficas.EscribeValor(s);
  if FResultado then
    GuardaCabecera;
end;

destructor TSalida.Destroy;
begin
  InfoEntorno.Free;
  InfoMorfo.Free;
  InfoAgentes.Free;
  InfoHuevos.Free;
  InfoCiclos.Free;
  InfoGraficas.Free;
  inherited Destroy;
end;

procedure TSalida.GuardaCabecera;
var
  Archivo: TextFile;
begin
  AssignFile(Archivo, Directorio + Nombre + '.sag');
  Rewrite(Archivo);
  CloseFile(Archivo);
end;

procedure TSalida.GuardaEscenario;
var
  Lineas: TStringList;
  Linea: string;
  Simple: TSustratoSimple;
  Mixto: TSustratoMixto;
  i, j: Integer;
begin
  with Entorno do
  begin
    with InfoEntorno do
    begin
      Lineas := TStringList.Create;
      EscribeValor('Anchura', Anchura);
      EscribeValor('Altura', Altura);
      EscribeValor('NumSustratosMixtos', NumSustratosMixtos);
      Lineas.Clear;
      for i := 1 to 7 do
      begin
        Simple := Simples[i];
        Lineas.Add(Simple.Nombre);
        Lineas.Add(IntAStr(Simple.Color, 8));
      end;
      EscribeValor('SustratosSimples', Lineas);
      Lineas.Clear;
      for i := 1 to NumSustratosMixtos do
      begin
        Linea := '';
        Mixto := Mixtos[i];
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
      EscribeValor('SustratosMixtos', Lineas);
      Lineas.Clear;
      for j := 1 to Altura do
      begin
        Linea := '';
        for i := 1 to Anchura do
          Linea := Linea + Cuadro[i,j];
        Lineas.Add(Linea);
      end;
      EscribeValor('MapaEscenario', Lineas);
      Lineas.Free;
    end;  //with InfoEntorno
  end;  //with Escenario
end;

procedure TSalida.GuardaInfoEntorno;
var
  Lineas : TStringList;
  i      : Integer;
begin
  with Entorno do
  begin
    with InfoEntorno do
    begin
      Lineas := TStringList.Create;
      Reestablece;
      EscribeValor('Titulo', Titulo);
      EscribeValor('Ciclos', Ciclos);
      //EscribeValor('NumAgentes', ListaAgentes.Contador);
      EscribeValor('NumElementosDinamicos', ListaDinamicos.Contador);
      EscribeValor('NumSitiosOviposicion', ListaOviposicion.Contador);
      //EscribeValor('NumHuevos', ListaHuevos.Contador);
      Lineas.Text := Comentarios;
      EscribeValor('Comentarios', Lineas);
      GuardaEscenario;
      GuardaJuego;
      Lineas.Clear;
      for i := 1 to ListaDinamicos.Contador do
      	Lineas.Add(ElementoDinamicoAString(ListaDinamicos.Elementos[i]));
      EscribeValor('ElementosDinamicos', Lineas);
      Lineas.Clear;
      for i := 1 to ListaOviposicion.Contador do
        Lineas.Add(SitOviposicionAString(ListaOviposicion.Elementos[i]));
      EscribeValor('SitiosOviposicion', Lineas);
      Lineas.Clear;
      Lineas.Free;
      Guarda(Directorio + Nombre + '.ent');
    end;  //with Infoentorno
  end;  //with Entorno
end;

procedure TSalida.GuardaJuego;
var
  Lineas : TStringList;
  Linea  : string;
  i, j, k: Integer;
begin
  with Entorno.Juego do
  begin
    with InfoEntorno do
    begin
      Lineas := TStringList.Create;
      EscribeValor('NumEstadios', NumEstadios);
      EscribeValor('NumPrototiposM', NumPrototiposM);
      EscribeValor('NumPrototiposH', NumPrototiposH);
      Linea := '';
      for i := 1 to 7 do
        Linea := Linea + Movimiento.Velocidad[i] + ',';
      EscribeValor('Velocidad', Linea);
      Linea := '';
      for i := 1 to NumEstadios do
      begin
        if Estadios[i].Y_O then
          Linea := Linea + '1,'
        else
          Linea := Linea + '0,';
      end;
      EscribeValor('Y_OEstadios', Linea);
      Linea := '';
      for i := 1 to NumEstadios do
      begin
        if Estadios[i].Y_OR then
          Linea := Linea + '1,'
        else
          Linea := Linea + '0,';
      end;
      EscribeValor('Y_OEstadiosR', Linea);
      Linea := '';
      for i := 1 to NumEstadios do
      begin
        if Estadios[i].Y_OC1C2 then
          Linea := Linea + '1,'
        else
          Linea := Linea + '0,';
      end;
      EscribeValor('Y_OEstadiosC1C2', Linea);
      Linea := '';
      for i := 1 to NumEstadios do
      begin
        if Estadios[i].Prototipo <> 0 then
          Linea := Linea + IntToStr(Estadios[i].Prototipo) + ','
        else
          Linea := Linea + '0,';
      end;
      EscribeValor('PrototiposLigados', Linea);
      Linea := '';
      for i := 1 to NumEstadios do
        Linea := Linea + Estadios[i].Ciclos + ',';
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
      for i := 1 to NumEstadios do
        Lineas.Add(Estadios[i].Condicion1);
      EscribeValor('EstadiosCondiciones1', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios do
        Lineas.Add(Estadios[i].Condicion2);
      EscribeValor('EstadiosCondiciones2', Lineas);
      Lineas.Clear;
      for j := 0 to NumPrototiposM - 1 do
      begin
        Linea := '';
        for i := 0 to 2 do
          Linea := Linea + CriteriosM[i,j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('CriteriosM', Lineas);
      Lineas.Clear;
      for j := 0 to NumPrototiposH - 1 do
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
      for i := 1 to NumEstadios do
        Lineas.Add(Estadios[i].Nombre);
      EscribeValor('NombresEstadios', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios do
        Lineas.Add(IntAStr(Estadios[i].Color, 8));
      EscribeValor('ColoresEstadios', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
        Lineas.Add(PrototiposM[i].Nombre);
      EscribeValor('NombresPrototiposM', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
        Lineas.Add(IntAStr(PrototiposM[i].Color, 8));
      EscribeValor('ColoresPrototiposM', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
        Lineas.Add(PrototiposM[i].Longevidad);
      EscribeValor('LongevidadesPrototiposM', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
        Lineas.Add(PrototiposH[i].Nombre);
      EscribeValor('NombresPrototiposH', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
        Lineas.Add(IntAStr(PrototiposH[i].Color, 8));
      EscribeValor('ColoresPrototiposH', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
        Lineas.Add(PrototiposH[i].Longevidad);
      EscribeValor('LongevidadesPrototiposH', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
      begin
        Linea := PrototiposH[i].ProporcionMachos + ','
                  + PrototiposH[i].ProporcionHembras;
        Lineas.Add(Linea);
      end;
      EscribeValor('ProporcionesSexuales', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios do
      begin
        Linea := '';
        for j := 1 to 4 do
          Linea := Linea + Estadios[i].Requiere[j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('RequerimientosEstadios', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios do
      begin
        Linea := '';
        for j := 1 to 4 do
          Linea := Linea + Estadios[i].Costos[j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('CostosEstadios', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
      begin
        Linea := '';
        for j := 1 to 15 do
          Linea := Linea + (PrototiposM[i].Discretos[j].ValorGenetico) + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('DiscretosPrototiposM', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
      begin
        Linea := '';
        for j := 1 to 15 do
          Linea := Linea + PrototiposH[i].Discretos[j].ValorGenetico + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('DiscretosPrototiposH', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
        for j := 1 to 15 do
          Lineas.Add(PrototiposM[i].Continuos[j].ValorGenetico);
      EscribeValor('ContinuosPrototiposM', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
        for j := 1 to 15 do
          Lineas.Add(PrototiposH[i].Continuos[j].ValorGenetico);
      EscribeValor('ContinuosPrototiposH', Lineas);
      Linea := '';
      for i := 1 to NumPrototiposM do
        Linea := Linea + PrototiposM[i].RefractarioCombate + ',';
      EscribeValor('RefractariosCombateM', Linea);
      Linea := '';
      for i := 1 to NumPrototiposH do
        Linea := Linea + PrototiposH[i].RefractarioCombate + ',';
      EscribeValor('RefractariosCombateH', Linea);
      Linea := '';
      for i := 1 to NumPrototiposM do
        Linea := Linea + PrototiposM[i].RefractarioCortejo + ',';
      EscribeValor('RefractariosCortejoM', Linea);
      Linea := '';
      for i := 1 to NumPrototiposH do
        Linea := Linea + PrototiposH[i].RefractarioCortejo + ',';
      EscribeValor('RefractariosCortejoH', Linea);
      Lineas.Clear;
      Linea := '';
      for i := 1 to NumEstadios do
      begin
        Linea := '';
        for j := 1 to 8 do
          Linea := Linea + Estadios[i].Tendencias[j] + ', ';
        Lineas.Add(Linea);
      end;
      EscribeValor('TendenciasEstadios', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposM do
      begin
        Linea := '';
        for j := 1 to 8 do
          Linea := Linea + PrototiposM[i].Tendencias[j] + ', ';
        Lineas.Add(Linea);
      end;
      EscribeValor('TendenciasMachos', Lineas);
      Lineas.Clear;
      for i := 1 to NumPrototiposH do
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
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizSustratos.Celda[i,j]);
      EscribeValor('MatrizSustratos', Lineas);
      Lineas.Clear;
      for i := 1 to 5 do  //Número de elementos dinámicos = 5
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizDinamicos.Celda[i,j]);
      EscribeValor('MatrizDinamicos', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizAgentes.Celda[i,j]);
      EscribeValor('MatrizAgentes', Lineas);
      Lineas.Clear;
      for i := 1 to 7 do  //Número de sustratos = 7
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizSustratosA.Celda[i,j]);
      EscribeValor('MatrizSustratosA', Lineas);
      Lineas.Clear;
      for i := 1 to 5 do  //Número de elementos dinámicos = 5
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizDinamicosA.Celda[i,j]);
      EscribeValor('MatrizDinamicosA', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Lineas.Add(MatrizAgentesA.Celda[i,j]);
      EscribeValor('MatrizAgentesA', Lineas);
      Lineas.Clear;
      for i := 1 to 7 do  //Número de sustratos = 7
      begin
        Linea := '';
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Linea := Linea + MatrizSustratosM.Celda[i,j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('MatrizSustratosM', Lineas);
      Lineas.Clear;
      for i := 1 to 5 do  //Número de elementos dinámicos = 5
      begin
        Linea := '';
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Linea := Linea + MatrizDinamicosM.Celda[i,j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('MatrizDinamicosM', Lineas);
      Lineas.Clear;
      for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        Linea := '';
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
          Linea := Linea + MatrizAgentesM.Celda[i,j] + ',';
        Lineas.Add(Linea);
      end;
      EscribeValor('MatrizAgentesM', Lineas);
      Lineas.Clear;
      for i := 1 to 14 do  //Número de conductas = 14
      begin
        Linea := '';
        for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
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
            Linea := Linea + PrototiposM[k].Combate[i,j] + ',';
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
            Linea := Linea + PrototiposM[k].Cortejo[i,j] + ',';
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
            Linea := Linea + PrototiposH[k].Combate[i,j] + ',';
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
            Linea := Linea + PrototiposH[k].Cortejo[i,j] + ',';
          Lineas.Add(Linea);
         end;
      end;
      EscribeValor('MatricesCortejoH', Lineas);
    end;  //with InfoEntorno
  end;  //with Entorno.Juego
  Lineas.Free;
end;

end.
