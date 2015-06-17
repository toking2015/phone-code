#ifndef _PRSingleArenaCheck_H_
#define _PRSingleArenaCheck_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*对手排名有变动*/
class PRSingleArenaCheck : public SMsgHead
{
public:
    uint8 flag;    //0 代表战斗开始前就检测到对手排名已改变   1 代表战斗结束后检测到对手排名已改变

    PRSingleArenaCheck() : flag(0)
    {
        msg_cmd = 1321816909;
    }

    virtual ~PRSingleArenaCheck()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaCheck(*this) );
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
            && TFVarTypeProcess( flag, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaCheck";
    }
};

#endif
