#手动集成
*Bugtags SDK 全部版本均采用 HTTPS 协议进行网络传输，完全符合 Apple ATS 安全标准，请放心使用。*

### 注意：

### 步骤：
#### 1.下载[SDK压缩包](https://www.tuputech.com/)并解压缩
#### 2. 将 GPUImage.framework 和 framework 文件夹拖到 Xcode 项目中
#### 3. 在 AppDelegate.m 中导入头文件

```
#import <tuputechSDK/TPTechSDK.h>
```
	
#### 4. 在项目 AppDelegate 的 application didFinishLaunchingWithOptions 方法中初始化 TupuTech SDK（请不要在异步线程中调用）

> 图谱SDK初始化除了初始化功能本身以外，需要对接下来可能用到的功能组合（SDK称为services）进行鉴权。SDK考虑到开发者对于app secret安全性的考虑，提供了两种方式：
	
首先创建两种方式都需要用的鉴权service：
		
```
id<TPSDKAuthInterface> authService = [TPTechSDK createTPAuthService];
	
```
	
	
第一种，开发者使用TupuTech SDK提供的autoInstallLicenseBySDKWithAppkey方法：
> 这种用起来简单，但是有泄漏app secret的风险。
	
	
```
[authService autoInstallLicenseBySDKWithAppkey:TP_APP_KEY appSecret:TP_APP_SECRET serviceIDs:@[@(TPFaceCheckService)] complete:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
        NSLog(@"Install tuputech liscense success!");
    } else {
        NSLog(@"Install tuputech liscense failed, err = [%@]", [error domain]);
    }
}];
```
	
第二种，开发者首先利用鉴权service生成authMsg，然后拿着authMsg去开发者自己业务服务器请求license，业务服务器想图谱科技鉴权服务器请求license，然后返回给client。
> 本质上就是把第一种方法中需要用到appsecret的代码放到放在服务器上，来降低泄漏appsecret的风险。
	
```
NSString *authMsg = [authService authMsgWithDuration:TPLicenseDuration30Days APIs:@[@(TPAuthService), @(TPFaceCheckService)]];
//HttpHandler需要开发者自己实现，其功能就是根据authMsg去自己业务服务器请求license。这样就可以将app secret放在服务器，规避泄漏的风险。
//客户端通过参数authMsg向服务器请求license，服务器根据tupuSDK提供的算法（后面有介绍）向tuputech鉴权服务器请求license，然后返回给客户端。
[HttpHandler downloadLicenseWithAuthMsg:authMsg complete:^(NSString *license, NSError *err) {
    if(!err && license) {
        [authService setLicense:license APIs:@[@(TPAuthService), @(TPFaceCheckService)]];
    }
 }]
```
	
#### 5. 代码示例
TupuSDK是以id+protocol这种方式对SDK外的代码提供服务的，TupuSDK现提供如下服务：
	
* 	人脸识别service
* 	渲染service（包括美颜、大眼瘦脸功能、人脸贴图功能）
* 	On the way...
	
	> ✌️注意：TupuTech SDK所有的服务（Service）都需要鉴权（除鉴权服务TPSDKAuthInterface本身除外），所以务必保证步骤四（安装license）是返回成功的。
	
	
	#### 创建人脸识别service：
	
	```
	[TPTechSDK createService:TPFaceCheckService complete:^(id service, NSError *error) {
        if (!error) {
        	  //@_landmarkService: 人脸识别service
            _landmarkService = (id<TPLandmarkServiceInterface>)service;
            [_landmarkService setFaceRectDebugScale:self.boxScale];
            [_landmarkService enableDebugMode:YES];
            [self tryStartupVideoCamera];
        }
    }];
    
    [_landmarkService faceCheckAndLandmark:pixelBuffer smoothEnable:_smoothEnabled complete:^(NSError *error, BOOL isFace, NSArray<NSValue*> *keyPoints, CGRect rect) {
            if (isFace) {
                [_stickerFilter updateFaceKeyPoint:@[keyPoints]];
                [_landmarkFilter updateFaceKeyPoint:keyPoints];
                [_landmarkFilter updateFaceRect:rect];
            } else {
                [_stickerFilter updateFaceKeyPoint:@[]];
                [_landmarkFilter updateFaceKeyPoint:@[]];
                [_landmarkFilter updateFaceRect:CGRectNull];
            }
        } debug:^(NSString *debugInfo, UIImage *debugImg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (debugInfo) {
                    self.debugInfoView.text = debugInfo;
                }
                
                if (debugImg) {
                    [self.debugImageView setImage:debugImg];
                }
            });

        }];
	```

	#### 创建渲染service：
		
	> TupuSDK的美颜、人脸贴图功能依赖GPUImage库，所以通过renderservice创建对应的service即可。
	
	```
	[TPTechSDK createService:TPRenderingService complete:^(id service, NSError *error) {
        if (!error) {
            _landmarkService = (id<TPLandmarkServiceInterface>)service;
            [_landmarkService setFaceRectDebugScale:self.boxScale];
            [_landmarkService enableDebugMode:YES];
            [self tryStartupVideoCamera];
        }
    }];
    
    /*
    *贴图filter：根据人脸识别的结果在对应的点上渲染开发者定义的特效贴图
    *GPUImageFilter<TPReceiveFaceKeyPointProtocol> *stickerFilter;
    */
    
    self.stickerFilter = [_renderService createStickerFilter];
    
    /*
    *美颜filter：立即生效
    *GPUImageFilterGroup *beautifyFilter;
    */
    
    self.beautifyFilter = [_renderService createTPBeautifyFilter];
    
    
	```
	
	> 最好可以运行demo，可以在代码层面对SDK有一个更明确的认识。

### 参考资源：

[官方demo](https://github.com/tuputech/tupu-iOS-demo)

[官网](https://www.tuputech.com/)