#ifndef _GAMESVR_REPORTPOST_DC_H_
#define _GAMESVR_REPORTPOST_DC_H_

#include "common.h"
#include "proto/user.h"
#include "proto/reportpost.h"
#include "dc.h"

class CReportPostDC : public TDC< CReportPostMap >
{
public:
    CReportPostDC() : TDC< CReportPostMap >( "reportpost" )
    {
    }

    ~CReportPostDC()
    {
    }


    void    OnLoadData( std::map< uint32, SReportPostInfo >& info_map );



    SReportPostInfo* find_info( uint32 target_id );
    void    del_info( uint32 target_id );
    void    set_info( uint32 target_id, SReportPostInfo &info );
    void    clear_all( void );

};
#define theReportPostDC TSignleton< CReportPostDC >::Ref()

#endif

