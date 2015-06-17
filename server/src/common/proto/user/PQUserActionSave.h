#ifndef _PQUserActionSave_H_
#define _PQUserActionSave_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*用户行为记录*/
class PQUserActionSave : public SMsgHead
{
public:
    std::string last_action;

    PQUserActionSave()
    {
        msg_cmd = 658374206;
    }

    virtual ~PQUserActionSave()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQUserActionSave(*this) );
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
            && TFVarTypeProcess( last_action, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQUserActionSave";
    }
};

#endif
