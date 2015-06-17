--定时执行
function f_delay_do(obj,fn,arg,delay)--对象,方法，参数，延时(秒)
    if not obj then
        return
    end
    local function fn_cb()
		if fn then
			return fn(arg)
		end
    end
    local t_delay = 0
    if delay then 
        t_delay = tonumber(delay)
    end
    local action = cc.Sequence:create(
    cc.DelayTime:create(t_delay),
    cc.CallFunc:create(fn_cb))
    obj:runAction(action)
end	

---------------------------------------------------------------------------------------------
--淡入 动作
function a_fadein(obj,t_fadein,delay,cb)--对象，延时，时效，回调函数,是否复原
    assert(obj)
    local array = {}
	local idx = 1
	if delay then
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
    local action = cc.FadeIn:create(t_fadein)
	array[idx] = action
	idx = idx + 1	
	if cb then
	    array[idx] = cc.CallFunc:create(cb)		
	end
	obj:runAction(cc.Sequence:create(array))
end

--淡出 动作
function a_fadeout(obj,delay,t_fadeout,fn,arg)--对象，延时，时效，回调函数,是否复原
    --obj:runAction( cc.FadeIn:create(t_fadeout))
    local function fn_cb()
        if fn then
            return fn(arg)
        end
    end
    local array = {}
	local idx = 1
    if delay then
        array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
    end
	array[idx] = cc.FadeOut:create(t_fadeout)
	idx = idx + 1
	array[idx] = cc.CallFunc:create(fn_cb)	
	obj:runAction(cc.Sequence:create(array))
end

--谈出并移动
function a_fadeout_move(obj,t_fadeout,t_move,ptTo,delay,fn,arg)
    local function fn_cb()
        if fn then
            return fn(arg)
        end
    end
    local array = {}
	local idx = 1
    if delay then
        array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
    end
    --array:addObject(cc.FadeOut:create(t_fadeout))
	array[idx] = cc.Spawn:create(cc.FadeOut:create(t_fadeout),CCMoveBy:create(t_move,ptTo))
	idx = idx + 1
	array[idx] = cc.CallFunc:create(fn_cb)	
	obj:runAction(cc.Sequence:create(array))
end


--淡入&移动-停留-淡出 动作
function a_fadein_move_fadeout(obj,t_fadein,t_move,ptTo,t_stay,t_fadeout,delay,fn,arg) -- ptTo need cc.p(x,y)
    local function fn_cb()
        return fn(arg)
    end
    local array = {}
	local idx = 1
    local m_fi = cc.Spawn:create(cc.FadeIn:create(t_fadein),cc.MoveTo:create(t_move,ptTo))
    if delay then
        array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
    end
	array[idx] = m_fi
	idx = idx + 1
	array[idx] = cc.DelayTime:create(t_stay)
	idx = idx + 1
	array[idx] = cc.FadeOut:create(t_fadeout)
	idx = idx + 1
	if fn then
		array[idx] = cc.CallFunc:create(fn_cb)
	end
	obj:runAction(cc.Sequence:create(array))
end

--移动 动作
function a_move(obj,delay,t_move,ptTo,fn,arg) -- ptTo need cc.p(x,y)
	local move = cc.MoveTo:create(t_move,ptTo)
    local function fn_cb()
		if fn then	
			return fn(arg)
		end
    end
	local function fn_move()
		obj:stopAllActions()
		obj:runAction(cc.Sequence:create(move,cc.CallFunc:create(fn_cb)))
	end				
	if delay and tonumber(delay) > 0 then
		obj:runAction(cc.Sequence:create(cc.DelayTime:create(delay),
		                                 cc.CallFunc:create(fn_move)))
	else
		fn_move()
	end
end

--加速度移动&淡入 动作
function a_emove_fadeIn(obj,t_move,ptTo,delay,fn,arg)
    local function fn_cb()
		if fn then
			return fn(arg)
		end
    end
	local function fn_hide()
		obj:setVisible(false)
	end
    local a_move = cc.MoveTo:create(t_move, cc.p(ptTo.x,ptTo.y))
    local a_ease = cc.EaseExponentialIn:create(a_move)
    local m_fo = cc.Spawn:create(cc.FadeIn:create(t_move),a_ease)
    local array = {}
	local idx = 1
	if delay then
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
    array[idx] = m_fo
	idx = idx + 1
	array[idx] = cc.CallFunc:create(fn_hide)
	idx = idx + 1
    array[idx] = cc.CallFunc:create(fn_cb)
    obj:runAction(cc.Sequence:create(array))
end

--摇动
function a_shake(obj,t_shake,count,angle,delay,fn,arg)--t_shake摇动一次时长,摇动次数,角度
	assert(obj)
    local function fn_cb()
		if fn then
			return fn(arg)
		end
    end		
	local array = {}
	local idx = 1
    local a = cc.RotateTo:create(t_shake,angle)
	local b = cc.RotateTo:create(t_shake,-angle)
	local c = cc.RotateTo:create(t_shake/2,0)	
	for i = 1,count do
		array[idx] = a
		idx = idx + 1		
		array[idx] = b
		idx = idx + 1
	end
	array[idx] = c
	idx = idx + 1	
	array[idx] = cc.CallFunc:create(fn_cb)		
    obj:runAction(cc.Sequence:create(array))
end

--转动
function a_rotate(obj,t_shake,angle,delay,fn,arg)--a_rotate转动一次时长,摇动次数,角度
	assert(obj)
    local function fn_cb()
		if fn then
			return fn(arg)
		end
    end	
	local a = cc.RotateTo:create(t_shake,angle)	
	local b = cc.RotateTo:create(t_shake,-angle)		
	local s = cc.Sequence:create(a,b)
	local r = cc.RepeatForever:create(s)
    obj:runAction(r)
end

--循环动作
function a_play(obj,config,bLoop,begin_sec,delay,fn,arg)
	local function fn_cb()
		if fn then
			fn(arg)
		end
	end
    local file = getResFilename( config.res )	
    local frame_time = config.time
    local frame_width = config.width
    local frame_height = config.height
	local frame_across = config.across
	local frame_row = config.row
	--local frame_sx = config.sx
	--local frame_sy = config.sy
	local frame_count = frame_across * frame_row	
    --local texture = cc.TextureCache:sharedTextureCache():addImage(file)
	local texture = cc.Director:getInstance():getTextureCache():addImage(file)	
    local frame_index = 0	
	if begin_sec then
		assert(begin_sec <= frame_time)
		frame_index = math.floor(frame_count / frame_time )*frame_width
	end
    --local animFrames = CCArray:create()
	local animFrames = {}
	local idx = 1
     --local sprite = nil
    for i = 0,frame_across - 1 do
		for j = 0,frame_row - 1 do
			if frame_index <= i*j then
				local rect = cc.rect(j*frame_width,frame_height*i,frame_width,frame_height)
				local frame = cc.SpriteFrame:createWithTexture(texture, rect)
				--[[if frame_sx and frame_sy then
					frame:setContentSize(cc.size(math.abs(frame_sx), math.abs(frame_sy)) )
				end	--]]			
				--animFrames:addObject(frame)
				animFrames[idx] = frame
				idx = idx + 1
			end
		end
    end		
	local animation = nil
	local animation = cc.Animation:createWithSpriteFrames(animFrames, frame_time)
    local animate = cc.Animate:create(animation)
    local repeatloop = cc.RepeatForever:create(animate)
    --local array = CCArray:create()
	local array = {}
    if bLoop then
        --array:addObject(repeatloop)
		obj:runAction(repeatloop)
		return
    else
        local function destory()
            obj:removeFromParent(true)
        end
        array[1] = animate
        array[2] = cc.CallFunc:create(destory)
    end
	array[3] = cc.CallFunc:create(fn_cb)
    local sequence = cc.Sequence:create(array)
    obj:runAction(sequence)
end

--倒计时动作
function a_countdown(obj,delay,scale,fn,arg)
    local function fn_show()
        obj:setVisible(true)
    end
	local function fn_cb()
		if fn then
			fn(arg)
		end
	end
	local fScale = 1
	if scale then
	    fScale = tonumber(scale)
	end
	local aScale =  cc.ScaleTo:create(0.5*fScale, 1.5*fScale)
	local aFaceOut = cc.FadeOut:create(0.5)
	local bScale =  cc.ScaleTo:create(0.5*fScale, 1*fScale)
	local array = {}
	local idx = 1
	array[idx] = cc.DelayTime:create(delay)
	idx = idx + 1
	array[idx] = cc.CallFunc:create(fn_show)
	idx = idx + 1
	array[idx] = aScale
	idx = idx + 1
	array[idx] = cc.Spawn:create(bScale,aFaceOut)
	idx = idx + 1
	if fn then
	    array[idx] = cc.CallFunc:create(fn_cb)		
	end
	local as = cc.Sequence:create(array)
	obj:runAction(as)	 
end
function play_countdown(parent,config,begin_sec,delay,fn)
	local file_path = getResFilename( config.path )
	local frame_count = config.count
	local frame_x = config.x
	local frame_y = config.y
	local frame_scale = config.scale
	--local animFrames = CCArray:create()
	local function fn_cb(arg)
	    if fn and tonumber(arg) >= frame_count then
	        return fn()
	    end
    end 
	if begin_sec > 1 and begin_sec <= frame_count then
		local t_delay = 0
		if delay then
		    t_delay = t_delay + delay
		end
		for i = 1+(frame_count - begin_sec),frame_count do		
		    --local file = string.format("res/countdown/%d.png", i)
		    local file = string.format("%s/%d.png", file_path,i)
			local sprite = cc.Sprite:create( file)
			parent:addChild(sprite)
			sprite:setPosition(frame_x,frame_y)
			sprite:setVisible(false)
			a_countdown(sprite,t_delay,frame_scale,fn_cb,i)
			t_delay = t_delay + 1
		end		
	end 
end

--跳跃
function a_jump(obj,delay,t_jump,ptTo,height,num_jump,fn,arg) -- ptTo need cc.p(x,y)
    local function fn_cb()	
        return fn(arg)
    end
    local array = {}
	local idx = 1
	if delay then
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
	array[idx] = cc.JumpTo:create(t_jump,ptTo,height,num_jump)
	idx = idx + 1
	if fn then
		array[idx] = cc.CallFunc:create(fn_cb)		
	end
	obj:runAction(cc.Sequence:create(array))
end

--连续跳跃
function a_sequence_jump(obj,delay,t_jump,arr_ptTo,height,num_jump,fn,arg) -- ptTo need cc.p(x,y)
    local function fn_cb()	
        return fn(arg)
    end
    --local array = CCArray:create()
	local array = {}
	local idx = 1
	if delay then
		--array:addObject(cc.DelayTime:create(delay))
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
	for k,v in pairs(arr_ptTo) do
		--d(k .. " x = " .. v.x .. ' y = ' .. v.y)
		array[idx] = cc.JumpTo:create(t_jump/(#arr_ptTo),v,height,num_jump)
		idx = idx + 1
	end
	if fn then
		array[idx] = cc.CallFunc:create(fn_cb)		
	end
	obj:runAction(cc.Sequence:create(array))
end

--连续跳跃和移动格子
function a_sequence_jump_moveCell(obj,delay,t_jump,arr_ptTo,height,num_jump,cells,fn,arg) -- ptTo need cc.p(x,y)
    local function fn_cb()	
        return fn(arg)
    end
    --local array = CCArray:create()
	local array = {}
	local idx = 1
	if delay > 0 then
		--array:addObject(cc.DelayTime:create(delay))
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
	for k=1,#arr_ptTo do
		--d(k .. " x = " .. v.x .. ' y = ' .. v.y)		
		local index = k
		local function moveDown_y()
			local a = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,-10))
			local b = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,10))	
			local sprite = cells[index]:getSprite()
			sprite:runAction(cc.Sequence:create(a,b))
		end
				
		array[idx] = cc.JumpTo:create(t_jump/(#arr_ptTo),arr_ptTo[k],height,num_jump)
		idx = idx + 1		
		array[idx] = cc.CallFunc:create(moveDown_y)
		idx = idx + 1
	end
	if fn then
		array[idx] = cc.CallFunc:create(fn_cb)		
	end	
	obj:runAction(cc.Sequence:create(array))
end	

--棋子跳跃和移动格子
function a_roleJump_moveCell(obj,delay,t_jump,arr_ptTo,height,num_jump,cells,cities,fn,arg) -- ptTo need cc.p(x,y)
    local function fn_cb()	
        return fn(arg)
    end
    
	local array = {}
	local idx = 1
	if delay > 0 then
		array[idx] = cc.DelayTime:create(delay)
		idx = idx + 1
	end
	for k=1,#arr_ptTo do	
		local index = k
		local function moveDown_y()
			local a = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,-10))
			local b = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,10))	
			local cell = cells[index]
			cell:runAction(cc.Sequence:create(a,b))
		end
		
		local function moveDownCity()
			local a = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,-10))
			local b = cc.MoveBy:create(t_jump/(#arr_ptTo), cc.p(0,10))	
			local city = cities[index]
			if city then
				city:runAction(cc.Sequence:create(a,b))
			end
		end
				
		array[idx] = cc.JumpTo:create(t_jump/(#arr_ptTo),arr_ptTo[k],height,num_jump)
		idx = idx + 1		
		--array[idx] = cc.CallFunc:create(moveDown_y)
		if cities[index] then
			array[idx] = cc.Spawn:create(cc.CallFunc:create(moveDown_y),cc.CallFunc:create(moveDownCity))
		else
			array[idx] = cc.CallFunc:create(moveDown_y)
		end
		idx = idx + 1
	end
	if fn then
		array[idx] = cc.CallFunc:create(fn_cb)		
	end	
	obj:runAction(cc.Sequence:create(array))
end

--移动格子
function a_moveBy_cell(obj, t_move, downBy_y)
	assert(obj)
		
	local a = cc.MoveBy:create(t_move, downBy_y)
	local b = cc.MoveBy:create(t_move, -1*downBy_y)	
	obj:runAction(cc.Sequence:create(a,b))	
end


--翻转
function a_overturn(src_obj,des_obj,t_turn,t_count) --原图，目标图，旋转耗时，旋转次数
	assert(src_obj)
	assert(des_obj)
	local t = t_turn/(t_count*2+1)
	local a = cc.OrbitCamera:create(t*(t_count*2+1),1, 0, 0, 90 + 180*t_count, 0, 0)		
	des_obj:setVisible(false)
		
	local function onOrbit()			
		src_obj:setVisible(false)
		des_obj:setVisible(true)
		local b = cc.OrbitCamera:create(t,1, 0, 90, 90,0,0)			
		des_obj:runAction(b)		
	end
	
	local c = cc.Sequence:create(a,cc.CallFunc:create(onOrbit))
	src_obj:runAction(c)				
end

--加速移动
function a_move_easein(obj,t_delay,t_move,t_stay,ptTo) --对象，延时，移动时间，停留时间，移动位置偏移
	local a = cc.MoveBy:create(t_move, ptTo)
    local b = cc.EaseIn:create(a,t_move/2)	
	local c = nil
	if t_delay then
		c = cc.Sequence:create(cc.DelayTime:create(t_delay),b)
	else
		c = b
	end
	local function onEasein()
		if t_stay then
			local s = cc.Sequence:create(cc.DelayTime:create(t_stay),b:reverse())
			obj:runAction(s)
		end
	end
	obj:runAction(cc.Sequence:create(c,cc.CallFunc:create(onEasein)))
end

--减速移动
function a_move_easeout(obj,t_delay,t_move,t_stay,ptTo)
	local a = cc.MoveBy:create(t_move, ptTo)
    local b = cc.EaseOut:create(a,t_move/2)	
	local c = nil
	if t_delay then
		c = cc.Sequence:create(cc.DelayTime:create(t_delay),b)
	else
		c = b
	end
	local function onEasein()
		if t_stay then
			local s = cc.Sequence:create(cc.DelayTime:create(t_stay),b:reverse())
			obj:runAction(s)
		end
	end
	obj:runAction(cc.Sequence:create(c,cc.CallFunc:create(onEasein)))
end

-- 移动进入
function a_move_fadein_bs(obj, t_delay, src_p,tar_p, callback)
	obj:setPosition(src_p.x, src_p.y)
	local move = cc.MoveTo:create(t_delay, tar_p)
	local fadein = cc.FadeIn:create(t_delay)
	local spawn = cc.Spawn:create(move, fadein)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(spawn, func)
	local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
	local render = obj
	render:setOpacity(0)
	if isCCUI == true then
		render = btn:getVirtualRenderer()
	end
	render:setCascadeOpacityEnabled(true)
	obj:runAction(seq)
end

-- t_scale = {x = 1, y = 1} 从大到小
function a_scale_fadein_bs(obj, t_delay, t_scale_big,t_scale, callback)
	obj:setScale(t_scale_big.x, t_scale_big.y)
	local scale = cc.ScaleTo:create(t_delay, t_scale.x, t_scale.y)
	local fadein = cc.FadeIn:create(t_delay)
	local spawn = cc.Spawn:create(scale, fadein)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(spawn, func)
	local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
	local render = obj
	render:setOpacity(0)
	if isCCUI == true then
		render = btn:getVirtualRenderer()
	end
	render:setCascadeOpacityEnabled(true)
	obj:runAction(seq)
end

-- t_scale = {x = 1, y = 1}
function a_scale_fadein(obj, t_delay, t_scale, callback)
	local scale = cc.ScaleTo:create(t_delay, t_scale.x, t_scale.y)
	local fadein = cc.FadeIn:create(t_delay)
	local spawn = cc.Spawn:create(scale, fadein)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(spawn, func)
	local isCCUI = (string.find(tolua.type(btn), "ccui.") == 1)
	local render = obj
	render:setOpacity(0)
	if isCCUI == true then
		render = btn:getVirtualRenderer()
	end
	render:setCascadeOpacityEnabled(true)
	obj:runAction(seq)
end

-- t_scale = {x = 1, y = 1}
function a_scale_fadeout(obj, t_delay, t_scale, callback)
	local scale = cc.ScaleTo:create(t_delay, t_scale.x, t_scale.y)
	local fadeout = cc.FadeOut:create(t_delay)
	local spawn = cc.Spawn:create(scale, fadeout)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(spawn, func)
	local render = obj
	if isCCUI == true then
		render = btn:getVirtualRenderer()
	end
	render:setCascadeOpacityEnabled(true)
	obj:runAction(seq)
end

-- t_scale = {x = 1, y = 1}
function a_scale_moveto(obj, t_delay, t_scale, t_pos, callback)
	local scale = cc.ScaleTo:create(t_delay, t_scale.x, t_scale.y)
	local moveto = cc.MoveTo:create(t_delay, t_pos)
	local spawn = cc.Spawn:create(scale, moveto)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(spawn, func)
	obj:runAction(seq)
end

function a_moveto(obj, t_delay, t_pos, callback)
	local moveto = cc.MoveTo:create(t_delay, t_pos)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(moveto, func)
	obj:runAction(seq)
end

function a_move_movefade(obj, m_delay, m_pos, delay, pos, callback)
	local move1 = cc.MoveTo:create(m_delay, m_pos)
	local move2 = cc.MoveTo:create(delay, pos)
	local fadeOut = cc.FadeOut:create(delay)
	local spawn = cc.Spawn:create(move2, fadeOut)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
	local seq = cc.Sequence:create(move1, spawn, func)
	obj:runAction(seq)
end

--来回晃动 
function a_forever_move(obj, t_delay , position ,callback)
    local move1 = cc.MoveBy:create(t_delay,position)
    local move2 = move1:reverse()
    local function t_fun()
        if nil ~= callback then
            callback()
        end
    end
    local func = cc.CallFunc:create(t_fun)
    local sq = cc.Sequence:create(move1,move2,func)
    local action = cc.RepeatForever:create(sq)
    obj:runAction(action)
end 

--一个变4个散开并飞出,1对象,2分散距离,3,分散偏移，4，分散时间，5，移动时间，6，到达位置 7，每个执行得回调，8，只执行一次回调
function a_copy_move(obj,radian ,culcal, r_delay,t_delay,position ,callback ,callback1)
   if nil ~= obj and #obj ~= 0 then 

      
      local move1 = cc.MoveBy:create(r_delay , cc.p(0,radian))
      local move2 = cc.MoveBy:create(r_delay , cc.p(0-radian,culcal))
      local move3 = cc.MoveBy:create(r_delay , cc.p(radian,0))
      local move4 = cc.MoveBy:create(r_delay , cc.p(0,0-radian))
--      local y = (position.y / position.x )*radian 
--      if position.x >= 0 then 
--          move1 = cc.MoveBy:create(r_delay , cc.p(radian,y*0.3))
--          move2 = cc.MoveBy:create(r_delay , cc.p(0-radian,(radian*radian)/y))
--          move3 = cc.MoveBy:create(r_delay , cc.p(radian,0-(radian*radian)/y))
--          move4 = cc.MoveBy:create(r_delay , cc.p(0-radian,0-y*0.3))
--      else 
--          move1 = cc.MoveBy:create(r_delay , cc.p(0-radian,y))
--          move2 = cc.MoveBy:create(r_delay , cc.p(0-radian,0-(radian*radian)/y))
--          move3 = cc.MoveBy:create(r_delay , cc.p(radian,(radian*radian)/y))
--          move4 = cc.MoveBy:create(r_delay , cc.p(radian,0-y))
--      end 

      local function t_fun(obj1)
          obj1:removeFromParent(true)
          if nil ~= callback then     
              callback()
          end
      end
      local function one_fun()
          if nil ~= callback1 then
             callback1()
          end 
      end 
      
      local t_move1 = cc.MoveBy:create(t_delay-0.2,cc.p(position.x,position.y -radian))
      local t_move2 = cc.MoveBy:create(t_delay,cc.p(position.x + radian ,position.y))
      local t_move3 = cc.MoveBy:create(t_delay,cc.p(position.x - radian  ,position.y))
      local t_move4 = cc.MoveBy:create(t_delay+0.2,cc.p(position.x  ,position.y + radian))

--        if position.x >= 0 then 
--           t_move1 = cc.MoveBy:create(t_delay-0.2,cc.p(position.x - radian ,position.y - y ))
--           t_move2 = cc.MoveBy:create(t_delay,cc.p(position.x + radian  ,position.y - (radian*radian)/y))
--           t_move3 = cc.MoveBy:create(t_delay,cc.p(position.x -radian   ,position.y + (radian*radian)/y))
--           t_move4 = cc.MoveBy:create(t_delay+0.2,cc.p(position.x + radian ,position.y + y))
--        else 
--           t_move1 = cc.MoveBy:create(t_delay-0.2,cc.p(position.x + radian,position.y - y ))
--           t_move2 = cc.MoveBy:create(t_delay,cc.p(position.x + radian ,position.y +(radian*radian)/y))
--           t_move3 = cc.MoveBy:create(t_delay,cc.p(position.x - radian  ,position.y -(radian*radian)/y))
--           t_move4 = cc.MoveBy:create(t_delay+0.2,cc.p(position.x -radian,position.y + y ))
--        end 
        
              
      local delay = cc.DelayTime:create(0.2)
      for key ,value in pairs(obj) do
         local func1 = cc.CallFunc:create(t_fun,{value})
         local funcone = cc.CallFunc:create(one_fun)
         if key == 1 then 
            local sq1 = cc.Sequence:create(move1,delay,t_move1,func1) 
            value:runAction(sq1)
         elseif key == 2 then 
            local sq2 = cc.Sequence:create(move2,delay,t_move2,func1)
            value:runAction(sq2)
         elseif key == 3 then 
            local sq3 = cc.Sequence:create(move3,delay,t_move3,func1)
            value:runAction(sq3)
         elseif key == 4 then  
            local sq4 = cc.Sequence:create(move4,delay,t_move4,funcone,func1)  
            value:runAction(sq4)     
         end 
      end      
      
   end  
end
--谈出，飞，淡入
function a_flyto(obj, in_delay,move_delay,pos,out_delay, callback)
	local in_fade = cc.FadeIn:create(in_delay)
	local scale = cc.ScaleTo:create(0.3,0.3)
	local move = cc.MoveTo:create(move_delay, pos)
	local fadeOut = cc.FadeOut:create(out_delay)
	local sp = cc.Spawn:create(scale,move)
	local function t_fun()
		if nil ~= callback then
			callback()
		end
	end
	local func = cc.CallFunc:create(t_fun)
    local seq = cc.Sequence:create(in_fade,sp,fadeOut,func)
	obj:runAction(seq)
end

-- 设置对象透明度, 不对非  ccui 进行递归
function setUiOpacity(obj, value)
    local isCCUI = (string.find(tolua.type(obj), "ccui.") == 1)
    if isCCUI == true then
        local render = obj:getVirtualRenderer()
        if nil ~= render then
            render:setOpacity(value)
        end
        local list = obj:getChildren()
        for _, v in pairs(list) do
            setUiOpacity(v, value)
        end
    end
end

-- 设置对象透明度, 对所有子进行递归
function setUIOpacityAll(obj, value)
    local isCCUI = (string.find(tolua.type(obj), "ccui.") == 1)
    if isCCUI == true then
        local render = obj:getVirtualRenderer()
        if nil ~= render then
            render:setOpacity(value)
        end
        local list = obj:getChildren()
        for _, v in pairs(list) do
            setUIOpacityAll(v, value)
        end
    else
        obj:setOpacity(value)
        local list = obj:getChildren()
        for _, v in pairs(list) do
            setUIOpacityAll(v, value)
        end
    end
end

-- 设置FadeIn FadeOut FadeTo
--@ui 设置的UI
--@func cc.FadeIn cc.FadeOut cc.FadeTo
--@time
--@target FadeTo 目标
--@action Fade动作后的action
function setUIFade(ui, func, time, target, action)
    local isCCUI = (string.find(tolua.type(ui), "ccui.") == 1)
    if isCCUI == true then
        local render = ui:getVirtualRenderer()
        if nil ~= render then
            local run_action = nil
            if target == nil then
                run_action = func:create(time)
            else
                run_action = func:create(time, target)
            end
            
            if action ~= nil then
                run_action = cc.Sequence:create( run_action, cc.CallFunc:create( action ) )
            end

            render:runAction( run_action )
        end
        local list = ui:getChildren()
        for _, v in pairs(list) do
            setUIFade(v, func, time, target, action)
        end
    end
end

function showScaleEffect(target)
    if nil ~= target then
        if target:getNumberOfRunningActions() == 0 then
	    	local per = 1.2
	    	local delay = 0.1
		    local p = cc.p(target:getPosition())
	  		local ap = target:getAnchorPoint()

			local scale1 = cc.ScaleTo:create(delay, per)
		    local scale2 = cc.ScaleTo:create(delay, 1)

		    local sq = nil
		    local isNeed = (ap.x == 0 and ap.y == 0)
	  		if true == isNeed then
	  			local dp = (per - 1) / 2
		    	local s = target:getSize()
		  		local sp = cc.p(p.x - s.width * dp, p.y - s.height * dp)
			    
			    target:setScale(per)
			    target:setPosition(sp)
			    local move1 = cc.MoveTo:create(delay, sp)
			    local move2 = cc.MoveTo:create(delay, p)
			    sq = cc.Sequence:create(cc.Spawn:create(scale1, move1), cc.Spawn:create(scale2, move2))
	  		else
		   	    sq = cc.Sequence:create(scale1, scale2)
	    	end
		    target:runAction(sq)

			local i = 0
			local tid = nil
		    
		    local function setLight()
		    	i = i + 1
		    	if target == nil or target.setScale == nil then
		    		TimerMgr.killTimer(tid)
		    		return
		    	end
		    	if i < 3 then
		    		ProgramMgr.setLight(target, 1 + i * 0.3)
		    	else
		    		ProgramMgr.setLight(target, 1.6 - (i - 2) * 0.3)
		    	end
		    	if i == 4 then
		    		TimerMgr.killTimer(tid)
		    	end
		    end
		    tid = TimerMgr.startTimer(setLight, 0.05, false)
		    
		    local function onNodeEvent(event)
                if "exit" == event then
                    TimerMgr.killTimer(tid)
	                target:setScale(1)
	                if isNeed == true then
	                    target:setPosition(p)
	                end
	                -- ProgramMgr.setNormal(target)
	                ProgramMgr.setLight(target, 1)
                end
		    end
            target:registerScriptHandler(onNodeEvent)
		end
    end 
end

-- viewlist ，移动时间 ， 移动撒开距离，移向的位置
function a_four_move(data,rdelay,tdelay,rand,position , percallback , callback)
   local move = {}
   for i = 1 ,#data ,1 do 
       move[i] = {}
   end  
   local moveposition = {
   {{-80,30},{80,0},{-50,100},{-10,-10}}, --右上角
   {{10,10},{10,10},{10,10},{10,10}}, --右下角  （未设置参数）
   {{-120,20},{-40,-30},{10,80},{30,10}}, --左上角
   {{10,10},{10,10},{10,10},{10,10}}  --左下角 （未设置参数）
   }
   
   local function perfun (obj1)
      if obj1 ~= nil then 
         obj1:removeFromParent(true)
         obj1 = nil 
      end 
      if percallback ~= nil then 
         percallback()
      end  
   end 
   local function fun() 
      if callback ~= nil then 
         callback ()
      end 
   end 
   
   if position.x >= 0 then 
      if position.y >= 0 then 
         --右上角
         for i ,v   in pairs(data) do 
              local mp = moveposition[1][i]
              mp[1] = mp[1] + 50
              mp[2] = mp[2] + 50
              local t_move = cc.MoveBy:create(rdelay,cc.p(mp[1],mp[2]))    
              table.insert(move[i] , t_move)
              local p = {x = 0,y = 0}
              p.x = math.random(20 ,  30)
              p.y = math.random(20 ,  30)
              local t_move1 = cc.MoveBy:create(0.5,cc.p(p.x,  p.y))
              table.insert(move[i],t_move1)
              local next = cc.MoveTo:create(tdelay,cc.p(position.x,position.y ))
              table.insert(move[i], next)
              local call = cc.CallFunc:create(perfun,{data[i]})
              table.insert(move[i], call)
         end 
      else 
         --右下角
         for i = 1  , #data ,1 do 
                local mp = moveposition[2][i]
                mp[1] = mp[1] + 50
                mp[2] = mp[2] + 50
                local t_move = cc.MoveBy:create(rdelay,cc.p(mp[1],mp[2]))    
                table.insert(move[i] , t_move)
                local p = {x = 0,y = 0}
                p.x = math.random(20 ,  30)
                p.y = math.random(-20 ,  -30)
                local t_move1 = cc.MoveBy:create(0.5,cc.p(p.x,  p.y))
                table.insert(move[i],t_move1)
                local next = cc.MoveTo:create(tdelay,cc.p(position.x,position.y ))
                table.insert(move[i], next)
                local call = cc.CallFunc:create(perfun,{data[i]})
                table.insert(move[i], call)
         end 
      end 
   elseif position.x < 0 then 
      if position.y >= 0 then 
         --左上角
         for i = 1  , #data ,1 do      
                local mp = moveposition[3][i]
                mp[1] = mp[1] + 50
                mp[2] = mp[2] + 50
                local t_move = cc.MoveBy:create(rdelay,cc.p(mp[1],mp[2]))    
                table.insert(move[i] , t_move)
                local p = {x = 0,y = 0}
                p.x = math.random(-20 ,  -30)
                p.y = math.random(20 ,  30)
                local t_move1 = cc.MoveBy:create(0.5,cc.p(p.x,  p.y))
                table.insert(move[i],t_move1)
                local next = cc.MoveTo:create(tdelay,cc.p(position.x,position.y ))
                table.insert(move[i], next)
                local call = cc.CallFunc:create(perfun,{data[i]})
                table.insert(move[i], call)
                
         end 
      else 
        --左下角
        for i = 1  , #data ,1 do 
                local mp = moveposition[4][i]
                mp[1] = mp[1] + 50
                mp[2] = mp[2] + 50
                local t_move = cc.MoveBy:create(rdelay,cc.p(mp[1],mp[2]))    
                table.insert(move[i] , t_move)
                local p = {x = 0,y = 0}
                p.x = math.random(-20 ,  -30)
                p.y = math.random(-20 ,  -30)
                local t_move1 = cc.MoveBy:create(0.5,cc.p(p.x,  p.y))
                table.insert(move[i],t_move1)
                local next = cc.MoveTo:create(tdelay,cc.p(position.x,position.y ))
                table.insert(move[i], next)
                local call = cc.CallFunc:create(perfun,{data[i]})
                table.insert(move[i], call)
        end 
      end
   end 
   local func = cc.CallFunc:create(fun)
   for k ,v in pairs(data) do 
      table.insert(move[k], func )
      v:runAction(cc.Sequence:create(move[k]))
   end 
   
end

function a_move_scale(obj, t, x, y, s, callfunc)
	local move = cc.MoveBy:create(t, cc.p(x, y))
	local scale = cc.ScaleTo:create(t, s)

	if callfunc ~= nil then
		obj:runAction(cc.Sequence:create(move, scale, callfunc))
	else
		obj:runAction(cc.Sequence:create(move, scale))
	end
end

-- 根据obj生成n个对象随机分散开 r：圆半径， t:时间
function a_copy_disperse(obj, parent, r, t, n)
	if nil == obj then
		return
	end
	local objList = {}
	local moveList = {}
    local degree = math.random(0, 360)
	for i=1, n do
		local copy = obj:clone()
		parent:addChild(copy)
		table.insert(objList, copy)
		local radian = (degree+360/n*i)%360 * math.pi / 180
        local x = math.cos(radian) * r
        local y = math.sin(radian) * r

        local move = cc.MoveBy:create(t, cc.p(x, y))
        local ease = cc.EaseSineIn:create(move)
        table.insert(moveList, ease)
	end
	obj:setVisible(false)
	for i=1, n do
		objList[i]:runAction(moveList[i])
	end
end

--变成多个分散 并缓慢移动 再变速上移
-- 1.obj 为对象（必须加入父类），2.parent为父类，3.半径， 4.时间，5.多少个obj，6.达到位置 ，7.每次到达的回调（回调多次），8.最后完成的回调只回调一次
function a_move_SpeedDown(obj,parent , r ,t , n , position,callback1 , callback2)
    if nil == obj then
        return
    end
    local x1 = position.x - obj:getPositionX()
    local y1 = position.y - obj:getPositionY()

    local objList = {}
    local moveList = {}
    for i = 1 ,n do
      moveList[i] = {}
    end 
    local degree = math.random(0, 360)
    local function fun1 (value)
       value:removeFromParent(true)
       value = nil 
       if callback1 ~= nil then 
          callback1()
       end 
    end 
    
    local function fun2 ()
       if callback2 ~= nil then 
          callback2()
       end 
    end 
    
    for i=1, n do
        local copy = obj:clone()
        parent:addChild(copy)
        table.insert(objList, copy)
        local radian = (degree+360/n*i)%360 * math.pi / 180
        local x = math.cos(radian) * r
        local y = math.sin(radian) * r
           
        local move = cc.MoveBy:create(t, cc.p(x, y))

        table.insert(moveList[i], move)
        local move1 = nil 
        if x1 >=0 then 
           if y1 >= 0 then 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(50, 70),math.random(80, 90)))
           else 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(50, 70),math.random(-80, -90)))
           end         
        else 
           if y1 >= 0 then 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(-50, -80),math.random(80, 90)))
           else 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(-50, -70),math.random(-80, -90)))
           end 
        end
        
        local ease1 = cc.EaseSineOut:create(move1)
        
        table.insert(moveList[i],ease1)
--        local sq1 = cc.Sequence:create(ease1,cc.CallFunc:create(function () print "move1" end ))
--        table.insert(moveList[i],sq1)
        
        local moveto = cc.MoveTo:create(0.3,cc.p(position.x,position.y))
        local out = cc.EaseSineIn:create(moveto)
        table.insert(moveList[i],out)

--        local sq2 = cc.Sequence:create(out,cc.CallFunc:create(function () print "move2" end ))
--        table.insert(moveList[i],sq2)

        local call = cc.CallFunc:create(fun1,{copy})
        table.insert(moveList[i],call)
        
        if i == n then 
            local call1 = cc.CallFunc:create(fun2)
            table.insert(moveList[n], call1 )
        end 
        
    end
--    local call1 = cc.CallFunc:create(fun2) 
--    local time = t + 0.4 + 0.3 
--    local delay = cc.DelayTime:create(time)
--    parent:runAction(cc.Sequence:create(delay,call1))
    obj:removeFromParent(true)
    for i=1, n do
        objList[i]:runAction(cc.Sequence:create(moveList[i]))
    end
end

function a_image_up_move(obj)
	obj:setOpacity(0)
	local fadein = cc.FadeIn:create(0.1)
	local move1 = cc.MoveBy:create(0.65, cc.p(0, 43))
	local ease = cc.EaseSineOut:create(move1)
	local move3 = cc.MoveBy:create(0.75, cc.p(0, 30))
	local fadeout = cc.FadeOut:create(0.25)
	local move2 = cc.MoveBy:create(0.25, cc.p(0, 25))

	action = cc.Sequence:create(cc.Spawn:create(fadein,ease), cc.Spawn:create(fadeout, move2), cc.RemoveSelf:create())
	obj:runAction(action)

	return action
end

function a_repeate(node, callback, delay, times)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.Repeat:create(sequence, times)
    node:runAction(action)
    return action
end

function a_scale_seq(list, s, t, callback)
	local sid = nil
	local index = 1
	local function showListAction()
		if index > #list then
			TimerMgr.killTimer(sid)
			if nil ~= callback then callback() end
			return
		end
		local obj = list[index]
		local show = cc.Show:create()
		local scale = cc.ScaleTo:create(t, s)
		local bounceOut = cc.EaseBounceOut:create(scale)
		obj:runAction(cc.Sequence:create(show, bounceOut))
		index = index + 1
	end
	sid = TimerMgr.startTimer(showListAction, t + 0.05)
end

function a_diverse_move_SpeedDown(img, pos, parent, r, t, n, position, callback1, callback2)
    local obj = ccui.ImageView:create(img, ccui.TextureResType.plistType)
    obj:setPosition(pos)
    if parent == nil then
	    parent = SceneMgr.getLayer(SceneMgr.LAYER_EFFECT)
	end
	parent:addChild(obj)

    local x1 = position.x - obj:getPositionX()
    local y1 = position.y - obj:getPositionY()
    
    local objList = {}
    local moveList = {}
    for i = 1 ,n do
      moveList[i] = {}
    end 
    local degree = math.random(0, 360)
    local function fun1 (value)
       value:removeFromParent(true)
       value = nil 
       if callback1 ~= nil then 
          callback1()
       end 
    end 
    
    local function fun2 ()
       if callback2 ~= nil then 
          callback2()
       end 
    end 
    
    for i=1, n do
        local copy = obj:clone()
        parent:addChild(copy)
        table.insert(objList, copy)
        local radian = (degree+360/n*i)%360 * math.pi / 180
        local x = math.cos(radian) * r
        local y = math.sin(radian) * r
           
        local move = cc.MoveBy:create(t, cc.p(x, y))

        table.insert(moveList[i], move)
        local move1 = nil 
        if x1 >=0 then 
           if y1 >= 0 then 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(50, 70),math.random(80, 90)))
           else 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(50, 70),math.random(-80, -90)))
           end         
        else 
           if y1 >= 0 then 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(-50, -80),math.random(80, 90)))
           else 
              move1 = cc.MoveBy:create(0.4,cc.p(math.random(-50, -70),math.random(-80, -90)))
           end 
        end
        
        local ease1 = cc.EaseSineOut:create(move1)
        
        table.insert(moveList[i],ease1)
        
        local moveto = cc.MoveTo:create(0.3,cc.p(position.x,position.y))
        local out = cc.EaseSineIn:create(moveto)
        table.insert(moveList[i],out)

        local call = cc.CallFunc:create(fun1,{copy})
        table.insert(moveList[i],call)
        
        if i == n then 
            local call1 = cc.CallFunc:create(fun2)
            table.insert(moveList[n], call1 )
        end 
        
    end
    obj:removeFromParent(true)
    for i=1, n do
        objList[i]:runAction(cc.Sequence:create(moveList[i]))
    end
end

-- 数字转动
-- @ target_num: 目标值
-- @ orig_num: 起始值
function a_num_rolling(obj, target_num, orig_num, callfunc)
	orig_num = orig_num or 0
	target_num = target_num or 0
	if orig_num == target_num then
		if not obj:isVisible() then
			obj:setVisible(true)
		end
		obj:setString(target_num)
		return
	end
	for i = orig_num, target_num, 1 do
		local function callback()
			if not obj:isVisible() then	obj:setVisible(true) end
			if i >= target_num then	if callfunc then callfunc() end	end
			obj:setString(i)
		end
		if i == orig_num then
			callback()
		else
			performWithDelay(obj, callback, 0.001 * (i-orig_num))
		end
	end
end