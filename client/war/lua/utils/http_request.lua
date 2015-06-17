-------------------------------------------------------------- http
--http请求数据队列
local http_queue = {
}
--http请求图片队列
local pic_download = {}

--http请求上传队列
local pic_upload = {}

local http_global_idx = 0
local http_pic_download_idx = 0
local http_pic_upload_idx = 0

local function http_response_cb(data, request_idx,code)
	local request_info = http_queue[request_idx]
	if request_info then
		if code == 200 then
			request_info["response_cb"](data)
		else
			d(code .. ' error ' .. request_info["url"])
		end
		http_queue[request_idx] = nil
	end		
end

local function http_download_pic_cb(data,request_idx,code)
	local request_info = pic_download[request_idx]
	if request_info then
		if code == 200 then
			--d('download sucessed:' .. pic_download[request_idx].url)
			request_info["response_cb"](data)
		else
			d(code .. ' error ' .. request_info["url"])
		end
		pic_download[request_idx] = nil
	end
end	

local function http_upload_pic_cb(data,request_idx)
	local request_info = pic_upload[request_idx]
	if request_info then
		request_info["response_cb"](data)
		pic_upload[request_idx] = nil
	end
end

function proc_single_request()
    --先获取优先级高的请求
    for request_idx, request_info in pairs(http_queue) do
		if request_info["busy"] == false then
			if request_info["http"] then		
				libcurl.lcurl_http_request(request_info["url"],request_info["idx"], http_response_cb)
				request_info["busy"] = true
				return
			end
		end
	end
	--再遍历上传列表
	for request_idx, request_info in pairs(pic_upload) do
		if request_info["busy"] == false then					
				libcurl.lcurl_http_upload(request_info["url"],request_info["param"], request_info["idx"], http_upload_pic_cb)
				request_info["busy"] = true
				return															
		end
	end
	--遍历图片下载列表	
	for request_idx, request_info in pairs(pic_download) do
		if request_info["busy"] == true then	
			--d(	request_info["time"] )
			if os.time()  - tonumber(request_info["time"]) < 6 then
				return
			else
				request_info = nil
			end
		end			
	end
	for request_idx, request_info in pairs(pic_download) do
		if request_info["busy"] == false then
			libcurl.lcurl_http_download_pic(request_info["url"],request_info["file"], request_info["idx"], http_download_pic_cb)
			request_info["busy"] = true
			return			
		end
	end
end

function http_request(url, response_cb,priority)
	http_global_idx = http_global_idx + 1

	local url_info = {}
	url_info["url"] = url
	url_info["response_cb"] = response_cb
	url_info["busy"] = false
	url_info["http"] = true
	url_info["priority"] = priority
	url_info["idx"] = http_global_idx

	http_queue[http_global_idx] = url_info
end

function http_download_pic(url,file,response_cb)
	http_pic_download_idx = http_pic_download_idx + 1

	local url_info = {}
	url_info["url"] = url
	url_info["response_cb"] = response_cb
	url_info["busy"] = false
	url_info["type"] = "pic"
	url_info["file"] = file		
	url_info["idx"] = http_pic_download_idx
	url_info["time"] = tonumber(os.time())

	pic_download[http_pic_download_idx] = url_info
end

function cancel_download_pic()
	pic_download = {}
	http_pic_download_idx = 0
end

function http_upload(url, param_info, response_cb)
	http_pic_upload_idx = http_pic_upload_idx + 1

	local url_info = {}
	url_info["url"] = url
	url_info["response_cb"] = response_cb
	url_info["busy"] = false
	url_info["upload"] = true
	url_info["param"] = param_info
	url_info["idx"] = http_pic_upload_idx

	pic_upload[http_pic_upload_idx] = url_info
end


