#ifndef _CServer_H_
#define _CServer_H_

#include <weedong/core/seq/seq.h>
/*============================数据中心========================*/
class CServer : public wd::CSeq
{
public:
    std::vector< uint32 > server_ids;    //服务器id列表( 合服后有效 )
    std::map< std::string, std::string > key_value;    //服务器系统变量

    CServer()
    {
    }

    virtual ~CServer()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CServer(*this) );
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
            && TFVarTypeProcess( server_ids, eType, stream, uiSize )
            && TFVarTypeProcess( key_value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CServer";
    }
};

#endif
