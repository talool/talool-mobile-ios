//
//  RegistrationOperation.m
//  Talool
//
//  Created by Douglas McCuen on 11/26/13.
//  Copyright (c) 2013 Douglas McCuen. All rights reserved.
//

#import "RegistrationOperation.h"
#import "Talool-API/ttCustomer.h"
#import "Talool-API/ttSocialAccount.h"
#import "Talool-API/TaloolPersistentStoreCoordinator.h"

@interface RegistrationOperation()

@property (nonatomic, readwrite, strong) NSString *email;
@property (nonatomic, readwrite, strong) NSString *password;
@property (nonatomic, readwrite, strong) NSString *lastName;
@property (nonatomic, readwrite, strong) NSString *firstName;
@property (strong, nonatomic) NSNumber *sex;
@property (nonatomic, readwrite, strong) NSDate *birthDate;
@property (nonatomic, readwrite, strong) NSString *facebookId;
@property (nonatomic, readwrite, strong) NSString *facebookToken;
@end

@implementation RegistrationOperation

- (id) initWithUser:(NSString *)e
           password:(NSString *)p
          firstName:(NSString *)fName
           lastName:(NSString *)lName
                sex:(NSNumber *)s
          birthDate:(NSDate *)bDate
         facebookId:(NSString *)fbId
      facebookToken:(NSString *)fbToken
           delegate:(id<OperationQueueDelegate>)d
{
    if (self = [super init])
    {
        self.email = e;
        self.password = p;
        self.delegate = d;
        self.firstName = fName;
        self.lastName = lName;
        self.sex = s;
        self.birthDate = bDate;
        self.facebookId = fbId;
        self.facebookToken = fbToken;
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        
        NSMutableDictionary *delegateResponse;
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self getContext];
        ttCustomer *customer = [ttCustomer createCustomer:self.firstName
                                                 lastName:self.lastName
                                                    email:self.email
                                            socialAccount:nil
                                                  context:context];
        

        [customer setAsFemale:([self.sex intValue]==0)];
        
        [customer setBirthDate:self.birthDate];
        
        if (self.facebookId)
        {
            ttSocialAccount *sa = [ttSocialAccount createSocialAccount:(int *)SOCIAL_NETWORK_FACEBOOK
                                                               loginId:self.facebookId
                                                                 token:self.facebookToken
                                                               context:context];
            [customer addSocialAccountsObject:sa];
        }
        
        BOOL result = [ttCustomer registerCustomer:customer password:self.password context:context error:&error];
        
        if (result)
        {
            delegateResponse = [self setUpUser:&error];
            result = [[delegateResponse objectForKey:DELEGATE_RESPONSE_SUCCESS] boolValue];
        }
        
        
        if (self.delegate)
        {
            if (!delegateResponse)
            {
                delegateResponse = [[NSMutableDictionary alloc] init];
            }
            [delegateResponse setObject:[NSNumber numberWithBool:result] forKey:DELEGATE_RESPONSE_SUCCESS];
            if (error)
            {
                [delegateResponse setObject:error forKey:DELEGATE_RESPONSE_ERROR];
            }
            [(NSObject *)self.delegate performSelectorOnMainThread:(@selector(userAuthComplete:))
                                                        withObject:delegateResponse
                                                     waitUntilDone:NO];
        }
        
    }
    
}
@end
