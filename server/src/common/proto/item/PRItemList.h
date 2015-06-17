#ifndef _PRItemList_H_
#define _PRItemList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/item/SUserItem.h>

/*返回物品列表*/
class PRItemList : public SMsgHead
{
public:
    uint32 bag_index;    //所处背包类型
    std::vector< SUserItem > item_list;    //好友列表

    PRItemList() : bag_index(0)
    {
        msg_cmd = 1822834778;
    }

    virtual ~PRItemList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRItemList(*this) );
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
            && TFVarTypeProcess( bag_index, eType, stream, uiSize )
            && TFVarTypeProcess( item_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRItemList";
    }
};

#endif
