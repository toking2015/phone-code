#ifndef _PQFightExtAbleList_H_
#define _PQFightExtAbleList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求好友列表*/
class PQFightExtAbleList : public SMsgHead
{
public:
    uint32 attr;    //武将

    PQFightExtAbleList() : attr(0)
    {
        msg_cmd = 1006064479;
    }

    virtual ~PQFightExtAbleList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightExtAbleList(*this) );
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
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFightExtAbleList";
    }
};

#endif
