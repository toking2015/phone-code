local const = trans.const
local err = trans.err
local base = trans.base



-- ==========================閫氳繀缁撴瀯==========================
base.reg( 'SLocalData', nil,
    {
        { 'data', 'string' },
    }
)

base.reg( 'SFightClientSkillObject', nil,
    {
        { 'time', 'uint32' },
        { 'totem_time', 'uint32' },
        { 'skill_object', 'SFightSkillObject' },
    }
)

base.reg( 'SFightClientRoundData', nil,
    {
        { 'time', 'uint32' },
        { 'totem_time', 'uint32' },
        { 'log_list', { 'array', 'SFightLog' } },
    }
)

base.reg( 'SFightClientSeed', nil,
    {
        { 'value', 'uint32' },
    }
)

base.reg( 'SFightClientLog', nil,
    {
        { 'fight_id', 'uint32' },
        { 'fight_type', 'uint32' },
        { 'fight_randomseed', 'SFightClientSeed' },
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },
        { 'round_soldier', { 'array', 'SFightClientSkillObject' } },
        { 'round_data_list', { 'array', 'SFightClientRoundData' } },
        { 'totem_skill_list', { 'array', 'SFightClientRoundData' } },
    }
)

base.reg( 'SEffectSound', nil,
    {
        { 'attr', 'uint8' },
        { 'time', 'int16' },
        { 'sound', 'string' },
    }
)

base.reg( 'STimeShaftSound', nil,
    {
        { 'flag', 'string' },
        { 'effectIndex', 'uint8' },
        { 'list', { 'array', 'SEffectSound' } },
    }
)

base.reg( 'SBodySound', nil,
    {
        { 'style', 'string' },
        { 'soundList', { 'array', 'SEffectSound' } },
        { 'dataList', { 'array', 'STimeShaftSound' } },
    }
)

base.reg( 'SSoundData', nil,
    {
        { 'list', { 'array', 'SBodySound' } },
    }
)

base.reg( 'SPhoneActionEffect', nil,
    {
        { 'index', 'uint8' },
        { 'ackEffect', 'string' },
        { 'fireEffect', 'string' },
        { 'targetEffect', 'string' },
        { 'timeShaftDataList', { 'array', 'int16' } },
    }
)

base.reg( 'SPhoneAction', nil,
    {
        { 'flag', 'string' },
        { 'frame', 'uint16' },
        { 'count', 'uint8' },
        { 'targetFocusX', 'int16' },
        { 'attribute', 'uint8' },
        { 'play', 'uint8' },
        { 'line', 'uint8' },
        { 'listEffect', { 'array', 'SPhoneActionEffect' } },
    }
)

base.reg( 'SPhoneBody', nil,
    {
        { 'style', 'string' },
        { 'headX', 'int16' },
        { 'headY', 'int16' },
        { 'bodyX', 'int16' },
        { 'bodyY', 'int16' },
        { 'footX', 'int16' },
        { 'footY', 'int16' },
        { 'scale', 'int16' },
        { 'list', { 'array', 'SPhoneAction' } },
    }
)

base.reg( 'SPhoneData', nil,
    {
        { 'list', { 'array', 'SPhoneBody' } },
    }
)

base.reg( 'SEffectItem', nil,
    {
        { 'flag', 'string' },
        { 'layer', 'uint8' },
        { 'count', 'uint8' },
        { 'coordX', 'int16' },
        { 'coordY', 'int16' },
        { 'focusX', 'int16' },
        { 'mirror', 'int8' },
        { 'binding', 'string' },
        { 'scale', 'int16' },
    }
)

base.reg( 'SEffect', nil,
    {
        { 'style', 'string' },
        { 'scale', 'int16' },
        { 'list', { 'array', 'SEffectItem' } },
    }
)

base.reg( 'SEffectData', nil,
    {
        { 'DataList', { 'array', 'SEffect' } },
    }
)


