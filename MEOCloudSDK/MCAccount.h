//
//  MEOCloudAccount.h
//  MEOCloudApp
//
//  Created by Luís Silva on 04/02/15.
//
//

#import <Foundation/Foundation.h>

@interface MCAccount : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSDate* lastEvent;
@property (nonatomic, assign) unsigned long long quotaShared;
@property (nonatomic, assign) unsigned long long quota;
@property (nonatomic, assign) unsigned long long quotaNormal;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* language;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;

@end
