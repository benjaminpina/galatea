program galateac;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, 
  { you can add units after this }
  Comunes, Multilenguaje, Proyectos, ArchivosSalida, Agentes, Mediadores,
  DateUtils;

type

	TTemporizadores = record
    Autoguardado,
    Informar,
    Detener: Boolean;
    IntervaloAutoGuardado,
    IntervaloInformar,
    IntervaloSalida,
    Detencion: Integer;
  end;

  { TGalateac }

  TGalateac = class(TCustomApplication)
  protected
    procedure DoRun; override;
  private
  	Proyecto: TProyecto; 
  	NombreArchivo: string;
    Inicio,
    Fin: TDateTime; //Fechas y horas de incio y fin de ejecución
    Salida: TSalida; 
  public
  	Temporizadores: TTemporizadores; 
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure AbreArchivo(PNombreArchivo: string);
    procedure Ciclo(Sender: TObject; Ciclo: Integer; Info: TStringList);
    procedure NuevoAgente(Sender: TObject; Agente: TAgente);
    procedure NuevoHuevo(Sender: TObject; Huevo: THuevo);
    procedure NuevoAdulto(Sender: TObject; Agente: TAgente);
    procedure CreaArchivosDeSalida;
    procedure EnviaInfoCiclo(Info: TStringList);
    procedure InformaEstado;
    procedure IniciarEjecucion;
    procedure DespliegaValorDe(Variable: string; Valor: Integer); overload;
    procedure DespliegaValorDe(Variable, Valor: string); overload;
  end;

const
	Version = '0.5'; 

{ TGalateac }

procedure TGalateac.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h v f a i o c',
  											'help version file autosave information output cycles');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Halt; //--->
  end;

  // parse parameters
  if HasOption('h','help') then
  begin
    WriteHelp;
    Halt; //--->
  end;
  if HasOption('v','version') then
  begin
    WriteLn('Galatea version ', Version);
    Halt; //--->
  end;
  if not HasOption('f', 'file') then
  begin
    WriteLn('ERROR: input file not specified');
    Halt; //--->
  end;
  with Temporizadores do
  begin
    Autoguardado := HasOption('a', 'autosave');
    Informar:= HasOption('i', 'information');
    Detener:= HasOption('c', 'cycles');
    if Autoguardado then
    	IntervaloAutoGuardado := StrToInt(GetOptionValue('a', 'autosave'));
    if Informar then
    	IntervaloInformar := StrToInt(GetOptionValue('i', 'information'));
    if Detener then
    	Detencion := StrToInt(GetOptionValue('c', 'cycles'));
    if HasOption('o', 'output') then
    	IntervaloSalida := StrToInt(GetOptionValue('o', 'output'));
  end;


  { add your program here }

  Randomize;
  AbreArchivo(GetOptionValue('f','file'));
  IniciarEjecucion;

  while Proyecto.Status <> stParado do;
  // stop program loop
  Terminate;
end;

constructor TGalateac.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=False;
end;

destructor TGalateac.Destroy;
begin
  inherited Destroy;
end;

procedure TGalateac.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -f [input file]');
  writeln(ExeName, ' -a [autosave] -i [information] -c [cycles] -o [output]');
  writeln('Usage: ',ExeName,' -h');
  writeln('Usage: ',ExeName,' -v');
end;

procedure TGalateac.AbreArchivo(PNombreArchivo: string);
begin
  if not FileExists(PNombreArchivo) then
  begin                                               //no existe el archivo
    WriteLn(ML(mlErrArchvNE) + ': ' + PNombreArchivo);
    Halt; //--->
  end;
  NombreArchivo := PNombreArchivo;
  Proyecto := TProyecto.Create; 
  Proyecto.Carga(NombreArchivo);
  if FileExists(Proyecto.ArchivoEntorno) then
  begin
    Proyecto.Entorno.Carga(Proyecto.ArchivoEntorno);
    Proyecto.OnCiclo := @Ciclo;
    Proyecto.OnNuevoAgente := @NuevoAgente;
    Proyecto.OnNuevoHuevo := @NuevoHuevo;
    Proyecto.OnNuevoAdulto := @NuevoAdulto;
  end
  else
  begin
    WriteLn(ML(mlFltArchEntrn), ': ', Proyecto.ArchivoEntorno);
    Halt; //---> 
  end;
end; 

procedure TGalateac.Ciclo(Sender: TObject; Ciclo: Integer; Info: TStringList); 
var
  NombreArchivoEnt,
  RutaEntorno : string;
begin
  if Proyecto.Status = stParado then
    Exit;
  if Temporizadores.Autoguardado then
    if (Ciclo mod Temporizadores.IntervaloAutoGuardado) = 0 then
    begin
      //RutaEntorno := ExtractFilePath(ExeName) + ML(mlEntornos)+ Diag;
      RutaEntorno := Salida.Directorio;
      if DirectoryExists(RutaEntorno) then
      begin
        NombreArchivoEnt:= ExtractFileName(NombreArchivo);
        NombreArchivoEnt := ChangeFileExt(NombreArchivoEnt, '');
        NombreArchivoEnt := NombreArchivoEnt + '_'
            + IntToStr(Proyecto.Entorno.Ciclos);
        NombreArchivoEnt := NombreArchivoEnt + '.ngl';
        NombreArchivoEnt := RutaEntorno + NombreArchivoEnt;
        Proyecto.Entorno.Guarda(NombreArchivoEnt);
      end
      else
        WriteLn('ERROR no se puede generar archivo de salida.');
    end;
  if Temporizadores.Informar then
    if (Ciclo mod Temporizadores.IntervaloInformar) = 0 then
      InformaEstado;
  EnviaInfoCiclo(Info);
  if (Ciclo mod Temporizadores.IntervaloSalida) = 0 then
    Salida.ActualizaArchivos;
  if Temporizadores.Detener then
    if (Ciclo mod Temporizadores.Detencion) = 0 then
    begin
      Proyecto.Detener;
    	if Assigned(Salida) then
      	Salida.Cierra;
    	FreeAndNil(Salida);
      InformaEstado;
      WriteLn('Execution Finished');
    end;
end;

procedure TGalateac.NuevoAgente(Sender: TObject; Agente: TAgente); 
begin
  Salida.AgregaAgente(Agente);
end;

procedure TGalateac.NuevoHuevo(Sender: TObject; Huevo: THuevo); 
begin
  Salida.AgregaHuevo(Huevo);
end;

procedure TGalateac.NuevoAdulto(Sender: TObject; Agente: TAgente); 
begin
  Salida.AgregaAdulto(Agente);
end;

procedure TGalateac.CreaArchivosDeSalida; 
var
  i: Integer;
  Exito: Boolean;
  Nombre,
  DirectorioSalida: string;
begin
  if Assigned(Salida) then
    Exit; //-->
  DirectorioSalida := ExtractFilePath(ExeName) + ML(mlSalida) + Diag;
  if not DirectoryExists(DirectorioSalida) then //No existe directorio
  	CreateDir(DirectorioSalida);
  Nombre := ExtractFileName(NombreArchivo);
  Nombre := ChangeFileExt(Nombre, '');
  Salida := TSalida.Create(DirectorioSalida, Nombre, Proyecto.Entorno);
  Exito := Salida.ResultadoCreacion;
  if not Exito then
  begin
    WriteLn(ML(mlErrDirSalNC));
    Exit; //-->
  end;
  Salida.GuardaInfoEntorno;
  with Proyecto.Entorno.ListaAgentes do
    for i := 1 to Contador do
      Salida.AgregaAgente(Elementos[i]);
  with Proyecto.Entorno.ListaHuevos do
    for i := 1 to Contador do
      Salida.AgregaHuevo(Elementos[i]);
end;

procedure TGalateac.EnviaInfoCiclo(Info: TStringList); 
begin
  Salida.AgregaCiclo(Proyecto.Entorno.Ciclos, Info);
  Salida.AgregaGrafica(Info[0]);
end;

procedure TGalateac.InformaEstado; 
var
  Duracion: Real;
  IAnio, IMes, IDia, IHora, IMinuto, ISegundo, //Fecha y hora de inicio
  FAnio, FMes, FDia, FHora, FMinuto, FSegundo, //Fecha y hora de fin
  w: Word;
  Horas,
  Minutos,
  Segundos,
  Totales,  //Segundos totales
  i, j: Integer;
  Cont: array of Word;
  sFInicio,
  sFFin,
  sHInicio,
  sHFin,
  sTiempoTotal,
  sDuracion: string;
  Mediador: TMediador;
begin
  WriteLn('--------------------------------------------------------------');
  Mediador := TMediador.Create(Proyecto.Entorno);
  DespliegaValorDe(ML(mlCiclos), Proyecto.Entorno.Ciclos);
  with Proyecto.Entorno.Juego do
    SetLength(Cont, NumEstadios + NumPrototiposM + NumPrototiposH);
  with Proyecto.Entorno.ListaAgentes do
  begin
    for i := 1 to Contador do
    begin
      Mediador.Agente := Elementos[i];
      Inc(Cont[Mediador.PrototipoListado - 1]);
    end;
  end;
  with Proyecto.Entorno.Juego do
  begin
    Cont[0] := Proyecto.Entorno.ListaHuevos.Contador;
    DespliegaValorDe(Estadios[1].Nombre , Cont[0]);
    j := 1;
    for i := 2 to NumEstadios do
    begin
      DespliegaValorDe(Estadios[i].Nombre, Cont[j]);
      Inc(j);
    end;
    for i := 1 to NumPrototiposM do
    begin
      DespliegaValorDe(PrototiposM[i].Nombre, Cont[j]);
      Inc(j);
    end;
    for i := 1 to NumPrototiposH do
    begin
      DespliegaValorDe(PrototiposH[i].Nombre, Cont[j]);
      Inc(j);
    end;
    j := 0;
    for i := 0 to Length(Cont) - 1 do
      j := j + Cont[i];
    DespliegaValorDe('Total' , j);
  end;
  Mediador.Free;
  if not (Proyecto.Status = stEjecutando) then
    Exit; //-->
  Fin := Now;
  Totales := SecondsBetween(Inicio, Fin);
  Horas := Totales div 3600;
  Minutos := (Totales mod 3600) div 60;
  Segundos := (Totales mod 3600) mod 60;
  Duracion := Totales / Proyecto.Entorno.Ciclos;
  sDuracion := FloatToStrF(Duracion, ffFixed, 7, 8);
  DecodeDate(Inicio, IAnio, IMes, IDia);
  DecodeDate(Fin, FAnio, FMes, FDia);
  DecodeTime(Inicio, IHora, IMinuto, ISegundo, w);
  DecodeTime(Fin, FHora, FMinuto, FSegundo, w);
  sFInicio := IntAStr(IDia, 2) + '/' + IntAStr(IMes, 2) + '/' + IntToStr(IAnio);
  sFFin := IntAStr(FDia, 2) + '/' + IntAStr(FMes, 2) + '/' + IntToStr(FAnio);
  sHInicio := IntAStr(IHora, 2) + ':' + IntAStr(IMinuto, 2)
      + ':' + IntAStr(ISegundo, 2);
  sHFin := IntAStr(FHora, 2) + ':' + IntAStr(FMinuto, 2)
      + ':' + IntAStr(FSegundo, 2);
  sTiempoTotal := IntToStr(Horas) + ':' + IntAStr(Minutos, 2) + ':'
      + IntAStr(Segundos, 2);
  DespliegaValorDe(ML(mlFechaInicio), sFInicio);
  DespliegaValorDe(ML(mlHoraInicio), sHInicio);
  DespliegaValorDe(ML(mlFechaFin), sFFin);
  DespliegaValorDe(ML(mlHoraFin), sHFin);
  DespliegaValorDe(ML(mlTiempoTotal), sTiempoTotal);
  DespliegaValorDe(ML(mlDuracCiclo), sDuracion);
  j := 0;
  for i := 0 to Length(Cont) - 1 do
    j := j + Cont[i];
  if j = 0 then       //Todos los agentes han muerto
  begin
    Proyecto.Detener;
    	if Assigned(Salida) then
      	Salida.Cierra;
    	FreeAndNil(Salida);
      InformaEstado;
      WriteLn('ALL AGENTS DIED');
      Halt; //--->
  end;
end;

procedure TGalateac.IniciarEjecucion; 
begin
  CreaArchivosDeSalida;
  Inicio := Now;
  Proyecto.Ejecutar;
end;

procedure TGalateac.DespliegaValorDe(Variable: string; Valor: Integer);
begin
  WriteLn(Variable, ': ', Valor);
end;

procedure TGalateac.DespliegaValorDe(Variable, Valor: string);
begin
  WriteLn(Variable, ': ', Valor);
end;

var
  Application: TGalateac;
begin
  Application:=TGalateac.Create(nil);
  Application.Run;
  Application.Free;
end.

