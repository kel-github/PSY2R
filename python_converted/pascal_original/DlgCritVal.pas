unit DlgCritVal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DlgSpin, ComCtrls, StdCtrls, ExtCtrls, Buttons, PsySpinEdit, Menus;

type
  TCritValDlg = class(TSpinDlg)
    OutGB: TGroupBox;
    OutEdt: TEdit;
    OutLbl: TLabel;
    alphaLbl: TLabel;
    TabControl2: TTabControl;
    param1Pnl: TPanel;
    param1Lbl: TLabel;
    param1Edt: TPsySpinEdit;
    param2Pnl: TPanel;
    param2Lbl: TLabel;
    param2Edt: TPsySpinEdit;
    param3Pnl: TPanel;
    param3Lbl: TLabel;
    param3Edt: TPsySpinEdit;
    kPnl: TPanel;
    kLbl: TLabel;
    kEdt: TPsySpinEdit;
    CritValRBtn: TRadioButton;
    pValRBtn: TRadioButton;
    PopupMenu1: TPopupMenu;
    Whatsthis1: TMenuItem;
    procedure OKBtnClick(Sender: TObject);
    procedure TabControl2Change(Sender: TObject);
    procedure CritValRBtnClick(Sender: TObject);
    procedure pValRBtnClick(Sender: TObject);
    procedure TabControl2Changing(Sender: TObject;
      var AllowChange: Boolean);
    procedure Whatsthis1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ValueChange(Sender: TObject);  // check what to calculate
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  CritValDlg: TCritValDlg;

implementation

{$R *.DFM}

uses
  Defines, FforPsy, SMR, GCR;

constructor TCritValDlg.Create(AOwner: TComponent);
begin
  inherited;
  CritValRBtn.Checked := True;  // critical vals, default
  TabControl2.TabIndex := 0;  // t-test
  param2Pnl.Visible := False;
  param3Pnl.Visible := False;
  param1Lbl.Caption := 'df:  ';
  alphaLbl.Visible := True;  // show alpha
  SpinLbl.Visible := False;  // not t:
  OutLbl.Caption := 't:';
  with SpinEdt do
  begin
    ValueIntOnly := False;
    ValueMax := 0.3;   // 70%
    ValueMin := 0.001; // 99.99%
    Value := 0.05;
    ValueDefault := 0.05;
    ValueIncrement := 0.01;
  end;
end;


procedure TCritValDlg.OKBtnClick(Sender: TObject);
var
  a: Double;
  k,
  df1, df2, df3: Integer;
begin
  inherited;
  if ActiveControl is TPsySpinEdit then  // check that values are sensible
    if (ActiveControl as TPsySpinEdit).Validate then Exit;
  Screen.Cursor := crHourGlass;
  try
  a := SpinEdt.Value;
  if kPnl.Visible then
    k := Trunc(kEdt.Value)
  else
    k := 1;
  a := a / k;  // k > 0
  df1 := Trunc(param1Edt.Value);  // integers
  df2 := Trunc(param2Edt.Value);
  df3 := Trunc(param3Edt.Value);
  if CritValRBtn.Checked then  // critical values
    with TabControl2 do
    begin
      case TabIndex of
  {t}   0: OutEdt.Text := FToStr(Sqrt(F_Crit(a, 1, df1)), prLead, prFigs);
  {F}   1: OutEdt.Text := FToStr(F_Crit(a, df1, df2), prLead, prFigs);
  {gcr} 2: OutEdt.Text := FToStr(gcr_Crit(a, df1,
                           param2Edt.Value, param3Edt.Value, // floats
                           0.001, 0.999), prLead, prFigs);
  {smr} 3: if df1 > df2 then  // p > q ?
            OutEdt.Text := FToStr(SmrCriticalValue(df2, df1, df3, a), prLead, prFigs)
           else
            OutEdt.Text := FToStr(SmrCriticalValue(df1, df2, df3, a), prLead, prFigs)
      end;
    end
  else                              // p values
    with TabControl2 do
    begin
      case TabIndex of
  {t}   0: OutEdt.Text := FToStr((F_Prob(a*a, 1, df1) /2), prLead, prFigs);
  {F}   1: OutEdt.Text := FToStr(F_Prob(a, df1, df2), prLead, prFigs);
  {PSY2R this is the p-value calculation}
  {gcr} 2: OutEdt.Text := FToStr(gcr_Prob(df1,
                           param2Edt.Value, param3Edt.Value, // floats
                           a),prLead,prFigs);
  {smr} 3: if df1 > df2 then  // p > q ?
            OutEdt.Text := FToStr(SmrPercentile(df2, df1, df3, a), prLead, prFigs)
           else
            OutEdt.Text := FToStr(SmrPercentile(df1, df2, df3, a), prLead, prFigs)
      end;
    end;
  finally
  end;
  Screen.Cursor := crDefault;
end;

procedure TCritValDlg.ValueChange(Sender: TObject);
begin
  param1Pnl.Hide;
  param2Pnl.Hide;
  param3Pnl.Hide;
  SpinPnl.Hide;
  kPnl.Hide;
  OutEdt.Text := '';
  if CritValRBtn.Checked then
  begin
    alphaLbl.Visible := True;
    SpinLbl.Visible := False;
    with SpinEdt do
    begin
      ValueMax := 0.3;   // 70%
      ValueMin := 0.001; // 99.99%
      Value := 0.05;
      ValueDefault := 0.05;
      ValueIncrement := 0.01;
    end;
    with TabControl2 do
    begin
      case TabIndex of
        0: OutLbl.Caption := 't:  ';
        1: begin
          OutLbl.Caption := 'F:  ';
          param2Pnl.Show;
        end;
        2: begin
          OutLbl.Caption := 'gcr:  ';
          param2Pnl.Show;
          param3Pnl.Show;
        end;
        3: begin
          OutLbl.Caption := 'smr:  ';
          param2Pnl.Show;
          param3Pnl.Show;
        end;
      end;
    end;
    kPnl.Show;
  end
  else
  begin  // p values
    alphaLbl.Visible := False;
    SpinLbl.Visible := True;
    OutLbl.Caption := 'p:';
    with SpinEdt do
    begin
      ValueMax := 10000;  // default limits
      ValueMin := 0.001;
      Value := 1;
      ValueDefault := 1;
      ValueIncrement := 1;
    end;
    with TabControl2 do
    begin
      case TabIndex of
        0: SpinLbl.Caption := 't:  ';
        1: begin
          SpinLbl.Caption := 'F:  ';
          param2Pnl.Show;
        end;
        2: begin
          SpinLbl.Caption := 'gcr:  ';
          SpinEdt.ValueMax := 0.999;  // specific limits for gcr
          SpinEdt.ValueMin := 0.001;
          SpinEdt.ValueIncrement := 0.01;
          SpinEdt.Value := 0.05;
          SpinEdt.ValueDefault := 0.05;
          param2Pnl.Show;
          param3Pnl.Show;
        end;
        3: begin
          SpinLbl.Caption := 'smr:  ';
          OutLbl.Caption := 'prob:';
          param2Pnl.Show;
          param3Pnl.Show;
        end;
      end;
    end;
  end;
//  TabControl2.Show;
  param1Pnl.Show;
  SpinPnl.Show;
end;

procedure TCritValDlg.TabControl2Change(Sender: TObject);
begin
  inherited;
  ValueChange(Sender);  // setup for value calculation type
  with TabControl2 do
  begin
    case TabIndex of
    0: begin  // t-test
      param1Edt.Value := 1;
      param1Edt.ValueDefault := 1;
      param1Edt.ValueMin := 1;
      param1Edt.ValueMax := 1000;
      param1Lbl.Caption := 'df:  ';
//      param2Pnl.Visible := False;
//      param3Pnl.Visible := False;
      end;
    1: begin  // F
      param2Edt.ValueIntOnly := True;
      param1Edt.Value := 1;
      param1Edt.ValueDefault := 1;
      param2Edt.Value := 1;
      param2Edt.ValueDefault := 1;
      param1Edt.ValueMin := 1;
      param1Edt.ValueMax := 1000;
      param2Edt.ValueMin := 1;
      param2Edt.ValueMax := 1000;
      param1Lbl.Caption := 'df 1:  ';
      param2Lbl.Caption := 'df 2:  ';
//      param2Pnl.Visible := True;
//      param3Pnl.Visible := False;
      end;
    2: begin  // gcr
      param1Edt.Value := 2;
      param2Edt.Value := 1;
      param3Edt.Value := 1;
      param1Edt.ValueDefault := 2;
      param2Edt.ValueDefault := 1;
      param3Edt.ValueDefault := 1;
      param1Edt.ValueMin := 2;     // 2 <= s <= 20
      param1Edt.ValueMax := 20;
      param2Edt.ValueIntOnly := False;
      param2Edt.ValueMin := -0.5;     // m <= 100 to speed up
      param2Edt.ValueMax := 100;
      param3Edt.ValueIntOnly := False;
      param3Edt.ValueMin := 1;
      param3Edt.ValueMax := 1000;   // n <= 1000
      param1Lbl.Caption := 's:  ';
      param2Lbl.Caption := 'm:  ';
      param3Lbl.Caption := 'n:  ';
//      param2Pnl.Visible := True;
//      param3Pnl.Visible := True;
      end;
    3: begin  // smr
      param1Edt.Value := 2;
      param2Edt.Value := 2;
      param3Edt.Value := 10;
      param1Edt.ValueDefault := 2;
      param2Edt.ValueDefault := 2;
      param3Edt.ValueDefault := 10;
      param1Edt.ValueMin := 2;
      param1Edt.ValueMax := 5;
      param2Edt.ValueIntOnly := True;
      param2Edt.ValueMin := 2;
      param2Edt.ValueMax := 6;
      param3Edt.ValueIntOnly := True;
      param3Edt.ValueMin := 10;
      param3Edt.ValueMax := 1000;   // df <= 1000
      param1Lbl.Caption := 'p:  ';
      param2Lbl.Caption := 'q:  ';
      param3Lbl.Caption := 'df:  ';
//      param2Pnl.Visible := True;
//      param3Pnl.Visible := True;
      end;
    end;
  end;
end;

procedure TCritValDlg.CritValRBtnClick(Sender: TObject);
begin
  if ActiveControl is TPsySpinEdit then
    if (ActiveControl as TPsySpinEdit).Validate then
    begin
      (ActiveControl as TPsySpinEdit).Value := (ActiveControl as TPsySpinEdit).ValueDefault; 
      Exit;
		end;
  inherited;
  ValueChange(Sender);
end;

procedure TCritValDlg.pValRBtnClick(Sender: TObject);
begin
  if ActiveControl is TPsySpinEdit then
    if (ActiveControl as TPsySpinEdit).Validate then
    begin
      (ActiveControl as TPsySpinEdit).Value := (ActiveControl as TPsySpinEdit).ValueDefault;
      Exit;
		end;
  inherited;
  ValueChange(Sender);
end;

procedure TCritValDlg.TabControl2Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  inherited;
  if ActiveControl is TPsySpinEdit then
    if (ActiveControl as TPsySpinEdit).Validate then
    begin
      (ActiveControl as TPsySpinEdit).Value := (ActiveControl as TPsySpinEdit).ValueDefault; 
      AllowChange := False;
		end;
end;

procedure TCritValDlg.Whatsthis1Click(Sender: TObject);
begin
  inherited;
  if (PopupMenu1.PopupComponent = CritValRBtn) then
    Application.HelpContext(CritValRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = pValRBtn) then
    Application.HelpContext(pValRBtn.HelpContext)
  else if (PopupMenu1.PopupComponent = CancelBtn) then
    Application.HelpContext(CancelBtn.HelpContext);
end;

end.

