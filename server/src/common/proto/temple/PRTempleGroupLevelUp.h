#ifndef _PRTempleGroupLevelUp_H_
#define _PRTempleGroupLevelUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/temple/STempleGroup.h>

class PRTempleGroupLevelUp : public SMsgHead
{
public:
    STempleGroup group;

    PRTempleGroupLevelUp()
    {
        msg_cmd = 1805247991;
    }

    virtual ~PRTempleGroupLevelUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTempleGroupLevelUp(*this) );
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
            && TFVarTypeProcess( group, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTempleGroupLevelUp";
    }
};

#endif
