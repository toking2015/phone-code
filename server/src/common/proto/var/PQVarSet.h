#ifndef _PQVarSet_H_
#define _PQVarSet_H_

#include <weedong/core/seq/seq.h>
#include <proto/common/SMsgHead.h>

/*@@请求变量修改*/
class PQVarSet : public SMsgHead
{
public:
    uint8 set_type;    //constant.[ kObjectDel or kObjectUpdate ]
    std::string var_key;
    uint32 var_value;
    uint32 timelimit;    //有效期

    PQVarSet() : set_type(0), var_value(0), timelimit(0)
    {
        msg_cmd = 280247880;
    }

    virtual ~PQVarSet()
    {
    }

    virtual wd::CSeq* clone(void)
    {
        return ( new PQVarSet(*this) );
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
            && TFVarTypeProcess( var_key, eType, stream, uiSize )
            && TFVarTypeProcess( var_value, eType, stream, uiSize )
            && TFVarTypeProcess( timelimit, eType, stream, uiSize )
            && loopend( stream, eType, uiSize );
    }
    operator const char* ()
    {
        return "PQVarSet";
    }
};

#endif
