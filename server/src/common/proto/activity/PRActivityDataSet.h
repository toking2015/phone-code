#ifndef _PRActivityDataSet_H_
#define _PRActivityDataSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityData.h>

class PRActivityDataSet : public SMsgHead
{
public:
    uint32 type;    //kObjectAdd
    SActivityData data;

    PRActivityDataSet() : type(0)
    {
        msg_cmd = 1958687693;
    }

    virtual ~PRActivityDataSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivityDataSet(*this) );
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
            && TFVarTypeProcess( type, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRActivityDataSet";
    }
};

#endif
