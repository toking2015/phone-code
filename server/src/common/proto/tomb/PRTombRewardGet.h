#ifndef _PRTombRewardGet_H_
#define _PRTombRewardGet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/tomb/STombTarget.h>
#include <proto/common/S3UInt32.h>

class PRTombRewardGet : public SMsgHead
{
public:
    STombTarget target;    //领取信息 
    std::vector< S3UInt32 > reward_list;    //奖励

    PRTombRewardGet()
    {
        msg_cmd = 1318917084;
    }

    virtual ~PRTombRewardGet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombRewardGet(*this) );
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
            && TFVarTypeProcess( target, eType, stream, uiSize )
            && TFVarTypeProcess( reward_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombRewardGet";
    }
};

#endif
