#ifndef _PQUserSingleArenaPre_H_
#define _PQUserSingleArenaPre_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*申请玩家竞技场当前四个对手的中真人竞技防御阵里所有的武将id与图腾id*/
class PQUserSingleArenaPre : public SMsgHead
{
public:

    PQUserSingleArenaPre()
    {
        msg_cmd = 595760048;
    }

    virtual ~PQUserSingleArenaPre()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQUserSingleArenaPre(*this) );
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
        return "PQUserSingleArenaPre";
    }
};

#endif
