#ifndef _PQCopyAreaPresentTake_H_
#define _PQCopyAreaPresentTake_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*副本区域全星通关奖励领取*/
class PQCopyAreaPresentTake : public SMsgHead
{
public:
    uint8 mopup_type;    //副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
    uint8 area_attr;    //副本区域属性 [ kCopyAreaAttrPass | kCopyAreaAttrFullStar ]
    uint32 area_id;    //副本区域id( int( Copy.xls->id / 1000 ) )

    PQCopyAreaPresentTake() : mopup_type(0), area_attr(0), area_id(0)
    {
        msg_cmd = 302285013;
    }

    virtual ~PQCopyAreaPresentTake()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQCopyAreaPresentTake(*this) );
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
            && TFVarTypeProcess( mopup_type, eType, stream, uiSize )
            && TFVarTypeProcess( area_attr, eType, stream, uiSize )
            && TFVarTypeProcess( area_id, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQCopyAreaPresentTake";
    }
};

#endif
