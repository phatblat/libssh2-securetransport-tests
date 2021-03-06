//
//  libssh2 securetransport bignum.m
//  libssh2 secure transport
//
//  Created by Keith Duncan on 30/11/2014.
//  Copyright (c) 2014 Keith Duncan. All rights reserved.
//

#import "libssh2test.h"

@interface libssh2_securetransport_bignum : libssh2test

@end

@implementation libssh2_securetransport_bignum

- (void)testDiffieHellmanGroup1 {
	static const unsigned char p_value[128] = {
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xC9, 0x0F, 0xDA, 0xA2, 0x21, 0x68, 0xC2, 0x34,
		0xC4, 0xC6, 0x62, 0x8B, 0x80, 0xDC, 0x1C, 0xD1,
		0x29, 0x02, 0x4E, 0x08, 0x8A, 0x67, 0xCC, 0x74,
		0x02, 0x0B, 0xBE, 0xA6, 0x3B, 0x13, 0x9B, 0x22,
		0x51, 0x4A, 0x08, 0x79, 0x8E, 0x34, 0x04, 0xDD,
		0xEF, 0x95, 0x19, 0xB3, 0xCD, 0x3A, 0x43, 0x1B,
		0x30, 0x2B, 0x0A, 0x6D, 0xF2, 0x5F, 0x14, 0x37,
		0x4F, 0xE1, 0x35, 0x6D, 0x6D, 0x51, 0xC2, 0x45,
		0xE4, 0x85, 0xB5, 0x76, 0x62, 0x5E, 0x7E, 0xC6,
		0xF4, 0x4C, 0x42, 0xE9, 0xA6, 0x37, 0xED, 0x6B,
		0x0B, 0xFF, 0x5C, 0xB6, 0xF4, 0x06, 0xB7, 0xED,
		0xEE, 0x38, 0x6B, 0xFB, 0x5A, 0x89, 0x9F, 0xA5,
		0xAE, 0x9F, 0x24, 0x11, 0x7C, 0x4B, 0x1F, 0xE6,
		0x49, 0x28, 0x66, 0x51, 0xEC, 0xE6, 0x53, 0x81,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	};

	_libssh2_bn *p = _libssh2_bn_init();
	_libssh2_bn_from_bin(p, 128, p_value);

	_libssh2_bn *g = _libssh2_bn_init();
	_libssh2_bn_set_word(g, 2);

	_libssh2_bn *x = _libssh2_bn_init();
	_libssh2_bn_rand(x, 128, 0, -1);

	_libssh2_bn *e = _libssh2_bn_init();
	_libssh2_bn_mod_exp(e, g, x, p, NULL);

	_libssh2_bn_free(p);
	_libssh2_bn_free(g);
	_libssh2_bn_free(x);
	_libssh2_bn_free(e);
}

- (void)testRandomNumber {
	_libssh2_bn *x = _libssh2_bn_init();
	_libssh2_bn_rand(x, 128, 128, 0);

	CCStatus status;
	char *string = CCBigNumToDecimalString(&status, x);
	XCTAssertEqual(status, kCCSuccess);
	XCTAssertTrue(strcmp(string, "0") != 0);

	free(string);

	_libssh2_bn_free(x);
}

- (void)testToData {
	uint16_t value = 65280;

	_libssh2_bn *x = _libssh2_bn_init();
	_libssh2_bn_set_word(x, value);

	uint16_t buffer;
	_libssh2_bn_to_bin(x, &buffer);

	_libssh2_bn_from_bin(x, 2, &buffer);

	_libssh2_bn_free(x);
}

@end
