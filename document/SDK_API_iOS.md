#iOS SDK API

## SDK鉴权

### TPLicenseDuration证书类型

```
/** 30天有效期 */
TPLicenseDuration30Days

/** 365天有效期 */
TPLicenseDuration365Days
```

## 创建SDK service

### TPServiceType服务类型枚举

```

/** 鉴权服务 */
TPAuthService

/** 人脸检测服务 */
TPFaceCheckService

/** 渲染服务 */
TPRenderingService

/** 大眼瘦脸服务 */
TPRenderFaceThinService 
```

### @protocol TPServiceInterfaceBase所有服务的父protocol (所有service都会实现)

```
/**该TPservice是否需要鉴权*/
- (BOOL)isAuthable:(BOOL)usrIsTupuTech;

/** 获取过期时间*/
- (NSDate *)getExpiration;

/** 获取service的API ID，后续会去掉*/
- (NSInteger)getAPIId;

/** 是否开启debug模式*/
- (void)enableDebugMode:(BOOL)enable;

@optional
/** 获取版本号 */
- (NSString *)getVersion;

/**传递自定义参数启动service，作为开发者不需要关注*/
- (void)bootupService:(NSDictionary*)params complete:(TuPuBooleanResultBlock)block;

```

### @protocol TPSDKAuthInterface （鉴权服务）

```
/** 根据TPServiceType查询目标服务是否可用 */
- (void)authServiceByType:(TPServiceType)type complete:(TuPuAuthServiceResultBlock)block;

/** 根据需要用到的service组合生成authMsg*/
- (NSString*)authMsgWithDuration:(TPLicenseDuration)duration APIs:(NSArray <NSNumber*> *)apis;

/** 将服务器返回的license传给SDK进行鉴权 */
- (BOOL)setLicense:(NSString *)licenseString APIs:(NSArray<NSNumber *> *)apis;

/** SDK将生成authMsg、请求license，设置license几个方法进行了封装，方便开发者在不考虑泄漏app secre风险的情况下，只需要调用一个方法就可以完成license的安装和鉴权 */
- (void)autoInstallLicenseBySDKWithAppkey:(NSString*)appkey appSecret:(NSString*)secret serviceIDs:(NSArray<NSNumber*>*)ids complete:(TuPuBooleanResultBlock)block;
```

### @protocol TPLandmarkServiceInterface （人脸识别服务）

```
/** 设置人脸识别范围比例 */
- (void)setFaceRectDebugScale:(float)scale;

/** 人脸检测并返回结果 */
- (void)faceCheckAndLandmark:(CVPixelBufferRef)pixelBuffer smoothEnable:(BOOL)enable complete:(TuPuFaceCheckResultBlock)block debug:(TuPuFaceCheckDebugInfo)debugBlock;
```

### @protocol TPRenderServiceInterface （渲染服务）

```
/** 创建美颜filter */
- (GPUImageFilterGroup*)createTPBeautifyFilter;

/** 创建根据人脸检测结果渲染人脸区域的filter */
- (GPUImageFilter<TPReceiveFaceKeyPointProtocol,TPSetRenderEventDelegateProtocol>*)createTPLandmarkFilter;

/** 根据人脸检测结果渲染贴图的filter */
- (GPUImageFilter<TPReceiveFaceKeyPointProtocol>*)createStickerFilter;

/** SDK加载贴图素材库，并返回贴图数组，方便开发者业务层查显示素材信息 */
- (void)loadStickerWithPath:(NSString*)path complete:(TuPuRenderLoadStickerResult)block;

/** 渲染贴图数组中指定的贴图 */
- (void)renderStickerWithIndex:(NSInteger)index;
```

### 参考资源：

[官方demo](https://github.com/tuputech/tupu-iOS-demo)
