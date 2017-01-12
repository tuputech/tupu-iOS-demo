//
//  TPSDKAuthKit.h
//  TPSDKAuthKit
//
//  Created by drakeDan on 24/11/2016.
//  Copyright © 2016 tupu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TPLicenseDuration) {
    TPLicenseDuration30Days = 30,
    TPLicenseDuration365Days = 365
};

@interface TPSDKAuthKit : NSObject

+ (NSString*) authMsgWithDuration:(TPLicenseDuration)duration APIs:(NSArray <NSNumber*> *)apis;

+ (BOOL) setLicense:(NSString *)licenseString APIs:(NSArray<NSNumber *> *)apis;

@end
