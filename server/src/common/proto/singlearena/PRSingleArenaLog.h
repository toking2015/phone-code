#ifndef _PRSingleArenaLog_H_
#define _PRSingleArenaLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/singlearena/SSingleArenaLog.h>

class PRSingleArenaLog : public SMsgHead
{
public:
    std::vector< SSingleArenaLog > fightlog_list;    //战斗log

    PRSingleArenaLog()
    {
        msg_cmd = 1355019612;
    }

    virtual ~PRSingleArenaLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaLog(*this) );
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
            && TFVarTypeProcess( fightlog_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaLog";
    }
};

#endif
