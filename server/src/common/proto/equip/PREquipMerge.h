#ifndef _PREquipMerge_H_
#define _PREquipMerge_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/item/SUserItem.h>

class PREquipMerge : public SMsgHead
{
public:
    SUserItem item;

    PREquipMerge()
    {
        msg_cmd = 1112608984;
    }

    virtual ~PREquipMerge()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PREquipMerge(*this) );
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
            && TFVarTypeProcess( item, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PREquipMerge";
    }
};

#endif
