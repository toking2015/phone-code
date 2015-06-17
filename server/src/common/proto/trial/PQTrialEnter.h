#ifndef _PQTrialEnter_H_
#define _PQTrialEnter_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>
#include <proto/formation/SUserFormation.h>

/*=========================通迅协议============================*/
class PQTrialEnter : public SMsgHead
{
public:
    uint32 id;    //试炼Id
    std::vector< SUserFormation > formation_list;    //试炼阵型

    PQTrialEnter() : id(0)
    {
        msg_cmd = 189825132;
    }

    virtual ~PQTrialEnter()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQTrialEnter(*this) );
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
            && TFVarTypeProcess( id, eType, stream, uiSize )
            && TFVarTypeProcess( formation_list, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQTrialEnter";
    }
};

#endif
