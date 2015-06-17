#ifndef _SUserProtect_H_
#define _SUserProtect_H_

#include <weedong/core/seq/seq.h>
/*用户保护性数据结构( 保存至服务器, 但绝不会发送给本用户以外的其它用户 )*/
class SUserProtect : public wd::CSeq
{
public:
    uint32 session;
    uint32 lock_time;    //用于临时锁定用户可能产生冲突的操作, 例如: 创建公会, 角色改名等

    SUserProtect() : session(0), lock_time(0)
    {
    }

    virtual ~SUserProtect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SUserProtect(*this) );
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
            && TFVarTypeProcess( session, eType, stream, uiSize )
            && TFVarTypeProcess( lock_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SUserProtect";
    }
};

#endif
