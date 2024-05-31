unit Main;

interface

uses
  Windows, SysUtils, Forms, Dialogs, ImgList, Controls, StdActns, Classes,
  ActnList, Menus, ComCtrls, StdCtrls, ToolWin, ChildWin, InChildWin,
	Messages, ExtCtrls, DataCheck, Defines;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
		Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
		ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    View1: TMenuItem;
    ViewGridItem: TMenuItem;
    StatsAnalysis1: TAction;
    ToolButton14: TToolButton;
    tbRunAnalysis: TToolButton;
    Stats1: TMenuItem;
    Analysis1: TMenuItem;
    ViewCode1: TAction;
    SaveDialog: TSaveDialog;
    N2: TMenuItem;
    Print1: TMenuItem;
    Insert1: TMenuItem;
    Delete1: TMenuItem;
    Distribution1: TMenuItem;
    Design1: TMenuItem;
    FilePrint1: TAction;
		EditIns1: TAction;
    EditDel1: TAction;
    StatsCrit1: TAction;
    ViewLabel1: TAction;
    OptsCode1: TAction;
    OptsPlaces1: TAction;
    SetSaveNow1: TAction;
    Options1: TMenuItem;
    UseCode1: TMenuItem;
    N4: TMenuItem;
    DecimalPlaces1: TMenuItem;
    N5: TMenuItem;
    SaveSettingsNow1: TMenuItem;
    tbProbCalc: TToolButton;
    ToolButton17: TToolButton;
    PrintDialog1: TPrintDialog;
    EditUndo1: TAction;
    Undo1: TMenuItem;
    N6: TMenuItem;
    ToolButton19: TToolButton;
    EditSelectAll1: TAction;
    SelectAll1: TMenuItem;
    ToolButton18: TToolButton;
    ViewToolBar1: TAction;
    ViewToolBar2: TMenuItem;
    ProgressBar1: TProgressBar;
    SetOnExit1: TAction;
		SaveSettingOnExit1: TMenuItem;
    TreeView1: TTreeView;
    Splitter1: TSplitter;
    ToolButton20: TToolButton;
    Navigator1: TMenuItem;
    ViewNavigator: TAction;
    WindowSwitch1: TAction;
    Switch1: TMenuItem;
    ToolButton21: TToolButton;
    HelpStart: TAction;
    Contents1: TMenuItem;
    N3: TMenuItem;
    PopupMenu1: TPopupMenu;
    HelpPopup1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FileSaveAs1Execute(Sender: TObject);
    procedure ViewCode1Execute(Sender: TObject);
    procedure ViewCode1Update(Sender: TObject);
    procedure StatsAnalysis1Update(Sender: TObject);
    procedure FileSaveAs1Update(Sender: TObject);
    procedure FileSave1Update(Sender: TObject);
    procedure FilePrint1Update(Sender: TObject);
    procedure StatsAnalysis1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FilePrint1Execute(Sender: TObject);
    procedure ViewToolBar1Execute(Sender: TObject);
    procedure OptsCode1Execute(Sender: TObject);
    procedure EditDel1Execute(Sender: TObject);
    procedure EditDel1Update(Sender: TObject);
    procedure EditUndo1Update(Sender: TObject);
    procedure EditUndo1Execute(Sender: TObject);
		procedure EditSelectAll1Update(Sender: TObject);
		procedure EditSelectAll1Execute(Sender: TObject);
		procedure OptsPlaces1Execute(Sender: TObject);
		procedure EditIns1Execute(Sender: TObject);
		procedure EditIns1Update(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure SetSaveNow1Execute(Sender: TObject);
		procedure SetOnExit1Execute(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure StatsCrit1Execute(Sender: TObject);
		procedure ViewNavigatorUpdate(Sender: TObject);
		procedure ViewNavigatorExecute(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WindowSwitch1Update(Sender: TObject);
    procedure WindowSwitch1Execute(Sender: TObject);
    procedure HelpStartExecute(Sender: TObject);
    procedure HelpPopup1Click(Sender: TObject);
    procedure TreeView1KeyPress(Sender: TObject; var Key: Char);
    procedure EditCut1Execute(Sender: TObject);
    procedure EditCopy1Execute(Sender: TObject);
    procedure EditPaste1Execute(Sender: TObject);
	private
		{ Private declarations }
		InWin: TMDIInChild;
		OutWin: TMDIChild;
    MainMaximised, ChildMaximised:  Boolean;
    FirstTime: Boolean;
    FTreeInNodes: array[Low(TInKeyTypes)..High(TInKeyTypes)] of TTreeNode;
    FTreeOutNodes: array of array[Low(TOutKeyTypes)..High(TOutKeyTypes)] of TTreeNode;
    FTreeInNode, FTreeOutNode: TTreeNode;
    FNode: TTreeNode;
    function CloseAll: Boolean;
    function IsCustomEdit: Boolean;
    function IsInplaceEdit: Boolean;
    procedure HandleReg(Read0Write1Exit2: Integer);
    // Background processing to maintain program states
    procedure Daemon(Sender: TObject; var Done: Boolean);
    procedure KeyLocate(Sender: TObject);
    procedure TreeViewUpdate(Win: TMDIChild); overload;
    procedure TreeViewUpdate(Win: TMDIInChild); overload;
    procedure ClearInTreeNodes;
		procedure ClearOutTreeNodes;
  public
    { Public declarations }
    procedure RemoveInTreeNodes;
    procedure RemoveOutTreeNodes;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

uses
	PrinterFormat, DlgAnalysis, DlgAbout, Splash,
	PsyFile, {PsyGrid,} DlgPlaces, DlgCritVal, Registry, ArraysClass,
  DlgWarnings, Clipbrd;

{===============================================================================
	Create & Close
===============================================================================}
{ Initialise Settings when form is created }
procedure TMainForm.FormCreate(Sender: TObject);
var
	path: String;
begin
	// set absolute help location, assumes help file in same dir as psy
  path := ExtractFilePath(Application.ExeName);
  Application.HelpFile := path +'Psy.hlp';
	InWin := nil;
	OutWin := nil;
	MainMaximised := False;
	ChildMaximised := False;
	FirstTime := True; // used to maximise in Daemon to avoid timing probs with maximise
	Enabled := False;  // disable use until splash form is finnished
  SetLength(FTreeOutNodes, 1);  // start with 1 out node list
	StatusBar.Panels[0].Width := Width - dfStatusWidth;       // Setup StatusBar
	with ProgressBar1 do                        // Add progress bar to StatusBar
	begin
		Parent := StatusBar;
		Visible := False;
		Top := 5;
		Left := 100;     // set this to right of string describing progress action
	end;
	TreeView1.Hide;
	Splitter1.Hide;
	HandleReg(0);                                      // read registry settings
	Application.OnIdle := Daemon;
	// printer setup
	with PrintDialog1 do
  begin
		Options := [poPageNums, poSelection];
		FromPage := 1;
		MinPage := 1;
		ToPage := 1;
		MaxPage := 1;
  end;
end;

{ Private function to Close All MDI Children }
function TMainForm.CloseAll: Boolean;
var
	I: Integer;
begin
	Result := False;
  for I := MDIChildCount-1 downto 0 do  // check all first
    if not MDIChildren[I].CloseQuery then
      exit;
  for I := MDIChildCount-1 downto 0 do  // then close all
    MDIChildren[I].Close;
  Result := True;

	TreeView1.Hide;
	Splitter1.Hide;
end;

{===============================================================================
  *** Actions ***
===============================================================================}
{ File | New }
procedure TMainForm.FileNew1Execute(Sender: TObject);
var
  DateTime: String;
begin
  if not CloseAll then
    exit;

// for some reason the old form still hangs arround after a close
// this seem extreme but it works
// NB Destroy is not ment to be called directly so this may cause problems
//	while ActiveMDIChild <> nil do ActiveMDIChild.Destroy;

  Splitter1.Show;
  TreeView1.Show;
  InWin := TMDIInChild.Create(Application);
  with InWin do
  begin
{   	WindowState := wsNormal;
		Top := 0;
		Left := 0;
    Width := Self.ClientWidth -TreeView1.Width -dfRight;
}		if ChildMaximised then
			WindowState := wsMaximized
    else
     	WindowState := wsNormal;
		Enabled := False;
    Caption := cwInTitle + cwDefTitle;
    FileName := '';
		// Initialiase template
		DateTime := 'Created: ' + DateToStr(Date) + ' ' + TimeToStr(Time);
		{NotesMemo.Lines.CommaText := '"Psy",,' +
			'"' + DateTime + '",,';}
		{ Initial Lines
		//Psy
		//
		//creation time & date
		//

		[Data]

		[BetweenContrasts]

		[WithinContrasts]
		}
		ChildEdit.Lines.CommaText := '"//PSY",//,' +
			'"//' + DateTime + '",//,,' +
			'[Data],,' +
			'[BetweenContrasts],,' +
			'[WithinContrasts],';
		ChildEdit.SelStart :=
      SendMessage(ChildEdit.Handle, EM_LINEINDEX, 6, 0);  // set to start of data entry point
		ChildEdit.SelLength := 0;  // select line
		{ChildEdit.}Modified := False;
		Enabled := True;
    FTreeInNode := TreeView1.Items.AddChildFirst(nil, Caption);
//    ChildEdit.ClearUndo; //*** doesn't seem to clear undo
{ ClearUndo is wrong, it sends WM_CLEAR not EM_EMPTYUNDOBUFFER message }
    SendMessage(ChildEdit.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
	end;
end;

{ File | Open }
procedure TMainForm.FileOpen1Execute(Sender: TObject);
var
	Win: TMDIChild;
	FileName: String;
	mbRtn: Word;
  psyType: Byte;
begin
	Win := nil;
	OpenDialog.DefaultExt := cwOpenDef;
	psyType := 7;  // in case error in IsPsyFile
  try
	if OpenDialog.Execute then
	begin
		FileName := OpenDialog.FileName;
		if FileExists(FileName) then
		begin
			with PsyCheck do
			begin
      	psyType := 7;  // in case error in IsPsyFile
      	psyType := IsPsyFile(FileName);
				case (psyType) of  // check 1st line for Psy header info
				0:  begin  // IN file
      		if not CloseAll then
      			exit;
          Splitter1.Show;
          TreeView1.Show;
					InWin := TMDIInChild.Create(Application);
					with InWin, ChildEdit do
					begin
						FileName := OpenDialog.FileName;
						Caption := cwInTitle + ExtractFileName(FileName);
{						WindowState := wsNormal;
						InWin.Top := 0;
						InWin.Left := 0;
			      InWin.Width := Self.ClientWidth -TreeView1.Width -dfRight;
}						if ChildMaximised  then
							WindowState := wsMaximized
            else
              WindowState := wsNormal;
            Lines.BeginUpdate;
						PlainText := True;  // force file to be read as plain text
						Lines.LoadFromFile(FileName);
            TabToMark(Lines);  // convert tabs to '»' mark
						Lines.Delete(0);  // remove Psy header info
            SendMessage(ChildEdit.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
						Modified := False;  // don't prompt for save until modified
            Touched := True;
            // data update done by treeviewupdate
            FTreeInNode := TreeView1.Items.AddChildFirst(nil, Caption);
						PlainText := False;  // alow rich text during editting
            Lines.EndUpdate;
					end;
				end;
				1:  begin  // OUT file
          if not CloseAll then
            exit;
// do we want to be able to open in and out files?
// causes an exception, OutWin not set to nil after close
{          if (OutWin <> nil) and OutWin.CloseQuery then
            OutWin.Close;
}
          Splitter1.Show;
          TreeView1.Show;
					OutWin := TMDIChild.Create(Application);
					with OutWin, ChildEdit do
					begin
						FileName := OpenDialog.FileName;
						Caption := cwOutTitle + ExtractFileName(FileName);
{						WindowState := wsNormal;
  					OutWin.Top := dfTop;
						OutWin.Left := dfLeft;
			      OutWin.Width := Self.ClientWidth -TreeView1.Width -dfRight;
}						if ChildMaximised  then
							WindowState := wsMaximized
            else
              WindowState := wsNormal;
            Lines.BeginUpdate;
						PlainText := True;  // force file to be read as plain text
						Lines.LoadFromFile(FileName);
            TabToMark(Lines);  // convert tabs to '»' mark
						Lines.Delete(0);  // remove Psy header info
            SendMessage(ChildEdit.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
						Modified := False;  // don't prompt for save until modified
            Touched := True;
            FTreeOutNode := TreeView1.Items.AddChild(nil, Caption);
						PlainText := False;  // alow rich text during editting
            Lines.EndUpdate;
					end;
				end
				else  // unknown, assume IN file
				  if (OpenDialog.FilterIndex = 1) then  // IN?
				  begin
          	Beep();
						mbRtn := MessageDlg(ExtractFileName(FileName) +
							' is not recognised as a PSY ''IN'' file' + dfNL + 'Open anyway?',
							mtConfirmation, [mbYes, mbCancel], 0);
						if (mbRtn = mrYes) then
            begin
          		if not CloseAll then
          			exit;
              TreeView1.Show;
   						Win := TMDIInChild.Create(Application);  // IN
            end;
				  end
          else if (OpenDialog.FilterIndex = 2) then  // OUT?
				  begin
          	Beep();
						mbRtn := MessageDlg(ExtractFileName(FileName) +
							' is not recognised as a PSY ''OUT'' file' + dfNL + 'Open anyway?',
							mtWarning, [mbYes, mbCancel], 0);
						if (mbRtn = mrYes) then
            begin
              if not CloseAll then
                exit;
{              if (OutWin <> nil) and OutWin.CloseQuery then
                OutWin.Close;
}
              Splitter1.Show;
              TreeView1.Show;
   						Win := TMDIChild.Create(Application);  // OUT
            end;
				  end
				  else  // any other type, use IN
				  begin
          	Beep();
						mbRtn := MessageDlg(ExtractFileName(FileName) +
							' is not recognised as a PSY file' + dfNL + 'Open anyway?',
							mtWarning, [mbYes, mbCancel], 0);
						if (mbRtn = mrYes) then
            begin
          		if not CloseAll then
          			exit;
              Splitter1.Show;
              TreeView1.Show;
   						Win := TMDIInChild.Create(Application);  // IN
            end;
				  end;
					if (mbRtn = mrYes) then
					begin
						with Win do
						begin
							FileName := OpenDialog.FileName;
	            ChildEdit.Lines.BeginUpdate;
							ChildEdit.PlainText := True;  // force file to be read as plain text
							ChildEdit.Lines.LoadFromFile(FileName);
	            TabToMark(ChildEdit.Lines);  // convert tabs to '»' mark
							ChildEdit.PlainText := False;  // alow rich text during editting
// do conversion latter ?, convert at all ?
{							if IsInWin and (mbRtn = mrYes) and (not ConvertToPsy(Win)) then
              begin
		          	Beep();
								MessageDlg(ExtractFileName(FileName) +
									' could not be properly converted', mtWarning, [mbOK], 0);
              end;
}
	            SendMessage(ChildEdit.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
							Modified := True;  // force save
              Touched := True;
	            ChildEdit.Lines.EndUpdate;
							FileName := '';  // force save as
              if IsInWin then
              begin
								Caption := cwInTitle + cwDefTitle;
{								WindowState := wsNormal;
								Win.Top := 0;
								Win.Left := 0;
					      Win.Width := Self.ClientWidth -TreeView1.Width -dfRight;
}								if ChildMaximised  then
									WindowState := wsMaximized
                else
                  WindowState := wsNormal;
              	InWin := (Win as TMDIInChild);
                FTreeInNode := TreeView1.Items.AddChildFirst(nil, Caption);
              end
              else
              begin
								Caption := cwOutTitle + cwDefTitle;
{								WindowState := wsNormal;
								Win.Top := dfTop;
								Win.Left := dfLeft;
					      Win.Width := Self.ClientWidth -TreeView1.Width -dfRight;
}								if ChildMaximised  then
									WindowState := wsMaximized
                else
                  WindowState := wsNormal;
              	OutWin := Win;
                FTreeOutNode := TreeView1.Items.AddChildFirst(nil, Caption);
              end;  // if IsInWin
						end;  // with win
					end  // if Yes
					else  // Cancel
						;
				end;  // case ... else
			end;  // with PsyCheck
		end;  // if FileExists
	end;  // if OpenDialog.Execute
  except
  	on E: Exception do
    begin
    	MessageDlg('Error reading file.' + dfNL +
                 'The file may be open in another program.', mtError, [mbOK], 0);
      if (psyType = 7) then exit;
      if (psyType = 1) and (OutWin <> nil) then OutWin.Close;
      if (psyType <> 1) and (InWin <> nil) then InWin.Close;
    end;
  end;
end;

{ File | Save }
procedure TMainForm.FileSave1Execute(Sender: TObject);
var
	Win:  TMDIChild;
  tmpLines: TStringList;
begin
	Win := (ActiveMDIChild as TMDIChild);
{	if ViewCode1.Checked then
		PsyCheck.CheckData(InWin)  // convert to grid, do this silently
	else
		PsyCheck.DataToMemo(InWin);  // convert to memo
}	if Win.FileName = '' then
  begin
		FileSaveAs1.Execute;  // SaveAs gets info only and comes back with FileName
  end
  else
  begin
  	tmpLines := TStringList.Create;
  	with Win, tmpLines do
    begin
    	Clear;
      ChildEdit.PlainText := True;  // must save as plain text or else header info is rtf stuff
      AddStrings(ChildEdit.Lines);
      ChildEdit.PlainText := False;
    	//BeginUpdate;
	  	if IsInWin then                  // add headers
  	     Insert(0, PSYINHEADER)
    	else
  	     Insert(0, PSYOUTHEADER);
      PsyCheck.MarkToTab(tmpLines);  // convert tab marks to tabs
	    SaveToFile(Win.FileName);        // save
  	  //Delete(0);                       // remove header
      SendMessage(ChildEdit.Handle, EM_EMPTYUNDOBUFFER, 0, 0);
      //EndUpdate;
    end;
    // if saved succesfuly mark as unmodified
		if Win.Modified then
      Win.Modified := False;
//    if ActiveMDIChild is TMDIInChild then
//      (ActiveMDIChild as TMDIInChild).Modified := False;
		tmpLines.Free;
  end;
end;

{ File | SaveAs }
procedure TMainForm.FileSaveAs1Execute(Sender: TObject);
var
  Win: TMDIChild;
begin
  // TMDIInChild is derived form TMDIChild so check if TMDIInChild first
  if ActiveMDIChild is TMDIInChild then  // .in file
  begin
    SaveDialog.DefaultExt := cwSaveIn;
    SaveDialog.FilterIndex := 1;
  end
  else if ActiveMDIChild is TMDIChild then  // .out file
  begin
    SaveDialog.DefaultExt := cwSaveOut;
    SaveDialog.FilterIndex := 2;
  end;

	{ because IN & OUT use diff forms and trees don't allow one to be saved
    as the other }
  Win := (ActiveMDIChild as TMDIChild);
  if not SaveDialog.Execute then
 	  exit;
  while Win.IsInWin and (SaveDialog.FilterIndex = 2) do
  begin
  	MessageDlg('A PSY ''IN'' file cannot be saved as a PSY ''OUT'' file',
      mtError, [mbOK], 0);
	  if not SaveDialog.Execute then
  	  exit;
  end;
  while not Win.IsInWin and (SaveDialog.FilterIndex = 1) do
  begin
  	MessageDlg('A PSY ''OUT'' file cannot be saved as a PSY ''IN'' file',
      mtError, [mbOK], 0);
	  if not SaveDialog.Execute then
  	  exit;
  end;

  Win.FileName := SaveDialog.FileName;
  if (not Win.IsInWin) then  // OUT
  begin
    Win.Caption := cwOutTitle + ExtractFileName(Win.FileName);
    FTreeOutNode.Text := Win.Caption;
  end
	else  // IN
  begin
    Win.Caption := cwInTitle + ExtractFileName(Win.FileName);
    FTreeInNode.Text := Win.Caption;
  end;
  FileSave1.Execute;
end;

{ File | Exit }
procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

{ Form Close, save settings if necessary }
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if SetOnExit1.Checked then
    HandleReg(1)  // write
  else
    HandleReg(2);  // exit
  Action := caFree;
end;

{ Edit | Cut }
procedure TMainForm.EditCut1Execute(Sender: TObject);
begin
  with ActiveMDIChild do
  begin
    if (ActiveControl is TCustomEdit) then
    begin
      (ActiveControl as TCustomEdit).CutToClipboard;
      if (ActiveMDIChild is TMDIInChild) then  // '»' to tab
       	Clipboard.AsText := StringReplace(Clipboard.AsText , '»', #9,
                              [rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

{ Edit | Copy }
procedure TMainForm.EditCopy1Execute(Sender: TObject);
begin
  with ActiveMDIChild do
  begin
    if (ActiveControl is TCustomEdit) then
    begin
      (ActiveControl as TCustomEdit).CopyToClipboard;
      if (ActiveMDIChild is TMDIInChild) then  // '»' to tab
       	Clipboard.AsText := StringReplace(Clipboard.AsText , '»', #9,
                              [rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

{ Edit | Paste }
procedure TMainForm.EditPaste1Execute(Sender: TObject);
begin
	EditIns1Execute(Sender);
end;

{ Edit | Undo }
procedure TMainForm.EditUndo1Execute(Sender: TObject);
begin
  with ActiveMDIChild do
  begin
    if ActiveControl is TCustomEdit then
      (ActiveControl as TCustomEdit).Undo
;{    else if (ActiveControl is TPsyGrid) then  // check CellEditor exists done by update
      (ActiveControl as TPsyGrid).CellEditor.Undo;
}  end;
  // also undo sellected cell deletes ?
end;

{ Edit | Insert }
procedure TMainForm.EditIns1Execute(Sender: TObject);
begin
  if (ActiveMDIChild is TMDIInChild) then  // tab to '»'
   	Clipboard.AsText := StringReplace(Clipboard.AsText , #9, '»',
                          [rfReplaceAll, rfIgnoreCase]);
  with ActiveMDIChild do
  begin
    if (ActiveControl is TCustomEdit) then
      (ActiveControl as TCustomEdit).PasteFromClipboard;
{    else if (ActiveControl is TPsyGrid) then  // check CellEditor exists done by update
      (ActiveControl as TPsyGrid).CellEditor.PasteFromClipboard;
}
  end;
  if (ActiveMDIChild is TMDIInChild) then  // '»' to tab
   	Clipboard.AsText := StringReplace(Clipboard.AsText , '»', #9,
                          [rfReplaceAll, rfIgnoreCase]);
  // handle ins for cells
end;

{ Edit | Delete }
procedure TMainForm.EditDel1Execute(Sender: TObject);
  // internal procedure, select and delete chars
  procedure OwnDel(Edit: TCustomEdit);
  begin
    // if selection is empty, select next char
    if Edit.SelLength = 0 then
      Edit.SelLength := 1;
    // if Carage Return check for Line Feed and delete both
    // richedit returns '' for CR or LF and CRLF for both
    if Edit.SelText = '' then
    begin
      Edit.SelLength := 2
    end;
    Edit.ClearSelection;
  end;

{var
  Grid: TPsyGrid;
}begin
  with ActiveMDIChild do
  begin
{    if ActiveControl is TPsyGrid then
    begin
      Grid := (ActiveControl as TPsyGrid);
      if Grid.CellEditor.Focused then  // check CellEditor exists done by update
      begin
        OwnDel(Grid.CellEditor);  // is there a windows message to do this?
      end
      else  // manage selected cells
      begin
        // do cell stuff
      end;
    end
    else} if ActiveControl is TCustomEdit then
    begin
      OwnDel((ActiveControl as TCustomEdit));
    end;
  end;
  inherited;
end;

{ Edit | Select All }
procedure TMainForm.EditSelectAll1Execute(Sender: TObject);
begin
  with ActiveMDIChild do
  begin
    if ActiveControl is TCustomEdit then
      (ActiveControl as TCustomEdit).SelectAll
;{    else if (ActiveControl is TPsyGrid) then  // check CellEditor exists done by update
      (ActiveControl as TPsyGrid).CellEditor.SelectAll;
}  end;
  // Select all for cells ?
end;

{ Calculate | Run Analysis }
procedure TMainForm.StatsAnalysis1Execute(Sender: TObject);
begin
{  if ViewCode1.Checked then  // ie memo
    PsyCheck.CheckData(InWin);  // ************check result
}
  PsyCheck.UpdateData(InWin);
  if InWin.IsRunnable then
  begin
    if (PsyCheck.Warnings.Text <> '') then
    begin
      Warnings.ListBox1.Items.Text := PsyCheck.Warnings.Text;
      if (Warnings.ShowModal <> mrOK) then
      	Exit;
    end;
    if (AnalysisDlg.ShowModal = mrOK) then
    begin
  {    if not ViewCode1.Checked then
        PsyCheck.DataToMemo(InWin);
      PsyCheck.DataToMatrices(InWin);
  }    if MDIChildCount < 2 then
      begin
        OutWin := TMDIChild.Create(Application);
        OutWin.Caption := cwOutTitle + cwDefTitle;
  {      OutWin.WindowState := wsNormal;
        OutWin.Top := dfTop;
        OutWin.Left := dfLeft;
        OutWin.Width := Self.ClientWidth -TreeView1.Width -dfRight;
        if ChildMaximised  then
          OutWin.WindowState := wsMaximized;
  }
        FTreeOutNode := TreeView1.Items.AddChild(nil, OutWin.Caption);
      end;
      try
			  Screen.Cursor := crHourGlass;
	      PsyOut.WriteSummaryToMemo(InWin, OutWin);
      finally
			  Screen.Cursor := crDefault;
      end;
    end;
  end
  else
  begin
    Warnings.ListBox1.Items.Text := PsyCheck.Warnings.Text;
    Warnings.ShowModal;
  end;
end;

{ Calculate | Critical Values }
procedure TMainForm.StatsCrit1Execute(Sender: TObject);
begin
  CritValDlg.ShowModal;
end;

{ View | ToolBar }
procedure TMainForm.ViewToolBar1Execute(Sender: TObject);
begin
  ViewToolBar1.Checked := not ViewToolBar1.Checked;  // toggle state
  ToolBar2.Visible := ViewToolBar1.Checked;
end;

{ View | Code }
procedure TMainForm.ViewCode1Execute(Sender: TObject);
begin
(*  ViewCode1.Checked := not ViewCode1.Checked;  // togle checked
  with InWin do
  begin
    if not ViewCode1.Checked then  // view grids
    begin
      ChildEdit.Visible := True;
      Panel1.Visible := False;
      if InWin.Modified then  // need better test to convert ?
        Check.CheckData(InWin);
      Panel1.Visible := True;
      ChildEdit.Visible := False;
      Panel1.SetFocus;
      case TabControl1.TabIndex of  // set focus to grid
        0:  DataGrid.SetFocus;
        1:  BContGrid.SetFocus;
        2:  WContGrid.SetFocus;
        3:  NotesMemo.SetFocus;
      end;
    end
    else  // view text
    begin
      Panel1.Visible := True;
      ChildEdit.Visible := False;
      if InWin.Modified then
        Check.DataToMemo(InWin);
      ChildEdit.Visible := True;
      Panel1.Visible := False;
      ChildEdit.SetFocus;
    end;
  end;
*)end;

{ View | Navigator }
procedure TMainForm.ViewNavigatorExecute(Sender: TObject);
begin
  ViewNavigator.Checked := not ViewNavigator.Checked;  // togle
//  TreeView1.Visible := ViewNavigator.Checked;
  if ViewNavigator.Checked and (TreeView1.Width < 1) then
    TreeView1.Width := dfNavWidth;  // default design width
  if not ViewNavigator.Checked then
    TreeView1.Width := 0;
end;

{ Options | Use Code }
procedure TMainForm.OptsCode1Execute(Sender: TObject);
begin
  OptsCode1.Checked := not OptsCode1.Checked;  // toggle state
end;

{ Options | Decimal Places }
procedure TMainForm.OptsPlaces1Execute(Sender: TObject);
begin
  { ***
   NB prFigs must be >= 3 or get error using format('%*.*s', [x, prFigs -3, ''])
      in PsyFile
  *** }
  with DecimalPlacesDlg, SpinEdt do
  begin
    Value := prFigs;          // set current value
    if ShowModal = mrOK then  // now show the form and get the value when done
      prFigs := Trunc(Value);
  end;
end;

{ Options | Save Settings Now }
procedure TMainForm.SetSaveNow1Execute(Sender: TObject);
begin
  HandleReg(1);  // write
end;

{ Options | Save Setting On Exit }
procedure TMainForm.SetOnExit1Execute(Sender: TObject);
begin
  SetOnExit1.Checked := not SetOnExit1.Checked;
end;

{ Window | Switch }
procedure TMainForm.WindowSwitch1Execute(Sender: TObject);
begin
  Next;
end;

{ Help | Contents }
procedure TMainForm.HelpStartExecute(Sender: TObject);
begin
  Application.HelpContext(0);  // zero is contents and default help
end;

{ Help | About }
procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

{ Right Click Help }
procedure TMainForm.HelpPopup1Click(Sender: TObject);
begin
  // Run Analysis
  if (PopupMenu1.PopupComponent = tbRunAnalysis) then  // use action lists context
    Application.HelpContext((tbRunAnalysis.Action as TAction).HelpContext)
  // Probability Calculator
  else if (PopupMenu1.PopupComponent = tbProbCalc) then
    Application.HelpContext((tbProbCalc.Action as TAction).HelpContext);
end;

{===============================================================================
  Update action states
  Routines to track state of system
  need to be simple since program loops through these updates when idle.
  See TActionList.
===============================================================================}

{ Daemon, maintain program states on idle
  Assigned in TMainForm.Create }
procedure TMainForm.Daemon(Sender: TObject; var Done: Boolean);
begin
  // first time if not maximised ...
  if FirstTime and MainMaximised then
  begin
    FirstTime := False;
    WindowState := wsMaximized;
  end;
  if (Application.Active) then  // don't bother if not active
  begin
    // set state of child window if changed
    if ActiveMDIChild <> nil then
    begin
{      with (ActiveMDIChild as TMDIChild) do
      if ViewNavigator.Checked then  // show Navigator
      begin
				if not Splitter1.Visible then  // order is important, splitter then tree
					Splitter1.Show;
        Repaint;
        if not TreeView1.Visible then
          TreeView1.Show;
			end;
}			if (ActiveMDIChild.WindowState = wsMaximized) then
			begin
				if not ChildMaximised then  // update record of child window state
					ChildMaximised := True;
			end
			else if ChildMaximised then
				ChildMaximised := False;
		end
		else  // no child window open
		begin
      // clean up navigator
			if Splitter1.Visible then  // order is important, splitter then tree
				Splitter1.Hide;
			if TreeView1.Visible then
				TreeView1.Hide;
      if (StatusBar.Panels[1].Text <> '') then
        StatusBar.Panels[1].Text := '';
		end;
		if (ActiveMDIChild is TMDIInChild) {and not ViewCode1.Checked} then
    with InWin do  // ie ActiveMDIChild is InWin and exists
    begin
      StatusBar.Panels[1].Text := 'Line: ' +
	      IntToStr(SendMessage(ChildEdit.Handle, EM_LINEFROMCHAR,
        	ChildEdit.SelStart, 0) +1);
      if Touched then  // only check when new data entered
      begin
        Touched := False;
{        if (ActiveControl is TDataGrid) then
          DataGrid.CountData
        else if (ActiveControl is TBContGrid) then
          BContGrid.CountContrasts
        else if (ActiveControl is TWContGrid) then
          WContGrid.CountContrasts;
}
//        IsRunnable := PsyCheck.CanRun(InWin);
        TreeViewUpdate(InWin);
{ no group/measure status, too time consuming to update every edit
        StatusBar.Panels[1].Text := Format('G:%2d M:%2d',
          [Arrays.NumberOfGroups, Arrays.NumberOfRepeats]);
}
      end;
    end
    else if (ActiveMDIChild is TMDIChild) then  // ie not a TMDIInChild
    with OutWin do
    begin
      StatusBar.Panels[1].Text := 'Line: ' +
	      IntToStr(SendMessage(ChildEdit.Handle, EM_LINEFROMCHAR,
        	ChildEdit.SelStart, 0) +1);
      if Touched then
      begin
        Touched := False;
        TreeViewUpdate(OutWin);
      end;
    end;
{
	  // catch dead trees that wern't killed by CloseAll
    if (InWin <> nil) and InWin.Touched and (FTreeInNode <> nil) then
    begin
    	TreeView1.Items.Delete(FTreeInNode);
      FTreeInNode := nil;
      ClearInTreeNodes;
      InWin.Touched := False;
    end;
    if (OutWin <> nil) and OutWin.Touched and (FTreeOutNode <> nil) then
    begin
    	TreeView1.Items.Delete(FTreeOutNode);
      FTreeOutNode := nil;
      SetLength(FTreeOutNodes, 0);
      OutWin.Touched := False;
    end;
}
  end;
end;

{ View Code }
procedure TMainForm.ViewCode1Update(Sender: TObject);
begin
  ViewCode1.Enabled := (ActiveMDIChild is TMDIInChild);
  ViewCode1.Checked := ((ActiveMDIChild is TMDIInChild) and
                        (ActiveMDIChild as TMDIInChild).ChildEdit.Visible) or
                       ((ActiveMDIChild = nil) and OptsCode1.Checked);
end;

{ View Navigator }
procedure TMainForm.ViewNavigatorUpdate(Sender: TObject);
begin
  ViewNavigator.Enabled := (ActiveMDIChild is TMDIChild);
  // don't change check state when no child
  if ViewNavigator.Enabled then
    ViewNavigator.Checked := TreeView1.Visible and (TreeView1.Width > 0);
end;

{ Run Analysis }
procedure TMainForm.StatsAnalysis1Update(Sender: TObject);
begin
  StatsAnalysis1.Enabled := {(}(MDIChildCount > 0) {and
                             (ViewCode1.Checked or
                              (MDIChildren[0] as TMDIChild).IsRunnable)) or
                            ((MDIChildCount > 1) and
                             (MDIChildren[1] as TMDIChild).IsRunnable)};
end;

{ Save As }
procedure TMainForm.FileSaveAs1Update(Sender: TObject);
begin
  FileSaveAs1.Enabled := (ActiveMDIChild <> nil);
end;

{ Save }
procedure TMainForm.FileSave1Update(Sender: TObject);
begin
  FileSave1.Enabled := ((ActiveMDIChild is TMDIChild) and
                       (ActiveMDIChild as TMDIChild).Modified) or
                       // this update forces a check of Modified
                       ((ActiveMDIChild is TMDIInChild) and
                       (ActiveMDIChild as TMDIInChild).Modified);
end;

{ Print }
procedure TMainForm.FilePrint1Update(Sender: TObject);
begin
  FilePrint1.Enabled := (ActiveMDIChild <> nil) and
                        ((ActiveMDIChild as TMDIChild).ChildEdit.Lines.Count > 0);
end;

{ common checks for edit updates }
function TMainForm.IsCustomEdit: Boolean;
begin
  Result := (ActiveMDIChild is TMDIChild) and
            (ActiveMDIChild.ActiveControl is TCustomEdit);
end;

function TMainForm.IsInplaceEdit: Boolean;
begin
{  Result := (ActiveMDIChild is TMDIInChild) and
            (ActiveMDIChild.ActiveControl is TPsyGrid) and
            Assigned((ActiveMDIChild.ActiveControl as TPsyGrid).CellEditor);
}
  Result := False;
end;

{ Undo }
procedure TMainForm.EditUndo1Update(Sender: TObject);
begin
  EditUndo1.Enabled := IsCustomEdit and
    (ActiveMDIChild.ActiveControl as TCustomEdit).CanUndo
{    or
    IsInplaceEdit and
    (ActiveMDIChild.ActiveControl as TPsyGrid).CellEditor.CanUndo};
end;

{ Insert }
procedure TMainForm.EditIns1Update(Sender: TObject);
begin
  EditIns1.Enabled := IsCustomEdit or IsInplaceEdit;
end;

{ Delete }
procedure TMainForm.EditDel1Update(Sender: TObject);
begin
  EditDel1.Enabled := IsCustomEdit or IsInplaceEdit;
end;

{ SelectAll }
procedure TMainForm.EditSelectAll1Update(Sender: TObject);
begin
  EditSelectAll1.Enabled := IsCustomEdit or IsInplaceEdit;
end;

{ Switch }
procedure TMainForm.WindowSwitch1Update(Sender: TObject);
begin
  WindowSwitch1.Enabled := (MDIChildCount > 1);
end;


//**********************************************************************
procedure TMainForm.FilePrint1Execute(Sender: TObject);
begin
	PrintFormat.PageDimensions;
//  PrintDialog1.MaxPage := xxx;
//  PrintDialog1.ToPage := xxx;
  if (PrintDialog1.Execute) then
// 		PrintFormat.ShowModal;
(ActiveMDIChild as TMDIChild).ChildEdit.Print('Psy');
end;

(* example
procedure TForm1.Button1Click(Sender: TObject);

var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromFile('MyBitmap.bmp');
    with Printer do
    begin
      BeginDoc;
      Canvas.Draw((PageWidth - Bmp.Width) div 2,
                  (PageHeight - Bmp.Height) div 2,
                  Bmp);
      EndDoc;
    end;
  finally
    Bmp.Free;
  end;
end;
*)

{ old print version
procedure TFMain.Mnu_PrintClick(Sender: TObject);
var
  Line: Integer; //declare an integer variable for the number of lines of text
begin
  if PrintDialog1.Execute then
  begin
    AssignPrn(GV_PrintText);	//assign the global variable PrintText to the printer
    Rewrite(GV_PrintText);	//create and open the output file
    Printer.Canvas.Font := ChildEdit.Font; //assign the current Font setting for ChildEdit
    to the Printer object's canvas
    for Line := 0 to ChildEdit.Lines.Count - 1 do
      Writeln(GV_PrintText, ChildEdit.Lines[Line]);	//write the contents of the Memo
      field to the printer object
    System.Close(GV_PrintText);
  end;
end;
}

{===============================================================================
  Maintainence routines
===============================================================================}
{ Private functions to handle registry entries }
procedure TMainForm.HandleReg(Read0Write1Exit2: Integer);
var
  RegHandle: TRegistry;
  CanCreate: Boolean;
begin
  if Read0Write1Exit2 = 0 then
    CanCreate := False
  else
    CanCreate := True;
  RegHandle := nil;  // prevents compiler warning
  try  // Read/Write in order of importance as exception will skip rest
  try
    RegHandle := TRegistry.Create;
    with RegHandle do
    begin
      if OpenKey('Software\UNSW\Psy', CanCreate) then
      begin
        case Read0Write1Exit2 of
          0:  // Read
          begin
            // read Save Settings first in case exception is rased
            SetOnExit1.Checked := ReadBool('SaveSettingsOnExit');
            prFigs := ReadInteger('DecimalPlaces');
            MainMaximised := ReadBool('Maximized');
            ChildMaximised := ReadBool('ChildMaximized');
            ViewToolBar1.Checked := ReadBool('ViewToolbar');
            ToolBar2.Visible := ViewToolBar1.Checked;
            TreeView1.Width := ReadInteger('ViewNavigator');  // 0 if no nav
//            OptsCode1.Checked := ReadBool('UseText');  // not used now
          end;
          1:  // Write
          begin
            WriteBool('SaveSettingsOnExit', SetOnExit1.Checked);
            WriteInteger('DecimalPlaces', prFigs);
            if WindowState = wsMaximized then
              WriteBool('Maximized', True)
            else
              WriteBool('Maximized', False);
            WriteBool('ChildMaximized', ChildMaximised);  // set ChildMaximised in children
            WriteBool('ViewToolbar', ViewToolBar1.Checked);
            WriteInteger('ViewNavigator', TreeView1.Width);  // 0 if no nav
//						WriteBool('UseText', OptsCode1.Checked);  // not used now
          end;
          2:  // Exit
            WriteBool('SaveSettingsOnExit', False);
        end; { case }
      end; { if OpenKey }
    end; { with }
  except
    on ERegistryException do;  // catch but do nothing
  end;
  finally
    RegHandle.Free;
  end;
end;

{ Maintain look on resize }
procedure TMainForm.FormResize(Sender: TObject);
begin
  StatusBar.Panels[0].Width := Width - dfStatusWidth;
end;

{==============================================================================}
{	TreeView handling -- should be in it's own class                             }
{==============================================================================}
procedure TMainForm.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  FNode := Node;  // track selected node
end;

procedure TMainForm.TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  HT : THitTests;
begin
  if (Sender is TTreeView) then  // for correctness
  begin
    with Sender as TTreeView do
    begin
      HT := GetHitTestInfoAt(X,Y);
      if (htOnIcon in HT) or (htOnLabel in HT) then  // clicked an item ?
        KeyLocate(Sender);
    end;
  end;
end;

procedure TMainForm.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Sender is TTreeView) then
  begin
    if (Key = VK_RETURN) or (Key = VK_SPACE) then
    begin
      KeyLocate(Sender);
    end;
  end;
end;

// prevent error beep when pressing enter or space
procedure TMainForm.TreeView1KeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) or (KEY = ' ') then
    Key := #0;
end;

procedure TMainForm.KeyLocate(Sender: TObject);
var
  i: TInKeyTypes;
  j: TOutKeyTypes;
  x: Integer;
  flagIn, flagOut: Boolean;
begin
  if FNode.Text = '' then
    Exit;
  if (FNode = FTreeInNode) then
  begin
    {
       to get cursor to show up in Edit control is wierd,
       sending SETFOCUS seems to do the trick, KILLFOCUS prevents a return to
       the tree view and SetFocus doesn't show the cursor
       Also behaves differently depending on navigating in same edit or
       between edits
    }
    // bring child to front
    InWin.BringToFront;
    // focus & show cursor in child (SetFocus doesn't do it)
    SendMessage(InWin.Handle, WM_SETFOCUS, TreeView1.Handle, 0);
    Exit;
  end;
  if (FNode = FTreeOutNode) then
  begin
    OutWin.BringToFront;
    SendMessage(OutWin.Handle, WM_SETFOCUS, TreeView1.Handle, 0);
    Exit;
  end;
  flagIn := False;
  for i := Low(TInKeyTypes) to High(TInKeyTypes) do
  begin
    if (FTreeInNodes[i] = FNode) then
    begin
    	flagIn := True;
      break;
    end;
  end;
  if (flagIn) then
  begin
    with InWin, ChildEdit, KeyList do
    begin
      if (i = ptComment) then
        SelStart := 0
      else
        SelStart :=  // convert line to char position
 	        SendMessage(Handle, EM_LINEINDEX, InKeyList[i].StartLine +1, 0);
   	  SendMessage(Handle, EM_SCROLLCARET, 0, 0);  // scroll to location
    	InWin.BringToFront;
 	    SendMessage(InWin.Handle, WM_SETFOCUS, TreeView1.Handle, 0);
    end;
  end  // if not flagIn
  else
  begin
    flagOut := False;
    j := Low(TOutKeyTypes);
    for x := 0 to High(FTreeOutNodes) do
    begin
			for j := Low(TOutKeyTypes) to High(TOutKeyTypes) do
      begin
        if (FTreeOutNodes[x, j] = FNode) then
        begin
        	flagOut := True;
        	break;
        end;
      end;
      if (flagOut = True) then
      	break;
    end;
    if (flagOut) then
    begin
      with OutWin, ChildEdit, KeyList do
      begin
        SelStart :=  // convert line to char position
          SendMessage(Handle, EM_LINEINDEX, OutKeyList^[x, j].StartLine, 0);
        SendMessage(Handle, EM_SCROLLCARET, 0, 0);  // scroll to location
        OutWin.BringToFront;
        SendMessage(OutWin.Handle, WM_SETFOCUS, TreeView1.Handle, 0);
      end;
    end;
  end;
end;

procedure TMainForm.TreeViewUpdate(Win: TMDIChild);

  function AddInOrder(KeyType: TOutKeyTypes; x: Integer; Title: String): TTreeNode;
  begin
    with TreeView1.Items do
    begin
      if FTreeOutNodes[x, Low(TOutKeyTypes)].HasChildren and
         (KeyType <> Low(TOutKeyTypes)) and         // denotes no following node
         (FTreeOutNodes[x, KeyType] <> nil) then
        Result := Insert(FTreeOutNodes[x, KeyType], Title)
      else
      begin
        Result := AddChild(FTreeOutNodes[x, Low(TOutKeyTypes)], Title);
      end;
    end;
  end;

const
  lowKey: TOutKeyTypes = Low(TOutKeyTypes);
  highKey: TOutKeyTypes = High(TOutKeyTypes);
var
  i, j: TOutKeyTypes;
  x: Integer;
  FOldIndex: TPsyOutKeyList;
  { get internal compiler error if array from Succ(Low(..)) to Pred(High(..)) }
  nextNode: array of array[Low(TOutKeyTypes)..High(TOutKeyTypes)] of TOutKeyTypes;
begin
  with Win, KeyList do
  begin
    FOldIndex := OutKeyList^;
    // exit if no change
    if not PsyCheck.UpdateKeys(Win) then
      Exit;
    // determine node that follows given node
    SetLength(nextNode, Length(OutKeyList^));
    if (Length(OutKeyList^) > Length(FTreeOutNodes)) then
      SetLength(FTreeOutNodes, Length(OutKeyList^))
	  else if (Length(OutKeyList^) < Length(FTreeOutNodes)) then
    begin
      for x:= Length(OutKeyList^) to High(FTreeOutNodes) do
        for i := lowKey to highKey do
          if (FTreeOutNodes[x, i] <> nil) then
            TreeView1.Items.Delete(FTreeOutNodes[x, i]);
  	  SetLength(FTreeOutNodes, Length(OutKeyList^));  // resize
    end;
    for x := 0 to High(OutKeyList^) do
    begin
      i := Pred(highKey);
      j := lowKey;  // denotes no following nodes
      if (OutKeyList^[x, High(TOutKeyTypes)].StartLine >= 0) then
        j := High(TOutKeyTypes);
      while (i > Low(TOutKeyTypes)) do
      begin
        nextNode[x, i] := j;
        if (OutKeyList^[x, i].StartLine >= 0) then
          j := i;  // update node that follows
        Dec(i);
      end;
    end;  // for x
    // add/insert nodes
    with TreeView1.Items do
    begin
      for x := 0 to High(OutKeyList^) do
      begin
        for i := lowKey to highKey do  // build tree in order of TParseType entries
        begin;
          if (OutKeyList^[x, i].StartLine > -1) and
             (FOldIndex[x, i].StartLine < 0) or
             (x > High(FOldIndex)) then
          begin
              case i of
                ptTop: begin;
                  FTreeOutNodes[x, i] :=
                    AddChild(FTreeOutNode, 'Analysis ' +IntToStr(x +1));
                end;
                ptSummary: begin;
                  FTreeOutNodes[x, i] := AddInOrder(nextNode[x, i], x, 'Design');
                end;
                ptMeanSD: begin;
                  FTreeOutNodes[x, i] := AddInOrder(nextNode[x, i], x, 'Means & SDs');
                end;
                ptANOVA: begin;
                  FTreeOutNodes[x, i] := AddInOrder(nextNode[x, i], x, 'ANOVA');
                end;
                ptContCs: begin;
                  FTreeOutNodes[x, i] := AddInOrder(nextNode[x, i], x, 'Contrasts');
                end;
                ptRawCIs: begin;
                  FTreeOutNodes[x, i] := AddInOrder(nextNode[x, i], x, 'Raw CIs');
                end;
                ptzCIs: begin;
                  FTreeOutNodes[x, i] :=
                    AddChild(FTreeOutNodes[x, Low(TOutKeyTypes)], 'Standardized CIs');
                end;
              end;
    //          FTreeRoot.Expand(False);  // expand when adding
          end;
// *** check delete works properly, and free up FTreeOutNodes
          if (FOldIndex[x, i].StartLine > -1) and (OutKeyList^[x, i].StartLine < 0) then
          begin
            Delete(FTreeOutNodes[x, i]);
            FTreeOutNodes[x, i] := nil;
          end;
        end;  // for i
      end;  // for x
    end;  // with TreeView1
  end;  // with Win, KeyList
end;  // TreeViewUpdate(Win: TMDIChild)

procedure TMainForm.TreeViewUpdate(Win: TMDIInChild);

  function AddInOrder(KeyType: TInKeyTypes; Title: String): TTreeNode;
  begin
    with TreeView1.Items do
    begin
      if FTreeInNode.HasChildren and (KeyType <> Low(TInKeyTypes)) and
         (FTreeInNodes[KeyType] <> nil) then
        Result := Insert(FTreeInNodes[KeyType], Title)
      else
        Result := AddChild(FTreeInNode, Title);
    end;
  end;

const
  lowKey: TInKeyTypes = Low(TInKeyTypes);
  highKey: TInKeyTypes = High(TInKeyTypes);
var
  i, j: TInKeyTypes;
  FOldIndex: TPsyInKeyList;
  { get internal compiler error if array from Succ(Low(..)) to Pred(High(..)) }
  nextNode: array[Low(TInKeyTypes)..High(TInKeyTypes)] of TInKeyTypes;
begin
  with Win, KeyList do
  begin
    FOldIndex := InKeyList;
    // exit if no change
    if not PsyCheck.UpdateKeys(Win) then
      Exit;
    // determine node that follows given node
    i := Pred(highKey);
    j := lowKey;  // denotes no following nodes
    if (InKeyList[High(TInKeyTypes)].StartLine >= 0) then
      j := High(TInKeyTypes);
    while (i > Low(TInKeyTypes)) do
    begin
      nextNode[i] := j;
      if (InKeyList[i].StartLine >= 0) then
        j := i;  // update node that follows
      Dec(i);
    end;
    // add/insert nodes
    with TreeView1.Items do
    begin
      for i := lowKey to highKey do  // build tree in order of TParseType entries
      begin;
        if (InKeyList[i].StartLine > -1) and (FOldIndex[i].StartLine < 0) then
        begin
            case i of
              ptComment: begin;
                FTreeInNodes[i] := AddChildFirst(FTreeInNode,'Comments');
//                FTreeInNodes[i].ImageIndex := 2;
//                FTreeInNodes[i].SelectedIndex := 2;
              end;
              ptHeader: begin;
                FTreeInNodes[i] := AddInOrder(nextNode[i], 'Header');
              end;
              ptData: begin;
                FTreeInNodes[i] := AddInOrder(nextNode[i], 'Data');
              end;
              ptBetween: begin;
                FTreeInNodes[i] := AddInOrder(nextNode[i], 'Between Contrasts');
              end;
              ptWithin: begin;
                FTreeInNodes[i] := AddChild(FTreeInNode,'Within Contrasts');
              end;
            end;
  //          FTreeRoot.Expand(False);  // expand when adding
        end;
        if (FOldIndex[i].StartLine > -1) and (InKeyList[i].StartLine < 0) then
        begin
          Delete(FTreeInNodes[i]);
          FTreeInNodes[i] := nil;
        end;
      end;
    end;
  end;  // with Win, KeyList
end;  // TreeViewUpdate(Win: TMDIInChild)

procedure TMainForm.RemoveInTreeNodes;
begin
  TreeView1.Items.Delete(FTreeInNode);
  FTreeInNode := nil;
  ClearInTreeNodes;
  if (InWin <> nil) then
    InWin.Touched := False;
end;

procedure TMainForm.RemoveOutTreeNodes;
begin
  TreeView1.Items.Delete(FTreeOutNode);
  FTreeOutNode := nil;
  ClearOutTreeNodes;
  if (OutWin <> nil) then
    OutWin.Touched := False;
end;

procedure TMainForm.ClearInTreeNodes;
const
  lowKey: TInKeyTypes = Low(TInKeyTypes);
  highKey: TInKeyTypes = High(TInKeyTypes);
var
  i: TInKeyTypes;
begin
	for i := lowkey to highkey do
  	FTreeInNodes[i] := nil;
end;

procedure TMainForm.ClearOutTreeNodes;
const
  lowKey: TOutKeyTypes = Low(TOutKeyTypes);
  highKey: TOutKeyTypes = High(TOutKeyTypes);
var
  i: TOutKeyTypes;
begin
	SetLength(FTreeOutNodes, 1);
	for i := lowkey to highkey do
  	FTreeOutNodes[0,i] := nil;
end;

end.

