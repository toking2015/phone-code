#ifndef _PRGuildSimpleList_H_
#define _PRGuildSimpleList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/guild/SGuildSimple.h>

class PRGuildSimpleList : public SMsgHead
{
public:
    std::vector< SGuildSimple > list;    //公会基本信息列表数据

    PRGuildSimpleList()
    {
        msg_cmd = 1305794030;
    }

    virtual ~PRGuildSimpleList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildSimpleList(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildSimpleList";
    }
};

#endif
