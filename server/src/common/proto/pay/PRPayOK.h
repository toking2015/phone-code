#ifndef _PRPayOK_H_
#define _PRPayOK_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRPayOK : public SMsgHead
{
public:
    uint32 coin;    //充值的RMB

    PRPayOK() : coin(0)
    {
        msg_cmd = 1398201345;
    }

    virtual ~PRPayOK()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPayOK(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( coin, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PRPayOK";
    }
};

#endif
