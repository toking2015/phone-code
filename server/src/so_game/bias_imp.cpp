#include "local.h"
#include "bias_imp.h"
#include "proto/constant.h"
#include "misc.h"
#include "soldier_imp.h"
#include "resource/r_biasext.h"
#include "resource/r_rewardext.h"
#include "resource/r_packetext.h"
#include "user_dc.h"
#include "common.h"

namespace bias
{
    uint32 Random( SUser *puser, uint32 bias_id )
    {
        CBiasData::SData *pdata = theBiasExt.Find( bias_id );
        if ( NULL == pdata )
            return 0;

        SUserBias &user_bias = puser->data.bias_map[bias_id];
        user_bias.bias_id = bias_id;

        if ( 0 != pdata->day_count && user_bias.day_count >= pdata->day_count )
            return 0;

        uint32 count = user_bias.use_count + 1;
        if ( count >= pdata->must_count )
        {
            //清空次数添加每日次数
            user_bias.use_count = 0;
            user_bias.day_count++;
            return pdata->back_id;
        }

        uint32 percent = count >= pdata->begin_count ? pdata->begin_factor + pdata->add_factor * (count-pdata->begin_count) : 0;
        uint32 value = TRand( 0, 10000 );
        if ( value < percent )
        {
            user_bias.use_count = 0;
            user_bias.day_count++;
            return pdata->back_id;
        }
        else
        {
            user_bias.use_count++;
        }
        return 0;
    }

    uint32 PacketRandomReward( SUser *puser, uint32 packet_id )
    {

        CPacketData::SData *pdata = thePacketExt.Find(packet_id);
        if ( NULL == pdata )
            return 0;
        if ( 0 != pdata->bias_id )
        {
            uint32 back_id = Random( puser, pdata->bias_id );
            if ( 0 != back_id )
                packet_id = back_id;
        }
        return thePacketExt.RandomReward( packet_id );
    }

    void TimeLimit( SUser *puser )
    {
        for ( std::map<uint32, SUserBias>::iterator iter = puser->data.bias_map.begin();
            iter != puser->data.bias_map.end();
            ++iter )
        {
            iter->second.day_count = 0;
        }
    }
}// namespace bias

