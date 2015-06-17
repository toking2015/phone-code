#ifndef _PRTaskSet_H_
#define _PRTaskSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/task/SUserTask.h>

class PRTaskSet : public SMsgHead
{
public:
    uint8 set_type;    //kObjectAdd, kObjectDel, kObjectUpdate
    SUserTask data;

    PRTaskSet() : set_type(0)
    {
        msg_cmd = 2040321963;
    }

    virtual ~PRTaskSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTaskSet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTaskSet";
    }
};

#endif
