#ifndef _PQBuildingGetOutput_H_
#define _PQBuildingGetOutput_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQBuildingGetOutput : public SMsgHead
{
public:
    uint32 building_type;    //建筑类型

    PQBuildingGetOutput() : building_type(0)
    {
        msg_cmd = 493876112;
    }

    virtual ~PQBuildingGetOutput()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingGetOutput(*this) );
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
            && TFVarTypeProcess( building_type, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingGetOutput";
    }
};

#endif
