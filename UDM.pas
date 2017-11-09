unit UDM;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.FMTBcd, Data.DB,
  System.RegularExpressions, Data.SqlExpr, System.IOUtils, ArrayAssoc,
  FMX.Dialogs;

type
  TDM = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

{$R *.dfm}

implementation

procedure TDM.DataModuleCreate(Sender: TObject);
// var
// TblCat, TblCli, TblCfg, TblSinc, TblUser, TblEmp, TblProd, TblVen, TblIVen: String;
// DB: TConnection;
begin
  // if DB.Driver = SQLITE then
  // begin
  // DB.FDriver := SQLITE;
  // DB.FPath :=
  // {$IFDEF MSWINDOWS}
  // ExtractFilePath(ParamStr(0)) + 'db.db';
  // {$ELSE}
  // TPath.Combine(TPath.GetDocumentsPath, 'db.db');
  // {$ENDIF}
  // DB := TConnection.GetInstance();
  // try
  // if not FileExists(DB.FSQLConnection.Params.Values['Database']) then
  // begin
  // try
  // { Tabelas do SIMPOS }
  // TblSinc := 'CREATE TABLE IF NOT EXISTS sincronizacao ( ' +
  // '  id TEXT(32) NOT NULL, ' + '  data_sincronizacao TEXT(10), ' +
  // '  hora_sincronizacao TEXT(10) ' + ');';
  // DB.FSQLConnection.ExecuteDirect(TblSinc);
  //
  // TblCfg := 'CREATE TABLE IF NOT EXISTS configuracao ( ' +
  // '  id TEXT(32) NOT NULL, ' + '  enviar_sms_ao_sucesso TEXT(1), ' +
  // '  enviar_email_ao_sucesso TEXT(1), ' +
  // '  confirmar_ao_fechar TEXT(1), ' +
  // '  exibir_forma_dinheiro TEXT(1), ' + '  criar_atalhos TEXT(1), ' +
  // '  auto_sincronizar TEXT(1), ' + '  simpos TEXT(1), ' +
  // '  simtef TEXT(1), ' + '  simpdv TEXT(1), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT CONFIGURACAO_PK PRIMARY KEY (id) ' + ');';
  // DB.FSQLConnection.ExecuteDirect(TblCfg);
  //
  // TblEmp := 'CREATE TABLE IF NOT EXISTS empresa ( ' +
  // '  id INTEGER NOT NULL, ' + '  cnpj TEXT(18), ' + '  imei TEXT(28), '
  // + '  nome_fantasia TEXT(255), ' + '  razao_social TEXT(255), ' +
  // '  data_validacao TEXT(10), ' + '  data_expiracao TEXT(10), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT EMPRESA_PK PRIMARY KEY (id) ' + ');' +
  // 'CREATE INDEX CNPJ_INDEX ON empresa (cnpj); ' +
  // 'CREATE INDEX IMEI_INDEX ON empresa (imei);';
  // DB.FSQLConnection.ExecuteDirect(TblEmp);
  //
  // TblUser := 'CREATE TABLE IF NOT EXISTS usuarios ( ' +
  // '  id INTEGER NOT NULL, ' + '  apelido TEXT(255), ' +
  // '  email TEXT(255), ' + '  senha TEXT(255), ' + '  logado TEXT(1), ' +
  // '  administrador TEXT(1), ' + '  sincronizado TEXT(1), ' +
  // '  data_insercao TEXT(20), ' + '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT USUARIOS_PK PRIMARY KEY (id) ' + '  );' +
  // 'CREATE UNIQUE INDEX EMAIL_USUARIO_UNIQUE ON usuarios (email);';
  // DB.FSQLConnection.ExecuteDirect(TblUser);
  //
  // TblVen := 'CREATE TABLE IF NOT EXISTS vendas ( ' +
  // '  id INTEGER NOT NULL, ' + '  cliente_id INTEGER NOT NULL, ' +
  // '  forma_pagamento TEXT(255) NOT NULL, ' +
  // '  valor_venda REAL(10,2), ' + '  data_venda TEXT(20), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT VENDAS_PK PRIMARY KEY (id) ' + ');' +
  // 'CREATE INDEX FORMA_PAGAMENTO_INDEX ON vendas (FORMA_PAGAMENTO); ' +
  // 'CREATE INDEX CLIENTE_ID_INDEX ON vendas (cliente_id);';
  // DB.FSQLConnection.ExecuteDirect(TblVen);
  //
  // { Tabelas do SIMTEF e SIMPDV }
  //
  // TblCat := 'CREATE TABLE IF NOT EXISTS categorias ( ' +
  // '  id INTEGER NOT NULL, ' + '  nome TEXT(255), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT CATEGORIAS_PK PRIMARY KEY (id) ' + ');';
  // DB.FSQLConnection.ExecuteDirect(TblCat);
  //
  // TblCli := 'CREATE TABLE IF NOT EXISTS clientes ( ' +
  // '  id INTEGER NOT NULL, ' + '  nome TEXT(255), ' + '  rg TEXT(50), ' +
  // '  cpf TEXT(14), ' + '  email TEXT(255), ' + '  fone TEXT(255), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT CLIENTES_PK PRIMARY KEY (id) ' + ');' +
  // 'CREATE UNIQUE INDEX EMAIL_CLIENTE_UNIQUE ON clientes (email); ' +
  // 'CREATE UNIQUE INDEX FONE_UNIQUE ON clientes (fone); ' +
  // 'CREATE INDEX RG_INDEX ON clientes (rg); ' +
  // 'CREATE INDEX CPF_INDEX ON clientes (cpf);';
  // DB.FSQLConnection.ExecuteDirect(TblCli);
  //
  // TblIVen := 'CREATE TABLE IF NOT EXISTS itens_vendas ( ' +
  // '  id INTEGER NOT NULL, ' + '  venda_id INTEGER NOT NULL, ' +
  // '  produto_id INTEGER NOT NULL, ' + '  quantidade INTEGER NOT NULL, '
  // + '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT ITENS_VENDAS_PK PRIMARY KEY (id) ' + ');' +
  // 'CREATE INDEX VENDA_ID_INDEX ON itens_vendas (venda_id); ' +
  // 'CREATE INDEX PRODUTO_ID_INDEX ON itens_vendas (produto_id);';
  // DB.FSQLConnection.ExecuteDirect(TblIVen);
  //
  // TblProd := 'CREATE TABLE IF NOT EXISTS produtos ( ' +
  // '  id INTEGER NOT NULL, ' + '  status TEXT(255) NOT NULL, ' +
  // '  categoria_id INTEGER NOT NULL, ' + '  descricao TEXT(255), ' +
  // '  valor_unitario REAL(10,2), ' + '  codigo_barras TEXT(50), ' +
  // '  sincronizado TEXT(1), ' + '  data_insercao TEXT(20), ' +
  // '  data_edicao TEXT(20), ' +
  // '  CONSTRAINT PRODUTOS_PK PRIMARY KEY (id) ' + ');' +
  // 'CREATE INDEX STATUS_INDEX ON produtos (status); ' +
  // 'CREATE INDEX CATEGORIA_ID_INDEX ON produtos (categoria_id);';
  // DB.FSQLConnection.ExecuteDirect(TblProd);
  //
  // except
  // on E: Exception do
  // raise Exception.Create(E.Message);
  // end;
  // end;
  // DB.FSQLConnection.Connected := True;
  // except
  // on E: Exception do
  // raise Exception.Create(E.Message);
  // end;
  // end;
end;

end.
