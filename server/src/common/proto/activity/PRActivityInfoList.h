#ifndef _PRActivityInfoList_H_
#define _PRActivityInfoList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityInfo.h>

class PRActivityInfoList : public SMsgHead
{
public:
    std::vector< SActivityInfo > list;

    PRActivityInfoList()
    {
        msg_cmd = 1390946469;
    }

    virtual ~PRActivityInfoList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityInfoList(*this) );
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
        return "PRActivityInfoList";
    }
};

#endif
