unit PrinterFormat;

{
	PrinterFormat: handle printer output and status reporting
  eventually should have a simmilar unit for general output
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TPrintFormat = class(TForm)
    FileName1: TLabel;
    Pages1: TLabel;
    Cancel1: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Cancel1Click(Sender: TObject);
  private
    { Private declarations }
    FLinesPerPage,
    FStartPage, FEndPage: Integer;
  public
    { Public declarations }
    procedure PageDimensions;
    procedure PrintPage;
  end;

var
  PrintFormat: TPrintFormat;

implementation

{$R *.DFM}

uses
	Printers, ChildWin;

procedure TPrintFormat.FormShow(Sender: TObject);
var
	FCopies, FPage, FPages: Integer;
  copyStr: String;
begin
	// do print formatting here
  with Printer do
  begin
    copyStr := (ActiveMDIChild as TMDIChild).Caption;
    if (copyStr = '') then
    	copyStr := 'Untitled';
  	Title := 'Psy: ' + copyStr;
// for now
{    FPages := FEndPage - FStartPage +1;
    if Copies > 1 then
    	copyStr := '(1)'
    else
    	copyStr := '';
    for FCopies := 1 to Copies do
    begin
	    BeginDoc;
  	  try
      	if (FCopies > 1) then
        	copyStr := '(' + IntToStr(FCopies) + ')';
      	for FPage := FStartPage to FEndPage do
        begin
        	Pages1.Caption := format('Page: %2d of %2d', [FPage, FPages]);
        	PrintPage;
        end;
	    finally
  	  	EndDoc;
    	end;
    end;
}  end;
end;

procedure TPrintFormat.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
	// abort printing if canceled
  if (ModalResult = mrCancel) then
  try
  	Printer.Abort;
  except on EPrinter do {nothing};
  end;
end;

procedure TPrintFormat.Cancel1Click(Sender: TObject);
begin
	ModalResult := mrCancel;
  Close;
end;

procedure TPrintFormat.PageDimensions;
begin
	with Printer, (ActiveMDIChild as TMDIChild) do
  begin
    FLinesPerPage := PageHeight;
    FStartPage := 1;
    FEndPage := 1;
  end;
end;

procedure TPrintFormat.PrintPage;
begin
end;
end.
