unit ReportesAgenteCiclo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmReportesAgenteCiclo = class(TForm)
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    procedure btbAceptarClick(Sender: TObject);
  private
    { Private declarations }
    Salida: TextFile;
    procedure Provisional;
  public
    { Public declarations }
    Directorio: string;
  end;

var
  frmReportesAgenteCiclo: TfrmReportesAgenteCiclo;

implementation

uses
  AnalizadorSalidas, Multilenguaje, Comunes;

{$R *.dfm}

procedure TfrmReportesAgenteCiclo.btbAceptarClick(Sender: TObject);
begin
  Provisional;
end;

function Encabezado: string;
begin
  Result := 'Ciclo, Nombre, Padre, Madre, Sexo, '
        + 'PCC1, PCV1, MCC1, MCV1, PCC2, PCV2, MCC2, MCV2, '
        + 'PCC3, PCV3, MCC3, MCV3, PCC4, PCV4, MCC4, MCV4, '
        + 'PCC5, PCV5, MCC5, MCV5, PCC6, PCV6, MCC6, MCV6, '
        + 'PCC7, PCV7, MCC7, MCV7, PCC8, PCV8, MCC8, MCV8, '
        + 'PCC9, PCV9, MCC9, MCV9, '
        + 'PCC10, PCV10, MCC10, MCV10, PCC11, PCV11, MCC11, MCV11, '
        + 'PCC12, PCV12, MCC12, MCV12, PCC13, PCV13, MCC13, MCV13, '
        + 'PCC14, PCV14, MCC14, MCV14, PCC15, PCV15, MCC15, MCV15, '
        + 'PDC1, PDV1, MDC1, MDV1, PDC2, PDV2, MDC2, MDV2, '
        + 'PDC3, PDV3, MDC3, MDV3, PDC4, PDV4, MDC4, MDV4, '
        + 'PDC5, PDV5, MDC5, MDV5, PDC6, PDV6, MDC6, MDV6, '
        + 'PDC7, PDV7, MDC7, MDV7, PDC8, PDV8, MDC8, MDV8, '
        + 'PDC9, PDV9, MDC9, MDV9, '
        + 'PDC10, PDV10, MDC10, MDV10, PDC11, PDV11, MDC11, MDV11, '
        + 'PDC12, PDV12, MDC12, MDV12, PDC13, PDV13, MDC13, MDV13, '
        + 'PDC14, PDV14, MDC14, MDV14, PDC15, PDV15, MDC15, MDV15, ';
  Result := Result + 'Longitud_del_cuerpo, Grueso_del_abdomen, '
        + 'Longitud_de_pedipalpos, Longitud_de_patasII, '
        + 'C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, '
        + 'Patas_locomotoras, Patas_sensoriales, D3, D4, D5, D6, D7, D8, D9, '
        + 'D10, D11, D12, D13, D14, D15, ';
  Result := Result + 'X, Y, Estadio, Prototipo, Tiempo Estadio, '
        + 'Tiempo Sustrato, Tiempo Interaccion, Edad, Dirección, '
        + 'Reservas Agua, Reservas Carbohidratos, Reservas Lípidos, '
        + 'Reservas Proteínas, Huevos/Paquetes, Huevos/Paquetes, '
        + 'Huevos Fertilizados, Huevos Acarreados, Paquetes Almacenados, '
        + 'MemUlt Mover, MemNum Mover, MemUlt Reposo, MemNum Resposo, '
        + 'MemUlt Beber, MemNum Beber, MemUlt ComCarbohidratos, MemNum ComCarbohidratos, '
        + 'MemUlt ComLipidos, MemNum Com Lipidos, MemUlt ComProteinas, MemNum ComProteinas, '
        + 'MemUlt Desplegar, MemNum Desplegar, MemUlt Escalar, MemNum Escalar, '
        + 'MemUlt Retirarse, MemNum Retirarse, MemUlt Intento Desp., MemNum Intento Desp., '
        + 'MemUlt Intento Esc., MemNum Intento Esc., MemUlt Aceptar, MemNum Aceptar, '
        + 'MemUlt Rechazar, MemNum Rechazar, MemUlt Ovipositar, MemNum Ovipositar, '
        + 'MemUlt Ganar pelea, MemNum Ganar pelea, MemUlt Copular, MemNum Copular, '
        ;
end;

procedure TfrmReportesAgenteCiclo.Provisional;
var
  s: string;
  Lineas,
  ListaAgentes: TStringList;
  Ciclos,
  i: Integer;
  InfoCiclo: TGuardable;
begin
  with frmAnalizadorSalidas do
  begin
    AssignFile(Salida, Directorio + NombreBase + 'Salida.csv');
    Rewrite(Salida);
    WriteLn(Salida, Encabezado);
    InfoCiclos.Carga(Directorio + NombreBase + '.cls');
    InfoAgentes.Carga(Directorio + NombreBase + '.agn');
    InfoMorfo.Carga(Directorio + NombreBase + '.mrf');
    Ciclos := 0;
    repeat
      Ciclos := Ciclos + 1000;
      Lineas := InfoCiclos.LeeValorAmpliado(IntToStr(Ciclos));
      Lineas.Delete(0);
      if Lineas.Count = 0 then
        Break; //->
      Lineas.SaveToFile(Directorio + NombreBase + '.tmp');
      InfoCiclo := TGuardable.Create;
      InfoCiclo.Reestablece;
      InfoCiclo.Carga(Directorio + NombreBase + '.tmp');
      ListaAgentes := InfoCiclo.ListadoIndicesSimples;
      for i := 0 to ListaAgentes.Count - 1 do
      begin
        s := IntToStr(Ciclos) + ', ';
        s := s + ListaAgentes.Strings[i] + ', '
           + InfoAgentes.LeeValor(ListaAgentes.Strings[i]);
        s := s + InfoMorfo.LeeValor(ListaAgentes.Strings[i]);
        s := s + InfoCiclo.LeeValor(ListaAgentes.Strings[i]);
        WriteLn(Salida, s);
      end;
      InfoCiclo.Free;
    until Lineas.Count = 0;
  end;
  CloseFile(Salida);
end;  //Provisional

end.
