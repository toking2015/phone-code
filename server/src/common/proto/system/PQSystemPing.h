#ifndef _PQSystemPing_H_
#define _PQSystemPing_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*ping 包, 检测连接用*/
class PQSystemPing : public SMsgHead
{
public:

    PQSystemPing()
    {
        msg_cmd = 660488974;
    }

    virtual ~PQSystemPing()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQSystemPing(*this) );
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
        return "PQSystemPing";
    }
};

#endif
