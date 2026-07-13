unit ExportarAgentes;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons{, OleServer, ExcelXP}, LResources;

type
  TfrmExportar = class(TForm)
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    GroupBox1: TGroupBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    grbPlantilla: TGroupBox;
    edtPlantilla: TEdit;
    //exaJuegoAgentes: TExcelApplication;
    chbPlantilla: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure chbPlantillaClick(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    {$WARNINGS OFF}
    //Rango: ExcelRange;
    {$WARNINGS ON}
    procedure Exporta;
    procedure ExportaGenerales;
    procedure ExportaGenetica;
    procedure ExportaMorfologia;
    procedure ExportaFisiologia;
    procedure ExportaEstadios;
    procedure ExportaPrototipos;
    procedure ExportaCriterios;
    procedure ExportaMatrices;
    {$WARNINGS OFF}
    procedure CabecerasGenetica;//(Rango: ExcelRange);
    {$WARNINGS ON}
    procedure ListaNutrimentos(Col: string; Ren: Integer);
    procedure CabecerasNutrimentos(CeldaInicio: string);
    procedure ListaAgentes(Col: string; Ren: Integer);
    procedure CabecerasAgentes(CeldaInicio: string);
    procedure CabecerasSustratos(CeldaInicio: string);
    procedure CabecerasDinamicos(CeldaInicio: string);
    procedure Celda(Loc, Valor: string); overload;
    procedure Celda(Loc: string; Valor: Integer); overload;
    procedure Celda(Loc: string; Valor: Real); overload;
  public
    { Public declarations }
  end;

var
  frmExportar: TfrmExportar;

implementation

uses
  EditorAgentes, Multilenguaje, Dialogos, Comunes;


procedure TfrmExportar.FormCreate(Sender: TObject);
begin
  with frmEditorAgentes.ArchivoInicio do
  begin
    if ReadBool('GeneralesEditorAgentes', 'APlantilla', False) then
    begin
      chbPlantilla.Checked := True;
      grbPlantilla.Enabled := True;
      edtPlantilla.Text :=
                          ReadString('GeneralesEditorAgentes', 'Plantilla', '');
    end
    else
      chbPlantilla.Checked := False;
      edtPlantilla.Text := '';
      grbPlantilla.Enabled := False;
  end;
  PuedeCerrar := True;
end;

procedure TfrmExportar.chbPlantillaClick(Sender: TObject);
begin
  if chbPlantilla.Checked then
    grbPlantilla.Enabled := True
  else
    grbPlantilla.Enabled := False;
end;

procedure TfrmExportar.btbAceptarClick(Sender: TObject);
begin
  with frmEditorAgentes.ArchivoInicio do
  begin
    WriteBool('GeneralesEditorAgentes', 'APlantilla', chbPlantilla.Checked);
    WriteString('GeneralesEditorAgentes', 'Plantilla', edtPlantilla.Text);
  end;
  Exporta;
end;

procedure TfrmExportar.Exporta;
begin
  if chbPlantilla.Checked then
  begin
    if edtPlantilla.Text = '' then
    begin
      Fallo(ML(mlErrFltPlnt), ML(mlEdAgntGlt)); //Falta nombre de plantilla
      PuedeCerrar := False;
      edtPlantilla.SetFocus;
      Exit; //-->
    end;
    //exaJuegoAgentes.Workbooks.Add(edtPlantilla.Text, 0);
  end
  else
    //exaJuegoAgentes.Workbooks.Add(NULL, 0);
  //exaJuegoAgentes.Visible[0] := True;
  ExportaGenerales;
  ExportaGenetica;
  ExportaMorfologia;
  ExportaFisiologia;
  ExportaEstadios;
  ExportaPrototipos;
  ExportaCriterios;
  ExportaMatrices;
end;

procedure TfrmExportar.ExportaGenerales;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    {Celda('A1', Titulo);
    Celda('A2', Comentarios);
    Celda('A4', ML(mlEstadios));
    for i := 1 to NumEstadios do
    begin
      Rango := Rango.Next;
      if Estadios[i].Prototipo = 0 then
        Rango.Value2 := Estadios[i].Nombre
      else
        if Estadios[i].Prototipo <= NumPrototiposM then
          Rango.Value2 := Estadios[i].Nombre + '['
                              + PrototiposM[Estadios[i].Prototipo].Nombre + ']'
        else
          Rango.Value2 := Estadios[i].Nombre + '['
            + PrototiposH[Estadios[i].Prototipo - NumPrototiposM].Nombre + ']';
    end; //for
    Rango := exaJuegoAgentes.Range['A5', 'A5'];
    Rango.Value2 := ML(mlPrttMachos);
    for i := 1 to NumPrototiposM do
    begin
      Rango := Rango.Next;
      Rango.Value2 := PrototiposM[i].Nombre;
    end;
    Rango := exaJuegoAgentes.Range['A6', 'A6'];
    Rango.Value2 := ML(mlPrttHembras);
    for i := 1 to NumPrototiposH do
    begin
      Rango := Rango.Next;
      Rango.Value2 := PrototiposH[i].Nombre;
    end;
    Rango := exaJuegoAgentes.Range['A7', 'A7'];
    Rango.Value2 := ML(mlSustratos);
    for i := 1 to 7 do
    begin
      Rango := Rango.Next;
      Rango.Value2 := Sustratos[i];
    end;  }
  end; //with
end;

procedure TfrmExportar.ExportaGenetica;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    {Celda('A9', ML(mlLociCont));
    Celda('A10', '');
    CabecerasGenetica(Rango);
    for i := 1 to 4 do
    begin
      Celda('A' + IntToStr(i+10), 'CL' + IntToStr(i));
      Celda('B' + IntToStr(i+10), LociContinuos[i].Dominante);
      Celda('C' + IntToStr(i+10), LociContinuos[i].Recesivo);
      Celda('D' + IntToStr(i+10), LociContinuos[i].MutacionD);
      Celda('E' + IntToStr(i+10), LociContinuos[i].MutacionR);
      Celda('F' + IntToStr(i+10), LociContinuos[i].RangoMutacionD);
      Celda('G' + IntToStr(i+10), LociContinuos[i].RangoMutacionR);
    end;
    Celda('A16', ML(mlLociDisc));
    Celda('A17', '');
    CabecerasGenetica(Rango);
    for i := 1 to 15 do
    begin
      Celda('A' + IntToStr(i+17), 'DL' + IntToStr(i));
      Celda('B' + IntToStr(i+17), LociDiscretos[i].Dominante);
      Celda('C' + IntToStr(i+17), LociDiscretos[i].Recesivo);
      Celda('D' + IntToStr(i+17), LociDiscretos[i].MutacionD);
      Celda('E' + IntToStr(i+17), LociDiscretos[i].MutacionR);
      Celda('F' + IntToStr(i+17), LociDiscretos[i].RangoMutacionD);
      Celda('G' + IntToStr(i+17), LociDiscretos[i].RangoMutacionR);
    end;   }
  end; //with
end;


{$WARNINGS OFF}
procedure TfrmExportar.CabecerasGenetica;//(Rango: ExcelRange);
{$WARNINGS ON}
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    {Rango.Value2 := 'Loci';
    Rango := Rango.Next;
    Rango.Value2 := ML(mlDominante);
    Rango := Rango.Next;
    Rango.Value2 := ML(mlRecesivo);
    Rango := Rango.Next;
    Rango.Value2 := ML(mlTasaMutacion) + ' ' +  ML(mlDominante);
    Rango := Rango.Next;
    Rango.Value2 := ML(mlTasaMutacion) + ' ' +  ML(mlRecesivo);
    Rango := Rango.Next;
    Rango.Value2 := ML(mlRangoMut) + ' ' +  ML(mlDominante);
    Rango := Rango.Next;
    Rango.Value2 := ML(mlRangoMut) + ' ' +  ML(mlRecesivo); }
  end;
end;

procedure TfrmExportar.ExportaMorfologia;
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    {Rango := exaJuegoAgentes.Range['A36', 'A36'];
    Rango.Value2 := ML(mlCarCont);
    for i := 1 to 4 do
    begin
      Rango := Rango.Next;
      Rango.Value2 := Continuos[i].Nombre;
    end;
    Rango := exaJuegoAgentes.Range['A37', 'A37'];
    Rango.Value2 := ML(mlCarDisc);
    for i := 1 to 15 do
    begin
      Rango := Rango.Next;
      Rango.Value2 := Discretos[i].Nombre;
    end; }
  end;  //with
end;

procedure TfrmExportar.ExportaFisiologia;
var
  i, j: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    Celda('A39', ML(mlNutrimentos) + '\' + ML(mlValores));
    Celda('B39', ML(mlMinimo));
    Celda('C39', ML(mlCritico));
    Celda('D39', ML(mlOptimo));
    Celda('E39', ML(mlInicial));
    Celda('F39', ML(mlMaximo));
    ListaNutrimentos('A', 40);
    for i := 1 to 5 do
      for j := 1 to 4 do
        Celda(Chr(65+i) + IntToStr(j+39), Metabolismo[i, j]);
    Celda('A45', ML(mlMaxHuevos));
    Celda('B45', MaxHuevos);
    Celda('C45', ML(mlMaxEsperma));
    Celda('D45', MaxPaquetes);
    Celda('A46', ML(mlCostoUnidad));
    Celda('C46', ML(mlCostoUnidad));
    ListaNutrimentos('A', 47);
    ListaNutrimentos('C', 47);
    for i := 1 to 4 do
      Celda('B' + IntToStr(i+46), CostoHuevo[i]);
    for i := 1 to 4 do
      Celda('D' + IntToStr(i+46), CostoPaquete[i]);
    Celda('A52', ML(mlConducta) + '\' + ML(mlCostos));
    CabecerasNutrimentos('B52');
    Celda('A53', ML(mlMovimiento));
    Celda('A54', ML(mlEnReposo));
    Celda('A55', ML(mlBeber));
    Celda('A56', ML(mlCmrGrasa));
    Celda('A57', ML(mlCmrAzucar));
    Celda('A58', ML(mlCmrProteina));
    Celda('A59', ML(mlDesplegar));
    Celda('A60', ML(mlEscalar));
    Celda('A61', ML(mlRetirar));
    Celda('A62', ML(mlIA));
    Celda('A63', ML(mlIB));
    Celda('A64', ML(mlCopular));
    Celda('A65', ML(mlRechazar));
    Celda('A66', ML(mlOvipositar));
    for i := 1 to 4 do
    begin
      Celda(Char(i+65) + '53', Movimiento.Costos[i,1]);
      Celda(Char(i+65) + '54', Movimiento.Costos[i,2]);
      Celda(Char(i+65) + '55', Alimentacion.Costos[i,1]);
      Celda(Char(i+65) + '56', Alimentacion.Costos[i,2]);
      Celda(Char(i+65) + '57', Alimentacion.Costos[i,3]);
      Celda(Char(i+65) + '58', Alimentacion.Costos[i,4]);
      Celda(Char(i+65) + '59', CostosCombate[i,1]);
      Celda(Char(i+65) + '60', CostosCombate[i,2]);
      Celda(Char(i+65) + '61', CostosCombate[i,3]);
      Celda(Char(i+65) + '62', CostosCortejo[i,1]);
      Celda(Char(i+65) + '63', CostosCortejo[i,2]);
      Celda(Char(i+65) + '64', CostosCortejo[i,3]);
      Celda(Char(i+65) + '65', CostosCortejo[i,4]);
      Celda(Char(i+65) + '66', CostosCortejo[i,5]);
    end;  //for
    Celda('A68', ML(mlVelocidad));
    for i := 1 to 7 do
    begin
      Celda('A' + IntToStr(i + 68), Sustratos[i]);
      Celda('B' + IntToStr(i + 68), Movimiento.Velocidad[i]);
    end;
    Celda('A77', ML(mlNtrmntUndds));  //Unidades de nutrimentos tomadas
    ListaNutrimentos('A', 78);
    for i := 1 to 4 do
      Celda('B' + IntToStr(i+77), Alimentacion.Ganancias[i]);
    Celda('A83', ML(mlNmrPETC));
    Celda('A84', ML(mlMaxPEAH));
    Celda('A85', ML(mlTasaConsmPE));
    Celda('A86', ML(mlFrccHFC));
    Celda('A87', ML(mlPrbbPtrnd));
    Celda('A88', ML(mlHvsOvpstd));
    Celda('A89', ML(mlPrddPE));
    Celda('A90', ML(mlPrddHv));
    Celda('B83', PaquetesTransferidos);
    Celda('B84', MaxPaquetesH);
    Celda('B85', TasaConsumo);
    Celda('B86', FraccionHuevo);
    Celda('B87', Paternidad);
    Celda('B88', HuevosCiclo);
    Celda('B89', FraccionPaquete);
    Celda('B90', FraccionHuevo);
  end;  //with
end;

procedure TfrmExportar.Celda(Loc, Valor: string);
begin
  //Rango := exaJuegoAgentes.Range[Loc, Loc];
  //Rango.Value2 := Valor;
end;

procedure TfrmExportar.Celda(Loc: string; Valor: Integer);
begin
  //Rango := exaJuegoAgentes.Range[Loc, Loc];
  //Rango.Value2 := Valor;
end;

procedure TfrmExportar.Celda(Loc: string; Valor: Real);
begin
  //Rango := exaJuegoAgentes.Range[Loc, Loc];
  //Rango.Value2 := Valor;
end;

procedure TfrmExportar.ListaNutrimentos(Col: string; Ren: Integer);
begin
  {Celda(Col + IntToStr(Ren), ML(mlAgua));
  Celda(Col + IntToStr(Ren+1), ML(mlGrasa));
  Celda(Col + IntToStr(Ren+2), ML(mlAzucar));
  Celda(Col + IntToStr(Ren+3), ML(mlProteina));   }
end;

procedure TfrmExportar.CabecerasNutrimentos(CeldaInicio: string);
begin
  {Celda(CeldaInicio, ML(mlAgua));
  Rango := Rango.Next;
  Rango.Value2 := ML(mlGrasa);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlAzucar);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlProteina);   }
end;

procedure TfrmExportar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmExportar.ExportaEstadios;
var
  i, j: Integer;
begin
  {with frmEditorAgentes.JuegoAgentes do
  begin
    Celda('A92', ML(mlEstadios));
    Celda('B92', ML(mlCambrEst));
    Celda('C92', ML(mlYOReqrmnts));
    Celda('D92', ML(mlColor));
    for i := 1 to NumEstadios do
    begin
      if Estadios[i].Prototipo = 0 then
        Celda('A' + IntToStr(i+92), Estadios[i].Nombre)
      else
        Celda('A' + IntToStr(i+92), Estadios[i].Nombre + '[' + Ligado(i) + ']');
      Celda('A' + IntToStr(i+92), Estadios[i].Nombre);
      Celda('B' + IntToStr(i+92), Estadios[i].Ciclos);
      if Estadios[i].Y_O then
        Celda('C' + IntToStr(i+92), ML(mlY))
      else
        Celda('C' + IntToStr(i+92), ML(mlO));
      Celda('D' + IntToStr(i+92), ML(mlColor));
      Rango.Font.Color := Estadios[i].Color;
    end;
    for j := 1 to NumEstadios do
    begin
      Celda('A' + IntToStr(((j-1)*5)+98), Estadios[j].Nombre);
      Celda('A' + IntToStr(((j-1)*5)+99),
                            ML(mlValor) + '\' + ML(mlNutrimentos));
      CabecerasNutrimentos('B' + IntToStr(((j-1)*5)+99));
      Celda('A' + IntToStr(((j-1)*5)+100), ML(mlRqrmnts));
      Celda('A' + IntToStr(((j-1)*5)+101), ML(mlCostos));
      for i := 1 to 4 do
      begin
        Celda(Chr(65+i) + IntToStr(((j-1)*5)+100), Estadios[j].Requiere[i]);
        Celda(Chr(65+i) + IntToStr(((j-1)*5)+101), Estadios[j].Costos[i]);
      end;
    end;
  end;  //with  }
end;

procedure TfrmExportar.ExportaPrototipos;
var
  i, j, k,
  RenIni: Integer;
begin
  {with frmEditorAgentes.JuegoAgentes do
  begin
    RenIni := 92+NumEstadios+(NumEstadios*5)+2;
                        //Renglon apartir del cual varía secuencia según número
                        //de estadios, prototipos machos y hembras = 92
    Celda('A' + IntToStr(RenIni), ML(mlPrttMachos));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipos)+'\'+ML(mlCrctrstcs));
    for i := 1 to 4 do
      Celda(Chr(65+i) + IntToStr(RenIni+1), Continuos[i].Nombre);
    for i := 1 to 15 do
      Celda(Chr(69+i) + IntToStr(RenIni+1), Discretos[i].Nombre);
    Celda('U' + IntToStr(RenIni+1), ML(mlLongevidad));
    Celda('V' + IntToStr(RenIni+1), ML(mlRfrctr)+' '+ML(mlCombate));
    Celda('W' + IntToStr(RenIni+1), ML(mlRfrctr)+' '+ML(mlCortejo));
    Celda('X' + IntToStr(RenIni+1), ML(mlColor));
    for i := 1 to NumPrototiposM do
    begin
      Celda('A' + IntToStr(RenIni+i+1), PrototiposM[i].Nombre);
      for j := 1 to 4 do
        Celda(Chr(65+j) + IntToStr(RenIni+i+1), PrototiposM[i].Continuos[j].ValorGenetico);
      for j := 1 to 15 do
        Celda(Chr(69+j) + IntToStr(RenIni+i+1), PrototiposM[i].Discretos[j].ValorGenetico);
      Celda('U' + IntToStr(RenIni+i+1), PrototiposM[i].Longevidad);
      Celda('V' + IntToStr(RenIni+i+1), PrototiposM[i].RefractarioCombate);
      Celda('W' + IntToStr(RenIni+i+1), PrototiposM[i].RefractarioCortejo);
      Celda('X' + IntToStr(RenIni+i+1), ML(mlColor));
      Rango.Font.Color := PrototiposM[i].Color;
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+(NumPrototiposM)+5;
    Celda('A' + IntToStr(RenIni), ML(mlPrttHembras));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipos)+'\'+ML(mlCrctrstcs));
    for i := 1 to 4 do
      Celda(Chr(65+i) + IntToStr(RenIni+1), Continuos[i].Nombre);
    for i := 1 to 15 do
      Celda(Chr(69+i) + IntToStr(RenIni+1), Discretos[i].Nombre);
    Celda('U' + IntToStr(RenIni+1), ML(mlLongevidad));
    Celda('V' + IntToStr(RenIni+1), ML(mlRfrctr)+' '+ML(mlCombate));
    Celda('W' + IntToStr(RenIni+1), ML(mlRfrctr)+' '+ML(mlCortejo));
    Celda('X' + IntToStr(RenIni+1), ML(mlColor));
    Celda('Y' + IntToStr(RenIni+1), ML(mlAsgncnSx));
    for i := 1 to NumPrototiposH do
    begin
      Celda('A' + IntToStr(RenIni+i+1), PrototiposH[i].Nombre);
      for j := 1 to 4 do
        Celda(Chr(65+j) + IntToStr(RenIni+i+1), PrototiposH[i].Continuos[j].ValorGenetico);
      for j := 1 to 15 do
        Celda(Chr(69+j) + IntToStr(RenIni+i+1), PrototiposH[i].Discretos[j].ValorGenetico);
      Celda('U' + IntToStr(RenIni+i+1), PrototiposH[i].Longevidad);
      Celda('V' + IntToStr(RenIni+i+1), PrototiposH[i].RefractarioCombate);
      Celda('W' + IntToStr(RenIni+i+1), PrototiposH[i].RefractarioCortejo);
      Celda('X' + IntToStr(RenIni+i+1), ML(mlColor));
      Rango.Font.Color := PrototiposH[i].Color;
      Celda('Y' + IntToStr(RenIni+i+1), PrototiposH[i].ProporcionMachos + ':'
                              + PrototiposH[i].ProporcionHembras);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM+NumPrototiposH+8;
    Celda('A' + IntToStr(RenIni), ML(mlEstrtgCombt));
    for i := 1 to NumPrototiposM do
    begin
      Celda('A' + IntToStr(RenIni+(6*(i-1))+2), PrototiposM[i].Nombre);
      Celda('A' + IntToStr(RenIni+(6*(i-1))+3),
                                   ML(mlContendiente) + '\' + ML(mlPrototipo));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+4), ML(mlDesplegar));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+5), ML(mlEscalar));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+6), ML(mlRetirar));
      Celda('B' + IntToStr(RenIni+(6*(i-1))+3), ML(mlDesplegar));
      Celda('C' + IntToStr(RenIni+(6*(i-1))+3), ML(mlEscalar));
      Celda('D' + IntToStr(RenIni+(6*(i-1))+3), ML(mlRetirar));
      for j := 1 to 3 do
        for k := 1 to 3 do
          Celda(Chr(65+j)+IntToStr(RenIni+(6*(i-1))+3+k),
                                            PrototiposM[i].Combate[j,k]);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+9;
    for i := 1 to NumPrototiposH do
    begin
      Celda('A' + IntToStr(RenIni+(6*(i-1))+1), PrototiposH[i].Nombre);
      Celda('A' + IntToStr(RenIni+(6*(i-1))+2),
                                    ML(mlContendiente) + '/' + ML(mlPrototipo));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+3), ML(mlDesplegar));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+4), ML(mlEscalar));
      Celda('A' + IntToStr(RenIni+(6*(i-1))+5), ML(mlRetirar));
      Celda('B' + IntToStr(RenIni+(6*(i-1))+2), ML(mlDesplegar));
      Celda('C' + IntToStr(RenIni+(6*(i-1))+2), ML(mlEscalar));
      Celda('D' + IntToStr(RenIni+(6*(i-1))+2), ML(mlRetirar));
      for j := 1 to 3 do
        for k := 1 to 3 do
          Celda(Chr(65+j)+IntToStr(RenIni+(6*(i-1))+2+k),
                                            PrototiposH[i].Combate[j,k]);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)+11;
    Celda('A' + IntToStr(RenIni), ML(mlEstrtgCortj));
    for i := 1 to NumPrototiposM do
    begin
      Celda('A' + IntToStr(RenIni+(7*(i-1))+2), PrototiposM[i].Nombre);
      Celda('A' + IntToStr(RenIni+(7*(i-1))+3),
                                    ML(mlContendiente) + '/' + ML(mlPrototipo));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+4), ML(mlIA));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+5), ML(mlIB));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+6), ML(mlCopular));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+7), ML(mlRechazar));
      Celda('B' + IntToStr(RenIni+(7*(i-1))+3), ML(mlIA));
      Celda('C' + IntToStr(RenIni+(7*(i-1))+3), ML(mlIB));
      Celda('D' + IntToStr(RenIni+(7*(i-1))+3), ML(mlCopular));
      Celda('E' + IntToStr(RenIni+(7*(i-1))+3), ML(mlRechazar));
      for j := 1 to 4 do
        for k := 1 to 4 do
          Celda(Chr(65+j)+IntToStr(RenIni+(7*(i-1))+3+k),
                                            PrototiposM[i].Cortejo[j,k]);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+12;
    for i := 1 to NumPrototiposH do
    begin
      Celda('A' + IntToStr(RenIni+(7*(i-1))+1), PrototiposH[i].Nombre);
      Celda('A' + IntToStr(RenIni+(7*(i-1))+2),
                                    ML(mlContendiente) + '/' + ML(mlPrototipo));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+3), ML(mlIA));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+4), ML(mlIB));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+5), ML(mlCopular));
      Celda('A' + IntToStr(RenIni+(7*(i-1))+6), ML(mlRechazar));
      Celda('B' + IntToStr(RenIni+(7*(i-1))+2), ML(mlIA));
      Celda('C' + IntToStr(RenIni+(7*(i-1))+2), ML(mlIB));
      Celda('D' + IntToStr(RenIni+(7*(i-1))+2), ML(mlCopular));
      Celda('E' + IntToStr(RenIni+(7*(i-1))+2), ML(mlRechazar));
      for j := 1 to 4 do
        for k := 1 to 4 do
          Celda(Chr(65+j)+IntToStr(RenIni+(7*(i-1))+2+k),
                                            PrototiposH[i].Cortejo[j,k]);
    end;
  end;  //with }
end;

procedure TfrmExportar.ExportaCriterios;
var
  i, j, k,
  RenIni: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)+14;
    Celda('A' + IntToStr(RenIni), ML(mlCrtrsAsgnc) + ' ' + ML(mlMachos));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipos) + '\' + ML(mlValores));
    Celda('B' + IntToStr(RenIni+1), ML(mlFormula));
    Celda('C' + IntToStr(RenIni+1), ML(mlOperador));
    Celda('D' + IntToStr(RenIni+1), ML(mlValor));
    for j := 1 to NumPrototiposM do
    begin
      Celda('A' + IntToStr(RenIni+j+1), PrototiposM[j].Nombre);
      for i := 0 to 2 do
        Celda(Chr(66+i) + IntToStr(RenIni+j+1), CriteriosM[i,j-1]);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +(NumPrototiposM)+17;
    Celda('A' + IntToStr(RenIni), ML(mlCrtrsAsgnc) + ' ' + ML(mlHembras));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipos) + '\' + ML(mlValores));
    Celda('B' + IntToStr(RenIni+1), ML(mlFormula));
    Celda('C' + IntToStr(RenIni+1), ML(mlOperador));
    Celda('D' + IntToStr(RenIni+1), ML(mlValor));
    for j := 1 to NumPrototiposH do
    begin
      Celda('A' + IntToStr(RenIni+j+1), PrototiposH[j].Nombre);
      for i := 0 to 2 do
        Celda(Chr(66+i) + IntToStr(RenIni+j+1), CriteriosH[i,j-1]);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +(NumPrototiposM)+(NumPrototiposH)+20;
    Celda('A' + IntToStr(RenIni), ML(mlAsgncnJrrq) + ' ' + ML(mlMachos));
    for i := 1 to NumPrototiposM do
    begin
      k := StrToInt(ObtenNsimo(JerarquiaM,i));
      Celda('A' + IntToStr(RenIni+i), PrototiposM[k].Nombre);
    end;
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +(NumPrototiposM)+(NumPrototiposH)
              +(NumPrototiposM)+22;
    Celda('A' + IntToStr(RenIni), ML(mlAsgncnJrrq) + ' ' + ML(mlHembras));
    for i := 1 to NumPrototiposH do
    begin
      k := StrToInt(ObtenNsimo(JerarquiaH,i));
      Celda('A' + IntToStr(RenIni+i), PrototiposH[k].Nombre);
    end;
  end;  //with
end;

procedure TfrmExportar.ExportaMatrices;
var
  i, j,
  RenIni: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +(NumPrototiposM)+(NumPrototiposH)
              +(NumPrototiposM)+(NumPrototiposM)+24;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizInt) + ' ' + ML(mlSustratos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlSustratos));
    CabecerasSustratos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 7 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizSustratos.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +NumEstadios+NumPrototiposM+NumPrototiposM+27;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizInt) + ' ' + ML(mlDinamicos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlDinamico));
    CabecerasDinamicos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 5 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizDinamicos.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*2)+30;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizInt) + ' ' +ML(mlAgentes));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipo) + '\' + ML(mlContendiente));
    CabecerasAgentes('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizAgentes.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*3)+33;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizAtr) + ' ' + ML(mlSustratos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlSustratos));
    CabecerasSustratos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 7 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizSustratosA.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*4)+36;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizAtr) + ' ' + ML(mlDinamicos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlDinamico));
    CabecerasDinamicos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 5 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizDinamicosA.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*5)+39;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizAtr) + ' ' +ML(mlAgentes));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipo) + '\' + ML(mlContendiente));
    CabecerasAgentes('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizAgentesA.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*6)+42;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizMem) + ' ' + ML(mlSustratos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlSustratos));
    CabecerasSustratos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 7 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizSustratosM.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*7)+45;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizMem) + ' ' + ML(mlDinamicos));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgentes) + '\' + ML(mlDinamico));
    CabecerasDinamicos('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to 5 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizDinamicosM.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*8)+48;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizMem) + ' ' +ML(mlAgentes));
    Celda('A' + IntToStr(RenIni+1), ML(mlPrototipo) + '\' + ML(mlContendiente));
    CabecerasAgentes('B' + IntToStr(RenIni+1));
    ListaAgentes('A', RenIni+2);
    for i := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizAgentesM.Celda[i,j]);
    RenIni := 92+NumEstadios+(NumEstadios*5)+NumPrototiposM
              +(NumPrototiposM*6)+NumPrototiposH+(NumPrototiposH*6)
              +(NumPrototiposM*7)+(NumPrototiposH*7)
              +NumPrototiposM+NumPrototiposH
              +NumPrototiposM+NumPrototiposM
              +((NumEstadios+NumPrototiposM+NumPrototiposM)*9)+51;
    Celda('A' + IntToStr(RenIni), ML(mlMatrizMemCon));
    Celda('A' + IntToStr(RenIni+1), ML(mlAgente) + '\' + ML(mlConducta));
    ListaAgentes('A', RenIni+2);
    Celda('B' + IntToStr(RenIni+1), ML(mlMovimiento));
    Celda('C' + IntToStr(RenIni+1), ML(mlEnReposo));
    Celda('D' + IntToStr(RenIni+1), ML(mlBeber));
    Celda('E' + IntToStr(RenIni+1), ML(mlCmrGrasa));
    Celda('F' + IntToStr(RenIni+1), ML(mlCmrAzucar));
    Celda('G' + IntToStr(RenIni+1), ML(mlCmrProteina));
    Celda('H' + IntToStr(RenIni+1), ML(mlDesplegar));
    Celda('I' + IntToStr(RenIni+1), ML(mlEscalar));
    Celda('J' + IntToStr(RenIni+1), ML(mlRetirar));
    Celda('K' + IntToStr(RenIni+1), ML(mlIA));
    Celda('L' + IntToStr(RenIni+1), ML(mlIB));
    Celda('M' + IntToStr(RenIni+1), ML(mlCopular));
    Celda('N' + IntToStr(RenIni+1), ML(mlRechazar));
    Celda('O' + IntToStr(RenIni+1), ML(mlOvipositar));
    for i := 1 to 14 do
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
        Celda(Chr(65+i) + IntToStr(RenIni+j+1), MatrizConductasM.Celda[i,j]);
  end;  //with
end;

procedure TfrmExportar.ListaAgentes(Col: string; Ren: Integer);
var
  i: Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to NumEstadios do
      Celda(Col + IntToStr(Ren-1+i), Estadios[i].Nombre);
    for i := 1 to NumPrototiposM do
      Celda(Col + IntToStr(NumEstadios+Ren-1+i), PrototiposM[i].Nombre);
    for i := 1 to NumPrototiposH do
      Celda(Col + IntToStr(NumEstadios+NumPrototiposH+Ren-1+i),
              PrototiposH[i].Nombre);
  end;
end;

procedure TfrmExportar.CabecerasAgentes(CeldaInicio: string);
var
  i: Integer;
begin
  {with frmEditorAgentes.JuegoAgentes do
  begin
    Rango := exaJuegoAgentes.Range[CeldaInicio, CeldaInicio];
    for i := 1 to NumEstadios do
    begin
      Rango.Value2 := Estadios[i].Nombre;
      Rango := Rango.Next;
    end;
    for i := 1 to NumPrototiposM do
    begin
      Rango.Value2 := PrototiposM[i].Nombre;
      Rango := Rango.Next;
    end;
    for i := 1 to NumPrototiposH do
    begin
      Rango.Value2 := PrototiposH[i].Nombre;
      Rango := Rango.Next;
    end;
  end;  //with  }
end;

procedure TfrmExportar.CabecerasDinamicos(CeldaInicio: string);
begin
  {Rango := exaJuegoAgentes.Range[CeldaInicio, CeldaInicio];
  Rango.Value2 := ML(mlFntAgua);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlFntAzucar);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlFntGrasa);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlFntPrtn);
  Rango := Rango.Next;
  Rango.Value2 := ML(mlSitOvipo);  }
end;

procedure TfrmExportar.CabecerasSustratos(CeldaInicio: string);
begin
 { Rango := exaJuegoAgentes.Range[CeldaInicio, CeldaInicio];
  for i := 1 to 7 do
  begin
    Rango.Value2 := frmEditorAgentes.JuegoAgentes.Sustratos[i];
    Rango := Rango.Next;
  end; }
end;

initialization
  {$i ExportarAgentes.lrs}

end.
