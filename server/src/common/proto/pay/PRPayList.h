#ifndef _PRPayList_H_
#define _PRPayList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/pay/SUserPay.h>

class PRPayList : public SMsgHead
{
public:
    std::vector< SUserPay > list;    //pay_list

    PRPayList()
    {
        msg_cmd = 1166471284;
    }

    virtual ~PRPayList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRPayList(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRPayList";
    }
};

#endif
