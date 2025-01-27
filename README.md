# Lua-libuv

Este é um projeto de laboratório desenvolvido para explorar a execução de scripts Lua com módulos compilados em C, com suporte à biblioteca `libuv` para operações assíncronas e gerenciamento de eventos. O projeto demonstra como integrar Lua com `libuv` e como compilar módulos Lua personalizados em C.

## Estrutura do Repositório

A estrutura do repositório é organizada da seguinte forma:

- **`external/libuv`**: Contém a biblioteca `libuv` como submódulo. A `libuv` é usada para fornecer suporte a operações assíncronas e de I/O de baixo nível.
- **`external/lua`**: Contém o interpretador Lua como submódulo. Este submódulo integra a versão 5.4.7 do Lua para execução dos scripts.
- **`src/`**: Contém os arquivos-fonte para os módulos customizados escritos em C, que serão compilados e carregados pelo Lua.
- **`modules/`**: Diretório onde os módulos compilados são armazenados. Aqui você encontrará as bibliotecas compartilhadas (.dll ou .so) para serem carregadas pelos scripts Lua.
- **`lua.bat`** e **`lua.sh`**: Scripts para executar arquivos Lua no Windows ou sistemas Unix-like, respectivamente.

## Pré-requisitos

Para configurar o ambiente, você precisará de algumas ferramentas de compilação e dependências específicas dependendo do seu sistema operacional.

### Windows
- **Visual Studio 2019** (com o Prompt de Desenvolvedor configurado para x64).

### Unix-like
- **GCC**: Compilador de C.
- **Make**: Utilitário para automação de compilação.
- **Autotools**: Ferramentas necessárias para configurar e compilar a `libuv`.

## Configuração Inicial

Siga os passos abaixo para configurar o projeto e compilar as dependências:

1. Clone o repositório:

```bash
git clone https://github.com/joaoneto/lua-libuv.git
cd lua-libuv
```

2. Inicialize os submódulos para obter as dependências externas:

```bash
git submodule update --init --recursive
```

3. Compile as dependências e módulos:

```bash
make
```

## Execução de Scripts Lua

Após a configuração, você pode executar scripts Lua com a infraestrutura montada. Utilize os scripts fornecidos para executar arquivos Lua no seu sistema operacional.

### Windows

```cmd
.\lua helloworld.lua
```

### Unix-like

```bash
./lua.sh helloworld.lua
```

Esses comandos irão executar o arquivo `helloworld.lua` utilizando o interpretador Lua configurado com os módulos compilados.

## Limpeza

Para limpar os arquivos gerados pela compilação, como os módulos compilados e arquivos temporários, execute o seguinte comando:

```bash
make clean
```

Isso irá remover a pasta `external` e todos os artefatos de build.

## Descrição dos Arquivos

### `Makefile`

O `Makefile` contém as regras para a construção do projeto. Ele define as dependências do projeto, como a `libuv` e a versão do Lua, além das instruções para compilar os módulos C. As principais seções são:

- **`externals`**: Garante que os submódulos sejam atualizados e que a versão correta da `libuv` e do Lua sejam baixadas.
- **`build_libuv`**: Constrói a biblioteca `libuv` a partir do código-fonte.
- **`build_lua`**: Constrói o interpretador Lua.
- **`build_modules`**: Compila os módulos em C encontrados na pasta `src` e os coloca na pasta `modules`.
- **`clean`**: Limpa os artefatos de compilação.

### `modules/init.lua`

Este arquivo configura o carregamento dos módulos Lua para incluir tanto scripts Lua quanto módulos compilados em C. Os módulos compilados ficam nesse diretório.


### `modules/async.lua`

Este módulo é um exemplo de módulo `.lua`, ele define funções para lidar com corrotinas e simular um comportamento assíncrono com o Lua. Ele implementa uma função `await` que suspende a execução da corrotina até que a promessa seja resolvida.

```lua
local async = {}

-- Função para simular 'await'
function async.await(promise)
    return coroutine.yield(promise)  -- Suspende a execução até que o promise seja resolvido
end

-- Função para rodar uma corrotina assíncrona
function async.run(func)
    local co = coroutine.create(func)
    local function resume(...)
        local status, result = coroutine.resume(co, ...)
        if not status then
            print("Erro na execução da corrotina:", result)
        end
    end
    resume()
end

return async
```

### `helloworld.lua`

Este arquivo Lua demonstra a utilização do módulo `my_mod`. Ele carrega o módulo e executa uma função `helloworld()` que provavelmente retorna uma mensagem.

```lua
local my_mod = require("modules").my_mod

print(my_mod.helloworld())
```

### `server.lua`

Este é um exemplo de servidor HTTP simples que utiliza o módulo `http` compilado em C. Ele define um callback para tratar requisições HTTP, lê um arquivo HTML e retorna seu conteúdo como resposta.

```lua
local http = require("modules").http

-- Define o callback
http.setCallback(function(req)
    print("[lua] Requisição recebida")

    -- Lê o conteúdo do arquivo HTML
    local file = io.open("index.html", "r")
    if not file then
        print("[lua] Erro ao abrir o arquivo HTML")
        return "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nArquivo não encontrado.\n"
    end

    local content = file:read("*all")
    file:close()

    -- Cabeçalhos da resposta
    local headers = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: " .. #content .. "\r\n\r\n"

    -- Retorna o cabeçalho seguido do conteúdo do arquivo HTML
    return headers .. content
end)

-- Inicia o servidor
local server = http.createServer("0.0.0.0", 8080)
print("Servidor rodando! Pressione Enter para parar.")
io.read()
http.stopServer(server)
print("Servidor parado.")
```

## Contribuições

Contribuições são bem-vindas! Se você encontrar um bug ou quiser melhorar o projeto, sinta-se à vontade para enviar um pull request. Ao contribuir, siga as convenções do código e garanta que o projeto continue bem organizado e fácil de usar.

