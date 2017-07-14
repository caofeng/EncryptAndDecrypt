//
//  NSData+CFHASH.h
//  DemoSet
//
//  Created by MountainCao on 2017/7/13.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCDIGESTAlgorithm) {
    //md2 16字节长度
    CCDIGEST_MD2 = 1000,
    //md4 16字节长度
    CCDIGEST_MD4,
    //md5 16字节长度
    CCDIGEST_MD5,
    //sha1 20字节长度
    CCDIGEST_SHA1,
    //SHA224 28字节长度
    CCDIGEST_SHA224,
    //SHA256 32字节长度
    CCDIGEST_SHA256,
    //SHA384 48字节长度
    CCDIGEST_SHA384,
    //SHA512 64字节长度
    CCDIGEST_SHA512,
};

@interface NSData (CFHASH)

/**
 计算数据的hash值，根据不同的算法
 */
- (NSData *)hashDataWith:(CCDIGESTAlgorithm )ccAlgorithm;


/**
 返回 hex string的 data
 */
- (NSString *)hexString;


@end
