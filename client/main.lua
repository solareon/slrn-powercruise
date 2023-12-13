local config = require 'config.shared'

local autopilot = nil
local MenuItemId1 = nil
local MenuItemId2 = nil

local function autoPilot()
	if autopilot then
		exports.qbx_core:Notify('Already In Autopilot mode', 'error')
		return
	end
	if cache.seat ~= -1 then
		exports.qbx_core:Notify('Only the driver can do that', 'error')
		return
	end
	autopilot = true
	if not GetFirstBlipInfoId(8) ~= 0 then
		exports.qbx_core:Notify('Set a Waypoint idiot.', 'error')
		return
	end
	Wait(2000)
	local waypointBlip = GetFirstBlipInfoId(8)
	local coord = GetBlipInfoIdCoord(waypointBlip)
	TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, coord.x, coord.y, coord.z - 1, 100.0, 447, 20.0)
	local loc2 = #(GetEntityCoords(cache.ped) - coord)
	print(loc2)
	if loc2 < 5.0 then
		autopilot = nil
		ClearPedTasks(cache.ped)
		ClearVehicleTasks(cache.vehicle)
	end
end

local function stopAutoPilot()
	autopilot = nil
	if cache.vehicle and cache.seat ~= -1 then
		ClearPedTasks(cache.ped)
		ClearVehicleTasks(cache.vehicle)
	end
end

RegisterNetEvent('slrn-powercruise:client:startAutopilot', function()
	if autopilot then
		exports.qbx_core:Notify('Already In Autopilot mode', 'error')
	elseif exports.ox_inventory:Search('count', config.autopilotItem) then
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
			title = 'Start Autopilot',
			icon = 'square-parking',
			type = 'command',
			event = config.autopilotCommand,
			shouldClose = true
		}, MenuItemId1)
	end
	if not MenuItemId2 then
		MenuItemId2 = exports['qb-radialmenu']:AddOption({
			id = 'stop_autopilot',
			title = 'Stop Autopilot',
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
	if exports.ox_inventory:Search('count', 'autopilot') and value == -1 then
		addStartRadialOption()
	else
		removeRadialOptions()
	end
end)
