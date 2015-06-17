#ifndef _PQActivitySet_H_
#define _PQActivitySet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/activity/SActivityData.h>

/*只接受从authsvr 发起的协议处理*/
class PQActivitySet : public SMsgHead
{
public:
    uint8 set_type;    //修改类型 kObjectAdd、kObjectDel、kObjectUpdate
    uint8 time_type;    //时间类型 kActivityTimeTypeBound、kActivityTimeTypeOpen、kActivityTimeTypeUnite
    SActivityData activity;

    PQActivitySet() : set_type(0), time_type(0)
    {
        msg_cmd = 900505404;
    }

    virtual ~PQActivitySet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQActivitySet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( time_type, eType, stream, uiSize )
            && TFVarTypeProcess( activity, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQActivitySet";
    }
};

#endif
