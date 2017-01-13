##TUPUSDK
TUPUSDK 是集成了面部关键点追踪和美颜等功能的基于GPUImage 的开发套件

##TUPUSDK 的特性

* 人脸关键点追踪
*  速度: 8-10 ms
*  数量：83 点
* 美颜
* 贴纸
* 基于GPUImage，结构合理，集成简单




##依赖

* GPUImage 
* libTPSDKAuthKit

##运行环境
* iOS 8.3 以上
* OpenGLES2.0

##集成
```javascript
#import <GPUImage/GPUImageFramework.h>
#import <tupu-sdk/tupu.h>

//初始化tupusdk 关键点检测对象
TUPULandmark *tupu = ...
//设置 GPUImageCamera 用来获取相机
GPUImageCamera *videoCamera = ...
//设置SDK 内置美颜滤镜
TPBeautifyFilter *beautifyFilter = ...

//设置贴纸滤镜
TPStickerFilter *stickerFilter = ...

//将美颜滤镜加入处理管线
[videoCamera addTarget: beautifyFilter];
//将贴纸滤镜加入处理管线
[beautifyFilter addTarget: TPStickerFilter];
...

//实现TPRenderingDelegate 方法获取渲染前像素
- (void)TPRendererWillBeginRender:(GPUImageFramebuffer *)buffer {
[buffer lock];
CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
//使用tupusdk 检测对象进行关键点检测
[tupu getLandmark:pixelBuffer smoothEnable:YES];
if (tupu.isFace) {
//更新贴纸关键点
stickerFilter.faces = @[tupu.points];
}
[buffer unlock];
}

//实现此方法获取最终渲染结果
- (void)TPRendererDidFinishRender:(GPUImageFramebuffer *)buffer {
//编码，推流
}


```

##关键点
coming soon...

##美颜
coming soon...

##贴纸
coming soon...

##自定义贴纸通道
coming soon...

##鉴权
coming soon...



