#ifndef _PQBuildingList_H_
#define _PQBuildingList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*## 获取建筑列表*/
class PQBuildingList : public SMsgHead
{
public:
    uint32 target_id;    //目标id ( role_id )

    PQBuildingList() : target_id(0)
    {
        msg_cmd = 600622277;
    }

    virtual ~PQBuildingList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQBuildingList(*this) );
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
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQBuildingList";
    }
};

#endif
