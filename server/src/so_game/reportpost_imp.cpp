#include "reportpost_imp.h"
#include "reportpost_dc.h"
#include "proto/constant.h"
#include "var_imp.h"
#include "user_imp.h"
#include "user_dc.h"
#include "local.h"
#include "common.h"
#include "log.h"
#include "pro.h"
#include "server.h"
#include "resource/r_globalext.h"

struct Report_EqualGuid
{
    uint32 guid;
    Report_EqualGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const uint32& id)
    {
        return id == guid;
    }
};

namespace reportpost
{

void    Report( SUser* puser, SUser* target )
{
    if( puser->data.simple.team_level < 20 )
        return;

    PRReportPostMake rep;
    bccopy( rep, puser->ext );
    rep.target_id = target->guid;
    local::write(local::access, rep);

    uint32 time_now  = server::local_time();
    uint32 time_day  = server::local_6_time( time_now, 1);

    if ( puser->data.other.chat_ban_endtime > time_now )
        return;


    SReportPostInfo* pinfo = theReportPostDC.find_info( target->guid );
    if( NULL == pinfo )
    {
        SReportPostInfo d_info;
        d_info.target_id    = target->guid;
        d_info.report_time  = time_day;
        d_info.report_list.push_back( puser->guid );

        theReportPostDC.set_info( d_info.target_id, d_info );

        UpdateInfoToDB( kObjectAdd, d_info.target_id, puser->guid, d_info.report_time );

    }
    else
    {
        std::vector<uint32>::iterator iter = std::find_if( pinfo->report_list.begin(), pinfo->report_list.end(), Report_EqualGuid( puser->guid ) );
        if( iter != pinfo->report_list.end() )
            return;

        pinfo->report_list.push_back( puser->guid );

        uint32 max_count  =  theGlobalExt.get<uint32>("reportpost_max_count");
        uint32 ban_times  =  var::get( target, "reportpost_ban_times");

        if( (uint32)pinfo->report_list.size() >= max_count )
        {
            UpdateInfoToDB( kObjectDel, target->guid, 0, 0 );
            theReportPostDC.del_info( target->guid );

            uint32 ban_time = 0;
            if( ban_times > 0 )
                ban_time  = theGlobalExt.get<uint32>("reportpost_ban_time_limit_two");
            else
                ban_time  = theGlobalExt.get<uint32>("reportpost_ban_time_limit_one");


            target->data.other.chat_ban_endtime  =   time_now + ban_time * 60;
            user::ReplyUserOther( target );


            var::set( target, "reportpost_ban_times", ban_times+1, time_day);

            pinfo->report_list.clear();

            return;
        }

        UpdateInfoToDB( kObjectAdd, target->guid, puser->guid, pinfo->report_time );

    }
}

void    UpdateInfoToDB( uint8 set_type, uint32 target_id, uint32 report_id, uint32 report_time )
{
    PQReportPostUpdate rep;

    rep.set_type        = set_type;
    rep.target_id       = target_id;
    rep.report_id       = report_id;
    rep.report_time     = report_time;

    local::write(local::realdb, rep);
}

void    UserLoaded( SUser* puser )
{
    uint32 time_now   = server::local_time();
    SReportPostInfo* pinfo = theReportPostDC.find_info( puser->guid );
    if( pinfo && time_now >= pinfo->report_time  )
    {
        pinfo->report_list.clear();
        UpdateInfoToDB( kObjectDel, puser->guid, 0, 0 );
    }
}

void    TimeLimit( SUser* puser )
{
    SReportPostInfo* pinfo = theReportPostDC.find_info( puser->guid );

    if( pinfo )
    {
        pinfo->report_list.clear();
        UpdateInfoToDB( kObjectDel, puser->guid, 0, 0 );
    }
}

} // namespace reportpost

