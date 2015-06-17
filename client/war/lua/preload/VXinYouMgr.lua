--新游数据收集接口
local __this = VXinYouMgr or {}
VXinYouMgr = __this
__this.GAME_ID = nil --"10007" --暂时屏蔽
__this.RETRY_TIMES = 1000000
__this.PRIVATE_KEY = "@@vxinyou.com.mobile@@" --需要新游提供
__this.API_URL = "http://gameapi.vxinyou.com/%s.php"
__this.AD_API = "https://adapi.vxinyou.com/game/index/index/"

__this.GROUP_MAP =
{
	["tribe-ios-apple"]=1,
	["tribe-android"]=2, 
	["tribe-ios-crack"]=4
}

function __this.onComplete(data)
	LogMgr.info(data)
end

function __this.setDefault(t)
	t.game_id = __this.GAME_ID
	t.group_id = __this.GROUP_MAP[Config.data.group]
	t.server_id = Config.login_data.sid
	t.channel_id = Config.platform.name
	t.user_id = Config.login_data.aid
	t.role_id = Config.login_data.rid or 0
end

function __this.doSendData(url, tb)
	if not tb.game_id then --如果没填game_id，不统计
		return
	end
	local t = __this.createData()
	for k,v in pairs(tb) do
		table.insert(t, string.format("%s=%s", k, string.urlencode(v)))
	end
	local data = crypto.base64Encode(table.concat(t, "&"))
	local sign = crypto.sha256Encode(data .. __this.PRIVATE_KEY)
	local content = string.urlencode(string.format("data=%s&sign=%s", data, sign))
	URLLoader.new(url, __this.onComplete, nil, nil, __this.RETRY_TIMES, nil, nil, seq.string_to_stream(content))
end

--提交运营数据
function __this.sendData(name, t)
	__this.setDefault(t)
	local url = string.format(__this.API_URL, name)
	__this.doSendData(url, t)
end

--提交广告数据
function __this.sendADData(name, t)
	t["do"] = name
	t.is_crack = __this.is_crack()
	t.gid = __this.GAME_ID
	local url = __this.AD_API
	__this.doSendData(url, t)
end

--获取设备信息，创建表
function __this.createData()
	__this.device_info = system.device_info()
	return {}
end

function __this.user_register()
	local t = __this.createData()
	t.create_time = DateTools.getTime()
	-- t.login_ip = system.getIP()
	t.reg_ip = ""
	t.device_is_crack = __this.is_crack()
	t.device_operators = __this.net_isp()
	t.device_os_ver = __this.os_ver()
	t.device_name = __this.machine_version()
	t.device_resolution = __this.device_resolution()
	t.device_mac = __this.mac()
	t.device_idfa = __this.idfa()
	t.device_idfv = __this.idfv()
	__this.sendData("user_register", t)
end

function __this.user_login()
	local t = __this.createData()
	t.login_time = DateTools.getTime()
	-- t.login_ip = system.getIP()
	t.login_ip = ""
	__this.sendData("user_login", t)
end

function __this.user_pay(uid, coin, name, level, startTime)
	local t = __this.createData()
	t.role_name = name
	t.role_level = level
	t.order_no = uid
	t.pay_money = coin
	t.pay_time = startTime
	t.arrive_time = DateTools.getTime()
	t.pay_ip = ""
	t.device_os_ver = __this.os_ver()
	t.device_name = __this.machine_version()
	t.device_resolution = __this.device_resolution()
	
	__this.sendData("user_pay", t)
end

function __this.role_create(role_name, role_job, create_time)
	local t = __this.createData()
	t.role_name = role_name
	t.role_job = role_job
	t.create_time = create_time
	__this.sendData("role_create", t)
end

function __this.role_login(level)
	local t = __this.createData()
	t.role_level = level
	t.login_time = DateTools.getTime()
	__this.sendData("role_login", t)
end

function __this.role_upgrade(level)
	local t = __this.createData()
	t.role_level = level
	t.upgrade_time = DateTools.getTime()
	__this.sendData("role_upgrade", t)
end

function __this.ad_active()
	local t = __this.createData()
	t.net_isp = __this.net_isp()
	t.os_ver = __this.os_ver()
	t.netconn_type = __this.netconn_type()
	t.machine_version = __this.machine_version()
	t.mac = __this.mac()
	t.idfa = __this.idfa()
	t.idfv = __this.idfv()
	t.os = __this.os()
	t.adid = __this.adid()
	__this.sendADData("active", t)
end

function __this.ad_reg()
	local t = __this.createData()
	t.server_id = Config.login_data.sid
	t.user_name = Config.login_data.aid
	t.platform = Config.platform.name
	t.net_isp = __this.net_isp()
	t.os_ver = __this.os_ver()
	t.netconn_type = __this.netconn_type()
	t.machine_version = __this.machine_version()
	t.mac = __this.mac()
	t.idfa = __this.idfa()
	t.idfv = __this.idfv()
	t.os = __this.os()
	t.adid = __this.adid()
	__this.sendADData("reg", t)
end

function __this.ad_login()
	local t = __this.createData()
	t.server_id = Config.login_data.sid
	t.user_name = Config.login_data.aid
	t.role_id = Config.login_data.rid
	t.platform = Config.platform.name
	t.net_isp = __this.net_isp()
	t.os_ver = __this.os_ver()
	t.netconn_type = __this.netconn_type()
	t.machine_version = __this.machine_version()
	t.mac = __this.mac()
	t.idfa = __this.idfa()
	t.idfv = __this.idfv()
	t.os = __this.os()
	t.adid = __this.adid()
	__this.sendADData("login", t)
end

function __this.ad_pay(order_id, amount, pay_platform)
	local t = __this.createData()
	t.platform = Config.platform.name
	t.server_id = Config.login_data.sid
	t.user_name = Config.login_data.aid
	t.role_id = Config.login_data.rid
	t.order_id = order_id
	t.amount = amount
	t.pay_platform = pay_platform
	t.net_isp = __this.net_isp()
	t.os_ver = __this.os_ver()
	t.netconn_type = __this.netconn_type()
	t.machine_version = __this.machine_version()
	t.mac = __this.mac()
	t.idfa = __this.idfa()
	t.idfv = __this.idfv()
	t.os = __this.os()
	t.adid = __this.adid()
	__this.sendADData("pay", t)
end

function __this.ad_update_level(level)
	local t = __this.createData()
	t.server_id = Config.login_data.sid
	t.user_name = Config.login_data.aid
	t.level = level
	t.os = __this.os()
	__this.sendADData("update_level", t)
end


-------通用数据获取--------
function __this.is_crack()
	return __this.GROUP_MAP[Config.data.group] == 4 and 1 or 0
end

function __this.net_isp()
	return __this.device_info.device_operators
end

function __this.os_ver()
	return __this.device_info.device_os_ver
end

function __this.netconn_type()
	return __this.device_info.device_net_info
end

function __this.machine_version()
	return __this.device_info.device_name
end

function __this.device_resolution()
	local glview = cc.Director:getInstance():getOpenGLView()
	local size = glview and glview:getFrameSize() or cc.size(0, 0)
	return string.format("%s*%s", size.width, size.height)
end

function __this.mac()
	return __this.device_info.device_mac
end

function __this.idfa()
	return __this.device_info.device_idfa
end

function __this.idfv()
	return __this.device_info.device_idfv
end

function __this.os()
	local group = __this.GROUP_MAP[Config.data.group]
	if group then
		return group == 2 and "android" or "ios"
	else
		return "windows"
	end
end

function __this.adid()
	return 0
end
