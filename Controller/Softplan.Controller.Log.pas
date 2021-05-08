{-------------------------------------------------------------------------------
Classe: TControlLog                                              Data:08/05/2021
Objetivo: Classe de Controle da Model Log

Dev.: Sérgio de Siqueira Silva

Data Alteração:
Dev.:
Alteração:
-------------------------------------------------------------------------------}

unit Softplan.Controller.Log;

interface

uses System.SysUtils, System.Types, System.UITypes, System.Classes,
     System.Variants, FMX.Dialogs, uEnums, Softplan.Model.Log;

type
  TControlLog = class
  private
    objLog: TLog;
    FLog: TLog;
  public
    constructor Create;
    destructor Destroy;

    property Log: TLog read objLog write objLog;
    function Acao(Tipo: TAcao; ID: Integer = 0): Boolean;
  end;

implementation


{ TControlLog }

function TControlLog.Acao(Tipo: TAcao; ID: Integer = 0): Boolean;
begin
  Result := False;

  case Tipo of
    tacIncluir  :  Result := objLog.Acao(tacIncluir);
    tacCarregar :  Result := objLog.Acao(tacCarregar, ID);
    tacAlterar  :  Result := objLog.Acao(tacAlterar);
    tacGravar   :  Result := objLog.Acao(tacGravar);
    tacExcluir  :  Result := objLog.Acao(tacExcluir);
  end;
end;

constructor TControlLog.Create;
begin
  objLog := TLog.Create;
end;

destructor TControlLog.Destroy;
begin
  FreeAndNil(objLog);
end;

end.
