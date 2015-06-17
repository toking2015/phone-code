#ifndef _PRTaskLogList_H_
#define _PRTaskLogList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTaskLog.h>

class PRTaskLogList : public SMsgHead
{
public:
    std::map< uint32, SUserTaskLog > list;

    PRTaskLogList()
    {
        msg_cmd = 1234819902;
    }

    virtual ~PRTaskLogList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskLogList(*this) );
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
        return "PRTaskLogList";
    }
};

#endif
