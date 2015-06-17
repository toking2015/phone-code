#ifndef _PRTaskDayValRewardList_H_
#define _PRTaskDayValRewardList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*日常活动积分奖励列表*/
class PRTaskDayValRewardList : public SMsgHead
{
public:
    std::vector< uint32 > id_list;

    PRTaskDayValRewardList()
    {
        msg_cmd = 1705235466;
    }

    virtual ~PRTaskDayValRewardList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskDayValRewardList(*this) );
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
            && TFVarTypeProcess( id_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTaskDayValRewardList";
    }
};

#endif
