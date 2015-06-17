#ifndef _IMMORTAL_PUBLIC_RANK_DC_H_
#define _IMMORTAL_PUBLIC_RANK_DC_H_

#include "common.h"
#include "proto/rank.h"

#include "dc.h"

class CRankDC : public TDC< CRankCenter >
{
public:
    CRankDC() : TDC< CRankCenter >( "rank" )
    {
    }

    ~CRankDC()
    {
    }
};
#define theRankDC TSignleton< CRankDC >::Ref()

#endif

