#ifndef _PRActivityTakeReward_H_
#define _PRActivityTakeReward_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRActivityTakeReward : public SMsgHead
{
public:
    uint32 open_guid;
    uint32 index;    //第几个条件 从0开始

    PRActivityTakeReward() : open_guid(0), index(0)
    {
        msg_cmd = 1687101483;
    }

    virtual ~PRActivityTakeReward()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityTakeReward(*this) );
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
            && TFVarTypeProcess( open_guid, eType, stream, uiSize )
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRActivityTakeReward";
    }
};

#endif
