#ifndef _SUserInfo_H_
#define _SUserInfo_H_

#include <weedong/core/seq/seq.h>
/*用户基本信息结构*/
class SUserInfo : public wd::CSeq
{
public:
    uint32 online_time_all;    //上线总时间(秒)
    uint32 history_fight_value;    //历史最大战斗力

    SUserInfo() : online_time_all(0), history_fight_value(0)
    {
    }

    virtual ~SUserInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserInfo(*this) );
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
            && TFVarTypeProcess( online_time_all, eType, stream, uiSize )
            && TFVarTypeProcess( history_fight_value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserInfo";
    }
};

#endif
