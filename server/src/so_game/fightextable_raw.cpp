#include "raw.h"

#include "proto/soldier.h"
#include "proto/constant.h"

RAW_USER_LOAD( fightextable_map )
{
    QuerySql( "select soldier_guid, attr, hp, physical_ack, physical_def, magic_ack , magic_def, speed, critper, critper_def, recover_critper, recover_critper_def, crithurt, crithurt_def, hitper, dodgeper, parryper, parryper_dec, rage, stun_def, silent_def, stun_def, fire_def, recover_add_fix, recover_del_fix, recover_add_per, recover_del_per, rage_add_fix, rage_del_fix, rage_add_per, rage_del_per from fightextable where role_id = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SFightExtAbleInfo fightextable;
        fightextable.guid                       = sql->getInteger(i++);
        fightextable.attr                       = sql->getInteger(i++);
        fightextable.able.hp                    = sql->getInteger(i++);
        fightextable.able.physical_ack          = sql->getInteger(i++);
        fightextable.able.physical_def          = sql->getInteger(i++);
        fightextable.able.magic_ack             = sql->getInteger(i++);
        fightextable.able.magic_def             = sql->getInteger(i++);
        fightextable.able.speed                 = sql->getInteger(i++);
        fightextable.able.critper               = sql->getInteger(i++);
        fightextable.able.critper_def           = sql->getInteger(i++);
        fightextable.able.recover_critper       = sql->getInteger(i++);
        fightextable.able.recover_critper_def   = sql->getInteger(i++);
        fightextable.able.crithurt              = sql->getInteger(i++);
        fightextable.able.crithurt_def          = sql->getInteger(i++);
        fightextable.able.hitper                = sql->getInteger(i++);
        fightextable.able.dodgeper              = sql->getInteger(i++);
        fightextable.able.parryper              = sql->getInteger(i++);
        fightextable.able.parryper_dec          = sql->getInteger(i++);
        fightextable.able.rage                  = sql->getInteger(i++);
        fightextable.able.stun_def              = sql->getInteger(i++);
        fightextable.able.silent_def            = sql->getInteger(i++);
        fightextable.able.weak_def              = sql->getInteger(i++);
        fightextable.able.fire_def              = sql->getInteger(i++);
        fightextable.able.recover_add_fix       = sql->getInteger(i++);
        fightextable.able.recover_del_fix       = sql->getInteger(i++);
        fightextable.able.recover_add_per       = sql->getInteger(i++);
        fightextable.able.recover_del_per       = sql->getInteger(i++);
        fightextable.able.rage_add_fix          = sql->getInteger(i++);
        fightextable.able.rage_del_fix          = sql->getInteger(i++);
        fightextable.able.rage_add_per          = sql->getInteger(i++);
        fightextable.able.rage_del_per          = sql->getInteger(i++);

        data.fightextable_map[fightextable.attr].push_back( fightextable );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( fightextable_map )
{
    stream << strprintf( "delete from fightextable where role_id = %u;", guid ) << std::endl;

    if ( data.fightextable_map.empty() )
        return;

    for( std::map<uint32, std::vector<SFightExtAbleInfo> >::iterator iter = data.fightextable_map.begin();
        iter != data.fightextable_map.end();
        ++iter )
    {
        if ( (iter->second).empty() )
            continue;
        stream << "insert into fightextable ( role_id, soldier_guid, attr, hp, physical_ack, physical_def, magic_ack, magic_def, speed, critper, critper_def, recover_critper, recover_critper_def, crithurt, crithurt_def, hitper, dodgeper, parryper, parryper_dec, rage, stun_def, silent_def, weak_def, fire_def, recover_add_fix, recover_del_fix, recover_add_per, recover_del_per, rage_add_fix, rage_del_fix, rage_add_per, rage_del_per ) values";
    int32 count = 0;
        for ( std::vector< SFightExtAbleInfo >::iterator jter = (iter->second).begin();
            jter != (iter->second).end();
            ++jter )
        {
            if ( 0 != count )
                stream << ",";
            SFightExtAbleInfo &fightextable = *jter;
            stream << "(" << guid << "," << fightextable.guid << "," << iter->first << "," << fightextable.able.hp << "," << fightextable.able.physical_ack<< "," << fightextable.able.physical_def << "," << fightextable.able.magic_ack<< "," << fightextable.able.magic_def<< "," << fightextable.able.speed<< "," << fightextable.able.critper<< "," << fightextable.able.critper_def << "," << fightextable.able.recover_critper << "," << fightextable.able.recover_critper_def << "," << fightextable.able.crithurt<<"," << fightextable.able.crithurt_def<<"," << fightextable.able.hitper<<"," << fightextable.able.dodgeper<<"," << fightextable.able.parryper<< "," << fightextable.able.parryper_dec<<"," << fightextable.able.rage<<"," << fightextable.able.stun_def<<"," << fightextable.able.silent_def<<"," << fightextable.able.weak_def<<"," << fightextable.able.fire_def<<"," << fightextable.able.recover_add_fix<<"," << fightextable.able.recover_del_fix<<"," << fightextable.able.recover_add_per<<"," << fightextable.able.recover_del_per<<"," << fightextable.able.rage_add_fix<<"," << fightextable.able.rage_del_fix<<"," << fightextable.able.rage_add_per<<"," << fightextable.able.rage_del_per<<")";
            ++count;
        }
        stream << ";" << std::endl;
    }
}
