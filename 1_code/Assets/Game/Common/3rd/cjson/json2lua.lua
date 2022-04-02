-- #!/usr/bin/env lua

-- usage: json2lua.lua [json_file]
--
-- Eg:
-- echo '[ "testing" ]' | ./json2lua.lua
-- ./json2lua.lua test.json

local json = require "cjson.safe"
local util = require "cjson.util"

function json2lua(json_text)
    if json_text == nil then
        return json_text
    else
        local t = json.decode(json_text)
        -- print(util.serialise_value(t))
        return t
    end
end