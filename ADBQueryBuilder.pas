unit ADBQueryBuilder;

interface

uses
  System.SysUtils,
  System.RegularExpressions,
  ADBConnection,
  ArrayAssoc;

type

  { Record TADBQueryBuilder para Criação de Consultas para a Classe TADBQuery }
  TADBQueryBuilder = record
  private
    { Private declarations }
    function ExtractStringBetweenDelims(Input: String; Delim1, Delim2: String): String;
    function GenericQuery(Input: string; Mode: Boolean = False): TADBQuery;
  public
    { Public declarations }
    function View(Input: string; const Mode: Boolean = False): TADBQuery;
    function Exec(Input: string; const Mode: Boolean = True): TADBQuery;

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

{ TADBQueryBuilder }

function TADBQueryBuilder.ExtractStringBetweenDelims(Input: String;
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

function TADBQueryBuilder.GenericQuery(Input: string; Mode: Boolean = False): TADBQuery;
var
  SQL: TADBQuery;
begin
  SQL := TADBQuery.Create;
  SQL.Query.Close;
  SQL.Query.SQL.Clear;
  SQL.Query.SQL.Text := Input;
  if not Mode then
    SQL.Query.Open
  else
    SQL.Query.ExecSQL;
  Result := SQL;
end;

function TADBQueryBuilder.Filter(Input, Column: String): String;
begin
  Result := ExtractStringBetweenDelims(Input, '<' + Column + '>',
    '</' + Column + '>');
end;

function TADBQueryBuilder.View(Input: string; const Mode: Boolean = False): TADBQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

function TADBQueryBuilder.Exec(Input: string; const Mode: Boolean = True): TADBQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

function TADBQueryBuilder.Fetch(ATable: string; Filter: string;
  Condition: string = '1'): TArray;
var
  Query: TADBQueryBuilder;
  SQL: TADBQuery;
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

function TADBQueryBuilder.Fetch(ATable: string; Filter: string): TArray;
var
  Query: TADBQueryBuilder;
  SQL: TADBQuery;
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

function TADBQueryBuilder.Fetch(ATable: string): TArray;
var
  Query: TADBQueryBuilder;
  SQL: TADBQuery;
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

function TADBQueryBuilder.Select(ATable: string): String;
begin
  Result := 'SELECT * FROM ' + ATable + ';';
end;

function TADBQueryBuilder.Select(ATable: string; Filter: string): String;
begin
  Result := 'SELECT ' + Filter + ' FROM ' + ATable + ';';
end;

function TADBQueryBuilder.Select(ATable: string; Filter: string;
  Condition: string = '1'): String;
begin
  if ((Condition = '') or (Condition = '1')) then
    Condition := ';'
  else
    Condition := ' WHERE ' + Condition + ';';
  Result := 'SELECT ' + Filter + ' FROM ' + ATable + Condition;
end;

function TADBQueryBuilder.Insert(ATable: string; Data: TArray;
  Run: Boolean = False): String;
var
  DbNames: String;
  DbValues: String;
  I: Integer;
  Value: String;
  Sentencia: String;
  Query: TADBQueryBuilder;
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

function TADBQueryBuilder.Update(ATable: String; Data: TArray; Condition: TArray;
  Run: Boolean = False): String;
var
  DbValues: String;
  DbFilters: String;
  Value: String;
  I: Integer;
  Sentencia: String;
  Query: TADBQueryBuilder;
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

function TADBQueryBuilder.Update(ATable: String; Data: TArray;
  Run: Boolean = False): String;
var
  DbValues: String;
  Value: String;
  I: Integer;
  Sentencia: String;
  Query: TADBQueryBuilder;
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

function TADBQueryBuilder.Delete(ATable: String; Condition: TArray;
  Run: Boolean = False): String;
var
  Sentencia: String;
  DbFilters: String;
  Query: TADBQueryBuilder;
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

function TADBQueryBuilder.Delete(ATable: String; Run: Boolean = False): string;
var
  Sentencia: String;
  Query: TADBQueryBuilder;
begin
  Sentencia := 'DELETE FROM ' + ATable + ';';
  if Run then
    Query.Exec(Sentencia);
  Result := Sentencia;
end;

function TADBQueryBuilder.Replace(ATable: String; Data: TArray;
  Run: Boolean = False): String;
var
  DbNames: string;
  DbValues: string;
  Value: string;
  I: Integer;
  Sentencia: String;
  Query: TADBQueryBuilder;
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

end.
