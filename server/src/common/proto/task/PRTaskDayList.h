#ifndef _PRTaskDayList_H_
#define _PRTaskDayList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTaskDay.h>

/*返回日常任务记录列表*/
class PRTaskDayList : public SMsgHead
{
public:
    std::map< uint32, SUserTaskDay > data;

    PRTaskDayList()
    {
        msg_cmd = 1843551594;
    }

    virtual ~PRTaskDayList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskDayList(*this) );
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
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTaskDayList";
    }
};

#endif
