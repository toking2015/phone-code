#ifndef _PRTakeHaohuaReward_H_
#define _PRTakeHaohuaReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRTakeHaohuaReward : public SMsgHead
{
public:

    PRTakeHaohuaReward()
    {
        msg_cmd = 2024857271;
    }

    virtual ~PRTakeHaohuaReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTakeHaohuaReward(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTakeHaohuaReward";
    }
};

#endif
