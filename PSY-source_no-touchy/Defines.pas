unit Defines;

interface

uses
  Graphics, stdctrls, comctrls;

type
  { Array types for calculations }
  Float = Extended;  // 3.6 x 10^–4951 .. 1.1 x 10^4932, 10 bytes
  // Dynamic arrays, length must be set in code

const
  { Version Control Defines }
//  vcVersionMajor = '2000';
// no longer used
//  vcVersionMinor = '0';
//  vcVersionRelease = '0';
//  vcVersionBuild = '0';

	// build num
  dfBuildNum = '20000818';

  { Output Defines }
  dfHeaderInfo = 'PSY ' {+
     vcVersionMajor + '.' + vcVersionMinor + '.' +
     vcVersionRelease + '.' + vcVersionBuild};
	dfCopyright = '© 2000';

  { File headers }
  PSYINHEADER = '%PSY IN%';
  PSYOUTHEADER = '%PSY OUT%';

  { Char defines }
  dfNL = #13#10;    // New Line character
  dfDefDelim = #9;  // Tab as default delimitor

  { Input Headers }
  dfComment = '//';  // Chars used to indicate the start of a comment
  dfComLen = Length(dfComment);
  { IN Key Words }
  // default keys used
  dfHeader = '[Header]';
  dfData   = '[Data]';
  dfBCont  = '[BetweenContrasts]';
  dfWCont  = '[WithinContrasts]';
  // search list with alternate keys
  // *** change number if change to # of keys
  dfSearchKeyList: array[0 .. 9] of String =
    (dfHeader, dfData,
  	'[BContrasts]', dfBCont, '[BContrast]', '[BetweenContrast]',
  	'[WContrasts]', dfWCont, '[WContrast]', '[WithinContrast]');
  dfNumSearchKeys = Length(dfSearchKeyList);

  { OUT Key Words }
  // nb check array size
  // nb case sensitive
//  nvAnalysis = 'PSY 2000';
  nvAnalysis = 'PSY';
  dfOutSearchKeyList: array[0 .. 6] of String =
    ('====', ' Number ', ' Means ', ' Analysis ', ' Rescaled ', ' Raw ',
     ' Approximate ');  // use space to test for single word
  dfNumOutSearchKeys = Length(dfOutSearchKeyList);

  { Confidence Level Defines }
  clLow = 70.0;
  clHigh = 99.9;
  clErrMsg = 'Confidence Level must be between 70% and 99.9%';
  clHintMsg = '70 to 99.9';
  clDefMsg = '95';

  { Child Window Defines }
  cwInTitle = 'IN - ';
  cwOutTitle = 'OUT - ';
  cwDefTitle = 'Untitled';
  cwCloseMsg = 'Close In/Out Window?';
  cwInCloseSaveMsg = 'Save changes to IN window?';
  cwOutCloseSaveMsg = 'Save changes to OUT window?';
  cwOpenDef = 'in';
  cwSaveIn = 'in';
  cwSaveOut = 'out';

  { StatusBar }
  dfStatusWidth = 100;

  { Navigator width }
  dfNavWidth = 121;

  { Parse Error message }
  peMSG = 'Error found in input!';

  { Divider line width }
  dfRpt = 60;

  { Contrast Label width }
  dfLblWid = 12;

  { Grid Defines }
  dfMinRows = 3;
  dfMinCols = 4;
  dfMinColWidth = 64;
  dfCol0Width = 32;

  { Decimal Places }
  prLead = 6;  // leading figures

  dfTol = 1e-30;  // tollerence for zero vals

  { Colours }
  dfMissing = {clTeal} clYellow;
  dfError   = clRed;
  dfNot0Sum = clYellow;

  { MDI Child size/position }
  dfTop = 22;    // these values give the same size and pos as cascade
  dfLeft = 22;
  dfRight = 95; 

  { Error and Warning messages }
  // format: Text;Context
  ewNoData =       'ERROR: No Data was found;20';
  ewContrasts =    'ERROR: The Number of Groups and Measures must both be greater than two;0';
  ewDf =           'ERROR: The degrees of freedom must be greater than zero;0';
  ewGroup =        'ERROR: There must be at least one Between contrast;0';
  ewMeasure =      'ERROR: There must be at least one Within contrast;0';
  ewNoContrats =   'ERROR: There must be at least one Between or Within contrast;0';
  ewIntContrasts = 'ERROR: Contrast coefficients must be integers;0';
  ewBadData =      'Warning:  Data missing or could not be understood;0';
  ewBadCont =      'Warning:  Either a contrast coefficient or the data''s group membership variable is missing or could not be understood;0';

var
  { precision }
  prFigs: Integer = 3;

type
  // word info
	TWordType = (wtBlank, wtDelimitor, wtComment, wtText, wtNewLine, wtEOL);
	TLineType = (ltComment, ltHeader, ltData, ltBContrast, ltWContrast, ltBlank,
							 ltError);
  // Parse info
  TKeyInfo = record
    StartLine: Integer;  // line number
    Lines: Integer;     // number of lines
  end;
	// Key list types
	TKeyTypes = (InKeys, OutKeys);
  // IN parse types
  TInKeyTypes = (ptComment, ptHeader, ptData, ptBetween, ptWithin);
  TPsyInKeyList = array[Low(TInKeyTypes)..High(TInKeyTypes)] of TKeyInfo;
  // OUT parse types
  TOutKeyTypes = (ptTop, ptSummary, ptMeanSD, ptANOVA, ptContCs, ptRawCIs, ptzCIs);
  TOutKeyInfo = array[Low(TOutKeyTypes)..High(TOutKeyTypes)] of TKeyInfo;
  TPsyOutKeyList = array of TOutKeyInfo;
	//  KeyList for IN or OUT
	TPsyKeyList = record
  	case KeyType: TKeyTypes of
    	InKeys: (InKeyList: TPsyInKeyList);
      OutKeys: (OutKeyList: ^TPsyOutKeyList);
  end;

// true if string is a float
function isFloat(const InStr: String): Boolean;
// true if string is an integer
function isInt(const InStr: String): Boolean;
// Returns a string with the desired precision
function FtoStr(const InVal: Float; const Leading, Places: Integer): String;

implementation

uses
  SysUtils, Math;

{ True if InStr is a Float }
function isFloat(const InStr: String): Boolean;
begin
  isFloat := False;
  if (InStr = '') then
  	exit;
  {if InStr <> '.' then}    // missing value ok
    try
      StrToFloat(InStr);
    except
      exit;
    end;
  isFloat := True;
end;

{ True if InStr is an Integer }
function isInt(const InStr: String): Boolean;
begin
  isInt := False;
  if (InStr = '') then
  	exit;
  {if InStr <> '.' then}  // missing value ok
    try
     StrToInt(InStr);
    except
      exit;
    end;
  isInt := True;
end;

{
Returns a string with the desired precision and leading figures (or padded)
format is ' -lllll.ppppp' or ' -p.ppppE-ddd'
}
function FtoStr(const InVal: Float; const Leading, Places: Integer): String;
var
  tmpStr, MagStr: String;
  i, Mag, MagLen: Integer;
begin
  { Messy way to produce nicer exponential notation than provided }
  tmpStr := format('%e', [InVal]); // convert to exponential notation
  i := Pos('E', tmpStr) +1;        // find the exponent, +1 to skip E
  MagStr := Copy(tmpStr, i +1, 3); // +1 to skip sign
  Mag := StrToInt(MagStr);
  MagStr := IntToStr(Mag);         // explicit convert to clean leading zeros
  MagLen := Length(MagStr);
  if Mag > 30 then                // * done to avoid rounding errors near zero
    FtoStr := format('%*.*f',[Leading + Places +2, Places, 0.0])
  else if Mag >= Leading then
    // format: number as -d.dddde-d
    FtoStr := format('%*.*se%s%s',[Leading +Places -MagLen, // width
                                   Leading +Places -MagLen -1, // number width, -1 for sign
                                   tmpStr,  // number
                                   tmpStr[i], // exponent sign
                                   MagStr])   // exponent
  else
    FtoStr := format('%*.*f',[Leading + Places +2, Places, InVal]);
end;

end.

