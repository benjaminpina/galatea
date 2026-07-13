program EdEsGlt;

{$MODE Delphi}

{*******************************************************************************
Editor de Escenarios de Galatea version 1.0
Programa para edición de escenarios utilizados en el Programa Simulador de
Estrategias reproductivas Galatea.
Versión: 1.0
Autor: Benjaminn Pina Altamiranoo
Verano del 2002
Derechos de autor en tramite
*******************************************************************************}



uses
  Forms,
  Interfaces,
  EditorEscenarios in 'EditorEscenarios.pas' {frmEditorEscenarios},
  NuevoEscenario in 'NuevoEscenario.pas' {frmNuevoEscenario},
  PropiedadesEscenario in 'PropiedadesEscenario.pas' {frmPropiedadesEscenario},
  SeleccionarMixto in 'SeleccionarMixto.pas' {frmSeleccionarMixto},
  VerSustrato in 'VerSustrato.pas' {frmVerSustrato},
  AcercaEdEs in 'AcercaEdEs.pas' {frmAcerca},
  SeleccionaJuego in 'SeleccionaJuego.pas' {frmSeleccionaJuego},
  PantallaEscenario in 'PantallaEscenario.pas' {frmPantallaEscenario};

{$IFDEF WINDOWS}{$R EdEsGlt.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.Title := 'Galatea Stage Editor';
  Application.CreateForm(TfrmEditorEscenarios, frmEditorEscenarios);
  Application.Run;
end.
