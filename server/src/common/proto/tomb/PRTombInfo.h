#ifndef _PRTombInfo_H_
#define _PRTombInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/tomb/SUserTomb.h>

class PRTombInfo : public SMsgHead
{
public:
    SUserTomb info;    //info 

    PRTombInfo()
    {
        msg_cmd = 1945453920;
    }

    virtual ~PRTombInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombInfo(*this) );
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
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombInfo";
    }
};

#endif
