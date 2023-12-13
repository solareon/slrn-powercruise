local config = require 'config.shared'

lib.addCommand(config.autopilotCommand, { help = 'Turn on autopilot'}, function(source)
    TriggerClientEvent('slrn-powercruise:client:startAutopilot', source)
end)
lib.addCommand(config.autopilotStopCommand, { help = 'Turn off autopilot'}, function(source)
    TriggerClientEvent('slrn-powercruise:client:stopAutopilot', source)
end)