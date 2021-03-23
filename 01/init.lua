local yaml = require('yaml')
local fio = require('fio')

local function get_config(filename)
    local fh, err_msg = fio.open(filename, {'O_RDONLY'})
    if fh == nil then
        print("Error: couldn't open a file ", err_msg)
        return nil
    end
    local ok, config = pcall(yaml.decode, fh:read())
    fh:close()
    if ok ~= true then
        print("Error: couldn't decode config file ", config)
        return nil
    end
    return config
end

local config_filename = './config.yml'
local config = get_config(config_filename)
if config == nil then
    return
end

local function handler(req)
    local client = require('http.client').new()

    local url = config.proxy.bypass.host .. ':' .. config.proxy.bypass.port .. req:path() .. '?' .. req:query()

    return client:request(req:method(), url, req.body, {timeout = 10, req:headers()})
end

local server = require('http.server').new('localhost', config.proxy.port)


local router = require('http.router').new()
router:route({path = '/' }, handler)
router:route({path = '/.*'}, handler)

server:set_router(router)
server:start()
