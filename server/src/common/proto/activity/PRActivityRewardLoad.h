#ifndef _PRActivityRewardLoad_H_
#define _PRActivityRewardLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityReward.h>

class PRActivityRewardLoad : public SMsgHead
{
public:
    std::vector< SActivityReward > list;

    PRActivityRewardLoad()
    {
        msg_cmd = 1427341341;
    }

    virtual ~PRActivityRewardLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityRewardLoad(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRActivityRewardLoad";
    }
};

#endif
