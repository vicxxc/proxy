////
//// Based on work from Michael Hohl on 29.06.12
////
//
//#import "NSData+AES256.h"
//#import <CommonCrypto/CommonCryptor.h>
//#import <CommonCrypto/CommonDigest.h>
//
//@implementation NSData (AESAdditions)
//
//
//- (NSData *)AES256EncryptWithKeyAndIV:(NSData*)key withIV:(NSData*)iv
//{
//	// Init cryptor
//	CCCryptorRef cryptor = NULL;
//	
//	// Create Cryptor
//	CCCryptorStatus cryptStatus = CCCryptorCreateWithMode(kCCEncrypt,          // operation
//															kCCModeCFB,          // mode CTR
//															kCCAlgorithmAES,  // Algorithm
//															ccNoPadding,      // padding
//															(iv == nil ? NULL :[iv bytes]),            // can be NULL, because null is full of zeros
//															key.bytes,           // key
//															[key length],          // keylength
//															NULL,                //const void *tweak
//															0,                   //size_t tweakLength,
//															0,                   //int numRounds,
//															kCCModeOptionCTR_BE, //CCModeOptions options,
//															&cryptor);           //CCCryptorRef *cryptorRef
//
//    if (cryptStatus == kCCSuccess)
//    {
//		// Alloc Data Out
//		NSMutableData *cipherDataDecrypt = [NSMutableData dataWithLength:self.length + kCCBlockSizeAES128];
//		
//		//alloc number of bytes written to data Out
//		size_t outLengthDecrypt;
//		
//		//Update Cryptor
//		CCCryptorStatus updateDecrypt = CCCryptorUpdate(cryptor,
//														self.bytes,                     //const void *dataIn,
//														self.length,                    //size_t dataInLength,
//														cipherDataDecrypt.mutableBytes, //void *dataOut,
//														cipherDataDecrypt.length,       // size_t dataOutAvailable,
//														&outLengthDecrypt);             // size_t *dataOutMoved)
//		
//		if (updateDecrypt == kCCSuccess) {
//			cipherDataDecrypt.length = outLengthDecrypt;
//			CCCryptorStatus final = CCCryptorFinal(cryptor,                        //CCCryptorRef cryptorRef,
//												   cipherDataDecrypt.mutableBytes, //void *dataOut,
//												   cipherDataDecrypt.length,       // size_t dataOutAvailable,
//												   &outLengthDecrypt);             // size_t *dataOutMoved)
//			if (final == kCCSuccess) {
//				CCCryptorRelease(cryptor);
//			}
//			
//			return cipherDataDecrypt;
//		}
//    }
//    return nil;
//}
//
//- (NSData *)AES256DecryptWithKeyAndIV:(NSData*)key withIV:(NSData*)iv
//{
//	// Init cryptor
//	CCCryptorRef cryptor = NULL;
//	
//	// Create Cryptor
//	CCCryptorStatus cryptStatus = CCCryptorCreateWithMode(kCCDecrypt,          // operation
//														  kCCModeCFB,          // mode CTR
//														  kCCAlgorithmAES,  // Algorithm
//														  ccNoPadding,      // padding
//														  (iv == nil ? NULL :[iv bytes]),            // can be NULL, because null is full of zeros
//														  key.bytes,           // key
//														  [key length],          // keylength
//														  NULL,                //const void *tweak
//														  0,                   //size_t tweakLength,
//														  0,                   //int numRounds,
//														  kCCModeOptionCTR_BE, //CCModeOptions options,
//														  &cryptor);           //CCCryptorRef *cryptorRef
//	
//	if (cryptStatus == kCCSuccess)
//	{
//		// Alloc Data Out
//		NSMutableData *cipherDataDecrypt = [NSMutableData dataWithLength:self.length + kCCBlockSizeAES128];
//		
//		//alloc number of bytes written to data Out
//		size_t outLengthDecrypt;
//		
//		//Update Cryptor
//		CCCryptorStatus updateDecrypt = CCCryptorUpdate(cryptor,
//														self.bytes,                     //const void *dataIn,
//														self.length,                    //size_t dataInLength,
//														cipherDataDecrypt.mutableBytes, //void *dataOut,
//														cipherDataDecrypt.length,       // size_t dataOutAvailable,
//														&outLengthDecrypt);             // size_t *dataOutMoved)
//		
//		if (updateDecrypt == kCCSuccess) {
//			cipherDataDecrypt.length = outLengthDecrypt;
//			CCCryptorStatus final = CCCryptorFinal(cryptor,                        //CCCryptorRef cryptorRef,
//												   cipherDataDecrypt.mutableBytes, //void *dataOut,
//												   cipherDataDecrypt.length,       // size_t dataOutAvailable,
//												   &outLengthDecrypt);             // size_t *dataOutMoved)
//			if (final == kCCSuccess) {
//				CCCryptorRelease(cryptor);
//			}
//			
//			return cipherDataDecrypt;
//		}
//	}
//	return nil;
//}
//
//- (NSData *)convertHexStrToData:(NSString *)str {
//	if (!str || [str length] == 0) {
//		return nil;
//	}
//	
//	NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
//	NSRange range;
//	if ([str length] % 2 == 0) {
//		range = NSMakeRange(0, 2);
//	} else {
//		range = NSMakeRange(0, 1);
//	}
//	for (NSInteger i = range.location; i < [str length]; i += 2) {
//		unsigned int anInt;
//		NSString *hexCharStr = [str substringWithRange:range];
//		NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
//		
//		[scanner scanHexInt:&anInt];
//		NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
//		[hexData appendData:entity];
//		
//		range.location += range.length;
//		range.length = 2;
//	}
//	
//	return hexData;
//}
//- (NSData *)generateKey:(NSData *)password keyLen:(NSInteger)keyLen IVLen:(NSInteger)IVLen {
//	NSInteger count = 0;
//	NSInteger totalLen = keyLen + IVLen;
//	NSInteger i = 0;
//	NSMutableData *data = [password mutableCopy];
//	NSMutableArray *m = [NSMutableArray new];
//	while (count < totalLen) {
//		
//		if (i > 0) {
//			data = [NSMutableData new];
//			[data appendData:m[i-1]];
//			[data appendData:password];
//		}
//		NSData *d = [data MD5Digest];
//		[m addObject:d];
//		count += d.length;
//		i+=1;
//	}
//	NSMutableData *allData = [NSMutableData new];
//	[m enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//		[allData appendData:obj];
//	}];
//	
//	
//	return [allData subdataWithRange:NSMakeRange(0, keyLen)];
//}
//
//+(NSData *)MD5Digest:(NSData *)input {
//	unsigned char result[CC_MD5_DIGEST_LENGTH];
//	
//	CC_MD5(input.bytes, (CC_LONG)input.length, result);
//	return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
//}
//
//-(NSData *)MD5Digest {
//	return [NSData MD5Digest:self];
//}
//
//+(NSString *)MD5HexDigest:(NSData *)input {
//	unsigned char result[CC_MD5_DIGEST_LENGTH];
//	
//	CC_MD5(input.bytes, (CC_LONG)input.length, result);
//	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
//	for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
//		[ret appendFormat:@"%02x",result[i]];
//	}
//	return ret;
//}
//
//-(NSString *)MD5HexDigest {
//	return [NSData MD5HexDigest:self];
//}
//
//@end
