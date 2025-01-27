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
