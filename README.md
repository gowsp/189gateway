# 189gateway

基于shell的天翼网关命令行工具, 要求: 

- [curl](https://github.com/curl/curl)
- [jq](https://github.com/stedolan/jq)部分命令下可选, gwinfo, devinfo, lsport要求

## 使用说明

[下载](https://github.com/gowsp/189gateway/releases/latest)最新版, 修改文件中的天翼网关用户名和密码, 执行相关命令. 目前支持以下功能:

- `bash gateway.sh gwinfo` 输出网关信息
- `bash gateway.sh wanip {地址类型}` 输出网关外网IP; 地址类型: -4 ipv4; -6 ipv6; 为空时ipv4地址
- `bash gateway.sh devinfo {设备类型}` 输出设备信息; 设备类型: 0 有线终端; 1 无线终端; 为空时输出全部已连接终端信息
- `bash gateway.sh lsport` 列出端口映射列表
- `bash gateway.sh addport {虚拟服务名称} {局域网IP} {服务协议} {内部端口} {外部端口}`: 增加端口映射
- `bash gateway.sh opport {服务名称} {命令: disable enable del}` 操作端口映射, 命令支持 disable 禁用; enable 启用; del 删除
- `bash gateway.sh reboot` 重启天翼网关