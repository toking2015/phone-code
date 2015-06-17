#ifndef _PQCopyRefurbish_H_
#define _PQCopyRefurbish_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*刷新副本数据( 战斗属性更新等, 不影响已提交验证的事件 )*/
class PQCopyRefurbish : public SMsgHead
{
public:

    PQCopyRefurbish()
    {
        msg_cmd = 778525585;
    }

    virtual ~PQCopyRefurbish()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyRefurbish(*this) );
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
        return "PQCopyRefurbish";
    }
};

#endif
