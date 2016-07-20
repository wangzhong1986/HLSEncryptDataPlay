//
//  NSData+ASE128.h
//  YoukuCore
//
//  Created by zhenghaishu on 11/8/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ASE128)

- (NSData *)AES128EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES128DecryptWithKey:(NSString *)key;   //解密

- (NSString *)convertDataToHexStr;//数据转16进制字符串
@end
