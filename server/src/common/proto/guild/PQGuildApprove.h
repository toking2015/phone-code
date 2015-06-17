#ifndef _PQGuildApprove_H_
#define _PQGuildApprove_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*审批*/
class PQGuildApprove : public SMsgHead
{
public:
    uint32 target_id;
    int8 is_accept;

    PQGuildApprove() : target_id(0), is_accept(0)
    {
        msg_cmd = 148826004;
    }

    virtual ~PQGuildApprove()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildApprove(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( is_accept, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGuildApprove";
    }
};

#endif
