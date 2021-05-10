{-------------------------------------------------------------------------------
Unit Simples: uEnums                                             Data:08/05/2021
Objetivo: Fornecer Enums comums as classes do sistema

Dev.: Sérgio de Siqueira Silva

Data Alteração:
Dev.:
Alteração:
-------------------------------------------------------------------------------}

unit uEnums;

interface

type
  //Enum para ações de CRUD
  TAcao = (tacIncluir, tacCarregar, tacAlterar, tacGravar, tacExcluir);

  //Enum para o status das classes que precisam de CRUD
  TStatus = (tstNavegando, tstInclusao, tstAlteracao);

implementation

end.
