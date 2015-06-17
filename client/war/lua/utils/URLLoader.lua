require('lua/utils/http')

URLLoader = class("URLLoader", function()
	return {}
end)

---
--@param url 		url地址
--@param complete	完成function(data)
--@param progress	[可选]进度function(curSize, maxSize)
--@param error 		[可选]失败function()
--@param retryTimes	[可选]最多加载次数
--@param timeout	[可选]超时时间（秒），多少时间重试一次加载
--@param url2		[可选]备用url地址
--@param postData	POST提交的数据
--
function URLLoader:ctor(url, complete, progress, error, retryTimes, timeout, url2, postData)
	self:load(url, complete, progress, error, retryTimes, timeout, url2, postData)
end

function URLLoader:load(url, complete, progress, error, retryTimes, timeout, url2, postData)
	self.url = url
	self.url2 = url2 or url
	self.postData = postData
	self.complete = complete
	self.progress = progress
	self.error = error
	self.retryTimes = retryTimes or complete and 9 or 3
	if url and url ~= "" then
		self:doLoad()
	end
	if timeout then
		self.timer_id = PreLoadUtils.startTimer(function() self:doLoad() end, timeout)
	end

end

function URLLoader:clear()
	self.complete = nil
	self.progress = nil
	self.error = nil
	self.timer_id = PreLoadUtils.killTimer(self.timer_id)
end

function URLLoader:doLoad()
	local function onData(data, curSize, maxSize)
		if self.progress then
			self.progress(curSize, maxSize)
		end
		if curSize ~= maxSize then
			return
		elseif curSize == 0 then
			if self.retryTimes > 0 then
				self:doLoad() --重试处理
			else
				if self.error then
					self.error()
					self:clear()
				end
			end
		else
			if self.complete then
				self.complete(data)
				self:clear()
			end
		end
	end
	self.retryTimes = self.retryTimes - 1
	local url = self.retryTimes % 2 == 0 and self.url or self.url2
	if self.postData then
		http.request(url, onData, "POST", self.postData)
	else
		http.request(url, onData)
	end
end