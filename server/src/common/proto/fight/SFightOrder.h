#ifndef _SFightOrder_H_
#define _SFightOrder_H_

#include <weedong/core/seq/seq.h>
/*使用的技能*/
class SFightOrder : public wd::CSeq
{
public:
    uint32 guid;    //角色ID                     //从10000开始有特殊的用途 10000表示设置自动
    uint32 order_id;    //技能ID
    uint16 order_level;    //等级  

    SFightOrder() : guid(0), order_id(0), order_level(0)
    {
    }

    virtual ~SFightOrder()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightOrder(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( order_id, eType, stream, uiSize )
            && TFVarTypeProcess( order_level, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightOrder";
    }
};

#endif
