//
//  CCCrypto.m
//  httpProxy
//
//  Created by scorpio on 2017/3/10.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "CCCrypto.h"

@interface CCCrypto ()
@property (nonatomic, assign) CCCryptorRef cryptor;
@end


@implementation CCCrypto
+ (instancetype)shareInstance
{
	static CCCrypto* g_cryptor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		g_cryptor = [[CCCrypto alloc] init];
		
	});
	return g_cryptor;
}

- (instancetype)initWithCCOperation:(CCOperation)op CCMode:(CCMode)mode CCAlgorithm:(CCAlgorithm)alg IV:(NSData *)iv Key:(NSData *)key{
	self = [super init];
	if (self) {
		CCCryptorRef cryptor = NULL;
		// Create Cryptor
		CCCryptorStatus cryptStatus = CCCryptorCreateWithMode(op, // operation
															  mode, // mode CTR
															  alg, // Algorithm
															  ccNoPadding,      // padding
															  (iv == nil ? NULL :[iv bytes]), // can be NULL, because null is full of zeros
															  key.bytes, // key
															  [key length], // keylength
															  NULL, //const void *tweak
															  0, //size_t tweakLength,
															  0, //int numRounds,
															  kCCModeOptionCTR_BE, //CCModeOptions options,
															  &cryptor); //CCCryptorRef *cryptorRef
		
		if (cryptStatus == kCCSuccess){
			self.cryptor = cryptor;
		}
	}
	return self;
}

- (NSData *)encryptData:(NSData *)data{
	NSMutableData *cipherDataEncrypt = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
	size_t outLengthDecrypt;
	CCCryptorStatus updateDecrypt = CCCryptorUpdate(self.cryptor,
													data.bytes,                     //const void *dataIn,
													data.length,                    //size_t dataInLength,
													cipherDataEncrypt.mutableBytes, //void *dataOut,
													cipherDataEncrypt.length,       // size_t dataOutAvailable,
													&outLengthDecrypt);             // size_t *dataOutMoved)
	
	if (updateDecrypt == kCCSuccess) {
		cipherDataEncrypt.length = outLengthDecrypt;
		CCCryptorFinal(self.cryptor,                        //CCCryptorRef cryptorRef,
					   cipherDataEncrypt.mutableBytes, //void *dataOut,
					   cipherDataEncrypt.length,       // size_t dataOutAvailable,
					   &outLengthDecrypt);             // size_t *dataOutMoved)
	
		return cipherDataEncrypt;
	}
	return nil;
}
@end
