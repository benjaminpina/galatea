program Galatea;

{$MODE Delphi}

{*******************************************************************************
Autor: Benjamin Piña Altamirano
*******************************************************************************}


uses
  Interfaces,
  Forms,
  Principal in 'Principal.pas' {frmPrincipal},
  OpcionesProyecto in 'OpcionesProyecto.pas' {frmOpcionesProyecto},
  SeleccionaEntorno in 'SeleccionaEntorno.pas' {frmSeleccionaEntorno},
  NuevoProyecto in 'NuevoProyecto.pas' {frmNuevoProyecto},
  Generales in 'Generales.pas' {frmGenerales},
  BuscarCarpeta in 'BuscarCarpeta.pas' {frmBuscarCarpeta};

{R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
