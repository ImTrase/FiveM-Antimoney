cfg = {}

cfg.max = {
    ['bank'] = 5000000,
    ['money'] = 500000,
    ['black_money'] = 500000
}

cfg.esxResource = 'es_extended'   -- default ESX resource name
cfg.qbResource  = 'qb-core'       -- default QB-Core resource name

cfg.whitelisted_groups = { 'admin' } -- Whitelisted group(s)
cfg.flag = 'kick' -- kick, wipe, log (Kick = Kick & Wipes players money | Wipe = Only wipe players money | Log = Only log to discord [cfg.webhook must be filled out]) [Both Kick & Wipe log if you have it filled out below]

cfg.checkTime = 15

cfg.webhook = 'WEBHOOK_HERE'
