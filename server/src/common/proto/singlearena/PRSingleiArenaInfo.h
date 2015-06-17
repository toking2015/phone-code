#ifndef _PRSingleiArenaInfo_H_
#define _PRSingleiArenaInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaInfo.h>

class PRSingleiArenaInfo : public SMsgHead
{
public:
    SSingleArenaInfo info;

    PRSingleiArenaInfo()
    {
        msg_cmd = 1176021520;
    }

    virtual ~PRSingleiArenaInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleiArenaInfo(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( info, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleiArenaInfo";
    }
};

#endif
