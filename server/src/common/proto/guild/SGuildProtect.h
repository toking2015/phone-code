#ifndef _SGuildProtect_H_
#define _SGuildProtect_H_

#include <weedong/core/seq/seq.h>
class SGuildProtect : public wd::CSeq
{
public:
    uint32 lock_time;    //用于临时锁定用户可能产生冲突的操作, 例如: 创建公会, 角色改名等

    SGuildProtect() : lock_time(0)
    {
    }

    virtual ~SGuildProtect()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildProtect(*this) );
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
            && TFVarTypeProcess( lock_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildProtect";
    }
};

#endif
