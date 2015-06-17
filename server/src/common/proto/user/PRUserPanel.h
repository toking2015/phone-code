#ifndef _PRUserPanel_H_
#define _PRUserPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/user/SUserPanel.h>

class PRUserPanel : public SMsgHead
{
public:
    uint32 target_id;
    SUserPanel data;

    PRUserPanel() : target_id(0)
    {
        msg_cmd = 1395064671;
    }

    virtual ~PRUserPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PRUserPanel(*this) );
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
        return "PRUserPanel";
    }
};

#endif
