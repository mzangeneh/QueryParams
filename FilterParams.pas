unit FilterParams;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls,
  SolarCalendarPackage;

type

  TLikeType = (ltContain, LtBegin, LtEnd, LtEqual);
  TDateType = (dtEqual, dtFrom, dtTo);

  TBaseFilterParam = class(TWinControl)
  private
    FField: string;
    FOnChange: TNotifyEvent;
  public
    procedure reset; virtual; abstract;
    function getQuery: String; virtual; abstract;
  protected
    property Query: String read getQuery;
    property Field: string read FField write FField;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TCustomLikeParam = class(TBaseFilterParam)
  private
    FLikeType: TLikeType;
    FEdit: TEdit;
    procedure SetLikeType(const Value: TLikeType);
    procedure OnEditChange(sender: TObject);
  Protected
    property Edit: TEdit read FEdit write FEdit;
    property LikeType: TLikeType read FLikeType write SetLikeType
      default ltContain;
  public
    function getQuery: string; override;
    procedure reset; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TCustomDateParam = class(TBaseFilterParam)
  private
    FDateType: TDateType;
    FDate: TSolarDatePicker;
    procedure SetDateType(const Value: TDateType);
    procedure OnEditChange(sender: TObject);
  Protected
    property DatePicker: TSolarDatePicker read FDate write FDate;
    property DateType: TDateType read FDateType write SetDateType
      default dtEqual;
  public
    function getQuery: string; override;
    procedure reset; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TCustomStringListParam = class(TBaseFilterParam)
    private
    FCombo: TComboBox;
    FItems: TStrings;
    procedure OnEditChange(sender: TObject);
    procedure SetItems(const Value: TStrings);
    function GetItems: TStrings;
    Protected
    property Combo: TComboBox read FCombo write FCombo;
    property Items: TStrings read GetItems write SetItems;
    public
    function getQuery: string; override;
    procedure reset; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    end; }

  TLikeParam = class(TCustomLikeParam)
  public
  published
    property Field;
    property LikeType;
    property Query;
    property OnChange;
    property Align;
  end;

  TDateParam = class(TCustomDateParam)
  public
  published
    property Field;
    property DateType;
    property Query;
    property OnChange;
    property Align;
  end;

  { TStringListParam = class(TCustomStringListParam)
    public
    published
    property Items;
    property Field;
    property Query;
    property OnChange;
    property Align;
    end; }

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Filter params', [TLikeParam, TDateParam]);
end;

{ TBaseFilterParam }

{ TCustomLikeParam }

constructor TCustomLikeParam.Create(AOwner: TComponent);
begin
  inherited;
  AutoSize := True;
  Edit := TEdit.Create(Self);
  Edit.Text := '';
  Edit.OnChange := OnEditChange;
  Edit.Parent := Self;
  Edit.Align := alClient;
  AutoSize := False;
end;

destructor TCustomLikeParam.Destroy;
begin
  Edit.Free;
  inherited;
end;

function TCustomLikeParam.getQuery: string;
begin
  if Trim(Edit.Text) <> '' then
  begin
    case LikeType of
      ltContain:
        Result := ' ' + Field + ' LIKE ' +
          QuotedStr('%' + Trim(Edit.Text) + '%') + ' ';
      LtBegin:
        Result := ' ' + Field + ' LIKE ' +
          QuotedStr(Trim(Edit.Text) + '%') + ' ';
      LtEnd:
        Result := ' ' + Field + ' LIKE ' +
          QuotedStr('%' + Trim(Edit.Text)) + ' ';
      LtEqual:
        Result := ' ' + Field + ' = ' + QuotedStr(Trim(Edit.Text));
    end;
  end
  else
  begin
    Result := ' 1 = 1 ';
  end;
end;

procedure TCustomLikeParam.OnEditChange(sender: TObject);
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TCustomLikeParam.reset;
begin
  Edit.Text := '';
end;

procedure TCustomLikeParam.SetLikeType(const Value: TLikeType);
begin
  FLikeType := Value;
  if Assigned(OnChange) then
    OnChange(Self);
end;

{ TCustomStringListParam }

{ constructor TCustomStringListParam.Create(AOwner: TComponent);
  begin
  inherited;
  AutoSize := True;
  Combo := TComboBox.Create(Self);
  Combo.Text := '';
  Combo.OnChange := OnEditChange;
  Combo.Parent := Self;
  Combo.Align := alClient;
  AutoSize := False;
  end;

  destructor TCustomStringListParam.Destroy;
  begin
  Combo.Free;
  inherited;
  end;

  function TCustomStringListParam.GetItems: TStrings;
  begin
  if Assigned(FItems) then
  Result := FItems
  else
  Result := TStrings.Create;
  end;

  function TCustomStringListParam.getQuery: string;
  begin
  if Trim(Combo.Text) <> '' then
  begin
  Result := ' ' + Field + ' = ' + QuotedStr(Trim(Combo.Text)) + ' ';
  end
  else
  begin
  Result := ' 1 = 1 ';
  end;
  end;

  procedure TCustomStringListParam.OnEditChange(sender: TObject);
  begin
  if Assigned(OnChange) then
  OnChange(Self);
  end;

  procedure TCustomStringListParam.reset;
  begin
  Combo.Text := '';
  end;

  procedure TCustomStringListParam.SetItems(const Value: TStrings);
  begin
  if Assigned(FItems) then
  FItems.Assign(Value)
  else
  FItems := Value;
  end; }

{ TCustomDateParam }

constructor TCustomDateParam.Create(AOwner: TComponent);
begin
  inherited;
  inherited;
  AutoSize := True;
  DatePicker := TSolarDatePicker.Create(Self);
  DatePicker.Text := '';
  DatePicker.OnChange := OnEditChange;
  DatePicker.MonthObject := moComboBox;
  DatePicker.Parent := Self;
  DatePicker.Align := alClient;
  AutoSize := False;
end;

destructor TCustomDateParam.Destroy;
begin
  DatePicker.Free;
  inherited;
end;

function TCustomDateParam.getQuery: string;
begin
  if Trim(DatePicker.Text) <> '' then
  begin
    case DateType of
      dtEqual:
        Result := ' ' + Field + ' = ' +
          QuotedStr(Trim(DatePicker.Text)) + ' ';
      dtFrom:
        Result := ' ' + Field + ' >= ' +
          QuotedStr(Trim(DatePicker.Text)) + ' ';
      dtTo:
        Result := ' ' + Field + ' <= ' +
          QuotedStr(Trim(DatePicker.Text)) + ' ';
    end;
  end
  else
  begin
    Result := ' 1 = 1 ';
  end;
end;

procedure TCustomDateParam.OnEditChange(sender: TObject);
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TCustomDateParam.reset;
begin
  DatePicker.Text := '';
end;

procedure TCustomDateParam.SetDateType(const Value: TDateType);
begin
  FDateType := Value;
  if Assigned(OnChange) then
    OnChange(Self);
end;

end.
