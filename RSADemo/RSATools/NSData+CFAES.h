//
//  NSData+CFAES.h
//  DemoSet
//
//  Created by MountainCao on 2017/7/13.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 支持的AES key size 有 128位，192位，256位
 数据填充方式：kCCOptionPKCS7Padding
 分组模式：cbc,ecb
 */

@interface NSData (CFAES)

/**
 AES cbc 模式加密，
 @key 长度16字节，24字节，32字节
 @iv 16字节
 */
- (NSData *)AES_CBC_EncryptWith:(NSData *)key iv:(NSData *)iv;

/**
 AES cbc 模式解密，
 @key 长度16字节，24字节，32字节
 @iv 16字节
 */
- (NSData *)AES_CBC_DecryptWith:(NSData *)key iv:(NSData *)iv;

/**
 AES ecb 模式加密，
 @key 长度16字节，24字节，32字节
 */
- (NSData *)AES_ECB_EncryptWith:(NSData *)key;

/**
 AES ecb 模式解密，
 @key 长度16字节，24字节，32字节
 */
- (NSData *)AES_ECB_DecryptWith:(NSData *)key;

@end
