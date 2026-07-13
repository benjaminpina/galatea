unit SeleccionarPrototipo;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Comunes, ComCtrls, LResources;

type
  TfrmSeleccionaPrototipo = class(TForm)
    lstMachos: TListBox;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    lstHembras: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    lstMachosInm: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    lstHembrasInm: TListBox;
    procedure lstMachosClick(Sender: TObject);
    procedure lstHembrasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstMachosInmClick(Sender: TObject);
    procedure lstMachosInmDblClick(Sender: TObject);
    procedure lstMachosDblClick(Sender: TObject);
    procedure lstHembrasDblClick(Sender: TObject);
    procedure btbCancelarClick(Sender: TObject);
    procedure lstHembrasInmClick(Sender: TObject);
    procedure lstHembrasInmDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure ImportaValores;
  public
    { Public declarations }
    NombrePrototipo: string;
    NumeroPrototipo: Word;
    SexoPrototipo: TSexo;
  end;

var
  frmSeleccionaPrototipo: TfrmSeleccionaPrototipo;

implementation

uses
  EditorEntornos, JuegoAgentes;



procedure TfrmSeleccionaPrototipo.lstMachosClick(Sender: TObject);
begin
  NombrePrototipo := lstMachos.Items.Strings[lstMachos.ItemIndex];
  NumeroPrototipo := frmEditorEntornos.Entorno.Juego.NumEstadios
                      + lstMachos.ItemIndex + 1;
  SexoPrototipo := sxMacho;
  lstMachosInm.ItemIndex := - 1;
  lstHembrasInm.ItemIndex := - 1;
  lstHembras.ItemIndex := - 1;
end;

procedure TfrmSeleccionaPrototipo.lstHembrasClick(Sender: TObject);
begin
  NombrePrototipo := lstHembras.Items.Strings[lstHembras.ItemIndex];
  NumeroPrototipo :=  frmEditorEntornos.Entorno.Juego.NumEstadios
                    + frmEditorEntornos.Entorno.Juego.NumPrototiposM
                    + lstHembras.ItemIndex + 1;
  SexoPrototipo := sxHembra;
  lstMachosInm.ItemIndex := - 1;
  lstHembrasInm.ItemIndex := - 1;
  lstMachos.ItemIndex := - 1;
end;

procedure TfrmSeleccionaPrototipo.FormCreate(Sender: TObject);
begin
  ImportaValores;
  lstMachosInm.ItemIndex := - 1;
  lstHembrasInm.ItemIndex := - 1;
  lstMachos.ItemIndex := 0;
  lstHembras.ItemIndex := - 1;
  NombrePrototipo := lstMachos.Items.Strings[lstMachos.ItemIndex];
  NumeroPrototipo := frmEditorEntornos.Entorno.Juego.NumEstadios
                      + lstMachos.ItemIndex + 1;
end;

procedure TfrmSeleccionaPrototipo.ImportaValores;
var
  i: Integer;
begin
  with frmEditorEntornos.Entorno.Juego do
  begin
    for i := 2 to NumEstadios do
    begin
      if SexoPrototipo(i) = sxIndefinido then
      begin
        lstMachosInm.Items.Add(IntToStr(i) + ', ' + Estadios[i].Nombre);
        lstHembrasInm.Items.Add(IntToStr(i) + ', ' + Estadios[i].Nombre);
      end
      else
      begin
        case SexoPrototipo(i) of
          sxMacho:
              lstMachosInm.Items.Add(IntToStr(i) + ', ' + Estadios[i].Nombre
                  + '[' + Ligado(i) + ']');
          sxHembra:
              lstHembrasInm.Items.Add(IntToStr(i) + ', ' + Estadios[i].Nombre
                  + '[' + Ligado(i) + ']');
        end
      end;
    end;
    for i := 1 to NumPrototiposM do
      lstMachos.Items.Add(PrototiposM[i].Nombre);
    for i := 1 to NumPrototiposH do
      lstHembras.Items.Add(PrototiposH[i].Nombre);
  end;
end;

procedure TfrmSeleccionaPrototipo.lstMachosInmClick(Sender: TObject);
begin
  NombrePrototipo := lstMachosInm.Items.Strings[lstMachosInm.ItemIndex];
  NumeroPrototipo := StrToInt(ObtenNsimo(NombrePrototipo, 1));
  SexoPrototipo := sxMacho;
  lstHembrasInm.ItemIndex := - 1;
  lstMachos.ItemIndex := - 1;
  lstHembras.ItemIndex := - 1;
end;

procedure TfrmSeleccionaPrototipo.lstMachosInmDblClick(Sender: TObject);
begin
  lstMachosInmClick(Self);
  Self.Close;
end;

procedure TfrmSeleccionaPrototipo.lstMachosDblClick(Sender: TObject);
begin
  lstMachosClick(Self);
  Self.Close;
end;

procedure TfrmSeleccionaPrototipo.lstHembrasDblClick(Sender: TObject);
begin
  lstHembrasClick(Self);
  Self.Close;
end;

procedure TfrmSeleccionaPrototipo.btbCancelarClick(Sender: TObject);
begin
  NombrePrototipo := '';
  NumeroPrototipo := 0;
end;

procedure TfrmSeleccionaPrototipo.lstHembrasInmClick(Sender: TObject);
begin
  NombrePrototipo := lstHembrasInm.Items.Strings[lstHembrasInm.ItemIndex];
  NumeroPrototipo := StrToInt(ObtenNsimo(NombrePrototipo, 1));
  SexoPrototipo := sxHembra;
  lstMachosInm.ItemIndex := - 1;
  lstMachos.ItemIndex := - 1;
  lstHembras.ItemIndex := - 1;
end;

procedure TfrmSeleccionaPrototipo.lstHembrasInmDblClick(Sender: TObject);
begin
  lstHembrasInmClick(Self);
  Self.Close;
end;

initialization
  {$i SeleccionarPrototipo.lrs}
  {$i SeleccionarPrototipo.lrs}

end.
