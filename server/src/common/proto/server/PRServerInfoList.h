#ifndef _PRServerInfoList_H_
#define _PRServerInfoList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRServerInfoList : public SMsgHead
{
public:
    std::map< std::string, std::string > key_value;

    PRServerInfoList()
    {
        msg_cmd = 1430484165;
    }

    virtual ~PRServerInfoList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRServerInfoList(*this) );
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
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, eType, _uiSize )
            && wd::CSeq::loop( stream, eType, uiSize )
            && TFVarTypeProcess( key_value, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRServerInfoList";
    }
};

#endif
