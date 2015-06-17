#ifndef _GAME_CHAT_EVENT_H_
#define _GAME_CHAT_EVENT_H_

#include "event.h"

struct SEventChat : public SEvent
{
    std::string& text;
    uint16 broad_cast;
    uint16 broad_type;
    uint32 broad_id;

    SEventChat( SUser* u, std::string& t, uint16 cast, uint16 type, uint32 id ) :
        SEvent( u, 0 ), text(t), broad_cast(cast), broad_type(type), broad_id(id) {}
};

#endif

