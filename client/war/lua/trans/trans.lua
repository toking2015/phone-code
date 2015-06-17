if trans == nil then
    trans = {}
end

if trans.const == nil then
    trans.const = {}
end

if trans.err == nil then
    trans.err = {}
end

if trans.call == nil then
    trans.call = {}
end

require "lua/trans/constant"
require "lua/trans/access"
require "lua/trans/activity"
require "lua/trans/altar"
require "lua/trans/auth"
require "lua/trans/back"
require "lua/trans/bias"
require "lua/trans/broadcast"
require "lua/trans/building"
require "lua/trans/chat"
require "lua/trans/client"
require "lua/trans/coin"
require "lua/trans/common"
require "lua/trans/copy"
require "lua/trans/equip"
require "lua/trans/fight"
require "lua/trans/fightextable"
require "lua/trans/formation"
require "lua/trans/friend"
require "lua/trans/guild"
require "lua/trans/gut"
require "lua/trans/item"
require "lua/trans/mail"
require "lua/trans/market"
require "lua/trans/notify"
require "lua/trans/opentarget"
require "lua/trans/paper"
require "lua/trans/pay"
require "lua/trans/platform"
require "lua/trans/present"
require "lua/trans/rank"
require "lua/trans/reportpost"
require "lua/trans/server"
require "lua/trans/shop"
require "lua/trans/sign"
require "lua/trans/singlearena"
require "lua/trans/social"
require "lua/trans/soldier"
require "lua/trans/star"
require "lua/trans/strength"
require "lua/trans/system"
require "lua/trans/task"
require "lua/trans/team"
require "lua/trans/temple"
require "lua/trans/timer"
require "lua/trans/tomb"
require "lua/trans/top"
require "lua/trans/totem"
require "lua/trans/trial"
require "lua/trans/user"
require "lua/trans/var"
require "lua/trans/vip"
require "lua/trans/viptimelimitshop"

const = trans.const
err = trans.err
