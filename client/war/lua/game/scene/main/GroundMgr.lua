-- Create By Live --
-- 此管理器本来是用来获取两张图片位置的交集，当前已废弃 --

GroundMgr = {}

-- function GroundMgr.createGround(row, col, bln)
-- 	local texture = createMixTexture(self.url, self.alphaUrl, self.gRect, self.aRect)
-- 	local ground = Sprite:
-- end

local shadowDic = {}
local groundDic = {}
local piece_width = PageInfo.piece_width
local piece_height = PageInfo.piece_height

function getDistanceRect(rect1, rect2)
	local rect = cc.rect()
	rect.x = rect1.x - rect2.x
	rect.y = (rect1.y - rect2.y)
	rect.width = rect1.width
	rect.height = rect1.height

	return rect
end
function getRectMix(rect1, rect2)
	local rect = cc.rectIntersection(rect1, rect2)
    -- LogMgr.log( 'scene', debug.dump(rect) )
	local gRect = getDistanceRect(rect, rect1)
	gRect.y = rect1.height - gRect.y - gRect.height
	local aRect = getDistanceRect(rect, rect2)
	aRect.y = rect2.height - aRect.y - aRect.height

	return gRect, aRect
end

function setGroundRect(page, url, x, y, width, height)
	-- LogMgr.log( 'debug',x .. " , " .. y .. " , " .. width .. " , " .. height)
	local minX = math.floor(x / piece_width)
	local maxX = math.floor((x + width) / piece_width)
	local minY = PageInfo.row - 1 - math.floor((y + height) / piece_height)
	local maxY = PageInfo.row - 1 - math.floor((y) / piece_height)

	-- LogMgr.log( 'debug',minX .. " , " .. maxX .. " , " .. minY .. " , " .. maxY)

	for i = minY, maxY, 1 do
		for j = minX, maxX, 1 do
			local key = i .. "_" .. j
			if nil == groundDic[key] then
				groundDic[key] = {}
			end
			-- 因为整图为3500 x 3500 ，但是 space = row x piece_width - 3500 ，所以必须下移space
			local rect1 = cc.rect(j * piece_width, (PageInfo.row - i - 1) * piece_height - PageInfo.left_space, piece_width, piece_height)
			local rect2 = cc.rect(x, y, width, height)
            -- LogMgr.log( 'scene', "rect1 = " .. debug.dump(rect1))
            -- LogMgr.log( 'scene', "rect2 = " .. debug.dump(rect2))
			local gRect, aRect = getRectMix(rect1, rect2)

			table.insert(groundDic[key], {alpha = url, gRect = gRect, aRect = aRect})
		end
	end
    -- LogMgr.log( 'scene', debug.dump(groundDic) )
end

function clearGroundDic()
	groundDic = {}
end

