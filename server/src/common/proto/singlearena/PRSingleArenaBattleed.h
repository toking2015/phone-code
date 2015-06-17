#ifndef _PRSingleArenaBattleed_H_
#define _PRSingleArenaBattleed_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*如果自己被玩家打败将会收到此协议作提醒*/
class PRSingleArenaBattleed : public SMsgHead
{
public:

    PRSingleArenaBattleed()
    {
        msg_cmd = 2093837737;
    }

    virtual ~PRSingleArenaBattleed()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaBattleed(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaBattleed";
    }
};

#endif
