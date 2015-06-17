#ifndef _PRUserSingleArenaPre_H_
#define _PRUserSingleArenaPre_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/common/S2UInt32.h>

class PRUserSingleArenaPre : public SMsgHead
{
public:
    std::map< uint32, std::vector< S2UInt32 > > s_map;    //武将
    std::map< uint32, std::vector< S2UInt32 > > t_map;    //图腾

    PRUserSingleArenaPre()
    {
        msg_cmd = 1897770585;
    }

    virtual ~PRUserSingleArenaPre()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRUserSingleArenaPre(*this) );
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
            && TFVarTypeProcess( s_map, eType, stream, uiSize )
            && TFVarTypeProcess( t_map, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PRUserSingleArenaPre";
    }
};

#endif
