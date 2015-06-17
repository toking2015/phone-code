#ifndef _PRTombMopUp_H_
#define _PRTombMopUp_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

class PRTombMopUp : public SMsgHead
{
public:
    std::vector< std::vector< S3UInt32 > > reward_list;    //奖励

    PRTombMopUp()
    {
        msg_cmd = 1828509994;
    }

    virtual ~PRTombMopUp()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombMopUp(*this) );
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
            && TFVarTypeProcess( reward_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombMopUp";
    }
};

#endif
