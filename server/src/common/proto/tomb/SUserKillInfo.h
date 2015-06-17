#ifndef _SUserKillInfo_H_
#define _SUserKillInfo_H_

#include <weedong/core/seq/seq.h>
class SUserKillInfo : public wd::CSeq
{
public:
    uint32 monster_id;    //怪物id
    uint32 count;    //次数

    SUserKillInfo() : monster_id(0), count(0)
    {
    }

    virtual ~SUserKillInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserKillInfo(*this) );
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
            && TFVarTypeProcess( monster_id, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserKillInfo";
    }
};

#endif
