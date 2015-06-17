local __this = EffectData or {}
EffectData = __this

function __this.getName(id)
	local jEffect = findEffect(id)
	return jEffect.desc
end

function __this.getValue(id, val)
	local jEffect = findEffect(id)
	if jEffect.PercenValue == 1 then
		return val / 100 .. "%"
	else
		return val
	end
end

function __this.getDesc(id, val, isSub)
	return __this.getName(id)..(isSub and " -" or " +")..__this.getValue(id, val)
end