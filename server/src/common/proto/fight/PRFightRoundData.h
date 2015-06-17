#ifndef _PRFightRoundData_H_
#define _PRFightRoundData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/fight/SFightLog.h>

/*战斗技能返回*/
class PRFightRoundData : public SMsgHead
{
public:
    uint32 fight_id;
    std::vector< SFightLog > fightlog;    //技能战斗结果 

    PRFightRoundData() : fight_id(0)
    {
        msg_cmd = 2083684729;
    }

    virtual ~PRFightRoundData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFightRoundData(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( fightlog, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRFightRoundData";
    }
};

#endif
