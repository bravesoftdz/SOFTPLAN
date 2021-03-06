{-------------------------------------------------------------------------------
Classe: TConexao                                                 Data:12/08/2015
Objetivo: Fornecer uma conex?o com o BD

Obs. Aqui pode fornecer varias conex?es (Firedac, Unidac, etc.) nesse caso mudar
     os metodos internos (Exe. TConexao.ConnFD, TConexao.ConnORA e etc.)

Dev.: S?rgio de Siqueira Silva

Data Altera??o: 08/05/2021
Dev.: S?rgio de Siqueira Silva
Altera??o: Alterado para simplificar para prova da SOFTPLAN
-------------------------------------------------------------------------------}

unit Softplan.Model.ConexaoBD;

interface

uses FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
     FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
     FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
     FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Dapt, FireDAC.Phys.SQLite,
     SysUtils, UITypes, StrUtils;

type
  TConexao = class
  private
    FConexao: TFDConnection;
    DriverSQLite: TFDPhysSQLiteDriverLink;
    procedure Conectar();
  public
    constructor Create;
    destructor Destroy;
    property Conn: TFDConnection read FConexao;
  end;

implementation

{ TConexao }


procedure TConexao.Conectar;
const sSQL = 'CREATE TABLE LOGDOWNLOAD (CODIGO      NUMERIC (22)  NOT NULL, '
                                       +'URL        VARCHAR (600) NOT NULL, '
                                       +'DATAINICIO DATETIME      NOT NULL, '
                                       +'DATAFIM    DATETIME ); ';

Var Query: TFDQuery;
    CriarBD: Boolean;
    Path: String;
begin
  CriarBD := False;
  Path := ExtractFileDir(GetCurrentDir)+'\SOFTPLAN.DB';

  DriverSQLite := TFDPhysSQLiteDriverLink.Create(nil);

  //Verifica se o arquivo de dados .DB existe para criar
  if not FileExists(Path) then
    CriarBD := True;

  FConexao := TFDConnection.Create(nil);
  FConexao.DriverName := 'SQLite';
  FConexao.Params.Database := Path;
  FConexao.Params.Password := ' ';
  FConexao.LoginPrompt := False;
  FConexao.Connected := True;

  //Se n?o achou o .DB executa a instru??o CREATE TABLE
  if CriarBD then
    FConexao.ExecSQL(sSQL);
end;

constructor TConexao.Create;
begin
  Conectar;

  inherited
end;

destructor TConexao.Destroy;
begin
  Self.FConexao.Free;
  Self.DriverSQLite.Free;

  inherited
end;

end.
