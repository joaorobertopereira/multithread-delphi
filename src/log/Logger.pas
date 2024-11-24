unit Logger;

interface

uses
  SysUtils, Classes, Windows, IOUtils, System.JSON;

type
  TLogSeverity = (Information, Debug, Warn, Error);

  TLogger = class
  private
    FLogFileName: string;
    FDebug: Boolean;
    procedure EnsureLogDirectoryExists;
    function SeverityToString(Severity: TLogSeverity): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(const Msg: string; Severity: TLogSeverity);
  end;

implementation

{ TLogger }

constructor TLogger.Create;
var
  LogDir, AppName: string;
begin
  FDebug := GetEnvironmentVariable('DEBUG') = 'true';
  LogDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Log';

  if not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);

  AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  FLogFileName := LogDir + PathDelim + AppName + '_' +
    FormatDateTime('yyyymmdd', Now) + '.log';
end;

destructor TLogger.Destroy;
begin
  // Adicione qualquer código de limpeza necessário aqui
  inherited Destroy;
end;

procedure TLogger.EnsureLogDirectoryExists;
var
  LogDir: string;
begin
  LogDir := ExtractFilePath(FLogFileName);
  if not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);
end;

function TLogger.SeverityToString(Severity: TLogSeverity): string;
begin
  case Severity of
    Information: Result := 'INFO';
    Debug: Result := 'DEBUG';
    Warn: Result := 'WARN';
    Error: Result := 'ERROR';
  else
    Result := 'UNKNOWN';
  end;
end;

procedure TLogger.Log(const Msg: string; Severity: TLogSeverity);
var
  LogFile: TextFile;
  LogText: string;
  LogJSON: TJSONObject;
begin
  if not FDebug and (Severity = Debug) then
    Exit;

  EnsureLogDirectoryExists;

  LogJSON := TJSONObject.Create;
  try
    LogJSON.AddPair('timestamp', FormatDateTime('dd-MM-yyyy hh:mm:ss', Now));
    LogJSON.AddPair('severity', SeverityToString(Severity));
    LogJSON.AddPair('message', Msg);

    LogText := LogJSON.ToString;
  finally
    LogJSON.Free;
  end;

  AssignFile(LogFile, FLogFileName);
  if FileExists(FLogFileName) then
    Append(LogFile)
  else
    Rewrite(LogFile);

  WriteLn(LogFile, LogText);
  CloseFile(LogFile);
end;

end.
