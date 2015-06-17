#include "proto/transfrom/transfrom_mail.h"

#include "proto/mail/CMail.h"
#include "proto/mail/SUserMail.h"
#include "proto/mail/PQMailWrite.h"
#include "proto/mail/PQMailTake.h"
#include "proto/mail/PQMailDel.h"
#include "proto/mail/PRMailData.h"
#include "proto/mail/PRMailDataList.h"
#include "proto/mail/PRMailWriteLocal.h"
#include "proto/mail/PQMailReaded.h"
#include "proto/mail/PQMailGetSystemId.h"
#include "proto/mail/PRMailGetSystemId.h"
#include "proto/mail/PQMailSave.h"
#include "proto/mail/PRMailSave.h"
#include "proto/mail/PQMailSystemTake.h"
#include "proto/mail/PRMailSystemTake.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_mail::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 281547260 ] = std::make_pair( "PQMailWrite", msg_transfrom< PQMailWrite > );
    handles[ 632569249 ] = std::make_pair( "PQMailTake", msg_transfrom< PQMailTake > );
    handles[ 364932350 ] = std::make_pair( "PQMailDel", msg_transfrom< PQMailDel > );
    handles[ 1094044067 ] = std::make_pair( "PRMailData", msg_transfrom< PRMailData > );
    handles[ 1082870710 ] = std::make_pair( "PRMailDataList", msg_transfrom< PRMailDataList > );
    handles[ 2126766481 ] = std::make_pair( "PRMailWriteLocal", msg_transfrom< PRMailWriteLocal > );
    handles[ 155252786 ] = std::make_pair( "PQMailReaded", msg_transfrom< PQMailReaded > );
    handles[ 628964938 ] = std::make_pair( "PQMailGetSystemId", msg_transfrom< PQMailGetSystemId > );
    handles[ 1243053845 ] = std::make_pair( "PRMailGetSystemId", msg_transfrom< PRMailGetSystemId > );
    handles[ 435304958 ] = std::make_pair( "PQMailSave", msg_transfrom< PQMailSave > );
    handles[ 1994869338 ] = std::make_pair( "PRMailSave", msg_transfrom< PRMailSave > );
    handles[ 239248455 ] = std::make_pair( "PQMailSystemTake", msg_transfrom< PQMailSystemTake > );
    handles[ 1976428632 ] = std::make_pair( "PRMailSystemTake", msg_transfrom< PRMailSystemTake > );

    return handles;
}

