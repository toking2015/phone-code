#ifndef _PRAltarLottery_H_
#define _PRAltarLottery_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S3UInt32.h>
#include <proto/altar/SAltarInfo.h>

class PRAltarLottery : public SMsgHead
{
public:
    std::vector< uint32 > id_list;
    std::vector< S3UInt32 > reward_list;
    std::vector< S3UInt32 > extra_reward_list;
    uint32 soldier_id;
    SAltarInfo info;

    PRAltarLottery() : soldier_id(0)
    {
        msg_cmd = 1154904222;
    }

    virtual ~PRAltarLottery()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRAltarLottery(*this) );
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
            && TFVarTypeProcess( id_list, eType, stream, uiSize )
            && TFVarTypeProcess( reward_list, eType, stream, uiSize )
            && TFVarTypeProcess( extra_reward_list, eType, stream, uiSize )
            && TFVarTypeProcess( soldier_id, eType, stream, uiSize )
            && TFVarTypeProcess( info, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRAltarLottery";
    }
};

#endif
