{-------------------------------------------------------------------------------
Tela: frmInicial                                                 Data:08/05/2021
Objetivo: Tela de apresenta��o

Dev.: S�rgio de Siqueira Silva

Data Altera��o:
Dev.:
Altera��o:
-------------------------------------------------------------------------------}

unit Softplan.View.Inicial;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.StdCtrls, FMX.ScrollBox,
  FMX.Memo;

type
  TfrmInicial = class(TForm)
    LayoutContainer: TLayout;
    LabelAppName: TLabel;
    LabelDev: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInicial: TfrmInicial;

implementation

{$R *.fmx}

end.
