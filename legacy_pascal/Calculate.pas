unit Calculate;

{$MODE Delphi}


//    *******************************************************
//    ***     Last Update : 08/09/2002                    ***
//    ***     Written By  : Mason Liotta                  ***
//    ***     Email       : dave_liotta@hotmail.com       ***
//    ***                                                 ***
//    ***    You are free to distribute/change/use this   ***
//    ***  as long as the credits above remain intact.    ***
//    ***  Please notify me of any changes that you make  ***
//    ***  before you redistribute it though. I may want  ***
//    ***  to use the changes too !                       ***
//    ***                                                 ***
//    *******************************************************
//
//    *******************************************************
//    08/09/2002 - Update by Clelson Luiz - Circular Reference Check
//    08/09/2002 - Update by Clelson Luiz - SetMemory procedure 
//    *******************************************************
//
//           To use this Unit simply instantiate an Object
//    ( myObj = Tcalculate.Create ). Then use the public
//    GetXXX methods provided to perform the calculation.
//    Be sure that 'Calculate' is in your uses clause as well.
//
//    Example :  myObj.GetCustom('1 - (-2) + 13 * 500 / 8', '0.0');
//    Returns :  '815.5'; ( String Formatted to your specs. )
//
//           Variables can also be used in a couple of ways.
//    I have provided a public TStrings "Memory" list. You must
//    add Strings in the 'name=value' form with no spaces on
//    either side. You may also add a formula ( 'name=formula' ).
//    That will be calculated each time the named variable is
//    requested. A special variable is provided in the memory
//    list that contains the answer for the last calculation.
//    That variable can be used in subsequent calculations by
//    using the name "_ANS" ( without the quotes ).
//
//    Example : myObj.memory.Add('myVariable=2.65');
//              myObj.GetInt('myVariable');
//    Returns : 3; ( Integer )
//
//           You can also handle the OnFindVariableEvent in your
//    code to provide a custom way to search for the variable that
//    is being requested. Simply set the 'value' parameter equal to
//    the value that you want the variable named in the 'name'
//    parameter to hold.
//

interface

uses
  Classes, SysUtils, Math;

const
  ADD = ord('+');
  SUBTRACT = ord('-');
  MULTIPLY = ord('*');
  DIVIDE = ord('/');
  MODULUS = ord('%');
  POWER = ord('^');

type
  TFindVariableEvent = procedure (Sender: TObject; name: string;
                                    var value: Extended) of object;

type
  TCalculate = class
  private
    { Private Declarations }
    FOnFindVariable: TFindVariableEvent;
    FMemory: TStringList;
    FUndefined: TStringList;
    delimiters: set of Char;
    current_pos: Integer; // holds the current read position in the expression
    function doCalc(operation: Integer; left_side, right_side: string): string;
    function MinPositiveIntValue(numbers: array of integer): Integer;
    function Calculate(expression: string): string;
    function RemoveWhiteSpace(expression: string): string;
    procedure SetMemory(value: TStringList);
  protected
    { Protected Declarations }
    function FindFloat(name: string): Extended;
    function FindInt(name: string): Integer;
  public
    { Public Declarations }
    constructor Create;
    destructor Destroy; override;

    // All of the GetXXX functions use the GetCustom method
    // for processing. For custom formatting simply pass
    // in a format string that complies with the format
    // strings in the FormatFloat method in Delphi.
    function GetCustom(expression, format : String) : String;
    function GetMoney(expression : String) : Extended;
    function GetInt(expression : String) : Integer;
    function GetPercent(expression : String) : String;
  published
    //     Users will want to add variables to this string list
    // in the form 'name=value' with no spaces. You may also
    // provide a formula like 'name=1+(4/5)-a' if you want.
    //     This particular variable list will have precedence
    // over the OnFindVariable event. In other words, if the
    // variable is found in this string list then the event
    // will not be fired. If, however, the variable is not
    // found in here and the OnFindVariable event is not
    // handled then an Exception will be thrown.
    property Memory : TStringList
      read FMemory write SetMemory;

    //     Users will handle this event to do thier own Variable processing.
    // simply set the 'value' parameter to whatever value you want to
    // give the variable that is named in the 'name' parameter. If this
    // event is not assigned and a variable is encountered that is also
    // not in the "Memory" TStrings ( which has precedence ), an Exception
    // will be thrown.
    //
    // *************************************************************************************************
    // TFindVariableEvent = procedure (Sender : TObject; name : String; var value : Extended) of object;
    // *************************************************************************************************
    //
    property OnFindVariable : TFindVariableEvent
      read FOnFindVariable write FOnFindVariable;
  end;

implementation

constructor Tcalculate.Create;
begin
  // a name=value TStrings list for holding
  // variables throughout the life of the
  // object.
  FMemory := TStringList.Create;

  // To hold undefined variables search, because it is recursive
  FUndefined := TStringList.Create;

  // divide, multiply, modulus, power, add, subtract,
  // open paren, close paren respectively.
  delimiters := ['/', '*', '%', '^', '+', '-', '(', ')'];
end;

destructor Tcalculate.Destroy;
begin
  FMemory.Free;
  FUndefined.Free;
  inherited Destroy;
end;

function Tcalculate.Calculate(expression : String) : String;
var
  tokens : TStrings;
  delim_pos : Integer;
begin
  tokens := TStringList.Create;
  tokens.Clear;
  // separate by delimiters
  while ( current_pos <= Length(expression) ) AND
        ( expression[current_pos] <> ')' ) do
  begin
    tokens.Add('');
    while  ( current_pos <= Length(expression) ) AND
          (not ( expression[current_pos] in delimiters )) do
    begin
        tokens[tokens.Count - 1]
          := tokens[tokens.Count - 1] + expression[current_pos];
        Inc(current_pos);
    end;

    // if we find an open paren, make the recursive call
    if expression[current_pos] = '(' then
    begin
      Inc(current_pos); tokens[tokens.Count - 1]
        := (Calculate(expression));
    end
    else if expression[current_pos] <> ')' then
    begin
      // needed in case two delimiters are encountered in succession
      // i.e. a negative assertion ( 1 - -2 )
      if tokens[tokens.Count - 1] = '' then
        tokens.Delete(tokens.Count - 1);

      // now add the current delimeter
      tokens.Add(expression[current_pos]);
      Inc(current_pos);
    end;
  end;

  Inc(current_pos); // move past the previous ')' if it existed

  // search for negative assertions
  delim_pos := 0;
  while delim_pos < tokens.Count - 1 do
  begin
    if CompareStr(tokens[delim_pos],'-') = 0 then
    begin
      if delim_pos = 0 then
      begin
        tokens.delete(delim_pos);
        tokens[delim_pos] := '-' + tokens[delim_pos];
      end
      else if (Length(tokens[delim_pos-1]) = 1)
        AND (tokens[delim_pos-1][1] in delimiters) then
      begin
        tokens.delete(delim_pos); tokens[delim_pos]
          := '-' + tokens[delim_pos];
      end;
    end;
    Inc(delim_pos);
  end;  //while

  // now check for the power operation
  delim_pos := tokens.IndexOf('^');
  while delim_pos > 0 do
  begin
    tokens.Insert(delim_pos -1, doCalc(ord(tokens[delim_pos][1]),
                                tokens[delim_pos - 1], tokens[delim_pos + 1]));
    tokens.Delete(delim_pos);
    tokens.Delete(delim_pos);
    tokens.Delete(delim_pos);
    delim_pos := tokens.IndexOf('^');
  end;

  // now check for multiply, divide, modulous operations
  delim_pos := MinPositiveIntValue([tokens.IndexOf('*'), tokens.IndexOf('/'), tokens.IndexOf('%')]);
  while delim_pos > 0 do begin
    tokens.Insert(delim_pos -1, doCalc(ord(tokens[delim_pos][1]),
                    tokens[delim_pos - 1], tokens[delim_pos + 1]));
    tokens.Delete(delim_pos);
    tokens.Delete(delim_pos); tokens.Delete(delim_pos);
    delim_pos := MinPositiveIntValue([tokens.IndexOf('*'), tokens.IndexOf('/'),
                                        tokens.IndexOf('%')]);
  end;

  // now check for add or subtract operation
  delim_pos := MinPositiveIntValue([tokens.IndexOf('+'), tokens.IndexOf('-')]);
  while delim_pos > 0 do
  begin
    tokens.Insert(delim_pos -1, doCalc(ord(tokens[delim_pos][1]),
                    tokens[delim_pos - 1], tokens[delim_pos + 1]));
    tokens.Delete(delim_pos); tokens.Delete(delim_pos);
    tokens.Delete(delim_pos);
    delim_pos := MinPositiveIntValue([tokens.IndexOf('+'), tokens.IndexOf('-')]);
  end;

  Result := Trim(tokens.Text);
  tokens.Free;
end;

function Tcalculate.doCalc(operation : Integer; left_side, right_side : String) : String;
var
  float_right_side : Extended;
begin
  // watch for divide by zero..
  float_right_side := FindFloat(right_side);
  if ((operation = DIVIDE) OR (operation = MODULUS)) AND (float_right_side = 0) then raise Exception.Create('Division by zero : ' + left_side + '/' + right_side);

  case operation of
    POWER:
      Result := FloatToStr(Math.Power(FindFloat(left_side), float_right_side));
    MULTIPLY:
      Result := FloatToStr(FindFloat(left_side) * float_right_side);
    DIVIDE:
      Result := FloatToStr(FindFloat(left_side) / float_right_side);
    MODULUS:
      Result := FloatToStr(FindInt(left_side) mod FindInt(right_side));
                            // mod requires integer operands
    ADD:
      Result := FloatToStr(FindFloat(left_side) + float_right_side);
    SUBTRACT:
      Result := FloatToStr(FindFloat(left_side) - float_right_side);
    else
      raise Exception.Create('Invalid Operation : ' + left_side
                                            + char(operation) + right_side);
  end;
end;

function Tcalculate.FindFloat(name : String) : Extended;
var
  temp_current_pos : Integer;
begin
  // Because FindFloat can be called recursively
  // We need to check if a Finding varible does not have a circular dependency;
  if FUndefined.IndexOf(name) >= 0 then
    raise Exception.Create('Circular dependency found: '+name);

  FUndefined.Add(name); // We are seeking for it value

  Result := 0.0;
  try
    // first check to see if its already a vaild Float
    Result := strToFloat(name);
  except
    on EConvertError{Exception} do

      // must not be a number, so lets see if its a variable
    begin
        if (name = '#') then  //Added by Benjamin Pina Altamirano
          Result := Random
        else if (name = '#G') then
        	Result := RandG(0.5, 0.25) 
        else if (FMemory <> nil) AND (FMemory.IndexOfName(name) >= 0) then
        begin
          // hafta temporarily reset the current_pos
          // so that the new calculate call can do
          // its job.
          temp_current_pos := current_pos;
          
          current_pos := 1;
          Result := StrToFloat(Calculate(RemoveWhiteSpace(FMemory.Values[name])));

          // set it back
          current_pos := temp_current_pos;
        end
        else if Assigned(FOnFindVariable) then
          TFindVariableEvent(FOnFindVariable)(Self, name, Result)
        else
        begin
          // Clear FUndefined for future use
          FUndefined.Clear;
          raise Exception.Create('Variable Undefined : ' + name);
        end;
    end; //on Except
  end;  //try
  // Good, we find the value for
  FUndefined.Delete(FUndefined.Count-1);
end;

function Tcalculate.FindInt(name : String) : Integer;
begin
  Result := StrToInt(FormatFloat('0', FindFloat(name)));
end;

function Tcalculate.MinPositiveIntValue(numbers : array of integer) : Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to Length(numbers) -1 do
  begin
    // operator will not be in the zero position unless it was a
    // negative assertion, in which case it has already been
    // handled before this is used.
    if numbers[i] > 0 then
    begin
      if Result < 0 then
        Result := numbers[i]
      else if numbers[i] < Result then Result := numbers[i];
    end;  //if
  end;  //for
end;

function Tcalculate.GetCustom(expression, format : String) : String;
var
  answer : Extended;
begin
  current_pos := 1; // intialize on each request
  answer := FindFloat(Calculate(RemoveWhiteSpace(expression)));

  // add the current answer to the memory
  // so it can be used in the next calculation
  // if needed.
  if FMemory = nil then FMemory := TStringList.Create;
  FMemory.Values['_ANS'] := FloatToStr(answer);

  Result := FormatFloat(format, answer);
end;

function Tcalculate.GetInt(expression : String) : Integer;
begin
  Result := StrToInt(GetCustom(expression, '0'));
end;

function Tcalculate.GetMoney(expression : String) : Extended;
begin
  Result := StrToFloat(GetCustom(expression, '0.00'));
end;

function Tcalculate.GetPercent(expression : String) : String;
begin
  Result := GetCustom(expression, '0.00%');
end;

function Tcalculate.RemoveWhiteSpace(expression : String) : String;
begin
  expression := StringReplace(expression, ' ', '', [rfReplaceAll]); // space
  expression := StringReplace(expression, #10, '', [rfReplaceAll]); // new line
  expression := StringReplace(expression, #13, '', [rfReplaceAll]); // carriage return
  expression := StringReplace(expression, #9, '', [rfReplaceAll]);  // tab
  expression := Trim(expression); // anything else on the ends we missed
  Result := expression;
end;

procedure Tcalculate.SetMemory(value : TStringList);
begin
  FMemory.Free;
  FMemory.Assign(value);
end;

end.
