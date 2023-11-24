unit DlgWarnings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Menus;

type
  TWarnings = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PopupMenu1: TPopupMenu;
    Whatsthis1: TMenuItem;
    BitBtn3: TBitBtn;
    ListBox1: TListBox;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn2Click(Sender: TObject);
    procedure Whatsthis1Click(Sender: TObject);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    RightContext: THelpContext;
    function GetContext(Warning: String; var Message: String): Integer;
  public
    { Public declarations }
  end;

var
  Warnings: TWarnings;

implementation

{$R *.DFM}

uses
	math;

// parse warning for message and context, return context
function TWarnings.GetContext(Warning: String; var Message: String): Integer;
var
  delimIndex: Integer;
begin
  Result := 0;
  // split warning into text & context
  delimIndex := LastDelimiter(';', Warning);
  if (Length(Warning) > delimIndex +1) then
  begin
    try
      Result := StrToInt(Copy(Warning, delimIndex +1, Length(Warning)));
    except
      on EConvertError do
        Result := 0;
    end;
  end;
  if (delimIndex > 0) then
    Message := Copy(Warning, 0, delimIndex -1)
  else
    Message := '';
end;

// draw the text so as to remove the help context
procedure TWarnings.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  tmpText: String;
  Context: Integer;
begin
  with (Control as TListBox), Canvas do  // draw on control canvas,
  begin                                 // not on the form
    Context := GetContext(ListBox1.Items[Index], tmpText);
    // set help context & display text
    if (odFocused in State) or (odSelected in State) then
      HelpContext := Context;
  	FillRect(Rect);  // clear the rectangle
    TextOut(Rect.Left + 2, Rect.Top, tmpText);  // draw the message
  end;
end;

{
  Help activation,
    Double Click
    Right Click
    F1 key
    Help Button
}
procedure TWarnings.ListBox1DblClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TWarnings.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F1) then
    Application.HelpContext(HelpContext);
end;

procedure TWarnings.BitBtn2Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TWarnings.Whatsthis1Click(Sender: TObject);
begin
  // only pops up when over message, so no need to check here
  Application.HelpContext(RightContext);
end;

procedure TWarnings.ListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  APoint: TPoint;
  Index: Integer;
  dumby: String;
begin
  if (Button = mbRight) then
  begin
    APoint.x := X;
    APoint.y := Y;
    Index := ListBox1.ItemAtPos(APoint, True);
    if (Index > -1) then
    begin
      RightContext := GetContext(ListBox1.Items[Index], dumby);
      // X & Y don't account for client's position
      PopupMenu1.Popup(Mouse.CursorPos.x, Mouse.CursorPos.y);
    end;
  end;
end;

procedure TWarnings.FormActivate(Sender: TObject);
var
  i, j, maxLength: Integer;
begin
  maxLength := 0;
  // find length of longest message & enable Horiz scroll bar
  with ListBox1, Canvas do
  begin
    for i := 0 to Items.Count -1 do
    begin
      j := TextWidth(Items[i]);
      if j > maxLength then maxLength := j;
    end;
    Perform(LB_SETHORIZONTALEXTENT, maxLength, 0);
  end;

  // place buttons
	if (Pos('ERROR', ListBox1.Items.Text) > 0) then
  begin
	  BitBtn3.Left := (Self.Width - BitBtn3.Width) div 2; // centered
  	BitBtn1.Visible := False;
  end
  else
  begin
	  BitBtn3.Left := BitBtn1.Left + BitBtn1.Width +5; // next to OK
  	BitBtn1.Visible := True;
  end;
end;

procedure TWarnings.FormResize(Sender: TObject);
begin
	ListBox1.Height := BitBtn1.Top -5;
  BitBtn1.Left := max(0, (Self.Width div 2) -2 -BitBtn1.Width);  // left of center
	if (Pos('ERROR', ListBox1.Items.Text) > 0) then
  begin
	  BitBtn3.Left := (Self.Width - BitBtn3.Width) div 2; // centered
  	BitBtn1.Visible := False;
  end
  else
  begin
	  BitBtn3.Left := BitBtn1.Left + BitBtn1.Width +5; // next to OK
  	BitBtn1.Visible := True;
  end;
end;

end.
