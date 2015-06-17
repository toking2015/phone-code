#ifndef _PRSingleArenaBattleEnd_H_
#define _PRSingleArenaBattleEnd_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>

/*战斗结束后，发掉落包*/
class PRSingleArenaBattleEnd : public SMsgHead
{
public:
    uint32 win_flag;    //1,赢 2,输
    std::vector< S3UInt32 > coins;    //奖励

    PRSingleArenaBattleEnd() : win_flag(0)
    {
        msg_cmd = 1539999730;
    }

    virtual ~PRSingleArenaBattleEnd()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRSingleArenaBattleEnd(*this) );
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
            && TFVarTypeProcess( win_flag, eType, stream, uiSize )
            && TFVarTypeProcess( coins, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRSingleArenaBattleEnd";
    }
};

#endif
