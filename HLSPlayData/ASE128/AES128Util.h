//
//  AES128Util.h
//  ASE128Demo
//
//  Created by zhenghaishu on 11/11/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES128Util : NSObject

+(NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)key;

+(NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)key;

@end
