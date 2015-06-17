#ifndef _chat_H_
#define _chat_H_

#include "proto/common.h"

const uint32 kPathGameMasterCommand = 25800757;
const uint32 kErrChatSoundNotExist = 82271493;

#include "proto/chat/PQChatContent.h"
#include "proto/chat/PRChatContent.h"
#include "proto/chat/PQChatSound.h"
#include "proto/chat/PRChatSound.h"
#include "proto/chat/PQChatBan.h"
#include "proto/chat/PQChatGetTotem.h"
#include "proto/chat/PRChatGetTotem.h"
#include "proto/chat/PQChatGetSoldier.h"
#include "proto/chat/PRChatGetSoldier.h"
#include "proto/chat/PQChatGetEquip.h"
#include "proto/chat/PRChatGetEquip.h"

#endif
