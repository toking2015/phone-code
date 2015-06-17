g_platform_server = true

if nil == LogMgr then
    LogMgr = {}
end

LogMgr.log = function( mod, str )
    System.CPrint( str )
end

if trans == nil then
    trans = {}
end

if trans.const == nil then
    trans.const = {}
end

if trans.err == nil then
    trans.err = {}
end

if trans.base == nil then
    trans.base = {}
end

if trans.base.reg == nil then
    trans.base.reg = {}
end

trans.base.reg = System.CReg
trans.base.rand = System.CRand

--全局JSON
Json = require("cjson")
