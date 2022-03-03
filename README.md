# hmap-prebuilt

## 简介

hmap-prebuilt基于美团的[一款可以让大型iOS工程编译速度提升50%的工具](https://tech.meituan.com/2021/02/25/cocoapods-hmap-prebuilt.html)，以 [Header Map 技术](https://clang.llvm.org/doxygen/classclang_1_1HeaderMap.html) 为基础，进一步提升代码的编译速度，完善头文件的搜索机制。

使用hmap-prebuilt前后编译时间对比

**使用前时长**
![使用hamp_prebuilt前的编译时间](https://neroblog.oss-cn-hangzhou.aliyuncs.com/time_unused_hmap_prebuilt.jpg)

**使用后时长**
![使用hmap_prebuilt后的编译时间](https://neroblog.oss-cn-hangzhou.aliyuncs.com/time_used_hmap_prebuilt.jpg)

## 使用

1. 将[hmap-prebuilt](./hmap-prebuilt)连同文件夹拷贝至你的电脑任一位置。
2. 在Podfile中引入`hmap_prebuilt.rb`
3. 在 post_install 中调用`hmap_prebuilt`函数并传入 installer 参数
4. 执行 pod install

![hmap_prebuilt 配置](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_hmap_prebuilt_config.jpg)

## Example

这里提供了一个[Example App](./Example)可供参考。
1. 安装Example
2. 运行`create_test_modules.rb`创建测试组件
3. 执行 pod install 并运行项目

## 作者

NeroXie, xyh30902@163.com

## 许可证

NNBox 基于 MIT 许可证，查看 LICENSE 文件了解更多信息。

