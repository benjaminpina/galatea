program EdSustGlt;

{$MODE Delphi}

uses
  Forms,
  Interfaces,
  EditorSustratos in 'EditorSustratos.pas' {frmEditorSustratos},
  EditarSimple in 'EditarSimple.pas' {frmEditarSimple},
  EditarMixto in 'EditarMixto.pas' {frmEditarMixto},
  AcercaEdSs in 'AcercaEdSs.pas' {frmAcerca};

{$IFDEF WINDOWS}{$R EdSustGlt.rc}{$ENDIF}

begin
  Application.Initialize;
  Application.Title := 'Substrate Editor';
  Application.CreateForm(TfrmEditorSustratos, frmEditorSustratos);
  Application.Run;
end.
