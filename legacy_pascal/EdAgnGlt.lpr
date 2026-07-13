program EdAgnGlt;

{$MODE Delphi}

uses
  Forms,
  Interfaces,
  EditorAgentes in 'EditorAgentes.pas' {frmEditorAgentes},
  NuevoJuegoAgentes in 'NuevoJuegoAgentes.pas' {frmNuevoJuegoAgentes},
  PropiedadesJuegoAgentes in 'PropiedadesJuegoAgentes.pas' {frmPropiedadesJuegoAgentes},
  Genetica in 'Genetica.pas' {frmGenetica},
  GeneralesAg in 'GeneralesAg.pas' {frmGeneralesAg},
  SeleccionaJuego in 'SeleccionaJuego.pas' {frmSeleccionaJuego},
  Prototipos in 'Prototipos.pas' {frmPrototipos},
  EditarPrototipo in 'EditarPrototipo.pas' {frmEditarPrototipo},
  MatricesInteraccion in 'MatricesInteraccion.pas' {frmMatricesInteraccion},
  LlenarCelda in 'LlenarCelda.pas' {frmLlenarCelda},
  Fisiologia in 'Fisiologia.pas' {frmFisiologia},
  Estadios in 'Estadios.pas' {frmEstadios},
  AcercaEdAg in 'AcercaEdAg.pas' {frmAcerca},
  EditarEstadio in 'EditarEstadio.pas' {frmEditarEstadio},
  Atractividad in 'Atractividad.pas' {frmAtractividad},
  EditorFormulas in 'EditorFormulas.pas' {frmEditorFormulas},
  MemoriaConducta in 'MemoriaConducta.pas' {frmMemoriaConducta},
  Morfologia in 'Morfologia.pas' {frmMorfologia},
  Asignacion in 'Asignacion.pas' {frmAsignacion},
  ExportarAgentes in 'ExportarAgentes.pas' {frmExportar},
  EditorNotas in 'EditorNotas.pas' {frmEditorNotas};

{$IFDEF WINDOWS}{$R EdAgnGlt.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.Title := 'Galatea Agent Editor';
  Application.CreateForm(TfrmEditorAgentes, frmEditorAgentes);
  Application.Run;
end.
