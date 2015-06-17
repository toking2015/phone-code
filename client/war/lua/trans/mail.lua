local const = trans.const
local err = trans.err
local base = trans.base

const.kMailFlagReaded		= 1		-- 已阅读 
const.kMailFlagTake		= 2		-- 附件已领取 
const.kMailFlagSystem		= 4		-- 系统邮件
const.kMailFlagAutoDel		= 8		-- 领取附件后自动删除
const.kMailTypePlayer		= 0		-- 个人邮件
const.kMailTypeAll		= 1		-- 全服邮件
const.kMailTypeOnline		= 2		-- 在线邮件
const.kPathMailUserSend		= 1831050662		-- 用户发送邮件

err.kErrMailTargetNotExist		= 198160320		--邮件发送对象不存在
err.kErrMailSubjectFormat		= 174397825		--邮件标题格式错误
err.kErrMailBodyFormat		= 846099063		--邮件正文格式错误
err.kErrMailNotExist		= 69921612		--邮件不存在
err.kErrMailAttachmentEmpty		= 1650907036		--邮件附件为空

-- ==========================数据中心========================
base.reg( 'CMail', nil,
    {
        { 'system_mail_id', 'uint32' },		-- 当前系统邮件最大Id
    }
)

-- ==========================通迅结构==========================
base.reg( 'SUserMail', nil,
    {
        { 'mail_id', 'uint32' },
        { 'flag', 'uint32' },		-- 状态
        { 'path', 'uint32' },		-- 途径 [kPath]
        { 'deliver_time', 'uint32' },		-- 发送时间
        { 'sender_name', 'string' },		-- 发送者名称
        { 'subject', 'string' },		-- 标题
        { 'body', 'string' },		-- 内容
        { 'coins', { 'array', 'S3UInt32' } },		-- 附件
        { 'coin_flag', 'uint32' },		-- 货币属性
    }
)

-- =========================通迅协议============================
base.reg( 'PQMailWrite', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 角色Id
        { 'subject', 'string' },		-- 邮件标题
        { 'body', 'string' },		-- 邮件正文
        { 'coins', { 'array', 'S3UInt32' } },		-- 附件数据
    }, 281547260
)

base.reg( 'PQMailTake', 'SMsgHead',
    {
        { 'mail_id', 'uint32' },		-- mail id
    }, 632569249
)

base.reg( 'PQMailDel', 'SMsgHead',
    {
        { 'mail_id', 'uint32' },		-- mail id
    }, 364932350
)

base.reg( 'PRMailData', 'SMsgHead',
    {
        { 'set_type', 'uint32' },		-- [ kObjectAdd, kObjectUpdate, kObjectDel ]
        { 'data', 'SUserMail' },
    }, 1094044067
)

base.reg( 'PRMailDataList', 'SMsgHead',
    {
        { 'set_type', 'uint32' },		-- [ kObjectAdd, kObjectUpdate, kObjectDel ]
        { 'list', { 'array', 'SUserMail' } },
    }, 1082870710
)

-- 服务器内部中转协议
base.reg( 'PRMailWriteLocal', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'data', 'SUserMail' },
    }, 2126766481
)

-- 修改阅读协议
base.reg( 'PQMailReaded', 'SMsgHead',
    {
        { 'mail_id', 'uint32' },
    }, 155252786
)

-- ==========================全服邮件用=========================
base.reg( 'PQMailGetSystemId', 'SMsgHead',
    {
    }, 628964938
)

base.reg( 'PRMailGetSystemId', 'SMsgHead',
    {
        { 'system_mail_id', 'uint32' },
    }, 1243053845
)

base.reg( 'PQMailSave', 'SMsgHead',
    {
        { 'data', 'SUserMail' },
    }, 435304958
)

base.reg( 'PRMailSave', 'SMsgHead',
    {
        { 'mail_id', 'uint32' },
    }, 1994869338
)

base.reg( 'PQMailSystemTake', 'SMsgHead',
    {
        { 'auto_id', 'uint32' },
    }, 239248455
)

base.reg( 'PRMailSystemTake', 'SMsgHead',
    {
        { 'data', { 'indices', 'SUserMail' } },
    }, 1976428632
)


