--UIFightRole显示对象池管理

local __this = 
{
	styleList = {},
	urlList = {},

	--功能测试专用索引
	test_index = 0,
	--功能测试专用对象引用
	test_view = nil,
}

-- local function getUrl(attr, style, name, type)
--     return "image/armature/fight/" .. attr .. "/" .. style .. '/' .. name .. '.' .. type
-- end
local function getUrl(attr, style)
    if attr and const.kAttrTotem == attr then
        local url = "image/armature/fight/totem/" .. style .. '/' .. style .. '.ExportJson'
        return url
    end
    
    return "image/armature/fight/model/" .. style .. '/' .. style .. '.ExportJson'
end

function __this:getStyleList(style)
	self.styleList[style] = self.styleList[style] or {}
	return self.styleList[style]
end

function __this:getNoUseModel(body, style)
	local list = __this:getStyleList(style)
	for _, view in pairs(list) do
		if not view.use then
			view:init(body, false)
			view.use = true
			view:setPosition(0, 0)
			view:setOpacity(255)
			view.playerView:setScale(view.body.scale / 100)
			-- view.initTime = os.time()
			return list, view
		end
	end
	return list, nil
end

--使用模型对象	[非镜像]
function __this:useModel(style, attr, animation_name, level)
	local body = FightFileMgr:getBody(style)
	if not body then
		LogMgr.log("ModelMgr", "getModel not body style:" .. style)
		return nil
	end

	local list, view = __this:getNoUseModel(body, style)
	if view then
		return view
	end
	local url = getUrl(attr, style)
	self.urlList[style] = url
	view = UIRoleForFight.new()
	view:init(body, false, table.empty(list), attr, animation_name, level)
	view.use = true
	view:nameSwap(false)
	-- view.initTime = os.time()
	table.insert(list, view)
	return view
end

--回收模型对象	[需要自己清除外部引用]
--@param	view	模型对象
--@param	release 即时释放
function __this:recoverModel(view, release)
	if not view then
		return
	end

	view:removeFromParent()
	view:setPosition(0, 0)
	view:setOpacity(255)
	view.playerView:setScale(view.body.scale / 100)
	view:setGLProgramStateChildren("normal")
    self:formationRecoverModel(view, release)
    view.formationRecover = nil
end

--回收模型对象	[需要自己清除外部引用]【布阵系统专用】
--@param	view	模型对象
--@param	release 即时释放
function __this:formationRecoverModel(view, release)
	view.use = false
	view.jump_frame = 1
	view.formationRecover = true
	view.lastTime = 0
	view.playOneFlag = nil
	view.playerView:onPlayComplete(nil)
	view.playOneFlag = false
	view:stopStand()
	view:nameSwap(false)
	view:setTalk()
	view:setScale(1)
	view:releaseHp()
	view.lastPlayOneFlag = nil

	if not release then
		return
	end

	local style = view.body.style
	local list = self.styleList[style]
	for i, model in pairs(list) do
		if view == model then
			table.remove(list, i)
			view:releaseAll()
			break
		end
	end

	--释放资源
	if 0 == #list then
		-- LoadMgr.removeArmature(getUrl("model", style, style, "ExportJson"))
		LoadMgr.removeArmature(self.urlList[style])
	end
end

--第一场假战斗资源预加载专用接口>><<>><<>><<
function __this:loadFirstShowModel()
	local msg = FightDataMgr:createFirstShowData()
	if not msg then
		return
	end

	for __, user in pairs(msg.fight_info_list) do
		for __, soldier in pairs(user.soldier_list) do
			local bodyStyle = nil
			if trans.const.kAttrTotem == soldier.attr then
		        local totem = findTotem(soldier.soldier_id)
		        if totem then
		            bodyStyle = totem.animation_name
		        end
		    elseif trans.const.kAttrMonster == soldier.attr then
		        local monster = findMonster(soldier.soldier_id)
		        if monster then
		            bodyStyle = monster.animation_name
		        end
		    elseif trans.const.kAttrSoldier == soldier.attr then
		        local soldier = findSoldier(soldier.soldier_id)
		        if soldier then
		            bodyStyle = soldier.animation_name
		        end
		    end

		    if bodyStyle then
			    local view = self:useModel(bodyStyle)
				self:recoverModel(view)
			end
		end
	end
end

--预加载布阵资源
function __this:loadFormationModel(attr)
	if not attr then
		attr = const.kFormationTypeCommon
	end

	local list = FormationData.getTypeData(attr)
	for __, v in pairs(list) do
		local json = FormationData.getJsonByGuid(attr, v.guid, v.attr)
		if json and '' ~= json.animation_name then
			local view = nil
			if const.kAttrTotem == v.attr then
				view = self:useModel(json.animation_name .. '1', v.attr, json.animation_name, 1)
			else
				view = self:useModel(json.animation_name, v.attr)
			end
			if view then
				self:recoverModel(view)
			end
		end
	end
end

--释放非布阵角色叛逃
--@param	attr [布阵类型]
--@param	enforce	[强制释放标签]
function __this:releaseUnFormationModel(attr, enforce)
	if not attr then
		attr = const.kFormationTypeCommon
	end

	local dataList = FormationData.getTypeData(attr)
	if not dataList then
		return
	end
	local list = {}
	for __, v in pairs(dataList) do
		local json = FormationData.getJsonByGuid(attr, v.guid, v.attr)
		if json and '' ~= json.animation_name then
			list[json.animation_name] = 1
		end
	end

	for style, l in pairs(self.styleList) do
		if 1 ~= list[style] then
			self:releaseModel(style, l, enforce)
		end
	end
end

--释放某个模型的所有显示对象
function __this:releaseModel(style, list, enforce)
	if not list then
		list = self.styleList[style]
	end

	local del = {}
	for i, view in pairs(list) do
		if not view.use or enforce then
			table.insert(del, i)
		end
	end

	for i = #del, 1, -1 do
		local view = list[del[i]]
		table.remove(list, del[i])

		view:releaseAll()
	end

	--释放资源
	if 0 == #list then
		-- LoadMgr.removeArmature(getUrl("model", style, style, "ExportJson"))
		LoadMgr.removeArmature(self.urlList[style])
	end
end

--释放空闲模型对象
function __this:releaseIdleness()
	for style, list in pairs(self.styleList) do
		self:releaseModel(style, list)
	end
end


--音效预加载	[布阵专用]
function __this.loadSound()
	local resource = {}
	local map = FormationData.getCurrentList()
	for key, list in pairs(map) do
		if const.kAttrTotem ~= key then
			for __, json in pairs(list) do
				if '' ~= json.animation_name then
					local sound = FightFileMgr:getSound(json.animation_name)
					if sound then
						for __, es in pairs(sound.soundList) do
							if FightFileMgr.sound_enum.DEAD == es.attr then
								resource["sound/" .. es.sound .. ".mp3"] = 1
							end
						end

						local skill = findSkill(json.skills[1].first, json.skills[1].second)
						if skill then
							for __, ts in pairs(sound.dataList) do
								if skill.action_flag == ts.flag and skill.effect_index  == ts.effectIndex then
									for __, es in pairs(ts.list) do
										resource["sound/" .. es.sound .. ".mp3"] = 1
									end
								end
							end
						end
					end
				end
			end
		end
	end

	for key, v in pairs(resource) do
		SoundMgr.preloadEffect(key)
	end
end



--功能测试专用接口
function __this:nextModel()
	if self.test_index + 1 > #FightFileMgr.body.list then
		TipsMgr.showError("没有下一个形象")
		return
	end

	if self.test_view then
		self:recoverModel(self.test_view, true)
		self.test_view = nil
	end

	self.test_index = self.test_index + 1
	for i, body in pairs(FightFileMgr.body.list) do
		if i == self.test_index then
			self.test_view = self:useModel(body.style)
			SceneMgr.getCurrentScene():addChild(self.test_view)
			self.test_view:setPosition(visibleSize.width / 2, visibleSize.height / 3)
			self.test_view:playOne(false, "stand")
			break
		end
	end
end

function __this:beforeModel()
	if 0 == self.test_index - 1 then
		TipsMgr.showError("当前是第一个形象")
		return
	end

	if self.test_view then
		self:recoverModel(self.test_view, true)
		self.test_view = nil
	end

	self.test_index = self.test_index - 1
	for i, body in pairs(FightFileMgr.body.list) do
		if i == self.test_index then
			self.test_view = self:useModel(body.style)
			SceneMgr.getCurrentScene():addChild(self.test_view)
			self.test_view:setPosition(visibleSize.width / 2, visibleSize.height / 3)
			self.test_view:playOne(false, "stand")
			break
		end
	end
end

Command.bind("test model", function ( ... )
	local n = UIFactory.getButton("btn_1.png", SceneMgr.getCurrentScene(), 100, 100, 999999)
	local b = UIFactory.getButton("btn_2.png", SceneMgr.getCurrentScene(), 100, 200, 999999)
	ModelMgr:nextModel()

	UIMgr.addTouchEnded(n, function ()
		ModelMgr:nextModel()
	end)
	UIMgr.addTouchEnded(b, function ()
		ModelMgr:beforeModel()
	end)
end)

ModelMgr = __this