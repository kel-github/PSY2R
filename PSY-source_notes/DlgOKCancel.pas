unit DlgOKCancel;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TOKCancelDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    GroupBox: TGroupBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OKCancelDlg: TOKCancelDlg;

implementation

{$R *.DFM}

end.
