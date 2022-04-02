
local basefunc=require "Game.Common.basefunc"

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, description, nesting)
    if not AppDefine.IsDebug then
		return
	end

    if type(nesting) ~= "number" then nesting = 5 end

    local lookupTable = {}
    local result = {}

    local traceback = basefunc.string.split(debug.traceback("", 2), "\n")

	-- by lyx
	result[#result +1] = "dump from: " .. basefunc.string.trim(traceback[3])
    -- print("dump from: " .. basefunc.string.trim(traceback[3]))

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "- ", 1)

	-- by lyx
	print(table.concat(result,"\n"))
--    for i, line in ipairs(result) do
--        print(line)
--	end

end
--输出日志--
function log(str)
    Util.Log(str)
end

--错误日志--
function logError(str) 
    Util.LogError(str)
end

--警告日志--
function logWarn(str) 
    Util.LogWarning(str)
end

--[[
table_message 表的描述信息，也可以是自定义信息，用于确认打印出来的table是自己输出的
t table表
]]
function print_r ( table_message, t )  
    local temp = {}
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            table.insert(temp, indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        table.insert(temp, indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        table.insert(temp, indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        table.insert(temp, indent.."["..pos..'] => "'..val..'"')
                    else
                        table.insert(temp, indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                table.insert(temp, indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        table.insert(temp, tostring(t).." {")
        sub_print_r(t,"  ")
        table.insert(temp, "}")
    else
        sub_print_r(t,"  ")
    end
    local str = table_message.."\n"..table.concat(temp,"\n")
    str = debug.traceback(tostring(str), 3)
    log(str)
end

-- userdata
function IsEquals(obj)
    if obj then
        if type(obj) == "userdata" then
            if obj and not obj:Equals(nil) then
                return true
            end
        else
            return true
        end
    end
    return false
end

table.print = print_r



