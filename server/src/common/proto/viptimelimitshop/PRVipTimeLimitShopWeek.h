#ifndef _PRVipTimeLimitShopWeek_H_
#define _PRVipTimeLimitShopWeek_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/viptimelimitshop/SUserVipTimeLimitGoods.h>

/*@@返回商品列表*/
class PRVipTimeLimitShopWeek : public SMsgHead
{
public:
    uint32 now_week;    //当前周数
    std::vector< SUserVipTimeLimitGoods > buyed_list;    //购买记录
    uint32 next_refresh_time;    //下次可以购买的时间

    PRVipTimeLimitShopWeek() : now_week(0), next_refresh_time(0)
    {
        msg_cmd = 1223021540;
    }

    virtual ~PRVipTimeLimitShopWeek()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRVipTimeLimitShopWeek(*this) );
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
            && TFVarTypeProcess( now_week, eType, stream, uiSize )
            && TFVarTypeProcess( buyed_list, eType, stream, uiSize )
            && TFVarTypeProcess( next_refresh_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRVipTimeLimitShopWeek";
    }
};

#endif
