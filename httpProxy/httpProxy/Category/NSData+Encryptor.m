#import "NSData+Encryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (AESAdditions)

+(NSData *)MD5Digest:(NSData *)input {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(input.bytes, (CC_LONG)input.length, result);
	return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

-(NSData *)MD5Digest {
	return [NSData MD5Digest:self];
}

- (NSArray *)generateKeyAndIV:(NSData *)password keyLen:(NSInteger)keyLen IVLen:(NSInteger)IVLen {
	NSInteger count = 0;
	NSInteger totalLen = keyLen + IVLen;
	NSInteger i = 0;
	NSMutableData *data = [password mutableCopy];
	NSMutableArray *m = [NSMutableArray new];
	while (count < totalLen) {
		if (i > 0) {
			data = [NSMutableData new];
			[data appendData:m[i-1]];
			[data appendData:password];
		}
		NSData *d = [data MD5Digest];
		[m addObject:d];
		count += d.length;
		i+=1;
	}
	NSMutableData *allData = [NSMutableData new];
	[m enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[allData appendData:obj];
	}];
	NSData *key = [allData subdataWithRange:NSMakeRange(0, keyLen)];
	NSData *IV = [allData subdataWithRange:NSMakeRange(keyLen, IVLen)];
	return [[NSArray alloc] initWithObjects:key,IV, nil];
}

+(id)randomDataWithLength:(NSUInteger)length
{
	NSMutableData* data=[NSMutableData dataWithLength:length];
	[[NSInputStream inputStreamWithFileAtPath:@"/dev/urandom"] read:(uint8_t*)[data mutableBytes] maxLength:length];
	return data;
}

- (NSData *)convertHexStrToData:(NSString *)str {
	if (!str || [str length] == 0) {
		return nil;
	}

	NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
	NSRange range;
	if ([str length] % 2 == 0) {
		range = NSMakeRange(0, 2);
	} else {
		range = NSMakeRange(0, 1);
	}
	for (NSInteger i = range.location; i < [str length]; i += 2) {
		unsigned int anInt;
		NSString *hexCharStr = [str substringWithRange:range];
		NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];

		[scanner scanHexInt:&anInt];
		NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
		[hexData appendData:entity];

		range.location += range.length;
		range.length = 2;
	}

	return hexData;
}

@end
