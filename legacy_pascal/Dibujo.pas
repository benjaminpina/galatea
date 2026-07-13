unit Dibujo;

{$MODE Delphi}

interface

uses
  ExtCtrls, Graphics, Escenarios, Elementos, Entornos, Agentes;

var
  Plataforma: TCanvas;

procedure DibujaEscenario(Escenario: TEscenario);
procedure DibujaElementoDinamico(Elemento: TDinamico; XFisica, YFisica,
    CuadroFisico: Word);
procedure DibujaAgente(Agente: TAgente; XFisica, YFisica,
    CuadroFisico: Word);

implementation

uses
  Comunes;

procedure DibujaEscenario(Escenario: TEscenario);
var
  i, j: Integer;
begin
  with Plataforma do
  begin
  	Clear;
    Pen.Style := psSolid;
    Pen.Color := clBlack;
    Brush.Style := bsSolid;
    for i := 1 to Escenario.Anchura do
      for j := 1 to Escenario.Altura do
      begin
        Brush.Color := Escenario.ObtenColorSustrato(Escenario.Cuadro[i, j]);
        if not Escenario.Cuadricula then
          Pen.Color := Brush.Color;
        Rectangle(Escenario.XFisica(i + 1) , Escenario.YFisica(j + 1),
                  Escenario.XFisica(i + 1) + Escenario.CuadroFisico,
                  Escenario.YFisica(j + 1) + Escenario.CuadroFisico);
      end
  end; //with
end;

procedure DibujaElementoDinamico(Elemento: TDinamico; XFisica, YFisica,
    CuadroFisico: Word);
begin
  with Plataforma do
  begin
    Brush.Style := bsSolid;
    Pen.Style := psSolid;
    Pen.Color := clBlack;
    case Elemento.TipoED of
      edFntAgua    : Brush.Color := clAqua;
      edFntGrasa   : Brush.Color := clYellow;
      edFntAzucar  : Brush.Color := clWhite;
      edFntProteina: Brush.Color := clRed;
      edStOvpscn   : Brush.Color := clGreen;
    end;
    Ellipse(XFisica, YFisica, XFisica + CuadroFisico, YFisica + CuadroFisico);
    if (Elemento.TipoED = edStOvpscn) and (Elemento.Nivel > 0) then
                        //Marcar que sitio de oviposición que contiene huevos
    begin
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      Brush.Color := clYellow;
      Ellipse((XFisica + (CuadroFisico div 2)) - 1,
              (YFisica + (CuadroFisico div 2)) - 1,
              (XFisica + (CuadroFisico div 2)) + 1,
              (YFisica + (CuadroFisico div 2)) + 1);
    end;
  end;  //with
end;

procedure DibujaAgente(Agente: TAgente; XFisica, YFisica,
    CuadroFisico: Word);
var
  CabezaX, CabezaY,
  AbdomenX, AbdomenY,
  ColaX, ColaY        : Word;
begin
  if not Agente.Adulto then  //¿Es inmaduro?
  begin
    with Plataforma do
    begin
      Brush.Style := bsSolid;
      Pen.Color := clBlack;
      Pen.Style := psDot;
      Brush.Color := Agente.Color;
      Ellipse(XFisica, YFisica, XFisica + CuadroFisico, YFisica + CuadroFisico);
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      case Agente.Sexo of
        sxMacho : Brush.Color := clBlue;
        sxHembra: Brush.Color := clFuchsia;
      end;
      Ellipse((XFisica + (CuadroFisico div 2)) - 2,
              (YFisica + (CuadroFisico div 2)) - 2,
              (XFisica + (CuadroFisico div 2)) + 2,
              (YFisica + (CuadroFisico div 2)) + 2);
    end;
    Exit; //-->
  end;
  AbdomenX := XFisica + Round(CuadroFisico / 2);
  AbdomenY := YFisica + Round(CuadroFisico / 2);
  CabezaX := XFisica + Round(CuadroFisico / 5);
  CabezaY := YFisica + Round(CuadroFisico / 5);
  ColaX := XFisica + Round(CuadroFisico * 0.8);
  ColaY := YFisica + Round(CuadroFisico * 0.8);
  case Agente.Direccion of
    drNO:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 5);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico * 0.8);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drN:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 2);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 2);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drNE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drO:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 5);
      CabezaY := YFisica + Round(CuadroFisico / 2);
      ColaX := XFisica + Round(CuadroFisico * 0.8);
      ColaY := YFisica + Round(CuadroFisico / 2);
    end;
    drE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 2);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico / 2);
    end;
    drSO:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico / 5);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico * 0.8);
    end;
    drS:
    begin
      CabezaX := XFisica + Round(CuadroFisico / 2);
      CabezaY := YFisica + Round(CuadroFisico * 0.8);
      ColaX := XFisica + Round(CuadroFisico / 2);
      ColaY := YFisica + Round(CuadroFisico / 5);
    end;
    drSE:
    begin
      CabezaX := XFisica + Round(CuadroFisico * 0.8);
      CabezaY := YFisica + Round(CuadroFisico * 0.8);
      ColaX := XFisica + Round(CuadroFisico / 5);
      ColaY := YFisica + Round(CuadroFisico / 5);
    end;
  end; //case
  with Plataforma do
  begin
    Brush.Style := bsSolid;
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    if Agente.Sexo = sxMacho then
      Brush.Color := clBlue
    else
      Brush.Color := clFuchsia;
    Ellipse(CabezaX - Round(CuadroFisico / 5),
            CabezaY - Round(CuadroFisico / 5),
            CabezaX + Round(CuadroFisico / 5),
            CabezaY + Round(CuadroFisico / 5));
    Ellipse(AbdomenX - Round(CuadroFisico / 3),
            AbdomenY - Round(CuadroFisico / 3),
            AbdomenX + Round(CuadroFisico / 3),
            AbdomenY + Round(CuadroFisico / 3));
    Brush.Color := Agente.Color;
    Ellipse(ColaX - Round(CuadroFisico / 3),
            ColaY - Round(CuadroFisico / 3),
            ColaX + Round(CuadroFisico / 3),
            ColaY + Round(CuadroFisico / 3));
    if Agente.Acarreados > 0 then //Marcar agente como portador de huevos
    begin
      Pen.Style := psSolid;
      Pen.Color := clWhite;
      Brush.Color := clYellow;
      Ellipse((XFisica + (CuadroFisico div 2)) - 1,
              (YFisica + (CuadroFisico div 2)) - 1,
              (XFisica + (CuadroFisico div 2)) + 1,
              (YFisica + (CuadroFisico div 2)) + 1);
    end;
  end;//with
end;

end.
