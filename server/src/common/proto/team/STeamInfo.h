#ifndef _STeamInfo_H_
#define _STeamInfo_H_

#include <weedong/core/seq/seq.h>
/*==========================通迅结构==========================*/
class STeamInfo : public wd::CSeq
{
public:
    uint32 can_change_name;    //是否可以改名
    uint32 change_name_count;    //改名的次数

    STeamInfo() : can_change_name(0), change_name_count(0)
    {
    }

    virtual ~STeamInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new STeamInfo(*this) );
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
            && TFVarTypeProcess( can_change_name, eType, stream, uiSize )
            && TFVarTypeProcess( change_name_count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "STeamInfo";
    }
};

#endif
