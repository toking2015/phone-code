#ifndef _PQGuildPost_H_
#define _PQGuildPost_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*公告*/
class PQGuildPost : public SMsgHead
{
public:
    std::string content;

    PQGuildPost()
    {
        msg_cmd = 573031854;
    }

    virtual ~PQGuildPost()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildPost(*this) );
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
            && TFVarTypeProcess( content, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGuildPost";
    }
};

#endif
