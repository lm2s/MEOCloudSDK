//
//  MEOCloudUser.h
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import <Foundation/Foundation.h>

@interface MCUser : NSObject
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL isUser;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
