#ifndef _CUserItem_H_
#define _CUserItem_H_

#include <weedong/core/seq/seq.h>
/*============================数据中心========================*/
class CUserItem : public wd::CSeq
{
public:

    CUserItem()
    {
    }

    virtual ~CUserItem()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new CUserItem(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "CUserItem";
    }
};

#endif
