//
//  ViewController.m
//  RSADemo
//
//  Created by MountainCao on 2017/7/14.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

// 在线生成密钥对：http://web.chacuo.net/netrsakeypair

#define kRSA_KEY_SIZE   1024

#define kPublicKey @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCljo6vcgrScv8Y+WSlAdGZsdauCGRNMX180nSVAKEuVG3+oC616cCjCJAFmcs1LL/udLBE9ozfc56KSBdpbwk4rO0dKtuannkBo+1p4qR5JBs1LtYl4XPSWlTNZQxMw0qn1mIMq0KKIlDSMMPiYeOk/YzWiMx3F4jQ8mLk9w+a1wIDAQAB"

#define kPrivateKey @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKWOjq9yCtJy/xj5ZKUB0Zmx1q4IZE0xfXzSdJUAoS5Ubf6gLrXpwKMIkAWZyzUsv+50sET2jN9znopIF2lvCTis7R0q25qeeQGj7WnipHkkGzUu1iXhc9JaVM1lDEzDSqfWYgyrQooiUNIww+Jh46T9jNaIzHcXiNDyYuT3D5rXAgMBAAECgYB+9a3yWZB3Bv0d19MYvyZPqROq7oCMuhEzsej5gzwX3WNkys5HbvTtkdlwkhpFswWVBiNPH4u0qGPCQ7rAfgghFJx/e5SsCyvB5v4R9/729YbCHsotgURKKwTtpoYjQmD5miMzuY5vZqwzzZR1DlRWrxwVJBW4ylaJNjvUFW/vkQJBANHIlXjwEAJjMVJw42kbZcAyQdTlDZu/FJZizWhZtHFGUCO4rg9NCWC2ptc9Vg1FYwAnIjOjKYFq5TrD3LWNFRUCQQDKB6soNKDEpw+Jpl7Qkna0fnaRWYZR3FUfpaGstP16nNk5tllb293SsEYNVRr19avEzVw7G5DiX4zt8gxLOoM7AkBiD/xnEvi41PtaSTDUkh0HMbb6OLQayMBr5/WSwNQLW03c1NhwiJdIoTjuRlqyS2wSxzhCoROmznwm8yV5rGBdAkBCmGKH/0kbacJKaogIkq8EckddRDhtlYaNxwhTKNoBZ+CHEJ/GEuS9BZQh4vLfLtsvJU6IwV5x8HNBIC+DQMdvAkACrp8KU2eyxwKNsJ4Uk42j6ori/cOyiwH9tKpVXDW8Ht/eHE3tX2vnRf/4zy0IBpTZ+ODs3OoqASn4zsOKiFY0"

#import "ViewController.h"
#import "CFSeckeyTools.h"
#import "NSData+CFRSA.h"
#import <Security/Security.h>


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    SecKeyRef publicKeyRef; //公钥
    SecKeyRef privateKeyRef;//私钥
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"常用加密解密方式";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row==0) {
        
        cell.textLabel.text =@"RSA 直接使用pem文件加密解密(iOS10之后系统方法)";
        
    } else if (indexPath.row==1) {
        
        cell.textLabel.text = @"RSA 使用der文件加密，p12文件解密";
        
    } else if (indexPath.row==2) {
        
        cell.textLabel.text = @"RSA 使用公钥密钥字符串加密解密(最常用)";
        
    } else if (indexPath.row==3) {
        
        cell.textLabel.text = @"系统方法产生公钥密钥(不使用openssl相关的命令行)";

    } else if (indexPath.row==4) {
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        [self rsaUsePemDoctumentEncryptAndDecrypt];
        
    } else if (indexPath.row == 1) {
        
        [self rsaUseDerP12DoctumentEncryptAndDecrypt];
        
    } else if (indexPath.row == 2) {
        
        [self rsaUseStringEncryptAndDecrypt];
        
    } else if (indexPath.row == 3) {
        
        [self rsaUseSystemGenerateRSAKeyEncryptAndDecrypt];
        
    } else if (indexPath.row == 4) {
        
    }
}

/*
 使用pem文件加密解密(ios 10 以后)
 */
- (void)rsaUsePemDoctumentEncryptAndDecrypt {
    
    //----------------------加密
    
    NSString *password = @"cf9527";
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *pubPath = [[NSBundle mainBundle]pathForResource:@"rsa_public_key" ofType:@"pem"];
    SecKeyRef pubRef = [CFSeckeyTools publicKeyFromPem:pubPath keySize:kRSA_KEY_SIZE];
    
    NSData *encryptData = [data RSAEncryptWith:pubRef paddingType:RSAPaddingNONE];
    
    NSLog(@"==加密之后的数据=%@",encryptData);
    
    //-----------------------解密
    
    NSString *priPath = [[NSBundle mainBundle]pathForResource:@"private_key" ofType:@"pem"];
    SecKeyRef priRef = [CFSeckeyTools privaKeyFromPem:priPath keySize:kRSA_KEY_SIZE];
    
    NSData *decryptData = [encryptData RSADecryptWith:priRef paddingType:RSAPaddingNONE];
    NSLog(@"==解密之后的数据=%@",[[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding]);
    
}

/*
 使用der和p12文件加密解密(服务端应该给der文件让客户端加密)
 */
- (void)rsaUseDerP12DoctumentEncryptAndDecrypt {
    
    //-----------------------加密
    NSString *password = @"cf9527";
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *pubPath = [[NSBundle mainBundle]pathForResource:@"public_key" ofType:@"der"];
    SecKeyRef pubRef = [CFSeckeyTools publicKeyFromCer:pubPath];
    NSData *encryptData = [data RSAEncryptWith:pubRef paddingType:RSAPaddingNONE];
    NSLog(@"==加密之后的数据=%@",encryptData);
    
    //-----------------------解密用的p12文件
    
    NSString *priPath = [[NSBundle mainBundle]pathForResource:@"private_key" ofType:@"p12"];
    
    //p12文件一般都有密码，只是我这次生产文件时没设置密码
    SecKeyRef priRef = [CFSeckeyTools privateKeyFromP12:priPath password:@""];
    
    NSData *decryptData = [encryptData RSADecryptWith:priRef paddingType:RSAPaddingNONE];
    NSLog(@"==解密之后的数据=%@",[[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding]);
    
}

/*
 使用公钥密钥字符串加密解密(通常服务端给个公钥字符串)
 */
- (void)rsaUseStringEncryptAndDecrypt {
    
    NSString *string = @"cf9527";
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSData *enData = [data RSAEncryptWith:[CFSeckeyTools addPublicKey:kPublicKey] paddingType:RSAPaddingNONE];
    
    NSLog(@"==加密之后:=%@",enData);
    
    NSData *deData = [enData RSADecryptWith:[CFSeckeyTools addPrivateKey:kPrivateKey] paddingType:RSAPaddingNONE];
    
    NSString *deStr = [[NSString alloc]initWithData:deData encoding:NSUTF8StringEncoding];
    
    NSLog(@"==加密之后:=%@",deStr);

}

/** 系统生成公钥密钥（可用于客户端自主加密） */
- (void)rsaUseSystemGenerateRSAKeyEncryptAndDecrypt {
    
    [self generateRSAKeyPair:kRSA_KEY_SIZE];
    
    NSString *string = @"cf9527";
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *enData = [data RSAEncryptWith:publicKeyRef paddingType:RSAPaddingNONE];
    
    NSLog(@"==加密之后:=%@",enData);
    
    NSData *deData = [enData RSADecryptWith:privateKeyRef paddingType:RSAPaddingNONE];
    NSString *deStr = [[NSString alloc]initWithData:deData encoding:NSUTF8StringEncoding];
    
    NSLog(@"==加密之后:=%@",deStr);
    
}

//生成RSA密钥对，公钥和私钥，支持的SIZE有
// sizes for RSA keys are: 512, 768, 1024, 2048.
- (void)generateRSAKeyPair:(int )keySize
{
    
    OSStatus ret = 0;
    publicKeyRef = NULL;
    privateKeyRef = NULL;
    ret = SecKeyGeneratePair((CFDictionaryRef)@{(id)kSecAttrKeyType:(id)kSecAttrKeyTypeRSA,(id)kSecAttrKeySizeInBits:@(keySize)}, &publicKeyRef, &privateKeyRef);
    
    NSAssert(ret==errSecSuccess, @"密钥对生成失败：%d",ret);
    
//    NSLog(@"publicKeyRef==%@",publicKeyRef);
//    NSLog(@"privateKeyRef==%@",privateKeyRef);
//    NSLog(@"max size:%lu",SecKeyGetBlockSize(privateKeyRef));
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
