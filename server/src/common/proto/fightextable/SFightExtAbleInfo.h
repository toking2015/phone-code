#ifndef _SFightExtAbleInfo_H_
#define _SFightExtAbleInfo_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightExtAble.h>

/*二级属性-印佳*/
class SFightExtAbleInfo : public wd::CSeq
{
public:
    uint32 guid;    //guid
    uint32 attr;    //玩家
    SFightExtAble able;    //二级属性 

    SFightExtAbleInfo() : guid(0), attr(0)
    {
    }

    virtual ~SFightExtAbleInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightExtAbleInfo(*this) );
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
        return wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( attr, eType, stream, uiSize )
            && TFVarTypeProcess( able, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightExtAbleInfo";
    }
};

#endif
