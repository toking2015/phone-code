#ifndef _PRGuildMemberSet_H_
#define _PRGuildMemberSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/guild/SGuildMember.h>

/*成员数据更新*/
class PRGuildMemberSet : public SMsgHead
{
public:
    uint32 set_type;
    SGuildMember member;

    PRGuildMemberSet() : set_type(0)
    {
        msg_cmd = 1816172323;
    }

    virtual ~PRGuildMemberSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildMemberSet(*this) );
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
            && TFVarTypeProcess( member, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildMemberSet";
    }
};

#endif
