local config = require 'config.shared'

local autopilot, slowingDown = nil, nil
local MenuItemId1 = nil
local MenuItemId2 = nil
local waypointBlip

local function autoPilotThread()
	CreateThread(function()
		while autopilot do
			SetDriverAbility(cache.ped, 1)
			SetDriverAggressiveness(cache.ped, 0.5)
			local loc2 = #(GetEntityCoords(cache.ped) - GetBlipInfoIdCoord(waypointBlip))
			local turningOrBraking = IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64)
			print(loc2)			
			if loc2 < 250.0 and not slowingDown then
				slowingDown = true
				ClearPedTasks(cache.ped)
				ClearVehicleTasks(cache.vehicle)
				exports.qbx_core:Notify('Nearing destination reducing speed.')
				local coord = GetBlipInfoIdCoord(waypointBlip)
				TaskVehicleDriveToCoord(cache.ped, cache.vehicle, coord.x, coord.y, coord.z - 1, 30.0, 0, GetEntityModel(cache.vehicle), 319, 1.0, 1)
			end
			if loc2 < 5.0 or not DoesBlipExist(waypointBlip) or turningOrBraking then
				slowingDown = nil
				autopilot = nil
				ClearPedTasks(cache.ped)
				ClearVehicleTasks(cache.vehicle)
				local message = turningOrBraking and 'Autopilot disengaged' or 'Destination reached!'
				exports.qbx_core:Notify(message, 'success')
				BringVehicleToHalt(cache.vehicle, 3.0, 1.0)
				Wait(1500)
				StopBringVehicleToHalt(cache.vehicle)
			end
			Wait(10)
		end
    end)
end

local function autoPilot()
	if exports.ox_inventory:Search('count', 'autopilot') == 0 then
		exports.qbx_core:Notify('Who do you think is going to drive?', 'error')
		return
	end
	if autopilot then
		exports.qbx_core:Notify('Already In Autopilot mode', 'error')
		return
	end
	if cache.seat ~= -1 then
		exports.qbx_core:Notify('Only the driver can do that', 'error')
		return
	end
	autopilot = true
	waypointBlip = GetFirstBlipInfoId(8)
	if not DoesBlipExist(waypointBlip) then
		exports.qbx_core:Notify('Set a waypoint idiot.', 'error')
		return
	end
	exports.qbx_core:Notify('Autopilot engaged', 'success')
	Wait(1250)
	local coord = GetBlipInfoIdCoord(waypointBlip)
	SetVehicleHandlingHashForAi(cache.vehicle, `SPORTS_CAR`)
	TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, coord.x, coord.y, coord.z - 1, 50.0, 525119, 20.0)
	autoPilotThread()
end

local function stopAutoPilot()
	exports.qbx_core:Notify('Autopilot disengaged', 'success')
	autopilot = nil
	if cache.vehicle and cache.seat == -1 then
		ClearPedTasks(cache.ped)
		ClearVehicleTasks(cache.vehicle)
	end
end

RegisterNetEvent('slrn-powercruise:client:startAutopilot', function()
	if autopilot then
		exports.qbx_core:Notify('Already in Autopilot mode', 'error')
	else
		autoPilot()
	end
end)

RegisterNetEvent('slrn-powercruise:client:stopAutopilot', function()
	stopAutoPilot()
end)

local function addStartRadialOption()
	if not MenuItemId1 then
		MenuItemId1 = exports['qb-radialmenu']:AddOption({
			id = 'start_autopilot',
			title = 'AutoPilot',
			icon = 'square-parking',
			type = 'command',
			event = config.autopilotCommand,
			shouldClose = true
		}, MenuItemId1)
	end
	if not MenuItemId2 then
		MenuItemId2 = exports['qb-radialmenu']:AddOption({
			id = 'stop_autopilot',
			title = 'AP Stop',
			icon = 'square-parking',
			type = 'command',
			event = config.autopilotStopCommand,
			shouldClose = true
		}, MenuItemId2)
	end
end

local function removeRadialOptions()
    if MenuItemId1 then
        exports['qb-radialmenu']:RemoveOption(MenuItemId1)
        MenuItemId1 = nil
    end
    if MenuItemId2 then
        exports['qb-radialmenu']:RemoveOption(MenuItemId2)
        MenuItemId2 = nil
    end
end

lib.onCache('seat', function(value)
	if exports.ox_inventory:Search('count', 'autopilot') > 0 and value == -1 then
		addStartRadialOption()
	elseif not autopilot then
		removeRadialOptions()
	end
end)
