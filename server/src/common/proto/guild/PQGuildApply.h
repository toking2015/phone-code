#ifndef _PQGuildApply_H_
#define _PQGuildApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请*/
class PQGuildApply : public SMsgHead
{
public:
    uint32 set_type;    //[kObjectAdd,kObjectDel]
    uint32 guild_id;

    PQGuildApply() : set_type(0), guild_id(0)
    {
        msg_cmd = 747175929;
    }

    virtual ~PQGuildApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildApply(*this) );
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
            && TFVarTypeProcess( guild_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGuildApply";
    }
};

#endif
