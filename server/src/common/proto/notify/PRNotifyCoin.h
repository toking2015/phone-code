#ifndef _PRNotifyCoin_H_
#define _PRNotifyCoin_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*货币修改通知( 仅通知, 数据修改在其它模板协议返回 )*/
class PRNotifyCoin : public SMsgHead
{
public:
    uint8 set_type;    //kObjectAdd, kObjectDel
    uint32 path;    //kPathXXX
    std::vector< S3UInt32 > coins;    //{ cate = kCoinTypeXXX, objid = 扩展id( 可能物品需要 ), val = 操作数 }

    PRNotifyCoin() : set_type(0), path(0)
    {
        msg_cmd = 1746730510;
    }

    virtual ~PRNotifyCoin()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRNotifyCoin(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( path, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRNotifyCoin";
    }
};

#endif
