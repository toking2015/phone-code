#ifndef _PQUserPanel_H_
#define _PQUserPanel_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

class PQUserPanel : public SMsgHead
{
public:
    uint32 target_id;

    PQUserPanel() : target_id(0)
    {
        msg_cmd = 945575969;
    }

    virtual ~PQUserPanel()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQUserPanel(*this) );
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
        return "PQUserPanel";
    }
};

#endif
