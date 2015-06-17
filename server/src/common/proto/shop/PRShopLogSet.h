#ifndef _PRShopLogSet_H_
#define _PRShopLogSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/shop/SUserShopLog.h>

/*购买记录（单独更新）*/
class PRShopLogSet : public SMsgHead
{
public:
    SUserShopLog log;

    PRShopLogSet()
    {
        msg_cmd = 1510374863;
    }

    virtual ~PRShopLogSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRShopLogSet(*this) );
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
            && TFVarTypeProcess( log, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRShopLogSet";
    }
};

#endif
