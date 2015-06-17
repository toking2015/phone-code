#ifndef _PRSingleArenaLogLoad_H_
#define _PRSingleArenaLogLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaLog.h>

class PRSingleArenaLogLoad : public SMsgHead
{
public:
    std::vector< SSingleArenaLog > list;

    PRSingleArenaLogLoad()
    {
        msg_cmd = 1482603583;
    }

    virtual ~PRSingleArenaLogLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaLogLoad(*this) );
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
        return "PRSingleArenaLogLoad";
    }
};

#endif
