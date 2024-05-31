unit ChildWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Defines, ExtCtrls;

type
  TMDIChild = class(TForm)
    ChildEdit: TRichEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ChildEditChange(Sender: TObject);
  private
    { Private declarations }
    function GetModified: Boolean;
    procedure SetModified(Value: Boolean);
  public
    { Public declarations }
    Touched: Boolean;
    IsRunnable: Boolean;
    FileName: String;
    IsInWin: Boolean;
    CloseCheck: Boolean;
    KeyList: TPsyKeyList;
    property Modified: Boolean read GetModified write SetModified;
  end;

var
  MDIChild: TMDIChild;

implementation

uses
  Main, InChildWin, DataCheck;

{$R *.DFM}

procedure TMDIChild.FormCreate(Sender: TObject);
begin
  IsRunnable := False;
  CloseCheck := True;
  FileName := '';
  IsInWin := False;
  New(KeyList.OutKeyList);
  PsyCheck.InitKeyList(Self);
end;

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.RemoveOutTreeNodes;
  Dispose(KeyList.OutKeyList);
//  Touched := True;  // force tree view update
  Action := caFree;
end;

procedure TMDIChild.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  CloseMsg: String;
begin
  CanClose := False;
  if Modified and CloseCheck then
  begin
    if IsInWin then
      CloseMsg := cwInCloseSaveMsg
    else
      CloseMsg := cwOutCloseSaveMsg;
    MessageBeep(MB_ICONEXCLAMATION);
    case MessageDlg(CloseMsg, mtWarning, [mbYes, mbNo, mbCancel],0) of
      mrYes:
        MainForm.FileSave1.Execute;
      mrNo:
        CloseCheck := False;  // prevent Close using messages after CloseQuery
      mrCancel:
        exit;
    end;
  end
  else
    CloseCheck := True;
  CanClose := True;
end;

function TMDIChild.GetModified: Boolean;
begin
  Result := ChildEdit.Modified;
end;

procedure TMDIChild.SetModified(Value: Boolean);
begin
  ChildEdit.Modified := Value;
end;

procedure TMDIChild.ChildEditChange(Sender: TObject);
begin
  Touched := True;
end;

end.
