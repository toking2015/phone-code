#ifndef _PQActivityList_H_
#define _PQActivityList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*活动接入--黄少卿*/
class PQActivityList : public SMsgHead
{
public:

    PQActivityList()
    {
        msg_cmd = 255414195;
    }

    virtual ~PQActivityList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivityList(*this) );
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
        return "PQActivityList";
    }
};

#endif
