unit Dialogos;

{$MODE Delphi}

{*******************************************************************************
Contiene diversas funciones y procedimientos relacionados con cuadros de
di�logos comunes.

Autor: Benjam�n Pi�a Altamirano
Agosto del 2002

Actualizado: Diciembre 2003
Se sustituy� el m�todo Application.MessageBox por la funci�n MessageDlg de
la unidad Dialogs. Dado que al migrar a la versi�n 7 de Delphi dicho m�todo
generaba adevertencias de seguridad por el tipo PChar que manejaba.

Actualizado: Diciembre 2003
Se regres� al uso del m�todo Application.MessageBox ya que la funci�n MessageDlg
no se adapta al idioma local y no permite personalizar la barra de t�tulo,
adem�s se encontr� otra forma de contrarrestar los probelmas por el uso del
tipo PChar. El problema desaparece simplemente utilizando un arreglo de Char,
los cuales son tratados por el sistema como PChar, sin generar adevertencias de
seguridad.

Actualizado: Diciembre 2003
Se regres� a la implementaci�n original, debido a que el uso de arreglos de
Char en sustituci�n de PChar eliminaba el texto de los cuadros de di�logo
generados. Para eliminar las edvertecnias del uso de PChar se recurri� a
directivas de compilaci�n $WARNINGS ON|OFF
*******************************************************************************}

interface

type
  TRespuesta = (rSi, rNo, rCancelar, rAbortar, rReiterar, rIgnorar, rAceptar);

function PreguntaSN(Texto, Titulo: string): TRespuesta;
function PreguntaSNC(Texto, Titulo: string): TRespuesta;
function FalloSN(Texto, Titulo: string): TRespuesta;
function FalloARI(Texto, Titulo: string): TRespuesta;
function FalloSNC(Texto, Titulo: string): TRespuesta;
function FalloRC(Texto, Titulo: string): TRespuesta;
function ExclamaSN(Texto, Titulo: string): TRespuesta;
function ExclamaSNC(Texto, Titulo: string): TRespuesta;
procedure Informa(Texto, Titulo: string);
procedure Fallo(Texto, Titulo: string);
procedure Exclama(Texto, Titulo: string);

implementation

uses
  Forms, LResources, LCLType,Dialogs;

function PreguntaSN(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de pregunta, regresa rSi o rNO}
var
  i: Integer;
begin
  Texto := Texto + '?';
  {$WARNINGS OFF}
  i :=  Application.MessageBox(PChar(Texto), PChar(Titulo),
                                MB_YESNO + MB_ICONQUESTION);
  {$WARNINGS ON}
  if i = idYes then
    Result := rSi
  else
    Result := rNo;
end;

function PreguntaSNC(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de pregunta, regresa rSi, rNO o
rCancelar}
var
  i: Integer;
begin
  Texto := Texto + '?';
  {$WARNINGS OFF}
  i := Application.MessageBox(PChar(Texto), PChar(Titulo), MB_YESNOCANCEL
                                      + MB_ICONQUESTION);
  {$WARNINGS ON}
  Result := rSi;
  case i of
    idYes   : Result := rSi;
    idNo    : Result := rNo;
    idCancel: Result := rCancelar;
  end;
end;

function FalloSN(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de error, regresa rSi o rNo}
var
  i: Integer;
begin
  {$WARNINGS OFF}
  i :=  Application.MessageBox(PChar(Texto), PChar(Titulo)
                                , MB_YESNO + MB_ICONERROR);
  {$WARNINGS ON}
  if i = idYes then
    Result := rSi
  else
    Result := rNo;
end;

function FalloARI(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de error, regresa rAbortar, rReiterar
o rIgnorar}
var
  i: Integer;
begin
  {$WARNINGS OFF}
  i := Application.MessageBox(PChar(Texto), PChar(Titulo),
                            MB_ABORTRETRYIGNORE + MB_ICONERROR);
  {$WARNINGS ON}
  Result := rAbortar;
  case i of
    idAbort : Result := rAbortar;
    idRetry : Result := rReiterar;
    idIgnore: Result := rIgnorar;
  end;
end;

function FalloSNC(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de error, regresa rSi, rNo o rCancelar}
var
  i: Integer;
begin
  {$WARNINGS OFF}
  i := Application.MessageBox(PChar(Texto), PChar(Titulo),
                                MB_YESNOCANCEL + MB_ICONERROR);
  {$WARNINGS ON}
  Result := rSi;
  case i of
    idYes   : Result := rSi;
    idNo    : Result := rNo;
    idCancel: Result := rCancelar;
  end;
end;

function FalloRC(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de error, regresa rReiterar o rCancelar}
var
  i: Integer;
begin
  {$WARNINGS OFF}
  i := Application.MessageBox(PChar(Texto), PChar(Titulo),
                              MB_YESNOCANCEL + MB_ICONERROR);
  {$WARNINGS ON}
  Result := rCancelar;
  case i of
    idRetry : Result := rReiterar;
    idCancel: Result := rCancelar;
  end;
end;

function ExclamaSN(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de exclamaci�n, regresa rSi o rNo}
var
  i: Integer;
begin
  Texto := Texto + '!';
  {$WARNINGS OFF}
  i :=  Application.MessageBox(PChar(Texto), PChar(Titulo)
                                , MB_YESNO + MB_ICONEXCLAMATION);
  {$WARNINGS ON}
  if i=IDYes then
    Result := rSi
  else
    Result := rNo;
end;

function ExclamaSNC(Texto, Titulo: string): TRespuesta;
{Muestra cuadro de di�logo con el icono de exclamaci�n, regresa rSi, rNo
o rCancelar}
var
  i: Integer;
begin
  Texto := Texto + '!';
  {$WARNINGS OFF}
  i := Application.MessageBox(PChar(Texto), PChar(Titulo),
                                MB_YESNOCANCEL + MB_ICONEXCLAMATION);
  {$WARNINGS ON}
  Result := rSi;
  case i of
    IDYES   : Result := rSi;
    IDNO    : Result := rNo;
    IDCANCEL: Result := rCancelar;
  end;
end;

procedure Informa(Texto, Titulo: string);
{Muestra cuadro de di�logo con el icono de informaci�n}
begin
  {$WARNINGS OFF}
  Application.MessageBox(PChar(Texto), PChar(Titulo)
                          , MB_OK + MB_ICONINFORMATION);
  {$WARNINGS ON}
end;

procedure Fallo(Texto, Titulo: string);
{Muestra cuadro de di�logo con el icono de error}
begin
  {$WARNINGS OFF}
  Application.MessageBox(PChar(Texto), PChar(Titulo), MB_OK + MB_ICONERROR);
  {$WARNINGS ON}
end;

procedure Exclama(Texto, Titulo: string);
{Muestra cuadro de di�logo con el icono de exclamaci�n}
begin
  {$WARNINGS OFF}
  Texto := Texto + '!';
  Application.MessageBox(PChar(Texto), PChar(Titulo), MB_OK
                                      + MB_ICONEXCLAMATION);
  {$WARNINGS ON}
end;

end.

