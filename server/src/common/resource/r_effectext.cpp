#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_effectext.h"

uint32 CEffectExt::GetValue( uint32 value, uint32 mode, uint32 base )
{
    if ( 0 == mode )
        return value;
    else
    {
        if ( 0 == base )
            return 0;
        return (uint32)( value * base / 10000 );
    }
}

SFightExtAble CEffectExt::ToFightExtAble( uint32 id, SFightExtAble base, uint32 value )
{
    SFightExtAble ext_able;
    CEffectData::SData *effect = Find(id);
    if ( NULL == effect )
        return ext_able;

    switch( ( id > 127 ) ? ( id - 127 ) : id )
    {
        case kEffectHP:
            ext_able.hp = GetValue( value, effect->mode, base.hp );
            break;
        case kEffectPhysicalAck:
            ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
            break;
        case kEffectPhysicalDef:
            ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
            break;
        case kEffectMagicAck:
            ext_able.magic_ack = GetValue( value, effect->mode, base.magic_ack);
            break;
        case kEffectMagicDef:
            ext_able.magic_def = GetValue( value, effect->mode, base.magic_def);
            break;
        case kEffectSpeed:
            ext_able.speed = GetValue( value, effect->mode, base.speed);
            break;
        case kEffectCrit:
            ext_able.critper = GetValue( value, effect->mode, base.critper);
            break;
        case kEffectCritDef:
            ext_able.critper_def = GetValue( value, effect->mode, base.critper_def);
            break;
        case kEffectRecoverCrit:
            ext_able.recover_critper = GetValue( value, effect->mode, base.recover_critper);
            break;
        case kEffectRecoverCritDef:
            ext_able.recover_critper_def = GetValue( value, effect->mode, base.recover_critper_def);
            break;
        case kEffectCritHurt:
            ext_able.crithurt = GetValue( value, effect->mode, base.crithurt);
            break;
        case kEffectCritHurtDef:
            ext_able.crithurt_def = GetValue( value, effect->mode, base.crithurt_def);
            break;
        case kEffectHit:
            ext_able.hitper = GetValue( value, effect->mode, base.hitper);
            break;
        case kEffectDodge:
            ext_able.dodgeper = GetValue( value, effect->mode, base.dodgeper);
            break;
        case kEffectParry:
            ext_able.parryper = GetValue( value, effect->mode, base.parryper);
            break;
        case kEffectParryDec:
            ext_able.parryper_dec = GetValue( value, effect->mode, base.parryper_dec);
            break;
        case kEffectStunDef:
            ext_able.stun_def = GetValue( value, effect->mode, base.stun_def);
            break;
        case kEffectSilentDef:
            ext_able.silent_def = GetValue( value, effect->mode, base.silent_def);
            break;
        case kEffectWeakDef:
            ext_able.weak_def = GetValue( value, effect->mode, base.weak_def);
            break;
        case kEffectFireDef:
            ext_able.fire_def = GetValue( value, effect->mode, base.fire_def);
            break;
        case kEffectRecoverAddFix:
            ext_able.recover_add_fix = GetValue( value, effect->mode, base.recover_add_fix );
            break;
        case kEffectRecoverDelFix:
            ext_able.recover_del_fix = GetValue( value, effect->mode, base.recover_del_fix );
            break;
        case kEffectRecoverAddPer:
            ext_able.recover_add_per = GetValue( value, effect->mode, base.recover_add_per );
            break;
        case kEffectRecoverDelPer:
            ext_able.recover_del_per = GetValue( value, effect->mode, base.recover_del_per );
            break;
        case kEffectRageAddFix:
            ext_able.rage_add_fix = GetValue( value, effect->mode, base.rage_add_fix );
            break;
        case kEffectRageDelFix:
            ext_able.rage_del_fix = GetValue( value, effect->mode, base.rage_del_fix );
            break;
        case kEffectRageAddPer:
            ext_able.rage_add_per = GetValue( value, effect->mode, base.rage_add_per );
            break;
        case kEffectRageDelPer:
            ext_able.rage_del_per = GetValue( value, effect->mode, base.rage_del_per );
            break;
        case kEffectAllAttr:
            {
                //ext_able.hp = GetValue( value, effect->mode, base.hp );
                ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
                ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
                ext_able.magic_ack = GetValue( value, effect->mode, base.magic_ack);
                ext_able.magic_def = GetValue( value, effect->mode, base.magic_def);
                ext_able.speed = GetValue( value, effect->mode, base.speed);
            }
            break;
        case kEffectDef:
            {
                ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
                ext_able.magic_def = GetValue( value, effect->mode, base.magic_def);
            }
            break;
        case kEffectAck:
            {
                ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
                ext_able.magic_ack = GetValue( value, effect->mode, base.magic_ack);
            }
            break;
        case kEffectPhysical:
            {
                ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
                ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
            }
            break;
        case kEffectCountryFightBuff:
            {
                ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
                ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
                ext_able.magic_ack = GetValue( value, effect->mode, base.magic_ack);
                ext_able.magic_def = GetValue( value, effect->mode, base.magic_def);
                ext_able.speed = GetValue( value, effect->mode, base.speed);
            }
            break;
        case kEffectTrialBuff:
            {
                ext_able.hp = GetValue( value, effect->mode, base.hp );
                ext_able.physical_ack = GetValue( value, effect->mode, base.physical_ack);
                ext_able.physical_def = GetValue( value, effect->mode, base.physical_def);
                ext_able.magic_ack = GetValue( value, effect->mode, base.magic_ack);
                ext_able.magic_def = GetValue( value, effect->mode, base.magic_def);
                ext_able.speed = GetValue( value, effect->mode, base.speed);
                ext_able.critper = GetValue( value, effect->mode, base.critper );
                ext_able.critper_def = GetValue( value, effect->mode, base.critper_def );
                ext_able.recover_critper = GetValue( value, effect->mode, base.recover_critper );
                ext_able.recover_critper_def = GetValue( value, effect->mode, base.recover_critper_def );
                ext_able.crithurt = GetValue( value, effect->mode, base.crithurt );
                ext_able.crithurt_def = GetValue( value, effect->mode, base.crithurt_def );
                ext_able.hitper = GetValue( value, effect->mode, base.hitper );
                ext_able.dodgeper = GetValue( value, effect->mode, base.dodgeper );
                ext_able.parryper = GetValue( value, effect->mode, base.parryper );
                ext_able.parryper_dec = GetValue( value, effect->mode, base.parryper_dec );
            }
            break;
        default:
            break;
    }
    return ext_able;

}

SFightExtAble CEffectExt::AddFightExtAble( SFightExtAble first, SFightExtAble second )
{
    SFightExtAble ext_able;
    ext_able.hp = first.hp + second.hp;
    ext_able.physical_ack = first.physical_ack + second.physical_ack;
    ext_able.physical_def = first.physical_def + second.physical_def;
    ext_able.magic_ack = first.magic_ack + second.magic_ack;
    ext_able.magic_def = first.magic_def + second.magic_def;
    ext_able.speed = first.speed + second.speed;
    ext_able.critper = first.critper + second.critper;
    ext_able.critper_def = first.critper_def + second.critper_def;
    ext_able.recover_critper = first.recover_critper + second.recover_critper;
    ext_able.recover_critper_def = first.recover_critper_def + second.recover_critper_def;
    ext_able.crithurt = first.crithurt + second.crithurt;
    ext_able.crithurt_def = first.crithurt_def + second.crithurt_def;
    ext_able.hitper = first.hitper + second.hitper;
    ext_able.dodgeper = first.dodgeper + second.dodgeper;
    ext_able.parryper = first.parryper + second.parryper;
    ext_able.parryper_dec = first.parryper_dec + second.parryper_dec;
    ext_able.stun_def = first.stun_def + second.stun_def;
    ext_able.silent_def = first.silent_def + second.silent_def;
    ext_able.weak_def = first.weak_def + second.weak_def;
    ext_able.fire_def = first.fire_def + second.fire_def;
    ext_able.rage = first.rage + second.rage;
    return ext_able;
}

SFightExtAble CEffectExt::SubFightExtAble( SFightExtAble first, SFightExtAble second )
{
    SFightExtAble ext_able;
    ext_able.hp = first.hp > second.hp ? first.hp - second.hp : 0;
    ext_able.physical_ack = first.physical_ack > second.physical_ack ? first.physical_ack - second.physical_ack : 0;
    ext_able.physical_def = first.physical_def > second.physical_def ? first.physical_def - second.physical_def : 0;
    ext_able.magic_ack = first.magic_ack > second.magic_ack ? first.magic_ack - second.magic_ack : 0;
    ext_able.magic_def = first.magic_def > second.magic_def ? first.magic_def - second.magic_def : 0;
    ext_able.speed = first.speed > second.speed ? first.speed - second.speed : 0;
    ext_able.critper = first.critper > second.critper ? first.critper - second.critper : 0;
    ext_able.critper_def = first.critper_def > second.critper_def ? first.critper_def - second.critper_def : 0;
    ext_able.recover_critper = first.recover_critper > second.recover_critper ? first.recover_critper - second.recover_critper : 0;
    ext_able.recover_critper_def = first.recover_critper_def > second.recover_critper_def ? first.recover_critper_def - second.recover_critper_def : 0;
    ext_able.crithurt = first.crithurt > second.crithurt ? first.crithurt - second.crithurt : 0;
    ext_able.crithurt_def = first.crithurt_def > second.crithurt_def ? first.crithurt_def - second.crithurt_def : 0;
    ext_able.hitper = first.hitper > second.hitper ? first.hitper - second.hitper : 0;
    ext_able.dodgeper = first.dodgeper > second.dodgeper ? first.dodgeper - second.dodgeper : 0;
    ext_able.parryper = first.parryper > second.parryper ? first.parryper - second.parryper : 0;
    ext_able.parryper_dec = first.parryper_dec > second.parryper_dec ? first.parryper_dec - second.parryper_dec : 0;
    ext_able.stun_def = first.stun_def > second.stun_def ? first.stun_def - second.stun_def : 0;
    ext_able.silent_def = first.silent_def > second.silent_def ? first.silent_def - second.silent_def : 0;
    ext_able.weak_def = first.weak_def > second.weak_def ? first.weak_def - second.weak_def : 0;
    ext_able.fire_def = first.fire_def > second.fire_def ? first.fire_def - second.fire_def : 0;
    ext_able.rage = first.rage > second.rage ? first.rage - second.rage : 0;
    return ext_able;
}
