#include "proto/transfrom/transfrom_client.h"

#include "proto/client/SLocalData.h"
#include "proto/client/SFightClientSkillObject.h"
#include "proto/client/SFightClientRoundData.h"
#include "proto/client/SFightClientSeed.h"
#include "proto/client/SFightClientLog.h"
#include "proto/client/SEffectSound.h"
#include "proto/client/STimeShaftSound.h"
#include "proto/client/SBodySound.h"
#include "proto/client/SSoundData.h"
#include "proto/client/SPhoneActionEffect.h"
#include "proto/client/SPhoneAction.h"
#include "proto/client/SPhoneBody.h"
#include "proto/client/SPhoneData.h"
#include "proto/client/SEffectItem.h"
#include "proto/client/SEffect.h"
#include "proto/client/SEffectData.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_client::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;


    return handles;
}

