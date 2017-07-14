//
//  CFSeckeyTools.m
//  DemoSet
//
//  Created by MountainCao on 2017/7/13.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import "CFSeckeyTools.h"

@implementation CFSeckeyTools

/**
 从x509 cer证书中读取公钥
 */
+ (SecKeyRef )publicKeyFromCer:(NSString *)cerFile
{
    OSStatus            err;
    NSData *            certData;
    SecCertificateRef   cert;
    SecPolicyRef        policy;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    SecKeyRef           publicKeyRef;
    
    certData = [NSData dataWithContentsOfFile:cerFile];
    cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    policy = SecPolicyCreateBasicX509();
    err = SecTrustCreateWithCertificates(cert, policy, &trust);
    NSAssert(err==errSecSuccess,@"证书加载失败");
    err = SecTrustEvaluate(trust, &trustResult);
    NSAssert(err==errSecSuccess,@"公钥加载失败");
    publicKeyRef = SecTrustCopyPublicKey(trust);
    
    CFRelease(policy);
    CFRelease(cert);
    return publicKeyRef;
}

/**
 从 p12 文件中读取私钥，一般p12都有密码
 */
+ (SecKeyRef )privateKeyFromP12:(NSString *)p12File password:(NSString *)pwd

{
    NSData *            pkcs12Data;
    CFArrayRef          imported;
    NSDictionary *      importedItem;
    SecIdentityRef      identity;
    OSStatus            err;
    SecKeyRef           privateKeyRef;
    
    pkcs12Data = [NSData dataWithContentsOfFile:p12File];
    err = SecPKCS12Import((__bridge CFDataRef)pkcs12Data,(__bridge CFDictionaryRef) @{(__bridge NSString *)kSecImportExportPassphrase:pwd}, &imported);
    NSAssert(err==errSecSuccess,@"p12加载失败");
    importedItem = (__bridge NSDictionary *) CFArrayGetValueAtIndex(imported, 0);
    identity = (__bridge SecIdentityRef) importedItem[(__bridge NSString *) kSecImportItemIdentity];
    
    err = SecIdentityCopyPrivateKey(identity, &privateKeyRef);
    NSAssert(err==errSecSuccess,@"私钥加载失败");
    CFRelease(imported);
    
    
    return privateKeyRef;
}


+ (SecKeyRef )publicKeyFromPem:(NSString *)pemFile keySize:(size_t )size
{
    SecKeyRef pubkeyref;
    NSError *readFErr = nil;
    CFErrorRef errref = noErr;
    NSString *pemStr = [NSString stringWithContentsOfFile:pemFile encoding:NSASCIIStringEncoding error:&readFErr];
    NSAssert(readFErr==nil, @"pem文件加载失败");
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    NSData *dataPubKey = [[NSData alloc]initWithBase64EncodedString:pemStr options:0];
    
    NSMutableDictionary *dicPubkey = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dicPubkey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [dicPubkey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [dicPubkey setObject:@(size) forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    pubkeyref = SecKeyCreateWithData((__bridge CFDataRef)dataPubKey, (__bridge CFDictionaryRef)dicPubkey, &errref);
    
    NSAssert(errref==noErr, @"公钥加载错误");
    
    return pubkeyref;
}

+ (SecKeyRef )privaKeyFromPem:(NSString *)pemFile keySize:(size_t )size
{
    SecKeyRef prikeyRef;
    NSError *readFErr = nil;
    CFErrorRef err = noErr;
    
    NSString *pemStr = [NSString stringWithContentsOfFile:pemFile encoding:NSASCIIStringEncoding error:&readFErr];
    NSAssert(readFErr==nil, @"pem文件加载失败");
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"-----BEGIN RSA PRIVATE KEY-----" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"-----END RSA PRIVATE KEY-----" withString:@""];
    
    NSData *pemData = [[NSData alloc]initWithBase64EncodedString:pemStr options:0];
    
    NSMutableDictionary *dicPrikey = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dicPrikey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [dicPrikey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [dicPrikey setObject:@(size) forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    prikeyRef = SecKeyCreateWithData((__bridge CFDataRef)pemData, (__bridge CFDictionaryRef)dicPrikey, &err);
    NSAssert(err==noErr, @"私钥加载错误");
    
    
    return prikeyRef;
}

+ (SecKeyRef)addPrivateKey:(NSString *)key{
    
    NSRange spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    
    NSData *data =[[NSData alloc]initWithBase64EncodedString:key options:0];
    
    data = [self stripPrivateKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PrivKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    // Add persistent version of the key to system keychain
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)
     kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key{
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 22; //magic byte at offset 22
    
    if (0x04 != c_key[idx++]) return nil;
    
    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    // Now make a new NSData from this buffer
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}




+ (SecKeyRef)addPublicKey:(NSString *)key{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    // This will be base64 encoded, decode it.
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:key options:0];
    data = [self stripPublicKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx     = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

@end
