#ifndef _S3UInt32_H_
#define _S3UInt32_H_

#include <weedong/core/seq/seq.h>
class S3UInt32 : public wd::CSeq
{
public:
    uint32 cate;    //类型
    uint32 objid;    //扩展Id
    uint32 val;    //数值

    S3UInt32() : cate(0), objid(0), val(0)
    {
    }

    virtual ~S3UInt32()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new S3UInt32(*this) );
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
            && TFVarTypeProcess( cate, eType, stream, uiSize )
            && TFVarTypeProcess( objid, eType, stream, uiSize )
            && TFVarTypeProcess( val, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "S3UInt32";
    }
};

#endif
