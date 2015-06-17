--声明类
local prePath = "image/ui/PaperSkillUI/"
local url = prePath .. "StarTipsUI.ExportJson"
StarTipsUI = createUIClass("StarTipsUI", url, PopWayMgr.SMALLTOBIG)

--构造函数
function StarTipsUI:ctor()
end

--onShow处理方法
--处理添加事件侦听
function StarTipsUI:onShow()
	self:updateData() --调用窗口更新
end

--onClose处理方法
--移除事件侦听
function StarTipsUI:onClose()
end

function StarTipsUI:dispose()
end

--窗口更新方法
function StarTipsUI:updateData()
	local copy = gameData.user.star.copy
	local sum_history = copy
	local sum_cur = CoinData.getCoinByCate(const.kCoinStar)
	self.text_bg.sum_text:setString(string.format("%d/%d", sum_cur, sum_history))
	self.text_bg.left_star:setString(sum_cur)
	self.text_bg.copy_star:setString(copy)
end
