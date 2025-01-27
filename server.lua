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
