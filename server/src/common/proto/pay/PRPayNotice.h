#ifndef _PRPayNotice_H_
#define _PRPayNotice_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*充值通知( 仅通知 )*/
class PRPayNotice : public SMsgHead
{
public:
    uint32 uid;    //唯一id
    uint32 coin;    //充值的RMB

    PRPayNotice() : uid(0), coin(0)
    {
        msg_cmd = 1722629611;
    }

    virtual ~PRPayNotice()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPayNotice(*this) );
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
            && TFVarTypeProcess( uid, eType, stream, uiSize )
            && TFVarTypeProcess( coin, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPayNotice";
    }
};

#endif
