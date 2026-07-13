unit EditarMixto;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, LResources;

type

  { TfrmEditarMixto }

  TfrmEditarMixto = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    edt5: TEdit;
    edt6: TEdit;
    edt7: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    btnColor: TButton;
    btbAceptar: TBitBtn;
    btbCancelar: TBitBtn;
    ColorDialog1: TColorDialog;
    chbMezclar: TCheckBox;
    shpColor: TShape;
    procedure FormCreate(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure btbAceptarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btbCancelarClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure chbMezclarChange(Sender: TObject);
  private
    { Private declarations }
    PuedeCerrar: Boolean;
    function Valida: Boolean;
  public
    { Public declarations }
  end;

var
  frmEditarMixto: TfrmEditarMixto;

implementation


uses
  Dialogos, Multilenguaje;

procedure TfrmEditarMixto.FormCreate(Sender: TObject);
begin
  PuedeCerrar := True;
end;

procedure TfrmEditarMixto.GroupBox1Click(Sender: TObject);
begin

end;

function TfrmEditarMixto.Valida: Boolean;
var
  i, j, c: Integer;
begin
  Result := True;
  j := 0;
  Val(edt1.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt1.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt2.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt2.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt3.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt3.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt4.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt4.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt5.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt5.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt6.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt6.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  Val(edt7.Text, i, c);
  if (c <> 0) or (i > 100) then
  begin
    Fallo(ML(mlErrNVld), ML(mlEdSustGl));
    edt7.SetFocus;
    Result := False;
    Exit; //-->
  end
  else
    j := j + i;
  if j <> 100 then
  begin
    Fallo(ML(mlErrSm100), ML(mlEdSustGl)); //La suma de % debe ser igual a 100
    edt1.SetFocus;
    Result := False;
  end;
end;

procedure TfrmEditarMixto.btbAceptarClick(Sender: TObject);
begin
  if Valida then
    PuedeCerrar := True
  else
    PuedeCerrar := False;
end;



procedure TfrmEditarMixto.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose :=  PuedeCerrar;
  PuedeCerrar := True;
end;

procedure TfrmEditarMixto.btbCancelarClick(Sender: TObject);
begin

end;

procedure TfrmEditarMixto.btnColorClick(Sender: TObject);
begin
  if ColorDialog1.Execute then
    shpColor.Brush.Color := ColorDialog1.Color;
end;

procedure TfrmEditarMixto.chbMezclarChange(Sender: TObject);
begin

end;

initialization
  {$i EditarMixto.lrs}

end.
