#ifndef _PRActivitySet_H_
#define _PRActivitySet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityData.h>

class PRActivitySet : public SMsgHead
{
public:
    uint8 set_type;    //修改类型 kObjectAdd、kObjectDel、kObjectUpdate
    SActivityData activity;

    PRActivitySet() : set_type(0)
    {
        msg_cmd = 1829943689;
    }

    virtual ~PRActivitySet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRActivitySet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( activity, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRActivitySet";
    }
};

#endif
