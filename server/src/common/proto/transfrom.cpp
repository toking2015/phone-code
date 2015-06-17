#include "proto/transfrom.h"

#include "proto/transfrom/transfrom_access.h"
#include "proto/transfrom/transfrom_activity.h"
#include "proto/transfrom/transfrom_altar.h"
#include "proto/transfrom/transfrom_auth.h"
#include "proto/transfrom/transfrom_back.h"
#include "proto/transfrom/transfrom_bias.h"
#include "proto/transfrom/transfrom_broadcast.h"
#include "proto/transfrom/transfrom_building.h"
#include "proto/transfrom/transfrom_chat.h"
#include "proto/transfrom/transfrom_client.h"
#include "proto/transfrom/transfrom_coin.h"
#include "proto/transfrom/transfrom_common.h"
#include "proto/transfrom/transfrom_copy.h"
#include "proto/transfrom/transfrom_equip.h"
#include "proto/transfrom/transfrom_fight.h"
#include "proto/transfrom/transfrom_fightextable.h"
#include "proto/transfrom/transfrom_formation.h"
#include "proto/transfrom/transfrom_friend.h"
#include "proto/transfrom/transfrom_guild.h"
#include "proto/transfrom/transfrom_gut.h"
#include "proto/transfrom/transfrom_item.h"
#include "proto/transfrom/transfrom_mail.h"
#include "proto/transfrom/transfrom_market.h"
#include "proto/transfrom/transfrom_notify.h"
#include "proto/transfrom/transfrom_opentarget.h"
#include "proto/transfrom/transfrom_paper.h"
#include "proto/transfrom/transfrom_pay.h"
#include "proto/transfrom/transfrom_platform.h"
#include "proto/transfrom/transfrom_present.h"
#include "proto/transfrom/transfrom_rank.h"
#include "proto/transfrom/transfrom_reportpost.h"
#include "proto/transfrom/transfrom_server.h"
#include "proto/transfrom/transfrom_shop.h"
#include "proto/transfrom/transfrom_sign.h"
#include "proto/transfrom/transfrom_singlearena.h"
#include "proto/transfrom/transfrom_social.h"
#include "proto/transfrom/transfrom_soldier.h"
#include "proto/transfrom/transfrom_star.h"
#include "proto/transfrom/transfrom_strength.h"
#include "proto/transfrom/transfrom_system.h"
#include "proto/transfrom/transfrom_task.h"
#include "proto/transfrom/transfrom_team.h"
#include "proto/transfrom/transfrom_temple.h"
#include "proto/transfrom/transfrom_timer.h"
#include "proto/transfrom/transfrom_tomb.h"
#include "proto/transfrom/transfrom_top.h"
#include "proto/transfrom/transfrom_totem.h"
#include "proto/transfrom/transfrom_trial.h"
#include "proto/transfrom/transfrom_user.h"
#include "proto/transfrom/transfrom_var.h"
#include "proto/transfrom/transfrom_vip.h"
#include "proto/transfrom/transfrom_viptimelimitshop.h"

void transfrom_register_handles(
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >& handles,
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > map )
{
    for ( std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >::iterator iter = map.begin();
        iter != map.end();
        ++iter )
    {
        handles[ iter->first ] = iter->second;
    }
}

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > class_transfrom::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    transfrom_register_handles( handles, class_transfrom_access::get_handles() );
    transfrom_register_handles( handles, class_transfrom_activity::get_handles() );
    transfrom_register_handles( handles, class_transfrom_altar::get_handles() );
    transfrom_register_handles( handles, class_transfrom_auth::get_handles() );
    transfrom_register_handles( handles, class_transfrom_back::get_handles() );
    transfrom_register_handles( handles, class_transfrom_bias::get_handles() );
    transfrom_register_handles( handles, class_transfrom_broadcast::get_handles() );
    transfrom_register_handles( handles, class_transfrom_building::get_handles() );
    transfrom_register_handles( handles, class_transfrom_chat::get_handles() );
    transfrom_register_handles( handles, class_transfrom_client::get_handles() );
    transfrom_register_handles( handles, class_transfrom_coin::get_handles() );
    transfrom_register_handles( handles, class_transfrom_common::get_handles() );
    transfrom_register_handles( handles, class_transfrom_copy::get_handles() );
    transfrom_register_handles( handles, class_transfrom_equip::get_handles() );
    transfrom_register_handles( handles, class_transfrom_fight::get_handles() );
    transfrom_register_handles( handles, class_transfrom_fightextable::get_handles() );
    transfrom_register_handles( handles, class_transfrom_formation::get_handles() );
    transfrom_register_handles( handles, class_transfrom_friend::get_handles() );
    transfrom_register_handles( handles, class_transfrom_guild::get_handles() );
    transfrom_register_handles( handles, class_transfrom_gut::get_handles() );
    transfrom_register_handles( handles, class_transfrom_item::get_handles() );
    transfrom_register_handles( handles, class_transfrom_mail::get_handles() );
    transfrom_register_handles( handles, class_transfrom_market::get_handles() );
    transfrom_register_handles( handles, class_transfrom_notify::get_handles() );
    transfrom_register_handles( handles, class_transfrom_opentarget::get_handles() );
    transfrom_register_handles( handles, class_transfrom_paper::get_handles() );
    transfrom_register_handles( handles, class_transfrom_pay::get_handles() );
    transfrom_register_handles( handles, class_transfrom_platform::get_handles() );
    transfrom_register_handles( handles, class_transfrom_present::get_handles() );
    transfrom_register_handles( handles, class_transfrom_rank::get_handles() );
    transfrom_register_handles( handles, class_transfrom_reportpost::get_handles() );
    transfrom_register_handles( handles, class_transfrom_server::get_handles() );
    transfrom_register_handles( handles, class_transfrom_shop::get_handles() );
    transfrom_register_handles( handles, class_transfrom_sign::get_handles() );
    transfrom_register_handles( handles, class_transfrom_singlearena::get_handles() );
    transfrom_register_handles( handles, class_transfrom_social::get_handles() );
    transfrom_register_handles( handles, class_transfrom_soldier::get_handles() );
    transfrom_register_handles( handles, class_transfrom_star::get_handles() );
    transfrom_register_handles( handles, class_transfrom_strength::get_handles() );
    transfrom_register_handles( handles, class_transfrom_system::get_handles() );
    transfrom_register_handles( handles, class_transfrom_task::get_handles() );
    transfrom_register_handles( handles, class_transfrom_team::get_handles() );
    transfrom_register_handles( handles, class_transfrom_temple::get_handles() );
    transfrom_register_handles( handles, class_transfrom_timer::get_handles() );
    transfrom_register_handles( handles, class_transfrom_tomb::get_handles() );
    transfrom_register_handles( handles, class_transfrom_top::get_handles() );
    transfrom_register_handles( handles, class_transfrom_totem::get_handles() );
    transfrom_register_handles( handles, class_transfrom_trial::get_handles() );
    transfrom_register_handles( handles, class_transfrom_user::get_handles() );
    transfrom_register_handles( handles, class_transfrom_var::get_handles() );
    transfrom_register_handles( handles, class_transfrom_vip::get_handles() );
    transfrom_register_handles( handles, class_transfrom_viptimelimitshop::get_handles() );

    return handles;
}

