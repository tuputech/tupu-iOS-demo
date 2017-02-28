//
//  TPLicenseHandle.m
//  tupuCameraDemo
//
//  Created by drakeDan on 27/12/2016.
//  Copyright © 2016 tupu. All rights reserved.
//

#import "TPLicenseHandle.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation TPLicenseHandle

//+ (BOOL)needLicenseForNet {
//    NSDate *expire = [TUPULandmark getExpiration];
//    if (expire == nil) return YES;
//    NSDate *now = [NSDate date];
//    double result = [expire timeIntervalSinceDate:now];
//    return (result < 1 * 24 * 60 * 60.0);
//}
//
//+ (void)licenseFromNetworkWithCompletion:(void (^)(bool, NSDate *))done {
//    if (![TPLicenseHandle needLicenseForNet]) {
//        if (done) {
//            done(YES, [TUPULandmark getExpiration]);
//        }
//        return;
//    }
//    
//    NSString *authMsg = [TPSDKAuthKit authMsgWithDuration:TPLicenseDuration365Days APIs:[TUPULandmark getAPINames]];
//    
//    NSString *signature = [TPLicenseHandle hmac_sha1:TP_APP_SECRET text:authMsg];
//    NSLog(@"authMsg: %@\nappKey: %@\nsignature:%@", authMsg, TP_APP_SECRET, signature);
//    
//    NSDictionary *parameters = @{
//                                 @"authMsg": authMsg,
//                                 @"APPKey": TP_APP_KEY,
//                                 @"signature": signature
//                                 };
//    NSLog(@"params: %@", parameters);
//    NSMutableArray *postArray = [NSMutableArray array];
//    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* obj, BOOL *stop) {
//        [postArray addObject:[NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString: obj]]];
//    }];
//    
//    NSString *postString = [postArray componentsJoinedByString:@"&"];
//    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSURL *authAPI = [NSURL URLWithString:TP_LICENSE_API];
//    NSMutableURLRequest *netRequest = [NSMutableURLRequest requestWithURL:authAPI cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
//    [netRequest setHTTPMethod:@"POST"];
//    [netRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [netRequest setHTTPBody:postData];
//    
//    NSURLSession *urlSession = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:netRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if (!error) {
//            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            
//            if (result == NULL) {
//                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                
//                if (string) {
//                    NSLog(@"Set License %@", string);
//                    [TPSDKAuthKit setLicense:string APIs:[TUPULandmark getAPINames]];
//                }
//            } else {
//                NSLog(@"Set License from JSON%@", result);
//                [TPSDKAuthKit setLicense:[result objectForKey:@"message"] APIs:[TUPULandmark getAPINames]];
//            }
//            
//        } else {
//            NSLog(@"%@", error);
//        }
//        
//        NSDate *licenseExpire = [TUPULandmark getExpiration];
//        if (done) {
//            done(licenseExpire != nil, licenseExpire);
//        }
//    }];
//    
//    [dataTask resume];
//}

+ (NSString *)hmac_sha1:(NSString *)key text:(NSString *)text{
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSLog(@"hmac: %@", HMAC);
    return [HMAC base64EncodedStringWithOptions:0];
//    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
//    return mutableString;
}


+ (NSString *)percentEscapeString:(NSString *)string {
    NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/?"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
