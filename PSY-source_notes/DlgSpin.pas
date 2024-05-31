{
  DlgSpin is basic OK Cancel Help dialog with an PsySpinEdit control
  PsySpinEdit is a special purpose edit that is installed in the pakage
  PsyComponents.dpk
  DlgSpin is inherited by DlgAddCols, DlgAnalysis, DlgPlaces and DlgCritVal
  The PsySpinEdit handles basic number entry and range checking;
}

unit DlgSpin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DlgHelp, ComCtrls, StdCtrls, ExtCtrls, Buttons, Spin, PsySpinEdit;

type
  TSpinDlg = class(THelpDlg)
    SpinPnl: TPanel;
    SpinLbl: TLabel;
    SpinEdt: TPsySpinEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpinDlg: TSpinDlg;

implementation

{$R *.DFM}


procedure TSpinDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  if (ActiveControl is TPsySpinEdit) and
     (ActiveControl as TPsySpinEdit). Validate then
    CanClose := False;
end;

end.

