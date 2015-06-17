#ifndef _SFightLog_H_
#define _SFightLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightOrder.h>
#include <proto/fight/SFightOrderTarget.h>

/*战斗记录*/
class SFightLog : public wd::CSeq
{
public:
    uint32 round;    //战斗回合
    SFightOrder order;    //战斗技能
    std::vector< SFightOrderTarget > orderTargetList;    //战斗结果

    SFightLog() : round(0)
    {
    }

    virtual ~SFightLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightLog(*this) );
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
            && TFVarTypeProcess( round, eType, stream, uiSize )
            && TFVarTypeProcess( order, eType, stream, uiSize )
            && TFVarTypeProcess( orderTargetList, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightLog";
    }
};

#endif
