//
//  NSString+CFBase64.h
//  RSADemo
//
//  Created by MountainCao on 2017/7/14.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CFBase64)

/**
 *  转换为Base64编码
 */
- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;

@end
