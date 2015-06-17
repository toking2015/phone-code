#ifndef _PRBuildingList_H_
#define _PRBuildingList_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/building/SUserBuilding.h>

/*@@ 返回建筑列表*/
class PRBuildingList : public SMsgHead
{
public:
    std::vector< SUserBuilding > list;    //建筑群

    PRBuildingList()
    {
        msg_cmd = 1774802370;
    }

    virtual ~PRBuildingList()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRBuildingList(*this) );
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
            && TFVarTypeProcess( list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRBuildingList";
    }
};

#endif
