#ifndef _CAuth_H_
#define _CAuth_H_

#include <weedong/core/seq/seq.h>
#include <proto/auth/SAuthRunData.h>

/*=========================数据中心============================*/
class CAuth : public wd::CSeq
{
public:
    std::map< uint32, SAuthRunData > loop_map;    //< guid, 执行指令数据 >
    std::map< uint32, uint32 > online_data;    //< guid, 在线时长( 每天清空 ) >

    CAuth()
    {
    }

    virtual ~CAuth()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CAuth(*this) );
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
            && TFVarTypeProcess( loop_map, eType, stream, uiSize )
            && TFVarTypeProcess( online_data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CAuth";
    }
};

#endif
