#ifndef _SFightLogList_H_
#define _SFightLogList_H_

#include <weedong/core/seq/seq.h>
#include <proto/fight/SFightLog.h>

class SFightLogList : public wd::CSeq
{
public:
    std::vector< SFightLog > fight_data_list;    //战斗数据

    SFightLogList()
    {
    }

    virtual ~SFightLogList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new SFightLogList(*this) );
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
            && TFVarTypeProcess( fight_data_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "SFightLogList";
    }
};

#endif
