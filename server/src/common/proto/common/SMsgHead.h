#ifndef _SMsgHead_H_
#define _SMsgHead_H_

#include <weedong/core/seq/seq.h>
/*协议包头*/
class SMsgHead : public wd::CSeq
{
public:
    uint32 msg_cmd;    //协议号
    uint32 role_id;    //角色ID
    uint32 session;    //登陆游戏sessionid
    uint32 order;    //协议包处理顺序
    uint32 action;    //用户行为号
    uint16 broad_cast;    //广播id
    uint16 broad_type;    //广播二级标识
    uint32 broad_id;    //广播三级标识

    SMsgHead() : msg_cmd(0)
    {
        role_id = 0;
        session = 0;
        order = 0;
        action = 0;
        broad_cast = 0;
        broad_type = 0;
        broad_id = 0;
    }

    virtual ~SMsgHead()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SMsgHead(*this) );
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
            && TFVarTypeProcess( msg_cmd, eType, stream, uiSize )
            && TFVarTypeProcess( role_id, eType, stream, uiSize )
            && TFVarTypeProcess( session, eType, stream, uiSize )
            && TFVarTypeProcess( order, eType, stream, uiSize )
            && TFVarTypeProcess( action, eType, stream, uiSize )
            && TFVarTypeProcess( broad_cast, eType, stream, uiSize )
            && TFVarTypeProcess( broad_type, eType, stream, uiSize )
            && TFVarTypeProcess( broad_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SMsgHead";
    }
};

#endif
