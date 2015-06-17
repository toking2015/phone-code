#ifndef _PRCopyFightLog_H_
#define _PRCopyFightLog_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/copy/SCopyFightLog.h>

class PRCopyFightLog : public SMsgHead
{
public:
    std::map< uint32, std::vector< SCopyFightLog > > fightlog_list;    //战斗log

    PRCopyFightLog()
    {
        msg_cmd = 1224955052;
    }

    virtual ~PRCopyFightLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyFightLog(*this) );
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
        return "PRCopyFightLog";
    }
};

#endif
