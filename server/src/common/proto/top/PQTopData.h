#ifndef _PQTopData_H_
#define _PQTopData_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@玩家排行相关数据获取*/
class PQTopData : public SMsgHead
{
public:

    PQTopData()
    {
        msg_cmd = 766459091;
    }

    virtual ~PQTopData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTopData(*this) );
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
        return "PQTopData";
    }
};

#endif
