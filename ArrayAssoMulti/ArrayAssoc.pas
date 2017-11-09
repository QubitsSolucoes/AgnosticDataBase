  unit ArrayAssoc;

interface

uses
  Classes, SysUtils, RTLConsts, VariantUtils;

type

  TArrayAssoc = record
  private
    FOwner: Array of String;
    FKeyItems: Array of String;
    FItems: Array of TVariant;
    procedure Edit(Key: Integer; KeyName: String; Value: TVariant);
    function GetValues(Index: string): TVariant;
    function GetValuesAtIndex(Index: Integer): TVariant;
    procedure SetValues(Index: string; const Value: TVariant);
    function GetIsEmpty: Boolean;
    function ValueExists(Index: string; const Value: TVariant): boolean;
    function GetCount: Integer;
    function GetFirst: TVariant;
    procedure SetFirst(const Value: TVariant);
    function GetLast: TVariant;
    procedure SetLast(const Value: TVariant);
    function IndexOf(Const FIndex: String): Integer;
    procedure Remove(const AKey: String); overload;
    procedure Remove(const AIndex: integer); overload;
  public
    class function Initialize(AOwner, AKeyItems: Array of String; AItems: Array of TVariant): TArrayAssoc; overload; static;
    class function Initialize(AArrayAssoc: TArrayAssoc): TArrayAssoc; overload; static;
    property Last: TVariant read GetLast write SetLast;
    property First: TVariant read GetFirst write SetFirst;
    property Count: Integer read GetCount;
    property IsEmpty: Boolean read GetIsEmpty;
    procedure Add(Key: String; Value: TVariant);
    property ItemsAtIndex[Index: Integer]: TVariant read GetValuesAtIndex;
    property Items[Index: string]: TVariant read GetValues write SetValues; default;
  end;

  TArrayAssocBi = record
  private
    FKeyItems: Array of String;
    FItems: Array of TArrayAssoc;
    function GetValues(Index: string): TArrayAssoc;
    function GetValuesAtIndex(Index: Integer): TArrayAssoc;
    procedure SetValues(Index: string; const Value: TArrayAssoc);
    function GetCount: Integer;
    function GetFirst: TArrayAssoc;
    procedure SetFirst(const Value: TArrayAssoc);
    function GetLast: TArrayAssoc;
    procedure SetLast(const Value: TArrayAssoc);
    function ValueOwnerExists(Owner: string): boolean;
    function IndexOf(FIndex: String): Integer;
    procedure Edit(Key: String; Value: TArrayAssoc);
  public
    procedure Add(Key: string; Value: TArrayAssoc);
    property Last: TArrayAssoc read GetLast write SetLast;
    property First: TArrayAssoc read GetFirst write SetFirst;
    property Count: Integer read GetCount;
    property ItemsAtIndex[Index: Integer]: TArrayAssoc read GetValuesAtIndex;
    property Items[Index: string]: TArrayAssoc read GetValues write SetValues; default;
  end;

implementation

uses
  Dialogs;

{ TArrayAssoc }

function TArrayAssoc.ValueExists(Index: string; const Value: TVariant): boolean;
begin
  Result := IndexOf(Index) > -1;
end;

procedure TArrayAssoc.Add(Key: String; Value: TVariant);
var
  I: Integer;
begin
  I := Length(FKeyItems);
  SetLength(FKeyItems, Length(FKeyItems)+ 1);
  FKeyItems[I] := Key;
  I := Length(FItems);
  SetLength(FItems, Length(FItems)+ 1);
  FItems[I] := Value;
end;

procedure TArrayAssoc.Edit(Key: Integer; KeyName: String; Value: TVariant);
begin
  FKeyItems[Key] := KeyName;
  FItems[Key] := Value;
end;

function TArrayAssoc.GetIsEmpty: Boolean;
var
  I: Integer;
begin
  for I := 0 to High(FItems) do
    if I > 0 then
      Break;
  Result := I > -1;
end;

function TArrayAssoc.GetFirst: TVariant;
begin
  Result := FItems[0];
end;

function TArrayAssoc.GetLast: TVariant;
begin
  Result := FItems[High(FItems)];
end;

procedure TArrayAssoc.SetFirst(const Value: TVariant);
begin
  if Count > 0 then
    FItems[0] := Value
  else
    raise Exception.Create('Não foi possível atribuir um valor a uma posição inexistente do array');
end;

procedure TArrayAssoc.SetLast(const Value: TVariant);
begin
  if Count > 0 then
    FItems[High(FItems)] := Value
  else
    raise Exception.Create('Não foi possível atribuir um valor a uma posição inexistente do array');
end;

function TArrayAssoc.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TArrayAssoc.GetValues(Index: string): TVariant;
var
  VIndex: Integer;
begin
  VIndex := IndexOf(Index);
  if VIndex > -1 then
    Result := FItems[VIndex]
end;

function TArrayAssoc.GetValuesAtIndex(Index: Integer): TVariant;
begin
  Result := FItems[Index];
end;

procedure TArrayAssoc.SetValues(Index: string; const Value: TVariant);
var
  VIndex: Integer;
begin
  VIndex := IndexOf(Index);
  if VIndex > -1 then
    if FKeyItems[VIndex] <> '' then
      FItems[VIndex] := Value
    else
      Add(Index, Value)
  else
  begin
    if (High(FItems) = 0) then
    begin
      if ValueExists(Index, Value) then
        Edit(High(FItems), Index, Value)
      else if FItems[High(FItems)] = '' then
        Edit(High(FItems), Index, Value)
      else
        Add(Index, Value);
    end
    else
      Edit(High(FItems), Index, Value);
  end;
end;

class function TArrayAssoc.Initialize(AOwner, AKeyItems: Array of String;
  AItems: array of TVariant): TArrayAssoc;
var
  I: Integer;
begin
  I := Length(AOwner);
  SetLength(Result.FOwner, I);
  I := Length(AKeyItems);
  SetLength(Result.FKeyItems, I);
  I := Length(AItems);
  SetLength(Result.FItems, I);
  for I := 0 to High(AItems) do
  begin
    Result.FOwner[i] := AOwner[i];
    Result.FKeyItems[i] := AKeyItems[i];
    Result.FItems[i] := AItems[i];
  end;
end;

function TArrayAssoc.IndexOf(const FIndex: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FKeyItems) do
    if FKeyItems[I] = FIndex then
    begin
      Result := I;
      Break;
    end;
end;

class function TArrayAssoc.Initialize(AArrayAssoc: TArrayAssoc): TArrayAssoc;
var
  I: Integer;
begin
  I := Length(AArrayAssoc.FOwner);
  SetLength(Result.FOwner, I);
  I := Length(AArrayAssoc.FKeyItems);
  SetLength(Result.FKeyItems, I);
  I := Length(AArrayAssoc.FItems);
  SetLength(Result.FItems, I);
  for I := 0 to High(AArrayAssoc.FItems) do
  begin
    Result.FOwner[i] := AArrayAssoc.FOwner[i];
    Result.FKeyItems[i] := AArrayAssoc.FKeyItems[i];
    Result.FItems[i] := AArrayAssoc.FItems[i];
  end;
end;

procedure TArrayAssoc.Remove(const AIndex: integer);
var
   Total, j : integer;
begin
  Total := Length(FItems);
  if Total <= AIndex then
    exit;
  for j := AIndex to Total - 2 do
    FOwner[j] := FOwner[j + 1];
  SetLength(FOwner, Total - 1);
  for j := AIndex to Total - 2 do
    FKeyItems[j] := FKeyItems[j + 1];
  SetLength(FKeyItems, Total - 1);
  for j := AIndex to Total - 2 do
    FItems[j] := FItems[j + 1];
  SetLength(FItems, Total - 1);
end;

procedure TArrayAssoc.Remove(const AKey: String);
var
   APosicao: integer;
begin
  APosicao := IndexOf(AKey);
  Remove(APosicao);
end;

{ TArrayAssocBi }

function TArrayAssocBi.GetFirst: TArrayAssoc;
begin
  Result := FItems[0];
end;

function TArrayAssocBi.GetLast: TArrayAssoc;
begin
  Result := FItems[High(FItems)];
end;

procedure TArrayAssocBi.SetFirst(const Value: TArrayAssoc);
begin
  if Count > 0 then
    FItems[0] := Value
  else
    raise Exception.Create('Não foi possível atribuir um valor a uma posição inexistente do array');
end;

procedure TArrayAssocBi.SetLast(const Value: TArrayAssoc);
begin
  if Count > 0 then
    FItems[High(FItems)] := Value
  else
    raise Exception.Create('Não foi possível atribuir um valor a uma posição inexistente do array');
end;

function TArrayAssocBi.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TArrayAssocBi.ValueOwnerExists(Owner: string): boolean;
var
  I, J, IResult: Integer;
begin
  IResult := -1;
  for I := 0 to High(FItems) do
    for J := 0 to High(FItems[I].FOwner) do
      if FItems[I].FOwner[J] = Owner then
      begin
        IResult := I;
        Break;
      end;
  Result := IResult > -1;
end;

procedure TArrayAssocBi.Edit(Key: String; Value: TArrayAssoc);
var
  J: Integer;
begin
  with FItems[IndexOf(Key)] do
  begin
    J := Length(FOwner);
    SetLength(FOwner, Length(FOwner)+ 1);
    FOwner[J] := Key;
    J := Length(FKeyItems);
    SetLength(FKeyItems, Length(FKeyItems)+ 1);
    FKeyItems[J] := '';
    J := Length(FItems);
    SetLength(FItems, Length(FItems)+ 1);
    FItems[J] := '';
  end;
  Value := FItems[IndexOf(Key)];
end;

procedure TArrayAssocBi.Add(Key: string; Value: TArrayAssoc);
var
  I, J: Integer;
begin
  if not ValueOwnerExists(Key) then
  begin
    //Add new key
    I := Length(FKeyItems);
    SetLength(FKeyItems, Length(FKeyItems)+ 1);
    FKeyItems[I] := Key;
    //Add new item
    I := Length(FItems);
    SetLength(FItems, Length(FItems)+ 1);
    FItems[I] := Value;
    if FItems[I].Count = 0 then
    begin
      //Set values of FItems
      with FItems[I] do
      begin
        J := Length(FOwner);
        SetLength(FOwner, Length(FOwner)+ 1);
        FOwner[J] := Key;
        J := Length(FKeyItems);
        SetLength(FKeyItems, Length(FKeyItems) + 1);
        FKeyItems[J] := '';
        J := Length(FItems);
        SetLength(FItems, Length(FItems) + 1);
        FItems[J] := '';
      end;
    end;
  end;
end;

function TArrayAssocBi.GetValuesAtIndex(Index: Integer): TArrayAssoc;
begin
  Result := FItems[Index];
end;

function TArrayAssocBi.IndexOf(FIndex: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FKeyItems) do
    if FKeyItems[I] = FIndex then
    begin
      Result := I;
      Break;
    end;
end;

function TArrayAssocBi.GetValues(Index: string): TArrayAssoc;
var
  VIndex: Integer;
begin
  VIndex := IndexOf(Index);
  if (VIndex > -1) and (Length(FItems) > 0) then
  begin
    Edit(Index, Result);
    Result := FItems[VIndex];
  end
  else
  begin
    Add(Index, Result);
    Result := FItems[High(FItems)];
  end;
end;

procedure TArrayAssocBi.SetValues(Index: string; const Value: TArrayAssoc);
var
  VIndex: Integer;
begin
  VIndex := IndexOf(Index);
  if (VIndex > -1) then
    if FKeyItems[VIndex] <> '' then
      FItems[VIndex] := Value
    else
      Add(Index, Value)
  else
    Add(Index, Value);
end;

end.
