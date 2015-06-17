#ifndef _SGuildData_H_
#define _SGuildData_H_

#include <weedong/core/seq/seq.h>
#include <proto/guild/SGuildSimple.h>
#include <proto/guild/SGuildInfo.h>
#include <proto/guild/SGuildProtect.h>
#include <proto/guild/SGuildLog.h>
#include <proto/guild/SGuildMember.h>

/*公会存储数据库的所有数据结构*/
class SGuildData : public wd::CSeq
{
public:
    SGuildSimple simple;
    SGuildInfo info;
    SGuildProtect protect;
    std::vector< SGuildLog > log_list;    //动态日志
    std::vector< SGuildMember > member_list;    //成员列表

    SGuildData()
    {
    }

    virtual ~SGuildData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildData(*this) );
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
            && TFVarTypeProcess( simple, eType, stream, uiSize )
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && TFVarTypeProcess( protect, eType, stream, uiSize )
            && TFVarTypeProcess( log_list, eType, stream, uiSize )
            && TFVarTypeProcess( member_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildData";
    }
};

#endif
