-- Create By Hujingjiang -- 

local prePath = "image/ui/CopyProgressUI/"
local effPath = "image/armature/scene/copy/"

CopyProgressUI = class("CopyProgressUI", function()
	return Node:create()
end)
-- 获取chunk中到最后一个战斗chunk的长度，不计最后一个战斗后的其他事件chunk
local function getChunkLen()
	local u_copy = CopyData.user.copy
    local chunks = u_copy.chunk
    for i = #chunks, 1, -1 do
    	local chunk = chunks[i]
    	if chunk.cate == const.kCopyEventTypeFightMeet then
    		return i - 1
    	end
    end
    return 1
end

function CopyProgressUI:ctor()
    self.curr = 0
	self.parent = nil
	self.off_x, self.off_y = 8, 8
	self.width = 417
	self:setContentSize(cc.size(433, 33))

	self.length = getChunkLen()
	-- 加载进度背景
	local bg = Sprite:create(prePath .. "cpu_bg.png")
	self:addChild(bg)
	self.progress = UIFactory.getLeftProgressBarWith(prePath .. "cpu_progress.png", self, self.off_x / 2 - 5, self.off_y / 2 - 3)
	-- 加载跑动的小人
	local roleName = "YS11xierwanasi-fb"
	self.role = Node:create()
	self.role:setCascadeOpacityEnabled(true)
	self.role:setPosition(-433 / 2, -self.off_y)
	self:addChild(self.role, 10)
	ArmatureSprite:addArmatureTo(self.role, effPath .. roleName .. "/" .. roleName .. ".ExportJson", roleName, -78, 100)
end
-- 创建怪物头像，如果type为2时加载boss头像
local function createMonsterIcon(monster)
	local icon = nil
	if monster.type == 1 then 	-- 普通怪物
		icon = Sprite:create(prePath .. "cpu_icon_monster.png")
	else 						-- boss
		icon = Sprite:create(prePath .. "cpu_icon_boss.png")
		local url = MonsterData.getAvatarUrl(monster)
		local img = Sprite:create(url)
		img:setScale(0.7)
		img:setPosition(icon:getContentSize().width / 2, 50)
		icon:addChild(img)
	end
	icon:setCascadeOpacityEnabled(true)
	icon:setAnchorPoint(0.5, 0)
	return icon
end
-- 初始化进度条
function CopyProgressUI:onShow()
	local u_copy = CopyData.user.copy
    local chunks = u_copy.chunk
    local len = self.length -- #chunks -- 
    for i = 1, len + 1 do
        local chunk = chunks[i]
        if chunk.cate == const.kCopyEventTypeFightMeet then
            local px = self.off_x + self.width * (i - 1) / len - 433 / 2
            local py = self.off_y
            local monster = findMonster(chunk.objid)
            local icon = createMonsterIcon(monster)
            icon:setPosition(px, py)
            self:addChild(icon)
        end
	end
	local posi = CopyData.user.copy.posi
	local percent = 100 * posi / len
	self.curr = percent -- 30 -- 
	self.progress:setPercentage(percent)

	local dx = self.off_x + self.width * posi / len - 433 / 2
	self.role:setPositionX(dx)
end

-- 设置进度，delay为时间间隔，num 为 0 ~ 100 的数
function CopyProgressUI:setProgress(delay, num)
    local progress = cc.ProgressFromTo:create(delay, self.curr, num) 
    self.progress:runAction(progress)
    self.curr = num

    local u_copy = CopyData.user.copy
    -- local dx = self.off_x + self.width * u_copy.posi / #u_copy.chunk - 433 / 2
    local dx = self.off_x + self.width * u_copy.posi / self.length - 433 / 2
    a_move(self.role, 0, delay - 0.2, cc.p(dx, self.role:getPositionY()))
end
-- 显示当前进度动画
function CopyProgressUI:showProgress()
	local u_copy = CopyData.user.copy
    local chunks = u_copy.chunk
	local num = 100 * u_copy.posi / self.length
		if u_copy.posi <= self.length then
		-- num = 80
		if num == self.curr then return end
		self.parent:addChild(self, 10)
		local d_t = 0.8
		self:setOpacity(0)
		self:setCascadeOpacityEnabled(true)
		self.progress:setOpacity(0)
		-- self.progress:setCascadeOpacityEnabled(true)
		local fadein = cc.FadeIn:create(0.5)
		local delayin = cc.DelayTime:create(0.1)
		local callfunc = cc.CallFunc:create(function() self:setProgress(d_t, num) end)
		local delayout = cc.DelayTime:create(d_t + 0.1)
		local fadeout = cc.FadeOut:create(0.5)
		local remove = cc.CallFunc:create(function() self:removeFromParent() end)
		
	    self.progress:runAction(cc.Sequence:create(fadein:clone(), cc.DelayTime:create(1), fadeout:clone()))
		self:runAction(cc.Sequence:create(fadein, delayin, callfunc, delayout, fadeout, remove))
	end
end

function CopyProgressUI:create(parent)
	local ui = CopyProgressUI:new()
	ui.parent = parent
	-- ui:setData(data)
	return ui
end