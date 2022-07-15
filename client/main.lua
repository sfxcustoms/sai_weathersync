CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false
local Synced = true

RegisterNetEvent('sai_weathersync:ToggleWeatherSync')
AddEventHandler('sai_weathersync:ToggleWeatherSync', function(state)
    Synced = state
end)

RegisterNetEvent('sai_weathersync:updateWeather')
AddEventHandler('sai_weathersync:updateWeather', function(NewWeather, newblackout)
	if not Synced then
        return
    end

    CurrentWeather = NewWeather
    blackout = newblackout
end)

Citizen.CreateThread(function()
    while true do
        if Synced then
            if lastWeather ~= CurrentWeather then
                lastWeather = CurrentWeather
                SetWeatherTypeOverTime(CurrentWeather, 15.0)
                Citizen.Wait(15000)
            end
            Citizen.Wait(100) -- Wait 0 seconds to prevent crashing.
            SetBlackout(blackout)
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(lastWeather)
            SetWeatherTypeNow(lastWeather)
            SetWeatherTypeNowPersist(lastWeather)
            if lastWeather == 'XMAS' then
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
            else
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('sai_weathersync:updateTime')
AddEventHandler('sai_weathersync:updateTime', function(base, offset, freeze)
	if not Synced then
        return
    end

    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
        local sleep = 500

        if Synced then
            sleep = 100
            local newBaseTime = baseTime
            if GetGameTimer() - 500  > timer then
                newBaseTime = newBaseTime + 0.25
                timer = GetGameTimer()
            end
            if freezeTime then
                timeOffset = timeOffset + baseTime - newBaseTime			
            end
            baseTime = newBaseTime
            hour = math.floor(((baseTime+timeOffset)/60)%24)
            minute = math.floor((baseTime+timeOffset)%60)
            NetworkOverrideClockTime(hour, minute, 0)
        end

        Citizen.Wait(sleep)
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('sai_weathersync:requestSync')
end)

RegisterNetEvent('sai_weathersync:notify')
AddEventHandler('sai_weathersync:notify', function(type, message)
    ESX.ShowNotification(type, message)
end)
