#include "reportpost_dc.h"
#include "proto/constant.h"
#include "log.h"

void    CReportPostDC::OnLoadData( std::map< uint32, SReportPostInfo >& info_map )
{
    db().reportpost_info_map.insert( info_map.begin(), info_map.end() );
}

SReportPostInfo* CReportPostDC::find_info( uint32 target_id )
{
    std::map< uint32, SReportPostInfo >::iterator iter = db().reportpost_info_map.find( target_id );
    if ( iter == db().reportpost_info_map.end() )
        return NULL;

    SReportPostInfo* info = &(iter->second);
    return info;
}

void CReportPostDC::del_info( uint32 target_id )
{
    std::map< uint32, SReportPostInfo >::iterator iter = db().reportpost_info_map.find( target_id );
    if ( iter == db().reportpost_info_map.end() )
        return;
    db().reportpost_info_map.erase(iter);
}


void CReportPostDC::set_info( uint32 target_id, SReportPostInfo &info )
{
    db().reportpost_info_map[target_id] = info;
}

void CReportPostDC::clear_all( void )
{
    db().reportpost_info_map.clear();
}

