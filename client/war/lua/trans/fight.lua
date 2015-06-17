local const = trans.const
local err = trans.err
local base = trans.base

const.kPathDrop		= 659351692		-- 战斗怪物掉落
const.kPathFightNormal		= 595290871		-- 普通战斗
const.kFightDelayTime		= 60		-- 延迟SkillTime
const.kSkillDoubleAckPhysicalID		= 10		-- 物理连击
const.kSkillDoubleAckMagicID		= 11		-- 魔法连击
const.kSkillAntiAttackPhysicalID		= 12		-- 物理反击
const.kSkillAntiAttackMagicID		= 13		-- 魔法反击
const.kSkillPursuitPhysicalID		= 14		-- 物理追击
const.kSkillPursuitMagicID		= 15		-- 魔法追击
const.kOddBreakID		= 101		-- 打断BUFF
const.kOddFireID		= 102		-- 燃烧ID
const.kOddDefineID		= 103		-- 护盾ID
const.kFightAttrDoubleHit		= 1		-- 连击
const.kFightAttrAntiAttack		= 2		-- 反击
const.kFightAttrPursuit		= 3		-- 追击
const.kFightAttrAttactReboundPer		= 4		-- 反震
const.kFightAttrRevive		= 5		-- 复活
const.kFightAttrBomb		= 6		-- 爆炸
const.kFightAttrTripleHit		= 7		-- 三连击
const.kFightAttrCall		= 8		-- 召唤
const.kFightAttrConfusion		= 9		-- 混乱
const.kFightAttrChange		= 10		-- 变身
const.kFightAttrDeadCall		= 11		-- 死亡复活
const.kFightAttrCounter		= 12		-- 反制
const.kFightAttrNoDisillusion		= 13		-- 不能觉醒
const.kFightAttrTotemValueShow		= 14		-- 显示图腾增加的值
const.kFightAttrRebound		= 15		-- 反弹
const.kFightDicHP		= 1		-- 减血
const.kFightAddHP		= 2		-- 加血
const.kFightAddRage		= 3		-- 战斗加怒气
const.kFightDicRage		= 4		-- 战斗减怒气
const.kFightNoHurt		= 5		-- 不造成伤害 
const.kFightChange		= 6		-- 换队
const.kFightMelee		= 1		-- 近战
const.kFightRanged		= 2		-- 远程
const.kFightRoundInit		= 1		-- 回合初始化
const.kFightRoundAuto		= 10000		-- 回合设置自动手动
const.kFightRoundEnd		= 3		-- 大队回合结束
const.kFightTargetOpposite		= 1		-- 对方
const.kFightTargetSelf		= 2		-- 己方
const.kFightTypeCommon		= 1		-- 普通战斗
const.kFightTypeCopy		= 2		-- 副本战斗
const.kFightTypeCommonPlayer		= 3		-- 普通玩家对战
const.kFightTypeFirstShow		= 4		-- 首场战斗
const.kFightTypeSingleArenaMonster		= 5		-- 竞技场假人
const.kFightTypeSingleArenaPlayer		= 6		-- 竞技场玩家
const.kFightTypeTrialSurvival		= 7		-- 生存 
const.kFightTypeTrialStrength		= 8		-- 力量
const.kFightTypeTrialAgile		= 9		-- 敏捷
const.kFightTypeTrialIntelligence		= 10		-- 智力 
const.kFightTypeTomb		= 11		-- 大墓地 
const.kFightTypeFriend		= 12		-- 好友挑战
const.kFightTypeCommonAuto		= 13		-- 假战斗
const.kFightLeft		= 1		-- 左
const.kFightRight		= 2		-- 右
const.kFightConditionHit		= 0		-- 击中
const.kFightConditionNothing		= 1		-- 无条件
const.kFightCommon		= 1		-- 普通攻击
const.kFightCrit		= 2		-- 暴击
const.kFightDodge		= 3		-- 闪避
const.kFightParry		= 4		-- 格挡
const.kFightPhysical		= 1		-- 物理攻击
const.kFightMagic		= 2		-- 法术攻击
const.kFightHPRecover		= 3		-- 恢复HP
const.kFightAttackHp		= 4		-- 技能攻击力加血
const.kFightBuff		= 5		-- BUFF技能
const.kFightClearOdd		= 6		-- 清除ODD
const.kFightHPRecoverTotem		= 7		-- 回复HP图腾
const.kFightStateCreateOK		= 1		-- 创建战斗OK
const.kFightStateDataOK		= 2		-- 战斗数据OK
const.SKILL_DOUBLEATTACK_PHYSICAL_ID		= 1		-- 物理连击
const.SKILL_DOUBLEATTACK_MAGIC_ID		= 2		-- 法术连击
const.SKILL_PURSUIT_PHYSICAL_ID		= 3		-- 物理追击
const.SKILL_PURSUIT_MAGIC_ID		= 4		-- 法术追击
const.SKILL_ANTIATTACK_PHYSICAL_ID		= 5		-- 物理反击
const.SKILL_ANTIATTACK_MAGIC_ID		= 6		-- 法术反击
const.ODD_COMMON_LEVEL		= 1		-- 系统异常统一等级
const.ODD_DEF_FIXED_ID		= 1		-- 盾
const.ODD_STUN_ID		= 2		-- 眩晕
const.kEffectHP		= 1		-- 气血
const.kEffectPhysicalAck		= 2		-- 物理攻击
const.kEffectPhysicalDef		= 3		-- 物理防御
const.kEffectMagicAck		= 4		-- 法术攻击
const.kEffectMagicDef		= 5		-- 法术防御
const.kEffectSpeed		= 6		-- 速度
const.kEffectCrit		= 7		-- 致命一击
const.kEffectCritDef		= 8		-- 致命一击抵抗
const.kEffectCritHurt		= 9		-- 致命伤害
const.kEffectCritHurtDef		= 10		-- 致命减免
const.kEffectHit		= 11		-- 命中
const.kEffectDodge		= 12		-- 闪避
const.kEffectParry		= 13		-- 格档
const.kEffectParryDec		= 14		-- 破格档
const.kEffectStunDef		= 15		-- 眩晕抗性
const.kEffectSilentDef		= 16		-- 沉默抗性
const.kEffectWeakDef		= 17		-- 虚弱抗性
const.kEffectFireDef		= 18		-- 火灼抗性
const.kEffectRage		= 28		-- 出场怒气
const.kEffectAllAttr		= 36		-- 全属性
const.kEffectDef		= 37		-- 防御
const.kEffectAck		= 38		-- 攻击
const.kEffectCountryFightBuff		= 39		-- 国战BUFF
const.kEffectPhysical		= 40		-- 物理
const.kEffectAckSpeed		= 42		-- 攻击和速度
const.kEffectRecoverCrit		= 43		-- 回血暴击
const.kEffectRecoverCritDef		= 44		-- 回血暴击抵抗
const.kEffectRecoverAddFix		= 45		-- 回血添加
const.kEffectRecoverDelFix		= 46		-- 回血减少
const.kEffectRecoverAddPer		= 47		-- 回血添加
const.kEffectRecoverDelPer		= 48		-- 回血减少
const.kEffectRageAddFix		= 49		-- 怒气添加
const.kEffectRageDelFix		= 50		-- 怒气减少
const.kEffectRageAddPer		= 51		-- 怒气添加
const.kEffectRageDelPer		= 52		-- 怒气减少
const.kEffectTrialBuff		= 53		-- 试炼全属性
const.kFightIndexFront		= 1		-- 前排
const.kFightIndexMid		= 2		-- 中排
const.kFightIndexBack		= 3		-- 后排
const.kFightIndexFirst		= 1		-- 第一行
const.kFightIndexSecond		= 2		-- 第二行
const.kFightIndexThird		= 3		-- 第三行
const.kFightSkillCommon		= 1		-- 随机
const.kFightSkillAll		= 2		-- 全体
const.kFightSkillHPMin		= 3		-- 生命最低
const.kFightSkillFront		= 4		-- 前排
const.kFightSkillMid		= 5		-- 中排
const.kFightSkillBack		= 6		-- 后排
const.kFightSkillFrontMid		= 7		-- 前中排
const.kFightSkillMidBack		= 8		-- 中后排
const.kFightSkillCurrentRow		= 9		-- 当前路
const.kFightSkillCurrentRowLast		= 10		-- 当前路最后一个
const.kFightSkillRandom		= 11		-- 随机不重复
const.kFightSkillRandomN		= 12		-- 随机重复
const.kFightSkillSelf		= 13		-- 自己
const.kFightSkillOccu		= 14		-- 职业
const.kFightSkillTenRandom		= 15		-- 十字随机
const.kFightSkillTenSelf		= 16		-- 十字自己
const.kFightSkillCurrentRowFirst		= 17		-- 当前路
const.kFightSkillCurrentRowRandom		= 18		-- 当前路随机
const.kFightSkillRandomNotSelf		= 19		-- 随机不包含自己
const.kFightSkillEquip		= 20		-- 装备类型
const.kFightSkillRandom2N		= 21		-- 需要增加一个2-n的随机目标,n为target_range_count
const.kFightSkillHPMinFix		= 22		-- 需要增加一个血量最少的目标
const.kFightSkillAttackMax		= 23		-- 先挑出目标的物攻和法攻最大者
const.kFightSkillHPMinNotSelf		= 24		-- 最小不包含自己
const.kFightSkillStunFirst		= 25		-- 眩晕的先
const.kFightSkillCommonTen		= 26		-- 按照正常的攻击顺序选择第一个目标，然后以他为中心的十字形
const.kFightSkillRage		= 27		-- 怒气最高的目标
const.kFightSkillSilentFirst		= 28		-- 沉默目标
const.kFightSkillConfusionFirst		= 29		-- 混乱的目标
const.kFightSkillCurrentRowLastTen		= 30		-- 新增技能攻击范围，以当前路最后一人为中心的十字形攻击
const.kFightSkillStatusId		= 31		-- 给敌方中了某个statusid的人添加一个buff 
const.kFightSkillRandom1N		= 32		-- 需要增加一个1-n的随机目标,n为target_range_count
const.kFightSkillRage1N		= 33		-- 怒气最高的目标1-N
const.kFightEffectTypeBuff		= 1		-- 增益属性
const.kFightEffectTypeDebuff		= 2		-- 减益属性
const.kFightOddAttrDebuff		= 1		-- 减益属性
const.kFightOddAttrBuff		= 2		-- 增益属性
const.kFightOddAttrCantDel		= 3		-- 不能删除
const.kFightOddTypeControl		= 6		-- 控制类BUFF
const.kFightOddAttackAdd		= 1		-- 对目标造成正常伤害的N%的伤害
const.kFightOddAttackMulti		= 2		-- 对目标造成M次正常伤害的N%的伤害
const.kFightOddAttackFixed		= 3		-- 对目标造成N点伤害。
const.kFightOddDef		= 4		-- 为目标添加护盾，持续为目标抵消掉其生命值N%的伤害，维持M回合。
const.kFightOddDefFixed		= 5		-- 为目标添加护盾，持续为目标抵消掉生命值N点的伤害，维持M回合.
const.kFightOddStun		= 6		-- 令目标不能行动N回合。
const.kFightOddWeak		= 7		-- 令目标造成的伤害下降N%，持续M回合。
const.kFightOddFire		= 8		-- 令目标每回合末生命值下降其最大生命值的N%，持续M回合。
const.kFightOddArmorDec		= 9		-- 令目标受到的伤害增加N%，持续M回合。
const.kFightOddRecoverHPPer		= 10		-- 回复目标使用者对其能造成的法术伤害的N%的生命值。
const.kFightOddHurtAddPer		= 11		-- 令目标输出的伤害增加N%，持续M回合。
const.kFightOddHurtAdd		= 12		-- 令目标输出的伤害增加N，持续M回合。
const.kFightOddAntiAttack		= 13		-- 反击 受到攻击时有N%几率自动反击，反击伤害为正常伤害
const.kFightOddMagicAntiAttack		= 14		-- 法术反击 受到攻击时有N%几率自动反击，反击伤害为正常伤害
const.kFightOddRageClear		= 15		-- 攻击有N%的机率清空敌方目标的怒气值。
const.kFightOddStunCreate		= 16		-- 攻击有N%的机率让敌方目标进入眩晕状态2回合。
const.kFightOddWeakCreate		= 17		-- 攻击有N%的机率让敌方目标进入虚弱状态2回合。
const.kFightOddFireCreate		= 18		-- 攻击有N%的机率让敌方目标进入烧伤状态2回合。
const.kFightOddArmorDecCreate		= 19		-- 攻击有N%的机率让敌方目标进入破甲状态2回合。
const.kFightOddAttackToHPPer		= 20		-- 攻击有50%的机率回复自身N%对敌方目标造成伤害的血量。
const.kFightOddAttackToHP		= 21		-- 再生 每轮回复自身血量N%。
const.kFightOddAttactReboundPer		= 22		-- 反震 反弹所受伤的N%。
const.kFightOddAttactRebound		= 23		-- NoUse
const.kFightOddClearOddBuff		= 24		-- 每轮有N%的机率清除身上增益。
const.kFightOddClearOddDebuff		= 25		-- 每轮有N%的机率清除身上减益。
const.kFightOddWind		= 26		-- 大风 使风系攻击增加额外N%攻击
const.kFightOddRain		= 27		-- 暴雨 使水系攻击增加额外N%攻击
const.kFightOddSun		= 28		-- 骄阳 使火系攻击额外增加N%攻击
const.kFightOddCloud		= 29		-- 阴霾 使木系攻击额外增加N%攻击
const.kFightOddSnow		= 30		-- 飞雪 每回合将受到自身血量N%的伤害
const.kFightOddPhysicalDoubleHit		= 31		-- 物理连击 普通攻击时有N%几率触发连击效果，可多攻击目标一次。
const.kFightOddMagicDoubleHit		= 32		-- 法术连击 普通攻击时有N%几率触发连击效果，可多攻击目标一次。
const.kFightOddStunMust		= 33		-- 被带眩晕的人打 一定眩晕
const.kFightOddBomb		= 34		-- 爆炸 受攻击时，对敌方全体造成N%的气血上限伤害
const.kFightOddSneak		= 35		-- 偷袭 不会造成爆炸和反震效果
const.kFightOddHide		= 36		-- 隐身 不会被打 但是伤害和速度降低
const.kFightOddPerception		= 37		-- 感知 可以打隐身状态的对手
const.kFightOddPursuit		= 38		-- 追击 杀死敌人时，随机普通攻击下一个敌人，但伤害降低
const.kFightOddShock		= 39		-- 冲击 暴击时，有一定几率令被攻击者晕眩1回合
const.kFightOddDeadFalse		= 40		-- 假死 死亡后不消失，死亡后第4回合一定几率复活并回复x%气血；装备“假死”天赋的武将不能被治疗（不能与“神佑”天赋同时装备）
const.kFightOddPenetrate		= 41		-- 识破 对装备“假死”天赋的武将造成的伤害提高x%，并在将其杀死时直接清除出场，不能复活
const.kFightOddGodBless		= 42		-- 神佑 死亡时有x%的几率直接复活并回复y%气血（不能与“假死”同时装备）
const.kFightOddNaturalEnemy		= 43		-- 天敌 克制拥有神佑技能的武将，对其伤害结果增加x%
const.kFightOddErode		= 44		-- 侵蚀 攻击时可减少对方一定量的怒气
const.kFightOddSign		= 45		-- 神迹 有x%几率将受到的伤害变成1
const.kFightOddCleverRoot		= 46		-- 慧根 使用技能时消耗怒气减少x%
const.kFightOddMagicDef		= 47		-- 破魔 受到法术攻击时，有x%几率完全抵抗该次魔法效果
const.kFightOddBombSelf		= 48		-- 自爆 死亡时自爆，对敌方造成一定伤害
const.kFightOddTerror		= 49		-- 恐怖 攻击后，有x%几率使对方在下回合被迫停止行动
const.kFightOddLucky		= 50		-- 幸运 不会被暴击，但双防降低x%
const.kFightOddWave		= 51		-- 波动 造成的伤害波动范围扩大x%
const.kFightOddDefenseZero		= 52		-- 破防 一定几率无视对方防御值直接造成伤害
const.kFightOddWarPower		= 53		-- 战神之力 不产生暴击，但是伤害提高x%   
const.kFightOddRevive		= 54		-- 复活 每多少回合判断是否复活 addodd.id = round, status_value=回血量,status_value2=概率
const.kFightOddInvincible		= 55		-- 金刚不坏 进入战斗时，前3回合处于无敌状态，受到的任何伤害都变为0
const.kFightOddInsensitive		= 56		-- 麻木不仁 BOSS攻击带有晕眩效果，玩家每次受击都有N%被晕眩1回合
const.kFightOddDeadly		= 57		-- 背水一战 BOSS每次攻击都有一定概率直接将受击方打死
const.kFightOddRageAll		= 58		-- 十万火急 BOSS一直处于满怒气状态，每回合都使用技能
const.kFightOddParryAntiAttack		= 59		-- 皇天后土 BOSS格挡率大幅提升，并且每次格挡后都反击
const.kFightOddJGNM		= 60		-- 金刚怒目 当BOSS血量低于20%时，进入狂暴状态，造成的伤害大幅提升
const.kFightOddRMSF		= 61		-- 入木三分 三连击效果，在普通攻击时有一定几率连续攻击三次
const.kFightOddYHJM		= 62		-- 移花接木 战斗开始时将玩家方的随机一个战斗单位变为怪物方
const.kFightOddDSSC		= 63		-- 滴水穿石 每次对玩家造成伤害的同时为玩家打上一个持续掉血的BUFF，BUFF效果不可叠加
const.kFightOddHSMY		= 64		-- 浑水摸鱼 BOSS每次攻击一个玩家有可能随机再对另一个造成伤害
const.kFightOddHSHL		= 65		-- 火烧火燎 玩家从进入战斗开始即被打上“燃烧”BUFF状态，持续掉血
const.kFightOddFTDH		= 66		-- 赴汤蹈火 每次攻击BOSS都有一定几率被反弹x%所受伤害
const.kFightOddJTWS		= 67		-- 积土为山 在怪物方只剩下BOSS一个时，BOSS会召唤两个小怪
const.kFightOddJTCL		= 68		-- 卷土重来 BOSS死亡后会立即复活一次并回复30%气血
const.kFightOddFEMetal		= 74		-- 雪 代表金，增加水系技能10%，削弱木系技能10%
const.kFightOddFEWood		= 71		-- 狂风 代表木，增强火系技能10%，削弱土系技能10%
const.kFightOddFEWater		= 72		-- 暴雨 代表水，增强木系技能10%，削弱火系技能10%
const.kFightOddFEFire		= 70		-- 晴空 代表火，增强土系技能10%，削弱金系技能10%
const.kFightOddFEEarth		= 73		-- 云雾 代表土，增强金系技能10%，削弱水系技能10%
const.kFightOddArmorAdd		= 75		-- 令目标受到的伤害减少N%，持续M回合
const.kFightOddJGMJ		= 76		-- 击鼓鸣金 物理和法术攻击大幅提升，持续到战斗结束
const.kFightOddYZQJ		= 77		-- 一掷千金 金系全体攻击技能，在战斗第1回合自动释放
const.kFightOddCMJB		= 78		-- 草木皆兵 木系全体攻击技能，在战斗第1回合自动释放
const.kFightOddKMFC		= 79		-- 枯木逢春 当BOSS血量低于30%时，每回合回复大量气血
const.kFightOddCDDS		= 80		-- 抽刀断水 进入战斗后，玩家方所有单位的战斗属性降低x%
const.kFightOddFSNS		= 81		-- 覆水难收 水系全体攻击技能，在战斗第1回合自动释放
const.kFightOddFHLT		= 82		-- 烽火连天 火系全体攻击技能，在战斗第1回合自动释放
const.kFightOddSFDH		= 83		-- 煽风点火 攻击时暴击几率大幅提升
const.kFightOddCTBZ		= 84		-- 寸土必争 BOSS每次攻击都会造成被攻击玩家怒气值降低
const.kFightOddTBWJ		= 85		-- 土崩瓦解 土系全体攻击技能，在战斗第1回合自动释放        
const.kFightOddFire2		= 86		-- 燃烧第二种模式
const.kFightOddMY		= 87		-- 免疫一切减益
const.kFightOddCreateStunNextRound		= 88		-- 下一回合产生一个眩晕的BUFF
const.kFightOddXYHL		= 89		-- 吸引火力
const.kFightOddSilent		= 90		-- 沉默
const.kFightOddFriendBuff		= 91		-- 队友的祝福
const.kFightOddPhysicalAdd		= 92		-- 物伤
const.kFightOddPhysicalDel		= 93		-- 物伤减免
const.kFightOddMagicAdd		= 94		-- 法伤
const.kFightOddMagicDel		= 95		-- 法免
const.kFightOddPhysicalDef		= 96		-- 铁壁
const.kFightOddUnLucky		= 97		-- 厄运 该效果有一定几率在一定的回合内让幸运无效化
const.kFightOddHpRecover		= 98		-- 不老诀 每回合回复血量最低单位5%血量
const.kFightOddXXLH		= 99		-- 怒火熊熊 每回合满怒气，但是伤害减少25%
const.kFightOddJGHT		= 100		-- 金刚护体 前1回合不受到任何伤害 -怒气获得X
const.kFightOddYYJ		= 101		-- 云雨诀 你的大招会使主公下3个回合内回复攻击造成数值的30%血量
const.kFightOddSYZ		= 102		-- 散云咒 每2回合驱散主公一个减益效果，但是你的防御值减少30%
const.kFightOddJZJL		= 103		-- 九转金莲 你的大招会给主角施加一个吸收本次攻击伤害50%的护盾
const.kFightOddXYMG		= 104		-- 血月暮光 你被动拥有20%的吸血效果（普通攻击也算）
const.kFightOddJDBH		= 105		-- 极地冰寒 你存在的时候，对方放一个buff
const.kFightOddHurtShare		= 106		-- 使你受到伤害的20%被所有队友平摊
const.kFightOddFriendAddHp		= 107		-- 你每次释放大招之后，队友都回复3%血量
const.kFightOddDodge		= 108		-- 你会闪避一切的暴击效果，但是闪避之后的怒气值降为0
const.kFightOddRageUp		= 109		-- 每回合攻击后产生的怒气值+5
const.kFightOddSuckAttack		= 110		-- 自己施加一个护盾，相当于攻击力的80%
const.kFightOddJZJL1		= 111		-- 你的大招会给血量少施加一个吸收本次攻击伤害50%的护盾
const.kFightOddJZJL2		= 112		-- 你的大招会给自己施加一个吸收本次攻击伤害50%的护盾
const.kFightOddHSMY2		= 113		-- 一个额外的随机目标造成本次伤害数额的40%伤害
const.kFightOddDefAck		= 114		-- 给目标方增加一个根据攻击力加成的护盾
const.kFightOddBSYZ		= 115		-- 当你的血量低于35%时，你受到的所有伤害降低30%
const.kFightOddAttackBuff		= 116		-- 物法加成
const.kFightOddUnLuckyTwo		= 117		-- 厄运2 该效果有一定几率在一定的回合内让幸运无效化( 这个是作为天赋加在自己身上的，效果是令对方的“幸运”无效化
const.kFightOddConfusion		= 118		-- 被混乱的敌人，会使用普通攻击，攻击相反阵营的目标。就是把target_type的目标换一下。被混乱的敌人无法被觉醒。
const.kFightOddRageLimit		= 119		-- 被打时不加怒气
const.kFightOddDefBuff		= 121		-- 被攻击叠加
const.kFightOddAttackHpBuff		= 122		-- 技能加血buff
const.kFightOddStayBuff		= 123		-- Stay添加BUFF
const.kFightOddHpReduceBuff		= 124		-- 生命减少之后加BUFF
const.kFightOddCirtBuff		= 125		-- 暴击之后加BUFF
const.kFightOddParryBuff		= 126		-- 格挡之后加BUFF
const.kFightOddSleep		= 127		-- 睡眠
const.kFightOddDisillusion		= 128		-- 觉醒状态
const.kFightOddCall		= 129		-- 召唤技能
const.kFightOddInFire		= 130		-- 献祭
const.kFightOddChange		= 131		-- 变身
const.kFightOddEvilShadow		= 132		-- 恶魔之影
const.kFightOddTenFire		= 133		-- 十字火焰
const.kFightOddDoubleHit		= 134		-- 风怒
const.kFightOddBreak		= 135		-- 打断
const.kFightOddInStunMoreHurt		= 136		-- 对处在昏迷效果的敌人造成更多伤害
const.kFightOddInStunMoreTime		= 137		-- 会延长其昏迷1回合
const.kFightOddHpToHurt		= 138		-- 承受贝恩攻击时就会多受到2%伤害
const.kFightOddDeadToStun		= 139		-- 每当一个盟友死亡时，贝恩就会昏迷对方随机一个单位2回合
const.kFightOddAttachToStun		= 140		-- 普通攻击有20%几率使敌人昏迷1回
const.kFightOddMagicHitBuff		= 141		-- 被法术攻击击中时，有一定几率给自身增加一个buff
const.kFightOddDeadNow		= 142		-- 增加一个buff，只要中了该buff就直接死亡
const.kFightOddCoil		= 143		-- 缠绕状态，所有的近战技能不能攻击，远程技能可以攻击
const.kFightOddCommonAttackMight		= 144		-- 普通攻击伤害+N%
const.kFightOddSkillBuff		= 145		-- 使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方) 暂不适用
const.kFightOddStarDown		= 146		-- 星辰陨落，持续2回合，每回合砸5次，全部随机目标（同一个目标有可能砸中多次)，造成释放者自身攻击30%的伤害
const.kFightOddPhyInvincible		= 147		-- 物理免疫，被物理攻击时，有一定几率免疫物理伤害
const.kFightOddMagInvincible		= 148		-- 法术免疫，被法术攻击时，有一定几率免疫法术伤害
const.kFightOddAttackToHp		= 149		-- 攻击被施加“吸血鬼之触”状态的敌方目标时，可将所造成伤害的15%回复成自身血量
const.kFightOddControlInvincible		= 150		-- 免疫所有控制类的buff
const.kFightOddAttackToSkill		= 151		-- 攻击时都会有几率额外触发另外一个主动技能(一回合只会触发一次)
const.kFightOddAttackToOdd		= 152		-- 攻击时都会有几率额外触发另外一个被动技能
const.kFightOddHitBuff		= 153		-- 被攻击击中时，有一定几率给自身增加一个buff
const.kFightOddRecoberRage		= 154		-- 每回合都会额外恢复N点能量
const.kFightOddNightDance		= 155		-- 暗影之舞,此状态下会一直保持潜行状态，并在攻击时偷袭目标，对目标造成昏迷效果，持续2回合
const.kFightOddDeadHit		= 156		-- 受到一次致命攻击时，会将该伤害变为1点血，并且将受到的所有伤害降低N%，持续N回合。
const.kFightOddGiveRevive		= 157		-- 己方队友死亡时，召唤出一个兽人灵魂施放到队友身上，持续2回合。2回合后，目标有50%几率复活，若复活失败，则继续向其释放此技能。一场战斗只能复活一名队友。
const.kFightOddRoundBuff		= 158		-- 每过一回合，英雄的伤害提高N%,最多提高M次
const.kFightOddDeadHitChange		= 159		-- 受到了致死的攻击，那么本回合他会贿赂对方英雄，使攻击目标转向其他英雄，同时使意图攻击自己的对方英雄伤害降低50%
const.kFightOddReduceHpBuff		= 160		-- 每次受到50%以上血量的攻击，都有50%几率产生一个吸收5%最大血量的护盾
const.kFightOddFireFix		= 161		-- 造成固定伤害
const.kFightOddLightning		= 162		-- 闪电链BUFF
const.kFightOddFireCount		= 163		-- Fire可以叠加
const.kFightOddSkillBuffSelf		= 164		-- 使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方)
const.kFightOddHitBuffDef		= 165		-- 被攻击时有一定几率给被攻击者增加一个buff
const.kFightOddHideBuff		= 166		-- 如果处于潜行 增加伤害
const.kFightOddArmorDecCount		= 167		-- 易伤状态，使得被攻击时伤害增加N%（相当于原来的破甲效果，不过这个要求可以叠加），最多可以叠加3次
const.kFightOddDealCall		= 168		-- 死亡召唤技能
const.kFightOddSilentBuff		= 169		-- 沉默加攻击
const.kFightOddRevive2		= 170		-- 复活 多少回合之后判断是否需要复活 addodd.id = round, status_value=回血量,status_value2=概率
const.kFightOddPositiveCharge		= 171		-- 正电荷 v1:hurt v2:stun_per
const.kFightOddBeCrit		= 172		-- 跟减少敌方的暴击率有点不同，就算是暴击值为0的人，打这个拥有被暴击属性的人也是可以暴击出来的
const.kFightOddDoubleHitBuff		= 173		-- 强化风怒图腾
const.kFightOddFireFlow		= 174		-- 火舌 每回合对随机敌方造成一次固定数值伤害，并有几率额外附加一个减益buff,伤害量=图腾等级*固定数值
const.kFightOddCounter		= 175		-- 身后英雄产生闪避后必对随机敌人进行一次额外的普通攻击(但是伤害降低N%)
const.kFightOddDisillusionCreate		= 176		-- 觉醒产生 status_value=概率 status_value2=类型
const.kFightOddRecoverCirtBuff		= 177		-- 回血暴击增加BUFF
const.kFightOddRecoverSelfAdd		= 178		-- 自身治疗别人增加的治疗效果
const.kFightOddRecoverSelfDel		= 179		-- 自身治疗别人增加的治疗效果
const.kFightOddRecoverTarAdd		= 180		-- 被治疗效果增加
const.kFightOddRecoverTarDel		= 181		-- 被治疗效果减少
const.kFightOddHpPerRecover		= 182		-- 当自身血量低于40%时，为自身回复30%血量，冷却时间5回合
const.kFightOddRecoverBuff		= 183		-- 加血的时候增加BUFF
const.kFightOddDeadFighting		= 184		-- 当你死后，你会继续以无敌形态（不可被选中，不可受伤）站在战场上持续2回合，2回合后就消失，真正死亡，并且怒气全满。此时可以被图腾觉醒激活
const.kFightOddDeadAddBuff		= 185		-- 死亡时给自己添加BUFF
const.kFightOddRecoverByHP		= 186		-- 在本回合结束时，回复一定血量，血量越少恢复越多,value1填增加的最小百分比,value2填增加的最大百分
const.kFightOddHurtAddFix		= 187		-- 拥有该状态时，伤害结果增加X点。如果是多次伤害的技能则，每次的伤害为 X/伤害的次数 
const.kFightOddHurtDelFix		= 188		-- 拥有该状态时，受到的伤害结果减少X点，如果是被多次伤害的技能攻击时，每次减少的伤害为 X/伤害的次数
const.kFightOddDefenseDelPhy		= 189		-- 拥有该状态时，每次攻击时忽略对方X点护甲，如果最终忽略后的护甲小于0，则把护甲值变成0
const.kFightOddDefenseDelMag		= 190		-- 拥有该状态时，每次攻击时忽略对方X点魔法抗性，如果最终忽略后的魔法抗性小于0，则把魔法抗性变成0
const.kFightOddDefenseDelAll		= 191		-- 拥有该状态时，每次攻击时忽略对方X点魔法抗性和护甲，如果最终忽略后的魔法抗性和护甲小于0，则把魔法抗性和护甲变成0
const.kFightOddAttackAddTotemValue		= 192		-- 拥有该状态时，每次使用普通攻击时额外获得XX点图腾活力值
const.kFightOddLightningFix		= 193		-- 闪电扣血
const.kFightOddAttackHpRecover		= 194		-- 按照施法者攻击的百分比回血,之前是只有主动技能才有,现在需要加一个buff是按照施法者攻击来回
const.kFightOddChangeSheep		= 195		-- 新加个变形术(变成羊)，中了这个状态不能行动,但被攻击后变羊的状态会消失。
const.kFightOddChangeFrog		= 196		-- 新加个变形术(变成青蛙)，中了这个状态不能行动，就算给打了变形术的状态也不会消失。
const.kFightOddDeadRevive		= 197		-- 有单位死开始如果2回合后自己还没死，救活该死亡单位。该死亡单位具有自身生前血量的50%，并且满怒气 v1多少回合 v2回复多少血
const.kFightOddDeadHurtRebound		= 198		-- 受到致命伤害时，会将该伤害的N%反弹给造成伤害的人
const.kFightOddPhysicalAttackDel		= 199		-- 受到的物理伤害降低N%
const.kFightOddMagicAttackDel		= 200		-- 受到的魔法伤害降低N%
const.kFightOddStone		= 201		-- 石化，效果跟眩晕一样，但是用新的status表明这个状态是石化，方便做客户端表现
const.kFightOddStorm		= 202		-- 飓风：令随机N个目标进入飓风状态（被驱逐出场）N回合         
const.kFightOddRageBuff		= 203		-- 获得的怒气速度提升N%。
const.kFightOddRecoverCount		= 204		-- 可以叠加的被治疗效果，效果为叠加的层数乘以所填的基数
const.kFightOddClearOdd		= 205		-- 清除BUFF
const.kFightOddKillRageAdd		= 206		-- 拥有该状态时，杀死敌人额外获得固定怒气
const.kFightOddTotemSkillCoolDown		= 207		-- 图腾主动技能一定几率立即冷却
const.kFightOddTotemSkillCost		= 208		-- 发动图腾技能消耗能量减少
const.kFightOddTotemSkillDel		= 209		-- 发动图腾技能时，一定几率减少敌方图腾能量
const.kFightOddTotemValueInit		= 210		-- 出场时增加初始图腾能量，如果有多个同样的buff存在，则取数值最高的那个，不叠加
const.kFightOddSkillChange		= 211		-- 使用某个id的主动技能时，有一定几率改为使用另个一个id的主动技能例如技能4
const.kFightOddSnakeStick		= 212		-- 蛇棒，插在自己身后，持续M回合，每回合在使用者攻击时，蛇棒会对随机一个敌人造成使用者自身攻击（物攻和法攻最大者)N%的伤害
const.kFightOddDisease		= 213		-- 疾病效果使对方速度降低，并且每回合造成自身攻击N%的伤害
const.kFightOddDevour		= 214		-- 吞噬对方身上的所有疾病效果，每吞噬一个疾病效果，就对该单位造成吞噬者自身攻击N%的伤害
const.kFightOddScourge		= 215		-- 主动技能:在对方脚下召唤天谴之地，每回合都为随机4个目标施加1-2层疾病效果，并且每回合都打击疾病数量最多的一名敌人，造成的伤害以施法者
const.kFightOddDevourAdd		= 216		-- 吞噬对方身上的所有疾病效果，每吞噬一个疾病效果，就对该单位造成吞噬者自身攻击N%的伤害
const.kFightOddRageAddSave		= 217		-- 攻击有100%的几率提升5-20点怒气，并且释放大招之后，保留15点怒气
const.kFightOddBlood		= 218		-- 新加一个可以叠加的燃烧效果，叫做流血效果
const.kFightOddBloodBuff		= 219		-- 在敌方身上的流血效果每持续多一回合，伤害提高
const.kFightOddImmune		= 220		-- 定几率免疫昏迷(这个可以做出一定几率免疫某个statusid的buff)
const.kFightOddPoison		= 221		-- 新加一个可以叠加的燃烧效果，叫做毒药。
const.kFightOddBuffPercent		= 222		-- 普通攻击对敌方目标上毒的几率提升10%
const.kFightOddHaveOddCirt		= 223		-- 攻击中了某个odd的人时，自身对其暴击几率提高N%
const.kFightOddBuffPercent2		= 224		-- 攻击时，对所有敌人造成冰冻的几率提升10%（普通技能与大大招也有10%几率造成冰冻）
const.kFightOddIceDef		= 225		-- 生命值低于50%时，可以生成一个寒冰护盾，吸收大量伤害，持续2回合,每场战斗只触发一次，改护盾被打破时不会给打破的人造成伤害
const.kFightOddBuffHurt		= 226		-- 对单体敌人释放焚烧，造成大量伤害,如果目标身上有燃烧效果，那么受到的伤害提升30%
const.kFightOddHpRage		= 227		-- 每次释放攻击时，有50%几率消耗自身4%血量，提升25点怒气。
const.kFightOddTrueGas		= 228		-- 真气
const.kFightOddRageSave		= 229		-- 使用大招之后会剩余25点怒气
const.kFightOddRecoverHPMin		= 230		-- 向友方血量最低目标释放愈合祷言，该目标在受到伤害后，愈合祷言会为其回复大量血量，并且弹射到下一个血量最低的友方单位。愈合祷言共可弹射3次。己方只存在一个愈合祷言
const.kFightOddDiseaseHurt		= 231		-- 织亡者的疾病伤害提升5%
const.kFightOddDiseaseChange		= 232		-- 每层疾病效果使对面的防御与攻击都降低1%
const.kFightOddTrueGasRecover		= 233		-- 在释放普通主动技能时，每一层真气会回复你血量3%
const.kFightOddDisillusionPer		= 234		-- 拥有该buff时，可以提高自身受到某个系别的觉醒几率
const.kFightOddDisillusionDouble		= 235		-- 拥有该buff时可以提高自身的觉醒几率
const.kFightOddHideRage		= 236		-- 在潜行状态下，攻击时额外增加N的点怒气
const.kFightOddbuffA		= 237		-- 拥有buffA攻击带buffB的人，buffA的人额外增加N点怒气，并给buffB添加一个状态add一个odd
const.kFightOddbuffB		= 238		-- 拥有buffA攻击带buffB的人，buffA的人额外增加N点怒气，并给buffB添加一个状态add一个odd
const.kFightOddDefAll		= 239		-- 己方所有人添加一个护盾，该护盾会吸收所有人的伤害并进行己方全体所吸收伤害进行统计，如果伤害超过了释放人生命上限的N%时就会打破。
const.kFightOddSuckExt		= 240		-- 单体攻击时，有一定几率偷去敌方的攻击N%（自己物攻和法攻增加N%,敌方的物攻和法攻减少N%），最多可以叠加N次，持续3回合.
const.kFightHpToExtraHurt		= 241		-- 拥有该buff时，对于50%生命(写死)以下敌人的攻击，会额外造成对方生命值10%（填v1)的伤害，最多不超过自身攻击的N%(填v2),对每一个目标冷却时间3回合(写死)
const.kFightOddHpLessMoreHurt		= 242		-- 拥有该buff时，敌方血量越少对敌人造成的伤害更多，血量越少伤害越多的buff计算
const.kFightOddSuperPursuit		= 243		-- 超级追击，拥有该buff时，杀死敌人时，怒气+100使用大招攻击另外一人，但是伤害降低N%
const.kFightOddDefAddRage		= 244		-- 拥有该buff时，当攻击者攻击这个buff拥有者时，会给攻击的人填加N-M点怒气
const.kFightOddHurtBuffAdd		= 245		-- 拥有该buff时，伤害增加N%，可以叠加N次
const.kFightOddKillBuffAdd		= 246		-- 杀死人的时候添加buff
const.kFightOddFear		= 247		-- 恐惧，不能行动，但是当从被恐惧的那刻起算如果累计受到的伤害超过自身生命的N%时，则解除这个状态
const.kFightOddDefMagicOrPhy		= 248		-- 可以减少物理或者法术攻击
const.kFightOddDefMelee		= 249		-- 受到的近战伤害减少N%
const.kFightOddDefRanged		= 250		-- 受到的远程伤害减少N%
const.kFightOddEquipTypeHurt		= 251		-- 拥有该Buff时，打某种甲的伤害增加N%.
const.kFightOddEquipTypeDef		= 252		-- 被某种甲的英雄打时受到的伤害减少N%

err.kErrFightInFight		= 859462928		--战斗中
err.kErrFightLogNotFind		= 1115661210		--战斗不存在或者已经过期
err.kErrFightLogVersion		= 584353244		--战斗不存在或者已经过期
err.kErrFightNotExist		= 1196542270		--战斗不存在
err.kErrFightCheck		= 1852386177		--战斗检查失败
err.kErrFightFailure		= 1189816107		--战斗失败

-- 使用的技能
base.reg( 'SFightOrder', nil,
    {
        { 'guid', 'uint32' },		-- 角色ID                     //从10000开始有特殊的用途 10000表示设置自动
        { 'order_id', 'uint32' },		-- 技能ID
        { 'order_level', 'uint16' },		-- 等级  
    }
)

-- 战斗技能
base.reg( 'SFightSkill', nil,
    {
        { 'skill_id', 'uint32' },		-- 战斗技能id
        { 'skill_level', 'uint32' },		-- 战斗技能等级
    }
)

-- 战斗属性
base.reg( 'SFightExtAble', nil,
    {
        { 'hp', 'uint32' },		-- 气血
        { 'physical_ack', 'uint32' },		-- 物理攻击
        { 'physical_def', 'uint32' },		-- 物理防御
        { 'magic_ack', 'uint32' },		-- 法术攻击
        { 'magic_def', 'uint32' },		-- 法术防御
        { 'speed', 'uint32' },		-- 速度
        { 'critper', 'uint32' },		-- 暴击率
        { 'critper_def', 'uint32' },		-- 暴击抵抗
        { 'recover_critper', 'uint32' },		-- 回血暴击率
        { 'recover_critper_def', 'uint32' },		-- 回血暴击抵抗
        { 'crithurt', 'uint32' },		-- 暴击伤害
        { 'crithurt_def', 'uint32' },		-- 暴击减免
        { 'hitper', 'uint32' },		-- 命中
        { 'dodgeper', 'uint32' },		-- 闪避
        { 'parryper', 'uint32' },		-- 格挡
        { 'parryper_dec', 'uint32' },		-- 格挡减少
        { 'rage', 'uint32' },		-- 蓄力值
        { 'stun_def', 'uint32' },		-- 眩晕抗性
        { 'silent_def', 'uint32' },		-- 沉默抗性
        { 'weak_def', 'uint32' },		-- 虚弱抗性
        { 'fire_def', 'uint32' },		-- 烧伤抗性
        { 'recover_add_fix', 'uint32' },		-- 回血固定值
        { 'recover_del_fix', 'uint32' },		-- 回血固定值
        { 'recover_add_per', 'uint32' },		-- 回血百分比
        { 'recover_del_per', 'uint32' },		-- 回血百分比
        { 'rage_add_fix', 'uint32' },		-- 怒气固定值
        { 'rage_del_fix', 'uint32' },		-- 怒气固定值
        { 'rage_add_per', 'uint32' },		-- 怒气百分比
        { 'rage_del_per', 'uint32' },		-- 怒气百分比
    }
)

-- BUFF或者DEBUFF
base.reg( 'SFightOdd', nil,
    {
        { 'id', 'uint32' },		-- 异常ID                                                
        { 'level', 'uint8' },		-- 异常等级                                              
        { 'start_round', 'uint16' },		-- 异常开始回合 会更新
        { 'begin_round', 'uint16' },		-- 异常开始回合 不会更新
        { 'status_id', 'uint16' },		-- 产生状态ID
        { 'status_value', 'uint32' },		-- 产生状态ID对应的Value
        { 'ext_value', 'uint32' },		-- 用于各种特殊情况
        { 'use_guid', 'uint32' },		-- 使用者的id
        { 'use_count', 'uint32' },		-- 使用次数
        { 'now_count', 'uint32' },		-- 现在的层数
        { 'delFlag', 'uint32' },		-- 删除标记
    }
)

-- BUFF SET
base.reg( 'SFightOddSet', nil,
    {
        { 'guid', 'uint32' },		-- 角色ID
        { 'set_type', 'uint8' },		-- kObjectDel, kObjectAdd, kObjectUpdate
        { 'fightOdd', 'SFightOdd' },		-- odd状态
    }
)

base.reg( 'SFightOddTriggered', nil,
    {
        { 'use_guid', 'uint32' },		-- 触发者ID
        { 'odd_id', 'uint32' },		-- 触发的ID
        { 'targetList', { 'array', 'SFightSoldierSimple' } },		-- 目标方
    }
)

-- 战斗伤害
base.reg( 'SFightOrderTarget', nil,
    {
        { 'guid', 'uint32' },		-- 角色ID被打的角色ID
        { 'attr', 'uint16' },		-- 人物标识 玩家/怪物/宠物
        { 'rage', 'uint32' },		-- 当前玩家怒气值
        { 'hp', 'uint32' },		-- 血量
        { 'fight_attr', 'uint16' },		-- 连击 反击 追击 客户端表现用
        { 'fight_might', 'uint16' },		-- 第几次攻击
        { 'fight_result', 'uint16' },		-- 战斗结果 扣血 加血等
        { 'fight_type', 'uint16' },		-- 战斗类型 暴击 格挡等
        { 'fight_value', 'uint32' },		-- 战斗值
        { 'totem_value', 'uint32' },		-- 图腾值
        { 'max_hp', 'uint32' },		-- 最大血量
        { 'odd_id', 'uint32' },		-- oddid造成的伤害
        { 'odd_list', { 'array', 'SFightOddSet' } },		-- 当前玩家ODD变更列表
        { 'odd_list_triggered', { 'array', 'SFightOddTriggered' } },		-- 触发的guid和oddid
    }
)

-- 战斗记录
base.reg( 'SFightLog', nil,
    {
        { 'round', 'uint32' },		-- 战斗回合
        { 'order', 'SFightOrder' },		-- 战斗技能
        { 'orderTargetList', { 'array', 'SFightOrderTarget' } },		-- 战斗结果
    }
)

-- 战斗技能以及对象
base.reg( 'SFightSkillObject', nil,
    {
        { 'round', 'uint32' },		-- 当前回合
        { 'order', 'SFightOrder' },
        { 'targetList', { 'array', 'SFightSoldierSimple' } },
    }
)

-- 战斗人员简单信息
base.reg( 'SFightSoldierSimple', nil,
    {
        { 'guid', 'uint32' },		-- 唯一标识
        { 'soldier_guid', 'uint32' },		-- 人物的情况下是武将GUID totem的情况下是totemextid 怪物情况下就是monsterid
        { 'attr', 'uint16' },		-- 人物标识 玩家/怪物
        { 'hp', 'uint32' },		-- 武将当前血量
        { 'rage', 'uint32' },		-- 玩家怒气
    }
)

-- 战斗人员信息
base.reg( 'SFightSoldier', 'SFightSoldierSimple',
    {
        { 'soldier_id', 'uint32' },		-- 武将ID,怪物ID,战宠Id
        { 'fame', 'uint32' },		-- 声望
        { 'name', 'string' },		-- 武将名称
        { 'platform_str', 'string' },		-- 平台名字
        { 'platform', 'uint32' },		-- 平台id+服务器id
        { 'avatar', 'uint16' },		-- 玩家头像
        { 'quality', 'uint16' },		-- 品质
        { 'occupation', 'uint32' },		-- 玩家职业
        { 'equip_type', 'uint32' },		-- 装备类型
        { 'gender', 'uint8' },		-- 玩家性别
        { 'horse_id', 'uint16' },		-- 马id
        { 'level', 'uint32' },		-- 玩家等级
        { 'fight_index', 'uint32' },		-- 当前位置
        { 'fight_ext_able', 'SFightExtAble' },		-- 武将二级属性
        { 'item_list', { 'array', 'SUserItem' } },		-- 角色装备
        { 'skill_list', { 'array', 'SFightSkill' } },		-- 技能列表
        { 'odd_list', { 'array', 'SFightOdd' } },		-- BUFF列表
        { 'order', 'SFightOrder' },		-- 使用技能
        { 'last_ext_able', 'SFightExtAble' },		-- 当前武将二级属性
        { 'lastOrderRound', { 'indices', 'uint32' } },		-- 上次使用技能的时间
        { 'limitCountAll', { 'indices', 'uint32' } },		-- 使用BUFF的次数
        { 'state_list', { 'indices', 'uint32' } },		-- 状态信息
        { 'delFlag', 'uint32' },		-- 删除标志
        { 'selfUserGuid', 'uint32' },		-- UserGuid
        { 'selfFightId', 'uint32' },		-- 战斗ID
        { 'isPlay', 'uint32' },		-- 是否在播放前置动画阶段
        { 'deadFlag', 'uint32' },		-- 死亡标志
        { 'glyph_list', { 'array', 'S2UInt32' } },		-- 图腾给该soldier所加的属性
        { 'totem', 'STotem' },		--  如果是图腾，则图腾的信息
        { 'totem_glyph_list', { 'array', 'STotemGlyph' } },		--  如果是图腾，则为图腾镶嵌的雕文列表
    }
)

-- 战斗团队信息
base.reg( 'SFightPlayerSimple', nil,
    {
        { 'guid', 'uint32' },		-- 唯一id
        { 'player_guid', 'uint32' },		-- 玩家GUID
        { 'camp', 'uint16' },		-- 用这个来标识阵营
        { 'attr', 'uint16' },		-- 人物标识 玩家/怪物
        { 'hurt', 'uint32' },		-- 造成的伤害
        { 'totem_value', 'uint32' },		-- totem值
        { 'soldier_list', { 'array', 'SFightSoldierSimple' } },		-- 玩家武将
    }
)

-- 战斗团队信息
base.reg( 'SFightPlayerInfo', nil,
    {
        { 'guid', 'uint32' },		-- 唯一id
        { 'player_guid', 'uint32' },		-- 玩家GUID
        { 'camp', 'uint16' },		-- 用这个来标识阵营
        { 'attr', 'uint16' },		-- 人物标识 玩家/怪物
        { 'flag', 'uint32' },		-- 状态
        { 'isAutoFight', 'uint32' },		-- 自动战斗
        { 'totem_value', 'uint32' },		-- totem值
        { 'soldier_list', { 'array', 'SFightSoldier' } },		-- 玩家武将
    }
)

-- 战斗结果
base.reg( 'SFightResult', nil,
    {
        { 'camp_win', 'uint32' },
        { 'coin_list', { 'array', 'S2UInt32' } },
    }
)

base.reg( 'SFightLogList', nil,
    {
        { 'fight_data_list', { 'array', 'SFightLog' } },		-- 战斗数据
    }
)

base.reg( 'SFightRecordSimple', nil,
    {
        { 'guid', 'uint32' },
        { 'create_time', 'uint32' },
    }
)

base.reg( 'SFightRecord', 'SFightRecordSimple',
    {
        { 'fight_id', 'uint32' },		-- 战斗
        { 'fight_type', 'uint32' },		-- 战斗类型
        { 'fight_randomseed', 'uint32' },		-- 战斗随机种子
        { 'order_list', { 'array', 'SFightOrder' } },		-- 战斗技能出手LOG
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },		-- 战斗人员时候的信息
    }
)

base.reg( 'SSoldier', nil,
    {
        { 'role_id', 'uint32' },		-- 玩家或者怪物ID
        { 'attr', 'uint16' },		-- 人物标识 玩家/怪物/宠物
        { 'camp', 'uint16' },		-- 阵营
        { 'seqno', 'uint32' },		-- 战斗同步id
    }
)

base.reg( 'SFightEndInfo', nil,
    {
        { 'camp', 'uint32' },		-- 阵型
        { 'round', 'uint32' },		-- 回合
        { 'hurt', 'uint32' },		-- 攻击总伤害
        { 'attack_count', 'uint32' },		-- 攻击次数
        { 'dodge_count', 'uint32' },		-- 闪避次数
        { 'recover', 'uint32' },		-- 恢复血量
        { 'magic_hurt', 'uint32' },		-- 魔法伤害
        { 'dead_count', 'uint32' },		-- 死亡次数 
    }
)

base.reg( 'SFight', nil,
    {
        { 'fight_id', 'uint32' },		-- 战斗id
        { 'fight_type', 'uint16' },		-- 战斗类型
        { 'create_time', 'uint32' },		-- 创建时间
        { 'gc_time', 'uint32' },		-- 删除时间
        { 'box_randomseed', 'uint32' },		-- 宝箱随机种子
        { 'fight_randomseed', 'uint32' },		-- 战斗随机种子
        { 'loop_id', 'uint32' },		-- 回调的id
        { 'win_camp', 'uint16' },		-- 胜利
        { 'ack_id', 'uint32' },		-- 挑战者Id
        { 'def_id', 'uint32' },		-- 应战者Id
        { 'soldier_list', { 'array', 'SSoldier' } },		-- 参战玩家
        { 'monster_list', { 'array', 'SSoldier' } },		-- 参战怪物
        { 'help_monster', 'uint32' },		-- 帮忙怪
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },
        { 'soldierEndList', { 'array', 'SFightPlayerSimple' } },
        { 'state', 'uint16' },		-- 状态 CreateOK DataOK
        { 'seqno', 'uint32' },		-- 双人战斗同步id
        { 'seqno_map', { 'indices', 'uint32' } },		-- user_guid, seqno
        { 'fight_record', 'SFightRecord' },		-- 战斗LOG保存信息
        { 'fightEndInfo', { 'indices', 'SFightEndInfo' } },		-- 战斗结束的信息
        { 'is_quit', 'uint32' },		-- 是否是撤退
        { 'is_roundout', 'uint32' },		-- 是否超时
    }
)

base.reg( 'CFightData', nil,
    {
        { 'fight_id', 'uint32' },		-- 战斗id
        { 'round', 'uint32' },		-- 回合
        { 'fightType', 'uint32' },
        { 'winCamp', 'uint32' },
        { 'isAutoFight', 'uint32' },
        { 'disillusionIndex', 'uint32' },		-- 觉醒的位置
        { 'userList', { 'indices', 'SFightPlayerInfo' } },
        { 'soldierList', { 'array', 'SFightSoldier' } },
        { 'soldierAttackList', { 'array', 'SFightSoldier' } },
        { 'soldierAttackListIndex', 'uint32' },
        { 'orderList', { 'array', 'SFightOrder' } },
        { 'soldierEndList', { 'array', 'SFightSoldier' } },
        { 'fightSeed', 'SInteger' },
        { 'fightEndInfo', { 'indices', 'SFightEndInfo' } },		-- 战斗结束的信息
    }
)

-- ============================数据中心========================
base.reg( 'CFightMap', nil,
    {
        { 'fight_map', { 'indices', 'SFight' } },		-- 战斗数据
        { 'fight_lua_map', { 'indices', 'CFightData' } },		-- Lua战斗数据
        { 'fight_id', 'uint32' },
    }
)

base.reg( 'CFightRecordMap', nil,
    {
        { 'is_init', 'uint32' },		-- 是否初始化
        { 'version', 'uint32' },		-- 版本
        { 'fight_record_id', 'uint32' },		-- 战斗LOG保存id
        { 'fight_guid_time_map', { 'indices', 'S2UInt32' } },		-- 开始time, <start,end>
        { 'fight_record_access_map', { 'indices', 'uint32' } },		-- time, 访问时间
        { 'fight_record_save_map', { 'indices', 'uint32' } },		-- time, 保存时间
        { 'fight_record_map', { 'indices', 'indices', 'bytes' } },		-- time, 记录List
    }
)

-- 触发战斗
base.reg( 'PQCommonFightApply', 'SMsgHead',
    {
        { 'attr', 'uint32' },		-- kAttrPlayer,kAttrMonster
        { 'target_id', 'uint32' },		-- 目标的怪物id
    }, 477321402
)

-- 返回战斗人员信息
base.reg( 'PRCommonFightInfo', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗id
        { 'fight_type', 'uint32' },		-- 战斗类型
        { 'fight_randomseed', 'uint32' },		-- 战斗随机种子
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },
    }, 1926767447
)

base.reg( 'PRCommonFightServerEnd', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗
        { 'order_list', { 'array', 'SFightOrder' } },		-- 战斗技能出手LOG
        { 'fight_type', 'uint32' },		-- 战斗类型
        { 'fight_randomseed', 'uint32' },		-- 战斗随机种子
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },
        { 'win_camp', 'uint32' },		-- 战斗胜利方
        { 'is_roundout', 'uint32' },		-- 是否回合超时
        { 'fightEndInfo', { 'indices', 'SFightEndInfo' } },		-- 战斗结束信息
        { 'coins_list', { 'array', 'S3UInt32' } },		-- 战斗奖励
    }, 1338160097
)

base.reg( 'PQCommonFightClientEnd', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗
        { 'win_camp', 'uint32' },		-- 胜利方
        { 'is_roundout', 'uint32' },		-- 是否超时
        { 'order_list', { 'array', 'SFightOrder' } },		-- 战斗技能出手LOG
        { 'fight_info_list', { 'array', 'SFightPlayerSimple' } },		-- 战斗结束时候的信息
        { 'fightEndInfo', { 'indices', 'SFightEndInfo' } },		-- 战斗结束信息
        { 'fight_info_game', 'SFight' },		-- 战斗信息 服务端用 客户端不需要赋值
    }, 228122789
)

base.reg( 'PRCommonFightClientEnd', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗
        { 'check_result', 'uint32' },		-- check result 0表示正常
        { 'win_camp', 'uint32' },		-- 战斗胜利方
        { 'is_roundout', 'uint32' },		-- 是否回合超时
        { 'fightEndInfo', { 'indices', 'SFightEndInfo' } },		-- 战斗结束信息
        { 'coins_list', { 'array', 'S3UInt32' } },		-- 战斗奖励
    }, 1435883798
)

-- 触发双人战斗
base.reg( 'PQPlayerFightApply', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标GUID
    }, 511019853
)

-- 返回战斗人员信息
base.reg( 'PRPlayerFightInfo', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗id 
        { 'fight_info_list', { 'array', 'SFightPlayerInfo' } },
    }, 1136960421
)

-- 战斗退出
base.reg( 'PQPlayerFightQuit', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗id
    }, 761774693
)

-- 战斗请求技能
base.reg( 'PQPlayerFightAck', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },
        { 'fight_order', 'SFightOrder' },
    }, 108217511
)

-- 战斗技能返回
base.reg( 'PRPlayerFightAck', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },
        { 'seqno', 'uint32' },
        { 'skill_obj', 'SFightSkillObject' },
    }, 1398910108
)

-- 战斗技能确认
base.reg( 'PQPlayerFightSyn', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },
        { 'seqno', 'uint32' },		-- 确认序列号
    }, 472110993
)

-- 战斗技能返回
base.reg( 'PRFightRoundData', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },
        { 'fightlog', { 'array', 'SFightLog' } },		-- 技能战斗结果 
    }, 2083684729
)

-- 战斗结束
base.reg( 'PRFightEnd', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },
        { 'winCamp', 'uint32' },		-- 胜利方
    }, 1930696995
)

-- 保存战斗LOG
base.reg( 'PQFightRecordSave', 'SMsgHead',
    {
        { 'fight_record', 'SFightRecord' },
    }, 409725311
)

-- 获取战斗LOG
base.reg( 'PQFightRecordGet', 'SMsgHead',
    {
        { 'guid', 'uint32' },
    }, 1025528566
)

base.reg( 'PRFightRecordGet', 'SMsgHead',
    {
        { 'fight_record', 'SFightRecord' },
    }, 1176844493
)

-- 战斗记录ID 服务端用的
base.reg( 'PQFightRecordID', 'SMsgHead',
    {
    }, 37267773
)

base.reg( 'PRFightRecordID', 'SMsgHead',
    {
        { 'id', 'uint32' },
    }, 1864886146
)

-- 首场开场动画
base.reg( 'PQFightFirstShow', 'SMsgHead',
    {
    }, 317670076
)

-- 触发竞技场战斗
base.reg( 'PQFightSingleArenaApply', 'SMsgHead',
    {
        { 'attr', 'uint32' },		-- kAttrPlayer,kAttrMonster
        { 'target_id', 'uint32' },		-- 人物为guid,怪物为rank
    }, 157609641
)

-- 战斗错误记录
base.reg( 'PQFightErrorLog', 'SMsgHead',
    {
        { 'data', 'SCompressData' },		-- 压缩战斗记录内容
    }, 448840913
)

-- 触发假人战斗
base.reg( 'PQCommonFightAuto', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标的怪物id
    }, 403257916
)


