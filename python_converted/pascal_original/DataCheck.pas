unit DataCheck;

interface

uses
	Classes, Math, SysUtils, ComCtrls, ChildWin, InChildWin, Defines;

type
  // nb types declared in Defines
	TPsyCheck = class
  private
    function WordType(const Key: Char): TWordType;
    function WholeWord(const Source: String): String;
    function StartOfWord(const Source: String; var Count: Integer;
      var wtIs: TWordType): String;
    function ParseWord(const Source: String; var WordIs: String;
      var Count: Integer; var wtIs: TWordType): String;
//    function ParseLine(const Source: String; var Comment: String;
//      var ltIs: TLineType): TStrings;
    { New parse routines }
    function LineToStringList(Source: String; MinCols: Integer): String;
    procedure LinesToParse(Source: TStrings; Index, Count: Integer;
                           Dest: TStringList; MinCols: Integer);
    function ColumnCount(Source: TStrings): Integer;
  protected
    function RowOK(Lines: TStrings; IsData: Boolean): Boolean;
  public
  	// List of warnings, use Message;Context to get help with Context
  	Warnings: TStringList;
    constructor Create;
    destructor Destroy; override;

  (*    // Converst Memo text to StringGrid and Matricies
    procedure CheckData(const Child: TMDIInChild); *)
    // true if data ok for analysis
    function CanRun(const Child: TMDIInChild): Boolean;
(*    // convert input data to matricies for data analysis
    procedure DataToMatrices(const Child: TMDIInChild); *)
(*    // convert Grid Data to Memo
		procedure DataToMemo(const Child: TMDIInChild); *)

    function KeyInfo(AStartLine, ALines: Integer): TKeyInfo;
		function IsPsyFile(FileName: String): Byte;
		procedure UpdateData(Win: TMDIChild);
		function ConvertToPsy(Win: TMDIChild): Boolean;
    function UpdateKeys(Win: TMDIInChild): Boolean; overload;
    function UpdateKeys(Win: TMDIChild): Boolean; overload;
    procedure EditToData(Win: TMDIInChild);
    procedure InitKeyList(Win: TMDIInChild); overload;
    procedure InitKeyList(Win: TMDIChild); overload;
    procedure TabToMark(Lines: TStrings);
    procedure MarkToTab(Lines: TStrings);
	end;

var
	PsyCheck: TPsyCheck;

implementation

{$R+}

uses
	Main, ArraysClass, Dialogs;

constructor TPsyCheck.Create;
begin
  Warnings := TStringList.Create;
end;

destructor TPsyCheck.Destroy;
begin
  inherited;
  Warnings.Free;
end;

{ returns word type based on chars in word }
function TPsyCheck.WordType(const Key: Char): TWordType;
begin
	case Key of
		'!'..'+',   // not ','
		'-'..'9',   // not ':' or ';'
		// handle 8bit
		#131 .. #140,
		#145 .. #156,
		#159,
		#161 .. #186,
		#188 .. #255,
		'<'..'~':
			WordType := wtText;
		#9, '»', ',', ':', ';':  // delimitors, #9 = TAB
			WordType := wtDelimitor;
	else  // default, blank char
		WordType := wtBlank;
	end; { case }
end; { WordType }

{ Extracts KeyWord, Text or Values. }
function TPsyCheck.WholeWord(const Source: String): String;
var
  wtIs: TWordType;
  Index: Integer;
  MaxLen: Integer;
begin
  Index := 1;
  MaxLen := Length(Source);
  if Source = '' then
  begin
    WholeWord := '';
    exit;
  end;
  repeat  // sets Index to char after end of word
    wtIs := WordType(Source[Index]);
    Inc(Index);
  until (Index > MaxLen) or (wtIs <> wtText);
  if wtIs <> wtText then
    if MaxLen > 1 then  // skip last char if not text
      WholeWord := copy(Source, 1, Index - 2)
    else
      WholeWord := ''
  else
    WholeWord := copy(Source, 1, Index - 1);
end; { WholeWord }

{ Returns Line starting at a word.  Source must be non empty }
function TPsyCheck.StartOfWord(const Source: String; var Count: Integer;
                     var wtIs: TWordType): String;
var
  Index: Integer;
  MaxLen: Integer;
  OldCount: Integer;
begin
  Index := 1;
  MaxLen := Length(Source);
  OldCount := Count;
  repeat    // inc word count for each delimitor
    repeat  // ignore blank chars
      wtIs := WordType(Source[Index]);
      Inc(Index);
    until (Index > MaxLen) or (wtIs <> wtBlank);
    if wtIs = wtDelimitor then
    begin
      if Count = 0 then  // count missing word before delimitor
        Inc(Count);
      Inc(Count);
    end;
  until (Index > MaxLen) or (wtIs <> wtDelimitor);
  if (wtIs <> wtText) then
  begin  // no start of word found
    StartOfWord := '';
    if (Count > 0) or (wtIs = wtComment) then wtIs := wtEOL
    else wtIs := wtNewLine;  // no words found in the line
  end
  else
  begin
    StartOfWord := copy(Source, Index - 1, MaxLen - Index + 2);
    if OldCount < Count then
      dec(Count);  // ignore last delimitor if followed by a word
  end;
end;  { StartOfWord }

{ Gets a Word, its type and returns the rest of the line. }
function TPsyCheck.ParseWord(const Source: String; var WordIs: String;
                   var Count: Integer; var wtIs: TWordType): String;
var
  TempWord: String;
  WordLen: Integer;
  TempLen: Integer;
begin
  if Source = '' then
  begin
    ParseWord := '';
    WordIs := '';
    if (Count > 0) or (wtIs = wtComment) then wtIs := wtEOL
    else wtIs := wtNewLine;  // no word found in line
    exit;
  end;
  TempWord := StartOfWord(Source, Count, wtIs);
  case wtIs of
    wtEOL, wtNewLine:
      WordIs := '';
    wtText:
    begin
      WordIs := WholeWord(TempWord);
      Inc(Count);
    end;
  end; { case }
  WordLen := Length(WordIs);
  TempLen := Length(TempWord);
  if (WordLen < TempLen) and (WordLen > 0) then // return rest of line
    ParseWord := copy(TempWord, WordLen + 1, TempLen - WordLen)
  else
    ParseWord := '';  // end of line
end; { ParseWord }

{ returns the line as String, removes comments and determines line type }
(*function TPsyCheck.ParseLine(const Source: String; var Comment: String;
                    var ltIs: TLineType): TStrings;
var
  TempLine,
  WordIs: String;
  Count,
  OldCount,
  Index,
  LineLen: Integer;
  wtIs: TWordType;
  tmpLines: TStringList;
begin
{*******************************}
{ Must handle TStrings better, not freed properly }
  tmpLines := TStringList.Create;
  Count := 0;
  wtIs := wtBlank;
  TempLine := Source;
  WordIs := '';
  LineLen := Length(TempLine);
  tmpLines.Clear;
  { remove any comment from line }
  Index := pos(dfComment, TempLine);
  if Index > 0 then
  begin
    wtIs := wtComment;
    ltIs := ltComment;
    if Index < (LineLen -dfComLen +1) then  // ie not // at end of line
      Comment := copy(TempLine, Index +dfComLen, LineLen -Index-dfComLen +1)
    else
      Comment := ' ';  // use space for a blank line
    if Index > 1 then                 // rest of line without comment
      TempLine := copy(TempLine, 1, Index -1)
    else
      TempLine := '';
  end;
  { get each word }
  repeat
    OldCount := Count;
    TempLine :=  ParseWord(TempLine, WordIs, Count, wtIs);
    { fill missing values with blank in list }
    while OldCount < Count - 1 do
    begin
      tmpLines.Add('');
      Inc(OldCount);
    end;
    if (OldCount = Count - 1) and (WordIs = '') then
      tmpLines.Add('');  // missing value at end of line
    { handle words }
    if wtIs = wtText then
    begin
      tmpLines.Add(WordIs);
      if (ltIs = ltHeader) and (Count > 1) and isFloat(WordIs) then
            ltIs := ltData
      // read contrasts and assume rest of line is label
      // NumberOfGroups/Repeats should be known by this stage
      else if (ltIs = ltBContrast) and (Count = Arrays.NumberOfGroups) or
        (ltIs = ltWContrast) and (Count = Arrays.NumberOfRepeats) then
      begin  // get rest of line
        TempLine :=  ParseWord(TempLine, WordIs, Count, wtIs);
        tmpLines.Add(WordIs + TempLine);
        wtIs := wtEOL;
      end;
    end;
  until (wtIs = wtEOL) or (wtIs = wtNewLine);
  { Number of repeats = # words -1 in data or header }
  if ((ltIs = ltData) or (ltIs = ltHeader)) and
     (Arrays.NumberOfRepeats = 0) and (wtIs = wtEOL) then
    Arrays.NumberOfRepeats := Count -1;
  if wtIs = wtNewLine then
    ltIs := ltBlank;
  Result := tmpLines;
end; { ParseLine }
*)
(*
{ main procedure for converting memo to tab grids }
procedure TPsyCheck.CheckData(const Child: TMDIInChild);
var
  Lines:  TStrings;
  I,
  MaxLines,
  LineCount,
  lclRowCount,
  DataStart, BContStart, WContStart: Integer;
  Comment,
  TempLine: String;
  ltIs: TLineType;
begin
  with Arrays do
    begin
    NumberOfRepeats := 0;
    NumberOfGroups := 0;
    Lines := Child.ChildEdit.Lines;
    Comment := '';
    TempLine := '';

  	{ Reset grids }
	  with Child do
  	begin
	  	DataGrid.HasHeader := False;
		  DataGrid.GridReset;
  		BContGrid.GridReset;
	  	WContGrid.GridReset;
		  NotesMemo.Clear;
  	end;

    { find key words }
    DataStart := Lines.IndexOf(dfData) +1;  // +1 to ignore keyword line
    I := max(Lines.IndexOf(dfBCont1), Lines.IndexOf(dfBCont2));
    I := max(I, Lines.IndexOf(dfBCont3));
    BContStart := max(I, Lines.IndexOf(dfBCont4)) +1;
    I := max(Lines.IndexOf(dfWCont1), Lines.IndexOf(dfWCont2));
    I := max(I, Lines.IndexOf(dfWCont3));
    WContStart := max(I, Lines.IndexOf(dfWCont4)) +1;
    { if first keyword > line 0 then copy precedding lines to notes }
    if (DataStart > 1) then
    begin
      MaxLines := DataStart;
      if BContStart > 0 then MaxLines := min(DataStart, BContStart);
      if WContStart > 0 then MaxLines := min(MaxLines, WContStart);
      MaxLines := MaxLines -2;
      for LineCount := 0 to MaxLines do
      begin
        Comment := Lines[LineCount];
        if pos(dfComment, Comment) = 1 then  // remove // if at start of line
          Comment := copy(Comment, dfComLen+1, Length(Comment) - dfComLen);
        Child.NotesMemo.Lines.Add(Comment);
        Comment := '';
      end;
  end;
  { get Data }
  lclRowCount := 0;
  MaxLines := Lines.Count -1;
  if min(BContStart, WContStart) > DataStart then  // both after [Data]
    MaxLines := min(BContStart, WContStart) -2
  else if max(BContStart, WContStart) > DataStart then  // one after [Data]
    MaxLines := max(BContStart, WContStart) -2;
  {ltIs := ltData;}
  ltIs := ltHeader;  // assume header is first line of data
  for LineCount := DataStart to MaxLines do
  begin
    TempLine := ParseLine(Lines[LineCount], Comment, ltIs);
    if Comment <> '' then
    begin
      if Comment = ' ' then  // add blank line if comment is a single space
        Comment := '';
      Child.NotesMemo.Lines.Add(Comment);
      Comment := '';
    end;
    with Child.DataGrid do
    begin
      if ColCount < NumberOfRepeats + 3 then
        ColCount := NumberOfRepeats + 3;  // one extra
      case ltIs of
        ltComment:
          ltIs := ltData;
        ltHeader:
{          if HasHeader then  // should never occur
            // error
          else}
          begin  // #160 (#128 + #32) inserts blank cell before header
            Rows[1].CommaText := #160 + TempLine;
            HasHeader := True;
            ltIs := ltData;
          end;
        ltData:
        begin
          inc(lclRowCount);
          if RowCount < lclRowCount + 3 then
            RowCount := lclRowCount + 3;  // one extra
          Rows[lclRowCount +1].CommaText :=
            IntToStr(lclRowCount) + ',' + TempLine;
        end;
        ltBlank:  // assumes not blank b/w [Data] and header
          // if no keywords, assume blank delimits blocks
          if (BContStart < 1) and (WContStart < 1) and (DataStart < 1) then
          begin  //
            BContStart := LineCount +1;
            ltIs := ltBContrast;
            break;
          end
          else  // ignore blank lines
            ltIs := ltData
      end; { case }
    end; { with Child.DataGrid }
  end; { for }
  { count number of groups, repeats and set up grids }
  Child.DataGrid.CountData;
  if Child.BContGrid.ColCount < NumberOfGroups + 3 then
    Child.BContGrid.ColCount := NumberOfGroups + 3;  // one extra
  if Child.WContGrid.ColCount < NumberOfRepeats + 3 then
    Child.WContGrid.ColCount := NumberOfRepeats + 3;  // one extra
  { get Between Contrasts }
  if BContStart > 0 then
  begin
    lclRowCount := 0;
    MaxLines := Lines.Count -1;
    if min(DataStart, WContStart) > BContStart then
      MaxLines := min(DataStart, WContStart) -2
    else if max(DataStart, WContStart) > BContStart then
      MaxLines := max(DataStart, WContStart) -2;
    ltIs := ltBContrast;
    for LineCount := BContStart to MaxLines do
    begin
      TempLine := ParseLine(Lines[LineCount], Comment, ltIs);
      if Comment <> '' then
      begin
        Child.NotesMemo.Lines.Add(Comment);
        Comment := '';
      end;
      case ltIs of
        ltComment:
          ltIs := ltBContrast;
        ltBContrast:
        begin
          inc(lclRowCount);
          if Child.BContGrid.RowCount < lclRowCount + 2 then
            Child.BContGrid.RowCount := lclRowCount + 2;  // one extra
          Child.BContGrid.Rows[lclRowCount].CommaText :=
            'B' + IntToStr(lclRowCount) + ',' + TempLine;
        end;
        ltBlank:
          // if no [BContrast] keyword, blank delimits block
          if (WContStart < 1) and (BContStart < 1) then
          begin
            WContStart := LineCount +1;
            ltIs := ltWContrast;
            break;
          end
          else  // ignore blank lines
            ltIs := ltBContrast;
      end; { case }
    end; { for }
  end;
  Child.BContGrid.CountContrasts;
  { get Within Contrasts }
  if WContStart > 0 then
  begin
    lclRowCount := 0;
    MaxLines := Lines.Count -1;
    if min(DataStart, BContStart) > WContStart then
      MaxLines := min(DataStart, BContStart) -2
    else if max(DataStart, BContStart) > WContStart then
      MaxLines := max(DataStart, BContStart) -2;
    ltIs := ltWContrast;
    for LineCount := WContStart to MaxLines do
    begin
      TempLine := ParseLine(Lines[LineCount], Comment, ltIs);
      if Comment <> '' then
      begin
        Child.NotesMemo.Lines.Add(Comment);
        Comment := '';
      end;
      case ltIs of
        ltComment:
          ltIs := ltWContrast;
        ltWContrast:
        begin
          inc(lclRowCount);
          if Child.WContGrid.RowCount < lclRowCount + 2 then
            Child.WContGrid.RowCount := lclRowCount + 2;  // one extra
          Child.WContGrid.Rows[lclRowCount].CommaText :=
            'W' + IntToStr(lclRowCount) + ',' + TempLine;
        end;
        ltBlank:
          // error, add rest to end of W contrast Grid
          ltIs := ltWContrast;
      end; { case }
    end; { for }
  end;
  Child.WContGrid.CountContrasts;
  end;
  Child.IsRunnable := CanRun(Child);
end; { CheckData }
*)
(*
// convert input data to matricies for data analysis
procedure TPsyCheck.DataToMatrices(const Child: TMDIInChild);
var
  Count, x, ContCount,
  GroupIndex: Integer;
  CountSubs:  array of Integer;
  DataStr: String;
begin
  with Child do
  begin
    DataGrid.CountData;
    WContGrid.CountContrasts;
    BContGrid.CountContrasts;
  end;
  with Arrays do
  begin
  SetLength(SubjectIndexArray, NumberOfGroups + 1);
  SetLength(DataMatrix, SumOfSubjects + 1, NumberOfRepeats + 1);
  SetLength(CountSubs, NumberOfGroups + 1);
  for Count := 0 to NumberOfGroups do
  begin
    SubjectIndexArray[Count] := 0;
    CountSubs[Count] := 0;
  end;
  SubjectIndexArray[1] := 1;
  for Count := 2 to NumberOfGroups do
    SubjectIndexArray[Count] := SubjectIndexArray[Count - 1] +
                                SubjectArray[Count - 1];
  // get the data
  with Child.DataGrid do
  begin
    for Count := 2 to RowCount -2 do
    begin
      if RowState[Count] = rsOK then
      begin
        GroupIndex := GroupsList.IndexOf(Cells[1, Count]) + 1;
        for x := 1 to NumberOfRepeats do
        begin
          DataStr := Cells[x + 1, Count];
          try
            DataMatrix[(SubjectIndexArray[GroupIndex] + CountSubs[GroupIndex]), x]
              := StrToFloat(DataStr);
          except
            on EConvertError do exit;  // handle error
          end;
        end;
        inc(CountSubs[GroupIndex]);
        if CountSubs[GroupIndex] > SubjectArray[GroupIndex] then
          ;// error
      end; { if }
    end; { for }
  end;
  // get the B contrasts
  with Child.BContGrid do
  begin
    SetLength(BContrastArray, NumberOfBContrasts + 2, NumberOfGroups + 1);  // set to #rows first
    for x := 1 to NumberOfGroups do
      BContrastArray[1, x] := 1;  // B0 = 1
    ContCount := 1;
    for Count := 1 to RowCount -2 do
    begin
      if (RowState[Count] = rsOK) or (RowState[Count] = rsNot0Sum) then
      begin
        // if ContCount > NumberOfBContrasts then error
        for x := 1 to NumberOfGroups do
        begin
          DataStr := Cells[x, Count];
          try
            BContrastArray[ContCount + 1, x] := StrToInt(DataStr);
          except
            on EConvertError do exit;  // handle error
          end;
        end;
        inc(ContCount);
      end; { if }
    end; { for }
  end;
  // get the W contrasts
  with Child.WContGrid do
  begin
    SetLength(WContrastArray, NumberOfWContrasts + 2, NumberOfRepeats + 1);
    for x := 1 to NumberOfRepeats do
      WContrastArray[1, x] := 1;  // W0 = 1
    ContCount := 1;
    for Count := 1 to RowCount -2 do
    begin
      if (RowState[Count] = rsOK) or (RowState[Count] = rsNot0Sum) then
      begin
        // if ContCount > NumberOfWContrasts then error
        for x := 1 to NumberOfRepeats do
        begin
          DataStr := Cells[x, Count];
          try
            WContrastArray[ContCount + 1, x] := StrToInt(DataStr);
          except
            on EConvertError do exit;  // handle error
          end;
        end;
        inc(ContCount);
      end; { if }
    end; { for }
  end;
  end; { with Arrays }
end;
*)
(*
procedure TPsyCheck.DataToMemo(const Child: TMDIInChild);
var
  Lines: TStrings;
  r: Integer;

  function TabText(const RowText: TStrings): String;
  var
    c: Integer;
    tempStr: String;
  begin
    with RowText do
    begin
      tempStr := Strings[1];
      for c := 2 to Count -2 do
        tempStr := tempStr + ', ' + Strings[c];
    end;
    Result := tempStr;
  end;

begin
  with Child do
  begin
    Lines := ChildEdit.Lines;
    Lines.Clear;
    for r := 0 to NotesMemo.Lines.Count -1 do  // Comments
      Lines.Add(dfComment + NotesMemo.Lines.Strings[r]);
    if NotesMemo.Lines.Count > 0 then
      Lines.Add('');
		with DataGrid do
    begin
      Lines.Add('[Data]');
      for r := 0 to RowCount -1 do
        if RowState[r] <> rsBlank then
          Lines.Add(TabText(Rows[r]));
      Lines.Add('');
    end;
    with BContGrid do
    begin
      Lines.Add('[BetweenContrasts]');
      for r := 0 to RowCount -1 do
        if RowState[r] <> rsBlank then
          Lines.Add(TabText(Rows[r]));
      Lines.Add('');
    end;
    with WContGrid do
    begin
			Lines.Add('[WithinContrasts]');
			for r := 0 to RowCount -1 do
				if RowState[r] <> rsBlank then
					Lines.Add(TabText(Rows[r]));
		end;
		ChildEdit.SelStart := 0;
	end;
end;
*)
{==============================================================================}

{ true if data is ok for analysis }
function  TPsyCheck.CanRun(const Child: TMDIInChild): Boolean;
begin
  Result := False;  // assume error
  with Arrays do
  begin
    if (NumberOfGroups < 2) and (NumberOfRepeats < 2) then  // can't run
    begin
    	Warnings.Add(ewContrasts);
      Exit;
    end;
    if (SumOfSubjects - NumberOfGroups) <= 0 then  // ie df > 0
    begin
    	Warnings.Add(ewDf);
      Exit;
    end;
    if (NumberOfRepeats < 2) and (NumberOfBContrasts = 0) then  // need group contrast
    begin
    	Warnings.Add(ewGroup);
      Exit;
    end;
    if (NumberOfGroups < 2) and (NumberOfWContrasts = 0) then  // need rpts contrast
    begin
    	Warnings.Add(ewMeasure);
      Exit;
    end;
    if (NumberOfBContrasts > 0) or (NumberOfWContrasts > 0) then  // must have at least one contrast
      Result := True
    else
    	Warnings.Add(ewNoContrats);
  end;
end;

{ looks for header info to determine file type; 0 = IN, 1 = OUT, 2 = Unknown }
function TPsyCheck.IsPsyFile(FileName: String): Byte;
const
	lenIn: Integer = Length(PSYINHEADER);
	lenOut: Integer = Length(PSYOUTHEADER);
var
	FH: TextFile;
  Line: String;
begin
	AssignFile(FH, FileName);
	Reset(FH);
  Readln(FH, Line);  // read 1st line only
 	CloseFile(FH);
	// case insensitive test
 	// check only statrt of line in case more info used in header in latter versions
	if (CompareText(PSYINHEADER, Copy(Line, 1, lenIn)) = 0) then
 		Result := 0  // IN file
	else if(CompareText(PSYOUTHEADER, Copy(Line, 1, lenOut)) = 0) then
 		Result := 1  // OUT file
 	else
		Result := 2; // unknown
end;

procedure TPsyCheck.UpdateData(Win: TMDIChild);
var
	x: Integer;
begin
  with Win.ChildEdit, Lines do
  begin
  	BeginUpdate;
    x := SelStart;
		TabToMark(Win.ChildEdit.Lines);
    SelStart := x;  // stops scrolling during tab conversion
		EndUpdate;
  end;
  if Win is TMDIInChild then
  begin
    // Clear Warnings
    Warnings.Clear;
  	UpdateKeys(Win as TMDIInChild);  // don't check result since
  	EditToData(Win as TMDIInChild);  // data can change but have same keys
  end
  else
  	UpdateKeys(Win);
end;

{ convert to IN file, True on success }
function TPsyCheck.ConvertToPsy(Win: TMDIChild): Boolean;
{var
  i, j: Integer;
  tmpLine: TStrings;
  tmpStr: String;
  ltIs: TLineType;
  KeyList: TPsyKeyList;
}begin
  // find / determine keys
(*  UpdateKeys(Win, KeyList);
  with Win.ChildEdit.Lines, KeyList do
  begin
    { ignor anything before 1st key word as a comment }
    { find header }
    j := InKeyList[ptHeader].StartLine +1;  // nb +1
    i := j;
    repeat
      ltIs := ltHeader;
      tmpLine := ParseLine(Strings[i], tmpStr, ltIs);
      Inc(i);
    until (ltIs = ltHeader) or (i >= Count);
    Dec(i);
    if (ltIs = ltHeader) then
      Insert(i, dfHeader);
    if (j > 0) then  // remove existing header key
      Delete(j -1);
    { find start of data }
    j := InKeyList[ptData].StartLine +1;  // nb +1
    i := j;
    repeat
      ltIs := ltHeader;
      tmpLine := ParseLine(Strings[i], tmpStr, ltIs);
      Inc(i);
    until (ltIs = ltData) or (i >= Count);
    Dec(i);
    if (ltIs = ltData) then
      Insert(i, dfData);
    if (j > 0) then  // remove existing header key
      Delete(j -1);
    { find end of data }
    repeat
      ltIs := ltData;
      tmpLine := ParseLine(Strings[i], tmpStr, ltIs);
      Inc(i);
    until (ltIs = ltBlank) or (i >= Count);
    Dec(i);


  end;  // with Lines, KeyList
*)	Result := True;
end;

function TPsyCheck.KeyInfo(AStartLine, ALines: Integer): TKeyInfo;
begin
	with Result do
  begin
	  StartLine := AStartLine;
  	Lines := ALines;
  end;
end;

function TPsyCheck.UpdateKeys(Win: TMDIInChild): Boolean;
const
	lowKey: TInKeyTypes = Low(TInKeyTypes);
  highKey: TInKeyTypes = High(TInKeyTypes);
var
	i, j, f{, l} : Integer;
  x, y: TInKeyTypes;
	oldKeyList: TPsyInKeyList;
begin
  with Win, KeyList do
  begin
    Result := False;
	  if (ChildEdit = nil) or (ChildEdit.Lines = nil) then
    	Exit;
		// simple update that checks entire file each update
  	oldKeyList := InKeyList;
    for x := lowKey to highKey do
      InKeyList[x] := KeyInfo(-1,-1);  // -1 denotes empty
	  { look for [... instead of using IndexOf[...], assuming line count >> # keys
  	  also takes care of sorting key order }
	  // find '[' at 1st char of line and check for key word
    with ChildEdit, ChildEdit.Lines do
    begin
    	InKeyList[ptComment] := KeyInfo(0,0);  // assume comments
      x := ptComment;
      for i := 0 to Count -1 do
      begin
        if (Length(Strings[i]) > 0) {and (Strings[i][1] = '[')} then
        begin
        	j := 0;
          {f := 1;}
          f := 0;

          while (j < dfNumSearchKeys) and {(f <> 0)} (f = 0) do
          begin
          	{l := Length(dfSearchKeyList[j]);}
            f := Pos(LowerCase(dfSearchKeyList[j]), LowerCase(Strings[i]));
            {f := CompareText(Copy(Strings[i], 1, l), dfSearchKeyList[j]);}
            Inc(j);
          end;
          Dec(j);
          if {(f = 0)} (f > 0) then  // key found
          begin
          	case dfSearchKeyList[j][2] of  // use 1st char as type
  	          'H': y := ptHeader;
	            'D': y := ptData;
    	        'B': y := ptBetween;
      	      'W': y := ptWithin;
            else
              y := ptHeader;  // default, ***** programming error if this occurs
            end;  // case
            if (InKeyList[y].StartLine = -1) then  // only change on 1st occurance of key
            begin
              InKeyList[y].StartLine := i;  // store line number
              KeyList.InKeyList[x].Lines := i - InKeyList[x].StartLine;  // length of last section
              x := y;
            end;  // if InKeyList...
          end;  // while CompareText...
        end;  // if '['
      end;  // for i...
      InKeyList[x].Lines := Count - InKeyList[x].StartLine; // last key found has length to end
      if (InKeyList[ptComment].Lines = 0) then  // no assumed comment
        InKeyList[ptComment].StartLine := -1;
    end;  // with ChildEdit...
    // compare Key lists
    Result := False;
    for x := lowKey to highKey do
    begin
      if (InKeyList[x].StartLine <> oldKeyList[x].StartLine) then
        Result := True  // changed
      else if (InKeyList[x].Lines <> oldKeyList[x].Lines) then
        Result := True;  // changed
    end;  // while x...
  end;  // with Win...
end;

function TPsyCheck.UpdateKeys(Win: TMDIChild): Boolean;
const
	lowKey: TOutKeyTypes = low(TOutKeyTypes);
  highKey: TOutKeyTypes = high(TOutKeyTypes);
var
	i, j, k, f: Integer;
  x, y, z: TOutKeyTypes;
  oldKeyList: ^TPsyOutKeyList;
begin
  with Win, KeyList do
  begin
    Result := False;
	  if (ChildEdit = nil) or (ChildEdit.Lines = nil) then
    	Exit;
    New(oldKeyList);
		// simple update that checks entire file each update
  	oldKeyList^ := OutKeyList^;
    SetLength(OutKeyList^, 1);  // clear the array, must have at least 1 element
    for x := lowKey to highKey do
      OutKeyList^[0, x] := KeyInfo(-1,-1);  // -1 denotes empty
	  { look for [... instead of using IndexOf[...], assuming line count >> # keys
  	  also takes care of sorting key order }
	  // find '[' at 1st char of line and check for key word
    with ChildEdit, ChildEdit.Lines do
    begin
      x := ptTop;
      k := 0;
      for i := 0 to Count -1 do
      begin
        if (Length(Strings[i]) > 0) then
        begin
        	j := 0;
          f := 0;
          while (j < dfNumOutSearchKeys) and (f <= 0) do
          begin
            f := Pos(dfOutSearchKeyList[j], Strings[i]);
            Inc(j);
          end;
          Dec(j);
          if (f > 0) then  // key found
          begin
            y := TOutKeyTypes(j);
            // add new key info
            if (y = ptTop) and (OutKeyList^[k, y].Lines > -1) then
            begin
//********* Check this, fix for PSY 2000
            	if (i < Count -1) and (Pos(nvAnalysis, Strings[i +1]) > 0) then
              begin
	              Inc(k);
  	            SetLength(OutKeyList^, k +1);
    	          for z := lowKey to highKey do
      	          OutKeyList^[k, z] := KeyInfo(-1,-1);  // -1 denotes empty
              end;
            end;
            if (OutKeyList^[k, y].StartLine = -1) then  // only change on 1st occurance of key
            begin
              OutKeyList^[k, y].StartLine := i;  // store line number
              OutKeyList^[k, x].Lines := i - OutKeyList^[k, x].StartLine;  // length of last section
// lines for last entry not set properly yet
              x := y;
            end;
          end;  // if f > 0
        end;  // Length > 0
      end;  // for i...
			OutKeyList^[k, x].Lines := Count - OutKeyList^[k, x].StartLine; // last key found has length to end
    end;  // with ChildEdit...
    // compare Key lists
    Result := False;
    for i := 0 to High(OutKeyList^) do
    begin
      for x := lowKey to highKey do
      begin
        if (OutKeyList^[i, x].StartLine <> oldKeyList^[i, x].StartLine) then
          Result := True  // changed
        else if (OutKeyList^[i, x].Lines <> oldKeyList^[i, x].Lines) then
          Result := True;  // changed
        // if no Analysis header found add one at the top
        // this is important or TreeUpdate will crash
        if (i = 0) and (Result = True) and (x > lowKey) and
                     (OutKeyList^[i, x].StartLine > -1) and
                     (OutKeyList^[i, lowKey].StartLine < 0) then
         OutKeyList^[i, lowKey].StartLine := 0;
      end;  // for x...
    end;  // for i...
  end;  // with Win...
  Dispose(oldKeyList);
end;

function TPsyCheck.RowOK(Lines: TStrings; IsData: Boolean): Boolean;
var
  i, x: Integer;
begin
  Result := True;  // assume true
  with Lines do
  begin

    if IsData then
    begin
      if (Strings[0] = '') then  // blank group label
        Result := False;
      i := 1;  // data, 2nd col to last
      x := Count;
    end
    else
    begin
      i := 0;  // contrast, 1st col to 2nd last
      x := Count -1;
    end;

    while (i < x) and Result do
    begin
      if not isFloat(Strings[i]) then
        Result := False;
      Inc(i);
    end;
  end;
end;

procedure TPsyCheck.EditToData(Win: TMDIInChild);
var
  EdLines:  TStrings;
  i, j, GroupIndex, ContCount: Integer;
  tmpStr: String;
  tmpLines, tmpParse: TStringList;
//  ltIs: TLineType;
//  FirstTime: Boolean;
begin
	tmpLines := nil;
  tmpParse := nil;
  try
    tmpLines := TStringList.Create;
    tmpParse := TStringList.Create;
    with Arrays, Win, KeyList do
    begin
      // init
      NumberOfRepeats := 0;
      NumberOfGroups := 0;
      SumOfSubjects := 0;
      NumberOfBContrasts := 0;
      NumberOfWContrasts := 0;
      GroupsList.Clear;
      EdLines := ChildEdit.Lines;

      { get header }
      i := InKeyList[ptHeader].StartLine;
      j := InKeyList[ptHeader].Lines;
      if (i > -1) then
      begin
  //      ltIs := ltHeader;
  //      Header := (ParseLine(EdLines.Strings[i+1], tmpStr, ltIs) as TStringList);
        LinesToParse(EdLines, i +1, j -1, tmpParse, 0);
        i := 0;
        while (i < j) and (tmpParse.Strings[i] = '') do Inc(i);  // skip blanks
        if (tmpParse.Strings[i] <> '') then
          Header.CommaText := tmpParse.Strings[i];
      end;

      { get data }
      with InKeyList[ptData] do
      begin
        if (StartLine > -1) then
        begin
          // init
          SetLength(SubjectArray, Lines +1);  // indexed from 1
          for i := 0 to Lines do
            SubjectArray[i] := 1;  // if group exists then at least 1 subject
          SetLength(SubjectIndexArray, Lines +1);
          SubjectIndexArray[0] := 0;

          LinesToParse(EdLines, StartLine +1, Lines -1, tmpParse, 0);
          NumberOfRepeats := ColumnCount(tmpParse) -1;
          SetLength(DataMatrix, Lines +1, NumberOfRepeats +1);
//          FirstTime := True;

          // count & get group labels, convert data
//          ltIs := ltData;
          // StartLine +1 to skip key word and Lines -1 is last data line
//          for i := (StartLine +1) to (StartLine +Lines -1) do
          for i := 0 to Lines -1 do
          begin
            // ParseLine sets NumberOfRepeats
//            tmpLines := ParseLine(EdLines.Strings[i], tmpStr, ltIs);
//            if (ltIs = ltData) then
            if (i < tmpParse.Count) and (tmpParse.Strings[i] <> '') then
            begin
              // set size on first time
//              if FirstTime then
//              begin
//                SetLength(DataMatrix, Lines +1, NumberOfRepeats +1);
//                FirstTime := False;
//              end;
              tmpLines.CommaText := tmpParse.Strings[i];
              // remove trailing delimitor if any
              if (tmpLines.Strings[tmpLines.Count -1] = '') then
              	tmpLines.Delete(tmpLines.Count -1);
              if RowOK(tmpLines, True) and
               (tmpLines.Count = NumberOfRepeats +1) then
              begin
                inc(SumOfSubjects);
                tmpStr := tmpLines.Strings[0];
                // update Group info
                GroupIndex := GroupsList.IndexOf(tmpStr) +1;  // nb +1
                if (GroupIndex < 1) then  // Group not in list so add to list
                begin
                  GroupsList.Add(tmpStr);
                  inc(NumberOfGroups);
                  SubjectIndexArray[NumberOfGroups] :=
                                          SubjectIndexArray[NumberOfGroups - 1] +
                                          SubjectArray[NumberOfGroups - 1];
                end
                else                      // count subs per group
                begin
                  inc(SubjectArray[GroupIndex]);
                end;
                // convert data
                for j := 1 to NumberOfRepeats do
                  // NumberOfGroups is running count at this stage, not total
                  DataMatrix[(SubjectIndexArray[NumberOfGroups] +
                              SubjectArray[NumberOfGroups] -1), j] :=
                    StrToFloat(tmpLines.Strings[j]);
              end  // if RowOK
              // else mark as invalid line
              else
              begin
                Warnings.Add('Line ' + IntToStr(i + StartLine +2) + ': ' + ewBadData);
              end;
            end;  // if ltData
//            ltIs := ltData;  // allow blank lines
          end;  // for i...
          // now have total NumberOfGroups & SumOfSubjects
          // resize arrays
          SubjectArray := Copy(SubjectArray, 0, NumberOfGroups +1);
          SubjectIndexArray := Copy(SubjectIndexArray, 0, NumberOfGroups +1);
          DataMatrix := Copy(DataMatrix, 0, SumOfSubjects +1);
        end;  // if StartLine...
      end;  // with ptData

      // don't do contrasts unless valid data
      if (NumberOfGroups < 1) or (NumberOfRepeats < 1) then
      begin
        Warnings.Add(ewNoData);
        Exit;
      end;

      { get Between contrasts }
      with InKeyList[ptBetween] do
      begin
        if (StartLine > -1) then
        begin
          BetweenComments.Clear;
          BetweenComments.Add('');  // B0 has no comment
          SetLength(BContrastArray, Lines +2, NumberOfGroups +1);
          for i := 1 to NumberOfGroups do
            BContrastArray[1, i] := 1;  // B0 = 1
          ContCount := 1;
//          ltIs := ltBContrast;
          LinesToParse(EdLines, StartLine +1, Lines -1, tmpParse, NumberOfGroups);
//          for i := (StartLine +1) to (StartLine +Lines -1) do
          for i := 0 to Lines -1 do
          begin
//            tmpLines := ParseLine(EdLines.Strings[i], tmpStr, ltIs);
//            if (ltIs = ltBContrast) then
            if (i < tmpParse.Count) and (tmpParse.Strings[i] <> '') then
            begin
              tmpLines.CommaText := tmpParse.Strings[i];
              if (tmpLines.Count = NumberOfGroups) then
              	tmpLines.Add('');  // if no lable, add blank
              if RowOK(tmpLines, False) and
               (tmpLines.Count >= NumberOfGroups) then
              begin;
                Inc(NumberOfBContrasts);
                for j := 1 to NumberOfGroups do
                  try
                    BContrastArray[ContCount + 1, j] := StrToInt(tmpLines.Strings[j-1]);
                  except
                    on EConvertError do
                    begin
                      Warnings.Add(ewIntContrasts);
                      Exit;
                    end;
                  end;
                // convert any tab marks to space
                tmpLines.Strings[NumberOfGroups] :=
                  StringReplace(tmpLines.Strings[NumberOfGroups], '»', ' ',
                    [rfReplaceAll, rfIgnoreCase]);
                BetweenComments.Add(tmpLines.Strings[NumberOfGroups]);
                inc(ContCount);
              end
              else
              begin
                Warnings.Add('Line ' + IntToStr(i + StartLine +2) + ': ' + ewBadCont);
              end;
            end;
//            ltIs := ltBContrast;
          end;
          BContrastArray := Copy(BContrastArray, 0, NumberOfBContrasts + 2);
        end  // if StartLine...
        else  // always need B0
        begin
          BetweenComments.Clear;
          BetweenComments.Add('');  // B0 has no comment
                                 // nb indexed from 1, so need 2 elements
          SetLength(BContrastArray, 2, NumberOfGroups +1);
          for i := 1 to NumberOfGroups do
            BContrastArray[1, i] := 1;  // B0 = 1
        end;
      end;

      { get Within contrasts }
      with InKeyList[ptWithin] do
      begin
        if (StartLine > -1) then
        begin
          WithinComments.Clear;
          WithinComments.Add('');  // W0 has no comment
          SetLength(WContrastArray, Lines +2, NumberOfRepeats +1);
          for i := 1 to NumberOfRepeats do
            WContrastArray[1, i] := 1;  // W0 = 1
          ContCount := 1;
//          ltIs := ltWContrast;
//          for i := (StartLine +1) to (StartLine +Lines -1) do
          LinesToParse(EdLines, StartLine +1, Lines -1, tmpParse, NumberOfRepeats);
          for i := 0 to Lines -1 do
          begin
//            tmpLines := ParseLine(EdLines.Strings[i], tmpStr, ltIs);
//            if (ltIs = ltWContrast) then
            if (i < tmpParse.Count) and (tmpParse.Strings[i] <> '') then
            begin
  	          tmpLines.CommaText := tmpParse.Strings[i];
              if (tmpLines.Count = NumberOfRepeats) then
              	tmpLines.Add('');  // if no lable, add blank
              if RowOK(tmpLines, False) and
               (tmpLines.Count >= NumberOfRepeats) then
              begin
                Inc(NumberOfWContrasts);
                for j := 1 to NumberOfRepeats do
                  try
                    WContrastArray[ContCount + 1, j] := StrToInt(tmpLines.Strings[j-1]);
                  except
                    on EConvertError do
                    begin
                      Warnings.Add(ewIntContrasts);
                      Exit;
                    end;
                  end;
                // convert any tab marks to space
                tmpLines.Strings[NumberOfRepeats] :=
                  StringReplace(tmpLines.Strings[NumberOfRepeats], '»', ' ',
                    [rfReplaceAll, rfIgnoreCase]);
                WithinComments.Add(tmpLines.Strings[NumberOfRepeats]);
                inc(ContCount);
              end
              else
              begin
                Warnings.Add('Line ' + IntToStr(i + StartLine +2) + ': ' + ewBadCont);
              end;
            end;
//            ltIs := ltWContrast;
          end;
          WContrastArray := Copy(WContrastArray, 0, NumberOfWContrasts + 2);
        end  // if StartLine
        else  // must have W0
        begin
          WithinComments.Clear;
          WithinComments.Add('');  // W0 has no comment
                                 // nb need 2 elements
          SetLength(WContrastArray, 2, NumberOfRepeats +1);
          for i := 1 to NumberOfRepeats do
            WContrastArray[1, i] := 1;  // W0 = 1
        end;
      end;  // with ptWithin
      IsRunnable := CanRun(Win);
    end;  // with Arrays, Win, KeyList
  finally
  	tmpLines.Free;
    tmpParse.Free;
  end;
end;

procedure TPsyCheck.InitKeyList(Win: TMDIInChild);
const
	lowKey: TInKeyTypes = low(TInKeyTypes);
  highKey: TInKeyTypes = high(TInKeyTypes);
var
  i: TInKeyTypes;
begin
  with Win.KeyList do
    for i := lowKey to highKey do
      InKeyList[i] := KeyInfo(-1,-1);  // -1 denotes empty
end;

procedure TPsyCheck.InitKeyList(Win: TMDIChild);
const
	lowKey: TOutKeyTypes = low(TOutKeyTypes);
  highKey: TOutKeyTypes = high(TOutKeyTypes);
var
  i: TOutKeyTypes;
begin
  with Win.KeyList do
  begin
    SetLength(Win.KeyList.OutKeyList^, 1);
    for i := lowKey to highKey do
      Win.KeyList.OutKeyList^[0, i] := KeyInfo(-1,-1);  // -1 denotes empty
  end;
end;

// convert tabs to '»' mark
procedure TPsyCheck.TabToMark(Lines: TStrings);
var
	i: Integer;
  tmpText: TStringList;
begin
	// safest to do search & replace line by line
  // or otherwise tabs may not be handled properly
  tmpText := TStringList.Create;
	tmpText.CommaText := Lines.CommaText;
  with tmpText do
	  for i := 0 to Count -1 do
    	Strings[i] := StringReplace(Strings[i], #9, '»',
      	[rfReplaceAll, rfIgnoreCase]);
  Lines.CommaText := tmpText.CommaText;
  tmpText.Free;
end;

// convert '»' mark to tab
procedure TPsyCheck.MarkToTab(Lines: TStrings);
var
	i: Integer;
  tmpText: TStringList;
begin
	// safest to do search & replace line by line
  // or otherwise tabs may not be handled properly
  tmpText := TStringList.Create;
	tmpText.CommaText := Lines.CommaText;
  with tmpText do
	  for i := 0 to Count -1 do
    	Strings[i] := StringReplace(Strings[i], '»', #9,
      	[rfReplaceAll, rfIgnoreCase]);
  Lines.CommaText := tmpText.CommaText;
  tmpText.Free;
end;

{====================}
{ New Parse routines }

// convert a string to stringList with a word per string, returned as comma text
// ignore everything once MinCols found, MinCols = 0 -> convert all
function TPsyCheck.LineToStringList(Source: String; MinCols: Integer): String;
var
	i, wrdStart, Cols: Integer;
	SrcLen: Integer;
  wtIs, lastWt: TWordType;
	tmpStrList: TStringList;
begin
	if (Source = '') then
  begin
  	Result := '';
    Exit;
  end;

	tmpStrList := nil;  // avoids compiler warning
  try
  tmpStrList := TStringList.Create;
  SrcLen := Length(Source);
  i := 1;
  Cols := 0;
  wrdStart := 0;
  lastWt := wtBlank;

  while (i <= SrcLen) do
 	begin
    wtIs := WordType(Source[i]);
    // end of preceding word
  	if (wrdStart > 0) and (wtIs = wtBlank) then
    begin
    	tmpStrList.Add(Copy(Source, wrdStart, i - wrdStart));
      wrdStart := 0;
      Inc(Cols);
    end;

    // skip blanks
    while (wtIs = wtBlank) and (i < SrcLen) do
    begin
    	Inc(i);
	    wtIs := WordType(Source[i]);
    end;

    // start of text, record start
    if (wrdStart = 0) and (wtIs = wtText) then
    begin
    	wrdStart := i;
      lastWt := wtText;
    end;
    // delimitor, end text or add blank
    if (wtIs = wtDelimitor) then
    begin
      // end of word
    	if (wrdStart > 0) then
      begin
      	tmpStrList.Add(Copy(Source, wrdStart, i - wrdStart));
	      wrdStart := 0;
  	    Inc(Cols);
      end
       // delimiter without preceding word, add blank
      else if (lastWt = wtDelimitor) then
      begin
      	tmpStrList.Add('');  // blank
	      Inc(Cols);
      end;
      lastWt := wtDelimitor;
    end;
    if (MinCols > 0) and (Cols >= MinCols) then
      break;
    Inc(i);
  end;  // while
  if (MinCols > 0) and (Cols >= MinCols) then
   	tmpStrList.Add(Copy(Source, i, SrcLen - i +1))
  else if (wrdStart > 0) then
   	tmpStrList.Add(Copy(Source, wrdStart, i - wrdStart))
  else if (lastWt = wtDelimitor) then
   	tmpStrList.Add('');  // blank

 	Result := tmpStrList.CommaText;
  finally
  	tmpStrList.Free;
  end;
end;

// convert the lines of data to an array of stringlists for parsing
procedure TPsyCheck.LinesToParse(Source: TStrings; Index, Count: Integer;
                                 Dest: TStringList; MinCols: Integer);
var
	i: Integer;
begin
	Dest.Clear;
  for i := Index to Index + Count -1 do
 	  Dest.Add(LineToStringList(Source.Strings[i], MinCols));
end;

// determine majority count of columns
function TPsyCheck.ColumnCount(Source: TStrings): Integer;
type
	TFreqCount = record
  	Value, Count: Integer;
  end;
var
	delimAtEnd, newCount: Boolean;
	i, j, k: Integer;
	countArr: array of TFreqCount;
  tmpLine: TStringList;
begin
	tmpLine := nil;
  try
  	SetLength(countArr, 1);
  	tmpLine := TStringList.Create;
    tmpLine.Clear;
	  j := -1;  // denote 1st time
    delimAtEnd := True;  // assume all lines end with a delimitor
		for i := 0 to Source.Count -1 do
	  begin
    	if (Source.Strings[i] <> '') then
      begin
	    	tmpLine.CommaText := Source.Strings[i];
        k := tmpLine.Count;
        // keep check of delimiters at end of line
        if (k > 0) and (tmpLine.Strings[k -1] <> '') then
        	delimAtEnd := False;
        // store count frequency
        if (j < 0) then
        begin
          countArr[0].Value := k;
          countArr[0].Count := 1;
        end
        else
        begin
        	newCount := True;
          j := 0;
        	while (j < Length(countArr)) do
          begin
          	// existing value, inc count
          	if (k = countArr[j].Value) then
            begin
            	newCount := False;
              Inc(countArr[j].Count);
              break;
            end;
            Inc(j);
          end;
          // new value
          if (newCount) then
          begin
          	SetLength(countArr, Length(countArr) +1);
            countArr[High(countArr)].Value := k;
            countArr[High(countArr)].Count := 1;
          end;
          j := 0;
        end;  // if j < 0 ... else ...
      end;
	  end;  // for...
    // find most frequent
    j := -1;
    k := -1;
    for i := 0 to High(countArr) do
    begin
      if (countArr[i].Count > k) then
      begin
      	k := countArr[i].Count;  // track count of most frequent
        j := countArr[i].Value;  // track value of mosr frequent
      end;
    end;
    // ignore delimiters at end?
    if (delimAtEnd) then
    	Result := j -1
    else
    	Result := j;

  finally
  	tmpLine.Free;
  end;
end;

{==============================================================================}
initialization
  PsyCheck := TPsyCheck.Create;
finalization
  PsyCheck.Free;
end.

