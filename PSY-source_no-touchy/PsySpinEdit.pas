{
  scrollbar disabling (see menu w scrollbars but text less than area
}
unit PsySpinEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, CommCtrl, Math;

type
  TPsyCustomSpinEdit = class(TCustomEdit)
  private
    { Private declarations }
    FPosition: Integer;  // use position for scrolling, prevents rounding probs
    FPlaces:  Integer;  // number of decimal places in FValueIncrement
    FAlignment: TAlignment;
    FArrowKeys: Boolean;
    FUpDown: Boolean;
    FValue: Double;
    FValueDefault: Double;
    FValueIncrement: Double;
    FValueIntOnly: Boolean;
    FValueMax: Double;
    FValueMin: Double;
    // private fn to keep Value in range min to max
    function ValueRange(InValue: Double): Double;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetAlignment(InValue: TAlignment);
    procedure SetUpDown(InValue: Boolean);
    function GetValue: Double;
    procedure SetValue(InValue: Double);
    function GetValueDefault: Double;
    procedure SetValueDefault(InValue: Double);
    procedure SetValueIncrement(InValue: Double);
    procedure SetValueMax(InValue: Double);
    procedure SetValueMin(InValue: Double);
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
    function ValueCheckError: Boolean;
    property Alignment: TAlignment read FAlignment write SetAlignment default taRightJustify;
    property ArrowKeys: Boolean read FArrowKeys write FArrowKeys default True;
    property UpDown: Boolean read FUpDown write SetUpDown default True;
    property Value: Double read GetValue write SetValue;
    property ValueDefault: Double read GetValueDefault write SetValueDefault;
    property ValueIncrement: Double read FValueIncrement write SetValueIncrement;
    property ValueIntOnly: Boolean read FValueIntOnly write FValueIntOnly default True;
    property ValueMax: Double read FValueMax write SetValueMax;
    property ValueMin: Double read FValueMin write SetValueMin;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function Validate: Boolean;
  published
    { Published declarations }
  end;

  TPsySpinEdit = class(TPsyCustomSpinEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    property Alignment;
    property ArrowKeys;
    property UpDown;
    property Value;
    property ValueDefault;
    property ValueIncrement;
    property ValueIntOnly;
    property ValueMax;
    property ValueMin;
    // following properties copied from StdCtrls.TEdit
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
//    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPsySpinEdit]);
end;

{ Create own Spin Edit control }
constructor TPsyCustomSpinEdit.Create(AOwner: TComponent);
begin
  inherited;
  // set defaults
  FArrowKeys := True;
  FUpDown := True;
  FValueIntOnly := True;
  FPosition := 0;
  FValue := 0;
  FValueDefault := 0;
  FValueIncrement := 1;
  FPlaces := 0;
  FValueMax := 100;
  FValueMin := 0;
  Alignment := taRightJustify;
  Text := '0';
  MaxLength := 7;  // -xxx.xx
  Width := Font.Size * 7 + GetSystemMetrics(SM_CXVSCROLL); // default 7 chars wide + scrollbar width
end;

procedure TPsyCustomSpinEdit.CreateParams(var Params: TCreateParams);
const
  ScrollBar: array[Boolean] of DWORD = (0, WS_VSCROLL);
  Alignments: array[Boolean, TAlignment] of DWORD =
    ((ES_LEFT, ES_RIGHT, ES_CENTER),(ES_RIGHT, ES_LEFT, ES_CENTER));
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not ES_LEFT;
    Style := Style or Alignments[UseRightToLeftAlignment, FAlignment] or
                      ScrollBar[FUpDown];
  end;
end;

procedure TPsyCustomSpinEdit.WMVScroll(var Message: TWMVScroll);
type Tdirn = (up, down);
  procedure SetNewValue(dirn: Tdirn);
  begin
    if dirn = up then
      inc(FPosition)
    else
      dec(FPosition);
    FValue := FPosition * FValueIncrement;
    try
      Text := Format('%.*f', [FPlaces, FValue]);
    except
      on EConvertError do ;  // do nothing
    end;
  end;

begin
  inherited;
  SetFocus;
  with Message do
    case ScrollCode of
      SB_LINEUP: begin;  // * strange floting pt handling
        if FValueIncrement * (FPosition +1) <= FValueMax +0.0000001 then
          SetNewValue(up);
        SelectAll;
      end;
      SB_LINEDOWN: begin;
        if FValueIncrement * (FPosition -1) >= FValueMin then
          SetNewValue(down);
        SelectAll;
      end;
    end;
end;

// private fn to keep Value in range min to max
function TPsyCustomSpinEdit.ValueRange(InValue: Double): Double;
begin
  Result := InValue;
  if InValue < FValueMin then
    Result := FValueMin;
  if InValue > FValueMax then
    Result := FValueMax;
end;

procedure TPsyCustomSpinEdit.SetAlignment(InValue: TAlignment);
begin
  if FAlignment <> InValue then
  begin
    FAlignment := InValue;
    RecreateWnd;  // alignment needs to send new window params
  end;
end;

procedure TPsyCustomSpinEdit.SetUpDown(InValue: Boolean);
begin
  if FUpDown <> InValue then
  begin
    FUpDown := InValue;
    RecreateWnd;  // for scrollbars need to send new window params
  end;
end;

function TPsyCustomSpinEdit.GetValue;
begin
  Result := ValueRange(FValue);
end;

procedure TPsyCustomSpinEdit.SetValue(InValue: Double);
begin
  if FValue <> InValue then
  begin
    FValue := InValue;  // don't change FValue here, handled by max & min
    FPosition := Trunc(FValue / FValueIncrement);  // to nearest Increment value
    Text := Format('%.*f', [FPlaces, ValueRange(FValue)]);  // the whole value
//    Invalidate; // request update of image
  end;
end;

function TPsyCustomSpinEdit.GetValueDefault;
begin
  Result := ValueRange(FValueDefault);
end;

procedure TPsyCustomSpinEdit.SetValueDefault(InValue: Double);
begin
  if FValueDefault <> InValue then
    FValueDefault := InValue;
end;

procedure TPsyCustomSpinEdit.SetValueIncrement(InValue: Double);
var
  tmpStr: String;
  tmpPos: Integer;
begin
  if (FValueIncrement <> InValue) and (InValue > 0) then
  begin
    FValueIncrement := InValue;
    FPosition := Trunc(FValue / FValueIncrement);
    tmpStr := FloatToStr(FValueIncrement);
    tmpPos := Pos('.', tmpStr);
    if tmpPos > 0 then  // has a '.'
      FPlaces := Length(tmpStr) - tmpPos
    else
      FPlaces := 0;
    Text := Format('%.*f', [FPlaces, ValueRange(FValue)]);
  end;
end;

procedure TPsyCustomSpinEdit.SetValueMax(InValue: Double);
begin
  if (FValueMax <> InValue) and (FValueMax > FValueMin) then
  begin
    FValueMax := InValue;
    FValue := ValueRange(FValue);  // do range checking here
    FValueDefault := ValueRange(FValueDefault);
    FPosition := Trunc(FValue / FValueIncrement);
    Text := Format('%.*f', [FPlaces, FValue]);
  end;
end;

procedure TPsyCustomSpinEdit.SetValueMin(InValue: Double);
begin
  if (FValueMin <> InValue) and (FValueMin < FValueMax) then
  begin
    FValueMin := InValue;
    FValue := ValueRange(FValue);  // do range checking here
    FValueDefault := ValueRange(FValueDefault);
    FPosition := Trunc(FValue / FValueIncrement);
    Text := Format('%.*f', [FPlaces, FValue]);
  end;
end;

function TPsyCustomSpinEdit.ValueCheckError: Boolean;
var
  tmpVal: Double;
begin
  Result := False;
  try
    tmpVal := StrToFloat(Text);
    if tmpVal <> ValueRange(tmpVal) then  // change if not in range
    begin
      Beep;
      MessageDlg('Value must be between ' +
        FloatToStr(FValueMin) + ' and ' + FloatToStr(FValueMax),
        mtWarning, [mbOK], 0);
      SetFocus;
      SelectAll;
      Result := True;
  end;
  except
    on EConvertError do
    begin
      Beep;
      if Text = '' then
        MessageDlg('Value required', mtWarning, [mbOK], 0)
      else if FValueIntOnly then
        MessageDlg('''' + Text + ''' is not a valid Integer value',
          mtWarning, [mbOK], 0)
      else
        MessageDlg('''' + Text + ''' is not a valid Real value',
          mtWarning, [mbOK], 0);
      SetFocus;
      SelectAll;
      Result := True;
    end;
  end;
end;

procedure TPsyCustomSpinEdit.DoExit;
begin
  if ValueCheckError then Exit;
  inherited;
end;

function TPsyCustomSpinEdit.Validate: Boolean;
begin
  Result := ValueCheckError;
end;

procedure TPsyCustomSpinEdit.Change;
begin
  inherited;
  try
    FValue := StrToFloat(Text);
  except
    on EConvertError do exit;
  end;
  FValue := ValueRange(FValue);
  if FValue > 0 then  // fixes probs with Trunc
    FPosition := Trunc((FValue + 0.0000001) / FValueIncrement)
  else
    FPosition := Trunc((FValue - 0.0000001) / FValueIncrement);
{  if (FPosition * FValueIncrement < FValueMin) then
    inc(FPosition)
  else if (FPosition * FValueIncrement > FValueMax) then
    dec(FPosition);
}//  FPosition := Trunc(FValue / FValueIncrement);
end;

procedure TPsyCustomSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FArrowKeys then
  begin
    if Key = VK_UP then
    begin
      if HandleAllocated then
        SendMessage(Handle, WM_VSCROLL, SB_LINEUP, 0);
      Key := 0;
    end;
    if Key = VK_DOWN then
    begin
      if HandleAllocated then
        SendMessage(Handle, WM_VSCROLL, SB_LINEDOWN, 0);
      Key := 0;
    end;
  end;
  inherited;
end;

procedure TPsyCustomSpinEdit.KeyPress(var Key: Char);
  function CharInText(InKey: Char): Integer;
  begin
    Result := pos(InKey, Text);
    if (Result = 0) then Exit;
    // SelStart = 0 at start, pos = 1
    if (Result > SelStart) and (Result <= SelStart + SelLength) then
      Result := 0;  // ignor if key in selected text
  end;

begin
  // restricts keys to strict number formats
  case Key of
    #8: ; // OK jump out of case
    // numbers must be after sign
    '0'..'9': if (SelStart < CharInText('+')) or (SelStart < CharInText('-')) then
                Key := #0;
    // +/- at start and not in text already
    '+', '-': if (SelStart <> 0) or
                 (CharInText('+') > 0) or (CharInText('-') > 0) then
                Key := #0;
    // if int only, already pressed or before sign then ignore
    '.': if FValueIntOnly or (CharInText('.') > 0) or
            (SelStart < CharInText('+')) or (SelStart < CharInText('-')) then
           Key := #0;
  else
    Key := #0;
  end;
  inherited KeyPress(Key);  // pass value of Key
end;

end.

