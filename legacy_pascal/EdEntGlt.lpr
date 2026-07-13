program EdEntGlt;

{$MODE Delphi}

uses
  Interfaces,
  Forms,
  EditorEntornos in 'EditorEntornos.pas' {frmEditorEntornos},
  PropiedadesEntorno in 'PropiedadesEntorno.pas' {frmPropiedadesEntorno},
  SeleccionarEscenario in 'SeleccionarEscenario.pas' {frmSeleccionarEscenario},
  NuevoEntorno in 'NuevoEntorno.pas' {frmNuevoEntorno},
  SeleccionarJuegoAgentes in 'SeleccionarJuegoAgentes.pas' {frmSeleccionarJuegoAgentes},
  SeleccionarPrototipo in 'SeleccionarPrototipo.pas' {frmSeleccionaPrototipo},
  ElementoDinamico in 'ElementoDinamico.pas' {frmElementoDinamico},
  EditarAgente in 'EditarAgente.pas' {frmEditarAgente},
  SeleccionaElemento in 'SeleccionaElemento.pas' {frmSeleccionarElemento},
  SitioOviposicion in 'SitioOviposicion.pas' {frmSitioOviposicion},
  CopiarNVeces in 'CopiarNVeces.pas' {frmCopiarNVeces},
  EditarPuesta in 'EditarPuesta.pas' {frmEditarPuesta},
  EditarHuevo in 'EditarHuevo.pas' {frmEditarHuevo};

{$IFDEF WINDOWS}{$R EdEntGlt.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.Title := 'Galatea Environment Editor';
  Application.CreateForm(TfrmEditorEntornos, frmEditorEntornos);
  Application.Run;
end.
