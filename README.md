# DLUDID
获取唯一UUID，卸载重装之后保证获取UUID不变

主要是将生成UUID，分别存储到keychain，pasteboard，和APP的UserDefaults中，其中keychain卸载之后不会被清空，pasteboard和UserDefaults使用来存储备份，以防止keychain中的数据不明原因的被清空。
具体流程见文章：http://blog.csdn.net/zgsxzdl/article/details/51356129
