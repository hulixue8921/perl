敏感字过滤系统使用方法：
1、安装需求：
perl 5.10版本
安装AVLTree 、JSON 、Data::Dumper、 POE（Wheel::SocketFactory Wheel::ReadWrite）
2、自定义敏感词库存入（/root/perl/m ）
如：/root/perl/m：
习近平
毛泽东
...
..
词库注意事项（1、敏感词中不能出现空格、‘，’ 等   2、敏感词中不能出现over（程序中有特殊用途））
3、启动
chmod +x minggan.pl
4、使用方法：
启动后，客户端是用socket 去连接服务端（ip+port,此服务port 端口定义5000）, 发送 文本内容 
注意事项(文本内容必须 拼接‘\n’)
返回内容是处理过的文本内容
