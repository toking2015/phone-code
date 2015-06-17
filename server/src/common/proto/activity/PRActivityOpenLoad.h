#ifndef _PRActivityOpenLoad_H_
#define _PRActivityOpenLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityOpen.h>

class PRActivityOpenLoad : public SMsgHead
{
public:
    std::vector< SActivityOpen > list;

    PRActivityOpenLoad()
    {
        msg_cmd = 2080405480;
    }

    virtual ~PRActivityOpenLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityOpenLoad(*this) );
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
        return "PRActivityOpenLoad";
    }
};

#endif
