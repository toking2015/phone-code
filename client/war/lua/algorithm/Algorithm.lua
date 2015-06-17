Algorithm = Algorithm or {}

function Algorithm.binarySearch(list, des)
	local low = 1
	local high = #list
	while low <= high and low <= #list and high <= #list do
		local mid = low + math.floor((high - low) / 2)
		if des == list[mid] then
			return mid
		elseif des < list[mid] then
			high = mid - 1
		else
			low = mid + 1
		end
	end
	return 0
end
