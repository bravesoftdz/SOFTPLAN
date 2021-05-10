program SOFTPLAN;

uses
  System.StartUpCopy,
  FMX.Forms,
  Softplan.View.Principal in 'View\Softplan.View.Principal.pas' {frmPrincipal},
  Softplan.View.Inicial in 'View\Softplan.View.Inicial.pas' {frmInicial},
  Softplan.Model.ConexaoBD in 'Model\Softplan.Model.ConexaoBD.pas',
  uEnums in 'Extras\uEnums.pas',
  Softplan.View.Dowload in 'View\Softplan.View.Dowload.pas' {frmDownload},
  uFuncoes in 'Extras\uFuncoes.pas',
  Softplan.Model.Log in 'Model\Softplan.Model.Log.pas',
  Softplan.Controller.Log in 'Controller\Softplan.Controller.Log.pas',
  Softplan.View.Logs in 'View\Softplan.View.Logs.pas' {frmLogs};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
