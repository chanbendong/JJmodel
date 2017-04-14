//
//  NSObject+JJModel.h
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



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


@protocol JJModel <NSObject>
@optional

/**
 通用遍历属性
 
 如果json和字典的key跟属性名不符，实现这个方法可以返回附加的遍历
 
 Example:
 
 json:
 {
 "n":"Harry Pottery",
 "p": 256,
 "ext" : {
 "desc" : "A book written by J.K.Rowling."
 },
 "ID" : 100010
 }
 
 model:
 @interface YYBook : NSObject
 @property NSString *name;
 @property NSInteger page;
 @property NSString *desc;
 @property NSString *bookID;
 @end
 
 @implementation YYBook
 + (NSDictionary *)modelCustomPropertyMapper {
 return @{@"name"  : @"n",
 @"page"  : @"p",
 @"desc"  : @"ext.desc",
 @"bookID": @[@"id", @"ID", @"book_id"]};
 }
 @end
 
 @return A custom mapper for properties.
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;


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
 通用类遍历属性
 
 如果属性是一个对象容器，例如数组，集合，字典，实现这个方法会返回一个属性类的遍历，去分别哪个对象需要被添加到数组，集合，字典
 
 
 Example:
 @class YYShadow, YYBorder, YYAttachment;
 
 @interface YYAttributes
 @property NSString *name;
 @property NSArray *shadows;
 @property NSSet *borders;
 @property NSDictionary *attachments;
 @end
 
 @implementation YYAttributes
 + (NSDictionary *)modelContainerPropertyGenericClass {
 return @{@"shadows" : [YYShadow class],
 @"borders" : YYBorder.class,
 @"attachments" : @"YYAttachment" };
 }
 @end
 
 @return A class mapper.
 */
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

/**<
    在黑名单中的属性将会在模型转换中被忽略
    return nil 则忽略这个特征
  @return 属性数组
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
    没有在白名单中的属性将会在模型转换中被忽略
    return nil 则忽略这个特征
 
 @return 属性数组
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;
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

NS_ASSUME_NONNULL_END
