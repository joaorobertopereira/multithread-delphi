unit HandlerException;

interface

uses
  SysUtils, Classes, Windows, IOUtils;

type
  THandlerException = class
  private
    FLogFileName: string;
    procedure LogException(E: Exception; const MethodName, ThreadName: string);
    procedure EnsureLogDirectoryExists;
    function GetExceptionLocation: string;
  public
    constructor Create;
    procedure HandleException(E: Exception; const MethodName, ThreadName: string);
  end;

implementation

uses
  Rtti;

{ THandlerException }

constructor THandlerException.Create;
var
  LogDir: string;
begin
  LogDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Log';

  if not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);

  FLogFileName := LogDir + PathDelim + 'ServerExceptions_' + FormatDateTime('yyyymmdd', Now) + '.log';
end;

procedure THandlerException.EnsureLogDirectoryExists;
var
  LogDir: string;
begin
  LogDir := ExtractFilePath(FLogFileName);
  if not DirectoryExists(LogDir) then
    ForceDirectories(LogDir);
end;

function THandlerException.GetExceptionLocation: string;
var
  Addr: Pointer;
  ModuleName: array[0..MAX_PATH] of Char;
  LineNumber: Integer;
  DebugInfo: string;
begin
  Addr := ExceptAddr;

  // Obtém o nome do módulo onde a exceção ocorreu
  GetModuleFileName(HInstance, ModuleName, MAX_PATH);

  // Tentativa de obter a linha do código fonte (requer suporte de depuração ativo)
  if Addr <> nil then
    LineNumber := -1 // Aqui seria onde obteríamos o número da linha se usássemos JclDebug ou similar.
  else
    LineNumber := 0;

  DebugInfo := Format('Module: %s, Address: %p, Line: %d', [ExtractFileName(ModuleName), Addr, LineNumber]);

  Result := DebugInfo;
end;

procedure THandlerException.LogException(E: Exception; const MethodName, ThreadName: string);
var
  LogFile: TextFile;
  LogText: string;
begin
  EnsureLogDirectoryExists;

  AssignFile(LogFile, FLogFileName);
  if FileExists(FLogFileName) then
    Append(LogFile)
  else
    Rewrite(LogFile);

  LogText := Format('%s - Thread: %s - Exception in method [%s]: %s | Location: %s',
    [DateTimeToStr(Now), ThreadName, MethodName, E.ClassName + ': ' + E.Message, GetExceptionLocation]);

  WriteLn(LogFile, LogText);
  CloseFile(LogFile);
end;

procedure THandlerException.HandleException(E: Exception; const MethodName, ThreadName: string);
begin
  LogException(E, MethodName, ThreadName);
  raise E;
end;

end.
