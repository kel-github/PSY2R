unit DlgAbout;

interface

uses
  WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, DdeMan;

type
  TAboutForm = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    Copyright: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    Label7: TLabel;
    Label8: TLabel;
    buildNum: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label6Click(Sender: TObject);
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}
uses
   Defines;


// Create AboutForm last to wait for splash screen
procedure TAboutForm.FormCreate(Sender: TObject);
begin
	ProductName.Caption := dfHeaderInfo;
	Label5.Caption := dfHeaderInfo;
  Copyright.Caption := dfCopyright;
  buildNum.Caption := dfBuildNum;
end;

procedure TAboutForm.Label6Click(Sender: TObject);
begin
// execute the file ('http://www.psy.unsw.edu.au');
end;

end.



