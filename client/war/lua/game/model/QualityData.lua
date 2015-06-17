QualityData = QualityData or {}

--0xffffff, 0x66ff00, 0x00c6ff, 0xfc00ff, 0xfa800a
local DATA = {
	[const.kFalse] = {"白色", cc.c3b(0xff, 0xff, 0xff), cc.c4b(0xff, 0xff, 0xff, 0xff),0},
	[const.kQualityWhite] = {"白色", cc.c3b(0xff, 0xff, 0xff), cc.c4b(0xff, 0xff, 0xff, 0xff),0},
	[const.kQualityGreen] = {"绿色", cc.c3b(0x54, 0xff, 0x00), cc.c3b(0x54, 0xff, 0x00, 0xff),2},
	[const.kQualityBlue] = {"蓝色", cc.c3b(0x53, 0xe9, 0xff), cc.c3b(0x53, 0xe9, 0xff, 0xff),3},
	[const.kQualityPurple] = {"紫色", cc.c3b(0xc6, 0x4c, 0xff), cc.c3b(0xc6, 0x4c, 0xff, 0xff),3},
	[const.kQualityOrange] = {"橙色", cc.c3b(0xff, 0x8a, 0x00), cc.c3b(0xff, 0x8a, 0x00, 0xff),4}
}
        
function QualityData.getName(quality)
	return DATA[quality][1]
end

function QualityData.getColor(quality)
	return DATA[quality][2]
end

function QualityData.getC4B(quality)
	return DATA[quality][3]
end

--最大属性个数
function QualityData.getMaxArr(quality)
	return DATA[quality][4]
end