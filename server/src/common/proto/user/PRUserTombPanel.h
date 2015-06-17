#ifndef _PRUserTombPanel_H_
#define _PRUserTombPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/user/SUserTombPanel.h>

class PRUserTombPanel : public SMsgHead
{
public:
    uint32 target_id;
    SUserTombPanel data;

    PRUserTombPanel() : target_id(0)
    {
        msg_cmd = 2067373703;
    }

    virtual ~PRUserTombPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRUserTombPanel(*this) );
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
        return "PRUserTombPanel";
    }
};

#endif
