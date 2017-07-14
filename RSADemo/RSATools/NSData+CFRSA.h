//
//  NSData+CFRSA.h
//  DemoSet
//
//  Created by MountainCao on 2017/7/13.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecBase.h>

//分组加密，支持最大的加密块为 block 和填充方式有关

typedef enum : NSUInteger {
    //不填充，最大数据块为 blockSize
    RSAPaddingNONE,
    //填充方式pkcs1,最大数据块为 blockSize -11
    RSAPaddingPKCS1,
    //填充方式OAEP, 最大数据块为 blockSize -42
    RSAPaddingOAEP,
} RSAPaddingTYPE;

@interface NSData (CFRSA)

/**
 公钥加密
 */
- (NSData *)RSAEncryptWith:(SecKeyRef )publicKey paddingType:(RSAPaddingTYPE )pdType;

/**
 私钥解密
 */
- (NSData *)RSADecryptWith:(SecKeyRef )privateKey paddingType:(RSAPaddingTYPE )pdType;

@end
