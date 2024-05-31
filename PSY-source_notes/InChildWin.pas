unit InChildWin;

interface

uses
  Windows, ComCtrls, Classes, Controls, ExtCtrls, Graphics, Forms,
  SysUtils, StdCtrls, Dialogs, {PsyGrid,} ChildWin, Grids;

type
  TMDIInChild = class(TMDIChild)
    Panel1: TPanel;
    TabControl1: TTabControl;
    NotesMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabControl1Change(Sender: TObject);
    procedure TabControl1Changing(Sender: TObject;
      var AllowChange: Boolean);
  private
    { Private declarations }
{    FTouched: Boolean;
    function GetTouched: Boolean;
    procedure SetTouched(Value: Boolean);
}    function GetModified: Boolean;
    procedure SetModified(Value: Boolean);
  protected
    procedure ShowTabsOnKeyPress(Sender: TObject; var Key: Char);
  public
    { Public declarations }
{    DataGrid: TDataGrid;
    BContGrid: TBContGrid;
    WContGrid: TWContGrid; }
//    property Touched: Boolean read GetTouched write SetTouched;
    property Modified: Boolean read GetModified write SetModified;
  end;

implementation

{$R *.DFM}

uses
  Main, Defines, {Arrays} ArraysClass, DataCheck;

procedure TMDIInChild.FormCreate(Sender: TObject);
begin
  IsRunnable := False;
  CloseCheck := True;
  FileName := '';
  IsInWin := True;
  // set tab to data tab
  TabControl1.TabIndex := 0;

{  //Create Grids
  BContGrid := TBContGrid.Create((Sender as TComponent));
  BContGrid.Parent := TabControl1;
  WContGrid := TWContGrid.Create((Sender as TComponent));
  WContGrid.Parent := TabControl1;
  // Create last so on top
  DataGrid := TDataGrid.Create((Sender as TComponent));
  DataGrid.Parent := TabControl1;
  ActiveControl := DataGrid;

  // initialise look of grids
  DataGrid.GridReset;
  BContGrid.GridReset;
  WContGrid.GridReset;
  NotesMemo.Lines.Clear;
}
  ChildEdit.Visible := True{MainForm.OptsCode1.Checked};
  Panel1.Visible := False{not MainForm.OptsCode1.Checked};
  PsyCheck.InitKeyList(Self);

  ChildEdit.OnKeyPress := ShowTabsOnKeyPress;
end;

procedure TMDIInChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // check if vars have been created before freeing
  with Arrays do
  begin
  if Assigned(DataMatrix) then
    Finalize(DataMatrix);
  if Assigned(SubjectArray) then
    Finalize(SubjectArray);
  if Assigned(SubjectIndexArray) then
    Finalize(SubjectIndexArray);
  if Assigned(BContrastArray) then
    Finalize(BContrastArray);
  if Assigned(WContrastArray) then
    Finalize(WContrastArray);
  end;
{  DataGrid.Free;
  WContGrid.Free;
  BContGrid.Free;
}
  MainForm.RemoveInTreeNodes;
//  Touched := True;  // force tree view update
  Action := caFree;
end;

procedure TMDIInChild.TabControl1Change(Sender: TObject);
begin
{  with TabControl1 do
  begin
    case TabIndex of
    1:  BContGrid.SizeToData;
    2:  WContGrid.SizeToData;
    end;
    DataGrid.Visible := (TabIndex = 0);  // Data tab
    BContGrid.Visible := (TabIndex = 1);  // Between Contrasts
    WContGrid.Visible := (TabIndex = 2);  // Within Contrasts
    NotesMemo.Visible := (TabIndex = 3);  // Notes tab
    case TabIndex of
    0:  DataGrid.SetFocus;
    1:  BContGrid.SetFocus;
    2:  WContGrid.SetFocus;
    3:  NotesMemo.SetFocus;
    end;
  end;
}end;

procedure TMDIInChild.TabControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
{if ActiveControl is TObject then;
  with TabControl1 do
  begin
    case TabIndex of
    0:  DataGrid.CountData;
    1:  BContGrid.CountContrasts;
    2:  WContGrid.CountContrasts;
    end;
  end;
}end;

(*function TMDIInChild.GetTouched: Boolean;
begin
{  Result := DataGrid.Touched or BContGrid.Touched or WContGrid.Touched;
}
  Result := FTouched;
end;

procedure TMDIInChild.SetTouched(Value: Boolean);
begin
{  DataGrid.Touched:= Value;
  BContGrid.Touched := Value;
  WContGrid.Touched := Value;
}  FTouched := Value;
end;
*)
function TMDIInChild.GetModified: Boolean;
begin
  Result := ChildEdit.Modified {or DataGrid.Modified
            or BContGrid.Modified or WContGrid.Modified};
  inherited Modified := Result;
end;

procedure TMDIInChild.SetModified(Value: Boolean);
begin
  ChildEdit.Modified := Value;
{  DataGrid.Modified := Value;
  BContGrid.Modified := Value;
  WContGrid.Modified := Value;
}  inherited Modified := Value;
end;

procedure TMDIInChild.ShowTabsOnKeyPress(Sender: TObject; var Key: Char);
begin
	// prevent tabs and use '»' insted
	if (Key = #9) then
  	Key := '»';
end;

end.
