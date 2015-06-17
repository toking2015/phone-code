#ifndef _PRTrialRewardList_H_
#define _PRTrialRewardList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/trial/SUserTrialReward.h>

class PRTrialRewardList : public SMsgHead
{
public:
    uint32 id;    //试炼ID
    std::vector< SUserTrialReward > reward_list;

    PRTrialRewardList() : id(0)
    {
        msg_cmd = 1679379448;
    }

    virtual ~PRTrialRewardList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTrialRewardList(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( reward_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTrialRewardList";
    }
};

#endif
