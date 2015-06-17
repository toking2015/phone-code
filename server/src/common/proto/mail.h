#ifndef _mail_H_
#define _mail_H_

#include "proto/common.h"

const uint32 kMailFlagReaded = 1;
const uint32 kMailFlagTake = 2;
const uint32 kMailFlagSystem = 4;
const uint32 kMailFlagAutoDel = 8;
const uint32 kMailTypePlayer = 0;
const uint32 kMailTypeAll = 1;
const uint32 kMailTypeOnline = 2;
const uint32 kPathMailUserSend = 1831050662;
const uint32 kErrMailTargetNotExist = 198160320;
const uint32 kErrMailSubjectFormat = 174397825;
const uint32 kErrMailBodyFormat = 846099063;
const uint32 kErrMailNotExist = 69921612;
const uint32 kErrMailAttachmentEmpty = 1650907036;

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

#endif
