{*******************************************************************************
Sistema Simulador de Estrategias Reproductivas Galatea

© Derechos Reservados. Benjamín Piña Altamirano. 2005

Registro Instituto Nacional del Derecho de Autor número: xxxxx


GALATEA es una obra registrada y protegida de acuerdo a la Ley Federal del
Derecho de Autor. Todos los derechos sobre esta sistema en conjunto y de cada
uno de los modulos que la integran, son propiedad exclusiva del autor.
Prohibida toda forma de utilización indebida como son: venta, copia, transmisión
por cualquier medio electrónico, sin la autorización por escrito del titular de
derechos.
La trasgresión de cualquiera de estas disposiciones constituye un delito
sancionado severamente por la Ley.
*******************************************************************************}
unit Comunes;

{$MODE Delphi}

{*******************************************************************************
Contiene procedimientos y funciones comunes a los proyectos de Galatea.
Proyecto: Galatea
Versión: 1.0
Autor: Benjamín Piña Altamirano
*******************************************************************************}

interface

uses
  Classes, SysUtils;

type

{Tipos}

  TCoordenadas = record
    X: Integer;
    Y: Integer;
  end;

  EValorInvalido = class (Exception);
  EFueraDeRango  = class (Exception);
  EIncompatibilidad = class (Exception);
  TPorcentajeSustrato = 0..100;
  TColor = -$7FFFFFFF-1..$7FFFFFFF; 

  TCuadro = '0'..'Z';
  TSexo = (sxMacho, sxHembra, sxIndefinido);
  TOpLOgico = (olIgual, olDesigual, olMayorQue, olMenorQue, olMenorIgual,
      olMayorIgual);
  TListaV = array of Integer;

  TMarco = record //Registro con datos para dibujar un rectángulo de marcaje
    X1, Y1,       // sobre controles de edición gráfica.
    X2, Y2: Integer;
  end;

{Clases}

  TGuardable = class
  protected
    IndicesSimples,
    IndicesAmpliados,
    Datos: TStringList;
    function IndiceSimple(Propiedad: string): Integer;
    function IndiceAmpliado(Propiedad: string): Integer;
  public
    function LeeValor(NombrePropiedad: string): string;
    function LeeValorEntero(NombrePropiedad: string): Integer;
    function LeeValorReal(NombrePropiedad: string): Real;
    function LeeValorAmpliado(NombrePropiedad: string): TStringList;
    function ListadoIndicesSimples: TStringList;
    destructor Destroy; override;
    procedure Reestablece;
    procedure EscribeValor(NombrePropiedad, Valor: string); overload;
    procedure EscribeValor(NombrePropiedad: string; Valor: Integer); overload;
    procedure EscribeValor(NombrePropiedad: string; Valor: Real); overload;
    procedure EscribeValor(NombrePropiedad: string;
        Valor: TStringList); overload;
    procedure EscribeValor(Valor: string); overload;
    procedure Guarda(NombreArchivo: string); virtual;
    procedure Actualiza(NombreArchivo: string); overload;
    procedure Actualiza(NombreArchivo: string; TamSeg: Integer); overload;
    procedure Carga(NombreArchivo: string); virtual;
  end;

{Funciones de reales}
function Distancia(X1, Y1, X2, Y2: Integer): Integer;

{Funciones de enteros}
function RestaMin(Minue, Sustrae, Min: Integer): Integer;
function SumaMax(Sum1, Sum2, Max: Integer): Integer;

{Funciones de cadena}
function IntAStr(i: Integer; Longitud: Word): string;
function CadenaLong(Cadena: string; Long: Word): string;
function ObtenNsimo(s: string; N: Word): string;
function NElementosEn(s: string): Integer;
function NVeces(s: string; N: Word): string;
function TruncaAPartirDe(c: Char; s: string): string;
function SustituyeCaracter(cO, cN: Char; s: string): string;
function Sustituye(Original, Nuevo, s: string): string;
function SustituyeConPrefijos(Original, Nuevo, s: string;
                                            Prefijos: array of string): string;
function SustituyeConSufijos(Original, Nuevo, s: string;
                                            Sufijos: array of string): string;
function ComienzaCon(Cadena, Subcadena: string): Boolean;
function TerminaCon(Cadena, Subcadena: string): Boolean;
function Diag: string;

{Funciones azarosas}
function Volado: Boolean;
function CadenaAzaroza(N: Word): string;
function NombreAzarozo: string;
function Dado(NumCaras: Word): Word;
function Ruleta(v: TListaV): Word;
{ Marsaglia-Bray algorithm: }
function RandG(Mean, StdDev : extended) : extended ;

{Otras funciones}
function OpLogico(Operador: string): TOpLOgico;
function Logica(V1: Real; Operador: string; V2: Real): Boolean;

implementation

uses StrUtils;

{Funciones de reales}

function Distancia(X1, Y1, X2, Y2: Integer): Integer;
{Regresa la distancia entre los puntos X1,Y1 y X2,Y2 aplicando el teorema de
Pitágoras}
begin
  Result := Round(Sqrt((Sqr(X1 - X2)) + (Sqr(Y1 - Y2))))
end;

{Funciones de enteros}

function RestaMin(Minue, Sustrae, Min: Integer): Integer;
{Regresa la resta de Minue - Sustrae, en caso de que el resultado sea menor
a Min, regresa Min}
begin
  if Minue - Sustrae >= Min then
    Result := Minue - Sustrae
  else
    Result := Min;
end;

function SumaMax(Sum1, Sum2, Max: Integer): Integer;
{Regresa la suma se Sum1 + Sum2, en caso de que el resultado sea mayor a Max,
regresa Max}
begin
  if Sum1 + Sum2 <= Max then
    Result := Sum1 + Sum2
  else
    Result := Max;
end;

{Funciones de cadena}

function IntAStr(i: Integer; Longitud: Word): string;
{Regresa una cadena de longitud mínima igual al parámetro Longitud formada por
los números del valor de i, los espacios sobrantes se retornan como ceros a la
izquierda.}
var
  j    : Integer;
  s,
  Ceros: string;
begin
  Ceros := '';
  s := IntToStr(i);
  if Length(s) < Longitud then
  begin
    for j := 1 to Longitud - Length(s) do
      Ceros := Ceros + '0';
  end;
  Result := Ceros + s;
end;

function CadenaLong(Cadena: string; Long: Word): string;
var
  i: Integer;
begin
  Result := Cadena;
  if Length(Cadena) = Long then
    Exit; //-->
  if Length(Cadena) > Long then
    Delete(Result, Long + 1, Length(Cadena) - Long)
  else
    for i := Length(Cadena) to Long - 1 do
      Result := Result + ' '; 
end;

function ObtenNsimo(s: string; N: Word): string;
{Obtiene el Nsimo elemento de un conjunto de cadenas, s es una cadena formada
por valores separados por comas, w es la posición dentro de la cadena que se
desea obtener. La numeración de los elementos comienza por 1}
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  Lista.Delimiter := ',';
  Lista.CommaText := s;
  Result := Lista.Strings[N-1];
  Lista.Free;
end;

function NElementosEn(s: string): Integer;
{Regresa el número de elementos en el conjunto de cadenas, s es una cadena
formada por valores separados por comas}
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  Lista.Delimiter := ',';
  Lista.CommaText := s;
  Result := Lista.Count;
  Lista.Free;
end;

function NVeces(s: string; N: Word): string;
{Regresa una cadena que contiene la cadena s reptida N veces}
var
  i : Integer;
  s1: string;
begin
  s1 := '';
  for i := 1 to N do
    s1 := s1 + s;
  Result := s1;
end;

function TruncaAPartirDe(c: Char; s: string): string;
{Regresa la cadena resultante de truncar la cadena s a partir de la primera
vez que se encuentre el caracter c en dicha cadena. La cadena devuelta no
contiene al caracter c}
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if s[i] <> c then
      Result := Result + s[i]
    else
      Exit; //-->
end;

function SustituyeCaracter(cO, cN: Char; s: string): string;
{Regresa la cadena resultante de sustituir el caracter cO por el caracter CN
dentro de la cadena s}
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if s[i] = cO then
      Result := Result + cN
    else
      Result := Result + s[i];
end;

function Sustituye(Original, Nuevo, s: string): string;
{Sustituye la(s) subcadena(s) iguales a Original por la subcadena Nuevo dentro
de la cadena s. Subcadena es cualquier conjunto de caracteres delimitados por
los simbolos / * % ^ + - ( ) y las marcas de inicio y fin de cadena.}
var
  i : Integer;
  Resultado,
  Subcadena: string;
  Delimitadores: set of Char;
begin
  Delimitadores := ['/', '*', '%', '^', '+', '-', '(', ')'];
  Resultado := '';
  Subcadena := '';
  for i := 1 to Length(s) do
  begin
    if (s[i] in Delimitadores) or (i = Length(s)) then
    begin
      if (i = Length(s)) and (not (s[i] in Delimitadores)) then
        Subcadena := Subcadena + s[i];
      if Subcadena = Original then
        Subcadena := Nuevo;
      Resultado := Resultado + Subcadena;
      if s[i] in Delimitadores then
        Resultado := Resultado + s[i];
      Subcadena := '';
    end
    else
      Subcadena := Subcadena + s[i]
   end;
  Result := Resultado;
end;

function SustituyeConPrefijos(Original, Nuevo, s: string;
                                            Prefijos: array of string): string;
{Sustituye la(s) subcadena(s) iguales a Prefijos[j]+Original por la subcadena
Prefijos[j]+Nuevo dentro de la cadena s. Subcadena es cualquier conjunto de
caracteres delimitados por los simbolos / * % ^ + - ( ) y las marcas de inicio
y fin de cadena.}
var
  i,j: Integer;
  Resultado,
  Subcadena: string;
  Delimitadores: set of Char;
begin
  Delimitadores := ['/', '*', '%', '^', '+', '-', '(', ')'];
  Resultado := '';
  Subcadena := '';
  for i := 1 to Length(s) do
  begin
    if (s[i] in Delimitadores) or (i = Length(s)) then
    begin
      if (i = Length(s)) and (not (s[i] in Delimitadores)) then
        Subcadena := Subcadena + s[i];
      for j := 0 to Length(Prefijos) - 1 do
      begin
        if Subcadena = Prefijos[j] + Original then
        begin
          Subcadena := Prefijos[j] + Nuevo;
          Break; //->
        end;
      end;
      Resultado := Resultado + Subcadena;
      if s[i] in Delimitadores then
        Resultado := Resultado + s[i];
      Subcadena := '';
    end
    else
      Subcadena := Subcadena + s[i]
   end;
  Result := Resultado;
end;

function SustituyeConSufijos(Original, Nuevo, s: string;
                                            Sufijos: array of string): string;
{Sustituye la(s) subcadena(s) iguales a Original+Sufijos[j] por la subcadena
NuevoSufijos[j] dentro de la cadena s. Subcadena es cualquier conjunto de
caracteres delimitados por los simbolos / * % ^ + - ( ) y las marcas de inicio
y fin de cadena.}
var
  i, j: Integer;
  Resultado,
  Subcadena: string;
  Delimitadores: set of Char;
begin
  Delimitadores := ['/', '*', '%', '^', '+', '-', '(', ')'];
  Resultado := '';
  Subcadena := '';
  for i := 1 to Length(s) do
  begin
    if (s[i] in Delimitadores) or (i = Length(s)) then
    begin
      if (i = Length(s)) and (not (s[i] in Delimitadores)) then
        Subcadena := Subcadena + s[i];
      for j := 0 to Length(Sufijos) - 1  do
      begin
        if Subcadena = Original + Sufijos[j] then
        begin
          Subcadena := Nuevo + Sufijos[j];
          Break; //->
        end;
      end;
      Resultado := Resultado + Subcadena;
      if s[i] in Delimitadores then
        Resultado := Resultado + s[i];
      Subcadena := '';
    end
    else
      Subcadena := Subcadena + s[i]
   end;
  Result := Resultado;
end;

function ComienzaCon(Cadena, Subcadena: string): Boolean;
var
  i: Integer;
begin
  i := Length(Subcadena);
  Result := Subcadena = LeftStr(Cadena, i);
end;

function TerminaCon(Cadena, Subcadena: string): Boolean;
var
  i: Integer;
begin
  i := Length(Subcadena);
  Result := Subcadena = RightStr(Cadena, i);
end;

function Diag: string;
begin
  {$IFDEF WIN32}
    Result := '\'
  {$ENDIF}
  {$IFDEF LINUX}
    Result := '/';
  {$ENDIF}
end;

{Funciones azarosas}

function Volado: Boolean;
var
  i: Integer;
begin
  i := Random(2);
  Result := i = 0;
end;

function CadenaAzaroza(N: Word): string;
{Regresa una cadena alfanumérica de longitud N, formada por caracteres al azar
comprendidos entre ['0'..'9', 'a'..'z']}
var
  i : Integer;
  c : Char;
  s : string;
  ss: array [1..36] of Char;
begin
  i := 1;
  for c := '0' to '9' do
  begin
    ss[i] := c;
    Inc(i);
  end;
  for c := 'a' to 'z' do
  begin
    ss[i] := c;
    Inc(i);
  end;
  s := '';
  for i := 1 to N do
    s := s + ss[Random(36)+1];
  Result := s;
end;

function NombreAzarozo: string;
{Regresa una cadena formada al azar de 10 caracteres, 5 alfabéticos y 5
numéricos}
var
  i: Integer;
  s1, s2: string;
const
  Letras: array [1..26] of Char = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
                                   'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
                                   's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
  Numeros: array [1..10] of Char = ('0', '1', '2', '3', '4', '5', '6', '7',
                                    '8', '9');
begin
  s1 := '';
  s2 := '';
  for i := 1 to 5 do
  begin
    s1 := s1 + Letras[Random(26)+1];
    s2 := s2 + Numeros[Random(10)+1];
  end;
  Result := s1 + s2;
end;

function Dado(NumCaras: Word): Word;
{Regresa el resultado de un sorteo de un dado con una cantidad de caras igual
a NumCaras, el valor de retorno va de 1 a Numcaras}
begin
  Result := Random(NumCaras) + 1;
end;

{** CONCEPTO ABANDONADO
function Ruleta(V: TListaV): Word;
Regresa un valor comprendido entre 1 y (Longitud de V) las probabilidades
de regresar el valor n corresponden al valor contenido en V[n]. Se suman todos
los valores en V, después se crea el arreglo tómbola cuya longitud será igual
a la suma de todos los valores en V. Tombola contendrá valores correspondientes
a posiciones de V repetidos tantas veces como la cantidad contenida en tal
posición de V. Se elige al azar un valor en Tombola y se regresa dicha valor.
Ejemplo:

Si V = (5,3,1) entonces Tombola = (1,1,1,1,1,2,2,2,3). Si al azar se elige la
posición 3 de Tombola, entonces el valor devuelto será 1.
De esta forma las probabilidades de regresar 1 son 5 sobre 8, de regresar 2 son
3 sobre 8, y de regresar 3 son 1 sobre 8
var
  Suma,
  i, j,
  k     : Integer;
  Tombola: TListaV;
begin
  Suma := 0;
  for i := 0 to Length(V) - 1 do
    Suma := Suma + V[i];
  SetLength(Tombola, Suma);
  k := 0;
  for i := 0 to Length(V) - 1 do
    for j := 1 to V[i] do
    begin
      Tombola[k] := i;
      Inc(k);
    end;
  i := Random(Suma) + 1;
  Result := Tombola[i-1];
end;}

function Ruleta(V: TListaV): Word;
{Regresa un valor comprendido entre 1 y (Longitud de V) las probabilidades
de regresar el valor n corresponden al valor contenido en V[n].
Ejemplo:

Si V = (5,3,1) entonces las probabilidades de regresar 1 son 5 sobre 8, de
regresar 2 son 3 sobre 8, y de regresar 3 son 1 sobre 8

En caso de que todos los calores en V sean iguales a cero, sustituye todos los
valores por 1}
var
  i,
  Azarosa,
  Suma: Integer;
begin
  Result := 0;
  Suma := 0;
  for i := 0 to Length(V) - 1 do
  begin
    if V[i] < 0 then    //Si es negativo
      V[i] := 0;
    Suma := Suma + V[i];
  end;
  if Suma = 0 then      //Todos los valores iguales a 0
  begin
    for i := 0 to Length(V) - 1 do
      V[i] := 1;        //Inicializar todos los valores como 1
    Suma := Length(V);  //Suma
  end;
  Azarosa := Random(Suma) + 1;
  Suma := 0;
  for i  := 0 to Length(V) - 1 do
  begin
    Suma := Suma + V[i];
    if Azarosa <= Suma then
    begin
      Result := i + 1;
      Exit; //-->
    end;
  end;
end;

{ Marsaglia-Bray algorithm: }
function RandG(Mean, StdDev : extended) : extended ;
{Regresa un numero aleatorio con distribucion normal, con media Mean y
desviacion estandar StdDev} 
var U1, S2 : extended ;
begin
  repeat
    U1 := 2*Random - 1 ;
    S2 := Sqr(U1) + Sqr(2*Random-1) ;
    until S2 < 1 ;
  Result := Sqrt(-2*Ln(S2)/S2) * U1 * StdDev + Mean ;
end;

{Otras funciones}

function OpLogico(Operador: string): TOpLOgico;
{Convierte la cadena Operador a un valor de tipo TOpLogico.
Ejemplo: Si Operador = '>', regresa olMayorQue}
begin
  Result := olIgual;
  if Operador = '=' then
    Result := olIgual
  else if  Operador = '<>' then
    Result := olDesigual
  else if  Operador = '<' then
    Result := olMenorQue
  else if  Operador = '>' then
    Result := olMayorQue
  else if  (Operador = '<=') or (Operador = '=<') then
    Result := olMenorIgual
  else if  (Operador = '>=') or (Operador = '=>') then
    Result := olMayorIgual;
end;

function Logica(V1: Real; Operador: string; V2: Real): Boolean;
{Regresa el resultado de la operación lógica V1 Operador V2, donde operador
previamente es convertido al tipo TOpLogico con la función OpLogico}
begin
  Result := False;
  case OpLogico(Operador) of
    olIgual     : Result := V1 =  V2;
    olDesigual  : Result := V1 <> V2;
    olMayorQue  : Result := V1 >  V2;
    olMenorQue  : Result := V1 <  V2;
    olMenorIgual: Result := V1 <= V2;
    olMayorIgual: Result := V1 >= V2;
  end;
end;

procedure TGuardable.Carga(NombreArchivo: string);
var
  s,
  Linea: string;
  i, j: Integer;
begin
  Reestablece;
  Datos.LoadFromFile(NombreArchivo);
  for i := 0 to Datos.Count - 1 do
  begin
    s := '';
    Linea := Datos.Strings[i];
    j := 0;
    repeat
      Inc(j);
      s := s + Copy(Linea, j, 1);
    until (Copy(Linea, j, 1) = '=') or (Copy(Linea, j, 1) = '{')
        or (j = Length(Linea)) or (Length(Linea) = 0);
    if TerminaCon(s, '=') then
      IndicesSimples.Add(s + IntToStr(i))
    else if TerminaCon(s, '{') then
      IndicesAmpliados.Add(s + IntToStr(i));
  end;
end;

destructor TGuardable.Destroy;
begin
  IndicesSimples.Free;
  IndicesAmpliados.Free;
  Datos.Free;
  inherited Destroy;
end;

procedure TGuardable.Guarda(NombreArchivo: string);
begin
  Datos.SaveToFile(NombreArchivo);
end;

function TGuardable.LeeValor(NombrePropiedad: string): string;
var
  s,
  Linea: string;
  i    : Integer;
begin
  Result := '';
  s := '';
  i := IndiceSimple(NombrePropiedad);
  if i = - 1 then
    Exit; //-->
  Linea := Datos.Strings[i];
  i := Length(Linea) + 1;
  repeat
    Dec(i);
    s := Linea[i] + s;
  until (Linea[i - 1] = '=') or (i = 2);
  if i > 2 then
    Result := s;
end;

function TGuardable.LeeValorAmpliado(NombrePropiedad: string): TStringList;
var
  i, j : Integer;
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  Result := Lista;
  j := IndiceAmpliado(NombrePropiedad);
  if j = - 1 then
    Exit; //-->
  i := j;
  repeat
    Inc(i);
    if Datos.Strings[i] <> '}' then
      Lista.Add(Datos[i]);
  until (Datos.Strings[i] = '}') or (i = Datos.Count - 1);
  Result := Lista;
end;

function TGuardable.LeeValorEntero(NombrePropiedad: string): Integer;
var
  s,
  Linea: string;
  i    : Integer;
begin
  Result := 0;
  s := '';
  i := IndiceSimple(NombrePropiedad);
  if i = - 1 then
    Exit; //-->
  Linea := Datos.Strings[i];
  i := Length(Linea) + 1;
  repeat
    Dec(i);
    s := Linea[i] + s;
  until (Linea[i - 1] = '=') or (i = 2);
  if i > 2 then
    Result := StrToInt(s);
end;

function TGuardable.LeeValorReal(NombrePropiedad: string): Real;
var
  s,
  Linea: string;
  i    : Integer;
begin
  Result := 0;
  s := '';
  i := IndiceSimple(NombrePropiedad);
  if i = - 1 then
    Exit; //-->
  Linea := Datos.Strings[i];
  i := Length(Linea) + 1;
  repeat
    Dec(i);
    s := Linea[i] + s;
  until (Linea[i - 1] = '=') or (i = 2);
  if i > 2 then
    Result := StrToFloat(s);
end;

function TGuardable.IndiceAmpliado(Propiedad: string): Integer;
var
  s,
  Linea: string;
  i, j: Integer;
begin
  Result := - 1;
  for i := 0 to IndicesAmpliados.Count - 1 do
  begin
    Linea := IndicesAmpliados.Strings[i];
    if ComienzaCon(Linea, Propiedad + '{') then
    begin
      j := Length(Linea) - Length(Propiedad) - 1;
      s := Copy(Linea, Length(Propiedad) + 2, j);
      Result := StrToInt(s);
      Exit; //-->
    end;
  end;  //for IndicesAmpliados
end;

function TGuardable.IndiceSimple(Propiedad: string): Integer;
var
  s,
  Linea: string;
  i, j: Integer;
begin
  Result := - 1;
  for i := 0 to IndicesSimples.Count - 1 do
  begin
    Linea := IndicesSimples.Strings[i];
    if ComienzaCon(Linea, Propiedad) then
    begin
      j := Length(Linea) - Length(Propiedad) - 1;
      s := Copy(Linea, Length(Propiedad) + 2, j);
      Result := StrToInt(s);
      Exit; //-->
    end;
  end;  //for IndicesSimples
end;

procedure TGuardable.EscribeValor(NombrePropiedad: string; Valor: Integer);
begin
  Datos.Add(NombrePropiedad + '=' + IntToStr(Valor));
end;

procedure TGuardable.EscribeValor(NombrePropiedad, Valor: string);
begin
  Datos.Add(NombrePropiedad + '=' + Valor);
end;

procedure TGuardable.EscribeValor(NombrePropiedad: string;
  Valor: TStringList);
var
  i : Integer;
begin
  Datos.Add(NombrePropiedad + '{');
  for i := 0 to Valor.Count - 1 do
    Datos.Add(Valor.Strings[i]);
  Datos.Add('}');
end;

procedure TGuardable.EscribeValor(NombrePropiedad: string; Valor: Real);
begin
  Datos.Add(NombrePropiedad + '=' + FloatToStr(Valor));
end;

procedure TGuardable.Reestablece;
begin
  IndicesSimples.Free;
  IndicesAmpliados.Free;
  Datos.Free;
  IndicesSimples := TStringList.Create;
  IndicesAmpliados := TStringList.Create;
  Datos := TStringList.Create;
end;

procedure TGuardable.EscribeValor(Valor: string);
begin
  Datos.Add(Valor);
end;

procedure TGuardable.Actualiza(NombreArchivo: string);
var
  i: Integer;
  Archivo: TextFile;
begin
  AssignFile(Archivo, NombreArchivo);
  if FileExists(NombreArchivo) then
    Append(Archivo)
  else
    Rewrite(Archivo);
  for i := 0 to Datos.Count - 1 do
    Writeln(Archivo, Datos.Strings[i]);
  Datos.Clear;
  CloseFile(Archivo);
end;

procedure TGuardable.Actualiza(NombreArchivo: string; TamSeg: Integer);
var
  i,
  Tam: Integer;
  Archivo: TextFile;
  Arch: File;
  Band: Boolean;
  Ext: string;
begin
  AssignFile(Arch, NombreArchivo);
  if FileExists(NombreArchivo) then
    Tam := FileSize(Arch) * 128;
  CloseFile(Arch);
  AssignFile(Archivo, NombreArchivo);
  if FileExists(NombreArchivo) then
  begin
    Append(Archivo);
    //Tam := FileSize(Archivo) * 128;
    if Tam > TamSeg then
    begin
      Band := False;
      Ext := ExtractFileExt(NombreArchivo);
      NombreArchivo := ChangeFileExt(NombreArchivo, '');
      i := 0;
      while not Band do
      begin
        Inc(i);
        Band := not(FileExists(NombreArchivo + IntToStr(i) + Ext));
      end;
      NombreArchivo := NombreArchivo + IntToStr(i) + Ext;
      AssignFile(Archivo,  NombreArchivo);
      Rewrite(Archivo);
    end;
  end
  else
    Rewrite(Archivo);
  for i := 0 to Datos.Count - 1 do
    Writeln(Archivo, Datos.Strings[i]);
  Datos.Clear;
  CloseFile(Archivo);
end;

function TGuardable.ListadoIndicesSimples: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;;
  for i := 0 to IndicesSimples.Count - 1 do
    Result.Add(TruncaAPartirDe('=', IndicesSimples.Strings[i]));
end;

end.

