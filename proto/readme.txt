./config.xml	—— 序列化结构生成配置文件
./protocol.txt	—— 传输协议所需要的 Type、Option 定义文件夹
./constant.txt  —— 项目使用的常量定义
./ignore.txt	—— 客户端过滤类名
./seq/		—— 序列化协议结构文件夹, 所有需要定义的传输协议结构都必须定在这个目录下, 并以 *.seq 来命名后缀名, 定义格式请详看上面网址

./update.bat	—— 更新相关目录
./commit.bat	—— 提交相关目录
./序列化解释器	—— 生成协议于客户端目录(../client/src/proxy/struct)和服务器目录(../server/src/common/proto)

./onekey.bat	—— 一键更新、生成、提交