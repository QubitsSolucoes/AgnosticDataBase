{
  SQLConnection.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a conexão à Bancos de Dados via codigos livre de
             componentes de terceiros.
  Suporta 3 tipos de componentes do dbExpres, ZeOSLIB e FireDAC.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit ADBConnection;

interface

{ Carrega a Interface Padrão }
//{$DEFINE dbExpress} //Chaveador
//{$DEFINE DBXDevart} //Chaveador
//{$DEFINE ZeOS} //Chaveador
{$DEFINE FireDAC} //Chaveador

{$IFDEF dbExpress} //Condição
  {$DEFINE dbExpressLib} //Constante
  {$IFDEF DBXDevart} //Condição
    {$DEFINE DBXDevartLib} //Constante
  {$ENDIF}
{$ENDIF}
{$IFDEF ZeOS} //Condição
  {$DEFINE ZeOSLib} //Constante
{$ENDIF}
{$IFDEF FireDAC} //Condição
  {$DEFINE FireDACLib} //Constante
{$ENDIF}

uses
  System.SysUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.RegularExpressions,
  System.Math,

  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,

  Data.DB,
  Data.FMTBcd,
  Data.SqlExpr, //Expressões SQL dbExpress

  FMX.Dialogs,
  FMX.Forms,
  FMX.Grid, //Necessário para o método toGrid
  FMX.ListBox, //Necessário para os métodos toFillList, toListBox e toComboBox
  FMX.Types,

  { Runtime Live Bindings }
  Data.Bind.Components,
  Data.Bind.Grid,
  Data.Bind.DBScope,
  Datasnap.DBClient,
  Datasnap.Provider,

  { dbExpress }
  {$IFDEF dbExpressLib}
  Data.DBXSqlite,
  Data.DBXMySql,
  Data.DBXMSSQL,
  Data.DBXOracle,
  Data.DBXFirebird,
  Data.DBXInterBase,
    {$IFDEF DBXDevartLib}
    DBXDevartPostgreSQL,
    {$ENDIF}
  {$ENDIF}

  { ZeOSLib }
  {$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZConnection,
  ZAbstractTable,
  ZDbcConnection,
  ZClasses,
  ZDbcIntfs,
  ZTokenizer,
  ZCompatibility,
  ZGenericSqlToken,
  ZGenericSqlAnalyser,
  ZPlainDriver,
  ZURL,
  ZCollections,
  ZVariant,
  {$ENDIF}

  { FireDAC }
  {$IFDEF FireDACLib}
  FireDAC.DatS, //FireDAC Local Data Storage Class
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.ExprFuncs,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  {$ENDIF}

  { Ping de Conexão }
  IdBaseComponent,
  IdComponent,
  IdRawBase,
  IdRawClient,
  IdIcmpClient,

  { Classe para Criação de Matrizes Associativas }
  ArrayAssoc;

type
  {$IFDEF dbExpressLib}
  TConvertConnection = class(TSQLConnection);
  {$ENDIF}
  {$IFDEF ZeOSLib}
  TConvertConnection = class(TZConnection);
  {$ENDIF}
  {$IFDEF FireDACLib}
  TConvertConnection = class(TFDConnection);
  {$ENDIF}
  {$IFDEF dbExpressLib}
  TConvertQuery = class(TSQLQuery);
  {$ENDIF}
  {$IFDEF ZeOSLib}
  TConvertQuery = class(TZQuery);
  {$ENDIF}
  {$IFDEF FireDACLib}
  TConvertQuery = class(TFDQuery);
  {$ENDIF}

  TDriver = (SQLITE, MYSQL, FIREBIRD, INTERBASE, SQLSERVER, MSSQL, POSTGRES, ORACLE);
          //   OK     OK       OK                                     OK
{ Design Pattern Singleton }
  TSingleton<T: class, constructor> = class
  strict private
    class var SInstance : T;
  public
    class function GetInstance(): T;
    class procedure ReleaseInstance();
  end;

{ Classe Helper para o Componente TStringGrid }
  TStringGridRowDeletion = class helper for TStringGrid
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
  end;

{ Classe Helper para o Componente TGrid }
  TGridRowDeletion = class helper for TGrid
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
  end;

{ Classe TConnection Herdada de TObject }
  TADBConnection = class(TObject)
  private
    { Private declarations }
    class var FInstance: TADBConnection;
    class var FSQLInstance: TConvertConnection;
    class var FDriver: TDriver;
    class var FHost: String;
    class var FSchema: String;
    class var FDatabase: String;
    class var FUsername: String;
    class var FPassword: String;
    class var FPort: Integer;
    class procedure SetDriver(const Value: TDriver); static;
    class function GetConnection: TConvertConnection; static;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    class procedure SetParams;
    class property Driver: TDriver read FDriver write SetDriver default SQLITE;
    class property Host: String read FHost write FHost;
    class property Schema: String read FSchema write FSchema;
    class property Database: String read FDatabase write FDatabase;
    class property Username: String read FUsername write FUsername;
    class property Password: String read FPassword write FPassword;
    class property Port: Integer read FPort write FPort;
    class property Connection: TConvertConnection read GetConnection;
    class function GetInstance: TADBConnection;
  end;

  { Cria Instancia Singleton da Classe TADBConnection }
  TADBConnectionClass = TSingleton<TADBConnection>;

{ Classe TQuery Herdada de TConnection }
  TQuery = class(TADBConnection)
  private
    { Private declarations }
    Instance: TADBConnection;
    FQuery: TConvertQuery;
    procedure toFillList(AOwner: TComponent; IndexField, ValueField : String);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure toGrid(AOwner: TComponent);
    procedure toComboBox(AOwner: TComponent; IndexField, ValueField : String);
    procedure toListBox(AOwner: TComponent; IndexField, ValueField : String);
    property Query: TConvertQuery read FQuery write FQuery;
  end;

{ Record TQueryBuilder para Criação de Consultas para a Classe TQuery }
  TQueryBuilder = record
  private
    { Private declarations }
    function ExtractStringBetweenDelims(Input: String; Delim1, Delim2: String): String;
    function GenericQuery(Input: string; Mode: Boolean = False): TQuery;
  public
    { Public declarations }
    function View(Input: string; const Mode: Boolean = False): TQuery;
    function Exec(Input: string; const Mode: Boolean = True): TQuery;

    function Filter(Input, Column: String): String;

    function Fetch(ATable: string; Filter: string; Condition: string = '1')
      : TArray; overload;
    function Fetch(ATable: string; Filter: string): TArray; overload;
    function Fetch(ATable: string): TArray; overload;

    function Select(ATable: string; Filter: string; Condition: string = '1')
      : string; overload;
    function Select(ATable: string; Filter: string): string; overload;
    function Select(ATable: string): string; overload;

    function Insert(ATable: string; Data: TArray; Run: Boolean = False): string;
    function Replace(ATable: string; Data: TArray;
      Run: Boolean = False): string;

    function Update(ATable: string; Data: TArray; Condition: TArray;
      Run: Boolean = False): string; overload;
    function Update(ATable: string; Data: TArray; Run: Boolean = False)
      : string; overload;

    function Delete(ATable: string; Condition: TArray; Run: Boolean = False)
      : string; overload;
    function Delete(ATable: String; Run: Boolean = False): string; overload;
  end;

implementation

{ Singleton }

class function TSingleton<T>.GetInstance: T;
begin
  if not Assigned(Self.SInstance) then
    Self.SInstance := T.Create();
  Result := Self.SInstance;
end;

class procedure TSingleton<T>.ReleaseInstance;
begin
  if Assigned(Self.SInstance) then
    Self.SInstance.Free;
end;

{ TStringGridRowDeletion }

procedure TStringGridRowDeletion.Clear;
var
  I: Integer;
begin
  for I := 0 to RowCount -1 do
    RemoveRows(0, RowCount);
  ClearColumns;
end;

procedure TStringGridRowDeletion.RemoveRows(RowIndex, RCount: Integer);
var
  I, J: Integer;
begin
  for i := RCount to RowCount - 1 do
    for j := 0 to ColumnCount - 1 do
      Cells[J, I] := Cells[J, I+1];
  RowCount := RowCount -RCount;
end;

{ TGridRowDeletion }

procedure TGridRowDeletion.Clear;
begin
  TStringGrid(Self).Clear;
end;

procedure TGridRowDeletion.RemoveRows(RowIndex, RCount: Integer);
begin
  TStringGrid(Self).RemoveRows(RowIndex, RCount);
end;

{ TADBConnection }

constructor TADBConnection.Create;
begin
  inherited Create;
end;

destructor TADBConnection.Destroy;
begin
  if Assigned(FInstance) then FreeAndNil(FInstance);
  if Assigned(FSQLInstance) then FreeAndNil(FSQLInstance);
  inherited;
end;

class procedure TADBConnection.SetDriver(const Value: TDriver);
begin
  FDriver := Value;
end;

class procedure TADBConnection.SetParams;
begin
  {$IFDEF ZeOSLib}
  with TADBConnection.FInstance.FSQLInstance do
  begin
    case FDriver of
      SQLITE:
      begin
        {$IFDEF MSWINDOWS}
          LibraryLocation := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
        {$ENDIF}
        Protocol := 'sqlite';
        DataBase := FDatabase;
      end;
      MYSQL:
      begin
        {$IFDEF MSWINDOWS}
          LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
        {$ENDIF}
        HostName := FHost;
        Protocol := 'mysql';
        Port     := IfThen(FPort = 3306, 3306, FPort);
        Database := FDatabase;
        User     := FUsername;
        Password := FPassword;
        AutoCommit := False;
        Properties.Clear;
        Properties.Add('CLIENT_MULTI_STATEMENTS=1');
        Properties.Add('controls_cp=GET_ACP');
      end;
      FIREBIRD:
      begin
        {$IFDEF MSWINDOWS}
        LibraryLocation := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
        {$ENDIF}
        HostName := FHost;
        Protocol := 'firebird-3.0';
        Port     := IfThen(FPort = 3050, 3050, FPort);
        Database := FDatabase;
        User     := FUsername;
        Password := FPassword;
        AutoCommit := False;
        Properties.Clear;
        Properties.Add('CLIENT_MULTI_STATEMENTS=1');
        Properties.Add('controls_cp=GET_ACP');
      end;
      INTERBASE: // Falta Testar
      begin

      end;
      SQLSERVER: // Falta Testar
      begin

      end;
      MSSQL: // Falta Testar
      begin

      end;
      POSTGRES:
      begin
        {$IFDEF MSWINDOWS}
          LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
        {$ENDIF}
        HostName := FHost;
        Protocol := 'postgresql';
        Port     := IfThen(FPort = 5432, 5432, FPort);
        Database := FDatabase;
        Catalog  := FSchema;
        User     := FUsername;
        Password := FPassword;
        AutoCommit := False;
        Properties.Clear;
        Properties.Add('CLIENT_MULTI_STATEMENTS=1');
        Properties.Add('controls_cp=GET_ACP');
      end;
      ORACLE: // Falta Testar
      begin

      end;
    end;
  end;
  {$ENDIF}
  {$IFDEF FireDACLib}
  with TADBConnection.FInstance.FSQLInstance do
  begin
    case FDriver of
      SQLITE:
        begin
          {$IFDEF MSWINDOWS}
          TFDPhysSQLiteDriverLink.Create(nil).VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
          {$ENDIF}
          ConnectionName := 'DBSQLite';
          DriverName := 'SQLite';
          Connected := False;
          with ResourceOptions as TFDTopResourceOptions do begin
            KeepConnection := True;
            Persistent := True;
            SilentMode := True;
          end;
          with FetchOptions as TFDFetchOptions do begin
            RecordCountMode := cmTotal;
          end;
          LoginPrompt := False;
          with Params as TFDPhysSQLiteConnectionDefParams do begin
            BeginUpdate();
            Clear;
            DriverID := 'SQLite';
            Database := FDatabase;
            EndUpdate();
          end;
        end;
      MYSQL:
        begin
          {$IFDEF MSWINDOWS}
          TFDPhysMySQLDriverLink.Create(nil).VendorLib := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
          {$ENDIF}
          ConnectionName := 'DBMySQL';
          DriverName := 'MySQL';
          Connected := False;
          with ResourceOptions as TFDTopResourceOptions do begin
            KeepConnection := True;
            Persistent := True;
            SilentMode := True;
          end;
          with FetchOptions as TFDFetchOptions do begin
            RecordCountMode := cmTotal;
          end;
          LoginPrompt := False;
          with Params as TFDPhysMySQLConnectionDefParams do begin
            BeginUpdate();
            Clear;
            DriverID := 'MySQL';
            Server := FHost;
            Port :=  IfThen(FPort = 3306, 3306, FPort);
            Database := FDatabase;
            UserName := FUsername;
            Password := FPassword;
            Compress := True;
            EndUpdate();
          end;
          ExecSQL('SET SQL_MODE=ANSI_QUOTES');
        end;
      FIREBIRD:
        begin
          {$IFDEF MSWINDOWS}
          TFDPhysFBDriverLink.Create(nil).VendorLib := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
          {$ENDIF}
          ConnectionName := 'DBFirebird';
          DriverName := 'FB';
          Connected := False;
          with ResourceOptions as TFDTopResourceOptions do begin
            KeepConnection := True;
            Persistent := True;
            SilentMode := True;
            DirectExecute := True;
          end;
          with FetchOptions as TFDFetchOptions do begin
            RecordCountMode := cmTotal;
          end;
          LoginPrompt := False;
          with Params as TFDPhysFBConnectionDefParams do begin
            BeginUpdate();
            Clear;
            DriverID := 'FB';
            Server := FHost;
            Port := IfThen(FPort = 3050, 3050, FPort);
            Database := FDatabase;
            UserName := FUsername;
            Password := FPassword;
            EndUpdate();
          end;
          Params.Values['Protocol'] := 'ipTCPIP';
        end;
      INTERBASE: // Falta Testar
        begin
          ConnectionName := 'DBInterbase';

        end;
      SQLSERVER: // Falta Testar
        begin
          ConnectionName := 'DBSQLServer';

        end;
      MSSQL: // Falta Testar
        begin
          ConnectionName := 'DBMSSQL';

        end;
      POSTGRES:
        begin
          {$IFDEF MSWINDOWS}
          TFDPhysPgDriverLink.Create(nil).VendorLib := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
          {$ENDIF}
          ConnectionName := 'DBPostgreSQL';
          DriverName := 'PG';
          Connected := False;
          with ResourceOptions as TFDTopResourceOptions do
          begin
            KeepConnection := True;
            Persistent := True;
            SilentMode := True;
          end;
          with FetchOptions as TFDFetchOptions do
          begin
            RecordCountMode := cmTotal;
          end;
          LoginPrompt := False;
          with Params as TFDPhysPGConnectionDefParams do begin
            BeginUpdate();
            Clear;
            DriverID := 'PG';
            Server := FHost;
            Port := IfThen(FPort = 5432, 5432, FPort);
            Database := FDatabase;
            UserName := FUsername;
            Password := FPassword;
            MetaDefSchema := FSchema;
            EndUpdate();
          end;
          ExecSQL('SET search_path TO E''' + FSchema + ''', E''public'';');
        end;
      ORACLE: // Falta Testar
        begin
          ConnectionName := 'DBOracle';

        end;
    end;
  end;
  {$ENDIF}
  {$IFDEF dbExpressLib}
  with TADBConnection.FInstance.FSQLInstance do
  begin
    case FDriver of
      SQLITE:
        begin
          ConnectionName := 'DBSQLite';
          DriverName := 'SQLite';
          KeepConnection := True;
          LoginPrompt := False;
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['ForceCreateDatabase'] := 'False';
          Params.Values['FailIfMissing'] := 'False';
          Params.Values['Database'] := FDatabase;
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
      MYSQL:
        begin
          ConnectionName := 'DBMySQL';
          DriverName := 'MySQL';
          KeepConnection := True;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverMYSQL';
          LibraryName := 'dbxmys.dll';
          VendorLib := 'LIBMYSQL.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['HostName'] := FHost;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 3306, 3306, FPort));
          Params.Values['Database'] := FDatabase;
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['ForceCreateDatabase'] := 'False';
          Params.Values['FailIfMissing'] := 'False';
          Params.Values['MaxBlobSize'] := '-1';
          Params.Values['BlobSize'] := '-1';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['Compressed'] := 'True';
          Params.Values['Encrypted'] := 'False';
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
      FIREBIRD:
        begin
          ConnectionName := 'DBFirebird';
          DriverName := 'Firebird';
          KeepConnection := True;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverINTERBASE';
          LibraryName := 'dbxfb.dll';
          VendorLib := 'fbclient.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          if ( (FHost = 'localhost') or (FHost = '127.0.0.1') ) then
            Params.Values['Database'] := FDatabase
          else
            Params.Values['Database'] := FHost + ':' + FDatabase;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 3050, 3050, FPort));
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['Role'] := 'RoleName';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['IsolationLevel'] := 'ReadCommitted';
          Params.Values['ServerCharSet'] := 'UTF8';
          Params.Values['SQLDialect'] := '3';
          Params.Values['BlobSize'] := '-1';
          Params.Values['CommitRetain'] := 'False';
          Params.Values['WaitOnLocks'] := 'True';
          Params.Values['TrimChar'] := 'False';
          Params.Values['RoleName'] := 'RoleName';
        end;
      INTERBASE: // Falta Testar
        begin
          ConnectionName := 'DBInterbase';
          DriverName := 'InterBase';
          KeepConnection := True;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverINTERBASE';
          LibraryName := 'dbxint.dll';
          VendorLib := 'GDS32.DLL';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          if FHost = 'localhost' then
            Params.Values['Database'] := FDatabase
          else
            Params.Values['Database'] := FHost + ':' + FDatabase;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 3050, 3050, FPort));
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['Role'] := 'RoleName';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['IsolationLevel'] := 'ReadCommitted';
          Params.Values['ServerCharSet'] := 'ISO8859_1';
          Params.Values['SQLDialect'] := '3';
          Params.Values['BlobSize'] := '-1';
          Params.Values['CommitRetain'] := 'False';
          Params.Values['WaitOnLocks'] := 'True';
          Params.Values['TrimChar'] := 'False';
          Params.Values['RoleName'] := 'RoleName';
        end;
      SQLSERVER: // Falta Testar
        begin
          ConnectionName := 'DBSQLServer';
          DriverName := 'SQLServer';
          KeepConnection := False;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverSQLServer';
          VendorLib := 'sqloledb.dll';
          LibraryName := 'dbexpsda.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['HostName'] := FHost;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 1433, 1433, FPort));
          Params.Values['Database'] := FDatabase;
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['ForceCreateDatabase'] := 'False';
          Params.Values['FailIfMissing'] := 'False';
          Params.Values['MaxBlobSize'] := '-1';
          Params.Values['BlobSize'] := '-1';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['Compressed'] := 'True';
          Params.Values['Encrypted'] := 'False';
          Params.Values['Max_DBProcesses'] := '50';
          Params.Values['SchemaOverride'] := '%.dbo';
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
      MSSQL: // Falta Testar
        begin
          ConnectionName := 'DBMSSQL';
          DriverName := 'MSSQL';
          KeepConnection := False;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverMSSQL';
          VendorLib := 'sqlncli10.dll';
          LibraryName := 'dbxmss.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['HostName'] := FHost;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 1433, 1433, FPort));
          Params.Values['Database'] := FDatabase;
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['ForceCreateDatabase'] := 'False';
          Params.Values['FailIfMissing'] := 'False';
          Params.Values['MaxBlobSize'] := '-1';
          Params.Values['BlobSize'] := '-1';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['Compressed'] := 'True';
          Params.Values['Encrypted'] := 'False';
          Params.Values['Max_DBProcesses'] := '50';
          Params.Values['SchemaOverride'] := '%.dbo';
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
      POSTGRES:
        begin
          ConnectionName := 'DBDevartPostgreSQL';
          DriverName := 'DevartPostgreSQL';
          KeepConnection := False;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverPostgreSQL';
          LibraryName := 'dbexppgsql40.dll';
          VendorLib := 'dbexppgsql40.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['HostName'] := FHost;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 5432, 5432, FPort));
          Params.Values['Database'] := FDatabase;
          Params.Values['SchemaName'] := FSchema;
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['SchemaName'] := FSchema;
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
      ORACLE: // Falta Testar
        begin
          ConnectionName := 'DBOracle';
          DriverName := 'Oracle';
          KeepConnection := False;
          LoginPrompt := False;
          GetDriverFunc := 'getSQLDriverORACLE';
          VendorLib := 'oci.dll';
          LibraryName := 'dbexpora.dll';
          Params.BeginUpdate();
          Params.Clear();
          Params.Values['ColumnMetadataSupported'] := 'False';
          Params.Values['LoginPrompt'] := 'False';
          Params.Values['HostName'] := FHost;
          Params.Values['Port'] :=
            IntToStr(IfThen(FPort = 1521, 1521, FPort));
          Params.Values['Database'] := FDatabase;
          Params.Values['User_Name'] := FUsername;
          Params.Values['Password'] := FPassword;
          Params.Values['Port'] := IntToStr(FPort);
          Params.Values['BlobSize'] := '1';
          Params.Values['LocaleCode'] := '0000';
          Params.Values['OS Authentification'] := 'False';
          Params.Values['Multiple Transaction'] := 'False';
          Params.Values['Trim Char'] := 'False';
          Params.Values['Oracle TransIsolation'] := 'ReadCommited';
          Params.EndUpdate();
          ParamsLoaded := True;
        end;
    end;
  end;
  {$ENDIF}
end;

class function TADBConnection.GetConnection: TConvertConnection;
begin
  Result := FSQLInstance;
end;

class function TADBConnection.GetInstance: TADBConnection;
begin
  try
    if not Assigned(FInstance) then
    begin
      FInstance := TADBConnection.Create;
      TADBConnection.FInstance.FSQLInstance := TConvertConnection.Create(nil);
      TADBConnection.SetParams;
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
  Result := FInstance;
end;

{ TQuery }

constructor TQuery.Create;
begin
  Instance := TADBConnection.Create;
  FQuery := TConvertQuery.Create(nil);
  {$IFDEF dbExpressLib}
  FQuery.SQLConnection := Instance.GetInstance.Connection;
  {$ENDIF}

  {$IFDEF FireDACLib}
  FQuery.Connection := Instance.GetInstance.Connection;
  {$ENDIF}

  {$IFDEF ZeOSLib}
  FQuery.Connection := Instance.GetInstance.Connection;
  {$ENDIF}
  Instance.FreeInstance;
end;

procedure TQuery.toFillList(AOwner: TComponent; IndexField, ValueField : String);
var
  DataSetProvider : TDataSetProvider;
  ClientDataSet : TClientDataSet;
  BindSourceDB : TBindSourceDB;
  BindingsList : TBindingsList;
  LinkListControlToField : TLinkListControlToField;
  LinkPropertyToFieldIndex : TLinkPropertyToField;
begin

  try

    Application.ProcessMessages;
    if (AOwner is TComboBox) and (TComboBox(AOwner) <> nil) and (TComboBox(AOwner).Items.Count > 0) then
      TComboBox(AOwner).Items.Clear
    else if (AOwner is TListBox) and (TListBox(AOwner) <> nil) and (TListBox(AOwner).Items.Count > 0) then
      TListBox(AOwner).Clear;

    {$WARNINGS OFF}
    {$HINTS OFF}

    DataSetProvider := TDataSetProvider.Create(FQuery);
    ClientDataSet := TClientDataSet.Create(DataSetProvider);
    BindSourceDB := TBindSourceDB.Create(ClientDataSet);
    BindingsList := TBindingsList.Create(BindSourceDB);
    LinkListControlToField := TLinkListControlToField.Create(BindSourceDB);
    LinkPropertyToFieldIndex := TLinkPropertyToField.Create(BindSourceDB);

    DataSetProvider.DataSet := FQuery;
    ClientDataSet.SetProvider(DataSetProvider);

    BindSourceDB.DataSet := ClientDataSet;
    BindSourceDB.DataSet.Active := True;

    BindingsList.PromptDeleteUnused := True;

    LinkListControlToField.Control := AOwner;
    LinkListControlToField.DataSource := BindSourceDB;
    LinkListControlToField.FieldName := ValueField;
    LinkListControlToField.AutoBufferCount := False;
    LinkListControlToField.Active := True;

    LinkPropertyToFieldIndex.Component := AOwner;
    LinkPropertyToFieldIndex.DataSource := BindSourceDB;
    LinkPropertyToFieldIndex.ComponentProperty := 'Index';
    LinkPropertyToFieldIndex.FieldName := IndexField;
    LinkPropertyToFieldIndex.Active := True;

    {$HINTS ON}
    {$WARNINGS ON}

  except

  end;

end;

procedure TQuery.toComboBox(AOwner: TComponent; IndexField, ValueField : String);
begin
  toFillList(AOwner, IndexField, ValueField);
end;

procedure TQuery.toListBox(AOwner: TComponent; IndexField, ValueField : String);
begin
  toFillList(AOwner, IndexField, ValueField);
end;

procedure TQuery.toGrid(AOwner: TComponent);
var
  DataSetProvider : TDataSetProvider;
  ClientDataSet : TClientDataSet;
  BindSourceDB : TBindSourceDB;
  BindingsList : TBindingsList;
  LinkGridToDataSource : TLinkGridToDataSource;
begin

  try

    Application.ProcessMessages;
    if (AOwner is TGrid) and (TGrid(AOwner) <> nil) and (TGrid(AOwner).VisibleColumnCount > 0) then
      TGrid(AOwner).Clear
    else if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) and (TStringGrid(AOwner).VisibleColumnCount > 0) then
      TStringGrid(AOwner).Clear;

    {$WARNINGS OFF}
    {$HINTS OFF}

    DataSetProvider := TDataSetProvider.Create(FQuery);
    ClientDataSet := TClientDataSet.Create(DataSetProvider);
    BindSourceDB := TBindSourceDB.Create(ClientDataSet);
    BindingsList := TBindingsList.Create(BindSourceDB);
    LinkGridToDataSource := TLinkGridToDataSource.Create(BindSourceDB);

    DataSetProvider.DataSet := FQuery;
    ClientDataSet.SetProvider(DataSetProvider);

    BindSourceDB.DataSet := ClientDataSet;
    BindSourceDB.DataSet.Active := True;

    BindingsList.PromptDeleteUnused := True;

    LinkGridToDataSource.GridControl := AOwner;
    LinkGridToDataSource.DataSource := BindSourceDB;
    LinkGridToDataSource.AutoBufferCount := False;
    LinkGridToDataSource.Active := True;

    {$HINTS ON}
    {$WARNINGS ON}

  except

  end;

end;

destructor TQuery.Destroy;
begin
  inherited;
end;

{ TQueryBuilder }

function TQueryBuilder.ExtractStringBetweenDelims(Input: String;
  Delim1, Delim2: String): String;
var
  Pattern: String;
  RegEx: TRegEx;
  Match: TMatch;
begin
  Result := '';
  Pattern := Format('%s(.*?)%s', [Delim1, Delim2]);
  RegEx := TRegEx.Create(Pattern);
  Match := RegEx.Match(Input);
  if Match.Success and (Match.Groups.Count > 1) then
    Result := Match.Groups[1].Value;
end;

function TQueryBuilder.GenericQuery(Input: string; Mode: Boolean = False): TQuery;
var
  SQL: TQuery;
begin
  SQL := TQuery.Create;
  SQL.Query.Close;
  SQL.Query.SQL.Clear;
  SQL.Query.SQL.Text := Input;
  if not Mode then
    SQL.Query.Open
  else
    SQL.Query.ExecSQL;
  Result := SQL;
end;

function TQueryBuilder.Filter(Input, Column: String): String;
begin
  Result := ExtractStringBetweenDelims(Input, '<' + Column + '>',
    '</' + Column + '>');
end;

function TQueryBuilder.View(Input: string; const Mode: Boolean = False): TQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

function TQueryBuilder.Exec(Input: string; const Mode: Boolean = True): TQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

function TQueryBuilder.Fetch(ATable: string; Filter: string;
  Condition: string = '1'): TArray;
var
  Query: TQueryBuilder;
  SQL: TQuery;
  Matriz, Return: TArray;
  I: Integer;
begin
  if ((Condition = '') or (Condition = '1')) then
    Condition := ';'
  else
    Condition := ' WHERE ' + Condition + ';';
  SQL := Query.View('SELECT ' + Filter + ' FROM ' + ATable + Condition);
  if (SQL.Query.RecordCount > 0) then
  begin
    Return := TArray.Create;
    Return.Clear;
    while not SQL.Query.Eof do
    begin // Linhas
      Matriz := TArray.Create;
      for I := 0 to SQL.Query.FieldCount - 1 do
      begin // Colunas
        Matriz[SQL.Query.Fields[I].DisplayName] := '<' + SQL.Query.Fields[I]
          .DisplayName + '>' + SQL.Query.Fields[I].Text + '</' +
          SQL.Query.Fields[I].DisplayName + '>';
      end;
      Return.Add(Matriz.ToString);
      SQL.Query.Next;
    end;
    Result := Return;
  end
  else
  begin
    Return := TArray.Create;
    Return.Clear;
    Return.Add('0');
    Result := Return;
  end;
end;

function TQueryBuilder.Fetch(ATable: string; Filter: string): TArray;
var
  Query: TQueryBuilder;
  SQL: TQuery;
  Matriz, Return: TArray;
  I: Integer;
begin
  SQL := Query.View('SELECT ' + Filter + ' FROM ' + ATable + ';');
  if (SQL.Query.RecordCount > 0) then
  begin
    Return := TArray.Create;
    Return.Clear;
    while not SQL.Query.Eof do
    begin // Linhas
      Matriz := TArray.Create;
      for I := 0 to SQL.Query.FieldCount - 1 do
      begin // Colunas
        Matriz[SQL.Query.Fields[I].DisplayName] := '<' + SQL.Query.Fields[I]
          .DisplayName + '>' + SQL.Query.Fields[I].Text + '</' +
          SQL.Query.Fields[I].DisplayName + '>';
      end;
      Return.Add(Matriz.ToString);
      SQL.Query.Next;
    end;
    Result := Return;
  end
  else
  begin
    Return := TArray.Create;
    Return.Clear;
    Return.Add('0');
    Result := Return;
  end;
end;

function TQueryBuilder.Fetch(ATable: string): TArray;
var
  Query: TQueryBuilder;
  SQL: TQuery;
  Matriz, Return: TArray;
  I: Integer;
begin
  SQL := Query.View('SELECT * FROM ' + ATable + ';');
  if (SQL.Query.RecordCount > 0) then
  begin
    Return := TArray.Create;
    Return.Clear;
    while not SQL.Query.Eof do
    begin // Linhas
      Matriz := TArray.Create;
      for I := 0 to SQL.Query.FieldCount - 1 do
      begin // Colunas
        Matriz[SQL.Query.Fields[I].DisplayName] := '<' + SQL.Query.Fields[I]
          .DisplayName + '>' + SQL.Query.Fields[I].Text + '</' +
          SQL.Query.Fields[I].DisplayName + '>';
      end;
      Return.Add(Matriz.ToString);
      SQL.Query.Next;
    end;
    Result := Return;
  end
  else
  begin
    Return := TArray.Create;
    Return.Clear;
    Return.Add('0');
    Result := Return;
  end;
end;

function TQueryBuilder.Select(ATable: string): String;
begin
  Result := 'SELECT * FROM ' + ATable + ';';
end;

function TQueryBuilder.Select(ATable: string; Filter: string): String;
begin
  Result := 'SELECT ' + Filter + ' FROM ' + ATable + ';';
end;

function TQueryBuilder.Select(ATable: string; Filter: string;
  Condition: string = '1'): String;
begin
  if ((Condition = '') or (Condition = '1')) then
    Condition := ';'
  else
    Condition := ' WHERE ' + Condition + ';';
  Result := 'SELECT ' + Filter + ' FROM ' + ATable + Condition;
end;

function TQueryBuilder.Insert(ATable: string; Data: TArray;
  Run: Boolean = False): String;
var
  DbNames: String;
  DbValues: String;
  I: Integer;
  Value: String;
  Sentencia: String;
  Query: TQueryBuilder;
begin
  DbNames := '';
  DbValues := '';
  for I := 0 to Data.Count - 1 do
  begin
    Value := Data.ValuesAtIndex[I];
    if Value = 'NOW()' then
      DbValues := DbValues + ',' + Value
    else
      DbValues := DbValues + ',''' + Value + '''';
    DbNames := DbNames + ',' + Data.Names[I] + '';
  end;
  System.Delete(DbNames, 1, 1);
  System.Delete(DbValues, 1, 1);
  Sentencia := 'INSERT INTO ' + ATable + ' (' + DbNames + ') VALUES (' +
    DbValues + ');';
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TQueryBuilder.Update(ATable: String; Data: TArray; Condition: TArray;
  Run: Boolean = False): String;
var
  DbValues: String;
  DbFilters: String;
  Value: String;
  I: Integer;
  Sentencia: String;
  Query: TQueryBuilder;
begin
  DbValues := '';
  for I := 0 to Data.Count - 1 do
  begin
    Value := Data.ValuesAtIndex[I];
    if Value = 'NOW()' then
      DbValues := DbValues + ', ' + Value
    else
      DbValues := DbValues + ', ' + Data.Names[I] + ' = ' + '''' + Value + '''';
  end;
  System.Delete(DbValues, 1, 1);
  if Condition.Count > 0 then
    DbFilters := ' WHERE ' + Condition.ToFilter + ';'
  else
    DbFilters := ';';
  Sentencia := 'UPDATE ' + ATable + ' SET ' + DbValues + DbFilters;
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TQueryBuilder.Update(ATable: String; Data: TArray;
  Run: Boolean = False): String;
var
  DbValues: String;
  Value: String;
  I: Integer;
  Sentencia: String;
  Query: TQueryBuilder;
begin
  DbValues := '';
  for I := 0 to Data.Count - 1 do
  begin
    Value := Data.ValuesAtIndex[I];
    if Value = 'NOW()' then
      DbValues := DbValues + ',' + Value
    else
      DbValues := DbValues + ',' + Data.Names[I] + ' = ' + '''' + Value + '''';
  end;
  System.Delete(DbValues, 1, 1);
  Sentencia := 'UPDATE ' + ATable + ' SET ' + DbValues;
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TQueryBuilder.Delete(ATable: String; Condition: TArray;
  Run: Boolean = False): String;
var
  Sentencia: String;
  DbFilters: String;
  Query: TQueryBuilder;
begin
  if Condition.Count > 0 then
    DbFilters := ' WHERE ' + Condition.ToFilter + ';'
  else
    DbFilters := ';';
  Sentencia := 'DELETE FROM ' + ATable + DbFilters;
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TQueryBuilder.Delete(ATable: String; Run: Boolean = False): string;
var
  Sentencia: String;
  Query: TQueryBuilder;
begin
  Sentencia := 'DELETE FROM ' + ATable + ';';
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TQueryBuilder.Replace(ATable: String; Data: TArray;
  Run: Boolean = False): String;
var
  DbNames: string;
  DbValues: string;
  Value: string;
  I: Integer;
  Sentencia: String;
  Query: TQueryBuilder;
begin
  DbNames := '';
  DbValues := '';
  for I := 0 to Data.Count - 1 do
  begin
    Value := Data.ValuesAtIndex[I];
    if Value = 'NOW()' then
      DbValues := DbValues + ',' + Value
    else
      DbValues := DbValues + ',''' + Value + '''';
    DbNames := DbNames + ',' + Data.Names[I] + '';
  end;
  System.Delete(DbNames, 1, 1);
  System.Delete(DbValues, 1, 1);
  Sentencia := 'REPLACE INTO ' + ATable + ' (' + DbNames + ') VALUES (' +
    DbValues + ')';
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

initialization

finalization
  TADBConnectionClass.ReleaseInstance();

end.