#ifndef _SUserItem_H_
#define _SUserItem_H_

#include <weedong/core/seq/seq.h>
#include <proto/item/SWildItem.h>

/*玩家物品*/
class SUserItem : public SWildItem
{
public:
    uint32 guid;    //惟一标识
    uint16 item_index;    //索引
    uint16 soldier_guid;    //武将GUID, 0为角色
    uint8 bag_type;    //所处背包类型

    SUserItem() : guid(0), item_index(0), soldier_guid(0), bag_type(0)
    {
    }

    virtual ~SUserItem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserItem(*this) );
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
        return SWildItem::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( item_index, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_guid, eType, stream, uiSize )
            && TFVarTypeProcess( bag_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserItem";
    }
};

#endif
