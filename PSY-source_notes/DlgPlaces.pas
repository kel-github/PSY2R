unit DlgPlaces;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DlgSpin, ComCtrls, StdCtrls, ExtCtrls, Buttons, PsySpinEdit;

type
  TDecimalPlacesDlg = class(TSpinDlg)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DecimalPlacesDlg: TDecimalPlacesDlg;

implementation

{$R *.DFM}

end.

