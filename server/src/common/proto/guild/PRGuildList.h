#ifndef _PRGuildList_H_
#define _PRGuildList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PRGuildList : public SMsgHead
{
public:
    uint32 index;    //返回的数据从索引index处开始, 索引从0开始
    uint32 sum;    //总长度( 全服列表总数 )
    std::vector< uint32 > list;    //公会 id 列表

    PRGuildList() : index(0), sum(0)
    {
        msg_cmd = 1358762892;
    }

    virtual ~PRGuildList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildList(*this) );
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
            && TFVarTypeProcess( sum, eType, stream, uiSize )
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildList";
    }
};

#endif
