#ifndef _SSingleArenaLog_H_
#define _SSingleArenaLog_H_

#include <weedong/core/seq/seq.h>
class SSingleArenaLog : public wd::CSeq
{
public:
    uint32 target_id;    //拥有者role_id <因为要保存到DB>
    uint32 fight_id;    //战斗log
    uint32 ack_id;    //进攻者id
    uint32 def_id;    //防御者id
    uint32 ack_level;    //进攻者等级
    uint32 def_level;    //防御者等级
    std::string ack_name;    //进攻者名字
    uint16 ack_avatar;    //进攻者头像
    std::string def_name;    //防御者名字
    uint16 def_avatar;    //防御者头像
    uint32 win_flag;    //1,进攻者羸 2，反之
    uint32 log_time;    //战斗记录时间
    int32 rank_num;    //名次的变动

    SSingleArenaLog() : target_id(0), fight_id(0), ack_id(0), def_id(0), ack_level(0), def_level(0), ack_avatar(0), def_avatar(0), win_flag(0), log_time(0), rank_num(0)
    {
    }

    virtual ~SSingleArenaLog()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSingleArenaLog(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( ack_id, eType, stream, uiSize )
            && TFVarTypeProcess( def_id, eType, stream, uiSize )
            && TFVarTypeProcess( ack_level, eType, stream, uiSize )
            && TFVarTypeProcess( def_level, eType, stream, uiSize )
            && TFVarTypeProcess( ack_name, eType, stream, uiSize )
            && TFVarTypeProcess( ack_avatar, eType, stream, uiSize )
            && TFVarTypeProcess( def_name, eType, stream, uiSize )
            && TFVarTypeProcess( def_avatar, eType, stream, uiSize )
            && TFVarTypeProcess( win_flag, eType, stream, uiSize )
            && TFVarTypeProcess( log_time, eType, stream, uiSize )
            && TFVarTypeProcess( rank_num, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSingleArenaLog";
    }
};

#endif
