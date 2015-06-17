#ifndef _PRSingleArenaRefresh_H_
#define _PRSingleArenaRefresh_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaOpponent.h>

class PRSingleArenaRefresh : public SMsgHead
{
public:
    std::vector< SSingleArenaOpponent > opponent_list;    //对手，固定四个

    PRSingleArenaRefresh()
    {
        msg_cmd = 1936653648;
    }

    virtual ~PRSingleArenaRefresh()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaRefresh(*this) );
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
            && TFVarTypeProcess( opponent_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaRefresh";
    }
};

#endif
