#ifndef _SUserVipTimeLimitGoods_H_
#define _SUserVipTimeLimitGoods_H_

#include <weedong/core/seq/seq.h>
/*vip限时商店-黄少杰*/
class SUserVipTimeLimitGoods : public wd::CSeq
{
public:
    uint32 vip_package_id;    //礼包等级
    uint32 buyed_count;    //购买数量
    uint32 next_buy_time;    //下次可以购买的时间

    SUserVipTimeLimitGoods() : vip_package_id(0), buyed_count(0), next_buy_time(0)
    {
    }

    virtual ~SUserVipTimeLimitGoods()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserVipTimeLimitGoods(*this) );
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
            && TFVarTypeProcess( vip_package_id, eType, stream, uiSize )
            && TFVarTypeProcess( buyed_count, eType, stream, uiSize )
            && TFVarTypeProcess( next_buy_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserVipTimeLimitGoods";
    }
};

#endif
