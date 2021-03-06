{-------------------------------------------------------------------------------
Classe: TDownloadThread                                          Data:12/03/2018
Objetivo: Fornecer uma Thread pronta para executar o download

Obs. Para lembrar! Tecnica usada no Embarcadero Conference lan?amento do Berlim

Dev.: S?rgio de Siqueira Silva

Data Altera??o:
Dev.:
Altera??o:
-------------------------------------------------------------------------------}
unit uThreadDownload;

interface

uses SysUtils, System.Classes, System.Net.URLClient, System.Net.HttpClient,
     System.Net.HttpClientComponent, System.Threading;

type
  TDownloadThreadDados = procedure(const Sender: TObject; BytesTotalDownload: Int64; BytesProcessado: Int64; var Abort: Boolean) of object;

  TDownloadThread = class(TThread)
  private
    FDados: TDownloadThreadDados;

  protected
    FURL: String;
    FArquivo: String;

    procedure ReceiveDataEvent(const Sender: TObject; BytesTotalDownload: Int64; BytesProcessado: Int64; var Abort: Boolean);
  public
    constructor Create(const URL, PathDownload: string);
    destructor Destroy; override;
    procedure Execute; override;

    property ThreadDados: TDownloadThreadDados write FDados;
  end;

implementation

{ TDownloadThread }

{Create: Informar os parametros URL e PathDownload obs. caminho completo}
constructor TDownloadThread.Create(const URL, PathDownload: string);
begin
  inherited Create(True);
  FURL := URL;
  FArquivo := PathDownload;
end;

destructor TDownloadThread.Destroy;
begin
  inherited;
end;

//Execute da Thread alocando o HTTP Client na processo
procedure TDownloadThread.Execute;
var
  Response:   IHTTPResponse;
  Stream:     TFileStream;
  HttpClient: THTTPClient;
begin
  inherited;
  HttpClient := THTTPClient.Create;
  try
    HttpClient.OnReceiveData := ReceiveDataEvent;
    Stream := TFileStream.Create(FArquivo, fmOpenWrite or fmShareDenyNone);
    try
      Response := HttpClient.Get(FURL, Stream);
    finally
      Stream.Free;
    end;
  finally
    HttpClient.Free;
  end;
end;

//Processa os dados recebidos
procedure TDownloadThread.ReceiveDataEvent(const Sender: TObject;
  BytesTotalDownload, BytesProcessado: Int64; var Abort: Boolean);
begin
  if Assigned(FDados) then
  begin
    FDados(Sender, BytesTotalDownload, BytesProcessado, Abort);
  end;
end;

end.
