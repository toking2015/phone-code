#ifndef _PRTaskList_H_
#define _PRTaskList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTask.h>

class PRTaskList : public SMsgHead
{
public:
    std::map< uint32, SUserTask > list;

    PRTaskList()
    {
        msg_cmd = 1480421482;
    }

    virtual ~PRTaskList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskList(*this) );
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
        return "PRTaskList";
    }
};

#endif
