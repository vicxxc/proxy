//
//  Encryptor.m
//  httpProxy
//
//  Created by scorpio on 2017/3/14.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "Encryptor.h"
#import "NSData+Encryptor.h"
#import <NAAEAD.h>

typedef NS_ENUM(NSUInteger, EncryptMethod) {
	AES128CFB,
	AES192CFB,
	AES256CFB,
	CHACHA20,
	SALSA20,
	RC4MD5
};
typedef NS_ENUM(NSUInteger, Operation) {
	ENCRYPT,
	DECRYPT
};

@interface Encryptor()
@property (nonatomic, strong) NSData *key;
@property (nonatomic, strong) NSData *encryptIV;
@property (nonatomic, strong) NSData *decryptIV;
@property (nonatomic, assign) NSInteger keyLen;
@property (nonatomic, assign) NSInteger IVlen;
@property (nonatomic, assign) BOOL ifWriteIV;
@property (nonatomic, assign) EncryptMethod method;
@property (nonatomic, assign) CCCryptorRef encryptor;
@property (nonatomic, assign) CCCryptorRef decryptor;
@end

@implementation Encryptor

- (instancetype)initWithPassword:(NSString *)password method:(NSString *)method {
	self = [super init];
	if (self) {
		NSDictionary *methodKeyIVLenDic = @{
											@(AES128CFB):@[@(16),@(16)],
											@(AES192CFB):@[@(24),@(16)],
											@(AES256CFB):@[@(32),@(16)],
											@(CHACHA20):@[@(32),@(8)],
											@(SALSA20):@[@(32),@(8)],
											@(RC4MD5):@[@(16),@(16)],
											};
		
		method = [method lowercaseString];
		if([method isEqualToString:@"aes-128-cfb"]){
			self.method = AES128CFB;
		}else if([method isEqualToString:@"aes-192-cfb"]){
			self.method = AES192CFB;
		}else if([method isEqualToString:@"aes-256-cfb"]){
			self.method = AES256CFB;
		}else if([method isEqualToString:@"chacha20"]){
			self.method = CHACHA20;
		}else if([method isEqualToString:@"salsa20"]){
			self.method = SALSA20;
		}else if([method isEqualToString:@"rc4-md5"]){
			self.method = RC4MD5;
		}
		NSArray *keyIVLenArray = [methodKeyIVLenDic objectForKey:@(self.method)];
		self.keyLen = [keyIVLenArray[0] integerValue];
		self.IVlen = [keyIVLenArray[1] integerValue];
		NSArray *keyIV = [[NSData new] generateKeyAndIV:[password dataUsingEncoding:NSUTF8StringEncoding] keyLen:self.keyLen IVLen:self.IVlen];
		self.key = keyIV[0];
		self.encryptIV = keyIV[1];
	}
	return self;
}

- (CCCryptorRef)initWithCCOperation:(CCOperation)op CCMode:(CCMode)mode CCAlgorithm:(CCAlgorithm)alg IV:(NSData *)iv Key:(NSData *)key{
	CCCryptorRef cryptor = NULL;
	CCCryptorCreateWithMode(op, // operation
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
	
	return cryptor;
}

- (NSData *)generateKey:(NSData *)password keyLen:(NSInteger)keyLen IVLen:(NSInteger)IVLen {
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
	
	return [allData subdataWithRange:NSMakeRange(0, keyLen)];
}

- (NSData *)encryptData:(NSData *)data{
	NSMutableData *toSendData = [NSMutableData new];
	if(!self.ifWriteIV){
		self.ifWriteIV = YES;
		[toSendData appendData:self.encryptIV];
	}
	[toSendData appendData:[self updateData:data operation:ENCRYPT]];
	return [[NSData alloc] initWithData:toSendData];
}

- (NSData *)decryptData:(NSData *)data{
	NSData *toDecryptedData;
	if(!self.decryptIV){
		self.decryptIV = [data subdataWithRange:NSMakeRange(0, self.IVlen)];
		toDecryptedData = [data subdataWithRange:NSMakeRange(self.IVlen, data.length-self.IVlen)];
	}else{
		toDecryptedData = data;
	}
	return [self updateData:toDecryptedData operation:DECRYPT];
}

- (NSData *)updateData:(NSData *)data operation:(Operation)operation{
	if(self.method == AES128CFB || self.method == AES192CFB || self.method == AES256CFB){
		 CCCryptorRef cryptor;
		if(operation == DECRYPT){
			cryptor = self.decryptor;
		}else{
			cryptor = self.encryptor;
		}
		NSMutableData *cipherDataEncrypt = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
		size_t outLengthDecrypt;
		CCCryptorStatus updateDecrypt = CCCryptorUpdate(cryptor,
														data.bytes,                     //const void *dataIn,
														data.length,                    //size_t dataInLength,
														cipherDataEncrypt.mutableBytes, //void *dataOut,
														cipherDataEncrypt.length,       // size_t dataOutAvailable,
														&outLengthDecrypt);             // size_t *dataOutMoved)
		
		if (updateDecrypt == kCCSuccess) {
			cipherDataEncrypt.length = outLengthDecrypt;
			CCCryptorFinal(cryptor,							// CCCryptorRef cryptorRef,
						   cipherDataEncrypt.mutableBytes,  // void *dataOut,
						   cipherDataEncrypt.length,        // size_t dataOutAvailable,
						   &outLengthDecrypt);              // size_t *dataOutMoved)
			
			return cipherDataEncrypt;
		}
	}
	if(self.method == CHACHA20){
		NSError *error;
		NSData *updateData;
		if(operation == DECRYPT){
			updateData = [[NAAEAD new] encryptChaCha20Poly1305:data nonce:self.decryptIV key:self.key additionalData:nil error:&error];
		}else{
			updateData = [[NAAEAD new] decryptChaCha20Poly1305:data nonce:self.encryptIV key:self.key additionalData:nil error:&error];
		}
		return updateData;
	}
	return nil;
}

- (CCCryptorRef)encryptor
{
	if (!_encryptor){
		if(self.method == AES128CFB || self.method == AES192CFB || self.method == AES256CFB){
			_encryptor = [self initWithCCOperation:kCCEncrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:self.encryptIV Key:self.key];
		}
	}
	return _encryptor;
}

- (CCCryptorRef)decryptor
{
	if (!_decryptor){
		if(self.method == AES128CFB || self.method == AES192CFB || self.method == AES256CFB){
			_decryptor = [self initWithCCOperation:kCCDecrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:self.decryptIV Key:self.key];
		}
	}
	return _decryptor;
}
@end
