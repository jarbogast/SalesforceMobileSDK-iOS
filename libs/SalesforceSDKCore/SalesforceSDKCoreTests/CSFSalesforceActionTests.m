/*
 Copyright (c) 2017-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

@import XCTest;
#import <OCMock/OCMock.h>

#import "CSFSalesforceAction.h"
#import "CSFAction+Internal.h"
#import "CSFNetwork.h"
#import "SFUserAccount.h"
#import "SFOAuthCredentials.h"

@interface CSFSalesforceActionTests : XCTestCase

@property (strong, nonatomic) CSFSalesforceAction *action;

@end

@implementation CSFSalesforceActionTests

- (void)setUp {
    [super setUp];
    self.action = [[CSFSalesforceAction alloc] initWithResponseBlock:^(CSFAction *action, NSError *error) {
        
    }];
}

- (void)testBaseUrlNilByDefault {
    XCTAssertNil(self.action.baseURL);
}

- (void)testAppendTrailingSlashForBaseURL {
    self.action.baseURL = [NSURL URLWithString:@"https://www.salesforce.com"];
    XCTAssertEqualObjects(self.action.baseURL, [NSURL URLWithString:@"https://www.salesforce.com/"]);
}

- (void)testSetBaseURLThenEnqueueOntoNetwork {
    NSURL *networkURL = [NSURL URLWithString:@"https://www.salesforce.com/"];
    NSURL *baseURL = [NSURL URLWithString:@"http://www.example.com/"];
    
    self.action.baseURL = baseURL;
    self.action.enqueuedNetwork = [self networkWithApiURL:networkURL];
    
    XCTAssertEqualObjects(self.action.baseURL, baseURL);
}

- (void)testEnqueueOntoNetworkThenSetBaseURL {
    NSURL *networkURL = [NSURL URLWithString:@"https://www.salesforce.com/"];
    NSURL *baseURL = [NSURL URLWithString:@"http://www.example.com/"];

    self.action.enqueuedNetwork = [self networkWithApiURL:networkURL];
    self.action.baseURL = baseURL;
    
    XCTAssertEqualObjects(self.action.baseURL, baseURL);
}

- (void)testEnqueueOntoNetwork {
    NSURL *networkURL = [NSURL URLWithString:@"https://www.salesforce.com/"];
    
    self.action.enqueuedNetwork = [self networkWithApiURL:networkURL];
    
    XCTAssertEqualObjects(self.action.baseURL, networkURL);
}

- (id)networkWithApiURL:(NSURL *)url {
    id credentials = OCMClassMock([SFOAuthCredentials class]);
    OCMStub([credentials apiUrl]).andReturn(url);
    
    id account = OCMClassMock([SFUserAccount class]);
    OCMStub([account credentials]).andReturn(credentials);
    
    id network = OCMClassMock([CSFNetwork class]);
    OCMStub([network account]).andReturn(account);
    
    return network;
}

@end