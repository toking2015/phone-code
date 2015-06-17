#ifndef _PQActivityInfoList_H_
#define _PQActivityInfoList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*进行中的活动*/
class PQActivityInfoList : public SMsgHead
{
public:

    PQActivityInfoList()
    {
        msg_cmd = 707651935;
    }

    virtual ~PQActivityInfoList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityInfoList(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivityInfoList";
    }
};

#endif
