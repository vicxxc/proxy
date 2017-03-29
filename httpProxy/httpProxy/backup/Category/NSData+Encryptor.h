#import <Foundation/Foundation.h>

@interface NSData (AES256)
+ (NSData *)MD5Digest:(NSData *)input;
- (NSData *)MD5Digest;
- (NSArray *)generateKeyAndIV:(NSData *)password keyLen:(NSInteger)keyLen IVLen:(NSInteger)IVLen;
+ (id)randomDataWithLength:(NSUInteger)length;
- (NSData *)convertHexStrToData:(NSString *)str;
@end
