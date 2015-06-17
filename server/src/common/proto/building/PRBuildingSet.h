#ifndef _PRBuildingSet_H_
#define _PRBuildingSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/building/SUserBuilding.h>

/*@@*/
class PRBuildingSet : public SMsgHead
{
public:
    uint8 set_type;    //kObjectAdd, kObjectUpdate, kObjectDel
    SUserBuilding building;

    PRBuildingSet() : set_type(0)
    {
        msg_cmd = 1484773370;
    }

    virtual ~PRBuildingSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRBuildingSet(*this) );
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
            && TFVarTypeProcess( set_type, eType, stream, uiSize )
            && TFVarTypeProcess( building, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRBuildingSet";
    }
};

#endif
