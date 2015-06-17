#ifndef _SWildItem_H_
#define _SWildItem_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S2UInt16.h>

/*物品-印佳*/
class SWildItem : public wd::CSeq
{
public:
    uint32 item_id;    //物品ID
    uint8 firm_level;    //强化级别
    uint32 count;    //数量
    uint32 due_time;    //过期时间
    uint32 main_attr_factor;    //主属性品质系数
    uint32 slave_attr_factor;    //副属性品质系数
    std::vector< uint16 > slave_attrs;    //装备副属性索引
    std::vector< S2UInt16 > slotattr;    //插槽属性first:物品ID;second:插槽属性ID
    uint8 flags;    //位移属性

    SWildItem() : item_id(0), firm_level(0), count(0), due_time(0), main_attr_factor(0), slave_attr_factor(0), flags(0)
    {
    }

    virtual ~SWildItem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SWildItem(*this) );
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
            && TFVarTypeProcess( item_id, eType, stream, uiSize )
            && TFVarTypeProcess( firm_level, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && TFVarTypeProcess( due_time, eType, stream, uiSize )
            && TFVarTypeProcess( main_attr_factor, eType, stream, uiSize )
            && TFVarTypeProcess( slave_attr_factor, eType, stream, uiSize )
            && TFVarTypeProcess( slave_attrs, eType, stream, uiSize )
            && TFVarTypeProcess( slotattr, eType, stream, uiSize )
            && TFVarTypeProcess( flags, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SWildItem";
    }
};

#endif
