{-------------------------------------------------------------------------------
Tela: frmPrincipal                                               Data:08/05/2021
Objetivo: Tela com o objetivo de ser um menu e container para as outras telas do
sistema

Dev.: S�rgio de Siqueira Silva

Data Altera��o: 09/05/2021
Dev.: S�rgio de Siqueira Silva
Altera��o: Altera��o na forma de abrir os forms dentro do LayoutMaster antes
           tinha uma procedure que carregava o layout atrav�s de um la�o FOR
-------------------------------------------------------------------------------}

unit Softplan.View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Ani, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TfrmPrincipal = class(TForm)
    LayoutMenu: TLayout;
    ImageFundo: TImage;
    LayoutMaster: TLayout;
    ImageMenuSuperior: TImage;
    RectangleMenuImportacao: TRectangle;
    RectangleSelecionado: TRectangle;
    FloatAnimation1: TFloatAnimation;
    RectangleMenuMusicas: TRectangle;
    Image1: TImage;
    Label2: TLabel;
    Label1: TLabel;
    Image2: TImage;
    RectangleMenuSair: TRectangle;
    Image4: TImage;
    Label4: TLabel;
    StyleBook1: TStyleBook;
    RectangleInicial: TRectangle;
    procedure FormShow(Sender: TObject);
    procedure RectangleMenuImportacaoClick(Sender: TObject);
    procedure RectangleMenuMusicasClick(Sender: TObject);
    procedure RectangleMenuSairClick(Sender: TObject);
    procedure RectangleInicialClick(Sender: TObject);
  private
    { Private declarations }
    procedure AnimaSelecaoMenu(Inicio,Fim:TPosition);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  FormAtivo : TForm;

implementation

{$R *.fmx}

uses Softplan.View.Inicial, Softplan.Model.ConexaoBD, Softplan.View.Dowload,
     Softplan.View.Logs;

//Procedure para exibi��o dos formul�rios da aplica��o no LayoutMaster
procedure CarregarForm(const FormClass: TComponentClass);
var LayoutPadrao : TComponent;
begin
  //Busca se o Form j� esta dentro do LayoutMaster
  if Assigned(FormAtivo) then
  begin
    if FormAtivo.ClassType = FormClass then
      exit
    else
    begin
      FormAtivo.DisposeOf;
      FormAtivo := nil;
    end;
  end;

  Application.CreateForm(FormClass, FormAtivo);

  // Busca pelo LayoutContainer no form a ser aberto
  LayoutPadrao := FormAtivo.FindComponent('LayoutContainer');

  if Assigned(LayoutPadrao) then
          frmPrincipal.LayoutMaster.AddObject(TLayout(LayoutPadrao));
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
Var Conn: TConexao;
begin
  Conn := TConexao.Create;

  CarregarForm(TfrmInicial);
end;

//Procedure para Anima��o do RectangleSelecionado
procedure TfrmPrincipal.AnimaSelecaoMenu(Inicio, Fim: TPosition);
begin
    FloatAnimation1.StartValue := Inicio.Y;
    FloatAnimation1.StopValue := Fim.Y;
    FloatAnimation1.Start;
end;

procedure TfrmPrincipal.RectangleMenuSairClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmPrincipal.RectangleMenuMusicasClick(Sender: TObject);
begin
  CarregarForm(TfrmLogs);
  AnimaSelecaoMenu(RectangleSelecionado.Position,RectangleMenuMusicas.Position);
end;

procedure TfrmPrincipal.RectangleInicialClick(Sender: TObject);
begin
  CarregarForm(TfrmInicial);
  AnimaSelecaoMenu(RectangleSelecionado.Position,RectangleInicial.Position);
end;

procedure TfrmPrincipal.RectangleMenuImportacaoClick(Sender: TObject);
begin
  CarregarForm(TfrmImportacao);
  AnimaSelecaoMenu(RectangleSelecionado.Position,RectangleMenuImportacao.Position);
end;

end.