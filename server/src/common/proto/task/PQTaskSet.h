#ifndef _PQTaskSet_H_
#define _PQTaskSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@任务数据更新*/
class PQTaskSet : public SMsgHead
{
public:
    uint32 task_id;
    uint32 cond;    //任务条件完成值( 部分任务由客户端主动提交数值修改 )

    PQTaskSet() : task_id(0), cond(0)
    {
        msg_cmd = 3607773;
    }

    virtual ~PQTaskSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTaskSet(*this) );
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
            && TFVarTypeProcess( task_id, eType, stream, uiSize )
            && TFVarTypeProcess( cond, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTaskSet";
    }
};

#endif
