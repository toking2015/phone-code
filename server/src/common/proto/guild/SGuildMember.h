#ifndef _SGuildMember_H_
#define _SGuildMember_H_

#include <weedong/core/seq/seq.h>
/*公会成员信息结构*/
class SGuildMember : public wd::CSeq
{
public:
    uint32 role_id;
    uint32 job;    //公会职位
    uint32 join_time;
    uint32 daily_contribute;
    uint32 history_contribute;

    SGuildMember() : role_id(0), job(0), join_time(0), daily_contribute(0), history_contribute(0)
    {
    }

    virtual ~SGuildMember()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildMember(*this) );
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
            && TFVarTypeProcess( job, eType, stream, uiSize )
            && TFVarTypeProcess( join_time, eType, stream, uiSize )
            && TFVarTypeProcess( daily_contribute, eType, stream, uiSize )
            && TFVarTypeProcess( history_contribute, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildMember";
    }
};

#endif
