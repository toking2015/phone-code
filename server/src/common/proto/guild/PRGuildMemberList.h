#ifndef _PRGuildMemberList_H_
#define _PRGuildMemberList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/guild/SGuildMember.h>

class PRGuildMemberList : public SMsgHead
{
public:
    std::vector< SGuildMember > list;

    PRGuildMemberList()
    {
        msg_cmd = 1797061462;
    }

    virtual ~PRGuildMemberList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildMemberList(*this) );
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
        return "PRGuildMemberList";
    }
};

#endif
