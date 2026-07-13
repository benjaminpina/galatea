unit SeleccionaElemento;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Elementos, Agentes, LResources;

type

  TAccion = (acEditar, acEliminar, acCopiarNveces, acHuevos);

  TfrmSeleccionarElemento = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    lstAgentes: TListBox;
    lstDinamicos: TListBox;
    GroupBox3: TGroupBox;
    lstOviposicion: TListBox;
    GroupBox4: TGroupBox;
    lstHuevos: TListBox;
    procedure lstAgentesClick(Sender: TObject);
    procedure lstDinamicosClick(Sender: TObject);
    procedure lstOviposicionClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure lstHuevosClick(Sender: TObject);
    procedure lstAgentesDblClick(Sender: TObject);
    procedure lstHuevosDblClick(Sender: TObject);
    procedure lstDinamicosDblClick(Sender: TObject);
    procedure lstOviposicionDblClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    procedure ProcesaAgentes;
    procedure ProcesaHuevos;
    procedure ProcesaDinamicos;
    procedure ProcesaOviposicion;
  public
    { Public declarations }
    Agentes    : array of TAgente;
    Huevos     : array of THuevo;
    Dinamicos  : array of TDinamico;
    Oviposicion: array of TSitioOviposicion;
    Accion: TAccion;
    procedure DespliegaListas;
  end;

var
  frmSeleccionarElemento: TfrmSeleccionarElemento;

implementation

uses
  Dialogos, Multilenguaje, ElementoDinamico, EditorEntornos, EditarAgente,
  SitioOviposicion, Mediadores, CopiarNVeces, EditarPuesta,
  EditarHuevo;


{ TfrmSeleccionarElemento }

procedure TfrmSeleccionarElemento.DespliegaListas;
var
  NumHuevos,
  i, j, k: Integer;
  s: string;
  HuevosPortador: array of THuevo;
  Mediador: TMediador;
begin
  NumHuevos := 0;
  for i := 0 to Length(Agentes) - 1 do
  begin
    Mediador := TMediador.Create(frmEditorEntornos.Entorno);
    Mediador.Agente := Agentes[i];
    lstAgentes.Items.Add(Agentes[i].Nombre + ' [' + Mediador.NombrePrototipo
        + ']');
    Mediador.Free;
  end;
  for i := 0 to Length(Agentes) - 1 do
  begin
    if Agentes[i].Acarreados > 0 then
    begin
      NumHuevos := NumHuevos + Agentes[i].Acarreados;
      SetLength(Huevos, NumHuevos);
      SetLength(HuevosPortador, Agentes[i].Acarreados);
      frmEditorEntornos.Entorno.ListaHuevos.HuevosPortador(Agentes[i],
          HuevosPortador);
      k := Length(Huevos) - 1;
      for j := Length(HuevosPortador) - 1 downto 0 do
      begin
        Huevos[k] := HuevosPortador[j];
        Dec(k);
      end;
    end;
  end;
  for i := 0 to Length(Dinamicos) - 1 do
  begin
    case Dinamicos[i].TipoED of
      edFntAgua    : s := ML(mlFntAgua);
      edFntGrasa   : s := ML(mlFntGrasa);
      edFntAzucar  : s := ML(mlFntAzucar);
      edFntProteina: s := ML(mlFntPrtn);
    end;
    lstDinamicos.Items.Add(Dinamicos[i].Nombre + ' [' + s + ']');
  end;
  for i := 0 to Length(Oviposicion) - 1 do
    lstOviposicion.Items.Add(
        Oviposicion[i].Nombre + ' [' + ML(mlSitOvipo) + ']');
  for i := 0 to Length(Oviposicion) - 1 do
  begin
    if Oviposicion[i].Nivel > 0 then
    begin
      NumHuevos := NumHuevos + Oviposicion[i].Nivel;
      SetLength(Huevos, NumHuevos);
      SetLength(HuevosPortador, Oviposicion[i].Nivel);
      frmEditorEntornos.Entorno.ListaHuevos.HuevosPortador(Oviposicion[i],
          HuevosPortador);
      k := Length(Huevos) - 1;
      for j := Length(HuevosPortador) - 1 downto 0 do
      begin
        Huevos[k] := HuevosPortador[j];
        Dec(k);
      end;
    end;
  end;
  for i := 0 to Length(Huevos) - 1 do
  begin
    lstHuevos.Items.Add(Huevos[i].Nombre + '[' + ML(mlHuevo) + ']:'
        + Huevos[i].Portador.Nombre);
  end;
  if Accion in [acHuevos, acCopiarNVeces] then
    lstHuevos.Enabled := False;
end;  //proc DespliegaListas

procedure TfrmSeleccionarElemento.lstAgentesClick(Sender: TObject);
begin
  lstDinamicos.ItemIndex := - 1;
  lstOviposicion.ItemIndex := - 1;
  lstHuevos.ItemIndex := - 1;
end;

procedure TfrmSeleccionarElemento.lstDinamicosClick(Sender: TObject);
begin
  lstAgentes.ItemIndex := - 1;
  lstOviposicion.ItemIndex := - 1;
  lstHuevos.ItemIndex := - 1;
end;

procedure TfrmSeleccionarElemento.lstOviposicionClick(Sender: TObject);
begin
  lstAgentes.ItemIndex := - 1;
  lstDinamicos.ItemIndex := - 1;
  lstHuevos.ItemIndex := - 1;
end;

procedure TfrmSeleccionarElemento.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmSeleccionarElemento.FormCreate(Sender: TObject);
begin
  PuedeCerrar := True;
  Accion := acEditar;
end;

procedure TfrmSeleccionarElemento.btbAceptarClick(Sender: TObject);
begin
  if (lstAgentes.ItemIndex = -1) and (lstDinamicos.ItemIndex = -1)
      and (lstOviposicion.ItemIndex = -1)and (lstHuevos.ItemIndex = -1) then
    begin
      Fallo(ML(mlNoSlccElmnt), ML(mlEdEntGlt));
      PuedeCerrar := False;
      Exit; //-->
    end;
  if lstAgentes.ItemIndex <> - 1 then
    ProcesaAgentes
  else if lstDinamicos.ItemIndex <> - 1 then
    ProcesaDinamicos
  else if lstOviposicion.ItemIndex <> - 1 then
    ProcesaOviposicion
  else if lstHuevos.ItemIndex <> - 1 then
    ProcesaHuevos;
end;  //proc btnAcepatrClick

procedure TfrmSeleccionarElemento.lstHuevosClick(Sender: TObject);
begin
  lstAgentes.ItemIndex := - 1;
  lstDinamicos.ItemIndex := - 1;
  lstOviposicion.ItemIndex := - 1;
end;

procedure TfrmSeleccionarElemento.ProcesaAgentes;
var
  Permitidos : array [1..7] of Boolean;
  Mediador   : TMediador;
  i,
  Veces,
  Indice     : Word;
 begin
  case Accion of
    acEditar:
    begin
      frmEditarAgente := TfrmEditarAgente.Create(Application);
      frmEditarAgente.Agente := Agentes[lstAgentes.ItemIndex];
      frmEditarAgente.DespliegaValores;
      if frmEditarAgente.ShowModal = mrOK then
        frmEditorEntornos.Salvado := False;
      FreeAndNil(frmEditarAgente);
    end;
    acEliminar:
    begin
      with Agentes[lstAgentes.ItemIndex] do
      begin
        if Acarreados > 0 then //¿Porta huevos?
        begin
          SetLength(Huevos, Acarreados);
          frmEditorEntornos.Entorno.ListaHuevos.HuevosPortador
              (Agentes[lstAgentes.ItemIndex], Huevos);
          for i := 0 to Acarreados - 1 do
            frmEditorEntornos.Entorno.ListaHuevos.Retira(Huevos[i]);
        end;
      end;
        frmEditorEntornos.Entorno.ListaAgentes.Retira
                                            (Agentes[lstAgentes.ItemIndex]);
    end;
    acCopiarNveces:
    begin
      Mediador :=
          TMediador.Create(frmEditorEntornos.Entorno);
      Mediador.Agente := Agentes[lstAgentes.ItemIndex];
      frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
      frmCopiarNVeces.NombreElemento := Agentes[lstAgentes.ItemIndex].Nombre
          + '[' + Mediador.NombrePrototipo + ']';
      Mediador.Free;
      if frmCopiarNVeces.ShowModal = mrOK then
      begin
        Veces := frmCopiarNVeces.Veces;
        Indice := frmEditorEntornos.Entorno.ListaAgentes.IndiceDe(
            Agentes[lstAgentes.ItemIndex]);
        for i := 1 to 7 do
          Permitidos[i] := frmCopiarNVeces.Palomeados[i];
        FreeAndNil(frmCopiarNVeces);
        frmEditorEntornos.CopiaNVecesAgente(Indice, Veces, Permitidos);
        frmEditorEntornos.Salvado := False;
      end;
    end;
    acHuevos:
    begin
      frmEditarPuesta := TfrmEditarPuesta.Create(Application);
      if frmEditarPuesta.ShowModal = mrOK then
      begin
        frmEditorEntornos.CreaPuestaHuevos(frmEditarPuesta.Padre,
            frmEditarPuesta.Madre, Agentes[lstAgentes.ItemIndex],
            frmEditarPuesta.Edad, frmEditarPuesta.Veces);
      end;
      FreeAndNil(frmEditarPuesta);
    end;
  end;  //case
end;

procedure TfrmSeleccionarElemento.ProcesaDinamicos;
var
  Permitidos : array [1..7] of Boolean;
  i,
  Veces,
  Indice     : Word;
begin
  case Accion of
    acEditar:
    begin
      frmElementoDinamico := TfrmElementoDinamico.Create(Application);
      frmElementoDinamico.Dinamico := Dinamicos[lstDinamicos.ItemIndex];
      frmElementoDinamico.DespliegaValores;
      if frmElementoDinamico.ShowModal = mrOK then
        frmEditorEntornos.Salvado := False;
      FreeAndNil(frmElementoDinamico);
    end;
    acEliminar:
      frmEditorEntornos.Entorno.ListaDinamicos.Retira
                                        (Dinamicos[lstDinamicos.ItemIndex]);
    acCopiarNveces:
    begin
      frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
      case Dinamicos[0].TipoED of
        edFntAgua : frmCopiarNVeces.NombreElemento := ML(mlFntAgua);
        edFntGrasa : frmCopiarNVeces.NombreElemento := ML(mlFntAzucar);
        edFntAzucar : frmCopiarNVeces.NombreElemento := ML(mlFntGrasa);
        edFntProteina : frmCopiarNVeces.NombreElemento := ML(mlFntPrtn);
      end;
      if frmCopiarNVeces.ShowModal = mrOK then
      begin
        Veces := frmCopiarNVeces.Veces;
        Indice :=
            frmEditorEntornos.Entorno.ListaDinamicos.IndiceDe(
            Dinamicos[lstDinamicos.ItemIndex]);
        for i := 1 to 7 do
          Permitidos[i] := frmCopiarNVeces.Palomeados[i];
        frmEditorEntornos.CopiaNVecesDinamico(Indice, Veces, Permitidos);
        frmEditorEntornos.Salvado := False;
      end;
      FreeAndNil(frmCopiarNVeces);;
    end;
  end;  //case
end;

procedure TfrmSeleccionarElemento.ProcesaHuevos;
begin
  case Accion of
    acEditar:
    begin
      frmEditarHuevo := TfrmEditarHuevo.Create(Application);
      frmEditarHuevo.Huevo := Huevos[lstHuevos.ItemIndex];
      frmEditarHuevo.DespliegaValores;
      if frmEditarHuevo.ShowModal = mrOK then
        frmEditorEntornos.Salvado := False;
      FreeAndNil(frmEditarHuevo);
    end;
    acEliminar:
    begin
      with Huevos[lstHuevos.ItemIndex] do
      begin
        {if Portador is TAgente then
          Dec((Portador as TAgente).Acarreados)
        else
          (Portador as TSitioOviposicion).Nivel :=
              (Portador as TSitioOviposicion).Nivel - 1;}
        frmEditorEntornos.Entorno.ListaHuevos.Retira
                                        (Huevos[lstHuevos.ItemIndex]);
      end;
    end;
  end; //case
end;

procedure TfrmSeleccionarElemento.ProcesaOviposicion;
var
  Permitidos : array [1..7] of Boolean;
  i,
  Veces,
  Indice     : Word;
begin
  case Accion of
    acEditar:
    begin
      frmSitioOviposicion := TfrmSitioOviposicion.Create(Application);
      frmSitioOviposicion.Oviposicion :=
          Oviposicion[lstOviposicion.ItemIndex];
      frmSitioOviposicion.DespliegaValores;
      if frmSitioOviposicion.ShowModal = mrOK then
        frmEditorEntornos.Salvado := False;
      FreeAndNil(frmSitioOviposicion);
    end;
    acEliminar:
    begin
      with Oviposicion[lstOviposicion.ItemIndex] do
      begin
        if  Nivel > 0 then //¿Contiene huevos?
        begin
          SetLength(Huevos, Nivel);
          frmEditorEntornos.Entorno.ListaHuevos.HuevosPortador
              (Oviposicion[lstOviposicion.ItemIndex], Huevos);
          for i := 0 to Nivel - 1 do
            frmEditorEntornos.Entorno.ListaHuevos.Retira(Huevos[i]);
        end;
      end;
      frmEditorEntornos.Entorno.ListaOviposicion.Retira
                                      (Oviposicion[lstOviposicion.ItemIndex]);
    end;
    acCopiarNveces:
    begin
      frmCopiarNVeces := TfrmCopiarNVeces.Create(Application);
      frmCopiarNVeces.NombreElemento := ML(mlSitOvipo);
      if frmCopiarNVeces.ShowModal = mrOK then
      begin
        Veces := frmCopiarNVeces.Veces;
        Indice :=
            frmEditorEntornos.Entorno.ListaOviposicion.IndiceDe(
                Oviposicion[lstOviposicion.ItemIndex]);
        for i := 1 to 7 do
          Permitidos[i] := frmCopiarNVeces.Palomeados[i];
        frmEditorEntornos.CopiaNVecesOviposicion(Indice, Veces, Permitidos);
        frmEditorEntornos.Salvado := False;
      end;
      FreeAndNil(frmCopiarNVeces);
    end;
    acHuevos:
    begin
      frmEditarPuesta := TfrmEditarPuesta.Create(Application);
      if frmEditarPuesta.ShowModal = mrOK then
      begin
        frmEditorEntornos.CreaPuestaHuevos(frmEditarPuesta.Padre,
            frmEditarPuesta.Madre, Oviposicion[lstOviposicion.ItemIndex],
            frmEditarPuesta.Edad, frmEditarPuesta.Veces);
      end;
      FreeAndNil(frmEditarPuesta);
    end;
  end;  //case
end;

procedure TfrmSeleccionarElemento.lstAgentesDblClick(Sender: TObject);
begin
  ProcesaAgentes;
  Self.ModalResult := mrOK;
end;

procedure TfrmSeleccionarElemento.lstHuevosDblClick(Sender: TObject);
begin
  ProcesaHuevos;
  Self.ModalResult := mrOK;
end;

procedure TfrmSeleccionarElemento.lstDinamicosDblClick(Sender: TObject);
begin
  ProcesaDinamicos;
  Self.ModalResult := mrOK;
end;

procedure TfrmSeleccionarElemento.lstOviposicionDblClick(Sender: TObject);
begin
  ProcesaOviposicion;
  Self.ModalResult := mrOK;
end;

initialization
  {$i SeleccionaElemento.lrs}
  {$i SeleccionaElemento.lrs}

end.
