#include "jsonconfig.h"
#include "r_itemdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CItemData::CItemData()
{
}

CItemData::~CItemData()
{
    resource_clear(id_item_map);
}

void CItemData::LoadData(void)
{
    CJson jc = CJson::Load( "Item" );

    theResDataMgr.insert(this);
    resource_clear(id_item_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pitem                         = new SData;
        pitem->id                              = to_uint(aj[i]["id"]);
        pitem->model                           = to_uint(aj[i]["model"]);
        pitem->locale_id                       = to_uint(aj[i]["locale_id"]);
        pitem->name                            = to_str(aj[i]["name"]);
        pitem->icon                            = to_uint(aj[i]["icon"]);
        pitem->icon_resource                   = to_str(aj[i]["icon_resource"]);
        pitem->type                            = to_uint(aj[i]["type"]);
        pitem->client_type                     = to_uint(aj[i]["client_type"]);
        pitem->subclass                        = to_uint(aj[i]["subclass"]);
        pitem->equip_type                      = to_uint(aj[i]["equip_type"]);
        pitem->level                           = to_uint(aj[i]["level"]);
        pitem->limitlevel                      = to_uint(aj[i]["limitlevel"]);
        pitem->stackable                       = to_uint(aj[i]["stackable"]);
        pitem->occupation                      = to_uint(aj[i]["occupation"]);
        pitem->quality                         = to_uint(aj[i]["quality"]);
        pitem->bind                            = to_uint(aj[i]["bind"]);
        pitem->del_bind                        = to_uint(aj[i]["del_bind"]);
        pitem->due_time                        = to_uint(aj[i]["due_time"]);
        pitem->unique                          = to_uint(aj[i]["unique"]);
        pitem->drop_dead                       = to_uint(aj[i]["drop_dead"]);
        pitem->drop_logout                     = to_uint(aj[i]["drop_logout"]);
        pitem->auto_buy_gold                   = to_uint(aj[i]["auto_buy_gold"]);
        std::string coin_string = aj[i]["coin"].asString();
        sscanf( coin_string.c_str(), "%u%%%u%%%u", &pitem->coin.cate, &pitem->coin.objid, &pitem->coin.val );
        pitem->auto_sell                       = to_uint(aj[i]["auto_sell"]);
        S2UInt32 attrs;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "attrs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &attrs.first, &attrs.second ) )
                break;
            pitem->attrs.push_back(attrs);
        }
        S2UInt32 slave_attrs;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "slave_attrs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &slave_attrs.first, &slave_attrs.second ) )
                break;
            pitem->slave_attrs.push_back(slave_attrs);
        }
        pitem->multiuse                        = to_uint(aj[i]["multiuse"]);
        std::string buff_string = aj[i]["buff"].asString();
        sscanf( buff_string.c_str(), "%u%%%u%%%u", &pitem->buff.cate, &pitem->buff.objid, &pitem->buff.val );
        pitem->bias_id                         = to_uint(aj[i]["bias_id"]);
        pitem->can_exchange                    = to_uint(aj[i]["can_exchange"]);
        pitem->can_sell                        = to_uint(aj[i]["can_sell"]);
        pitem->can_drop                        = to_uint(aj[i]["can_drop"]);
        pitem->can_grant                       = to_uint(aj[i]["can_grant"]);
        pitem->cooltime                        = to_uint(aj[i]["cooltime"]);
        pitem->oddid                           = to_uint(aj[i]["oddid"]);
        pitem->marktype                        = to_uint(aj[i]["marktype"]);
        pitem->desc                            = to_str(aj[i]["desc"]);
        pitem->soul_score                      = to_uint(aj[i]["soul_score"]);
        pitem->open_cost                       = to_uint(aj[i]["open_cost"]);
        pitem->src_item_id                     = to_uint(aj[i]["src_item_id"]);
        S2UInt32 sources;
        for ( uint32 j = 1; j <= 10; ++j )
        {
            std::string buff = strprintf( "sources%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &sources.first, &sources.second ) )
                break;
            pitem->sources.push_back(sources);
        }

        Add(pitem);
        ++count;
        LOG_DEBUG("id:%u,model:%u,locale_id:%u,name:%s,icon:%u,icon_resource:%s,type:%u,client_type:%u,subclass:%u,equip_type:%u,level:%u,limitlevel:%u,stackable:%u,occupation:%u,quality:%u,bind:%u,del_bind:%u,due_time:%u,unique:%u,drop_dead:%u,drop_logout:%u,auto_buy_gold:%u,auto_sell:%u,multiuse:%u,bias_id:%u,can_exchange:%u,can_sell:%u,can_drop:%u,can_grant:%u,cooltime:%u,oddid:%u,marktype:%u,desc:%s,soul_score:%u,open_cost:%u,src_item_id:%u,", pitem->id, pitem->model, pitem->locale_id, pitem->name.c_str(), pitem->icon, pitem->icon_resource.c_str(), pitem->type, pitem->client_type, pitem->subclass, pitem->equip_type, pitem->level, pitem->limitlevel, pitem->stackable, pitem->occupation, pitem->quality, pitem->bind, pitem->del_bind, pitem->due_time, pitem->unique, pitem->drop_dead, pitem->drop_logout, pitem->auto_buy_gold, pitem->auto_sell, pitem->multiuse, pitem->bias_id, pitem->can_exchange, pitem->can_sell, pitem->can_drop, pitem->can_grant, pitem->cooltime, pitem->oddid, pitem->marktype, pitem->desc.c_str(), pitem->soul_score, pitem->open_cost, pitem->src_item_id);
    }
    LOG_INFO("Item.xls:%d", count);
}

void CItemData::ClearData(void)
{
    for( UInt32ItemMap::iterator iter = id_item_map.begin();
        iter != id_item_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_item_map.clear();
}

CItemData::SData* CItemData::Find( uint32 id )
{
    UInt32ItemMap::iterator iter = id_item_map.find(id);
    if ( iter != id_item_map.end() )
        return iter->second;
    return NULL;
}

void CItemData::Add(SData* pitem)
{
    id_item_map[pitem->id] = pitem;
}
