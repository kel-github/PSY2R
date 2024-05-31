unit Splash;
{ Splash Screen:
  Used when program first appears.
  There are no methods for this form
}
interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls;

type
  TSplashForm = class(TForm)
    BevelPanel       : TPanel;
    AppNameLabel     : TLabel;
    Bevel1           : TBevel;
    LoadingLabel     : TLabel;
    CopyrightLabel   : TLabel;
    PsyImage         : TImage;
    UNSWLabel        : TLabel;
    PsychologyLabel  : TLabel;

    Timer1: TTimer;
    Shape1: TShape;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  SplashForm : TSplashForm;

implementation

{$R *.DFM}

uses
  Main, Defines;

procedure TSplashForm.FormCreate(Sender: TObject);
begin
  AppNameLabel.Caption := dfHeaderInfo;
	CopyrightLabel.Caption := dfCopyright;
end;

{ The Splash Form has a System Timer with interval set to 2 seconds }
procedure TSplashForm.Timer1Timer(Sender: TObject);
begin
  // after timer interval, close Splash Form
  Timer1.Enabled := False;
  Timer1.Free;
  MainForm.Enabled := True;  // allow prog to be used
  Close;
end;

end.
