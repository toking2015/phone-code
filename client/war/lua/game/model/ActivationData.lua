ActivationData = {}
ActivationData.ERR_INEXIST="ERR_INEXIST" --不存在
ActivationData.ERR_USED="ERR_USED" -- 已使用
ActivationData.actcoad = ""

function ActivationData.ShowWin( ... )
	Command.run( 'ui show', "ActivationUI", PopUpType.SPECIAL )
end

function ActivationData.ShowErr( coad )
	ActivationData.CurErr = coad
	Command.run( 'ui show', "ActivationUI", PopUpType.SPECIAL )
	--ActivationUI:updateData()
end

--EventMgr.addListener(EventType.FirstEnterScene, ActivationData.ShowWin)