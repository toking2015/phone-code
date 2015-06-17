local __this = SoldierLevelUpEffect or {}
SoldierLevelUpEffect = __this
__this.effect = false
__this.timeCount = 0 
local data = SoldierData.effLvData
function __this:isData( )
    return not table.empty(data)
end
--启动升级接口 
function __this:playEffect( )
    if not self:isData() then
        return
    end

	self.effect = true

    --钱减少
    local top = MainUIMgr.getRoleTop()
    top:reduceValue("con_solution",data.warterNeedOld)

	data.changeWater = SoldierData:getArrChange(data.warterNeedNew,data.warterNeedOld) 
    data.changeArr={}
    data.oldArrAdd = {}
    for k,v in pairs(data.newArr) do
        local changeInfo =SoldierData:getArrChange(data.newArr[k],data.oldArr[k]) 
        table.insert( data.changeArr ,changeInfo )
        table.insert(data.oldArrAdd,data.oldArr[k])
    end
    self:effectBig()
    self:effectLight()
end

--计时器
function __this:loop( gcount,time )
    if not self:isData() then
        return
    end
	if not self.effect then
		return
	end

	self.timeCount = self.timeCount + 1
	__this:effectWaterJump( time )
	__this:effectArrJump( time )
end

function __this:removeAllEffect( )
    if not self:isData() then
        return
    end
    self.effect = false
    self.timeCount = 0 
    __this:removeLightEffect()
    __this:removeEffectBig()
    
end

function __this:removeEffectBig()
    if not self:isData() then
        return
    end

    local arrLay = data.arrLay
    if arrLay == nil then
        return
    end
    
    self:removeBig(arrLay.warterIcon)
    self:removeBig(arrLay.levelValue)
    for i=1,14 do
        local changTxt = arrLay["arrValue_" .. ( i - 1 )]
        changTxt:setScale(1)
    end
end

function __this:removeBig( obj )
    if obj then
        obj:stopAllActions()
        obj:setScale(1)
        obj:setOpacity(255)
    end
end

--放大效果
function __this:effectBig( )
    if not self:isData() then
        return
    end

    local arrLay = data.arrLay
    arrLay.warterIcon:setOpacity(0)
	a_scale_fadein_bs(arrLay.warterIcon, 0.3, {x = 5, y = 5},{x = 1, y = 1})
    arrLay.needNum:setOpacity(0)
    a_scale_fadein_bs(arrLay.needNum, 0.2, {x = 3, y = 3},{x = 1, y = 1})

    arrLay.levelValue:setString(data.levelValue_Value .. "/" .. data.levelValue_max)
    arrLay.levelValue:setOpacity(0)
    a_scale_fadein_bs(arrLay.levelValue, 0.2, {x = 3, y = 3},{x = 1, y = 1})
end


function __this:effectWaterJump( )
    if not self:isData() then
        return
    end
    if self.timeCount % 2 ~= 0 then
        return
    end
    local list1 = data.changeWater.numi
    local list2 = data.changeWater.numf 
    local allComp = true
    if  list1 and #list1 > 0 then
        allComp = false
        data.warterNeedOld = data.warterNeedOld + list1[1]
        table.remove(list1,1)
    elseif  list2 and #list2 > 0 then
        allComp = false
        data.warterNeedOld = data.warterNeedOld + list2[1]
        table.remove(list2,1)
    end

    local value = data.warterNeedOld
    if allComp then
    	value = data.warterNeedNew
    	self.timeCount = 0
    end

    data.arrLay.needNum:setString(data.warterNeedNew)
end

function __this:removeLightEffect( )
    if self.levelEfect1 then
        self.levelEfect1:removeNextFrame()
        self.levelEfect1 = nil
    end
end

--英雄形象上的光
function __this:effectLight( )
    if not self:isData() then
        return
    end
    local arrLay = data.arrLay
    local norStyle = data.norStyle
    self:removeLightEffect()
    local function onComplete( )
        self.timeCount = 0
        self.levelEfect1:stop()
        self:removeLightEffect()
    end
    local path1 = 'image/armature/ui/SoldierUI/sj-tx-01/sj-tx-01.ExportJson'
    self.levelEfect1 = ArmatureSprite:addArmature(path1, 'sj-tx-01', "SoldierUI", norStyle, 115, 145,onComplete,100)
    self.levelEfect1:setScale(2)
end

--属性跳动
function __this:effectArrJump( time )
    if not self:isData() then
        return
    end
    if self.timeCount % 2 ~= 0 then
        return
    end

    local len = table.getn(data.changeArr)
    if len <= 0 then
        return
    end
    local allComp = true
    for i=1,len do
        local changTxt = data.arrLay["arrValue_" .. ( i - 1 )]
        local list1 = data.changeArr[i].numi
        local list2 = data.changeArr[i].numf 
        if  list1 and #list1 > 0 then
            allComp = false
            data.oldArrAdd[i] = data.oldArrAdd[i] + list1[1]
            if list1[1] > 0 then
                a_scale_fadein_bs(changTxt, 0.1, {x = 3, y = 3},{x = 1, y = 1})
            end
            table.remove(list1,1)
        elseif  list2 and #list2 > 0 then
            allComp = false
            data.oldArrAdd[i] = data.oldArrAdd[i] + list2[1]
            if list2[1] > 0 then
                a_scale_fadein_bs(changTxt, 0.1, {x = 3, y = 3},{x = 1, y = 1})
            end
            table.remove(list2,1)
        end
    end

    local list3 = data.oldArrAdd
    if allComp then
        list3 = data.newArr
        self.timeCount = 0
        self.type = 0
        self.effect = false
        --动画完成
    end
    
    if not self:isData() then
        return
    end

    for k,v in pairs( list3 ) do
        local arrValueTxt = data.arrLay["arrValue_" .. ( k - 1 )]
        arrValueTxt:setString(tostring(v))
    end
end

