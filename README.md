# Delphi Multithreading Example

Este projeto é um exemplo de como implementar o uso de multithreading em Delphi 10.2. Ele demonstra a criação e gerenciamento de um pool de threads, incluindo a fila de tarefas e o tratamento de exceções.

## Funcionalidades

- Criação de um pool de threads com um número máximo de threads configurável.
- Fila de tarefas para execução assíncrona.
- Tratamento de exceções em threads.
- Registro de logs em formato JSON com diferentes níveis de severidade (Information, Debug, Warn, Error).
- Logs condicionais baseados na variável de ambiente `DEBUG`.

## Estrutura do Projeto

- `ThreadPoolManager.pas`: Implementa a classe `TThreadPoolManager` que gerencia o pool de threads e a fila de tarefas.
- `HandlerException.pas`: Implementa a classe `THandlerException` para tratamento de exceções.
- `Logger.pas`: Implementa a classe `TLogger` para registro de logs em formato JSON.

## Como Usar

1. Clone o repositório.
2. Abra o projeto no Delphi 10.2.
3. Compile e execute o projeto.

## Exemplo de Uso

```delphi
var
  ThreadPool: TThreadPoolManager;
begin
  ThreadPool := TThreadPoolManager.Create(5); // Cria um pool com 5 threads
  try
    ThreadPool.QueueTask(
      procedure
      begin
        // Código da tarefa a ser executada
      end,
      'Task1'
    );
    ThreadPool.WaitForAll; // Aguarda todas as tarefas serem concluídas
  finally
    ThreadPool.Free;
  end;
end;
```


## Contato
- Nome: João Roberto
- Email: joaorobertof@gmail.com

Sinta-se à vontade para entrar em contato se tiver alguma dúvida ou sugestão.

Este projeto é apenas um exemplo educacional e pode ser adaptado conforme necessário para atender às suas necessidades específicas.

