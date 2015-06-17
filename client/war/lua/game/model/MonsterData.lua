local __this = MonsterData or {}
MonsterData = __this

function __this.getAvatarUrl(jMonster)
	return string.format("image/icon/avatar/%s.png", jMonster.avatar)
end

function __this.getBodyUrl(jMonster)
	return string.format("image/body/%s.png", jMonster.avatar)
end

function __this.getPhotoUrl(jMonster)
	return string.format("image/photo/%s.png", jMonster.avatar)
end

function __this.getTalk(monsterId)
	local jTalk = findMonsterTalk(monsterId)
	return jTalk and jTalk.talk
end