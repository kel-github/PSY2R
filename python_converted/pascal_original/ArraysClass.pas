unit ArraysClass;

interface

uses
  Defines, Classes;

type
  TArrays = class
  public
    DataMatrix                 : array of array of Float; // group x row x col
    SubjectArray               : array of Integer;
    SubjectIndexArray          : array of Integer;
    // nb use float for these arrays to avoid incorect results when squaring
    //    large coefs, ie 99999
    BContrastArray             : array of array of Float;
    WContrastArray             : array of array of Float;
//    RepeatComments             : TStringList;
//    GroupComments              : TStringList;
    Header                     : TStringList;
    GroupsList                 : TStringList;
    BetweenComments            : TStringList;
    WithinComments             : TStringList;

    SumOfSubjects              : Integer;
    NumberOfGroups             : Integer;
    NumberOfRepeats            : Integer;
    NumberOfBContrasts         : Integer;
    NumberOfWContrasts         : Integer;

//   OutFileName                : string;
//   OutFileTitle               : string;
//   OutFileText                : Text;
//   PrintText                  : Text;
    AlphaString                : string;
//   FullFileName               : string;
//   FileToSave                 : string;

//   AContrastsOrthogonal       : Boolean;
//   ResultsToScreen            : Boolean;
//   OpenForAnalysis            : Boolean;
    DoConfidenceInterval       : Byte;
    DoRescaling                : Boolean;

    CC                         : array [0..2] of Float;
    Alpha                      : Float;
    p, q                       : Integer;
    OrdB, OrdW                 : Integer;
    DFE                        : Float;
    RoyMessage                 : Boolean;

    Bcc                        : Float;          // Between critical constant
    Wcc                        : Float;          // Within critical constant
    BWcc                       : Float;          // B & W ineraction

    procedure ClearAll;
  end;

var
  Arrays: TArrays = nil;

implementation

procedure TArrays.ClearAll;
begin
    SetLength(DataMatrix, 1, 1);
    SetLength(SubjectArray, 1);
    SetLength(SubjectIndexArray, 1);
    SetLength(BContrastArray, 1, 1);
    SetLength(WContrastArray, 1, 1);

    DataMatrix[0,0] := 0.0;
    SubjectArray[0] := 0;
    SubjectIndexArray[0] := 0;
    BContrastArray[0,0] := 0.0;
    WContrastArray[0,0] := 0.0;
    
    SumOfSubjects := 0;
    NumberOfGroups := 0;
    NumberOfRepeats := 0;
    NumberOfBContrasts := 0;
    NumberOfWContrasts := 0;
    AlphaString := '';
    DoConfidenceInterval := 1;
    DoRescaling := False;
    CC[0] := 0.0;
    CC[1] := 0.0;
    CC[2] := 0.0;
    Alpha := 0.0;
    p := 0;
    q := 0;
    OrdB := 0;
    OrdW := 0;
    DFE := 0.0;
    RoyMessage := False;
    Bcc := 0.0;
    Wcc := 0.0;
    BWcc := 0.0;

    Header.Clear;
    GroupsList.Clear;
    BetweenComments.Clear;
    WithinComments.Clear;
end;

{ initialise and finalise here (globally) }
initialization
  Arrays := TArrays.Create;
  with Arrays do
  begin
    Header := TStringList.Create;
    GroupsList := TStringList.Create;
    BetweenComments := TStringList.Create;
    WithinComments := TStringList.Create;
  end;

finalization
  with Arrays do
  begin
    Header.Free;
    GroupsList.Free;
    BetweenComments.Free;
    WithinComments.Free;
  end;
  Arrays.Free;

end.
