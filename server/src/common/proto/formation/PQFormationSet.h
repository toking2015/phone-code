#ifndef _PQFormationSet_H_
#define _PQFormationSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/formation/SUserFormation.h>

class PQFormationSet : public SMsgHead
{
public:
    uint32 formation_type;
    std::vector< SUserFormation > formation_list;

    PQFormationSet() : formation_type(0)
    {
        msg_cmd = 323879387;
    }

    virtual ~PQFormationSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQFormationSet(*this) );
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
            && TFVarTypeProcess( formation_type, eType, stream, uiSize )
            && TFVarTypeProcess( formation_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQFormationSet";
    }
};

#endif
