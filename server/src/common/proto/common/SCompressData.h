#ifndef _SCompressData_H_
#define _SCompressData_H_

#include <weedong/core/seq/seq.h>
/*压缩数据*/
class SCompressData : public wd::CSeq
{
public:
    uint32 size;    //原文长度
    wd::CStream data;    //压缩内容

    SCompressData() : size(0)
    {
    }

    virtual ~SCompressData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SCompressData(*this) );
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
            && TFVarTypeProcess( size, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SCompressData";
    }
};

#endif
