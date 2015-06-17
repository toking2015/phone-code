#ifndef _PRCopyFightLogLoad_H_
#define _PRCopyFightLogLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/copy/SCopyFightLog.h>

class PRCopyFightLogLoad : public SMsgHead
{
public:
    uint32 copy_id;
    std::vector< SCopyFightLog > list;

    PRCopyFightLogLoad() : copy_id(0)
    {
        msg_cmd = 2002119907;
    }

    virtual ~PRCopyFightLogLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRCopyFightLogLoad(*this) );
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
            && TFVarTypeProcess( copy_id, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRCopyFightLogLoad";
    }
};

#endif
