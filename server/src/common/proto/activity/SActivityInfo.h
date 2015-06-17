#ifndef _SActivityInfo_H_
#define _SActivityInfo_H_

#include <weedong/core/seq/seq.h>
class SActivityInfo : public wd::CSeq
{
public:
    std::string name;    //活动标志
    uint32 start_time;    //活动开启时间
    uint32 end_time;    //活动结束时间

    SActivityInfo() : start_time(0), end_time(0)
    {
    }

    virtual ~SActivityInfo()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SActivityInfo(*this) );
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
            && TFVarTypeProcess( name, eType, stream, uiSize )
            && TFVarTypeProcess( start_time, eType, stream, uiSize )
            && TFVarTypeProcess( end_time, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SActivityInfo";
    }
};

#endif
