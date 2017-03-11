#import <Foundation/Foundation.h>

@interface NSData (AES256)
- (NSData *)AES256EncryptWithKeyAndIV:(NSData*)key withIV:(NSData*)iv;
- (NSData *)AES256DecryptWithKeyAndIV:(NSData*)key withIV:(NSData*)iv;
- (NSData *)convertHexStrToData:(NSString *)str;
- (NSData *)generateKey:(NSData *)password keyLen:(NSInteger)keyLen IVLen:(NSInteger)IVLen;
+ (NSData *)MD5Digest:(NSData *)input;
- (NSData *)MD5Digest;
+ (NSString *)MD5HexDigest:(NSData *)input;
- (NSString *)MD5HexDigest;
@end
