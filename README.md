#16asmcode
8086汇编示例代码
## V1
这里主要记录8086cpu的masm汇编的示例代码，后续会添加masm汇编的项目和8086cpu的反汇编引擎

## V2
联系人管理系统
- ​   实现了对内存和字符串的函数：memset、memcpy、 memcmp、strlen、strcpy、strcmp、strsub等
- ​   实现了对堆的管理：malloc、free等，主要通过控制块管理
- ​   实现了对io的函数：print、scan、fopen、fseek、fwrite、fread、fclose等
- ​   数据管理主要通过带哨兵节点的双向链表
- ​   本系统实现的函数没有使用宏汇编
- ​   本系统实现对数据的保存和加载
- ​   本系统实现增删改和模糊查询


效果图
img[https://github.com/l140w4n9/16asmcode/blob/main/image/GIF%202023-01-17%2012-16-10.gif]
