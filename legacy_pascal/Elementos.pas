unit Elementos;

{$MODE Delphi}

interface

uses
  {ExtCtrls,} Contnrs;

type

  TTipoED = (edFntAgua, edFntGrasa, edFntAzucar, edFntProteina, edStOvpscn);

  TEventoDibuja = procedure (Sender: TObject; XFisica, YFisica,
      CuadroFisico: Word) of object;

  TElemento = class
  private
    FOnDibuja: TEventoDibuja;
  protected
    //Plataforma: TPaintBox;
  public
    X, Y: Word;
    Nombre: string;
    //constructor Create(PPlataforma: TPaintBox); virtual;
    constructor Create; virtual;
    procedure Dibuja(XFisica, YFisica, CuadroFisico: Word); virtual; abstract;
    procedure Actualiza; virtual; abstract;
    property OnDibuja: TEventoDibuja read FOnDibuja write FOnDibuja;
  end;

  TDinamico = class(TElemento)
  private
    FNivel: Integer;
    procedure SetNivel(const Value: Integer);
  public
    TipoED: TTipoED;
    Calidad: Integer;
    Maximo: Integer;
    Tasa: Real;
    function ElementoListado: Word;
    //constructor Create(PPlataforma: TPaintBox); override;
    constructor Create; override;
    procedure Dibuja(XFisica, YFisica, CuadroFisico: Word); override;
    procedure Actualiza; override;
    property Nivel: Integer
      read FNivel write SetNivel;
  end;

  TSitioOviposicion = class(TDinamico)
  public
    //constructor Create(PPlataforma: TPaintBox); override;
    constructor Create; override;
    procedure Dibuja(XFisica, YFisica, CuadroFisico: Word); override;
  end;

  TListaDinamicos = class
  private
    FLista: TObjectList;
    procedure SetElemento (Index: Integer; Obj: TDinamico);
    function GetElemento (Index: Integer): TDinamico;
    function GetContador: Integer;
    function GetElementoPorNombre(PNombre: string): TDinamico;
  public
    constructor Create;
    destructor Destroy; override;
    function Agrega (Obj: TDinamico): Integer;
    function Retira (Obj: TDinamico): Integer;
    function IndiceDe (Obj: TDinamico): Integer;
    procedure Inserta(Index: Integer; Obj: TDinamico);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: TDinamico
      read GetElemento write SetElemento;
    property ElementosPorNombre [PNombre: string]: TDinamico
      read GetElementoPorNombre;
  end;

  TListaOviposicion = class
  private
    FLista: TObjectList;
    procedure SetElemento (Index: Integer; Obj: TSitioOviposicion);
    function GetElemento (Index: Integer): TSitioOviposicion;
    function GetContador: Integer;
    function GetElementoPorNombre(PNombre: string): TSitioOviposicion;
  public
    constructor Create;
    destructor Destroy; override;
    function Agrega (Obj: TSitioOviposicion): Integer;
    function Retira (Obj: TSitioOviposicion): Integer;
    function IndiceDe (Obj: TSitioOviposicion): Integer;
    procedure Inserta(Index: Integer; Obj: TSitioOviposicion);
    property Contador: Integer
      read GetContador;
    property Elementos [Index: Integer]: TSitioOviposicion
      read GetElemento write SetElemento;
    property ElementosPorNombre [PNombre: string]: TSitioOviposicion
      read GetElementoPorNombre;
  end;

implementation

uses {Graphics,} Comunes;

{ TElemento }

constructor TElemento.Create;//(PPlataforma: TPaintBox);
begin
  //Plataforma := PPlataforma;
  Nombre := CadenaAzaroza(10);
  X := 1;
  Y := 1;
end;

{ TDinamico }

procedure TDinamico.Actualiza;
begin
  if Round(Nivel * Tasa) <= Maximo then
    Nivel := Round(Nivel * Tasa)
  else
    Nivel := Maximo;
  if Nivel = 0 then
  	Nivel := 10;   //Evitar que se quede perpetuamente en cero
end;

constructor TDinamico.Create;//(PPlataforma: TPaintBox);
begin
  inherited Create;//(PPlataforma);
  Calidad := 10;
  Maximo := 100;
  Tasa := 1.1;
  FNivel := 50;
  TipoED := edFntAgua;
end;

procedure TDinamico.Dibuja(XFisica, YFisica, CuadroFisico: Word);
begin
  if Assigned(FOnDibuja) then
    TEventoDibuja(FOnDibuja)(Self, XFisica, YFisica, CuadroFisico);
 { with Plataforma.Canvas do
  begin
    Brush.Style := bsSolid;
    Pen.Style := psSolid;
    Pen.Color := clBlack;
    case TipoED of
      edFntAgua    : Brush.Color := clAqua;
      edFntGrasa   : Brush.Color := clYellow;
      edFntAzucar  : Brush.Color := clWhite;
      edFntProteina: Brush.Color := clRed;
      edStOvpscn   : Brush.Color := clGreen;
    end;
    Ellipse(XFisica, YFisica, XFisica + CuadroFisico, YFisica + CuadroFisico);
  end;  //with }
end;

function TDinamico.ElementoListado: Word;
{Regresa la posición del tipo de elemento según una lista en la que los tipos
se establecen en el siguiente orden: FntAgua, FntAzucar, FntGrasa, FntProteina
y StOvpscn}
begin
  Result := 1;
  case TipoED of
    edFntAgua    : Result := 1;
    edFntAzucar  : Result := 2;
    edFntGrasa   : Result := 3;
    edFntProteina: Result := 4;
    edStOvpscn   : Result := 5;
  end;
end;

procedure TDinamico.SetNivel(const Value: Integer);
begin
  if Value <= Maximo then
    FNivel := Value
  else if TipoED = edStOvpscn then
    raise EFueraDeRango.Create('Valor por encima del maximo nivel para '
        + 'el elemento [Dinamico.SetNivel:' + Nombre + ']')
  else
  	FNivel := Maximo;
end;

{ TSitioOviposicion }

constructor TSitioOviposicion.Create;
begin
  inherited Create;//(PPlataforma);
  TipoED := edStOvpscn;
  Nivel := 0;
end;

procedure TSitioOviposicion.Dibuja(XFisica, YFisica, CuadroFisico: Word);
begin
  inherited Dibuja(XFisica, YFisica, CuadroFisico);
  {if Nivel > 0 then //Marcar que sitio contiene huevos
  begin
    with Plataforma.Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      Brush.Color := clYellow;
      Ellipse((XFisica + (CuadroFisico div 2)) - 1,
              (YFisica + (CuadroFisico div 2)) - 1,
              (XFisica + (CuadroFisico div 2)) + 1,
              (YFisica + (CuadroFisico div 2)) + 1);
    end;}
end;

{ TListaDinamicos }

function TListaDinamicos.Agrega(Obj: TDinamico): Integer;
begin
  Result := FLista.Add(Obj) + 1;
end;

constructor TListaDinamicos.Create;
begin
  inherited Create;
  FLista := TObjectList.Create;
end;

destructor TListaDinamicos.Destroy;
begin
  FLista.Free;
  inherited Destroy;
end;

function TListaDinamicos.GetContador: Integer;
begin
  Result := FLista.Count;
end;

function TListaDinamicos.GetElemento(Index: Integer): TDinamico;
begin
  Result := FLista[Index - 1] as TDinamico;
end;

function TListaDinamicos.GetElementoPorNombre(PNombre: string): TDinamico;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to Contador do
    if Elementos[i].Nombre = PNombre then
      Result := Elementos[i];
end;

function TListaDinamicos.IndiceDe(Obj: TDinamico): Integer;
begin
  Result := FLista.IndexOf(Obj) + 1;
end;

procedure TListaDinamicos.Inserta(Index: Integer; Obj: TDinamico);
begin
  FLista.Insert(Index - 1, Obj);
end;

function TListaDinamicos.Retira(Obj: TDinamico): Integer;
begin
   Result := FLista.Remove(Obj) + 1;
end;

procedure TListaDinamicos.SetElemento(Index: Integer; Obj: TDinamico);
begin
  FLista[Index - 1] := Obj;
end;

{ TListaOviposicion }

function TListaOviposicion.Agrega(Obj: TSitioOviposicion): Integer;
begin
  Result := FLista.Add(Obj) + 1;
end;

constructor TListaOviposicion.Create;
begin
  inherited Create;
  FLista := TObjectList.Create;
end;

destructor TListaOviposicion.Destroy;
begin
  FLista.Free;
  inherited Destroy;
end;

function TListaOviposicion.GetContador: Integer;
begin
  Result := FLista.Count;
end;

function TListaOviposicion.GetElemento(Index: Integer): TSitioOviposicion;
begin
  Result := FLista[Index - 1] as TSitioOviposicion;
end;

function TListaOviposicion.GetElementoPorNombre(
  PNombre: string): TSitioOviposicion;
var
  i: Integer;
begin
  Result := nil;
  for i := 1 to Contador do
    if Elementos[i].Nombre = PNombre then
      Result := Elementos[i];
end;

function TListaOviposicion.IndiceDe(Obj: TSitioOviposicion): Integer;
begin
  Result := FLista.IndexOf(Obj) + 1;
end;

procedure TListaOviposicion.Inserta(Index: Integer;
  Obj: TSitioOviposicion);
begin
  FLista.Insert(Index - 1, Obj);
end;

function TListaOviposicion.Retira(Obj: TSitioOviposicion): Integer;
begin
  Result := FLista.Remove(Obj) - 1;
end;

procedure TListaOviposicion.SetElemento(Index: Integer;
  Obj: TSitioOviposicion);
begin
  FLista[Index - 1] := Obj;
end;

end.
