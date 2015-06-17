#ifndef _PQMarketCustomBuyList_H_
#define _PQMarketCustomBuyList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@自定义请求拍卖行购买数据, 返回 PRMarketBuyList*/
class PQMarketCustomBuyList : public SMsgHead
{
public:
    uint32 sid;    //服务器标识(仅服务器处理)
    uint8 equip;    //YY甲类型 kEquipYYY
    uint16 level;    //T1, T2 ... Tx 对应的等级( 20, 35, 50, 65, 80, 95, 110, 125, 140, 155 )

    PQMarketCustomBuyList() : sid(0), equip(0), level(0)
    {
        msg_cmd = 11023047;
    }

    virtual ~PQMarketCustomBuyList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQMarketCustomBuyList(*this) );
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
            && TFVarTypeProcess( sid, eType, stream, uiSize )
            && TFVarTypeProcess( equip, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQMarketCustomBuyList";
    }
};

#endif
