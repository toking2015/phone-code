#ifndef _SGuildExt_H_
#define _SGuildExt_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/S4Int32.h>

/*公会扩展信息结构( 不保存至数据库,只用于服务器内部临时保存 )*/
class SGuildExt : public wd::CSeq
{
public:
    std::map< std::string, S4Int32 > check;    //公会数据一致性校验
    uint32 operate_time;    //最后操作时间
    uint32 meet_time;    //最后访问时间
    uint32 save_time;    //最后保存时间
    std::vector< uint32 > apply_users;    //申请人列表

    SGuildExt() : operate_time(0), meet_time(0), save_time(0)
    {
    }

    virtual ~SGuildExt()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildExt(*this) );
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
            && TFVarTypeProcess( check, eType, stream, uiSize )
            && TFVarTypeProcess( operate_time, eType, stream, uiSize )
            && TFVarTypeProcess( meet_time, eType, stream, uiSize )
            && TFVarTypeProcess( save_time, eType, stream, uiSize )
            && TFVarTypeProcess( apply_users, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildExt";
    }
};

#endif
