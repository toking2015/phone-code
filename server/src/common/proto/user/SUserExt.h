#ifndef _SUserExt_H_
#define _SUserExt_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S4Int32.h>

/*用户扩展信息结构( 不保存至数据库,只用于服务器内部临时保存 )*/
class SUserExt : public wd::CSeq
{
public:
    uint32 role_id;    //玩家id
    uint32 session;    //session
    uint32 fight_id;    //战斗ID
    std::map< std::string, S4Int32 > check;    //用户数据一致性校验
    uint32 operate_time;    //最后操作时间( 以客户端发 PQSystemOnline 为准 )
    uint32 meet_time;    //最后访问时间
    uint32 save_time;    //最后保存时间
    uint32 trial_id;    //试炼ID
    uint32 trial_time;    //进入试炼的时间
    std::vector< uint32 > apply_guilds;    //已申请的公会

    SUserExt() : role_id(0), session(0), fight_id(0), operate_time(0), meet_time(0), save_time(0), trial_id(0), trial_time(0)
    {
    }

    virtual ~SUserExt()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserExt(*this) );
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
            && TFVarTypeProcess( role_id, eType, stream, uiSize )
            && TFVarTypeProcess( session, eType, stream, uiSize )
            && TFVarTypeProcess( fight_id, eType, stream, uiSize )
            && TFVarTypeProcess( check, eType, stream, uiSize )
            && TFVarTypeProcess( operate_time, eType, stream, uiSize )
            && TFVarTypeProcess( meet_time, eType, stream, uiSize )
            && TFVarTypeProcess( save_time, eType, stream, uiSize )
            && TFVarTypeProcess( trial_id, eType, stream, uiSize )
            && TFVarTypeProcess( trial_time, eType, stream, uiSize )
            && TFVarTypeProcess( apply_guilds, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserExt";
    }
};

#endif
