unit DlgAnalysis;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DlgSpin, StdCtrls, ComCtrls, Buttons, ExtCtrls, Defines, PsySpinEdit,
  Menus;

type
  TAnalysisDlg = class(TSpinDlg)
    Txt_Title: TEdit;
    GroupBox1: TGroupBox;
    IndividualRBtn: TRadioButton;
    BonferroniRBtn: TRadioButton;
    PostHocRBtn: TRadioButton;
    SMRRBtn: TRadioButton;
    grpScaling: TGroupBox;
    MDCRBtn: TRadioButton;
    NoRescalingRBtn: TRadioButton;
    GroupBox2: TGroupBox;
    pnlSMR: TPanel;
    pLabel: TLabel;
    qLabel: TLabel;
    ICRBtn: TRadioButton;
    Panel1: TPanel;
    BOrdLbl: TLabel;
    WOrdLbl: TLabel;
    Label1: TLabel;
    pEdit: TPsySpinEdit;
    qEdit: TPsySpinEdit;
    BOrdEdit: TPsySpinEdit;
    WOrdEdit: TPsySpinEdit;
    SpclRBtn: TRadioButton;
    Panel2: TPanel;
    BCVLbl: TLabel;
    WCVLbl: TLabel;
    BCVPSpin: TPsySpinEdit;
    WCVPSpin: TPsySpinEdit;
    BWCVPSpin: TPsySpinEdit;
    BWCVLbl: TLabel;
    PopupMenu1: TPopupMenu;
    HelpPopup1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure SMRRBtnClick(Sender: TObject);
    procedure IndividualRBtnClick(Sender: TObject);
    procedure NoRescalingRBtnClick(Sender: TObject);
    procedure MDCRBtnClick(Sender: TObject);
    procedure ICRBtnClick(Sender: TObject);
    procedure SpclRBtnClick(Sender: TObject);
    procedure HelpPopup1Click(Sender: TObject);
  private
    { Private declarations }
//    function ValueCheck(KeyEdit: TEdit; DefVal, ErrMsg: String;
//      MinVal, MaxVal: Float): Float;
  public
    { Public declarations }
  end;

var
  AnalysisDlg: TAnalysisDlg;

implementation

{$R *.DFM}

uses
  Math, ArraysClass;

procedure TAnalysisDlg.FormCreate(Sender: TObject);
begin
  SpinEdt.Hint := clHintMsg;
  SpinLbl.Hint := clHintMsg;
  Arrays.DoConfidenceInterval := 1; {default}
  // ValueEdt.Text is the confidence level, so use (100 - CL)/100 for alpha
  Arrays.Alpha := (100.0 - SpinEdt.Value)/100.0;
  Arrays.DoRescaling := True;
  grpScaling.Visible  := True;
  Arrays.RoyMessage := False;  // always false ?
end;

procedure TAnalysisDlg.OKBtnClick(Sender: TObject);
begin
	// exit if analysis impossible
	if PostHocRBtn.Checked and
		(Arrays.SumOfSubjects -Arrays.NumberOfGroups -Arrays.NumberOfRepeats < 1) then
	begin
		Beep();
		MessageDlg('Post-hoc analysis is not possible;' + #13#10 +
			'The number of subjects is less than the' +#13#10 +
			'number of Groups and Measurements', mtError, [mbOk], 0);
		ModalResult := mrNone;
		exit;
	end;

	Arrays.RoyMessage := False;  // set true by PsyOut
	inherited;
	with Arrays do
	begin
		// Arrays.DoConfidenceInterval := 0; { None }
		if IndividualRBtn.Checked then
			DoConfidenceInterval := 1 { Individual }
		else if BonferroniRBtn.Checked then
			DoConfidenceInterval := 2 { Bonferroni }
		else if PostHocRBtn.Checked then
			DoConfidenceInterval := 3 { Post-Hoc }
		else if SMRRBtn.Checked then
			DoConfidenceInterval := 4 { SMR }
		else if SpclRBtn.Checked then
			DoConfidenceInterval := 5; { Special/user supplied }

		DoRescaling := (MDCRBtn.Checked or ICRBtn.Checked);
    Alpha := (100.0 -  SpinEdt.Value)/100.0;
    p := Trunc(pEdit.Value);
    q := Trunc(qEdit.Value);
    OrdB := Trunc(IntPower(2, Trunc(BOrdEdit.Value)));
    OrdW := Trunc(IntPower(2, Trunc(WOrdEdit.Value)));
    Bcc := BCVPSpin.Value;
    Wcc := WCVPSpin.Value;
    BWcc := BWCVPSpin.Value;
  end;
end;

{
  Confidence Interval  routines
}
{ used by Individual, Bonferroni and Post hoc. disable p & q, BCV & WCV }
procedure TAnalysisDlg.IndividualRBtnClick(Sender: TObject);
begin
  inherited;
  // enable Confidence Level;
  SpinLbl.Enabled := True;
  SpinEdt.Enabled := True;
  pLabel.Enabled := False;
  pEdit.Enabled := False;
  qLabel.Enabled := False;
  qEdit.Enabled := False;
  BCVLbl.Enabled := False;
  BCVPSpin.Enabled := False;
  WCVLbl.Enabled := False;
  WCVPSpin.Enabled := False;
  BWCVLbl.Enabled := False;
  BWCVPSpin.Enabled := False;
end;

{ enable p & q, disable BCV & WCV }
procedure TAnalysisDlg.SMRRBtnClick(Sender: TObject);
begin
  inherited;
  // enable Confidence Level;
  SpinLbl.Enabled := True;
  SpinEdt.Enabled := True;
  pLabel.Enabled := True;
  pEdit.Enabled := True;
  qLabel.Enabled := True;
  qEdit.Enabled := True;
  BCVLbl.Enabled := False;
  BCVPSpin.Enabled := False;
  WCVLbl.Enabled := False;
  WCVPSpin.Enabled := False;
  BWCVLbl.Enabled := False;
  BWCVPSpin.Enabled := False;
end;

{ disable p & q, enable BCV & WCV }
procedure TAnalysisDlg.SpclRBtnClick(Sender: TObject);
begin
  inherited;
  // disable Confidence Level;
  SpinLbl.Enabled := False;
  SpinEdt.Enabled := False;
  pLabel.Enabled := False;
  pEdit.Enabled := False;
  qLabel.Enabled := False;
  qEdit.Enabled := False;
  with Arrays do
  begin
  if (NumberOfBContrasts > 0) then
  begin
    BCVLbl.Enabled := True;
    BCVPSpin.Enabled := True;
  end;
  if (NumberOfWContrasts > 0) then
  begin
    WCVLbl.Enabled := True;
    WCVPSpin.Enabled := True;
  end;
  if (NumberOfBContrasts > 0) and (NumberOfWContrasts > 0) then
  begin
    BWCVLbl.Enabled := True;
    BWCVPSpin.Enabled := True;
  end
  else
  begin
    BWCVLbl.Enabled := False;
    BWCVPSpin.Enabled := False;
  end;
  end; // with
end;

{
  Scaling Options routines
}
procedure TAnalysisDlg.NoRescalingRBtnClick(Sender: TObject);
begin
  inherited;
  BOrdLbl.Enabled := False;
  BOrdEdit.Enabled := False;
  BOrdEdit.Value := 0;
  WOrdLbl.Enabled := False;
  WOrdEdit.Enabled := False;
  WOrdEdit.Value := 0;
end;

procedure TAnalysisDlg.MDCRBtnClick(Sender: TObject);
begin
  inherited;
  BOrdLbl.Enabled := False;
  BOrdEdit.Enabled := False;
  BOrdEdit.Value := 0;
  WOrdLbl.Enabled := False;
  WOrdEdit.Enabled := False;
  WOrdEdit.Value := 0;
end;

procedure TAnalysisDlg.ICRBtnClick(Sender: TObject);
begin
  inherited;
  if (Arrays.NumberOfBContrasts > 0) then
  begin
    BOrdLbl.Enabled := True;
    BOrdEdit.Enabled := True;
  end;
  if (Arrays.NumberOfWContrasts > 0) then
  begin
    WOrdLbl.Enabled := True;
    WOrdEdit.Enabled := True;
  end;
end;

{===================================
 old stuff before PsySpinEdit used
===================================}
{function TAnalysisDlg.ValueCheck(KeyEdit: TEdit; DefVal, ErrMsg: String;
  MinVal, MaxVal: Float): Float;
begin
  Result := StrToFloat(DefVal);  // default value
  if ActiveControl = CancelBtn then
  begin
    KeyEdit.Text := DefVal;
    exit;
  end;
  if not isFloat(KeyEdit.Text) then
  begin
    ShowMessage(ErrMsg);
    KeyEdit.SelectAll;
    KeyEdit.SetFocus;
    exit;
  end;
  Result := StrToFloat(KeyEdit.Text);  // entered value
  if (Result < MinVal) or (Result > MaxVal) then
  begin
    ShowMessage(ErrMsg);
    KeyEdit.SelectAll;
    KeyEdit.SetFocus;
    Result := StrToFloat(DefVal);  // default value
  end;
end;
}

{procedure TAnalysisDlg.pEditExit(Sender: TObject);
begin
  inherited;
  ValueCheck(pEdit, '2', 'p must be from 2 to 5', 2, 5);  // returns float
end;

procedure TAnalysisDlg.qEditExit(Sender: TObject);
begin
  inherited;
  ValueCheck(qEdit, '2', 'q must be from 2 to 6', 2, 6);
end;

procedure TAnalysisDlg.BOrdEditExit(Sender: TObject);
begin
  inherited;
  ValueCheck(BOrdEdit, '0', 'Between interaction order must be from 0 to 9', 0, 9);
end;

procedure TAnalysisDlg.WOrdEditExit(Sender: TObject);
begin
  inherited;
  ValueCheck(WOrdEdit, '0', 'Within interaction order must be from 0 to 9', 0, 9);
end;
}

procedure TAnalysisDlg.HelpPopup1Click(Sender: TObject);
begin
  inherited;
  if (PopupMenu1.PopupComponent = IndividualRBtn) then
    Application.HelpContext(IndividualRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = BonferroniRBtn) then
    Application.HelpContext(BonferroniRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = PostHocRBtn) then
    Application.HelpContext(PostHocRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = SMRRBtn) then
    Application.HelpContext(SMRRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = SpclRBtn) then
    Application.HelpContext(SpclRBtn.HelpContext)
  // labels don't have help contexts
  else if (PopupMenu1.PopupComponent = Label1) then
    Application.HelpContext(100)
  else if (PopupMenu1.PopupComponent = SpinLbl) then
    Application.HelpContext(100)
  else if (PopupMenu1.PopupComponent = MDCRBtn) then
    Application.HelpContext(MDCRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = NoRescalingRBtn) then
    Application.HelpContext(NoRescalingRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = ICRBtn) then
    Application.HelpContext(ICRBtn.HelpContext);
end;

end.

