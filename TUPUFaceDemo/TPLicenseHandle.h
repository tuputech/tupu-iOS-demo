//
//  TPLicenseHandle.h
//  tupuCameraDemo
//
//  Created by drakeDan on 27/12/2016.
//  Copyright © 2016 tupu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "TPSDKAuthKit.h"
//#import <tupu-sdk/TUPULandmark.h>
#import <tuputechSDK/TPTechSDK.h>
#import "TPNetConfig.h"

@interface TPLicenseHandle : NSObject

+ (BOOL) needLicenseForNet;

+ (void)licenseFromNetworkWithCompletion:(void (^)(bool license, NSDate *expire))done;

@end
