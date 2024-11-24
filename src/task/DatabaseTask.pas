unit DatabaseTask;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.Stan.Pool, FireDAC.Stan.Option, ThreadPoolManager;

type
  TDatabaseTask = class(TThreadPoolManager)
  private
    FConnection: TFDConnection;
    procedure InitializeDatabase;
  public
    constructor Create(MaxThreads: Integer);
    destructor Destroy; override;
    procedure ExecuteQuery(const SQL: string);
    procedure ExecuteNonQuery(const SQL: string);
  end;

implementation

constructor TDatabaseTask.Create(MaxThreads: Integer);
begin
  inherited Create(MaxThreads);
  InitializeDatabase;
end;

destructor TDatabaseTask.Destroy;
begin
  FConnection.Free;
  inherited Destroy;
end;

procedure TDatabaseTask.InitializeDatabase;
var
  Server, Database, UserName, Password, Port: string;
begin
  Server := GetEnvironmentVariable('DB_SERVER');
  Database := GetEnvironmentVariable('DB_DATABASE');
  UserName := GetEnvironmentVariable('DB_USERNAME');
  Password := GetEnvironmentVariable('DB_PASSWORD');
  Port := GetEnvironmentVariable('DB_PORT');

  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'MySQL';
  FConnection.Params.Values['Server'] := Server;
  FConnection.Params.Values['Database'] := Database;
  FConnection.Params.Values['User_Name'] := UserName;
  FConnection.Params.Values['Password'] := Password;
  FConnection.Params.Values['Port'] := Port;
  FConnection.LoginPrompt := False;
  FConnection.Connected := True;
end;

procedure TDatabaseTask.ExecuteQuery(const SQL: string);
begin
  QueueTask(
    procedure
    var
      FDQuery: TFDQuery;
    begin
      FDQuery := TFDQuery.Create(nil);
      try
        try
          FDQuery.Connection := FConnection;
          FDQuery.SQL.Text := SQL;
          FDQuery.Open;

          while not FDQuery.Eof do
          begin
            // Process each row
            FDQuery.Next;
          end;

          TThread.Queue(nil,
            procedure
            begin
              // Update UI with query results
            end);
        except
          on E: Exception do
          begin
            TThread.Queue(nil,
              procedure
              begin
                // Update UI with the error message
              end);
            raise;
          end;
        end;
      finally
        FDQuery.Free;
      end;
    end,
    'DatabaseQueryTask'
  );
end;

procedure TDatabaseTask.ExecuteNonQuery(const SQL: string);
begin
  QueueTask(
    procedure
    var
      FDQuery: TFDQuery;
    begin
      FDQuery := TFDQuery.Create(nil);
      try
        try
          FDQuery.Connection := FConnection;
          FDQuery.SQL.Text := SQL;
          FDQuery.ExecSQL;

          TThread.Queue(nil,
            procedure
            begin
              // Update UI with non-query execution result
            end);
        except
          on E: Exception do
          begin
            TThread.Queue(nil,
              procedure
              begin
                // Update UI with the error message
              end);
            raise;
          end;
        end;
      finally
        FDQuery.Free;
      end;
    end,
    'DatabaseNonQueryTask'
  );
end;

end.
