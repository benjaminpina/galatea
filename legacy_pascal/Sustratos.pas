unit Sustratos;

{$MODE Delphi}

{*******************************************************************************
Implementación del tipo TJuegoSustratos

Sistema Galatea
Autor: Benjamín Piña Altamirano
2002
*******************************************************************************}

interface

uses
  {Graphics,} SysUtils, Classes, Comunes;

type

  {Tipos}

  TSustratoSimple = record
    Nombre: string[15];
    Color: TColor;
  end;

  TSustratoMixto = record
    Porcentajes: array [1..7] of TPorcentajeSustrato;
    Color: TColor;
  end;

  {Clases}

  TJuegoSustratos = class(TGuardable)
  protected
    FSimples: array [1..7] of TSustratoSimple;
    FMixtos: array of TSustratoMixto;
  private
    FNumMixtos: Integer;
    function GetSustratoMixto(i: Integer): TSustratoMixto;
    function GetSustratoSimple(i: Integer): TSustratoSimple;
    procedure SetNumMixtos(const Value: Integer);
    procedure SetSustratoMixto(i: Integer; const Value: TSustratoMixto);
    procedure SetSustratoSimple(i: Integer; const Value: TSustratoSimple);
  public
    Titulo: string[80];
    Comentarios: string;
    constructor Create;
    procedure Guarda(NombreArchivo: string); override;
    procedure Carga(NombreArchivo: string); override;
    procedure EliminaMixto(i: Integer);
    property NumMixtos: Integer
      read FNumMixtos write SetNumMixtos;
    property SustratoSimple[i: Integer]: TSustratoSimple
      read GetSustratoSimple write SetSustratoSimple;
    property SustratoMixto[i: Integer]: TSustratoMixto
      read GetSustratoMixto write SetSustratoMixto;
  end;

implementation

{ TJuegoSustratos }

constructor TJuegoSustratos.Create;
var
  i: Integer;
begin
  for i := 1 to 7 do
  begin
    FSimples[i].Color := $FFFFFF; //blanco 
  end;
  NumMixtos := 1;
end;

procedure TJuegoSustratos.Carga(NombreArchivo: string);
var
  Lineas     : TStringList;
  Linea,
  sColor,
  sPorcentaje: string;
  i, j       : Integer;
begin
  inherited Carga(NombreArchivo);
  Titulo := LeeValor('Titulo');
  NumMixtos := LeeValorEntero('NumMixtos');
  Lineas := LeeValorAmpliado('Comentarios');
  Comentarios := Lineas.Text;
  Lineas := LeeValorAmpliado('SustratosSimples');
  i := 0;
  repeat
    Inc(i);
    j := i * 2;
    FSimples[i].Nombre := Lineas.Strings[j-2];
    sColor := Lineas.Strings[j-1];
    FSimples[i].Color := StrToInt(sColor);
  until i = 7;
  Lineas := LeeValorAmpliado('SustratosMixtos');
  for i := 0 to FNumMixtos - 1 do
  begin
    Linea := Lineas.Strings[i];
    for j := 1 to 7 do
    begin
      sPorcentaje := Copy(Linea, (j * 3) - 2, 3);
      FMixtos[i].Porcentajes[j] := StrToInt(sPorcentaje);
    end;
    sColor := Copy(Linea, 22, 8);
    FMixtos[i].Color := StrToInt(sColor);
  end;
end;

procedure TJuegoSustratos.Guarda(NombreArchivo: string);
var
  Linea  : string;
  i, j   : Integer;
  Lineas : TStringList;
begin
  Reestablece;
  EscribeValor('Titulo', Titulo);
  EscribeValor('NumMixtos', NumMixtos);
  Lineas := TStringList.Create;
  Lineas.Text := Comentarios;
  EscribeValor('Comentarios', Lineas);
  Lineas.Clear;
  for i := 1 to 7 do
  begin
    Lineas.Add(FSimples[i].Nombre);
    Lineas.Add(IntAStr(FSimples[i].Color, 8));
  end;
  EscribeValor('SustratosSimples', Lineas);
  Lineas.Clear;
  for i := 1 to FNumMixtos do
  begin
    Linea := '';
    for j := 1 to 7 do
        Linea := Linea + IntAStr(SustratoMixto[i].Porcentajes[j], 3);
    Linea := Linea + IntAStr(SustratoMixto[i].Color, 8);
    Lineas.Add(Linea);
  end;
  EscribeValor('SustratosMixtos', Lineas);
  Lineas.Free;
  inherited Guarda(NombreArchivo);
end;

function TJuegoSustratos.GetSustratoMixto(i: Integer): TSustratoMixto;
begin
  if (i <= FNumMixtos) and (i > 0) then
    Result := FMixtos[i-1]
  else
    raise EFueraDeRango.Create('Índice de sustrato mixto fuera de intervalo');
end;

function TJuegoSustratos.GetSustratoSimple(i: Integer): TSustratoSimple;
begin
  if (i <= 7) and (i > 0) then
    Result := FSimples[i]
  else
    raise EFueraDeRango.Create('Índice de sustrato simple fuera de intervalo');
end;


procedure TJuegoSustratos.SetNumMixtos(const Value: Integer);
var
  i, j,
  NumAnterior: Integer;
begin
  if (Value > 26) or (Value < 1) then
  begin
    raise EValorInvalido.Create('Valor mayor o menor al permitido '
                                  + ' (1-26)');
    Exit; //-->
  end;
  NumAnterior := FNumMixtos;
  FNumMixtos := Value;
  SetLength(FMixtos, Value);
  if NumAnterior < Value then
  begin
    for i := NumAnterior to Value - 1 do
    begin
      for j := 1 to 7 do
        FMixtos[i].Porcentajes[j] := 0;
      FMixtos[i].Color := $FFFFFF; //blanco 
    end;
  end;
end;

procedure TJuegoSustratos.SetSustratoMixto(i: Integer;
  const Value: TSustratoMixto);
begin
  if (i <= FNumMixtos) and (i > 0) then
    FMixtos[i-1] := Value
  else
    //raise EFueraDeRango.Create(ML(mlErrIndFrInt)); //índice fuera de intervalo
    raise EFueraDeRango.Create('Índice de sustrato mixto fuera de intervalo');
end;

procedure TJuegoSustratos.SetSustratoSimple(i: Integer;
  const Value: TSustratoSimple);
begin
  if (i <= 7) and (i > 0) then
    FSimples[i] := Value
  else
    //raise EFueraDeRango.Create(ML(mlErrIndFrInt)); //índice fuera de intervalo
    raise EFueraDeRango.Create('Índice de sustrato simple fuera de intervalo');
end;

procedure TJuegoSustratos.EliminaMixto(i: Integer);
var
  j: Integer;
begin
  if (i <= FNumMixtos) and (i > 0) then
  begin
    for j := i - 1 to FNumMixtos - 2 do
      FMixtos[j] := FMixtos[j+1];
    NumMixtos := FNumMixtos -  1;
  end
  else
    //raise EFueraDeRango.Create(ML(mlErrIndFrInt)); //índice fuera de intervalo
    raise EFueraDeRango.Create('Índice de sustrato mixto fuera de intervalo');
end;

end.
