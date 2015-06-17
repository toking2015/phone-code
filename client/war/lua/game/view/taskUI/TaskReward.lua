-- create by Live --
--任务奖励格子

local prePath = "image/ui/TaskUI/"
TaskRewardItem = class(
	"RewardItem", 
	function()
		return getLayout(prePath .. "RewardItem.ExportJson")
	end
)

function TaskRewardItem:ctor()
	self:setTouchEnabled(true)
	local function touchBeginHandler(target)
		if self.data then
			local postion = self:getParent():convertToWorldSpace( cc.p(self:getPositionX(), self:getPositionY() - 100) )
			if self.data.cate == const.kCoinItem then
				local item = findItem( self.data.objid )
				TipsMgr.showTips(postion, TipsMgr.TYPE_ITEM, item )
			else
				local info = CoinData.getCoinName( self.data.cate, self.data.objid )
				TipsMgr.showTips(postion, TipsMgr.TYPE_STRING, info .. '*' ..self.data.val )
			end
		end
		ActionMgr.save( 'UI', '[TaskUI] click [ TaskRewardItem ]' )
	end
	UIMgr.addTouchBegin(self, touchBeginHandler)
end

function TaskRewardItem:updateData( value )
	if self.data ~= value then
		self.data = value
		self.icon:loadTexture( TaskData.taskRewardIcon( value ), ccui.TextureResType.localType )
		self.text_num:setString( value.val )
	end
end
