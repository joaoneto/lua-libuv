#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <uv.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct
{
    uv_loop_t *loop;
    uv_tcp_t server;
} http_server_t;

static lua_State *luaCallbackState = NULL;
static int luaCallbackRef = LUA_NOREF;

static int log_level = 0; // 0: Erros, 1: Avisos, 2: Informações

#define LOG(level, fmt, ...)                                    \
    if (level <= log_level)                                     \
    {                                                           \
        const char *levels[] = {"ERRO", "AVISO", "INFO"};       \
        printf("[%s] " fmt "\n", levels[level], ##__VA_ARGS__); \
    }

static int set_callback(lua_State *L)
{
    if (lua_isfunction(L, 1))
    {
        luaCallbackState = L;
        luaL_unref(L, LUA_REGISTRYINDEX, luaCallbackRef);
        luaCallbackRef = luaL_ref(L, LUA_REGISTRYINDEX);
        LOG(2, "Callback Lua configurado com sucesso.");
    }
    return 0;
}

void alloc_buffer(uv_handle_t *handle, size_t suggested_size, uv_buf_t *buf)
{
    buf->base = (char *)malloc(suggested_size);
    buf->len = suggested_size;
}

static void on_write(uv_write_t *req, int status)
{
    if (status < 0)
    {
        if (status == UV_ECONNRESET)
        {
            LOG(0, "Conexão resetada pelo cliente.");
        }
        else
        {
            LOG(0, "Erro ao enviar dados: %s", uv_strerror(status));
        }

        uv_close((uv_handle_t *)req->handle, NULL);
    }
    else
    {
        LOG(2, "Resposta enviada ao cliente com sucesso.");
    }

    free(req);
}

void on_read(uv_stream_t *client, ssize_t nread, const uv_buf_t *buf)
{
    if (nread > 0)
    {
        LOG(2, "Recebido: %.*s", (int)nread, buf->base);

        if (luaCallbackRef != LUA_NOREF)
        {
            lua_rawgeti(luaCallbackState, LUA_REGISTRYINDEX, luaCallbackRef);
            lua_pushstring(luaCallbackState, buf->base);

            if (lua_pcall(luaCallbackState, 1, 1, 0) != LUA_OK)
            {
                LOG(0, "Erro no callback Lua: %s", lua_tostring(luaCallbackState, -1));
                lua_pop(luaCallbackState, 1);
            }
            else
            {
                if (lua_isstring(luaCallbackState, -1))
                {
                    const char *response = lua_tostring(luaCallbackState, -1);
                    uv_write_t *req = malloc(sizeof(uv_write_t));
                    uv_buf_t res_buf = uv_buf_init((char *)response, strlen(response));
                    uv_write(req, client, &res_buf, 1, on_write);
                }
                else
                {
                    LOG(0, "Erro na resposta do servidor");
                }
                lua_pop(luaCallbackState, 1);
            }
        }
    }
    else if (nread < 0)
    {
        if (nread == UV_EOF)
        {
            LOG(2, "Conexão fechada pelo cliente.");
        }
        else if (nread != UV_EOF)
        {
            LOG(0, "Erro na leitura: %s", uv_strerror(nread));
        }

    }

    uv_close((uv_handle_t *)client, NULL);
    free(buf->base);
}

static void on_new_connection(uv_stream_t *server, int status)
{
    LOG(2, "Nova conexão recebida!");

    if (status < 0)
    {
        LOG(0, "Erro na conexão: %s", uv_strerror(status));
        return;
    }

    uv_tcp_t *client = (uv_tcp_t *)malloc(sizeof(uv_tcp_t));
    uv_tcp_init(server->loop, client);

    if (uv_accept(server, (uv_stream_t *)client) == 0)
    {
        LOG(2, "Novo cliente conectado.");
        uv_read_start((uv_stream_t *)client, alloc_buffer, on_read);
    }
    else
    {
        LOG(0, "Falha ao aceitar a conexão.");
        uv_close((uv_handle_t *)client, NULL);
        free(client);
    }
}

static int create_server(lua_State *L)
{
    const char *host = luaL_checkstring(L, 1);
    int port = luaL_checkinteger(L, 2);

    http_server_t *server = (http_server_t *)malloc(sizeof(http_server_t));
    server->loop = uv_default_loop();

    uv_tcp_init(server->loop, &server->server);

    struct sockaddr_in addr;
    uv_ip4_addr(host, port, &addr);

    uv_tcp_bind(&server->server, (const struct sockaddr *)&addr, 0);

    int r = uv_listen((uv_stream_t *)&server->server, 128, on_new_connection);
    if (r)
    {
        luaL_error(L, "Erro ao iniciar servidor: %s", uv_strerror(r));
        return 0;
    }

    LOG(2, "Servidor HTTP escutando em %s:%d", host, port);

    uv_thread_t server_thread;
    uv_thread_create(&server_thread, (uv_thread_cb)uv_run, server->loop);

    lua_pushlightuserdata(L, server);
    return 1;
}

static int stop_server(lua_State *L)
{
    http_server_t *server = (http_server_t *)lua_touserdata(L, 1);
    if (server)
    {
        LOG(2, "Parando o servidor...");

        uv_stop(server->loop);
        uv_close((uv_handle_t *)&server->server, NULL);
        free(server);

        LOG(2, "Servidor parado.");
    }
    return 0;
}

static const struct luaL_Reg httpLib[] = {
    {"createServer", create_server},
    {"stopServer", stop_server},
    {"setCallback", set_callback},
    {NULL, NULL}
};

int luaopen_http(lua_State *L)
{
    luaL_newlib(L, httpLib);
    return 1;
}
