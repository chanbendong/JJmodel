//
//  main.m
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+JJModel.h"

@interface YYBook : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) uint64_t pages;
@property (nonatomic, strong) NSDate *publishDate;
@end

@implementation YYBook
@end

static void SimpleObjectExample() {
    YYBook *book = [YYBook modelWithJSON:@"     \
                    {                                           \
                    \"name\": \"Harry Potter\",              \
                    \"pages\": 512,                          \
                    \"publishDate\": \"2010-01-01\"          \
                    }"];
//    NSString *bookJSON = [book modelToJSONString];
    NSLog(@"Book: %@", book);
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        NSLog(@"Hello, World!");
        SimpleObjectExample();
    }
    return 0;
}
