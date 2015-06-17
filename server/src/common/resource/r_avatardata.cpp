#include "jsonconfig.h"
#include "r_avatardata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CAvatarData::CAvatarData()
{
}

CAvatarData::~CAvatarData()
{
    resource_clear(id_avatar_map);
}

void CAvatarData::LoadData(void)
{
    CJson jc = CJson::Load( "Avatar" );

    theResDataMgr.insert(this);
    resource_clear(id_avatar_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pavatar                       = new SData;
        pavatar->id                              = to_uint(aj[i]["id"]);
        pavatar->type                            = to_uint(aj[i]["type"]);
        pavatar->model                           = to_uint(aj[i]["model"]);

        Add(pavatar);
        ++count;
        LOG_DEBUG("id:%u,type:%u,model:%u,", pavatar->id, pavatar->type, pavatar->model);
    }
    LOG_INFO("Avatar.xls:%d", count);
}

void CAvatarData::ClearData(void)
{
    for( UInt32AvatarMap::iterator iter = id_avatar_map.begin();
        iter != id_avatar_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_avatar_map.clear();
}

CAvatarData::SData* CAvatarData::Find( uint32 id )
{
    UInt32AvatarMap::iterator iter = id_avatar_map.find(id);
    if ( iter != id_avatar_map.end() )
        return iter->second;
    return NULL;
}

void CAvatarData::Add(SData* pavatar)
{
    id_avatar_map[pavatar->id] = pavatar;
}
