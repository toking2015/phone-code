#ifndef IMMORTAL_COMMON_RESOURCE_R_GUTDATA_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUTDATA_H_

#include "proto/common.h"
#include "r_basedata.h"
#include "resource.h"

class CGutData : public CBaseData
{
public:
    struct SData
    {
        uint32                                  id;
        uint32                                  step;
        uint32                                  type;
        uint32                                  target;
        uint32                                  face;
        uint32                                  move_face;
        uint32                                  move_speed;
        uint32                                  attr;
        std::string                             talk;
        uint32                                  monster;
        uint32                                  reward;
        uint32                                  box;
        std::string                             video;
        std::string                             sound;
        uint32                                  weather;
        uint32                                  shock;
        uint32                                  shaking_screen;
        uint32                                  red_screen;
        std::string                             special;
        S3UInt32                                take_coin;
    };

	typedef std::map<uint32, std::map<uint32, SData*> >UInt32GutMap;

	CGutData();
	virtual ~CGutData();
	virtual void LoadData(void);
	void ClearData(void);
	SData * Find( uint32 id, uint32 step );

protected:
	UInt32GutMap id_gut_map;
	void Add(SData* gut);
};
#endif  //IMMORTAL_COMMON_RESOURCE_R_GUTMGR_H_
