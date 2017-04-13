//
//  NSObject+JJModel.h
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JJModel <NSObject>
@optional

/**
 如果你需要在json转对象的时候创建不同类的实例，可以使用这个基于字典的方法去选择相应的类
 示例:
 + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
 if (dictionary[@"radius"] != nil) {
 return [YYCircle class];
 } else if (dictionary[@"width"] != nil) {
 return [YYRectangle class];
 } else if (dictionary[@"y2"] != nil) {
 return [YYLine class];
 } else {
 return [self class];
 }
 }
 @param  dictionary json转成的字典
 @return 选择的类
 */
+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

/**
 这个方法类似于 '-(BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;'
 但是需要在model转换之前调用
 如果model实现了这个方法，他将会在'+modelWithJSON:','+modelWithDictionary:','-modelSetWithJSON:' 和 '-modelSetWithDictionary:'。
 @param  dic json转成的字典
 @return 选择的类
 */

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

/**
 如果默认json转model不适合你的model，实现这个方法可以使json转成model的属性,如果返回NO，转换进程将会忽略这个model
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

@end

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
NS_ASSUME_NONNULL_END
