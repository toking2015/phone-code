#ifndef _IMMORTAL_SO_GAME_COIN_EVENT_H_
#define _IMMORTAL_SO_GAME_COIN_EVENT_H_

#include "event.h"

//货币变更事件
struct SEventCoin : public SEvent
{
    S3UInt32 coin;          //[获得/扣取]的货币
    uint32 set_type;        //kObjectAdd, kObjectDel
    uint32 old_val;         //原有数量

    SEventCoin
    (
        SUser* u,           //用户指针
        uint32 p,           //途径          path    - kPathYYY
        uint32 c,           //货币类型      cate    - kCoinXXX
        uint32 o,           //货币扩展值    objid   - [ soldier_id | item_id | ... ]
        uint32 v,           //货币值        val
        uint32 t,           //操作方式      set_type - [ kObjectAdd | kObjectDel ]
        uint32 ov           //原有值        old_val
    ) : SEvent( u, p ), set_type(t), old_val(ov){ coin.cate = c; coin.objid = o; coin.val = v; }
};

#endif
