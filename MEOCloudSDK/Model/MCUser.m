// MCUser.h
//
// Copyright (c) 2015 Luís M. Marques Silva
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "MCUser.h"

/*
"users":[
         {
             "id":"d6aef5c8-9594-4e4a-ae85-7405cd8a4ee8",
             "owner":true,
             "user":true,
             "name":"Luci Gel"
         },
         {
             "id":"e328c1e9-149c-4065-815e-274de86c5f32",
             "name":"Zé das couves"
         }
         ],
*/

@implementation MCUser
- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        if (dictionary[@"owner"]) {
            self.isOwner = [dictionary[@"owner"] boolValue];
        }
        if (dictionary[@"user"]) {
            self.isUser = [dictionary[@"user"] boolValue];
        }
        
        self.identifier = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.email = dictionary[@"email"];
    }
    return self;
}
@end
