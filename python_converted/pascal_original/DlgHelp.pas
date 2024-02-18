unit DlgHelp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DlgOKCancel, StdCtrls, ExtCtrls, Buttons;

type
  THelpDlg = class(TOKCancelDlg)
    HelpBtn: TBitBtn;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpDlg: THelpDlg;

implementation

{$R *.DFM}

procedure THelpDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.

