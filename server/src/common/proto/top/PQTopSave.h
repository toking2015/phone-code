#ifndef _PQTopSave_H_
#define _PQTopSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/top/SUserTop.h>

/*##玩家排行相关数据保存*/
class PQTopSave : public SMsgHead
{
public:
    SUserTop top_data;

    PQTopSave()
    {
        msg_cmd = 195577959;
    }

    virtual ~PQTopSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTopSave(*this) );
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
            && TFVarTypeProcess( top_data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTopSave";
    }
};

#endif
