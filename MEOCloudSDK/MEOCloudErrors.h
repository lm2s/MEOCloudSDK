//
//  MEOCloudErrors.h
//  MEOCloudApp
//
//  Created by Luís Silva on 11/02/15.
//
//

#ifndef MEOCloudApp_MEOCloudErrors_h
#define MEOCloudApp_MEOCloudErrors_h

#define ERROR_DOMAIN com.lm2s.meocloud.sdk

#define TO_OBJC_STRING(x) @"x"
#define ERROR(error_code,error_msg) [NSError errorWithDomain:TO_OBJC_STRING(ERROR_DOMAIN) code:error_code userInfo:@{@"description" : TO_OBJC_STRING(error_msg)}];


#endif
