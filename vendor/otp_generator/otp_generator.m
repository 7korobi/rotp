//
//  IGHMAC.m
//  IGDigest
//
//  Created by Chong Francis on 13年4月1日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "otp_generator.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

static NSUInteger kPinModTable[] = {
  0,
  10,
  100,
  1000,
  10000,
  100000,
  1000000,
  10000000,
  100000000,
};

@implementation OtpGenerator

+(NSString *)generateWithDigest:(NSString*)digest key:(NSString*)key input:(uint64_t)counter digits: (int)digits{
  CCHmacAlgorithm alg;
  NSUInteger hashLength = 0;
  if ([digest isEqualToString:@"sha1"]){
    alg = kCCHmacAlgSHA1;
    hashLength = CC_SHA1_DIGEST_LENGTH;
  } else if ([digest isEqualToString:@"sha256"]) {
    alg = kCCHmacAlgSHA256;
    hashLength = CC_SHA256_DIGEST_LENGTH;
  } else if ([digest isEqualToString:@"sha512"]) {
    alg = kCCHmacAlgSHA512;
    hashLength = CC_SHA512_DIGEST_LENGTH;
  } else if ([digest isEqualToString:@"md5"]) {
    alg = kCCHmacAlgMD5;
    hashLength = CC_MD5_DIGEST_LENGTH;
  } else {
    return nil;
  }
  NSMutableData *hash = [NSMutableData dataWithLength:hashLength];

  counter = NSSwapHostLongLongToBig(counter);
  NSData *keyData = [self hexToBytes:key];
  NSData *counterData = [NSData dataWithBytes:&counter
                                       length:sizeof(counter)];
  CCHmacContext ctx;
  CCHmacInit(&ctx, alg, [keyData bytes], [keyData length]);
  CCHmacUpdate(&ctx, [counterData bytes], [counterData length]);
  CCHmacFinal(&ctx, [hash mutableBytes]);
  NSData *out = [NSData dataWithBytes:hash length:hashLength];

  const char *ptr = [hash bytes];
  unsigned char offset = ptr[hashLength-1] & 0x0f;
  unsigned long truncatedHash =
    NSSwapBigIntToHost(*((unsigned long *)&ptr[offset])) & 0x7fffffff;
  unsigned long pinValue = truncatedHash % kPinModTable[digits];

  return [NSString stringWithFormat:@"%0*lu", digits, pinValue];
}

+(NSData*) hexToBytes:(NSString*)key {
  NSMutableData* data = [NSMutableData data];
  int idx;
  for (idx = 0; idx+2 <= key.length; idx+=2) {
    NSRange range = NSMakeRange(idx, 2);
    NSString* hexStr = [key substringWithRange:range];
    NSScanner* scanner = [NSScanner scannerWithString:hexStr];
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    [data appendBytes:&intValue length:1];
  }
  return data;
}

@end
