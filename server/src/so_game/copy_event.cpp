#include "event.h"
#include "fight_imp.h"
#include "proto/copy.h"
#include "proto/constant.h"
#include "copy_imp.h"
#include "copy_dc.h"
#include "var_imp.h"
#include "user_event.h"
#include "link_event.h"

EVENT_FUNC( copy, SEventUserLogin )
{
    SUserCopy& data = ev.user->data.copy;
    if ( data.copy_id == 0 )
        return;

    for ( int32 i = 0; i < (int32)data.chunk.size(); ++i )
    {
        S3UInt32& chunk = data.chunk[i];
        switch ( chunk.cate )
        {
        case kCopyEventTypeFight:
        case kCopyEventTypeFightMeet:
            {
                //移除原有战斗数据
                if ( chunk.val != 0 )
                {
                    std::map< uint32, SFight >::iterator iter = data.fight.find( chunk.val );
                    if ( iter != data.fight.end() )
                    {
                        SFight* fight = theFightDC.find( iter->second.fight_id );

                        if ( fight != NULL )
                            fight::DelFight( fight );
                        theFightDC.del( iter->second.fight_id );

                        data.fight.erase( iter );
                        data.seed.erase( chunk.val );
                    }

                    chunk.val = 0;
                }

                //新增战斗数据
                if ( i >= data.posi )
                {
                    SFight* fight = fight::Interface( kFightTypeCopy )->AddFightToMonster( ev.user, chunk.objid );
                    if ( fight != NULL )
                    {
                        data.fight[ fight->fight_id ] = *fight;
                        data.seed[ fight->fight_id ].value = TRand( 0, 0x7FFFFFFF );
                        chunk.val = fight->fight_id;
                    }
                }
            }
            break;
        }
    }
}

EVENT_FUNC( copy, SEventUserTimeLimit )
{
    //重设扫荡次数
    for ( std::map< uint32, uint32 >::iterator iter = ev.user->data.mopup.normal_times.begin();
        iter != ev.user->data.mopup.normal_times.end();
        ++iter )
    {
        iter->second = 0;
    }
    for ( std::map< uint32, uint32 >::iterator iter = ev.user->data.mopup.elite_times.begin();
        iter != ev.user->data.mopup.elite_times.end();
        ++iter )
    {
        iter->second = 0;
    }

    //重设扫荡重置次数
    for ( std::map< uint32, uint32 >::iterator iter = ev.user->data.mopup.normal_reset.begin();
        iter != ev.user->data.mopup.normal_reset.end();
        ++iter )
    {
        iter->second = 0;
    }
    for ( std::map< uint32, uint32 >::iterator iter = ev.user->data.mopup.elite_reset.begin();
        iter != ev.user->data.mopup.elite_reset.end();
        ++iter )
    {
        iter->second = 0;
    }

    //返回重设数据通知
    copy::reply_mopup_data( ev.user, kCopyMopupTypeNormal, kCopyMopupAttrTimes, 0, 0 );
    copy::reply_mopup_data( ev.user, kCopyMopupTypeElite, kCopyMopupAttrTimes, 0, 0 );
    copy::reply_mopup_data( ev.user, kCopyMopupTypeNormal, kCopyMopupAttrReset, 0, 0 );
    copy::reply_mopup_data( ev.user, kCopyMopupTypeElite, kCopyMopupAttrReset, 0, 0 );
}

EVENT_FUNC( copy, SEventNetRealDB )
{
    theCopyDC.QuestLogList();
}

