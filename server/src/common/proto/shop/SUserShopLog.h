#ifndef _SUserShopLog_H_
#define _SUserShopLog_H_

#include <weedong/core/seq/seq.h>
/*购买记录*/
class SUserShopLog : public wd::CSeq
{
public:
    uint32 id;    //商品id
    uint32 daily_count;    //本日购买数量
    uint32 history_count;    //历史购买数量

    SUserShopLog() : id(0), daily_count(0), history_count(0)
    {
    }

    virtual ~SUserShopLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserShopLog(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( daily_count, eType, stream, uiSize )
            && TFVarTypeProcess( history_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserShopLog";
    }
};

#endif
