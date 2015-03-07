//
//  MEOCloudSharedFolder.h
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import <Foundation/Foundation.h>

@interface MCShare : NSObject
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* type;

- (instancetype)initWithIdentifier:(NSString*)identifier dictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;
@end
