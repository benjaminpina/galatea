unit CopiarNVeces;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, LResources;

type
  TfrmCopiarNVeces = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    sttNombre: TStaticText;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    edtVeces: TEdit;
    UpDown1: TUpDown;
    Label3: TLabel;
    btbCancelar: TBitBtn;
    btbAceptar: TBitBtn;
    GroupBox3: TGroupBox;
    chkSustrato1: TCheckBox;
    chkSustrato2: TCheckBox;
    chkSustrato3: TCheckBox;
    chkSustrato4: TCheckBox;
    chkSustrato5: TCheckBox;
    chkSustrato6: TCheckBox;
    chkSustrato7: TCheckBox;
    btnTodos: TButton;
    btnNinguno: TButton;
    procedure edtVecesKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnTodosClick(Sender: TObject);
    procedure btnNingunoClick(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    function RevisaCasillas: Boolean;
    procedure LlenaCasillasSustratos;
  public
    { Public declarations }
    NombreElemento: string;
    Palomeados: array [1..7] of Boolean;  //Indica los sustratos palomeados
    Veces: Word;
  end;

var
  frmCopiarNVeces: TfrmCopiarNVeces;

implementation

uses
  Multilenguaje, EditorEntornos, Dialogos;


procedure TfrmCopiarNVeces.edtVecesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then
    Key := #8;
end;

procedure TfrmCopiarNVeces.FormCreate(Sender: TObject);
begin
  LlenaCasillasSustratos;
  PuedeCerrar := True;
end;

procedure TfrmCopiarNVeces.LlenaCasillasSustratos;
begin
  with frmEditorEntornos.Entorno.Juego do
  begin
    chkSustrato1.Caption := Sustratos[1];
    chkSustrato2.Caption := Sustratos[2];
    chkSustrato3.Caption := Sustratos[3];
    chkSustrato4.Caption := Sustratos[4];
    chkSustrato5.Caption := Sustratos[5];
    chkSustrato6.Caption := Sustratos[6];
    chkSustrato7.Caption := Sustratos[7];
  end;
end;

procedure TfrmCopiarNVeces.btbAceptarClick(Sender: TObject);
var
  cont,    //cuenta las veces que aparece el sustrato en el entorno
  i, j, k: Integer;
begin
  if not RevisaCasillas then
  begin
    Fallo(ML(mlNMrcCsllSust), ML(mlEdEntGlt));
    PuedeCerrar := False;
    Exit; //-->
  end;
  Veces := StrToIntDef(edtVeces.Text, 1);
  Palomeados[1] := chkSustrato1.Checked;
  Palomeados[2] := chkSustrato2.Checked;
  Palomeados[3] := chkSustrato3.Checked;
  Palomeados[4] := chkSustrato4.Checked;
  Palomeados[5] := chkSustrato5.Checked;
  Palomeados[6] := chkSustrato6.Checked;
  Palomeados[7] := chkSustrato7.Checked;
  for k := 1 to 7 do
  begin      //Verificando que todos los sutratos permitidos están en el entorno
    cont := 0;
    if Palomeados[k] then
    begin
      for i := 1 to frmEditorEntornos.Entorno.Anchura do
        for j := 1 to frmEditorEntornos.Entorno.Altura do
          if frmEditorEntornos.Entorno.Cuadro[i,j] = Chr(k + 48) then
            Inc(cont);
      if cont = 0 then  //Ningún cuadro de entorno contiene al sustrato simple k
      begin
        Fallo(ML(mlSustNngnCdr) + frmEditorEntornos.Entorno.Juego.Sustratos[k],
          ML(mlEdEntGlt));
        PuedeCerrar := False;
        Exit; //-->
      end;  //if
    end;  //if
  end;  //for
end;

procedure TfrmCopiarNVeces.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PuedeCerrar;
  PuedeCerrar := True;
end;

function TfrmCopiarNVeces.RevisaCasillas: Boolean;
begin
  Result := (chkSustrato1.Checked) or
            (chkSustrato2.Checked) or
            (chkSustrato3.Checked) or
            (chkSustrato4.Checked) or
            (chkSustrato5.Checked) or
            (chkSustrato6.Checked) or
            (chkSustrato7.Checked);
end;

procedure TfrmCopiarNVeces.FormShow(Sender: TObject);
begin
  sttNombre.Caption := NombreElemento;
end;

procedure TfrmCopiarNVeces.btnTodosClick(Sender: TObject);
begin
  chkSustrato1.Checked := True;
  chkSustrato2.Checked := True;
  chkSustrato3.Checked := True;
  chkSustrato4.Checked := True;
  chkSustrato5.Checked := True;
  chkSustrato6.Checked := True;
  chkSustrato7.Checked := True;
end;

procedure TfrmCopiarNVeces.btnNingunoClick(Sender: TObject);
begin
  chkSustrato1.Checked := False;
  chkSustrato2.Checked := False;
  chkSustrato3.Checked := False;
  chkSustrato4.Checked := False;
  chkSustrato5.Checked := False;
  chkSustrato6.Checked := False;
  chkSustrato7.Checked := False;
end;

initialization
  {$i CopiarNVeces.lrs}
  {$i CopiarNVeces.lrs}

end.
