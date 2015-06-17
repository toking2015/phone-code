#ifndef _CFight_H_
#define _CFight_H_

#include <weedong/core/seq/seq.h>
class CFight : public wd::CSeq
{
public:
    uint32 fight_id;    //战斗id
    uint32 round;    //回合
    uint32 fightType;
    uint32 winCamp;
    uint32 isAutoFight;

    CFight() : fight_id(0), round(0), fightType(0), winCamp(0), isAutoFight(0)
    {
    }

    virtual ~CFight()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CFight(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( fight_id, type, stream, uiSize )
            && TFVarTypeProcess( round, type, stream, uiSize )
            && TFVarTypeProcess( fightType, type, stream, uiSize )
            && TFVarTypeProcess( winCamp, type, stream, uiSize )
            && TFVarTypeProcess( isAutoFight, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "CFight";
    }
};

#endif
