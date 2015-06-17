#ifndef _PQTempleOpenHole_H_
#define _PQTempleOpenHole_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/* 开神符孔*/
class PQTempleOpenHole : public SMsgHead
{
public:
    uint32 hole_type;    // 神符类型，kEquipXXX
    uint32 is_use_item;    // 是否使用道具开，否则使用钻石

    PQTempleOpenHole() : hole_type(0), is_use_item(0)
    {
        msg_cmd = 515062735;
    }

    virtual ~PQTempleOpenHole()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTempleOpenHole(*this) );
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
            && TFVarTypeProcess( hole_type, eType, stream, uiSize )
            && TFVarTypeProcess( is_use_item, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTempleOpenHole";
    }
};

#endif
