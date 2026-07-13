unit Escenarios;

{$MODE Delphi}

interface

uses
  {ExtCtrls,} SysUtils, {Graphics,} Classes, Comunes, Sustratos;

type
  {Tipos}

  TPorcentajeDespliege = 20..200;

  TEventoDibujaEscenario = procedure (Sender: TObject) of object;

  {Clases}

  TEscenario = class(TGuardable)
  protected
    //Plataforma : TPaintBox;
    Mapa : array of array of TCuadro;
  private
    FAnchura: Word;
    FAltura: Word;
    FPorcentaje: TPorcentajeDespliege;
    FOnDibuja: TEventoDibujaEscenario;
    function GetCuadro(X, Y: Word): TCuadro;
    procedure SetAltura(const Value: Word);
    procedure SetAnchura(const Value: Word);
    procedure SetCuadro(X, Y: Word; const Value: TCuadro);
    procedure SetPorcentaje(const Value: TPorcentajeDespliege);
  public
    Titulo: string[80];
    Comentarios: string;
    DesplazamientoX: Integer;
    DesplazamientoY: Integer;
    Cuadricula: Boolean;
    JuegoSustratos: TJuegoSustratos;
    function ObtenColorSustrato(PCuadro : TCuadro): TColor;
    function XFisica(X: Integer): Integer;
    function YFisica(Y: Integer): Integer;
    function XLogica(X: Integer): Integer;
    function YLogica(Y: Integer): Integer;
    function CuadroFisico: Integer;
    function AlturaFisica: Integer;
    function AnchuraFisica: Integer;
    constructor Create;//(PPlataforma: TPaintBox);
    procedure Despliega;
    procedure Rellena(Sustrato: TCuadro); overload;
    procedure Rellena(X1, Y1, X2, Y2: Integer; Sustrato: TCuadro); overload;
    procedure Guarda(NombreArchivo: string); override;
    procedure Carga(NombreArchivo: string); override;
    property Cuadro[X, Y: Word]: TCuadro
      read GetCuadro write SetCuadro;
    property Anchura: Word
      read FAnchura write SetAnchura default 50;
    property Altura: Word
      read FAltura write SetAltura default 50;
    property Porcentaje: TPorcentajeDespliege
      read FPorcentaje write SetPorcentaje;
    property OnDibuja: TEventoDibujaEscenario read FOnDibuja write FOnDibuja;
   end;

const
  CuadroVacio : TCuadro = '0';

implementation

{ TEscenario }

constructor TEscenario.Create;//(PPlataforma: TPaintBox);
begin
  //Plataforma := PPlataforma;
  FAltura := 50;
  FAnchura := 50;
  Porcentaje := 100;
  JuegoSustratos := TJuegoSustratos.Create;
  DesplazamientoX := 0;
  DesplazamientoY := 0;
  Cuadricula := False;
  SetLength(Mapa, FAnchura, FAltura);
  Rellena(CuadroVacio);
end;

procedure TEscenario.Despliega;
{var
  i, j: Integer; }
begin
  if Assigned(FOnDibuja) then
    TEventoDibujaEscenario(FOnDibuja)(Self);
  {with Plataforma.Canvas do
  begin
    Pen.Style := psSolid;
    Pen.Color := clBlack;
    Brush.Style := bsSolid;
    for i := 0 to FAnchura - 1 do
      for j := 0 to FAltura - 1 do
      begin
        Brush.Color := ObtenColorSustrato(Mapa[i, j]);
        if not Cuadricula then
          Pen.Color := Brush.Color;
        Rectangle(XFisica(i + 1) , YFisica(j + 1),
                  XFisica(i + 1) + CuadroFisico, YFisica(j + 1) + CuadroFisico);
      end
  end; //with }
end;

function TEscenario.AlturaFisica: Integer;
begin
  Result:= (FPorcentaje * FAltura) div 10;
end;

function TEscenario.AnchuraFisica: Integer;
begin
  Result:= (FPorcentaje * FAnchura) div 10;
end;

function TEscenario.GetCuadro(X, Y: Word): TCuadro;
begin
  if (X <= FAnchura) and (Y <= FAltura) then
    Result := Mapa[X - 1,Y - 1]
  else
    //raise EFueraDeRango.Create(ML(mlErrCrdFrInt));//coords fuera de intervalo
    raise EFueraDeRango.Create('Coordenadas fuera de intervalo');
end;

function TEscenario.CuadroFisico: Integer;
begin
  Result := FPorcentaje div 10;
end;

procedure TEscenario.Rellena(Sustrato: TCuadro);
var
 i, j: Integer;
begin
  for i := 0 to FAnchura - 1 do
    for j := 0 to FAltura - 1 do
      Mapa[i,j] := Sustrato;
end;

procedure TEscenario.Rellena(X1, Y1, X2, Y2: Integer; Sustrato: TCuadro);
var
 i, j: Integer;
begin
  for i := X1 - 1 to X2 - 1 do
    for j := Y1 - 1 to Y2 - 1 do
      Mapa[i, j] := Sustrato;
end;

procedure TEscenario.SetAltura(const Value: Word);
var
  AlturaAnterior,
  i, j          : Integer;
begin
  AlturaAnterior := FAltura;
  FAltura := Value;
  SetLength(Mapa, FAnchura, FAltura);
  if AlturaAnterior < FAltura then
  begin
    for i := 0 to FAnchura - 1 do
      for j := AlturaAnterior to FAltura - 1 do
        Mapa[i,j] := CuadroVacio;
  end;
end;

procedure TEscenario.SetAnchura(const Value: Word);
var
  AnchuraAnterior,
  i, j           : Integer;
begin
  AnchuraAnterior := FAnchura;
  FAnchura := Value;
  SetLength(Mapa, FAnchura, FAltura);
  if AnchuraAnterior < FAnchura then
  begin
    for i := AnchuraAnterior to FAnchura - 1 do
      for j := 0 to FAltura - 1 do
        Mapa[i,j] := CuadroVacio;
  end;
end;

procedure TEscenario.SetCuadro(X, Y: Word; const Value: TCuadro);
begin
  if (X <= FAnchura) and (Y <= FAltura) and (X > 0) and (Y > 0) then
    Mapa[X - 1, Y - 1] := Value;
end;

procedure TEscenario.SetPorcentaje(const Value: TPorcentajeDespliege);
begin
  if Value mod 20 = 0 then
    FPorcentaje := Value
  else
    raise EValorInvalido.Create('El porcentaje debe ser múltiplo de 20');
end;

function TEscenario.XFisica(X: Integer): Integer;
begin
  Result := ((CuadroFisico * X) - DesplazamientoX) - CuadroFisico;
end;

function TEscenario.YFisica(Y: Integer): Integer;
begin
  Result := ((CuadroFisico * Y) - DesplazamientoY) - CuadroFisico;
end;

function TEscenario.ObtenColorSustrato(PCuadro : TCuadro): TColor;
var
  i: Integer;
begin
  Result := $FFFFFF; //blanco 
  if Pcuadro in ['1'..'7'] then
  begin
    i := Ord(PCuadro) - 48;
    Result := JuegoSustratos.SustratoSimple[i].Color;
  end
  else if Pcuadro in ['A'..'Z'] then
  begin
    i := Ord(PCuadro) - 64;
    Result := JuegoSustratos.SustratoMixto[i].Color;
  end;
end;

procedure TEscenario.Carga(NombreArchivo: string);
var
  Lineas     : TStringList;
  i, j       : Integer;
  s,
  Linea,
  Caracter   : string;
  Simple     : TSustratoSimple;
  Mixto      : TSustratoMixto;
begin
  inherited Carga(NombreArchivo);
  Titulo := LeeValor('Titulo');
  Anchura := LeeValorEntero('Anchura');
  Altura := LeeValorEntero('Altura');
  JuegoSustratos.NumMixtos := LeeValorEntero('NumSustratosMixtos');
  Lineas:= LeeValorAmpliado('Comentarios');
  Comentarios := Lineas.Text;
  Lineas := LeeValorAmpliado('SustratosSimples');
  i := 0;
  repeat
    Inc(i);
    j := i * 2;
    Simple.Nombre := Lineas.Strings[j-2];
    s := Lineas.Strings[j-1];
    Simple.Color := StrToInt(s);
    JuegoSustratos.SustratoSimple[i] := Simple;
  until i = 7;
  Lineas := LeeValorAmpliado('SustratosMixtos');
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
  Lineas := LeeValorAmpliado('Mapa');
  for j := 0 to FAltura - 1 do
  begin
    s := Lineas.Strings[j];
    for i := 0 to FAnchura - 1 do
    begin
      Caracter :=  Copy(s, i+1, 1);
      Mapa[i,j] := Caracter[1];
    end;
  end;
end;

procedure TEscenario.Guarda(NombreArchivo: string);
var
  Linea  : string;
  Lineas : TStringList;
  i, j   : Integer;
  Simple : TSustratoSimple;
  Mixto  : TSustratoMixto;
begin
  Reestablece;
  Lineas := TStringList.Create;
  EscribeValor('Titulo', Titulo);
  EscribeValor('Anchura', FAnchura);
  EscribeValor('Altura', FAltura);
  EscribeValor('NumSustratosMixtos', JuegoSustratos.NumMixtos);
  Lineas.Clear;
  Lineas.Text := Comentarios;
  EscribeValor('Comentarios', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do
  begin
    Simple := JuegoSustratos.SustratoSimple[i];
    Lineas.Add(Simple.Nombre);
    Lineas.Add(IntAStr(Simple.Color, 8));
  end;
  EscribeValor('SustratosSimples', Lineas);
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
  EscribeValor('SustratosMixtos', Lineas);
  Lineas.Clear;
  for j := 0 to FAltura - 1 do
  begin
    Linea := '';
    for i := 0 to FAnchura - 1 do
      Linea := Linea + Mapa[i,j];
    Lineas.Add(Linea);
  end;
  EscribeValor('Mapa', Lineas);
  inherited Guarda(NombreArchivo);
end;

function TEscenario.XLogica(X: Integer): Integer;
begin
  Result := ((X + DesplazamientoX) div CuadroFisico) + 1;
end;

function TEscenario.YLogica(Y: Integer): Integer;
begin
  Result := ((Y + DesplazamientoY) div CuadroFisico) + 1;
end;

end.
