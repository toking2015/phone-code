#ifndef _CFightData_H_
#define _CFightData_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightPlayerInfo.h>
#include <proto/fight/SFightSoldier.h>
#include <proto/fight/SFightOrder.h>
#include <proto/common/SInteger.h>
#include <proto/fight/SFightEndInfo.h>

class CFightData : public wd::CSeq
{
public:
    uint32 fight_id;    //战斗id
    uint32 round;    //回合
    uint32 fightType;
    uint32 winCamp;
    uint32 isAutoFight;
    uint32 disillusionIndex;    //觉醒的位置
    std::map< uint32, SFightPlayerInfo > userList;
    std::vector< SFightSoldier > soldierList;
    std::vector< SFightSoldier > soldierAttackList;
    uint32 soldierAttackListIndex;
    std::vector< SFightOrder > orderList;
    std::vector< SFightSoldier > soldierEndList;
    SInteger fightSeed;
    std::map< uint32, SFightEndInfo > fightEndInfo;    //战斗结束的信息

    CFightData() : fight_id(0), round(0), fightType(0), winCamp(0), isAutoFight(0), disillusionIndex(0), soldierAttackListIndex(0)
    {
    }

    virtual ~CFightData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CFightData(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, wd::CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType eType, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( round, eType, stream, uiSize )
            && TFVarTypeProcess( fightType, eType, stream, uiSize )
            && TFVarTypeProcess( winCamp, eType, stream, uiSize )
            && TFVarTypeProcess( isAutoFight, eType, stream, uiSize )
            && TFVarTypeProcess( disillusionIndex, eType, stream, uiSize )
            && TFVarTypeProcess( userList, eType, stream, uiSize )
            && TFVarTypeProcess( soldierList, eType, stream, uiSize )
            && TFVarTypeProcess( soldierAttackList, eType, stream, uiSize )
            && TFVarTypeProcess( soldierAttackListIndex, eType, stream, uiSize )
            && TFVarTypeProcess( orderList, eType, stream, uiSize )
            && TFVarTypeProcess( soldierEndList, eType, stream, uiSize )
            && TFVarTypeProcess( fightSeed, eType, stream, uiSize )
            && TFVarTypeProcess( fightEndInfo, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CFightData";
    }
};

#endif
