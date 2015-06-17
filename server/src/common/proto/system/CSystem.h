#ifndef _CSystem_H_
#define _CSystem_H_

#include <weedong/core/seq/seq.h>
/*=========================数据中心===========================*/
class CSystem : public wd::CSeq
{
public:
    std::map< uint32, uint32 > sessions;

    CSystem()
    {
    }

    virtual ~CSystem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CSystem(*this) );
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
            && TFVarTypeProcess( sessions, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CSystem";
    }
};

#endif
