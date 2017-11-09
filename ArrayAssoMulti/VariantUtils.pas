unit VariantUtils;

interface

uses
  Variants, VarUtils, SysUtils;

type

  TTypeVar = class
  public
    class function VarToInt(AValue: Variant): Integer;
    class function VarToInt64(AValue: Variant): Int64;
    class function VarToDouble(AValue: Variant): Double;
    class function VarToValue(AValue: Variant; AVarType: TVarType): Variant;
  end;

  TVariant = record
  private
    FValue: Variant;
  public
    class operator Implicit(AValue: Variant): TVariant; overload;
    class operator Implicit(AValue: TVariant): Variant; overload;
    class operator Implicit(AValue: TVariant): Integer; overload;
    class operator Implicit(AValue: TVariant): String; overload;
    class operator Implicit(AValue: TVariant): Int64; overload;
    class operator Implicit(AValue: TVariant): Double; overload;
    class operator Implicit(AValue: TVariant): TDateTime; overload;
  end;

implementation

{ TTypeVar }

class function TTypeVar.VarToInt(AValue: Variant): Integer;
var
  ATemp: String;
begin
  ATemp := VartoStr(AValue);
  Result := StrToInt(ATemp);
end;

class function TTypeVar.VarToInt64(AValue: Variant): Int64;
var
  ATemp: String;
begin
  ATemp := VartoStr(AValue);
  Result := StrToInt64(ATemp);
end;

class function TTypeVar.VarToDouble(AValue: Variant): Double;
var
  ATemp: String;
begin
  ATemp := VartoStr(AValue);
  Result := StrToFloat(ATemp);
end;

class function TTypeVar.VarToValue(AValue: Variant; AVarType: TVarType): Variant;
begin
  case AVarType of
    varEmpty: Result := '';
    varNull: Result := AValue;
    varInteger: Result := TTypeVar.VarToInt(AValue);
    varByte: Result := TTypeVar.VarToInt(AValue);
    varInt64: Result := TTypeVar.VarToInt64(AValue);
    varString: Result := Variants.VarToStr(AValue);
    varDate: Result := Variants.VarToDateTime(AValue);
    varDouble: Result := TTypeVar.VarToDouble(AValue);
  end;
end;

{ TVariant }

class operator TVariant.Implicit(AValue: TVariant): Integer;
begin
  Result := TTypeVar.VarToValue(AValue.FValue, varInteger);
end;

class operator TVariant.Implicit(AValue: TVariant): String;
begin
  Result := TTypeVar.VarToValue(AValue.FValue, varString);
end;

class operator TVariant.Implicit(AValue: TVariant): Int64;
begin
  Result := TTypeVar.VarToValue(AValue.FValue, varInt64);
end;

class operator TVariant.Implicit(AValue: TVariant): Double;
begin
  Result := TTypeVar.VarToValue(AValue.FValue, varDouble);
end;

class operator TVariant.Implicit(AValue: TVariant): TDateTime;
begin
  Result := TTypeVar.VarToValue(AValue.FValue, varDate);
end;

class operator TVariant.Implicit(AValue: Variant): TVariant;
begin
  Result.FValue := AValue;
end;

class operator TVariant.Implicit(AValue: TVariant): Variant;
begin
  Result := AValue.FValue;
end;

end.
