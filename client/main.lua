local userBinds = {}

-- Ao iniciar o resource, pede os binds salvos no servidor
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent("binds:getBinds")
    end
end)

RegisterNetEvent("binds:loadBinds")
AddEventHandler("binds:loadBinds", function(binds)
    userBinds = binds
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10) -- evita uso excessivo de CPU

        for keyName, bindData in pairs(userBinds) do
            local keyCode = Keys[keyName:lower()]
            if keyCode then
                if IsRawKeyPressed(keyCode) then
                    local argumento = bindData.argumento or ""
					local cmd = bindData.comando .. (argumento ~= "" and (" " .. argumento) or "")
                    ExecuteCommand(cmd)
                    Citizen.Wait(300) -- evita execução múltipla muito rápida
                end
            end
        end
    end
end)