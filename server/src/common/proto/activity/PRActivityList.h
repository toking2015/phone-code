#ifndef _PRActivityList_H_
#define _PRActivityList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityOpen.h>
#include <proto/activity/SActivityData.h>
#include <proto/activity/SActivityFactor.h>
#include <proto/activity/SActivityReward.h>

class PRActivityList : public SMsgHead
{
public:
    std::vector< SActivityOpen > activity_open_list;
    std::vector< SActivityData > activity_data_list;
    std::vector< SActivityFactor > activity_factor_list;
    std::vector< SActivityReward > activity_reward_list;

    PRActivityList()
    {
        msg_cmd = 1239021585;
    }

    virtual ~PRActivityList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityList(*this) );
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
            && TFVarTypeProcess( activity_open_list, eType, stream, uiSize )
            && TFVarTypeProcess( activity_data_list, eType, stream, uiSize )
            && TFVarTypeProcess( activity_factor_list, eType, stream, uiSize )
            && TFVarTypeProcess( activity_reward_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRActivityList";
    }
};

#endif
