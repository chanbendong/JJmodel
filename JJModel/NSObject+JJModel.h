//
//  NSObject+JJModel.h
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JJModel)

+ (instancetype)modelWithJSON:(id)json;

/**<
    设置接收者的属性为一个键值对的字典即字典转对象
    @prama dic 遍历对象属性得到的键值对
    @discussion 字典中的键将会遍历接收者的属性名，将值设置到属性中，如果值的类型不符合属性的数据类型，这个方法将会尝试基于以下规则进行转换:
    ‘NSString’,‘NSNumer’ -> c number such as BOOL, int, long, float, NSUInteger...
    `NSString` -> NSDate, parsed with format "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd".
    `NSString` -> NSURL.
    `NSValue` -> struct or union, such as CGRect, CGSize, ...
    `NSString` -> SEL, Class.
    @return 是否成功
 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;

@end
