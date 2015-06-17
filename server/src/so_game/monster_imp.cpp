#include "local.h"
#include "bias_imp.h"
#include "monster_imp.h"
#include "proto/constant.h"
#include "misc.h"
#include "soldier_imp.h"
#include "resource/r_monsterext.h"
#include "resource/r_rewardext.h"
#include "resource/r_packetext.h"
#include "luamgr.h"
#include "user_dc.h"

namespace monster
{
    std::vector<S3UInt32> GetMonsterDrop( SUser *puser, uint32 monster_id )
    {
        std::vector<S3UInt32> coin_list;

        CMonsterData::SData *pmonster = theMonsterExt.Find( monster_id );
        if ( NULL == pmonster )
            return coin_list;

        for( std::vector<uint32>::iterator iter = pmonster->packets.begin();
            iter != pmonster->packets.end();
            ++iter )
        {
            if ( 0 == *iter )
                continue;
            uint32 reward_id = bias::PacketRandomReward( puser, *iter );
            if ( 0 == reward_id )
                continue;

            CRewardData::SData *preward = theRewardExt.Find( reward_id );
            if ( NULL == preward )
                continue;

            coin_list.insert( coin_list.end(), preward->coins.begin(), preward->coins.end() );
        }

        return coin_list;
    }
}// namespace monster

