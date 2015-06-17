#ifndef IMMORTAL_GAMESVR_FIGHT_H_
#define IMMORTAL_GAMESVR_FIGHT_H_

#include "common.h"
#include "proto/constant.h"
#include "proto/fight.h"
#include "proto/user.h"

class CFight
{
public:
	CFight();
    virtual ~CFight();

	void AddSoldier( SFight *psfight, uint32 role_id, uint32 camp );
    void AddMonster( SFight *psfight, uint32 role_id, uint32 camp );

    virtual SFight* AddFightToPlayer( SUser *puser, uint32 target_id );
    virtual SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    virtual void SetFightInfo( SFight *psfight );
    virtual void AddBuff( SFight *psfight, uint32 guid, std::vector<SFightOdd> &odd_list );

    virtual void OnFightClientEnd( SFight *psfight, std::vector<S3UInt32>& coin_list );
    virtual void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
    //是否刷新结束战斗后处理一些事情
    virtual bool ExtraDo( SFight *psfight );
    //是否需要check
    virtual bool NeedCheck( SFight *psfight );
};

class CFightCopy : public CFight
{
public:
    virtual SFight* AddFightToMonster( SUser *puser, uint32 target_id );
};

class CFightPlayer : public CFight
{
    SFight* AddFightToPlayer( SUser *puser, uint32 target_id );
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightFirstShow : public CFight
{
public:
    SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
    bool NeedCheck( SFight *psfight );
};

class CFightSingleArenaMonster : public CFight
{
public:
    SFight* AddFightToPlayer( SUser *puser, uint32 target_id );
    SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightTrial : public CFight
{
    SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
};

class CFightTrialSurvival : public CFightTrial
{
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightTrialStrength : public CFightTrial
{
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightTrialAgile : public CFightTrial
{
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightTrialIntelligence : public CFightTrial
{
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightTomb : public CFight
{
    SFight* AddFightToPlayer( SUser *puser, uint32 target_id );
    SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};

class CFightFriend : public CFight
{
    SFight* AddFightToPlayer( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
};

class CFightAuto : public CFight
{
    SFight* AddFightToMonster( SUser *puser, uint32 target_id );
    void SetFightInfo( SFight *psfight );
    void ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins );
};
#endif	//__FIGHTMGR_H__

