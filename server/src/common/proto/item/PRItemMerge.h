#ifndef _PRItemMerge_H_
#define _PRItemMerge_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRItemMerge : public SMsgHead
{
public:
    uint32 id;    //物品合成的ID
    uint32 count;    //数量

    PRItemMerge() : id(0), count(0)
    {
        msg_cmd = 1847045381;
    }

    virtual ~PRItemMerge()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRItemMerge(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRItemMerge";
    }
};

#endif
