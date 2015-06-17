#ifndef _PRSystemUserLoad_H_
#define _PRSystemUserLoad_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/user/SUserData.h>

/*game 进程sql线程到逻辑线程的数据返回包*/
class PRSystemUserLoad : public SMsgHead
{
public:
    uint32 guid;
    uint8 created;    //新创建使用
    SUserData data;

    PRSystemUserLoad() : guid(0), created(0)
    {
        msg_cmd = 1461797166;
    }

    virtual ~PRSystemUserLoad()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSystemUserLoad(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( created, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSystemUserLoad";
    }
};

#endif
