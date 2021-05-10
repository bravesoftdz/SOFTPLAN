{-------------------------------------------------------------------------------
Unit Simples: uEnums                                             Data:08/05/2021
Objetivo: Fornecer Enums comums as classes do sistema

Dev.: S�rgio de Siqueira Silva

Data Altera��o:
Dev.:
Altera��o:
-------------------------------------------------------------------------------}

unit uEnums;

interface

type
  //Enum para a��es de CRUD
  TAcao = (tacIncluir, tacCarregar, tacAlterar, tacGravar, tacExcluir);

  //Enum para o status das classes que precisam de CRUD
  TStatus = (tstNavegando, tstInclusao, tstAlteracao);

implementation

end.
