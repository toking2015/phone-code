#ifndef _PRTombTargetList_H_
#define _PRTombTargetList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/tomb/STombTarget.h>

class PRTombTargetList : public SMsgHead
{
public:
    std::vector< STombTarget > tomb_target_list;    //对战信息

    PRTombTargetList()
    {
        msg_cmd = 1420666319;
    }

    virtual ~PRTombTargetList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRTombTargetList(*this) );
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
            && TFVarTypeProcess( tomb_target_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRTombTargetList";
    }
};

#endif
