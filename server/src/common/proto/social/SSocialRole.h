#ifndef _SSocialRole_H_
#define _SSocialRole_H_

#include <weedong/core/seq/seq.h>
/*=========================数据中心============================*/
class SSocialRole : public wd::CSeq
{
public:
    uint32 role_id;
    uint32 level;
    std::string name;

    SSocialRole() : role_id(0), level(0)
    {
    }

    virtual ~SSocialRole()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SSocialRole(*this) );
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
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SSocialRole";
    }
};

#endif
