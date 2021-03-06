{-------------------------------------------------------------------------------
Tela: frmDonwload                                                Data:08/05/2021
Objetivo: Tela para download e gera??o do LOG

Dev.: S?rgio de Siqueira Silva

Data Altera??o: 09/05/2021
Dev.: S?rgio de Siqueira Silva
Altera??o: Uso de uma nova classe TDownloadThread
-------------------------------------------------------------------------------}

unit Softplan.View.Dowload;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo, System.IOUtils, FMX.Edit,
  FMX.Objects, FMX.ScrollBox, uEnums, uFuncoes, DateUtils, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Softplan.Controller.Log,
  uThreadDownload;

type
  //Enum de op??es dos controles
  TControlesBotoes = (tIniciarDownload, tFimDownload);

  TfrmDownload = class(TForm)
    LayoutContainer: TLayout;
    LayoutAcoesPesquisa: TLayout;
    Label1: TLabel;
    RectangleEdtNomeFantasia: TRectangle;
    edtURL: TEdit;
    btnDownload: TRectangle;
    Image1: TImage;
    Label2: TLabel;
    LayoutAcoes: TLayout;
    LayoutProgresso: TLayout;
    ProgressBar: TProgressBar;
    LabelVelocidade: TLabel;
    btnCancelar: TRectangle;
    Image2: TImage;
    Label4: TLabel;
    Memo: TMemo;
    StyleBook1: TStyleBook;
    btnProgressoAtual: TRectangle;
    Image3: TImage;
    Label3: TLabel;
    procedure btnDownloadClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnProgressoAtualClick(Sender: TObject);
  private
    { Private declarations }
    FLog: TControlLog;
    FCodigoLog: Int64;

    procedure Controles(const Acao: TControlesBotoes);
    procedure DadosThread(const Sender: TObject; Tamanho: Int64; Processado: Int64; var Abort: Boolean);
  public
    { Public declarations }
    [volatile] FParar:  Boolean;
    [volatile] FFechar: Boolean;

    procedure Download(URL, PathDownload: String);
  end;

var
  frmDownload: TfrmDownload;

implementation

{$R *.fmx}

{ TfrmImportacao }

{Cancelar: Pede a confirma??o para abortar Thread "Download"}
procedure TfrmDownload.btnCancelarClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente abortar o download?',
                TMsgDlgType.mtWarning,
                [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrNo then exit;

  //Para a Thread "Download"
  FParar := True;

  //Informa no memo de resumo que o download foi abortado
  Memo.Lines.Add('Download abortado!');
	Application.ProcessMessages;

  Controles(tFimDownload);
end;

{Download: Confirma se tem algum link digitado, limpa o hist?rico do download
           anterior, seta o path para download, cria um novo log por fim start
           a Thread "Downlaod"}
procedure TfrmDownload.btnDownloadClick(Sender: TObject);
var PathDownload: String;
    URL: String;
begin
  if edtURL.Text = EmptyStr then
  begin
    ShowMessage('Preencha o link para download!');
    exit;
  end;
  URL := edtURL.Text;

  //Limpa o memo de resumo do download
  Memo.Lines.Clear;

  //Sele??o do path para o download
  SelectDirectory('Selecione uma pasta de destino','',PathDownload);
  PathDownload := PathDownload + '\' + GetURLFileName(edtURL.Text);

  //Inclus?o dos dados no objeto de controle do Log
  try
    FLog.Acao(tacIncluir);
    FCodigoLog       := FLog.Log.Codigo;
    FLog.Log.URL     := edtURL.Text;
    FLog.Log.DataIni := Now;
    FLog.Acao(tacGravar);
  except
    Controles(tFimDownload);
  end;

  //Inicializa a processo de download
  Controles(tIniciarDownload);
  FParar      := False;
  TThread.CreateAnonymousThread(procedure
  begin
    Download(URL,PathDownload);
  end).Start;
end;

{Exibir mensagem: Exibi progresso atual}
procedure TfrmDownload.btnProgressoAtualClick(Sender: TObject);
Var Progresso: Single;
begin
  Progresso := ProgressBar.Value / (ProgressBar.Max / 100);

  ShowMessage(Round(Progresso).ToString + '% concluido');
end;

{Controles Visuais: Bot?es e Edits}
procedure TfrmDownload.Controles(const Acao: TControlesBotoes);
begin
  case Acao of
    tIniciarDownload  :begin
                         btnDownload.Enabled       := False;
                         edtURL.Enabled            := False;

                         btnProgressoAtual.Enabled := True;
                         btnCancelar.Enabled       := True;
                       end;
    tFimDownload       :begin
                         btnDownload.Enabled       := True;
                         edtURL.Enabled            := True;

                         btnProgressoAtual.Enabled := False;
                         btnCancelar.Enabled       := False;
                       end;
  end;
end;

{Download: Procedure para download com dois parametros 1? URL do download 2?
           path aonde o arquivo ira ser salvo}
procedure TfrmDownload.Download(URL, PathDownload: String);
var
  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
  TamTotalDownload: Int64;
  Stream: TFileStream;
  Downloader: TDownloadThread;
  Abortar: Boolean;
begin
  //Na Memo de resumo informar o destino do download e a URL solicitada
  TThread.Synchronize(nil, procedure
  begin
    Memo.Lines.Add('Local do arquivo = ' + PathDownload);
    Memo.Lines.Add('Downloading ' + URL + ' ...');
    Application.ProcessMessages;
  end);

  try
    HTTPClient := THTTPClient.Create;

    if HTTPClient.CheckDownloadResume(URL) then
    begin
      Response := HTTPClient.Head(URL);

      //Total de Bytes do download
      TamTotalDownload := Response.ContentLength;

      //Stream que recebera o donwload
      try
        Stream   := TFileStream.Create(PathDownload, fmCreate);
      finally
        Stream.Free;
      end;

      //Estancia da Thread em suspens?o
      Downloader := TDownloadThread.Create(URL,PathDownload);
      Downloader.ThreadDados := DadosThread;

      TThread.Synchronize(nil, procedure
      begin
        ProgressBar.Max := TamTotalDownload;
        ProgressBar.Min := 0;
        ProgressBar.Value := 0;

        Controles(tIniciarDownload);
      end);

      //Inicia a Thread de Download
      Downloader.Start;

      //Monitoramento de solicita??es de Abortar e Fechar (Destroy)
      Abortar := False;
      while not Abortar and not FFechar do
      begin
        Abortar := True;
        Abortar := Abortar and Downloader.Finished;
      end;
    end else
    begin
      {Se HTTPClient n?o conseguir uma reposta positiva para o download
      informamos na memo de resumo essa informa??o}
      TThread.Synchronize(nil, procedure
      begin
        Memo.Lines.Add('Download indispon?vel!');
      end);
    end;

  finally
    HTTPClient.Free;

    TThread.Synchronize(nil, procedure
    begin
     //Verifica se completou o download para gravar no Log
     if ProgressBar.Max = ProgressBar.Value then
     begin
       FLog.Acao(tacCarregar,FCodigoLog);
       FLog.Acao(tacAlterar);
       FLog.Log.DataFim := Now;
       FLog.Acao(tacGravar);

       Memo.Lines.Add('Download conclu?do!');
     end;

     //Controle dos bot?es
     Controles(tFimDownload);
    end);
    FParar := True;
  end;

end;

{Processa o retorno de dados da Thread "Download" atualizado o progresso}
procedure TfrmDownload.DadosThread(const Sender: TObject; Tamanho, Processado: Int64; var Abort: Boolean);
var
  Cancelado: Boolean;
begin
  //Verifica uma solicita??o de fechar
  Cancelado := Abort or FFechar;

  if not Cancelado then
    TThread.Synchronize(nil,
      procedure
      begin
        Cancelado := not btnCancelar.Enabled;

        //Atualizar o ProgressBar
        ProgressBar.Value := Processado;
      end);
  Abort := Cancelado;
end;


{Create: Cria o objeto de controle do Log}
procedure TfrmDownload.FormCreate(Sender: TObject);
begin
  FLog := TControlLog.Create;
end;

//Destroy: Na destrui??o confirma o
procedure TfrmDownload.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if not btnDownload.Enabled then
  begin
    if MessageDlg('Deseja realmente abortar o download?',
                  TMsgDlgType.mtWarning,
                  [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrNo then Abort
  end;
  Application.ProcessMessages;

  //Finaliza a Thread "Download"
  FFechar := True;

  //Confirma se ainda existe o download
  if not btnDownload.Enabled then
  begin
    while not FParar do
    begin
      Application.ProcessMessages;
      Sleep(1);
    end;
  end;
end;

end.
