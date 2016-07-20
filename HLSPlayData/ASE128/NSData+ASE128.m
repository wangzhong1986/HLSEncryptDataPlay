//
//  NSData+ASE128.m
//  YoukuCore
//
//  Created by zhenghaishu on 11/8/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import "NSData+ASE128.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (ASE128)

- (NSData *)AES128EncryptWithKey:(NSString *)key {

    NSMutableData *keyData = [NSMutableData dataWithLength:kCCKeySizeAES128];
    [keyData setData:[self convertHexStrToData:key]];
    [keyData setLength:kCCKeySizeAES128];
    
    const char *keyPtr = keyData.bytes;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) &~(kCCBlockSizeAES128 - 1);
    void *buffer = malloc(bufferSize* sizeof(char));
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}


- (NSData *)AES128DecryptWithKey:(NSString *)key {
    
    NSMutableData *keyData = [NSMutableData dataWithLength:kCCKeySizeAES128];
    [keyData setData:[self convertHexStrToData:key]];
    [keyData setLength:kCCKeySizeAES128];
    
    const char *keyPtr = keyData.bytes;
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = (dataLength + kCCBlockSizeAES128) &~(kCCBlockSizeAES128 - 1);
    void *buffer = malloc(bufferSize* sizeof(char));
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return resultData;
    }
    free(buffer);
    return nil;
    
}

- (NSString *)convertDataToHexStr {
    if (!self || [self length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
    
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

@end
