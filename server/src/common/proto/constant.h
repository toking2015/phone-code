#ifndef _PROTO_constant_H_
#define _PROTO_constant_H_

#include <weedong/core/os.h>

const uint32 kFalse = 0;
const uint32 kTrue = 1;
const uint32 kYes = 1;
const uint32 kNo = 2;
const uint32 kCancel = 3;
const uint32 kObjectDel = 0;
const uint32 kObjectAdd = 1;
const uint32 kObjectUpdate = 2;
const uint32 kObjectKick = 3;
const uint32 kDialogAgree = 1;
const uint32 kDialogDisAgree = 2;
const uint32 kDialogIgnore = 3;
const uint32 kDialogAgreeButError = 4;
const uint32 kAttrPlayer = 1;
const uint32 kAttrSoldier = 2;
const uint32 kAttrTotem = 3;
const uint32 kAttrMonster = 4;
const uint32 kAttrNpc = 5;
const uint32 kAttrSoldierYesterday = 100;
const uint32 kQualityWhite = 1;
const uint32 kQualityGreen = 2;
const uint32 kQualityBlue = 3;
const uint32 kQualityPurple = 4;
const uint32 kQualityOrange = 5;
const uint32 kEquipCloth = 1;
const uint32 kEquipLeather = 2;
const uint32 kEquipMail = 3;
const uint32 kEquipPlate = 4;
const uint32 kGenderMan = 0;
const uint32 kGenderWomen = 1;
const uint32 kBoxQualityCopper = 1;
const uint32 kBoxQualitySilver = 2;
const uint32 kBoxQualityGolden = 3;

namespace constant
{
    const char* get_path_name( uint32 val );
}

#endif
