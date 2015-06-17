#ifndef _PRGuildApply_H_
#define _PRGuildApply_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请人列表*/
class PRGuildApply : public SMsgHead
{
public:
    std::vector< uint32 > apply_list;

    PRGuildApply()
    {
        msg_cmd = 1972373836;
    }

    virtual ~PRGuildApply()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRGuildApply(*this) );
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
            && TFVarTypeProcess( apply_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRGuildApply";
    }
};

#endif
