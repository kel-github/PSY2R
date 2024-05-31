program PsyOff;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  ArraysClass in 'ArraysClass.pas',
  ChildWin in 'ChildWin.pas' {MDIChild},
  DataCheck in 'DataCheck.pas',
  Defines in 'Defines.pas',
  DlgAbout in 'DlgAbout.pas' {AboutForm},
  DlgAnalysis in 'DlgAnalysis.pas' {AnalysisDlg},
  DlgCritVal in 'DlgCritVal.pas' {CritValDlg},
  DlgHelp in 'DlgHelp.pas' {HelpDlg},
  DlgOKCancel in 'DlgOKCancel.pas' {OKCancelDlg},
  DlgPlaces in 'DlgPlaces.pas' {DecimalPlacesDlg},
  DlgSpin in 'DlgSpin.pas' {SpinDlg},
  DlgWarnings in 'DlgWarnings.pas' {Warnings},
  FforPsy in 'FforPsy.pas',
  GCR in 'GCR.pas',
  InChildWin in 'InChildWin.pas' {MDIInChild},
  PrinterFormat in 'PrinterFormat.pas' {PrintFormat},
  PsyBaseStats in 'PsyBaseStats.pas',
  PsyFile in 'PsyFile.pas',
  SMR in 'SMR.pas',
  Splash in 'Splash.pas' {SplashForm};

{$E exe}

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Psy';
  SplashForm := TSplashForm.Create(Application);
  SplashForm.Show;
  SplashForm.Update;

  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TAnalysisDlg, AnalysisDlg);
  Application.CreateForm(TCritValDlg, CritValDlg);
  Application.CreateForm(THelpDlg, HelpDlg);
  Application.CreateForm(TOKCancelDlg, OKCancelDlg);
  Application.CreateForm(TDecimalPlacesDlg, DecimalPlacesDlg);
  Application.CreateForm(TSpinDlg, SpinDlg);
  Application.CreateForm(TWarnings, Warnings);
  Application.CreateForm(TPrintFormat, PrintFormat);
  Application.Run;
end.
