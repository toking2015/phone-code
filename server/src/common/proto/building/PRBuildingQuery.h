#ifndef _PRBuildingQuery_H_
#define _PRBuildingQuery_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/building/SUserBuilding.h>

/*@@*/
class PRBuildingQuery : public SMsgHead
{
public:
    uint32 target_id;    //目标id( role_id)
    SUserBuilding data;    //请求的数据

    PRBuildingQuery() : target_id(0)
    {
        msg_cmd = 1318423735;
    }

    virtual ~PRBuildingQuery()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRBuildingQuery(*this) );
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
            && TFVarTypeProcess( target_id, eType, stream, uiSize )
            && TFVarTypeProcess( data, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRBuildingQuery";
    }
};

#endif
