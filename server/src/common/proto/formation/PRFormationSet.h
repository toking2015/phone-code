#ifndef _PRFormationSet_H_
#define _PRFormationSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/formation/SUserFormation.h>

class PRFormationSet : public SMsgHead
{
public:
    uint8 set_type;    //修改类型 kObjectAdd、kObjectDel、kObjectUpdate
    std::vector< SUserFormation > formation_list;

    PRFormationSet() : set_type(0)
    {
        msg_cmd = 1824940868;
    }

    virtual ~PRFormationSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRFormationSet(*this) );
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

    bool loop( wd::CStream &stream, wd::CSeq::ELoopType type, uint32& uiSize )
    {
        uint32 _uiSize = 0;
        return SMsgHead::loop( stream, type, _uiSize )
            && wd::CSeq::loop( stream, type, uiSize )
            && TFVarTypeProcess( set_type, type, stream, uiSize )
            && TFVarTypeProcess( formation_list, type, stream, uiSize )
            && loopend( stream, type, uiSize );
    }
    operator const char* ()
    {
        return "PRFormationSet";
    }
};

#endif
