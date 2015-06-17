#include "proto/transfrom/transfrom_auth.h"

#include "proto/auth/SAuthRunTime.h"
#include "proto/auth/SAuthRunData.h"
#include "proto/auth/CAuth.h"
#include "proto/auth/PQAuthRunJson.h"
#include "proto/auth/PQAuthRunTimeSet.h"
#include "proto/auth/PRAuthRunTimeSet.h"
#include "proto/auth/PQAuthRunTimeList.h"
#include "proto/auth/PRAuthRunTimeList.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_auth::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 110123182 ] = std::make_pair( "PQAuthRunJson", msg_transfrom< PQAuthRunJson > );
    handles[ 149382596 ] = std::make_pair( "PQAuthRunTimeSet", msg_transfrom< PQAuthRunTimeSet > );
    handles[ 1140596663 ] = std::make_pair( "PRAuthRunTimeSet", msg_transfrom< PRAuthRunTimeSet > );
    handles[ 337467577 ] = std::make_pair( "PQAuthRunTimeList", msg_transfrom< PQAuthRunTimeList > );
    handles[ 1110885674 ] = std::make_pair( "PRAuthRunTimeList", msg_transfrom< PRAuthRunTimeList > );

    return handles;
}

