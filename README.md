# HLSEncryptDataPlay
use AVplayer to play encrypt data

使用方法：
需将hls-ecb-test文件夹移动到手机模拟器的Document目录下

实现原理：
播放本地的m3u8 文件，每个ts都经过ecb加密
实现AVplayer直接播放NSData数据，将NSData通过HttpServer桥伪装成路径
