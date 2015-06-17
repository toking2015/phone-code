#ifndef _SCopyFightLog_H_
#define _SCopyFightLog_H_

#include <weedong/core/seq/seq.h>
/*副本战斗记录*/
class SCopyFightLog : public wd::CSeq
{
public:
    uint32 copy_id;    //副本id
    uint32 fight_id;    //战斗log
    uint32 ack_id;    //进攻者id
    uint32 ack_level;    //进攻者等级
    std::string ack_name;    //进攻者名字
    uint16 ack_avatar;    //进攻者头像
    uint32 log_time;    //战斗记录时间
    uint32 star;    //星级
    uint32 fight_value;    //战斗力

    SCopyFightLog() : copy_id(0), fight_id(0), ack_id(0), ack_level(0), ack_avatar(0), log_time(0), star(0), fight_value(0)
    {
    }

    virtual ~SCopyFightLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SCopyFightLog(*this) );
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
            && TFVarTypeProcess( copy_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( ack_id, eType, stream, uiSize )
            && TFVarTypeProcess( ack_level, eType, stream, uiSize )
            && TFVarTypeProcess( ack_name, eType, stream, uiSize )
            && TFVarTypeProcess( ack_avatar, eType, stream, uiSize )
            && TFVarTypeProcess( log_time, eType, stream, uiSize )
            && TFVarTypeProcess( star, eType, stream, uiSize )
            && TFVarTypeProcess( fight_value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SCopyFightLog";
    }
};

#endif
