unit PsyFile;

interface

uses
   Classes, Math, Forms, SysUtils, Dialogs,
   ChildWin, InChildWin, Defines;

type
  TPsyOut = class(TObject)
  private
  protected
    InChild:  TMDIInChild;
    OutChild: TMDIChild;
    Lines: TStrings;
{    BetweenComments,
    WithinComments: TStrings; }
    procedure GenerateOutput;
    procedure WriteHeader;
    procedure Summary;
    procedure Contrasts;
    procedure SummaryStats;
    procedure Anova;
    procedure ConfidenceIntervals;
    procedure WriteBetweenScores;
    procedure WriteConfidenceInterval;
    procedure WriteScaledBContrastCoeffs;
    procedure WriteScaledWContrastCoeffs;
    procedure WriteStandardisedCI(Divisor: Float);
    procedure WriteWithinScores;
  public
  	constructor Create;
    procedure WriteSummaryToMemo(InWin: TMDIInChild; OutWin: TMDIChild);
  end;

  TPsyCalc = class(TObject)
  private
  protected
    function CalculateF(const Alpha,DFD,NDF : Float): Float;
    procedure CalculateFinalSampleValue;
    procedure CalculateSumSquaresWithinGroupsArray;
    procedure CalculateGroupMeansOnRepeatContrasts;
    function CalculateW(const AContrastNumber: integer): Float;
    function GetAnovaValue(const AContrastNumber, BContrastNumber: integer): Float;
    procedure GetMeanAndStDev(const MatrixStartRow, MatrixEndRow, MatrixStartCol, MatrixEndCol: integer;
          RawScore: Boolean; var Mean, StDev: Float);
    function GetMeanofNormalisedRepeatContrast(const NumberOfGroup, NumberOfContrast: integer): Float;
    function GetMeansAcrossGroups: string;
    function GetMeansString(const NumOfGroup: integer): string;
    procedure GetNormalisedContrastScores;
    function GetNormMatrixScore(const RowCounter, ColCounter: integer): Float;
    function GetSampleValue(const AContrastNumber, BContrastNumber: integer): Float;
    function GetSSErrorValue(const BContrast: integer): Float;
    function GetStDevString(const NumOfGroup: integer): string;
    procedure NormaliseBCoefficients;
    function SSOfBcontrasts(const BContrastNumber: integer): Float;
    function SumOfPositiveAcontrasts(const AContrastNumber: integer): Float;
    function SumOfPositiveBContrasts(const BContrastNumber: integer): Float;
  public
  end;

var
	PsyOut: TPsyOut;
  PsyCalc: TPsyCalc;
//function PsyOut: TPsyOut;    // ensures existance of PsyOut class
//function PsyCalc: TPsyCalc;  // PsyCalc class

implementation

{$SAFEDIVIDE ON}

uses
   DlgAnalysis,  ArraysClass,
   FforPsy, SMR, GCR, Main;

var
//  FPsyOut: TPsyOut;
//  FPsyCalc: TPsyCalc;

  NewWContrastArray            : array of array of Float; {NewBContrastsArray;}
  NormalisedDataMatrix         : array of array of Float; {NormalisedDataMatrixArray;}
  SumSquaresWithinGroupsArray  : array of Float;
  SumSquaresArray              : array of Float;
  MeanMatrix                   : array of array of Float;
  GroupMeansOnRepeatContrasts  : array of array of Float;
  StandardError                : array of array of Float; {StandardErrorMatrix;}
  SampleValue                  : array of array of Float; {SampleValueMatrix;}
  FinalSampleValue             : array of array of Float;
  LowerLimits                  : array of array of Float;
  UpperLimits                  : array of array of Float;
  DeviationMatrix              : array of array of Float;
  SumsOfSquaresMatrix          : array of array of Float;
  ReScaleFactor                : Integer;

{
  PsyOut class
  used to generate and output Psy analysis
}

constructor TPsyOut.Create;
begin
	Arrays.ClearAll;
end;

{ Writes all summary information to the Main.Memo component.
  Summary info includes the user's input into the data matrix }
procedure TPsyOut.WriteSummaryToMemo(InWin: TMDIInChild; OutWin: TMDIChild);
var
	OldStart: Integer;

begin
//  AnalysisDlg.Close;
  InChild := InWin;
  OutChild := OutWin;
{  with InChild do
  begin
    BetweenComments := BContGrid.Cols[BContGrid.ColCount -2];
    WithinComments := WContGrid.Cols[WContGrid.ColCount -2];
  end;
}  with OutChild do
  begin
    Lines := ChildEdit.Lines;
    // force draw of out edit to speed up output
    // makes a big difference
    ChildEdit.SetFocus;
    Show;
    Refresh;

		try
    try
    // generate output
    Lines.BeginUpdate;  // prevent repaint during update
    // store pos of last line
    OldStart := Length(Lines.Text);
    ChildEdit.SelStart := OldStart;
    GenerateOutput;  // do it
    // put cursor back to start of new output
    ChildEdit.SelStart := OldStart;
    finally
	    Lines.EndUpdate;  // allow repaint
    end;
    except
    	MessageDlg('An error occured during analysis calculations.', mtError, [mbOK], 0);
    end;
    // show output
    ActiveControl := ChildEdit;
    ChildEdit.SetFocus;
    Show;  // bring Out window to front
  end;
end;

procedure TPsyOut.GenerateOutput;
begin
  with Arrays do
  begin
    SetLength(NewWContrastArray, NumberOfWContrasts + 2, NumberOfRepeats + 1);
    SetLength(NormalisedDataMatrix, SumOfSubjects + 1, NumberOfWContrasts + 2);
    SetLength(SumSquaresWithinGroupsArray, NumberOfRepeats + 1);
    SetLength(SumSquaresArray, NumberOfWContrasts + 2);
    SetLength(MeanMatrix, NumberOfRepeats + 1, NumberOfGroups + 1);
    SetLength(GroupMeansOnRepeatContrasts, NumberOfGroups + 1, NumberOfWContrasts + 2);
    SetLength(StandardError, NumberOfBContrasts + 2, NumberOfWContrasts + 2);
    SetLength(SampleValue, NumberOfBContrasts + 2, NumberOfWContrasts + 2);
    SetLength(FinalSampleValue, NumberOfWContrasts + 2, NumberOfBContrasts + 2);
    SetLength(LowerLimits, NumberOfWContrasts + 2, NumberOfBContrasts + 2);
    SetLength(UpperLimits, NumberOfWContrasts + 2, NumberOfBContrasts + 2);
    SetLength(DeviationMatrix, SumOfSubjects + 1, NumberOfRepeats + 1);
    SetLength(SumsOfSquaresMatrix, NumberOfRepeats + 1, NumberOfGroups + 1);

    WriteHeader;
    Summary;
    Contrasts;
    SummaryStats;

    PsyCalc.CalculateGroupMeansOnRepeatContrasts;
    PsyCalc.CalculateFinalSampleValue;

    Anova;
    ConfidenceIntervals;
    Lines.Add('');

    ClearAll;
  end;
end;

procedure TPsyOut.WriteHeader;
var
  strDateTime: String;
  len, lenMax: Integer;
begin
  // find longest string
  lenMax := Length(dfHeaderInfo);
  len := Length(' Title: ' + AnalysisDlg.Txt_Title.Text);
  if len > lenMax then
    lenMax := len;
  strDateTime := ' Date:  ' + DateToStr(Date) + ' Time: ' + TimeToStr(Time);
  len := Length(strDateTime);
  if len > lenMax then
    lenMax := len;
  len := Length(' File:  ' + InChild.FileName);
  if len > lenMax then
    lenMax := len;
  // write header info
  Lines.Add(StringOfChar('=', lenMax +1));
  // centre pro title
  len := trunc((lenMax - Length(dfHeaderInfo))/2);
  Lines.Add(format('%*s%s', [len, '', dfHeaderInfo]));
  Lines.Add(StringOfChar('=', lenMax +1));
  if AnalysisDlg.Txt_Title.Text <> '' then
    Lines.Add(' Title: ' + AnalysisDlg.Txt_Title.Text);
  Lines.Add(strDateTime);
  if InChild.FileName <> '' then
    Lines.Add(' File:  ' + InChild.FileName);
  Lines.Add(StringOfChar('-', lenMax +1));
  Lines.Add('');
end;

procedure TPsyOut.Summary;
var
   i: Integer;
begin
  // write summary info
	Lines.Add(Format(' Number of Groups:       %2d',
									 [Arrays.NumberOfGroups]));
	Lines.Add(Format(' Number of Measurements: %2d',
                   [Arrays.NumberOfRepeats]));
  Lines.Add('');
  Lines.Add(' Number of subjects in...');
  with Arrays do
    for i := 1 to NumberOfGroups do
      Lines.Add(format('  Group %2d:  %2d',
                       [i, SubjectArray[i]]));
  Lines.Add('');
end;

procedure TPsyOut.Contrasts;
var
  g,b,r,w, tmpVal: Integer;
  tmpString: String;
  FirstWarn: Boolean;
begin
  with Arrays, {Lines,} PsyCalc do
  begin
    // Between Contrasts
    if (NumberOfBContrasts > 0) then
    begin
     Lines.Add(' Between contrast coefficients');
      tmpString := '';
      for g := 1 to NumberOfGroups do
        tmpString := tmpString +Format('  %3d', [g]);
     Lines.Add('         Contrast     Group...');
     Lines.Add('                  ' + tmpString);
      for b := 2 to NumberOfBContrasts + 1 do
      begin
        tmpString := '';
        for g := 1 to NumberOfGroups do
          tmpString := tmpString +Format('  %3d',
            [Trunc(BContrastArray[b, g])]);
       Lines.Add(Format('  %-*.*s B%-2d%s',[dfLblWid, dfLblWid,
                   Arrays.BetweenComments[b - 1], b - 1, tmpString]));
      end;
      FirstWarn := True;
      for b := 2 to NumberOfBContrasts + 1 do
      begin
        tmpVal := 0;
        for g := 1 to NumberOfGroups do
          tmpVal := tmpVal + Trunc(BContrastArray[b, g]);
        if tmpVal <> 0 then
        begin
          if FirstWarn then
          begin
           Lines.Add('');
           Lines.Add('  *** Caution ***');
            FirstWarn := False;
          end;
         Lines.Add(Format('  B%-2d coefficients do not sum to zero', [b -1]));
        end;
      end;
    end;
    // Within Contrasts
    if (NumberOfWCOntrasts > 0) then
    begin
      if (NumberOfBContrasts > 0) then
       Lines.Add('');
     Lines.Add(' Within contrast coefficients');
      tmpString := '';
      for r := 1 to NumberOfRepeats do
        tmpString := tmpString +Format('  %3d', [r]);
     Lines.Add('         Contrast     Measurement...');
     Lines.Add('                  ' + tmpString);
      for w := 2 to NumberOfWContrasts + 1 do
      begin
        tmpString := '';
        for r := 1 to NumberOfRepeats do
          tmpString := tmpString +Format('  %3d', [Trunc(WContrastArray[w, r])]);
       Lines.Add(Format('  %-*.*s W%-2d%s',[dfLblWid, dfLblWid,
                   WithinComments[w - 1], w - 1, tmpString]));
      end;
      FirstWarn := True;
      for w := 2 to NumberOfWContrasts + 1 do
      begin
        tmpVal := 0;
        for r := 1 to NumberOfRepeats do
          tmpVal := tmpVal + Trunc(WContrastArray[w, r]);
        if tmpVal <> 0 then
        begin
          if FirstWarn then
          begin
           Lines.Add('');
           Lines.Add('  *** Caution ***');
            FirstWarn := False;
          end;
         Lines.Add(Format('  W%-2d coefficients do not sum to zero', [w -1]));
        end;
      end;
    end;
  end; { with }
end;

procedure TPsyOut.SummaryStats;
var
  RepeatHeader, TempString: string;
  PV_Mean, PV_StDev: Float;
  iCounter, iCounter1: integer;
  ValueString: string;
  i: integer;
  Val: Float;
begin
  RepeatHeader := '';
  Lines.Add('');
  Lines.Add(' Means and Standard Deviations');
  with Arrays, PsyCalc do
  begin
    for iCounter1 := 1 to NumberOfRepeats do
      RepeatHeader := RepeatHeader + format(' %*d%*s',
              [(prLead +2), iCounter1,  // place # above decimal pts
               prFigs, '']); // pads with prFigs space
    RepeatHeader := '   Measurement' + Copy(RepeatHeader, prLead, Length(RepeatHeader));
    for iCounter := 1 to NumberOfGroups do
    begin
      PV_Mean := 0;
      PV_StDev := 0;
      if iCounter = 1 then
        GetMeanAndStDev(SubjectIndexArray[iCounter], SubjectArray[iCounter], 1,
                  NumberOfRepeats, True, PV_Mean, PV_StDev)
      else
        GetMeanAndStDev(SubjectIndexArray[iCounter], (SubjectIndexArray[iCounter] +
                 SubjectArray[iCounter] - 1), 1, NumberOfRepeats, True, PV_Mean, PV_StDev);
      GroupMeansOnRepeatContrasts[iCounter, 1] := PV_Mean;
      Lines.Add(format('  Group %d  Overall Mean: %s',
                 [iCounter, FtoStr(PV_Mean, prLead, prFigs)]));
      Lines.Add(RepeatHeader);
      Lines.Add(GetMeansString(iCounter));
      Lines.Add(GetStDevString(iCounter));
      Lines.Add('');
    end;
    TempString :=  '   Mean  ';
    Lines.Add(' Means and SDs averaged across groups');
    RepeatHeader := '';
    for i := 1 to NumberOfRepeats do
    begin
      RepeatHeader := RepeatHeader + format(' %*d%*s',
          [(prLead +2), i,  { place # above decimal pt }
           prFigs, '']);   // pads with prFigs space
      Val := 0;
      for iCounter1 := 1 to NumberOfGroups do
      begin
        Val := Val + MeanMatrix[i, iCounter1]
      end;
      Val := Val/NumberOfGroups;
      TempString := TempString + ' ' + FtoStr(Val, prLead, prFigs);
    end;
    RepeatHeader := '   Measurement' + Copy(RepeatHeader, prLead, Length(RepeatHeader));;
    Lines.Add(RepeatHeader);
    Lines.Add(TempString);
    CalculateSumSquaresWithinGroupsArray;
    ValueString := '';
    for i := 1 to NumberOfRepeats do
    begin
      ValueString := ValueString + ' ' +
                     FtoStr(SumSquaresWithinGroupsArray[i], prLead, prFigs);
    end;
    ValueString := '   SD    ' +  ValueString;
    Lines.Add(ValueString)
  end;
  Lines.Add(' ' + StringOfChar('-', Length(ValueString) -1));
end;

procedure TPsyOut.Anova;
var
  Tempstring: string;
begin
  Lines.Add('');
  Lines.Add(format(' %*s Analysis of Variance Summary Table', [dfLblWid, '']));
  Lines.Add('');
  Tempstring := format('Source  %*s%*s  %3s %*s%*s %*s%*s',
    [(prLead +2), 'SS', prFigs, '',
     'df',
     (prLead +2), 'MS', prFigs, '',
     (prLead +2), 'F', prFigs, '']);
  Lines.Add(format(' %*s ', [dfLblWid, '']) +Tempstring);
  Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', length(Tempstring)));
  WriteBetweenScores();
  Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', length(Tempstring)));
  if Arrays.NumberOfWContrasts > 0 then
  begin
    Lines.Add(format(' %*s Within', [dfLblWid, '']));
    Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', length(Tempstring)));
    WriteWithinScores();
    Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', length(Tempstring)));
  end;
end;

procedure TPsyOut.ConfidenceIntervals;
   function meanSD(): Float;
   var
      i: integer;
      tempdbl: Float;
   begin
      tempdbl := 0.0;
      with Arrays do
      begin
      for i := 1 to NumberOfRepeats do
         tempdbl := tempdbl + sqr(SumSquaresWithinGroupsArray[i]);
      meanSD := sqrt(tempdbl/NumberOfRepeats);
      end;
   end;

var
  i: Integer;
  tmpStr: String;
  Divisor: Float;
begin
  with Arrays, PsyCalc do
  begin
    if DoConfidenceInterval > 0 then
    begin
      Lines.Add('');
        ReScaleFactor := 1; {GV_NumberOfGroups;}
        case DoConfidenceInterval of
          1 : begin { Separate }
            tmpStr := format('Individual %2.5g%% Confidence Intervals',
              [100*(1-Alpha)]);
            Lines.Add(format(' %*s ', [dfLblWid, '']) + tmpStr);
          end;
          2 : begin  { Bonferroni}
            tmpStr := format('Bonferroni %2.5g%% Simultaneous Confidence Intervals',
              [100*(1-Alpha)]);
            Lines.Add(format(' %*s ', [dfLblWid, '']) + tmpStr);
          end;
          3 : begin { Post hoc }
            tmpStr := format('Post hoc %2.5g%% Simultaneous Confidence Intervals',
              [100*(1-Alpha)]);
            Lines.Add(format(' %*s ', [dfLblWid, '']) + tmpStr);
          end;
          4: begin { SMR }
            tmpStr := format('Maximum root %2.5g%% Simultaneous Confidence Intervals',
              [100*(1-Alpha)]);
            Lines.Add(format(' %*s ', [dfLblWid, '']) + tmpStr);
            Lines.Add(format(' %*s  p = %d and q = %d', [dfLblWid, '', p, q]));
          end;
          5: begin { User Supplied }
            tmpStr := 'Special Confidence Intervals: User-supplied Critical Constants';
            Lines.Add(format(' %*s ', [dfLblWid, '']) + tmpStr);
            if AnalysisDlg.BCVPSpin.Enabled then
              Lines.Add(format(' %*s  Between main effect CC: %g', [dfLblWid, '', Bcc]));
            if AnalysisDlg.WCVPSpin.Enabled then
              Lines.Add(format(' %*s  Within main effect CC: %g', [dfLblWid, '', Wcc]));
            if AnalysisDlg.BCVPSpin.Enabled and AnalysisDlg.WCVPSpin.Enabled then
              Lines.Add(format(' %*s  Between x Within interaction CC: %g', [dfLblWid, '', BWcc]));
          end;
        end; { Case }
        Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
      if DoRescaling then
      begin
        if AnalysisDlg.ICRBtn.Checked then
        begin
          Lines.Add(format(' %*s The coefficients are rescaled if necessary', [dfLblWid, '']));
          Lines.Add(format(' %*s  to provide a metric appropriate for interaction contrasts.', [dfLblWid, '']));
          { ** these control names must match those on the Analysis Dialog ** }
          if AnalysisDlg.BOrdEdit.Enabled then
            Lines.Add(format(' %*s Order of interaction for Between contrasts: %d',
              [dfLblWid, '', Trunc(AnalysisDlg.BOrdEdit.Value)]));
          if AnalysisDlg.WOrdEdit.Enabled then
            Lines.Add(format(' %*s Order of interaction for Within contrasts:  %d',
              [dfLblWid, '', Trunc(AnalysisDlg.WOrdEdit.Value)]));
        end
        else
        begin
           Lines.Add(format(' %*s The CIs refer to mean difference contrasts,', [dfLblWid, '']));
           Lines.Add(format(' %*s  with coefficients rescaled if necessary.', [dfLblWid, '']));
           Lines.Add(format(' %*s  The rescaled contrast coefficients are:', [dfLblWid, '']));
        end;
        If NumberOfBContrasts > 0 then WriteScaledBContrastCoeffs();
        If NumberOfWContrasts > 0 then WriteScaledWContrastCoeffs();
      end
      else
      begin
           ReScaleFactor := 1;
           Lines.Add(format(' %*s    ***Warning***', [dfLblWid, '']));
           for i:= 2 to NumberOfBContrasts + 1 do
              if SumOfPositiveAcontrasts(i) > 1 then
                 Lines.Add(format(' %*s B%d is not a mean difference contrast', [dfLblWid, '', i-1]));
           for i:= 2 to NumberOfWContrasts + 1 do
              if SumOfPositiveBcontrasts(i) > 1 then
                 Lines.Add(format(' %*s W%d is not a mean difference contrast', [dfLblWid, '', i-1]));
{           Lines.Add('');
           Lines.Add(format(' %*s You may wish to rescale the contrast coefficients', [dfLblWid, '']));
           Lines.Add(format(' %*s before interpreting sample values and confidence', [dfLblWid, '']));
           Lines.Add(format(' %*s intervals. For more information see the PSY manual.', [dfLblWid, '']));
}      end;
      Lines.Add('');
      Lines.Add(format(' %*s Raw CIs (scaled in Dependent Variable units)', [dfLblWid, '']));
      i := (prLead + prFigs +4) div 2;  // center b/w Lower & Upper '.'
      tmpStr := format('%*s%s%.*s%*s',
        [prLead +2, '',  // space before '.', not including
         StringOfChar('.', i-4),  // leading ....
         prLead + prFigs -i +8, 'CI limits.........',  // truncates trailing ....
         prFigs -1, '']);  // pad with space
      tmpStr := format('Contrast%*s%*s %*s%*s ',
        [(prLead +5), 'Value', prFigs -3, '',  // center over '.', pfFigs -x >= 0
         (prLead +3), 'SE', prFigs -1, '']) +tmpStr;
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
      Lines.Add(format(' %*s ', [dfLblWid, '']) +tmpStr);
      Lines.Add(format(' %*s         %*s%*s %*s%*s %*s%*s %*s%*s',
        [dfLblWid, '', prLead +2, '', prFigs, '', prLead +2, '', prFigs, '',
         prLead +5, 'Lower', prFigs -3, '',
         prLead +5, 'Upper', prFigs -3, '']));
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
      //======================//
      WriteConfidenceInterval();
      //======================//
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));

      Divisor := meanSD();
      if (abs(Divisor) > dfTol) then
      begin
      Lines.Add('');
      Lines.Add(format(' %*s Approximate Standardized CIs (scaled in Sample SD units)', [dfLblWid, '']));
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
      Lines.Add(format(' %*s ', [dfLblWid, '']) +tmpStr);
      Lines.Add(format(' %*s         %*s%*s %*s%*s %*s%*s %*s%*s',
        [dfLblWid, '', prLead +2, '', prFigs, '', prLead +2, '', prFigs, '',
         prLead +5, 'Lower', prFigs -3, '',
         prLead +5, 'Upper', prFigs -3, '']));
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
      //==================//
      WriteStandardisedCI(Divisor);
      //==================//
      Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(tmpStr)));
    	end
      else
			begin
      	Lines.Add('');
				Lines.Add(format(' %*s Approximate Standardized CI''s unavailable', [dfLblWid, '']));
			end;


{      if RoyMessage Then
      begin
           Lines.Add('  * This program does not have access to critical ');
           Lines.Add('  values of Roy''s largest root distribution, and ');
           Lines.Add('  therefore cannot construct post-hoc simultaneous ');
           Lines.Add('  CIs for BW interaction contrasts when there are ');
           Lines.Add('  more than two levels on each of the B (between) ');
           Lines.Add('  and W (within) factors. See the Psy manual for ');
           Lines.Add('  more information.');
      end;
}   end;
  end;
end;

procedure TpsyOut.WriteBetweenScores;
//type
//  Str255 = String[255];
var
   iCounter: integer;
   SSScore, FScore: Float;
   SSErrorValue, MSErrorValue: Float;
   TempString, {SSString, MSString,} FString: {^Str255} String;
   {SSErrorString, MSErrorString,} ErrorString: {^Str255} String;
   DegreesOfFreedom: integer;
   x: Float;
begin
{   New(TempString);
   New(SSString);
   New(MSString);
   New(FString);
   New(SSErrorString);
   New(MSErrorString);
   New(ErrorString);
}
  with Arrays, PsyCalc do
  begin
   DegreesOfFreedom := (SumOfSubjects - NumberOfGroups);
   DFE := DegreesOfFreedom;
   // divide W contrasts by SS of W contrasts
   NormaliseBCoefficients;
   // get sample values by sum of data * normalised W coef
   GetNormalisedContrastScores;
   {first, get the SSError value for the BContrast and format the string
   to pass}
   SSErrorValue := GetSSErrorValue(1);
   MSErrorValue := SSErrorValue / DegreesOfFreedom;
   //FScore := 0;
   if NumberOfBContrasts < 1 then
      ErrorString{^} := format(' %*s Between %s  %3d %s',
                      [dfLblWid, '',
                       FtoStr(SSErrorValue, prLead, prFigs),
                       DegreesOfFreedom,
                       FtoStr(MSErrorValue, prLead, prFigs)])
   else
   begin
      ErrorString{^} := format(' %*s Error   %s  %3d %s',
                      [dfLblWid, '',
                       FtoStr(SSErrorValue, prLead, prFigs),
                       DegreesOfFreedom,
                       FtoStr(MSErrorValue, prLead, prFigs)]);
    Lines.Add(format(' %*s Between', [dfLblWid, '']));
   end;
   for icounter := 2 to NumberOfBContrasts + 1 do
   begin
     SSScore := GetAnovaValue(icounter, 1);
     if (MSErrorValue < dfTol) then  // NB guess 1e-30 as tolerance
     begin
        FString{^} :=
          format('%*.*s',[prLead + prFigs +2, prLead + prFigs +2, 'Infinite']);
        StandardError[iCounter, 1] := 0.0;
     end
     else begin
     		if (abs(SSScore) > dfTol) then
	       FScore := SSScore / MSErrorValue
        else
        	FScore := 0.0;
       FString := FtoStr(FScore, prLead, prFigs);
       SampleValue[iCounter, 1] := GetSampleValue(iCounter, 1);
       x := (CalculateW(iCounter) * MSErrorValue * SSOfBcontrasts(1));
       if (abs(x) > dfTol) then
	       StandardError[iCounter, 1] := sqrt(x) / NumberOfRepeats
       else
       	StandardError[iCounter, 1] := 0.0;
     end;
     TempString{^} := format(' %-*.*s B%-2d     %s    1 %s %s',
                    [dfLblWid, dfLblWid, BetweenComments[iCounter - 1],
                    iCounter - 1,
                    FtoStr(SSScore, prLead, prFigs),
                    FtoStr(SSScore, prLead, prFigs),
                    FString]);
     if icounter = 2 then  // 1st time add line
       Lines.Add(format(' %*s ', [dfLblWid, '']) +StringOfChar('-', Length(TempString{^}) -dfLblWid -2));
     Lines.Add(TempString{^});
   end;
   {now put the error string for Between scores}
   Lines.Add(ErrorString{^});

{   Dispose(TempString);
   Dispose(SSString);
   Dispose(MSString);
   Dispose(FString);
   Dispose(SSErrorString);
   Dispose(MSErrorString);
   Dispose(ErrorString);
}  end;
end;

procedure TPsyOut.WriteWithinScores();
{type
    Str255 = String[255];}
var
   AContrastCounter, BContrastCounter: integer;
   SSScore : Float;
   FScore: Float;
   SSErrorValue, MSErrorValue: Float;
   TempString, {SSString, MSString,} FString: {^Str255} String;
   {SSErrorString, MSErrorString,} ErrorString: {^Str255} String;
   DegreesOfFreedom: integer;
   x: Float;
begin
{   New(TempString);
   New(SSString);
   New(MSString);
   New(FString);
   New(SSErrorString);
   New(MSErrorString);
   New(ErrorString);
}   {get the degrees of freedom and normalise the BCoefficients and
   fill the Normalised Data Matrix (GetNormalisedContrastScores}
  with Arrays, PsyCalc do
  begin
   DegreesOfFreedom := (SumOfSubjects - NumberOfGroups);
   DFE := DegreesOfFreedom;
// these are done in WriteBetweenScores
//   NormaliseBCoefficients;
//   GetNormalisedContrastScores;

   {first loop through the BContrasts (not B-naught) and get the values
   for AnBn, An+1,Bn etc.. and then the error values}
   for BContrastCounter := 2 to NumberOfWContrasts + 1 do
       begin
          {first, get the SSError value for the BContrast and format the string
          to pass}
          SSErrorValue := GetSSErrorValue(BContrastCounter);
          if (abs(SSErrorValue) > dfTol) then
	          MSErrorValue := SSErrorValue / DegreesOfFreedom
          else
          	MSErrorValue := 0.0;
          ErrorString{^} := format(' %*s Error   %s  %3d %s',
                          [dfLblWid, '',
                          FtoStr(SSErrorValue, prLead, prFigs),
                          DegreesOfFreedom,
                          FtoStr(MSErrorValue, prLead, prFigs)]);
          for AContrastCounter := 1 to NumberOfBContrasts + 1 do
          begin
             SSScore := GetAnovaValue(AContrastCounter, BContrastCounter);
             if (MSErrorValue < dfTol) then  // NB 1e-30 as tolerance
             begin
                FString{^} :=
				          format('%*.*s',[prLead + prFigs +2, prLead + prFigs +2, 'Infinite']);
                StandardError[AContrastCounter, BContrastCounter] := 0.0;
             end
             else begin
                FScore := SSScore / MSErrorValue;
                if (abs(FScore) < dfTol) then
                	FScore := 0.0;
                FString := FtoStr(FScore, prLead, prFigs);
                SampleValue[AContrastCounter, BContrastCounter] := GetSampleValue(AContrastCounter, BContrastCounter);
             		x := CalculateW(AContrastCounter) * MSErrorValue * SSOfBcontrasts(BContrastCounter);
                if AContrastCounter = 1 then
                begin
                	if (abs(x) > dfTol) then
	                   StandardError[AContrastCounter, BContrastCounter]
  		                 := sqrt(x)/NumberOfGroups
                  else
                    StandardError[AContrastCounter, BContrastCounter] := 0.0;
                end
                else
                begin
                	if (abs(x) > dfTol) then
	                   StandardError[AContrastCounter, BContrastCounter]
  		                 := sqrt(x)
                  else
                    StandardError[AContrastCounter, BContrastCounter] := 0.0;
                end;
             end;
             if AContrastCounter = 1 then
                  TempString{^} := format(' %-*.*s W%-2d     %s    1 %s %s',
                    [dfLblWid, dfLblWid, WithinComments[BContrastCounter - 1],
                    BContrastCounter - 1,
                    FtoStr(SSScore, prLead, prFigs),
                    FtoStr(SSScore, prLead, prFigs),
                    FString])
             else
                TempString{^} := format(' %*s %-7s %s    1 %s %s',
                    [dfLblWid, '',
                    format('B%dW%d', [AContrastCounter - 1, BContrastCounter -1]),
                    FtoStr(SSScore, prLead, prFigs),
                    FtoStr(SSScore, prLead, prFigs),
                    FString]);
             Lines.Add(TempString{^});
          end;
          Lines.Add(ErrorString{^})
       end;
{       Dispose(TempString);
       Dispose(SSString);
       Dispose(MSString);
       Dispose(FString);
       Dispose(SSErrorString);
       Dispose(MSErrorString);
       Dispose(ErrorString);
}  end;
end;

procedure TpsyOut.WriteScaledBContrastCoeffs();
var
iCounter, iCounter1: integer;
ColumnString: string;

begin
  ColumnString := '';
  Lines.Add('');
  Lines.Add(format(' %*s Rescaled Between contrast coefficients', [dfLblWid, '']));
  Lines.Add('        Contrast        Group...');
  for iCounter := 1 to Arrays.NumberOfGroups do
    ColumnString := ColumnString + format(' %*d%*s',
      [(prLead +2), iCounter,  // place # above decimal pts
       prFigs, '']); // pads with prFigs space
  Lines.Add(format(' %*s    ', [dfLblWid, '']) + ColumnString);
  ColumnString := '';
  with Arrays, PsyCalc do
  for iCounter := 2 to NumberOfBContrasts + 1 do
  begin
       for iCounter1 := 1 to NumberOfGroups do
       begin
              ColumnString := ColumnString + format(' %s',
                [FtoStr(((BContrastArray[iCounter, iCounter1] * OrdB) / { divided by }
                SumOfPositiveAcontrasts(iCounter)),
                prLead, prFigs)]);
       end;
       Lines.Add(format(' %-*.*s B%-2d%s',
                        [dfLblWid, dfLblWid, BetweenComments[iCounter -1],
                         iCounter - 1, ColumnString]));
       ColumnString := '';
  end;
end;

procedure TPsyOut.WriteScaledWContrastCoeffs();
var
iCounter, iCounter1: integer;
ColumnString: string;

begin
  ColumnString := '';
  Lines.Add('');
  Lines.Add(format(' %*s Rescaled Within contrast coefficients', [dfLblWid, '']));
  Lines.Add('        Contrast        Measurement...');
  for iCounter := 1 to Arrays.NumberOfRepeats do
    ColumnString := ColumnString + format(' %*d%*s',
      [(prLead +2), iCounter,  // place # above decimal pts
        prFigs, '']); // pads with prFigs space
  Lines.Add(format(' %*s    ', [dfLblWid, '']) + ColumnString);
  ColumnString := '';
  with Arrays, PsyCalc do
  for iCounter := 2 to NumberOfWContrasts + 1 do { NumberOfWContrasts + 1}
  begin
       for iCounter1 := 1 to NumberOfRepeats do
       begin
         ColumnString := ColumnString + format(' %s',
           [FtoStr(((WContrastArray[iCounter, iCounter1] * OrdW) / { divided by }
           SumOfPositiveBcontrasts(iCounter)), prLead, prFigs)]);
       end;
       Lines.Add(format(' %-*.*s W%-2d%s',
                        [dfLblWid, dfLblWid, WithinComments[iCounter -1],
                         iCounter - 1, ColumnString]));
       ColumnString := '';
  end;
end;

procedure TPsyOut.WriteConfidenceInterval;
{type
    Str255 = String[255];}
var
   AContrastCounter,
   BContrastCounter  : integer;
   lvCC, ScaleFactor   : Float;
   TempString,
   SSString,
   SVString,
   FString           : {^Str255} String;
   {SSErrorString,
   MSErrorString,}
   ErrorString       : {^Str255} String;
   S                 : integer;

   function MinI(const x,y: integer): integer;
   begin
      if x < y then
         MinI := x
      else
         MinI := y;
   end;

begin
{   New(TempString);
   New(SSString);
   New(SVString);
   New(FString);
   New(SSErrorString);
   New(MSErrorString);
   New(ErrorString);
}   with Arrays, PsyCalc do
   begin
   case DoConfidenceInterval of
      1 : begin {Separate}
             CC[0] := Sqrt(CalculateF(Alpha, DFE, 1));
             CC[1] := CC[0];
             CC[2] := CC[0];
          end;
      2 : begin {Bonferroni}
             if NumberOfBContrasts > 0 then
                CC[0] := Sqrt(CalculateF(Alpha/NumberOfBContrasts, DFE, 1));
             if NumberOfWContrasts > 0 then
                CC[1] := Sqrt(CalculateF(Alpha/NumberOfWContrasts, DFE, 1));
             if (NumberOfBContrasts > 0) and (NumberOfWContrasts > 0) then
                CC[2] := Sqrt(CalculateF(Alpha/(NumberOfBContrasts*NumberOfWContrasts), DFE, 1));
          end;
      3 : begin {Post-hoc}
             S := MinI(NumberOfGroups -1, NumberOfRepeats -1);
             if NumberOfBContrasts > 0 then
               CC[0] := Sqrt((NumberOfGroups - 1) *
                             CalculateF(Alpha, DFE, NumberOfGroups - 1));
             if NumberOfWContrasts > 0 then
               CC[1] := Sqrt((((NumberOfRepeats - 1) * DFE) /
                               (DFE - NumberOfRepeats + 2)) *
                              CalculateF(Alpha,
                              DFE - NumberOfRepeats + 2 , NumberofRepeats - 1));
             if (NumberOfBContrasts > 0) and (NumberOfWContrasts > 0) then
             begin
               if S > 1 then (* CC[2] := -1 { use gcr } *)
               begin
                 CC[2] := gcr_Crit(Alpha, S,
                  (abs(NumberOfGroups -NumberOfRepeats) -1)/2, // m
									(DFE - NumberOfRepeats)/2, 0.001, 0.999); // n
								 if (CC[2] > 0) and (CC[2] < 1) then
									 CC[2] := Sqrt(DFE * CC[2]/(1 -CC[2]))
								 else
								   CC[2] := 0;  // what to do when gcr = 1 ?
               end
               else if NumberOfGroups = 2 then  { S = 1 }
                 CC[2] := CC[1]
               else
                 CC[2] := CC[0];
               end;
          end;
      4 : begin { SMR }
             if p > q then
               CC[0] := Sqrt(SmrCriticalValue(q,p,Trunc(DFE),Alpha))  // symetric
             else
               CC[0] := Sqrt(SmrCriticalValue(p,q,Trunc(DFE),Alpha));
             CC[1] := CC[0];
             CC[2] := CC[0];
      end;
      5 : begin { Special/user supplied }
            CC[0] := Bcc;
            CC[1] := Wcc;
            CC[2] := BWcc;
      end;
   end;

   {Within}
   for BContrastCounter := 1 to {NumberOfRepeats} NumberOfWContrasts + 1 do
   begin
        for AContrastCounter := 1 to {NumberOfGroups} NumberOfBContrasts  + 1 do
        begin  {*** KT }
             // if (AContrastCounter = 1) and (BContrastCounter = 1) default
             lvCC := CC[0];
             ScaleFactor := 1;
             if (AContrastCounter > 1) and (BContrastCounter = 1) then
             begin
               lvCC := CC[0];
               ScaleFactor := SumOfPositiveAcontrasts(AContrastCounter) /
                              OrdB;
             end;
             if (AContrastCounter = 1) and (BContrastCounter > 1) then
             begin
               lvCC := CC[1];
               ScaleFactor := SumOfPositiveBcontrasts(BContrastCounter) /
                              OrdW;
             end;
             if (AContrastCounter > 1) and (BContrastCounter > 1) then
             begin
               lvCC := CC[2];
               ScaleFactor := (SumOfPositiveAcontrasts(AContrastCounter) *
                               SumOfPositiveBcontrasts(BContrastCounter)) /
                              (OrdB * OrdW);
             end;
             if lvCC <> -1 then
             begin
                { sqrt(lvCC) always used }
                LowerLimits[BContrastCounter, AContrastCounter] := FinalSampleValue[BContrastCounter, AContrastCounter]
                                - (StandardError[AContrastCounter, BContrastCounter] * lvCC);
                UpperLimits[BContrastCounter, AContrastCounter] := FinalSampleValue[BContrastCounter, AContrastCounter]
                                + (StandardError[AContrastCounter, BContrastCounter] * lvCC);
                { AI 981126 SclaeFactor moved before if CC <> -1
                ScaleFactor := (SumOfPositiveAcontrasts(AContrastCounter) * SumOfPositiveBcontrasts(BContrastCounter));}
                if (DoRescaling) {and not ((BContrastCounter = 1) and (AContrastCounter = 1))} then
                begin {Rescaled}
//                   if BContrastCounter = 1 then ScaleFactor := ScaleFactor/SumOfPositiveBcontrasts(BContrastCounter);
//                   if AContrastCounter = 1 then ScaleFactor := ScaleFactor/SumOfPositiveAcontrasts(AContrastCounter);
                   FinalSampleValue[BContrastCounter, AContrastCounter]
                   := FinalSampleValue[BContrastCounter, AContrastCounter]/ScaleFactor;    { ^^^}
                   StandardError[AContrastCounter, BContrastCounter]
                   := StandardError[AContrastCounter, BContrastCounter]/ScaleFactor;
                   LowerLimits[BContrastCounter, AContrastCounter]
                   := LowerLimits[BContrastCounter, AContrastCounter]/ScaleFactor;
                   UpperLimits[BContrastCounter, AContrastCounter]
                   := UpperLimits[BContrastCounter, AContrastCounter]/ScaleFactor;
                end;
                SVString{^} := FtoStr((FinalSampleValue[BContrastCounter, AContrastCounter] / ReScaleFactor), prLead, prFigs);
                SSString{^} := FtoStr((StandardError[AContrastCounter, BContrastCounter]/ReScaleFactor), prLead, prFigs);
                FString{^} := FtoStr((LowerLimits[BContrastCounter, AContrastCounter]/ReScaleFactor), prLead, prFigs);
                ErrorString{^} := FtoStr((UpperLimits[BContrastCounter, AContrastCounter]/ReScaleFactor), prLead, prFigs);
             end;
(*             else
             begin
                if (DoRescaling) {and not ((BContrastCounter = 1) and (AContrastCounter = 1))} then
                begin {Rescaled}
//                   if BContrastCounter = 1 then ScaleFactor := ScaleFactor/SumOfPositiveBcontrasts(BContrastCounter);
//                   if AContrastCounter = 1 then ScaleFactor := ScaleFactor/SumOfPositiveAcontrasts(AContrastCounter);
                   FinalSampleValue[BContrastCounter, AContrastCounter]
                   := (FinalSampleValue[BContrastCounter, AContrastCounter]/ScaleFactor)/ReScaleFactor;
                   StandardError[AContrastCounter, BContrastCounter]
                   := (StandardError[AContrastCounter, BContrastCounter]/ScaleFactor)/ReScaleFactor;
                end; {Rescaled}
                SVString^ := FtoStr((FinalSampleValue[BContrastCounter, AContrastCounter] / ReScaleFactor), prLead, prFigs);
                SSString^ := FtoStr((StandardError[AContrastCounter, BContrastCounter]/ReScaleFactor), prLead, prFigs);
                FString^ := format('  %*s %*s', [prLead, '*', prFigs, '']);
                ErrorString^ := format('  %*s %*s', [prLead, '*', prFigs, '']);
                RoyMessage := True;
             end;
*)
             if AContrastCounter = 1 then
                TempString{^} := format(' %-*.*s W%-2d     %s %s %s %s',
                  [dfLblWid, dfLblWid, WithinComments[BContrastCounter -1],
                   BContrastCounter - 1, SVString{^},
                   SSString{^}, FString{^}, ErrorString{^}])
             else
             if BContrastCounter = 1 then
                TempString{^} := format(' %-*.*s B%-2d     %s %s %s %s',
                  [dfLblWid, dfLblWid, BetweenComments[AContrastCounter -1],
                   AContrastCounter - 1, SVString{^},
                   SSString{^}, FString{^}, ErrorString{^}])
             else
                TempString{^} := format(' %*s %-7s %s %s %s %s',
                  [dfLblWid, ' ',  // fill with dfLblWid spaces
                   format('B%dW%d', [AContrastCounter -1, BContrastCounter -1]),
                   SVString{^}, SSString{^}, FString{^}, ErrorString{^}]);

             if not ((AcontrastCounter = 1) and (BContrastCounter = 1)) then
             begin
                Lines.Add(TempString{^})
             end;
        end;
   end;
   end;
{   Dispose(TempString);
   Dispose(SSString);
   Dispose(SVString);
   Dispose(FString);
   Dispose(SSErrorString);
   Dispose(MSErrorString);
   Dispose(ErrorString);
}end;

{AI 981217}
procedure TPsyOut.WriteStandardisedCI(Divisor: Float);
{type
    Str255 = String[255];}
var
   AContrastCounter,
   BContrastCounter  : integer;
   TempString,
   SSString,
   SVString,
   FString           : {^Str255} String;
//   SSErrorString,
//   MSErrorString,
   ErrorString       : {^Str255} String;
//   S                 : integer;

   function MinI(const x,y: integer): integer;
   begin
      if x < y then
         MinI := x
      else
         MinI := y;
   end;

begin
{   New(TempString);
   New(SSString);
   New(SVString);
   New(FString);
   New(SSErrorString);
   New(MSErrorString);
   New(ErrorString);
}
//   S := 1;
   {if Post-hoc}
  with Arrays do
  begin
{   if DoConfidenceInterval = 3 then
      S := MinI(NumberOfGroups -1, NumberOfRepeats -1);
}
   for BContrastCounter := 1 to NumberOfWContrasts + 1 do
   begin
      for AContrastCounter := 1 to NumberOfBContrasts  + 1 do
      begin
         {if roy's CI's use * for now}
{         if (AContrastCounter > 1) and (BContrastCounter > 1) and (S > 1) then
         begin
            SVString^ := FtoStr((FinalSampleValue[BContrastCounter, AContrastCounter] / ScaleFactor), prLead, prFigs);
            SSString^ := FtoStr((StandardError[AContrastCounter, BContrastCounter] / ScaleFactor), prLead, prFigs);
                // place * inline with decimal place for missing values
            FString^ := format('  %*s %*s', [prLead, '*', prFigs, '']);
            ErrorString^ := format('  %*s %*s', [prLead, '*', prFigs, '']);
         end
         else
         begin
}            SVString{^} := FtoStr((FinalSampleValue[BContrastCounter, AContrastCounter] / Divisor), prLead, prFigs);
            SSString{^} := FtoStr((StandardError[AContrastCounter, BContrastCounter] / Divisor), prLead, prFigs);
            FString{^} := FtoStr((LowerLimits[BContrastCounter, AContrastCounter] / Divisor), prLead, prFigs);
            ErrorString{^} := FtoStr((UpperLimits[BContrastCounter, AContrastCounter] / Divisor), prLead, prFigs);
//         end;

             if AContrastCounter = 1 then
                TempString{^} := format(' %-*.*s W%-2d     %s %s %s %s',
                  [dfLblWid, dfLblWid, WithinComments[BContrastCounter -1],
                   BContrastCounter - 1, SVString{^},
                   SSString{^}, FString{^}, ErrorString{^}])
             else
             if BContrastCounter = 1 then
                TempString{^} := format(' %-*.*s B%-2d     %s %s %s %s',
                  [dfLblWid, dfLblWid, BetweenComments[AContrastCounter -1],
                   AContrastCounter - 1, SVString{^},
                   SSString{^}, FString{^}, ErrorString{^}])
             else
                TempString{^} := format(' %*s %-7s %s %s %s %s',
                  [dfLblWid, ' ',  // fill with dfLblWid spaces
                   format('B%dW%d', [AContrastCounter -1, BContrastCounter -1]),
                   SVString{^}, SSString{^}, FString{^}, ErrorString{^}]);

         if not ((AcontrastCounter = 1) and (BContrastCounter = 1)) then
         begin
            Lines.Add(TempString{^})
         end;
      end;
   end;
  end;

{   Dispose(TempString);
   Dispose(SSString);
   Dispose(SVString);
   Dispose(FString);
   Dispose(SSErrorString);
   Dispose(MSErrorString);
   Dispose(ErrorString);
}end;


{
  PsyCalc class
  claculations performed here
}

procedure TPsyCalc.GetMeanAndStDev(const MatrixStartRow, MatrixEndRow, MatrixStartCol, MatrixEndCol: integer;
          RawScore: Boolean; var Mean, StDev: Float);
{Procedure gets the mean and standard deviation of either the DataMatrix
(RawScore = True) or the NormalisedDataMatrix (RawScore = False - mean only returned)}
var
   ColCounter,
   RowCounter,
   kCounter : Integer;
   iSum             : Float;
   sAverage,
   sSquare,
   sVariance,
   sError           : Float;
   sSumNormalised   : Float;

begin
   iSum := 0.0;
   kCounter := 0;
   with Arrays do
   begin
   if RawScore then  {using the raw data - i.e. the data entered by the user}
   begin
      for RowCounter := MatrixStartRow to MatrixEndRow do
         for ColCounter := MatrixStartCol to MatrixEndCol do
         begin
         		// skip if near zero
         		if (abs(Arrays.DataMatrix[RowCounter, ColCounter]) > dfTol) then
             iSum := iSum + DataMatrix[RowCounter, ColCounter];
             inc(kCounter);
         end;
      if (kCounter = 0) then
         kCounter := 1;
      Mean := iSum / kCounter;             {***^***}
      if (abs(Mean) < dfTol) then
      	Mean := 0.0;

          sSquare := 0.0;
          sError := 0.0;
          kCounter := 0;
          for RowCounter := MatrixStartRow to MatrixEndRow do
          begin
               for ColCounter := MatrixStartCol to MatrixEndCol do
               begin
                 sAverage := Mean - DataMatrix[RowCounter, ColCounter];
                 if (abs(sAverage) > dfTol) then
                 begin
                   sSquare := sSquare + (sAverage * sAverage);
                   sError := sError + sAverage;
                 end;
               end;
               inc(kCounter);
          end;
          if (kCounter = 1) then
          begin
               { If Number of Subjects in a group = 1 then StDev & Variance can't
               be calculated, therefore set those figures to -1 to be dealt with
               during the printout }
               StDev := -1
          end
          else
          begin
          	sVariance := 0.0;
          	if (abs(sSquare) > dfTol) then
               // -(sError^2) corrects for error in diff, see numerical recipes in c
               sVariance := (sSquare -(sError * sError))/ (kCounter - 1.0);   {*** KT ***}
            if (abs(sVariance) > dfTol) then
               StDev := Sqrt(sVariance)
            else
            	StDev := 0.0;
          end;
     end
     else { for normalised DataMatrix - scores different and only the mean needed - use the NormalisedDataMatrix}
     begin
        kCounter := 0;
        sSumNormalised := 0.0;
          for RowCounter := MatrixStartRow to MatrixEndRow do
          begin
               for ColCounter := MatrixStartCol to MatrixEndCol do
               begin
               		if (abs(NormalisedDataMatrix[RowCounter, ColCounter]) > dfTol) then
                    sSumNormalised := sSumNormalised + NormalisedDataMatrix[RowCounter, ColCounter];
                    kCounter := kCounter + 1;
               end;
          end;
               if kCounter = 0 then kCounter := 1;
               Mean := sSumNormalised / kCounter;   {***^***}
               if (abs(Mean) < dfTol) then
               		Mean := 0.0;
     end;
  end;
end;

function TPsyCalc.GetMeansString(const NumOfGroup: integer): string;
var
   PV_Mean, PV_StDev: Float;
   iCounter: integer;
   Tempstring: string;
begin
   PV_Mean := 0;
   PV_StDev := 0;
   Tempstring := '';

  with Arrays do
  begin
   for iCounter := 1 to NumberOfRepeats do
   begin
        {if first group, end column must be index array + subject array - i.e. not minus one}
        if NumOfGroup = 1 then    {*** KT}
           GetMeanAndStDev(SubjectIndexArray[NumOfGroup],
           SubjectArray[NumOfGroup], iCounter, iCounter, True, PV_Mean, PV_StDev)
        else
           GetMeanAndStDev(SubjectIndexArray[NumOfGroup], SubjectIndexArray[NumOfGroup] +
           SubjectArray[NumOfGroup] - 1, iCounter, iCounter, True, PV_Mean, PV_StDev);

        MeanMatrix[iCounter, NumOfGroup] := PV_Mean;
        TempString := Tempstring + ' ' + FtoStr(PV_Mean, prLead, prFigs);{  format('  %*.*f',[prWidth, prFigs, PV_Mean]);}
   end;
   GetMeansString := '   Mean  ' + Tempstring;
  end;
end;

Function TPsyCalc.GetStDevString(const NumOfGroup: integer): string;
{type
  Str255 = String[255];}
var
   PV_Mean, PV_StDev: Float;
   iCounter: integer;
//   StDevString: {^Str255} String;
   Tempstring: {^Str255} String;
begin
//   New(StDevString);
//   New(Tempstring);
   PV_Mean := 0;
   PV_StDev := 0;
   Tempstring{^} := '';

  with Arrays do
  begin
   for iCounter := 1 to NumberOfRepeats do
   begin
        {if first group, end column must be index array + subject array - i.e. not minus one}
        if NumOfGroup = 1 then
           GetMeanAndStDev(SubjectIndexArray[NumOfGroup],
           SubjectArray[NumOfGroup], iCounter, iCounter, True, PV_Mean, PV_StDev)
        else
           GetMeanAndStDev(SubjectIndexArray[NumOfGroup], (SubjectIndexArray[NumOfGroup] +
           SubjectArray[NumOfGroup] - 1), iCounter, iCounter, True, PV_Mean, PV_StDev);
        if (PV_StDev = -1) and (SubjectArray[NumOfGroup] = 1) then
           PV_StDev := 0;
        Tempstring{^} := Tempstring{^} +
                       ' ' + FtoStr(PV_StDev, prLead, prFigs);

   end;
   GetStDevString := '   SD    ' + Tempstring{^};
//   Dispose(Tempstring);
//   Dispose(StDevString);
  end;
end;

function TPsyCalc.GetMeansAcrossGroups: string;
{function returns the string for means averaged across groups -
before the summary of analysis of variance}
{type
  Str255 = String[255];}
var
   iCounter: integer;
   PV_Mean, PV_StDev: Float;
//   MeanString: {^Str255} String;
   TempString: {^Str255} String;
begin
//   New(MeanString);
//   New(TempString);
   PV_Mean := 0;
   PV_StDev := 0;
   TempString{^} := '';

  with Arrays do
  begin
   for iCounter := 1 to NumberOfRepeats do
   begin
        GetMeanAndStDev(1, SumOfSubjects, iCounter, iCounter, True, PV_Mean, PV_StDev);
        Tempstring{^} := Tempstring{^} +
                       FtoStr(PV_Mean, prLead, prFigs);
   end; {^^**}
{   Dispose(TempString);
   Dispose(MeanString);
}  end;
end;


procedure TPsyCalc.NormaliseBCoefficients;
{this procedure normalises the B Coefficients by dividing each coefficient
by the square root of Sum of Squares coefficients}
var
   iCounter, iCounter1: integer;
begin
  with Arrays do
  begin
   for iCounter := 1 to (NumberOfWContrasts + 1) do
   begin
        SumSquaresArray[iCounter] := 0.0;
        for iCounter1 := 1 to NumberOfRepeats do
        begin
            {get the sum of the squares of B coefficients}
            // skip if value is zero (to avoid possible errors)
            if (abs(WContrastArray[iCounter, iCounter1]) > dfTol) then
	            SumSquaresArray[iCounter] := SumSquaresArray[iCounter] +
  	            Sqr(WContrastArray[iCounter, iCounter1]);
        end;
        // incase of rounding errors, sum sqrs of int must be int
        SumSquaresArray[iCounter] := Round(SumSquaresArray[iCounter]);
   end;
   {now add the actual BContrast array values with the normalised values
   by dividing each contrast value by the sum of squares of the contrasts above}
   for iCounter := 1 to NumberOfWContrasts + 1 do
        for iCounter1 := 1 to NumberOfRepeats do
        begin
          // skip if value is zero (to avoid possible errors)
          if (abs(WContrastArray[iCounter, iCounter1]) > dfTol) then
            NewWContrastArray[iCounter, iCounter1] := WContrastArray[iCounter, iCounter1] / Sqrt(SumSquaresArray[iCounter])
          else
            NewWContrastArray[iCounter, iCounter1] := 0.0;
        end;
  end;
end;

procedure TPsyCalc.GetNormalisedContrastScores;
{ this procedure fills the NormalisedDataMatrix scores using the
  normalised coefficients }
var
   i, j  : integer;
begin
  with Arrays do
   for i := 1 to SumOfSubjects do  {rows}
       for j := 1 to NumberOfWContrasts+1 do  {columns} {*** KT 24/09/96 }
            NormalisedDataMatrix[i,j] := GetNormMatrixScore(i,j);
end;

function TPsyCalc.GetNormMatrixScore(const RowCounter, ColCounter: integer): Float;
{function retrieves the score for the new Data Matrix}
var
   i      : integer;
   TempMatrixScore: Float;
   x: Float;
begin
  TempMatrixScore := 0.0;
  with Arrays do
  for i := 1 to NumberOfRepeats do {NumberOfWContrasts + 1}
  begin
    // skip if value is zero (to avoid possible errors)
  	if (abs(DataMatrix[RowCounter,i]) > dfTol) and (abs(NewWContrastArray[ColCounter,i]) > dfTol) then
    begin
    	x := (DataMatrix[RowCounter,i] * NewWContrastArray[ColCounter,i]);
      if (abs(x) > dfTol) then
	      TempMatrixScore := TempMatrixScore + x;
    end;
  end;
  if (abs(TempMatrixScore) < dfTol) then
  	TempMatrixScore := 0.0;
  GetNormMatrixScore := TempMatrixScore;
end;

// AI: modified to be less error prone
function TPsyCalc.GetSSErrorValue(const BContrast: integer): Float;
{if BContrast = 0, then the Error value for Between will be calculated}
var
   GrpCounter, SubjectCounter, N: Integer;
   PV_Mean, diff, sum,
   err: Float;
   total: Float;
begin
  with Arrays do
  begin
		{ use sum((x - mean)^2) -(1/n)(sum(x - mean))^2,
      where (1/n)(sum(x - mean))^2 = 0 with out error
      and corrects for error otherwise,
      see numerical recipes in c
    }
    total := 0.0;
    for GrpCounter := 1 to NumberOfGroups do
    begin
    	N := SubjectArray[GrpCounter];
		  sum := 0.0;
  	  err := 0.0;
	    PV_Mean := GetMeanofNormalisedRepeatContrast(GrpCounter, BContrast);
      // for each subject in the group
  	  for SubjectCounter := SubjectIndexArray[GrpCounter] to
        (SubjectIndexArray[GrpCounter] +SubjectArray[GrpCounter] -1) do
	    begin
        diff := (NormalisedDataMatrix[SubjectCounter, BContrast] - PV_Mean);
	       	sum := sum + (diff * diff);  // sum((x - mean)^2)
  	      err := err + diff;           // sum(x - mean)
      end;  // for sunjects in group
      sum := sum - ((err * err) / N);
      if (sum < dfTol) then  // sum must be +ve
       	sum := 0.0;
      total := total + sum;
    end;  // for groups
  end;  // with arrays
  if (total < dfTol) then  // total must be +ve
	  Result := 0.0
  else
  	Result := total;
end;

(* AI: this is very error prone
function TPsyCalc.GetSSErrorValue(const BContrast: integer): Float;
{if BContrast = 0, then the Error value for Between will be calculated}
var
   GrpCounter, SubjectCounter: integer;
   PV_Mean, CScore: Float;
   SumOfSquares: Float;
   x: Float;
begin
    CScore := 0.0;
    SumOfSquares := 0.0;
  with Arrays do
  begin
    {first, get the sum of the squares of the normalised contrast scores
    for a particular B Contrast}
    for SubjectCounter := 1 to SumOfSubjects do
    begin
      // skip if near zero
    	if (abs(NormalisedDataMatrix[SubjectCounter, BContrast]) > dfTol) then
         SumOfSquares := SumOfSquares + Sqr(NormalisedDataMatrix[SubjectCounter, BContrast]);
    end;
    {now find the C Score - which is the number of subjects in each group multiplied
    by each mean of normalised repeat contrast}
    for GrpCounter := 1 to NumberOfGroups do
    begin
        PV_Mean := GetMeanofNormalisedRepeatContrast(GrpCounter, BContrast);
        x := (SubjectArray[GrpCounter] * Sqr(PV_Mean));
        if (abs(x) > dfTol) then
	        CScore := CScore + x;
    end;
    x := SumOfSquares - CScore;
    if (x < dfTol) then
    	x := 0.0;
    GetSSErrorValue := x;
  end;
end;
*)

function TPsyCalc.GetMeanofNormalisedRepeatContrast(const NumberOfGroup, NumberOfContrast: integer): Float;
{function returns the mean of normalised repeat contrasts}
var
   PV_Mean, PV_StDev: Float;
begin
   PV_Mean := 0.0;
   PV_StDev := 0.0;
   with Arrays do
   begin
        {if first group, end column must be index array + subject array - i.e. not minus one}
        if NumberOfGroup = 1 then
           GetMeanAndStDev(SubjectIndexArray[NumberOfGroup], SubjectArray[NumberOfGroup],
           NumberOfContrast, NumberOfContrast, False, PV_Mean, PV_StDev)
        else
           GetMeanAndStDev(SubjectIndexArray[NumberOfGroup], (SubjectIndexArray[NumberOfGroup] +
           SubjectArray[NumberOfGroup] - 1), NumberOfContrast, NumberOfContrast, False, PV_Mean, PV_StDev);
   end;
   if (abs(PV_Mean) < dfTol) then
   		PV_Mean := 0.0;
   GetMeanofNormalisedRepeatContrast := PV_Mean;
end;

//------------------------------------------------------------------------------
function TPsyCalc.GetSampleValue(const AContrastNumber, BContrastNumber: integer): Float;
var
   i  : integer;
   r, x  : Float;
begin
   r := 0.0;
  with Arrays do
   for i := 1 to NumberOfGroups do
   begin
   		x := GetMeanOfNormalisedRepeatContrast(i,BContrastNumber);
   		if (abs(BContrastArray[AContrastNumber,i]) > dfTol) and (abs(x) > dfTol) then
       r := r + BContrastArray[AContrastNumber,i] * x;
   end;
   if (abs(r) < dfTol) then
   	r := 0.0;
   GetSampleValue := r;
end;

function TPsyCalc.GetAnovaValue(const AContrastNumber, BContrastNumber: integer): Float;
var
   iCounter     : integer;
   TempValue    : Float;
   Denominator  : Float;
begin
   Denominator := 0.0;
   {first get the sample value for the particular contrast}
   TempValue := GetSampleValue(AContrastNumber, BContrastNumber);
   {now square the sample value obtained and divide by the particular
   AContrast value square by number of subjects in each group}
  with Arrays do
  begin
   for iCounter := 1 to NumberOfGroups do
   begin
      Denominator := Denominator +
        (Sqr(BContrastArray[AContrastNumber, iCounter]) / SubjectArray[iCounter]);
   end;
   if (abs(Denominator) < dfTol) then
      GetAnovaValue := 0.0
   else
      GetAnovaValue := Sqr(TempValue) / Denominator; { *** KT 28/09/96 *** }
  end;
end;

procedure TPsyCalc.CalculateGroupMeansOnRepeatContrasts;
var
   iCounter, j, k: integer;
   TempString, TempString2: string;
   TVal : Float;
begin
     TempString := '';
     TempString2 := '';
  with Arrays do
  begin
     for j := 1 to NumberOfGroups do
     {Dealing with B0 contrasts}
     begin
         TVal := 0.0;
         for k := 1 to NumberOfRepeats do
         begin   { *** KT ^^^}
              TVal := TVal + (MeanMatrix[k, j] * WContrastArray[1,k]);
         end;
         GroupMeansOnRepeatContrasts[j, 1]:= TVal/NumberOfRepeats;
     end;
     for iCounter := 2 to NumberOfWContrasts + 1  do
     {Deal with the rest of B contrasts}
     begin
          for j := 1 to NumberOfGroups do
          begin
               TVal := 0.0;
               for k := 1 to NumberOfRepeats do
               begin   { *** KT ^^^}
                    TVal := TVal + (MeanMatrix[k, j] * WContrastArray[iCounter,k]);
               end;
               GroupMeansOnRepeatContrasts[j, iCounter]:= TVal;
          end;
     end;
  end;
end;

procedure TPsyCalc.CalculateFinalSampleValue;
var
   iCounter, j, k: integer;
   TempString, TempString2: string;
   TVal : Float;

begin
     TempString := '';
     TempString2 := '';
  with Arrays do
  begin
     for iCounter := 1 to NumberOfBContrasts + 1 {NumberOfGroups} do
     {Deal with the rest of A contrasts}
     begin
          for j := 1 to NumberOfWContrasts + 1 {NumberOfRepeats} do
          begin
               TVal := 0.0;
               for k := 1 to {NumberOfBContrasts + 1} NumberOfGroups do
               begin   { *** KT ^^^}
                    TVal := TVal + (GroupMeansOnRepeatContrasts[k, j] * BContrastArray[iCounter,k]);
               end;
               FinalSampleValue[j, iCounter]:= TVal;
          end;
     end;
     for j := 1 to NumberOfWContrasts + 1 do
     {Dealing with A0 contrasts}
     begin
         TVal := 0.0;
         for k := 1 to NumberOfGroups do
         begin   { *** KT ^^^}
              TVal := TVal + (GroupMeansOnRepeatContrasts[k, j] * BContrastArray[1,k]);
         end;
         FinalSampleValue[j, 1]:= TVal/NumberOfGroups;
     end;
  end;
end;

//------------------------------------------------------------------------------
function TPsyCalc.CalculateW(const AContrastNumber: integer): Float;
var
   ResultVar : Float;
   i         : integer;
begin
   ResultVar := 0.0;
  with Arrays do
   for i := 1 to NumberOfGroups do
   begin
   		if (abs(BContrastArray[AContrastNumber,i]) > dfTol) then
        ResultVar := ResultVar +
          Sqr(BContrastArray[AContrastNumber,i]) / SubjectArray[i];
   end;
   if (abs(ResultVar) < dfTol) then
   		ResultVar := 0.0;
   CalculateW := ResultVar;
end;

//------------------------------------------------------------------------------
function TPsyCalc.SSOfBcontrasts(const BContrastNumber: integer): Float;
var
   ResultVar : Float;
   i : integer;
begin
   ResultVar := 0.0;
  with Arrays do
   for i := 1 to NumberOfRepeats do
   		if (abs(WContrastArray[BContrastNumber, i]) > dfTol) then
       ResultVar := ResultVar + Sqr(WContrastArray[BContrastNumber, i]);
   if (abs(ResultVar) < dfTol) then
   		ResultVar := 0.0;
   SSOfBcontrasts := ResultVar;
end;

//------------------------------------------------------------------------------
function TPsyCalc.SumOfPositiveBContrasts(const BContrastNumber: integer): Float;
var
   ResultVar : Float;
   i         : integer;
begin
  ResultVar := 0.0;
  with Arrays do
   for i := 1 to NumberOfRepeats do
      if (WContrastArray[BContrastNumber, i] > 0) then
        ResultVar := ResultVar + WContrastArray[BContrastNumber, i];
//   assert( ResultVar <> 0 );
   SumOfPositiveBcontrasts := ResultVar;
end;

//------------------------------------------------------------------------------
function TPsyCalc.SumOfPositiveAcontrasts(const AContrastNumber: integer): Float;
var
   ResultVar : Float;
   i         : integer;
begin
   ResultVar := 0;
  with Arrays do
   for i := 1 to NumberOfGroups do
       if BContrastArray[AContrastNumber, i] > 0 then
          ResultVar := ResultVar + BContrastArray[AContrastNumber, i];
   assert( ResultVar <> 0 );
   SumOfPositiveAcontrasts := ResultVar;
end;

//------------------------------------------------------------------------------
procedure TPsyCalc.CalculateSumSquaresWithinGroupsArray;
Var
   i, j, k:  Integer;
   TempValue: Float;

{   DeviationMatrix: DeviationDataMatrix;
   SumsOfSquaresMatrix: StandardMatrix;}
begin
  with Arrays do
  begin
   for i := 1 to SumOfSubjects do
      for j := 1 to NumberOfRepeats do
         DeviationMatrix[i,j] := 0;

   for i := 1 to NumberOfGroups do
      for j := SubjectIndexArray[i] to SubjectIndexArray[i] + SubjectArray[i] - 1 do
         for k := 0 to NumberOfRepeats do
            DeviationMatrix[j,k] := DataMatrix[j,k] - MeanMatrix[k,i];

   for i := 1 to NumberOfRepeats do
   begin
      for j := 1 to NumberOfGroups do
      begin
         TempValue := 0.0;
         for k := SubjectIndexArray[j] to SubjectIndexArray[j] + SubjectArray[j] - 1 do
         begin
             TempValue := TempValue + sqr(DeviationMatrix[k,i]);
         end;
         SumsOfSquaresMatrix[i,j] := TempValue;
      end;
   end;
   for i := 1 to NumberOfRepeats do
   begin
       TempValue := 0.0;
       for j := 1 to NumberOfGroups do
          TempValue := TempValue + SumsOfSquaresMatrix[i,j];
       SumSquaresWithinGroupsArray[i] := Sqrt(TempValue/(SumOfSubjects - NumberOfGroups));
   end;
  end;
end;

{ Use function from FforPsy.pas }
function TPsyCalc.CalculateF(const Alpha,DFD,NDF : Float): Float;
begin
  { convert types where necessary}
  { F_Crit(p: float; v1, v2: integer): float }
  CalculateF := F_Crit(Alpha, trunc(NDF), trunc(DFD));
end;

{
  end classes
}

(*
{ Initialise instances of PsyOut and PsyCalc objects }
function PsyOut: TPsyOut;
begin
  if FPsyOut = nil then FPsyOut := TPsyOut.Create;
  Result := FPsyOut;
end;

function PsyCalc: TPsyCalc;
begin
  if FPsyCalc = nil then FPsyCalc := TPsyCalc.Create;
  Result := FPsyCalc;
end;

initialization

finalization
  FPsyOut.Free;
  FPsyCalc.Free;
*)
// always use so create here
initialization
	PsyCalc := TPsyCalc.Create;
  PsyOut := TPsyOut.Create;

finalization
	PsyCalc.Free;
  PsyOut.Free;

end.
