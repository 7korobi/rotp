//
//  IGHMAC.h
//  IGDigest
//
//  Created by Chong Francis on 13年4月1日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@interface OtpGenerator : NSObject

+(NSString *)generateWithDigest:(NSString*)digest key:(NSString*)key input:(uint64_t)counter digits: (int)digits;
@end
