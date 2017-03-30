# SOCKS5协议
SOCKS5协议的全部内容点击查看[RFC 1928 - SOCKS Protocol Version 5](https://tools.ietf.org/html/rfc1928).
## 协议具体流程
### 客户端向服务端协商认证方法
+----+----------+----------+
|VER | NMETHODS | METHODS  |
+----+----------+----------+
| 1  |    1     | 1 to 255 |
+----+----------+----------+
* VER表示当前socks协议版本,X’05’
* NMETHODS表示客户端校验支持的个数
* METHODS表示客户端校验支持方法
### 服务端接收到请求以后就会从客户端的方法列表中选择一个方法
+----+--------+
|VER | METHOD |
+----+--------+
| 1  |   1    |
+----+--------+
* VER表示协议的版本
* METHOD的含义
> 00h表示没有认证方法  
> 01h表示GSSAPI  
> 02h表示通过USERNAME/PASSWORD认证  
> 03h到7fh都是由ISNA分配  
> 80h到feh是为私有方法保留的区间  
> ffh表示没有可以接受的方法  
### 协商完成以后，客户端开始发送详细的请求，请求的格式为
+----+-----+-------+------+----------+----------+
|VER | CMD |  RSV  | ATYP | DST.ADDR | DST.PORT |
+----+-----+-------+------+----------+----------+
| 1  |  1  | X'00' |  1   | Variable |    2     |
+----+-----+-------+------+----------+----------+	
* VER表示协议的版本
* CMD表示请求请求类型
> 01h表示CONNECT连接请求  
> 02h表示BIND连接请求  
> 03h表示通过UDP协议发送请求  
* RSV保留字段
- ATYP表示后面DST.ADDR地址类型
> 01h表示IPv4(DST.ADDR长度为4个字节)  
> 03h表示为域名(DST.ADDR第一个字节表示域名的长度)  
> 04h表示IPv6(DST.ADDR长度为16个字节)  
- DST.ADDR表示请求的目的地址
- DST.PORT表示请求的目的端口
### 服务端接收到请求后，会评估请求中携带的DST.ADDR和DST.PORT(目的地址的是否可达)，然后返回给客户端一条或多条响应，格式为
+----+-----+-------+------+----------+----------+
|VER | REP |  RSV  | ATYP | BND.ADDR | BND.PORT |
+----+-----+-------+------+----------+----------+
| 1  |  1  | X'00' |  1   | Variable |    2     |
+----+-----+-------+------+----------+----------+
- VER表示协议的版本
- REP表示回复类型
> 00h succeeded  
> 01h general SOCKS server failure  
> 02h connection not allowed by ruleset  
> 03h Network unreachable  
> 04h Host unreachable  
> 05h Connection refused  
> 06h TTL expired  
> 07h Command not supported  
> 08h Address type not supported  
> 09h到ffh没有分配  
- RSV保留字段
- ATYP表示后面DST.ADDR地址类型
> 01h表示IPv4(DST.ADDR长度为4个字节)  
> 03h表示为域名(DST.ADDR第一个字节表示域名的长度)  
> 04h表示IPv6(DST.ADDR长度为16个字节)  
- BND.ADDR表示socks服务器绑定的地址
- BND.PORT表示socks服务器绑定的端口
至此，客户端和服务端的连接已经建立完成，后续客户端可以通过SOCKS服务端与目的地址进行数据传递。

