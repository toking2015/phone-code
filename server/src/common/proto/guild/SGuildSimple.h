#ifndef _SGuildSimple_H_
#define _SGuildSimple_H_

#include <weedong/core/seq/seq.h>
/*公会简易信息结构*/
class SGuildSimple : public wd::CSeq
{
public:
    uint32 guid;
    std::string name;
    uint16 level;    //军团等级
    uint32 creator_id;    //创建人role_id

    SGuildSimple() : guid(0), level(0), creator_id(0)
    {
    }

    virtual ~SGuildSimple()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SGuildSimple(*this) );
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
            && TFVarTypeProcess( guid, eType, stream, uiSize )
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( level, eType, stream, uiSize )
            && TFVarTypeProcess( creator_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SGuildSimple";
    }
};

#endif
