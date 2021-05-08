{-------------------------------------------------------------------------------
Tela: frmLogs                                                    Data:08/05/2021
Objetivo: Tela de manuten��o dos Logs

Dev.: S�rgio de Siqueira Silva

Data Altera��o: 09/05/2021
Dev.: S�rgio de Siqueira Silva
Altera��o:
-------------------------------------------------------------------------------}

unit Softplan.View.Logs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  FMX.Layouts, FMX.Objects, FMX.Edit, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.TabControl, uEnums, Softplan.Controller.Log, Softplan.Model.ConexaoBD,
  FMX.ListBox, FMX.DateTimeCtrls;

type
  TTipoBusca = (tPesqCodigo, tPesqURL, tPesqDataIni, tPesqDataFim, tPesqTodas);

  TfrmLogs = class(TForm)
    LayoutContainer: TLayout;
    LayoutAcoesPesquisa: TLayout;
    Label1: TLabel;
    RectangleEdtNomeFantasia: TRectangle;
    edtPesquisa: TEdit;
    btnPesquisar: TImage;
    LayoutAcoes: TLayout;
    imgExcluir: TImage;
    chkDataIni: TCheckBox;
    chkCodigo: TCheckBox;
    chkURL: TCheckBox;
    TabControl: TTabControl;
    TabListagemLogs: TTabItem;
    TabCadastroLogs: TTabItem;
    LayoutCadastroClientes: TLayout;
    Layout3: TLayout;
    btnCancelar: TImage;
    btnGravar: TImage;
    Grid: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    Label7: TLabel;
    lblCodigo: TLabel;
    StyleBook1: TStyleBook;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    lblDataInicial: TLabel;
    lblURL: TLabel;
    Image1: TImage;
    Label15: TLabel;
    btnAlterar: TRectangle;
    imgAlterar: TImage;
    Label14: TLabel;
    btnExcluir: TRectangle;
    lblDataFinal: TLabel;
    chkDataFim: TCheckBox;
    procedure edtPesquisaKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure chkCodigoClick(Sender: TObject);
    procedure chkURLClick(Sender: TObject);
    procedure chkDataIniClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkDataFimChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Show: Boolean;

    CtrlLog: TControlLog;
    Query: TFDQuery;
    Conexao: TConexao;

    procedure LimpaGrideDados();
    procedure AbrirURL(const URL: String);
    procedure Checks(const Opcao: Integer);
    procedure AlterarLog(const Codigo: Integer);
    function CodigoSelecionado: Int64;
  public
    { Public declarations }
    procedure LocalizarLog();
    procedure PopularGrid;
    procedure CarregaLogs(TipoBusca:TTipoBusca);
  end;

var
  frmLogs: TfrmLogs;

implementation

{$R *.fmx}

uses {$IFDEF MSWINDOWS}
     Winapi.ShellAPI, Winapi.Windows;
     {$ENDIF MSWINDOWS}

{Fun��o auxiliar para abrir browse padr�o do SO}
procedure TfrmLogs.AbrirURL(const URL: String);
begin
  {$IFDEF MSWINDOWS}
  ShellExecute(0, 'OPEN', PChar(URL), '', '', SW_SHOWNORMAL);
  {$ENDIF MSWINDOWS}
end;

{Alterar: Primeiro faz a carga dos labels do TabCadastroLog e deixa o objeto de
          controle em modo de altera��o}
procedure TfrmLogs.AlterarLog(const Codigo: Integer);
begin
  if not CtrlLog.Acao(tacCarregar, CodigoSelecionado) then exit;

  lblCodigo.Text      := CtrlLog.Log.Codigo.ToString;
  lblURL.Text         := CtrlLog.Log.URL;
  lblDataInicial.Text := DateTimeToStr(CtrlLog.Log.DataIni);
  lblDataFinal.Text   := DateTimeToStr(CtrlLog.Log.DataFim);
end;

{Pesquisar: Utiliza a procedure LocalizarLog se o edtPesquisa tiver conteudo
            caso contrario trazer todos os dados}
procedure TfrmLogs.edtPesquisaKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    if edtPesquisa.Text <> EmptyStr then
      LocalizarLog
    else
      CarregaLogs(tPesqTodas);
  end;
end;

{Cria��o dos objetos na memoria}
procedure TfrmLogs.FormCreate(Sender: TObject);
begin
  CtrlLog := TControlLog.Create;
  Conexao := TConexao.Create;
  Query   := TFDQuery.Create(nil);
  Query.Connection := Conexao.Conn;

  CarregaLogs(tPesqTodas);
end;

{Libera objetos da memoria}
procedure TfrmLogs.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CtrlLog);
  FreeAndNil(Conexao);
  FreeAndNil(Query);
end;

{Procedure de carga de dados dos LOGS para carga do GRID}
procedure TfrmLogs.CarregaLogs(TipoBusca:TTipoBusca);
var sSQL: String;
begin
  sSQL := 'SELECT * FROM LOGDOWNLOAD ';

  //Monstagem da instru��o SQL
  Query.Active := False;
  Query.SQL.Clear;

  //Tipo de Busca
  case TipoBusca of
    tPesqCodigo:    begin
                      sSQL := sSQL + 'WHERE CODIGO = :BUSCA';
                      Query.SQL.Add(sSQL);
                      try
                        Query.ParamByName('BUSCA').AsLargeInt := edtPesquisa.Text.ToInt64;
                      except
                        ShowMessage('C�digo inv�lido!');
                        exit;
                      end;
                    end;

    tPesqURL:       begin
                      sSQL := sSQL + 'WHERE UPPER(URL) LIKE :BUSCA';
                      Query.SQL.Add(sSQL);
                      Query.ParamByName('BUSCA').AsString := '%' + UpperCase(edtPesquisa.Text) + '%';
                    end;

    tPesqDataIni:   begin
                      sSQL := sSQL + 'WHERE DATAINICIO = :BUSCA';
                      Query.SQL.Add(sSQL);
                      try
                        Query.ParamByName('BUSCA').AsDate := StrToDate(edtPesquisa.Text);
                      except
                        ShowMessage('Data inv�lida!');
                        exit;
                      end;
                    end;

    tPesqDataFim:   begin
                      sSQL := sSQL + 'WHERE DATAFIM = :BUSCA';
                      Query.SQL.Add(sSQL);
                      try
                        Query.ParamByName('BUSCA').AsDate := StrToDate(edtPesquisa.Text);
                      except
                        ShowMessage('Data inv�lida!');
                        exit;
                      end;
                    end;

    tPesqTodas:     begin
                      Query.SQL.Add(sSQL);
                    end;

  end;

  Query.Active := True;
  Query.FetchAll;

  PopularGrid;
end;

{Fun��o auxiliar para controle dos chekbox}
procedure TfrmLogs.Checks(const Opcao: Integer);
begin
  case Opcao of
    1 : begin
          chkURL.IsChecked     := False;
          chkDataIni.IsChecked := False;
          chkDataFim.IsChecked := False;
        end;
    2 : begin
          chkCodigo.IsChecked  := False;
          chkDataIni.IsChecked := False;
          chkDataFim.IsChecked := False;
        end;
    3 : begin
          chkCodigo.IsChecked  := False;
          chkURL.IsChecked     := False;
          chkDataFim.IsChecked := False;
        end;
    4 : begin
          chkCodigo.IsChecked  := False;
          chkURL.IsChecked     := False;
          chkDataIni.IsChecked := False;
        end;
  end;
end;

procedure TfrmLogs.chkCodigoClick(Sender: TObject);
begin
  Checks(1);
end;

procedure TfrmLogs.chkURLClick(Sender: TObject);
begin
  Checks(2);
end;

procedure TfrmLogs.chkDataFimChange(Sender: TObject);
begin
  Checks(4);
end;

procedure TfrmLogs.chkDataIniClick(Sender: TObject);
begin
  Checks(3);
end;

{Fun��o auxiliar para abrir o link do download no browse padr�o do SO}
procedure TfrmLogs.lblURLClick(Sender: TObject);
begin
  AbrirURL(lblURL.Text);
end;

{Fun��o auxiliar s� pra pegar o c�digo selecionado no GRID}
function TfrmLogs.CodigoSelecionado: Int64;
begin
  try
    Result := Grid.Cells[0,Grid.Row].ToInt64;
  except
    raise Exception.Create('Selecione pelo menos um Log!');
  end;
end;

{Excluir: Primeiro utiliza a objeto de controle do log para localizar o Log
          depois confirma se o usuario deseja realmente excluir}
procedure TfrmLogs.btnExcluirClick(Sender: TObject);
begin
  CtrlLog.Acao(tacCarregar, CodigoSelecionado);
  if MessageDlg('Deseja realmente apagar o log '+ CtrlLog.Log.Codigo.ToString +' ?', System.UITypes.TMsgDlgType.mtConfirmation,
             [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNO], 0) = mrYes then
    CtrlLog.Acao(tacExcluir);

  CarregaLogs(tPesqTodas);
end;

{Pesquisar: Utiliza a procedure LocalizarLog se o edtPesquisa tiver conteudo
            caso contrario trazer todos os dados}
procedure TfrmLogs.btnPesquisarClick(Sender: TObject);
begin
  if edtPesquisa.Text <> EmptyStr then
    LocalizarLog
  else
    CarregaLogs(tPesqTodas);
end;

{Alterar: Acessa procedure AlterarLog para colocar o Log selecionado no Grid
          em altera��o}
procedure TfrmLogs.btnAlterarClick(Sender: TObject);
begin
  AlterarLog(CodigoSelecionado);
  TabControl.Next();
end;

{Cancelar: O cancelamento se da s� pelo fato de voltar o TabControl}
procedure TfrmLogs.btnCancelarClick(Sender: TObject);
begin
  TabControl.Previous();
end;

{Gravar: Grava��o dos dados atrav�s da classe de Controle Log}
procedure TfrmLogs.btnGravarClick(Sender: TObject);
begin
  CtrlLog.Log.Codigo  := lblCodigo.Text.ToInt64;
  CtrlLog.Log.URL     := lblURL.Text;
  CtrlLog.Log.DataIni := StrToDateTime(lblDataInicial.Text);
  CtrlLog.Log.DataFim := StrToDateTime(lblDataFinal.Text);

  CtrlLog.Acao(tacGravar);

  TabControl.Previous();
  LocalizarLog();
end;

{Limpeza do Grid}
procedure TfrmLogs.LimpaGrideDados;
begin
  Grid.RowCount := 0;
end;

{Procedure auxiliar para pesquisas que precisam usar os Checkbox}
procedure TfrmLogs.LocalizarLog;
Var i: Integer;
begin
  i := 0;

  if (chkCodigo.IsChecked) then
  begin
    Inc(i,1);
  end;

  if (chkURL.IsChecked) then
  begin
    Inc(i,1);
  end;

  if (chkDataIni.IsChecked) then
  begin
    Inc(i,1);
  end;

  if (chkDataFim.IsChecked) then
  begin
    Inc(i,1);
  end;

  if i > 1 then
  begin
    ShowMessage('Escolha somente uma op��o para pesquisa!');
  end;

  if (chkCodigo.IsChecked) then
  begin
    CarregaLogs(tPesqCodigo);
  end;

  if (chkURL.IsChecked) then
  begin
    CarregaLogs(tPesqURL);
  end;

  if (chkDataIni.IsChecked) then
  begin
    CarregaLogs(tPesqDataIni);
  end;

  if (chkDataFim.IsChecked) then
  begin
    CarregaLogs(tPesqDataFim);
  end;
end;

{Procedure para popular a GRID com os dados das pesquisas pela Procedure
 CarregaLogs}
procedure TfrmLogs.PopularGrid;
var iAux: Integer;
begin
  LimpaGrideDados;

  with Query do
  begin

    First;
    Grid.RowCount := RecordCount;
    for iAux := 0 to RecordCount - 1 do
    begin
      Grid.Cells[0,iAux] := FieldByName('CODIGO').AsString;
      Grid.Cells[1,iAux] := FieldByName('URL').AsString;

      if FieldByName('DATAINICIO').AsDateTime <> 0 then
        Grid.Cells[2,iAux] := DateTimeToStr(FieldByName('DATAINICIO').AsDateTime)
      else
        Grid.Cells[2,iAux] := EmptyStr;

      if FieldByName('DATAFIM').AsDateTime <> 0 then
        Grid.Cells[3,iAux] := DateTimeToStr(FieldByName('DATAFIM').AsDateTime)
      else
        Grid.Cells[3,iAux] := EmptyStr;

      Next;
    end;

  end;
end;

end.