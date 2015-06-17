-- create by Live --
local PI = 3.1415926
local P_PI = PI / 180

PageData = {}

local currPage = 1

-- 配置文件路径
local configURL = ""
-- 图片文件夹路径
local imageFolder = "image/mainPage/pieces/"
-- 8个页面各个所需的图片
local pageList = {}
local buildingList = {}
local decorativeList = {}
local click = {}

local isLoadingEnd = true

function PageData.clear()
	currPage = 1
end
PageData.clear()
EventMgr.addListener(EventType.UserLogout, function()
	PageData.clear()
end)

function PageData.setIsLoadingEnd(bln)
	isLoadingEnd = bln
end
function PageData.getIsLoadingEnd()
	return isLoadingEnd
end

local pageOpen = {
	[1] = {type = 1, data = 0},
    [2] = {type = 1, data = 999},
	[3] = {type = 1, data = 999},
	[4] = {type = 1, data = 999},
    [5] = {type = 1, data = 999},
    [6] = {type = 1, data = 999},
    [7] = {type = 1, data = 999},
	[8] = {type = 1, data = 10}
}

function PageData.getPageOpen(page)
	return pageOpen[page]
end

function PageData.setCurrPage(page)
	currPage = page
end
function PageData.getCurrPage()
	return currPage
end

local redPointList = {}
function PageData.addRedPointData(obj)
	if nil == redPointList[obj.page .. "_" .. obj.id] then
		redPointList[obj.page .. "_" .. obj.id] = obj
	end
end
function PageData.getRedPointData()
	return redPointList
end
function PageData.clearRedPointData()
	redPointList = {}
end

local bubbleList = {}
function PageData.addBubbleIcon(obj)
	if nil == bubbleList[obj.page .. "_" .. obj.id] then
		bubbleList[obj.page .. "_" .. obj.id] = obj
	end
end
function PageData.getBubbleIcon()
	return bubbleList
end
function PageData.clearBubble()
	bubbleList = {}
end

-- 设置配置信息（当前只是添加图片）
function PageData.loadConfig()
	-- 加载配置设置pageList

	local list = PageInfo.pages
	for k, v in pairs(list) do
		local pieces = v.pieces
		pageList[k] = {}
		buildingList[k] = v.click
		decorativeList[k] = v.decoratives
		-- local row = 1
		-- local col = 1
		pageList[k] = v.need
	end
	-- LogMgr.debug(".............." .. debug.dump(click))
end

-- function PageData.getClickList(index)
-- 	if nil ~= click[index] then
-- 		return click[index]
-- 	end
-- 	return {}
-- end

-- 获取前一页的页数
function PageData.getPrevPage(index)
	local prevPage = index - 1
	if prevPage < 1 then
		prevPage = 8
	end
	return prevPage
end
-- 获取下一页的页数
function PageData.getNextPage(index)
	local nextPage = index + 1
	if nextPage > 8 then
		nextPage = 1
	end
	return nextPage
end
-- 获取页数所需的图片列表
function PageData.getPageImgList(index)
	if index > 8 or index < 1 then
		LogMgr.log( 'debug',"Error : You show a incorrect page, value = " .. index .. "!")
	end

	local list = {}
	if pageList[index] ~= nil then
    	for _, v in pairs(pageList[index]) do
    		list[v] = imageFolder .. v .. ".png"
    	end
	end

	return list
end
function PageData.getPrevPageImageList(index)
	local prevPage = PageData.getPrevPage(index)
	return PageData.getPageImgList(prevPage)
end
function PageData.getNextPageImageList(index)
	local nextPage = PageData.getNextPage(index)
	return PageData.getPageImgList(nextPage)
end

-- 实现table添加另一table的元素
local function addTableValue(target, list)
	for k, v in pairs(list) do
		if nil == target[k] then
			target[k] = v
		end
	end
end	
-- 获取当前页所需的图片列表
function PageData.getPageAllImgList(index)
	local list = {}
	local prevPage = PageData.getPrevPage(index)
	local nextPage = PageData.getNextPage(index)

	local imgs = PageData.getPageImgList(prevPage)
	addTableValue(list, imgs)
	imgs = PageData.getPageImgList(index)
	addTableValue(list, imgs)
	imgs = PageData.getPageImgList(nextPage)
	addTableValue(list, imgs)

	return list
end

function PageData.getPrevNextImageList(index)
	local list = {}
	local prevPage = PageData.getPrevPage(index)
	local nextPage = PageData.getNextPage(index)

	local imgs = PageData.getPageImgList(prevPage)
	addTableValue(list, imgs)
	imgs = PageData.getPageImgList(nextPage)
	addTableValue(list, imgs)

	return list
end

-- 获取第一个下标与第二下标中木有交集的图片
function PageData.getNotImageList(first, second)
	LogMgr.log( 'debug',"first = " .. first .. " and second = " .. second)
	local firstList = PageData.getPageImgList(first)
	local secondList = PageData.getPageImgList(second)

	for k, v in pairs(secondList) do
		-- LogMgr.log( 'debug'," k = " .. k .. " and f = " .. firstList[])
		if nil ~= firstList[k] then
			firstList[k] = nil
		end
	end
	return firstList
end

function PageData.getPageDecorative(index)
	return decorativeList[index]
end

function PageData.getPageBuilding(index)
	local list = buildingList[index]
	if not list then
		list = {}
		buildingList[index] = list
	end
	return list
end

function PageData.getPageParticle(index)
	return PageParticle[index]
end

-- 获取显示当前页所需添加及删除页数
function PageData.getAddRemovePage(lastPage, index)
	local removeIndex = 0
	local addIndex = 0

	if lastPage == 1 and index == 8 then
		removeIndex = PageData.getNextPage(lastPage)
		addIndex = PageData.getPrevPage(index)
	elseif lastPage == 8 and index == 1 then
		removeIndex = PageData.getPrevPage(lastPage)
		addIndex = PageData.getNextPage(index)
	elseif lastPage < index and lastPage <= 7 then
		removeIndex = PageData.getPrevPage(lastPage)
		addIndex = PageData.getNextPage(index)
	elseif lastPage > index and lastPage >= 2 then
		removeIndex = PageData.getNextPage(lastPage)
		addIndex = PageData.getPrevPage(index)
	end
	return addIndex, removeIndex
end

-- 获取显示当前页所需添加的图片和删除的图片
function PageData.getAddRemoveList(lastPage, index)
	local removeList = nil
	local addList = nil

	local addIndex, removeIndex = PageData.getAddRemovePage(lastPage, index)
	
	LogMgr.log( 'debug',"last = " .. lastPage .. " , curr = " .. index)
	removeList = PageData.getNotImageList(removeIndex, lastPage)
	addList = PageData.getNotImageList(addIndex, index)

	return removeList, addList
end
