unit Prototipos;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ComCtrls, Comunes, ExtCtrls, LResources;

type

  { TfrmPrototipos }

  TfrmPrototipos = class(TForm)
    btbAceptar: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    sbtAgregarM: TSpeedButton;
    sbtEliminarM: TSpeedButton;
    sbtModificarM: TSpeedButton;
    lstMachos: TListBox;
    lstHembras: TListBox;
    sbtAgregarH: TSpeedButton;
    sbtEliminarH: TSpeedButton;
    sbtModificarH: TSpeedButton;
    Label3: TLabel;
    Label1: TLabel;
    shpColorMacho: TShape;
    shpColorHembra: TShape;
    procedure FormCreate(Sender: TObject);
    procedure sbtModificarMClick(Sender: TObject);
    procedure sbtModificarHClick(Sender: TObject);
    procedure sbtAgregarMClick(Sender: TObject);
    procedure sbtAgregarHClick(Sender: TObject);
    procedure sbtEliminarMClick(Sender: TObject);
    procedure sbtEliminarHClick(Sender: TObject);
    procedure lstMachosDblClick(Sender: TObject);
    procedure lstHembrasDblClick(Sender: TObject);
    procedure lstMachosClick(Sender: TObject);
    procedure lstHembrasClick(Sender: TObject);
  private
    { Private declarations }
    procedure ImportaValores;
    procedure EditarPrototipo(Sexo: TSexo);
    procedure AgregarPrototipo(Sexo: TSexo);
    procedure EliminarPrototipo(Sexo: TSexo; Num: Word);
  public
    { Public declarations }
  end;

var
  frmPrototipos: TfrmPrototipos;

implementation

uses
  EditorAgentes, EditarPrototipo, Dialogos, Multilenguaje;


procedure TfrmPrototipos.FormCreate(Sender: TObject);
begin
  ImportaValores;
  if frmEditorAgentes.JuegoAgentes.NumPrototiposM = 1 then
    sbtEliminarM.Enabled := False;
  if frmEditorAgentes.JuegoAgentes.NumPrototiposH = 1 then
    sbtEliminarH.Enabled := False;
  lstMachos.ItemIndex := 0;
  lstHembras.ItemIndex := 0;
end;

procedure TfrmPrototipos.ImportaValores;
var
  i: Integer;
begin
  lstMachos.Clear;
  lstHembras.Clear;
  with frmEditorAgentes.JuegoAgentes do
  begin
    for i := 1 to NumPrototiposM do
      lstMachos.Items.Add(PrototiposM[i].Nombre);
    for i := 1 to NumPrototiposH do
      lstHembras.Items.Add(PrototiposH[i].Nombre);
    shpColorMacho.Brush.Color := PrototiposM[1].Color;
    shpColorHembra.Brush.Color := PrototiposH[1].Color;
  end;
 end;

procedure TfrmPrototipos.EditarPrototipo(Sexo: TSexo);
var
  i: Integer;
begin
  frmEditarPrototipo := TfrmEditarPrototipo.Create(Application);
  if Sexo = sxMacho then
    i := lstMachos.ItemIndex
  else
    i := lstHembras.ItemIndex;
  frmEditarPrototipo.Indice := i + 1;
  frmEditarPrototipo.Sexo := Sexo;
  frmEditarPrototipo.ImportaValores;
  if frmEditarPrototipo.ShowModal = mrOK then
  begin
    frmEditarPrototipo.ExportaValores;
    ImportaValores;
    frmEditorAgentes.Salvado := False;
  end;
  FreeAndNil(frmEditarPrototipo);
  if Sexo = sxMacho then
  begin
    lstMachos.ItemIndex := i;
    shpColorMacho.Brush.Color :=
        frmEditorAgentes.JuegoAgentes.PrototiposM[i+1].Color;
  end
  else
  begin
    lstHembras.ItemIndex := i;
    shpColorHembra.Brush.Color :=
        frmEditorAgentes.JuegoAgentes.PrototiposH[i+1].Color;
  end;
end;

procedure TfrmPrototipos.AgregarPrototipo(Sexo: TSexo);
var
  i, j       : Integer;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    if Sexo = sxMacho then
      i := NumPrototiposM
    else
      i := NumPrototiposH;
    InsertaPrototipo(Sexo);
    frmEditorAgentes.InicializaPrototipos(i + 1, i + 1, Sexo, True);
    ImportaValores;
    if Sexo = sxMacho then
    begin
      CriteriosM[0,i] := '0';
      CriteriosM[1,i] := '=';
      CriteriosM[2,i] := '0';
      JerarquiaM := JerarquiaM + IntToStr(i+1) + ',';
      for j := 1 to 7 do  //Número de sustratos = 7
      begin
        MatrizSustratos.Celda[j, NumEstadios+NumPrototiposM] := '1,'
            + NVeces('0,', 11);
        MatrizSustratosA.Celda[j, NumEstadios+NumPrototiposM] := '0,1';
        MatrizSustratosM.Celda[j, NumEstadios+NumPrototiposM] := 'Age';
      end;
      for j := 1 to 5 do  //Número de elementos dinámicos = 5
      begin
        MatrizDinamicos.Celda[j, NumEstadios+NumPrototiposM] := '1,'
            + NVeces('0,', 11);
        MatrizDinamicosA.Celda[j, NumEstadios+NumPrototiposM] := '0,1';
        MatrizDinamicosM.Celda[j, NumEstadios+NumPrototiposM] := 'Age';
      end;
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentes.Celda[j, NumEstadios+NumPrototiposM] := '1,'
            + NVeces('0,', 11);
        MatrizAgentes.Celda[NumEstadios+NumPrototiposM,j] := '1,'
            + NVeces('0,', 11);
        MatrizAgentesA.Celda[j, NumEstadios+NumPrototiposM] := '0,1';
        MatrizAgentesA.Celda[NumEstadios+NumPrototiposM,j] := '0,1';
        MatrizAgentesM.Celda[j, NumEstadios+NumPrototiposM] := 'Age';
        MatrizAgentesM.Celda[NumEstadios+NumPrototiposM,j] := 'Age';
      end;
      for j := 1 to 14 do
        MatrizConductasM.Celda[j, NumEstadios+NumPrototiposM] := 'Age';
      MatrizAgentes.Celda[NumEstadios+NumPrototiposM,1] := NVeces('0,', 12);
      lstMachos.ItemIndex := i;
      sbtEliminarM.Enabled := True;
    end
    else
    begin
      CriteriosH[0,i] := '0';
      CriteriosH[1,i] := '=';
      CriteriosH[2,i] := '0';
      JerarquiaH := JerarquiaH + IntToStr(i+1) + ',';
      for j := 1 to 7 do  //Número de sustratos = 7
      begin
        MatrizSustratos.Celda[j,NumEstadios+NumPrototiposM+NumPrototiposH] :=
              '1,' + NVeces('0,', 11);
        MatrizSustratosA.Celda[j,NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                  := '0,1';
        MatrizSustratosM.Celda[j,NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                  := 'Age';
      end;
      for j := 1 to 5 do  //Número de elementos dinámicos = 5
      begin
        MatrizDinamicos.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH] :=
              '1,' + NVeces('0,', 11);
        MatrizDinamicosA.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                 := '0,1';
        MatrizDinamicosM.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                 := 'Age';
      end;
      for j := 1 to NumEstadios + NumPrototiposM + NumPrototiposH do
      begin
        MatrizAgentes.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH] :=
              '1,' + NVeces('0,', 11);
        MatrizAgentes.Celda[NumEstadios+NumPrototiposM+NumPrototiposH,j] :=
              '1,' + NVeces('0,', 11);
        MatrizAgentesA.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                := '0,1';
        MatrizAgentesA.Celda[NumEstadios+NumPrototiposM+NumPrototiposH,j]
                                                                := '0,1';
        MatrizAgentesM.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                := '0';
        MatrizAgentesM.Celda[NumEstadios+NumPrototiposM+NumPrototiposH,j]
                                                                := '0';
      end;
      for j := 1 to 14 do
        MatrizConductasM.Celda[j, NumEstadios+NumPrototiposM+NumPrototiposH]
                                                                := '0';
      MatrizAgentes.Celda[NumEstadios+NumPrototiposM+NumPrototiposH,1]
                              := NVeces('0,', 12);
      lstHembras.ItemIndex := i;
      sbtEliminarH.Enabled := True;
    end;  //if
  end;  //with
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmPrototipos.EliminarPrototipo(Sexo: TSexo; Num: Word);
var
  i: Integer;
  s: string;
begin
  with frmEditorAgentes.JuegoAgentes do
  begin
    if PreguntaSN(ML(mlElmnrPrttp), ML(mlEdAgntGlt))= rSi then
      BorraPrototipo(Sexo, Num)  //¿seguro de eliminar?
    else
      Exit; //-->
    ImportaValores;
    if Sexo = sxMacho then
    begin
      s := '';
      for i := 1 to NumPrototiposM do
        if ObtenNsimo(JerarquiaM, i) <> IntToStr(Num) then
          s := s + ObtenNsimo(JerarquiaM, i) + ',';
      JerarquiaM := s;
      if Num > 1 then
        lstMachos.ItemIndex := Num - 2
      else
        lstMachos.ItemIndex := 0;
      if NumPrototiposM = 1 then
        sbtEliminarM.Enabled := False;
    end
    else
    begin
      s := '';
      for i := 1 to NumPrototiposH do
        if ObtenNsimo(JerarquiaH, i) <> IntToStr(Num) then
          s := s + ObtenNsimo(JerarquiaH, i) + ',';
      JerarquiaH := s;
      if Num > 1 then
        lstHembras.ItemIndex := Num - 2
      else
        lstHembras.ItemIndex := 0;
      if NumPrototiposH = 1 then
        sbtEliminarH.Enabled := False;
    end;
  end; //with
  frmEditorAgentes.Salvado := False;
end;

procedure TfrmPrototipos.sbtModificarMClick(Sender: TObject);
begin
  EditarPrototipo(sxMacho);
end;

procedure TfrmPrototipos.sbtModificarHClick(Sender: TObject);
begin
  EditarPrototipo(sxHembra);
end;

procedure TfrmPrototipos.sbtAgregarMClick(Sender: TObject);
begin
  AgregarPrototipo(sxMacho);
end;

procedure TfrmPrototipos.sbtAgregarHClick(Sender: TObject);
begin
  AgregarPrototipo(sxHembra);
end;

procedure TfrmPrototipos.sbtEliminarMClick(Sender: TObject);
begin
  EliminarPrototipo(sxMacho, lstMachos.ItemIndex + 1);
end;

procedure TfrmPrototipos.sbtEliminarHClick(Sender: TObject);
begin
  EliminarPrototipo(sxHembra, lstHembras.ItemIndex + 1);
end;

procedure TfrmPrototipos.lstMachosDblClick(Sender: TObject);
begin
  EditarPrototipo(sxMacho);
end;

procedure TfrmPrototipos.lstHembrasDblClick(Sender: TObject);
begin
  EditarPrototipo(sxHembra);
end;

procedure TfrmPrototipos.lstMachosClick(Sender: TObject);
begin
  if lstMachos.ItemIndex = -1 then
  	lstMachos.ItemIndex := 0;
  shpColorMacho.Brush.Color :=
    frmEditorAgentes.JuegoAgentes.PrototiposM[lstMachos.ItemIndex + 1].Color;
end;

procedure TfrmPrototipos.lstHembrasClick(Sender: TObject);
begin
  if lstHembras.ItemIndex = -1 then
  	lstHembras.ItemIndex := 0;
  shpColorHembra.Brush.Color :=
    frmEditorAgentes.JuegoAgentes.PrototiposH[lstHembras.ItemIndex + 1].Color;
end;

initialization
  {$i Prototipos.lrs}

end.
