program filtrador;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  Comunes
  { you can add units after this };

type

	TRegAgente = record
  	Nombre: string;
    Prototipo,
    Parejas: Integer;
  end;

  { Tfiltrador }

  Tfiltrador = class(TCustomApplication)
  protected
    procedure DoRun; override;
  private
    InfoAgentes,
    InfoHuevos: TGuardable;
    procedure InicializaArchivos;
    procedure CierraArchivos;
    procedure GeneraDatosGraficas;
    procedure GeneraDatosAdecuacion;
  public
  	Directorio,
  	NomArch: string;
    Ciclos: Integer;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

const
	Version = '0.2';

procedure Tfiltrador.DoRun;
var
  ErrorMsg: String;
begin
 ErrorMsg:=CheckOptions('h v f',
  											'help version file');
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
  if not FileExists(GetOptionValue('f')) then
  begin
  	WriteLn('ERROR: input file does not exists');
    Halt; //--->
  end;

  { add your program here }

	InicializaArchivos;
  GeneraDatosGraficas;
  GeneraDatosAdecuacion;

  CierraArchivos;

  // stop program loop
  Terminate;
end;

procedure Tfiltrador.InicializaArchivos;
begin
	Directorio:= ExtractFileDir(GetOptionValue('f'));
  NomArch:= ExtractFileName(GetOptionValue('f'));
  //InfoEntorno := TGuardable.Create;
  //InfoMorfo := TGuardable.Create;
  InfoAgentes := TGuardable.Create;
  InfoHuevos := TGuardable.Create;
  //InfoCiclos := TGuardable.Create;
  //InfoEntorno.Carga(Directorio + NomArch + '.ent');
  //InfoMorfo.Carga(Directorio + NomArch + '.mrf');
  //InfoHuevos.Carga(Directorio + NomArch + '.hvs');
  //InfoMorfo.Ciclos(Directorio + NomArch + '.cls');
  //
end;

procedure Tfiltrador.CierraArchivos;
begin
  //InfoEntorno.Free;
  //InfoMorfo.Free;
  InfoAgentes.Free;
  InfoHuevos.Free;
  //InfoCiclos.Free;
  //InfoGraficas.Free;
end;

procedure Tfiltrador.GeneraDatosGraficas;
var
	Arch1,
 	Arch2: TextFile;
  i: Integer;
  s: string;
begin
  AssignFile(Arch1, Directorio + Diag + ChangeFileExt(NomArch, '.csv'));
  AssignFile(Arch2, Directorio + Diag + ChangeFileExt(NomArch, 'F.csv'));
  Reset(Arch1);
  Rewrite(Arch2);
  i := 0;
  ReadLn(Arch1, s);
  WriteLn(Arch2, 'Ciclos,', s);
  while not EoF(Arch1) do
  begin
  	Inc(i);
  	ReadLn(Arch1, s);
    if ((i mod 100) = 0) or (i = 1) then
    	WriteLn(Arch2, i, ',', s);
  end;
  Ciclos := i;
  WriteLn('Total cycles: ', i);
  CloseFile(Arch1);
  CloseFile(Arch2);
end;

procedure Tfiltrador.GeneraDatosAdecuacion;
var
	RegAgns: array of TRegAgente;
  NombresAgentes,
  NombresHuevos,
  Hembras: TStringList;
  i, j, k: Integer;
  s,
  Padre,
  Madre: string;
  InfoCiclos,
  InfoAdecuacion: TextFile;
  Bandera: Boolean;
begin
  InfoAgentes.Carga(Directorio + Diag + ChangeFileExt(NomArch, '.agn'));
  NombresAgentes:= InfoAgentes.ListadoIndicesSimples;
  SetLength(RegAgns, NombresAgentes.Count);
  j := 0;
  for i := 0 to Length(RegAgns) - 1 do
  begin
    s := InfoAgentes.LeeValor(NombresAgentes.Strings[i]);
    if ObtenNsimo(s, 3) = 'M' then	//es macho
    begin
     RegAgns[j].Nombre := NombresAgentes.Strings[i];
     Inc(j);
    end;
  end;
  SetLength(RegAgns, j);
  AssignFile(InfoCiclos, Directorio + Diag + ChangeFileExt(NomArch, '.cls'));
  j := -1;
  for i := 0 to Length(RegAgns) - 1 do
  begin
    Bandera := False;
    Reset(InfoCiclos);
    while not (EoF(InfoCiclos) or Bandera) do
    begin
    	ReadLn(InfoCiclos, s);
      Bandera := (ComienzaCon(s, RegAgns[i].Nombre)) and (ObtenNsimo(s, 4) <> '0');
      if Bandera then
      begin
      	Inc(j);
      	RegAgns[j].Prototipo := StrToInt(ObtenNsimo(s, 4));
        writeln(j, ' de ', Length(RegAgns));
      end;
    end;
    if j = 300 then begin writeln('ROMPE'); break; end;//***************************************>
  end;
  CloseFile(InfoCiclos);
  SetLength(RegAgns, j);
  Hembras := TStringList.Create;
  InfoHuevos.Carga(Directorio + Diag + ChangeFileExt(NomArch, '.hvs'));
  NombresHuevos := InfoHuevos.ListadoIndicesSimples;
  for i := 0 to NombresHuevos.Count - 1 do
  begin
    s := InfoHuevos.LeeValor(NombresHuevos.Strings[i]);
    Padre := ObtenNsimo(s, 1);
    Madre := ObtenNsimo(s, 2);
    Bandera := False;
    for j := 0 to Hembras.Count - 1 do
    begin
    	Bandera := Hembras.Strings[j] = Madre;
      if Bandera then
      	Break; //->
    end;
    if not Bandera then
    begin
    	Hembras.Add(Madre);
      for k := 0 to Length(RegAgns) - 1 do
      	if RegAgns[k].Nombre = Padre then
        	Inc(RegAgns[k].Parejas);
      WriteLn(Padre, ':', Madre);
    end;
  end;
  WriteLn('Generando registro de apareamientos...');
  AssignFile(InfoAdecuacion, Directorio + Diag + 'mates.csv');
  Rewrite(InfoAdecuacion);
  for i := 0 to Length(RegAgns) - 1 do
  	if RegAgns[i].Prototipo = 1 then
  		WriteLn(InfoAdecuacion, RegAgns[i].Nombre, ', ', RegAgns[i].Prototipo, ', ', RegAgns[i].Parejas);
  for i := 0 to Length(RegAgns) - 1 do
    if RegAgns[i].Prototipo = 2 then
  		WriteLn(InfoAdecuacion, RegAgns[i].Nombre, ', ', RegAgns[i].Prototipo, ', ', RegAgns[i].Parejas);
  CloseFile(InfoAdecuacion);
end;

constructor Tfiltrador.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor Tfiltrador.Destroy;
begin
  inherited Destroy;
end;

procedure Tfiltrador.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: Tfiltrador;

{$IFDEF WINDOWS}{$R filtrador.rc}{$ENDIF}

begin
  Application:=Tfiltrador.Create(nil);
  Application.Title:='Filtrador Galatea';
  Application.Run;
  Application.Free;
end.

