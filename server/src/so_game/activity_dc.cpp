#include "activity_dc.h"
#include "server.h"
#include "log.h"
#include "local.h"
#include "proto/constant.h"
#include "proto/activity.h"

SActivityReward* CActivityDC::find_reward( uint32 guid )
{
    std::map< uint32, SActivityReward >::iterator iter = db().reward_map.find( guid );
    if ( iter == db().reward_map.end() )
        return NULL;

    SActivityReward* p_reward = &(iter->second);
    return p_reward;
}

/**
  void CActivityDC::del_reward( uint32 guid )
  {
  std::map< uint32, SActivityReward >::iterator iter = db().reward_map.find( guid );
  if ( iter == db().reward_map.end() )
  return;

  db().reward_map.erase(iter);

  PQActivityRewardSet rep;
  rep.guid = guid;
  local::write(local::realdb, rep);
  }
 **/


void CActivityDC::set_reward( SActivityReward &reward )
{
    db().reward_map[ reward.guid] = reward;
}

SActivityFactor* CActivityDC::find_factor( uint32 guid )
{
    std::map< uint32, SActivityFactor >::iterator iter = db().factor_map.find( guid );
    if ( iter == db().factor_map.end() )
        return NULL;

    SActivityFactor* p_factor = &(iter->second);
    return p_factor;
}

/**
  void CActivityDC::del_factor( uint32 guid )
  {
  std::map< uint32, SActivityFactor >::iterator iter = db().factor_map.find( guid );
  if ( iter == db().factor_map.end() )
  return;

  db().data_map.erase(iter);

  PQActivityFactorSet rep;
  rep.guid = guid;
  local::write(local::realdb, rep);
  }
 **/


void CActivityDC::set_factor( SActivityFactor &factor )
{
    db().factor_map[ factor.guid] = factor;
}

SActivityData* CActivityDC::find_data( uint32 guid )
{
    std::map< uint32, SActivityData >::iterator iter = db().data_map.find( guid );
    if ( iter == db().data_map.end() )
        return NULL;

    SActivityData* p_data = &(iter->second);
    return p_data;
}

/**
  void CActivityDC::del_data( uint32 guid )
  {
  std::map< uint32, SActivityData >::iterator iter = db().data_map.find( guid );
  if ( iter == db().data_map.end() )
  return;

  db().data_map.erase(iter);

  PQActivityDataSet rep;
  rep.guid = guid;
  local::write(local::realdb, rep);
  }
 **/


void CActivityDC::set_data( SActivityData &data )
{
    db().data_map[ data.guid] = data;
}

SActivityOpen* CActivityDC::find_open_by_guid( uint32 guid )
{
    std::map< uint32, SActivityOpen >::iterator iter = db().open_map.find( guid );
    if ( iter == db().open_map.end() )
        return NULL;

    SActivityOpen* p_open = &(iter->second);
    return p_open;
}

SActivityOpen* CActivityDC::find_open_by_name( std::string& name )
{

    SActivityOpen* p_open = NULL;
    for( std::map< uint32, SActivityOpen >::iterator iter = db().open_map.begin();
        iter != db().open_map.end();
        ++iter )
    {
        if ( name == iter->second.name )
        {
            p_open = &(iter->second);
            break;
        }
    }

    return p_open;
}

/**
  void CActivityDC::del_open( uint32 guid )
  {
  std::map< uint32, SActivityOpen >::iterator iter = db().open_map.find( guid );
  if ( iter == db().open_map.end() )
  return;

  db().open_map.erase(iter);

  PQActivityOpenSet rep;
  rep.guid = guid;
  local::write(local::realdb, rep);
  }
 **/

void CActivityDC::set_open( SActivityOpen &open )
{
    db().open_map[open.guid] = open;
    db().open_name_map[open.name] +=1;
}


void CActivityDC::ReplyActivityList( std::vector< SActivityOpen > &open_list, std::vector< SActivityData > &data_list, std::vector< SActivityFactor > &factor_list, std::vector< SActivityReward > &reward_list )
{
    for( std::map< uint32, SActivityFactor >::iterator iter = db().factor_map.begin();
        iter != db().factor_map.end();
        ++iter )
    {
        factor_list.push_back( iter->second );
    }

    for( std::map< uint32, SActivityReward >::iterator iter = db().reward_map.begin();
        iter != db().reward_map.end();
        ++iter )
    {
        reward_list.push_back( iter->second );
    }

    S2UInt32  temp;
    uint32   flag = 0;
    std::vector< SActivityReward >::iterator reward_iter = reward_list.begin();
    std::vector< SActivityFactor >::iterator factor_iter = factor_list.begin();
    for( std::map< uint32, SActivityData >::iterator iter = db().data_map.begin();
        iter != db().data_map.end();
        ++iter )
    {
        flag = 0;
        for( std::vector< std::string >::iterator i_iter = iter->second.value_list.begin();
            i_iter != iter->second.value_list.end();
            ++i_iter )
        {

            //条件奖励值字段规则错误
            if ( 2 != sscanf( (*i_iter).c_str(), "%u%%%u", &temp.first, &temp.second ) )
            {
                flag = 1;
                break;
            }

            factor_iter = std::find_if( factor_list.begin(), factor_list.end(), FindActivityFactorByGuid( temp.first ) );
            if( factor_iter == factor_list.end() )
            {
                flag = 1;
                break;
            }

            reward_iter = std::find_if( reward_list.begin(), reward_list.end(), FindActivityRewardByGuid( temp.second ) );
            if( reward_iter == reward_list.end() )
            {
                flag = 1;
                break;
            }
        }

        if( flag == 0 )
        {
            data_list.push_back( iter->second );
        }
        else
        {
            LOG_ERROR("activity_data is error guid=%u",iter->second.guid);
        }
    }

    std::vector< SActivityData >::iterator data_iter = data_list.begin();
    for( std::map< uint32, SActivityOpen >::iterator iter = db().open_map.begin();
        iter != db().open_map.end();
        ++iter )
    {
        data_iter = std::find_if( data_list.begin(), data_list.end(), FindActivityDataByGuid( iter->second.data_id ) );

        if( data_iter != data_list.end() )
        {
            open_list.push_back( iter->second );
        }
        else
        {
            LOG_ERROR("activity_open is error guid=%u",iter->second.guid);
        }
    }
}

void CActivityDC::clear_open( void )
{
    db().open_map.clear();
}

void CActivityDC::clear_data( void )
{
    db().data_map.clear();
}

void CActivityDC::clear_factor( void )
{
    db().factor_map.clear();
}

void CActivityDC::clear_reward( void )
{
    db().reward_map.clear();
}

