#ifndef _PQFightErrorLog_H_
#define _PQFightErrorLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/SCompressData.h>

/*战斗错误记录*/
class PQFightErrorLog : public SMsgHead
{
public:
    SCompressData data;    //压缩战斗记录内容

    PQFightErrorLog()
    {
        msg_cmd = 448840913;
    }

    virtual ~PQFightErrorLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFightErrorLog(*this) );
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
        return "PQFightErrorLog";
    }
};

#endif
