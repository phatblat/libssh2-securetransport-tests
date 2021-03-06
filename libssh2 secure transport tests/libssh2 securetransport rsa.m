//
//  libssh2 securetransport rsa.m
//  libssh2 secure transport
//
//  Created by Keith Duncan on 23/02/2014.
//  Copyright (c) 2014 Keith Duncan. All rights reserved.
//

#import "libssh2test.h"

@interface libssh2_securetransport_rsa : libssh2test

@end

@implementation libssh2_securetransport_rsa

- (void)_testRSASignAndVerifyWithKey:(NSString *)keyName passphrase:(NSString *)passphrase
{
	NSURL *keyLocation = [[NSBundle bundleForClass:self.class] URLForResource:keyName withExtension:nil];

	int rsaError;
	libssh2_rsa_ctx *rsa;

	if (passphrase != nil) {
		rsaError = _libssh2_rsa_new_private(&rsa, NULL, keyLocation.fileSystemRepresentation, NULL);
		XCTAssertNotEqual(rsaError, 0, @"_libssh2_rsa_new_private should return non 0 for encrypted keys decoded without a passphrase");
	}

	rsaError = _libssh2_rsa_new_private(&rsa, NULL, keyLocation.fileSystemRepresentation, (unsigned char const *)passphrase.UTF8String);
	XCTAssertEqual(rsaError, 0, @"_libssh2_rsa_new_private should return 0");
	if (rsaError != 0) return;

	NSData *data = [self randomData:1024];
	XCTAssertNotNil(data, @"random data should be non nil");
	NSData *sha1 = [self SHA1:data];
	XCTAssertNotNil(sha1, @"sha1(random data) should be non nil");

	unsigned char *signature = NULL;
	size_t signatureLength = 0;
	rsaError = _libssh2_rsa_sha1_sign(NULL, rsa, [sha1 bytes], [sha1 length], &signature, &signatureLength);
	XCTAssertEqual(rsaError, 0, @"_libssh2_rsa_sha1_sign should return 0");
	if (rsaError != 0) return;

	rsaError = _libssh2_rsa_sha1_verify(rsa, signature, signatureLength, [data bytes], [data length]);
	XCTAssertEqual(rsaError, 0, @"_libssh2_rsa_sha1_verify should return 0 for a valid signature");

	NSData *rogueData = [self randomData:1024];
	rsaError = _libssh2_rsa_sha1_verify(rsa, signature, signatureLength, [rogueData bytes], [rogueData length]);
	XCTAssertEqual(rsaError, 1, @"_libssh2_rsa_sha1_verify should return 1 for a valid signature of rogue data");

	NSData *rogueSignature = nil;
	while (rogueSignature == nil || [rogueSignature isEqualToData:[NSData dataWithBytesNoCopy:signature length:signatureLength freeWhenDone:NO]]) {
		rogueSignature = [self randomData:signatureLength];
	}
	rsaError = _libssh2_rsa_sha1_verify(rsa, [rogueSignature bytes], [rogueSignature length], [data bytes], [data length]);
	XCTAssertEqual(rsaError, 1, @"_libssh2_rsa_sha1_verify should return 1 for an invalid signature");

	free(signature);

	rsaError = _libssh2_rsa_free(rsa);
	XCTAssertEqual(rsaError, 0, @"_libssh2_rsa_free should return 0");

	unsigned char *method;
	size_t methodLength;
	unsigned char *pubData;
	size_t pubDataLength;
	rsaError = _libssh2_pub_priv_keyfile(NULL, &method, &methodLength, &pubData, &pubDataLength, keyLocation.fileSystemRepresentation, passphrase.UTF8String);
	XCTAssertEqual(rsaError, 0, @"_libssh2_pub_priv_keyfile should return 0");
	if (rsaError != 0) return;

	XCTAssertTrue(memcmp(method, "ssh-rsa", methodLength) == 0);

	free(method);
	free(pubData);
}

#warning test that keys created using _libssh2_rsa_new can be used for sign verify

- (void)test_PEM_PKCS1_Plain
{
	[self _testRSASignAndVerifyWithKey:@"plain_pkcs1_rsa.pem" passphrase:nil];
}

- (void)test_DER_PKCS1_Plain
{
	[self _testRSASignAndVerifyWithKey:@"plain_pkcs1_rsa.der" passphrase:nil];
}

///
// These are recognised as BSAFE format keys

- (void)test_PEM_PKCS8_Plain
{
	[self _testRSASignAndVerifyWithKey:@"plain_pkcs8_rsa.pem" passphrase:nil];
}

- (void)test_DER_PKCS8_Plain
{
	[self _testRSASignAndVerifyWithKey:@"plain_pkcs8_rsa.p8" passphrase:nil];
}

//
///

- (void)test_PEM_PKCS1_Cipher
{
	[self _testRSASignAndVerifyWithKey:@"enc_pkcs1_rsa.pem" passphrase:@"test"];
}

- (void)test_PEM_PKCS8_Cipher
{
	[self _testRSASignAndVerifyWithKey:@"enc_pkcs8_rsa.pem" passphrase:@"test"];
}

- (void)test_DER_PKCS8_Cipher
{
	[self _testRSASignAndVerifyWithKey:@"enc_pkcs8_rsa.p8" passphrase:@"test"];
}

@end
