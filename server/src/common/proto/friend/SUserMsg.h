#ifndef _SUserMsg_H_
#define _SUserMsg_H_

#include <weedong/core/seq/seq.h>
/*好友离线消息*/
class SUserMsg : public wd::CSeq
{
public:
    uint32 friend_id;    //好友角色id
    uint32 send_time;    //发送时间
    uint8 purview;    //用户权限
    std::string msg;    //离线消息正文

    SUserMsg() : friend_id(0), send_time(0), purview(0)
    {
    }

    virtual ~SUserMsg()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserMsg(*this) );
    }

    virtual bool write( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eWrite, uiSize ) &&
            loopend( stream, CSeq::eWrite, uiSize );
    }
    virtual bool read( wd::CStream &stream )
    {
        uint32 uiSize = 0;
        return loop( stream, CSeq::eRead, uiSize );
    }

    bool loop( wd::CStream &stream, CSeq::ELoopType type, uint32& uiSize )
    {
        return wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( friend_id, type, stream, uiSize )
            && TFVarTypeProcess( send_time, type, stream, uiSize )
            && TFVarTypeProcess( purview, type, stream, uiSize )
            && TFVarTypeProcess( msg, type, stream, uiSize );
    }
};

#endif
