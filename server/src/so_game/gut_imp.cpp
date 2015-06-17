#include "gut_imp.h"
#include "monster_imp.h"
#include "coin_imp.h"
#include "fight_event.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "bias_imp.h"
#include "resource/r_gutext.h"
#include "resource/r_packetext.h"
#include "resource/r_rewardext.h"
#include "resource/r_monsterext.h"
#include "log.h"
#include "local.h"
#include "server.h"

namespace gut
{

SGutInfo alloc( SUser* user, uint32 gut_id )
{
    SGutInfo data;

    data.gut_id = gut_id;

    //展开剧情
    for ( int32 index = 0; ; ++index )
    {
        CGutData::SData* gut = theGutExt.Find( gut_id, index );
        if ( gut == NULL )
            break;

        S3UInt32 s3;
        s3.cate = gut->type;
        s3.val = 0;
        switch ( gut->type )
        {
        case kGutTypeBox:
            {
                s3.objid = gut->box;

                //掉落包随机结果值保存于 val 中
                s3.val = bias::PacketRandomReward( user, gut->box );
            }
            break;
        case kGutTypeReward:
            s3.objid = gut->reward;
            break;
        case kGutTypeTalk:
        case kGutTypeVideo:
        case kGutTypeSpecial:
            break;
        }

        data.event.push_back( s3 );
    }

    return data;
}

void destory( SGutInfo& gut )
{
    //基本容错处理
    if ( gut.gut_id == 0 )
        return;

    gut.event.clear();

    gut.gut_id = 0;
}

void create( SUser* user, uint32 gut_id )
{
    destory( user->data.gut );

    user->data.gut = alloc( user, gut_id );

    reply_gut_info( user, user->data.gut );
}

int32 commit_event_normal( SGutInfo& gut, int32 index,
    std::vector< S3UInt32 >& give_coins,
    std::vector< S3UInt32 >& take_coins )
{
    //获取剧情情节列表
    std::vector< S3UInt32 >& events = gut.event;
    if ( index >= (int32)events.size() )
        return kErrGutIndex;

    S3UInt32& s3 = events[ index ];
    switch ( s3.cate )
    {
    case kGutTypeTalk:
    case kGutTypeVideo:
    case kGutTypeSpecial:
        break;
    case kGutTypeBox:
        {
            CRewardData::SData* reward = theRewardExt.Find( s3.val );
            if ( reward == NULL )
                return kErrGutRewardNotExist;

            give_coins.insert( give_coins.end(), reward->coins.begin(), reward->coins.end() );
        }
        break;
    case kGutTypeReward:
        {
            CRewardData::SData* reward = theRewardExt.Find( s3.objid );
            if ( reward == NULL )
                return kErrGutRewardNotExist;

            give_coins.insert( give_coins.end(), reward->coins.begin(), reward->coins.end() );
        }
        break;
    default:
        return kErrGutEventOrder;
    }

    //扣除剧情take_coin
    CGutData::SData* pGut = theGutExt.Find( gut.gut_id, index );
    if ( pGut != NULL && pGut->take_coin.cate != kCoinNone && pGut->take_coin.val != 0 )
        take_coins.push_back( pGut->take_coin );

    return 0;
}

void reply_gut_info( SUser* user, SGutInfo& gut )
{
    PRGutInfo rep;
    bccopy( rep, user->ext );

    rep.data = user->data.gut;

    local::write( local::access, rep );
}

} // namespace gut

