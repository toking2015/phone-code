#ifndef _SFightOddSet_H_
#define _SFightOddSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightOdd.h>

/*BUFF SET*/
class SFightOddSet : public wd::CSeq
{
public:
    uint32 guid;    //角色ID
    uint8 set_type;    //kObjectDel, kObjectAdd, kObjectUpdate
    SFightOdd fightOdd;    //odd状态

    SFightOddSet() : guid(0), set_type(0)
    {
    }

    virtual ~SFightOddSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightOddSet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( fightOdd, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightOddSet";
    }
};

#endif
