#ifndef _SFightClientRoundData_H_
#define _SFightClientRoundData_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightLog.h>

class SFightClientRoundData : public wd::CSeq
{
public:
    uint32 time;
    uint32 totem_time;
    std::vector< SFightLog > log_list;

    SFightClientRoundData() : time(0), totem_time(0)
    {
    }

    virtual ~SFightClientRoundData()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightClientRoundData(*this) );
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
            && TFVarTypeProcess( time, eType, stream, uiSize )
            && TFVarTypeProcess( totem_time, eType, stream, uiSize )
            && TFVarTypeProcess( log_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightClientRoundData";
    }
};

#endif
