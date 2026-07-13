unit EditorNotas;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Comunes, LResources;

type

  TNotas = class(TGuardable);

  TfrmEditorNotas = class(TForm)
    memNotas: TMemo;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure btbCancelarClick(Sender: TObject);
  private
    { Private declarations }
    Notas: TNotas;
    Asignacion,
    Fisiologia,
    Genetica,
    Interaccion,
    Memoria,
    Morfologia,
    Lineas: TStringList;
    Estadios,
    PrototiposM,
    PrototiposH: array of TStringList;
    function EliminaApersAnd(s: string): string;
  public
    { Public declarations }
    Indice: string;
    NombreArchivo: TFileName;
    procedure ImportaTexto;
    procedure ExportaTexto;
    procedure CreaApartados(Apartados: TStringList);
    destructor Destroy; override;
  end;

var
  frmEditorNotas: TfrmEditorNotas;

implementation

uses
  EditorAgentes;


{ TfrmEditorNotas }

procedure TfrmEditorNotas.ExportaTexto;
var
  i: Integer;
begin
  Lineas.Text := memNotas.Text;
  if Indice = 'Asignacion' then
    Asignacion.Text := Lineas.Text
  else if Indice = 'Fisiologia' then
    Fisiologia.Text := Lineas.Text
  else if Indice = 'Genetica' then
    Genetica.Text := Lineas.Text
  else if Indice = 'Interaccion' then
    Interaccion.Text := Lineas.Text
  else if Indice = 'Memoria' then
    Memoria.Text := Lineas.Text
  else if Indice = 'Morfologia' then
    Morfologia.Text := Lineas.Text
  else
  begin
    with frmEditorAgentes.JuegoAgentes do
    begin
      for i := 1 to NumEstadios do
        if Indice = 'Estadio' + IntToStr(i) then
          Self.Estadios[i-1].Text := Lineas.Text;
      for i := 1 to NumPrototiposM do
        if Indice = 'PrototipoM' + IntToStr(i) then
          Self.PrototiposM[i-1].Text := Lineas.Text;
      for i := 1 to NumPrototiposH do
        if Indice = 'PrototipoH' + IntToStr(i) then
        Self.PrototiposH[i-1].Text := Lineas.Text;
    end;
  end;
  Notas.Reestablece;
  with Notas do
  begin
    EscribeValor('Asignacion', Asignacion);
    EscribeValor('Fisiologia', Fisiologia);
    EscribeValor('Genetica', Genetica);
    EscribeValor('Interaccion', Interaccion);
    EscribeValor('Memoria', Memoria);
    EscribeValor('Morfologia', Morfologia);
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumEstadios do
      EscribeValor('Estadio' + IntToStr(i), Estadios[i-1]);
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposM do
      EscribeValor('PrototipoM' + IntToStr(i), PrototiposM[i-1]);
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposH do
      EscribeValor('PrototipoH' + IntToStr(i), PrototiposH[i-1]);
  end;  //with
  Notas.Guarda(NombreArchivo);
end;

procedure TfrmEditorNotas.FormCreate(Sender: TObject);
begin
  memNotas.Clear;
  Notas := TNotas.Create;
end;

procedure TfrmEditorNotas.ImportaTexto;
var
  Archivo: TextFile;
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    SetLength(Self.Estadios, NumEstadios);
    SetLength(Self.PrototiposM, NumPrototiposM);
    SetLength(Self.PrototiposH, NumPrototiposH);
  end;
  NombreArchivo := ChangeFileExt(NombreArchivo, '.not');
  if not (FileExists(NombreArchivo)) then
  begin
    AssignFile(Archivo, NombreArchivo);
    Rewrite(Archivo);
    CloseFile(Archivo);
  end;
  with Notas do
  begin
    Carga(NombreArchivo);
    Asignacion := LeeValorAmpliado('Asignacion');
    Fisiologia := LeeValorAmpliado('Fisiologia');
    Genetica := LeeValorAmpliado('Genetica');
    Interaccion := LeeValorAmpliado('Interaccion');
    Memoria := LeeValorAmpliado('Memoria');
    Morfologia := LeeValorAmpliado('Morfologia');
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumEstadios do
      Estadios[i-1] := LeeValorAmpliado('Estadio' + IntToStr(i));
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposM do
      PrototiposM[i-1] := LeeValorAmpliado('PrototipoM' + IntToStr(i));
    for i := 1 to frmEditorAgentes.JuegoAgentes.NumPrototiposH do
      PrototiposH[i-1] := LeeValorAmpliado('PrototipoH' + IntToStr(i));
    Lineas := LeeValorAmpliado(Indice);
    memNotas.Lines := Lineas;
  end;  //with
end;

procedure TfrmEditorNotas.btbAceptarClick(Sender: TObject);
begin
  ExportaTexto;
  Self.Close;
end;

procedure TfrmEditorNotas.CreaApartados(Apartados: TStringList);
var
  i   : Integer;
begin
  if memNotas.Text = '' then
    for i := 0 to Apartados.Count - 1 do
    begin
      memNotas.Lines.Add(EliminaApersAnd(Apartados.Strings[i]));
      memNotas.Lines.Add('');
      memNotas.Lines.Add('');
    end;
  memNotas.SelStart := 0;
  memNotas.SelLength := 0;
end;

function TfrmEditorNotas.EliminaApersAnd(s: string): string;
{Regresa la cadena s después de haberle extraído todos los caracteres '&'}
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if s[i] <> '&' then
      Result := Result + s[i];
end;

procedure TfrmEditorNotas.btbCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

destructor TfrmEditorNotas.Destroy;
begin
  Notas.Free;
  inherited Destroy;
end;

initialization
  {$i EditorNotas.lrs}
  {$i EditorNotas.lrs}

end.
