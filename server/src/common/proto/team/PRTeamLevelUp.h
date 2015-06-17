#ifndef _PRTeamLevelUp_H_
#define _PRTeamLevelUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTeamLevelUp : public SMsgHead
{
public:
    uint16 old_strength;    //旧体力
    uint16 old_level;    //旧等级
    uint16 new_level;    //新等级

    PRTeamLevelUp() : old_strength(0), old_level(0), new_level(0)
    {
        msg_cmd = 1901312684;
    }

    virtual ~PRTeamLevelUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTeamLevelUp(*this) );
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
            && TFVarTypeProcess( old_strength, eType, stream, uiSize )
            && TFVarTypeProcess( old_level, eType, stream, uiSize )
            && TFVarTypeProcess( new_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTeamLevelUp";
    }
};

#endif
