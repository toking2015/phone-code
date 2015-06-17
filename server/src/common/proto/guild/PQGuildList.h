#ifndef _PQGuildList_H_
#define _PQGuildList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*公会列表请求*/
class PQGuildList : public SMsgHead
{
public:
    uint32 index;    //从索引开始请求, 索引从0开始
    uint32 count;    //请求数量

    PQGuildList() : index(0), count(0)
    {
        msg_cmd = 660873787;
    }

    virtual ~PQGuildList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQGuildList(*this) );
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
            && TFVarTypeProcess( index, eType, stream, uiSize )
            && TFVarTypeProcess( count, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQGuildList";
    }
};

#endif
