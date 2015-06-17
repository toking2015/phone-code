#ifndef _PRItemSet_H_
#define _PRItemSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/item/SUserItem.h>

class PRItemSet : public SMsgHead
{
public:
    uint8 set_type;    //修改类型 kObjectAdd、kObjectDel、kObjectUpdate
    uint32 path;    //修改系统
    SUserItem item;

    PRItemSet() : set_type(0), path(0)
    {
        msg_cmd = 1778612727;
    }

    virtual ~PRItemSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRItemSet(*this) );
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
            && TFVarTypeProcess( item, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRItemSet";
    }
};

#endif
