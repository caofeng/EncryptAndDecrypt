//
//  NSString+CFBase64.m
//  RSADemo
//
//  Created by MountainCao on 2017/7/14.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import "NSString+CFBase64.h"

@implementation NSString (CFBase64)

- (NSString *)base64EncodedString; {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64DecodedString {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}


@end
