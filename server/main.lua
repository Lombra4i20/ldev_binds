local resourceName = GetCurrentResourceName()
local fileName = "bindsalva.json"
local bindsSalvas = {}

local function debugPrint(msg)
    if Config.debugMode then
       print(msg)
    end
end

-- Carregar binds do arquivo JSON ao iniciar o resource
local function loadBinds()
    local content = LoadResourceFile(resourceName, fileName)
    if content and content ~= "" then
        local ok, data = pcall(json.decode, content)
        if ok and data then
            bindsSalvas = data
            debugPrint("[Binds] Binds carregados.")
        else
            debugPrint("[Binds] Falha ao decodificar JSON.")
        end
    else
        bindsSalvas = {}
        debugPrint("[Binds] Nenhum arquivo encontrado, iniciando vazio.")
    end
end

-- Salvar binds no arquivo JSON com formatação legível (quebras de linha e indentação)
local function saveBinds()
    -- Se sua json.encode não suporta indentação, substitua por outra função que suporte.
    local encoded = json.encode(bindsSalvas, { indent = true }) 
    local success = SaveResourceFile(resourceName, fileName, encoded, -1)
    if success then
        debugPrint("[Binds] Binds salvos com sucesso.")
    else
        debugPrint("[Binds] Falha ao salvar binds.")
    end
end

-- Registro do comando /bindar no servidor
RegisterCommand(Config.commandForBind, function(source, args, rawCommand)
    local src = source
    if #args < 2 then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Uso correto: /bindar <tecla> <comando>", "menu_textures", "cross", 4000, "COLOR_YELLOW")
        return
    end

    local key = args[1]:lower()
    local comando = table.concat(args, " ", 2)

    local steamID = nil
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            steamID = id
            break
        end
    end

    if not steamID then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Erro: SteamID não encontrada.", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if not bindsSalvas[steamID] then
        bindsSalvas[steamID] = {}
    end

    bindsSalvas[steamID][key] = { comando = comando }
    saveBinds()

    TriggerClientEvent("binds:loadBinds", src, bindsSalvas[steamID])

    TriggerClientEvent('vorp:NotifyLeft', src, "Binds", ("Tecla '%s' vinculada ao comando: %s"):format(key, comando), "generic_textures", "tick", 5000, "COLOR_GREEN")
end)

RegisterCommand(Config.commandForDeleteBind, function(source, args, rawCommand)
    local src = source
    if #args < 1 then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Uso correto: /unbindar <tecla>", "menu_textures", "cross", 4000, "COLOR_YELLOW")
        return
    end

    local key = args[1]:lower()

    local steamID = nil
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            steamID = id
            break
        end
    end

    if not steamID then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Erro: SteamID não encontrada.", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if bindsSalvas[steamID] and bindsSalvas[steamID][key] then
        bindsSalvas[steamID][key] = nil
        saveBinds()
        TriggerClientEvent("binds:loadBinds", src, bindsSalvas[steamID])
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", ("Bind da tecla '%s' removido com sucesso."):format(key), "generic_textures", "tick", 4000, "COLOR_GREEN")
    else
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", ("Nenhum bind encontrado para a tecla '%s'."):format(key), "menu_textures", "cross", 4000, "COLOR_YELLOW")
    end
end)

RegisterCommand(Config.commandForViewBinds, function(source, args, rawCommand)
    local src = source

    local steamID = nil
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            steamID = id
            break
        end
    end

    if not steamID then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Erro: SteamID não encontrada.", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local userBinds = bindsSalvas[steamID]

    if not userBinds or next(userBinds) == nil then
        TriggerClientEvent('vorp:NotifyLeft', src, "Binds", "Você não possui binds configurados.", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local bindsList = ""
    for key, bindData in pairs(userBinds) do
        local cmd = bindData.comando or "nil"
        local linha = string.format("%s: %s\n", key, cmd)

        if #bindsList + #linha > 300 then
            bindsList = bindsList .. "..."
            break
        else
            bindsList = bindsList .. linha
        end
    end

    TriggerClientEvent('vorp:NotifyLeft', src, "Binds", bindsList, "generic_textures", "tick", 8000, "COLOR_WHITE")
end)


-- Ao iniciar o resource, carregar binds
AddEventHandler('onResourceStart', function(resName)
    if resName == resourceName then
        loadBinds()
    end
end)

-- Evento para o client solicitar as binds ao entrar no servidor
RegisterNetEvent("binds:getBinds")
AddEventHandler("binds:getBinds", function()
    local src = source
    local steamID = nil
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then
            steamID = id
            break
        end
    end

    local userBinds = bindsSalvas[steamID] or {}
    TriggerClientEvent("binds:loadBinds", src, userBinds)
end)
