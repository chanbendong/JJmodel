//
//  NSObject+JJModel.m
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import "NSObject+JJModel.h"
#import "YYClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))
#define msgSend(obj) ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model, meta->_setter, obj);


/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, YYEncodingType) {
    YYEncodingTypeMask       = 0xFF, ///< mask of type value
    YYEncodingTypeUnknown    = 0, ///< unknown
    YYEncodingTypeVoid       = 1, ///< void
    YYEncodingTypeBool       = 2, ///< bool
    YYEncodingTypeInt8       = 3, ///< char / BOOL
    YYEncodingTypeUInt8      = 4, ///< unsigned char
    YYEncodingTypeInt16      = 5, ///< short
    YYEncodingTypeUInt16     = 6, ///< unsigned short
    YYEncodingTypeInt32      = 7, ///< int
    YYEncodingTypeUInt32     = 8, ///< unsigned int
    YYEncodingTypeInt64      = 9, ///< long long
    YYEncodingTypeUInt64     = 10, ///< unsigned long long
    YYEncodingTypeFloat      = 11, ///< float
    YYEncodingTypeDouble     = 12, ///< double
    YYEncodingTypeLongDouble = 13, ///< long double
    YYEncodingTypeObject     = 14, ///< id
    YYEncodingTypeClass      = 15, ///< Class
    YYEncodingTypeSEL        = 16, ///< SEL
    YYEncodingTypeBlock      = 17, ///< block
    YYEncodingTypePointer    = 18, ///< void*
    YYEncodingTypeStruct     = 19, ///< struct
    YYEncodingTypeUnion      = 20, ///< union
    YYEncodingTypeCString    = 21, ///< char*
    YYEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    YYEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    YYEncodingTypeQualifierConst  = 1 << 8,  ///< const
    YYEncodingTypeQualifierIn     = 1 << 9,  ///< in
    YYEncodingTypeQualifierInout  = 1 << 10, ///< inout
    YYEncodingTypeQualifierOut    = 1 << 11, ///< out
    YYEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    YYEncodingTypeQualifierByref  = 1 << 13, ///< byref
    YYEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    YYEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    YYEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    YYEncodingTypePropertyCopy         = 1 << 17, ///< copy
    YYEncodingTypePropertyRetain       = 1 << 18, ///< retain
    YYEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    YYEncodingTypePropertyWeak         = 1 << 20, ///< weak
    YYEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    YYEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    YYEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};
/// Foundation Class Type
typedef NS_ENUM (NSUInteger, YYEncodingNSType) {
    YYEncodingTypeNSUnknown = 0,
    YYEncodingTypeNSString,
    YYEncodingTypeNSMutableString,
    YYEncodingTypeNSValue,
    YYEncodingTypeNSNumber,
    YYEncodingTypeNSDecimalNumber,
    YYEncodingTypeNSData,
    YYEncodingTypeNSMutableData,
    YYEncodingTypeNSDate,
    YYEncodingTypeNSURL,
    YYEncodingTypeNSArray,
    YYEncodingTypeNSMutableArray,
    YYEncodingTypeNSDictionary,
    YYEncodingTypeNSMutableDictionary,
    YYEncodingTypeNSSet,
    YYEncodingTypeNSMutableSet,
};

/// Get the Foundation class type from property info.
static force_inline YYEncodingNSType YYClassGetNSType(Class cls) {
    if (!cls) return YYEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return YYEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return YYEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return YYEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return YYEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return YYEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return YYEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return YYEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return YYEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return YYEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return YYEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return YYEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return YYEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return YYEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return YYEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return YYEncodingTypeNSSet;
    return YYEncodingTypeNSUnknown;
}

/// Whether the type is c number.
static force_inline BOOL YYEncodingTypeIsCNumber(YYEncodingType type) {
    switch (type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
        case YYEncodingTypeInt8:
        case YYEncodingTypeUInt8:
        case YYEncodingTypeInt16:
        case YYEncodingTypeUInt16:
        case YYEncodingTypeInt32:
        case YYEncodingTypeUInt32:
        case YYEncodingTypeInt64:
        case YYEncodingTypeUInt64:
        case YYEncodingTypeFloat:
        case YYEncodingTypeDouble:
        case YYEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}


@interface JJClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;   ///属性结构体
@property (nonatomic, strong, readonly) NSString *name;             ///属性名
@property (nonatomic, assign, readonly) YYEncodingType type;        ///属性类型
@property (nonatomic, strong, readonly) NSString *typeEncoding;     ///属性编码值
@property (nonatomic, strong, readonly) NSString *ivarName;         ///属性ivar名
@property (nullable, nonatomic, assign, readonly) Class cls;        ///可能为nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///可能为nil
@property (nonatomic, assign, readonly) SEL getter;                 ///getter
@property (nonatomic, assign, readonly) SEL setter;                 ///setter


@end


@interface _YYModelPropertyMeta : NSObject {
    @package
    NSString *_name;             //属性名
    YYEncodingNSType _nstype;   //属性类型
    YYEncodingType _type;       //属性函数类型
    BOOL _isCNumber;            //是否CNumebr类型
    Class _cls;                 //属性的类或者为nil
    Class _genericCls;          //通用类
    SEL _getter;                //getter方法，如果对象不能响应则为nil
    SEL _setter;                //setter方法, 如果对象不能响应则为nil
    BOOL _isKVCCompatible;      //如果为YES,则能接受KVC编码
    BOOL _isStructAvailableForKeyedArchiver; /**<如果为YES，则能压缩与解压*/
    BOOL _hasCustomClassFromDictionary; // cls/generic class 实现 +modelCustomClassForDictionary:
    /*
     property->key:       _mappedToKey:key     _mappedToKeyPath:nil            _mappedToKeyArray:nil
     property->keyPath:   _mappedToKey:keyPath _mappedToKeyPath:keyPath(array) _mappedToKeyArray:nil
     property->keys:      _mappedToKey:keys[0] _mappedToKeyPath:nil/keyPath    _mappedToKeyArray:keys(array)
     */
    NSString *_mappedToKey;      ///< the key mapped to
    NSArray *_mappedToKeyPath;   ///< the key path mapped to (nil if the name is not key path)
    NSArray *_mappedToKeyArray;  ///< the key(NSString) or keyPath(NSArray) array (nil if not mapped to multiple keys)
    YYClassPropertyInfo *_info;  ///< property's info
    _YYModelPropertyMeta *_next; ///< next meta if there are multiple properties mapped to the same key.
}

@end
@implementation _YYModelPropertyMeta
+ (instancetype)metaWithClassInfo:(YYClassInfo *)classInfo propertyInfo:(YYClassPropertyInfo *)propertyInfo generic:(Class)generic
{
    if (!generic && propertyInfo.protocols) {
        for (NSString *protocol in propertyInfo.protocols) {
            Class cls = objc_getClass(protocol.UTF8String);
            if (cls) {
                generic = cls;
                break;
            }
        }
    }
    _YYModelPropertyMeta *meta = [self new];
    meta->_name = propertyInfo.name;
    meta->_type = propertyInfo.type;
    meta->_info = propertyInfo;
    meta->_genericCls = generic;
    
    if ((meta->_type & YYEncodingTypeMask) == YYEncodingTypeObject) {
        meta->_nstype = YYClassGetNSType(propertyInfo.cls);
    }else{
        meta->_isCNumber = YYEncodingTypeIsCNumber(meta->_type);
    }
    if ((meta->_type & YYEncodingTypeMask) == YYEncodingTypeStruct) {
        //NSKeyedUnarchiver 不能解压除了以下的结构体之外的NSValue
        static NSSet *types = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *set = [NSMutableSet new];
            //32bit
            [set addObject:@"{CGSize=ff}"];
            [set addObject:@"{CGPoint=ff}"];
            [set addObject:@"{CGRect={CGPoint=ff}{CGSize=ff}}"];
            [set addObject:@"{CGAffineTransform=ffffff}"];
            [set addObject:@"{UIEdgeInsets=ffff}"];
            [set addObject:@"{UIOffset=ff}"];
            //64bit
            [set addObject:@"{CGSize=dd}"];
            [set addObject:@"{CGPoint=dd}"];
            [set addObject:@"{CGRect={CGPoint=dd}{CGSize=dd}}"];
            [set addObject:@"{CGAffineTransform=dddddd}"];
            [set addObject:@"{UIEdgeInsets=dddd}"];
            [set addObject:@"{UIOffset=dd}"];
            types = set;
        });
        if ([types containsObject:propertyInfo.typeEncoding]) {
            meta->_isStructAvailableForKeyedArchiver= YES;
        }
    }
    meta->_cls = propertyInfo.cls;
    
    if (generic) {
        meta->_hasCustomClassFromDictionary = [generic respondToSelector:@selector(modelCustomClassForDictionary:)];
    }else if (meta->_cls && meta->_nstype == YYEncodingTypeNSUnknown){
        meta->_hasCustomClassFromDictionary = [meta->_cls respondToSelector:@selector(modelCustomClassForDictionary:)];
    }
    
//    if (propertyInfo.getter) {
//        ]) {
//            <#statements#>
//        }
//    }
    
}

@end


@interface _YYModelMeta : NSObject{
    @package
    YYClassInfo *_classInfo;
    //遍历字典，值为_JJModelPropertyMeta
    NSDictionary *_mapper;
    //对象的所有元属性
    NSArray *_allPropertyMetas;
    //对象的属性对应的键路径
    NSArray *_keyPathPropertyMetas;
    //对象属性值对应的键
    NSArray *_multiKeysPropertyMetas;
    //_mapper.count
    NSUInteger _keyMapperCount;
    //对象类型
    YYEncodingNSType _nsType;
    
    BOOL _hasCustomWillTransformFromDictionary;
    BOOL _hasCustomTransformFromDictionary;
    BOOL _hasCustomTransformToDictionary;
    BOOL _hasCustomClassFromDictionary;
}

@end

@implementation _YYModelMeta

- (instancetype)initWithClass:(Class)cls
{
    return self;
}


#pragma mark - 转换方法
/// Parse a number value from 'id'.
static force_inline NSNumber *YYNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static force_inline NSDate *JJNSDateFromString(__unsafe_unretained NSString *string){
    typedef NSDate * (^JJNSDateParseBlock)(NSString *string);
    #define kParseNum 34
    static JJNSDateParseBlock blocks[kParseNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
        /**
            google time
         */
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd";
        blocks[10] = ^(NSString *string){
            return [formatter dateFromString:string];
        };
        }
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    
    if (!string) return nil;
    if (string.length > kParseNum) return nil;
    JJNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
    #undef kParserNum
}

//获取 'NSBlock' class
static force_inline Class YYNSBlockClass()
{
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

//从字典根据键路径获取值
//字典必须为NSDictionary，keyPath不为nill
static force_inline id YYValueForKeyPath(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *keyPaths){
    id value = nil;
    for (NSUInteger i = 0, max = keyPaths.count; i < max; i++) {
        value = dic[keyPaths[i]];
        if (i + 1 < max) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                dic = value;
            }else{
                return nil;
            }
        }
    }
    return value;
}


//从字典根据键（键路径）获取值
//字典需为NSDictionary
static force_inline id YYValueForMultiKeys(__unsafe_unretained NSDictionary *dic, __unsafe_unretained NSArray *multikeys){
    id value = nil;
    for (NSString *key in multikeys) {
        if ([key isKindOfClass:[NSString class]]) {
            value = dic[key];
            if (value) break;
        }else{
            value = YYValueForKeyPath(dic, (NSArray *)key);
            if (value) break;
        }
    }
    return value;
}

static force_inline void ModelSetNumberToProperty(__unsafe_unretained id model,
                                                  __unsafe_unretained NSNumber *num,
                                                  __unsafe_unretained _YYModelPropertyMeta *meta){
    switch (meta->_type & YYEncodingTypeMask) {
        case YYEncodingTypeBool:
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, meta->_setter,num.boolValue);
            break;
        case YYEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, meta->_setter, (int8_t)num.charValue);
        } break;
        case YYEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint8_t)num.unsignedCharValue);
        } break;
        case YYEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, meta->_setter, (int16_t)num.shortValue);
        } break;
        case YYEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint16_t)num.unsignedShortValue);
        } break;
        case YYEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, meta->_setter, (int32_t)num.intValue);
        }
        case YYEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint32_t)num.unsignedIntValue);
        } break;
        case YYEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.longLongValue);
            }
        } break;
        case YYEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, meta->_setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, meta->_setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case YYEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, meta->_setter, f);
        } break;
        case YYEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, meta->_setter, d);
        } break;
        case YYEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, meta->_setter, (long double)d);
        } // break; commented for code coverage in next line
        default: break;
    }
}




//返回缓存的对象元类
+ (instancetype)metaWithClass:(Class)cls
{
    if(!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    _JJModelMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!meta || meta->_classInfo.needUpdate) {
        meta = [[_JJModelMeta alloc]initWithClass:cls];
        if (meta) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}

@end


typedef struct {
    void *modelMeta; ///_JJModelMeta
    void *model; ///id (self)
    void *dictionary; /// NSDictionary (json)
} ModelSetContext;

static void ModelSetValueForProperty(__unsafe_unretained id model,
                                     __unsafe_unretained id value,
                                     __unsafe_unretained _JJModelPropertyMeta *meta){
    if (meta->_isCNumber) {
        NSNumber *num = YYNSNumberCreateFromID(value);
        ModelSetNumberToProperty(model, num, meta);
        if (num) [num class]; //保存变量
    }else if (meta->_nstype){
        if (value == (id)kCFNull) {
            msgSend((id)nil);
        }else{
            switch (meta->_nstype) {
                case YYEncodingTypeNSString:
                case YYEncodingTypeNSMutableString:
                    if ([value isKindOfClass:[NSString class]]) {
                        if (meta->_nstype == YYEncodingTypeNSString) {
                            msgSend(value);
                        }else{
                            msgSend(((NSString *)value).mutableCopy);
                        }
                    }else if ([value isKindOfClass:[NSNumber class]]){
                        msgSend((meta->_nstype == YYEncodingTypeNSString)?((NSNumber *)value).stringValue:((NSNumber *)value).stringValue.mutableCopy);
                    }else if ([value isKindOfClass:[NSData class]]){
                        NSMutableString *string = [[NSMutableString alloc]initWithData:value encoding:NSUTF8StringEncoding];
                        msgSend(string);
                    }else if ([value isKindOfClass:[NSURL class]]){
                        msgSend((meta->_nstype == YYEncodingTypeNSString) ?
                                ((NSURL *)value).absoluteString :
                                ((NSURL *)value).absoluteString.mutableCopy);
                    }else if ([value isKindOfClass:[NSAttributedString class]]){
                        msgSend((meta->_nstype == YYEncodingTypeNSString)?((NSMutableAttributedString *)value).string:((NSAttributedString *)value).string.mutableCopy);
                    }
                    break;
                case YYEncodingTypeNSValue:
                case YYEncodingTypeNSNumber:
                case YYEncodingTypeNSDecimalNumber:
                    if (meta->_nstype == YYEncodingTypeNSNumber) {
                        msgSend(YYNSNumberCreateFromID(value));
                    }else if (meta->_nstype == YYEncodingTypeNSDecimalNumber){
                        if ([value isKindOfClass:[NSDecimalNumber class]]) {
                            msgSend(value);
                        }else if ([value isKindOfClass:[NSNumber class]]){
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)value decimalValue]];
                            msgSend(decNum);
                        }else if ([value isKindOfClass:[NSString class]]){
                            NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                            NSDecimal dec = decNum.decimalValue;
                            if (dec._length == 0 && dec._isNegative) {
                                decNum = nil;
                            }
                            msgSend(decNum);
                        }
                    }else{ //JJEncodingTypeNSValue
                        if ([value isKindOfClass:[NSValue class]]) {
                            msgSend(value);
                        }
                    }
                    break;
                    
                case YYEncodingTypeNSData:
                case YYEncodingTypeNSMutableData:
                {
                    if ([value isKindOfClass:[NSData class]]) {
                        if (meta->_nstype == YYEncodingTypeNSData) {
                            msgSend(value)
                        }else{
                            NSMutableData *data = ((NSData *)value).mutableCopy;
                            msgSend(data);
                        }
                    }else if ([value isKindOfClass:[NSString class]]){
                        NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                        if (meta->_nstype == YYEncodingTypeNSMutableData) {
                            data = ((NSData *)data).mutableCopy;
                        }
                        msgSend(data);
                    }
                }
                    break;
                case YYEncodingTypeNSDate:
                    if ([value isKindOfClass:[NSDate class]]) {
                        msgSend(value);
                    }else if ([value isKindOfClass:[NSString class]]){
                        msgSend(JJNSDateFromString(value));
                    }
                    break;
                case YYEncodingTypeNSURL:
                {
                    if ([value isKindOfClass:[NSURL class]]) {
                        msgSend(value);
                    }else if ([value isKindOfClass:[NSString class]]){
                        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                        NSString *str = [value stringByTrimmingCharactersInSet:set];
                        if (str.length == 0) {
                            msgSend(nil);
                        }else{
                            msgSend([[NSURL alloc]initWithString:str]);
                        }
                    }
                }
                    break;
                case YYEncodingTypeNSArray:
                case YYEncodingTypeNSMutableArray:
                    if (meta->_genericCls) {
                        NSArray *valueArr = nil;
                        if ([value isKindOfClass:[NSArray class]]) {
                            valueArr = value;
                        }else if ([value isKindOfClass:[NSSet class]]){
                            valueArr = ((NSSet *)value).allObjects;
                        }
                        if (valueArr) {
                            NSMutableArray *objectArr = [NSMutableArray new];
                            for (id one in valueArr) {
                                if ([one isKindOfClass:meta->_genericCls]) {
                                    [objectArr addObject:one];
                                }else if ([one isKindOfClass:[NSDictionary class]]){
                                    Class cls = meta->_genericCls;
                                    if (meta->_hasCustomClassFromDictionary) {
                                        cls = [cls modelCustomClassForDictionary:one];
                                        if (!cls) cls = meta->_genericCls;
                                    }
                                    NSObject *newOne = [cls new];
                                    [newOne modelSetWithDictionary:one];
                                    if (newOne) [objectArr addObject:newOne];
                                }
                            }
                        }
                        msgSend(valueArr);
                    }else{
                        if ([value isKindOfClass:[NSArray class]]) {
                            if (meta->_nstype == YYEncodingTypeNSArray) {
                                msgSend(value)
                            }else{
                                msgSend(((NSArray *)value).mutableCopy);
                            }
                        }else if ([value isKindOfClass:[NSSet class]]){
                            if (meta->_nstype == YYEncodingTypeNSArray) {
                                msgSend(((NSSet *)value).allObjects);
                            }else{
                                msgSend(((NSSet *)value).allObjects.mutableCopy);
                            }
                        }
                    }
                    break;
                case YYEncodingTypeNSDictionary:
                case YYEncodingTypeNSMutableDictionary:
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        if (meta->_genericCls) {
                            NSMutableDictionary *dic = [NSMutableDictionary new];
                            [((NSDictionary *)value) enumerateKeysAndObjectsUsingBlock:^(NSString *oneKey, id oneValue, BOOL *stop) {
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    cls = [cls modelCustomClassForDictionary:oneValue];
                                    if (!cls) cls = meta->_genericCls;
                                }
                                NSObject *newOne = [cls new];
                                [newOne modelSetWithDictionary:(id)oneValue];
                                if (newOne) dic[oneKey] = newOne;
                            }];
                            msgSend(dic);
                        }
                    }else{
                        if (meta->_nstype == YYEncodingTypeNSDictionary) {
                            msgSend(value);
                        }else{
                            msgSend(((NSDictionary *)value).mutableCopy);
                        }
                    }
                    break;
                case YYEncodingTypeNSSet:
                case YYEncodingTypeNSMutableSet:{
                    NSSet *valueSet = nil;
                    if ([value isKindOfClass:[NSArray class]]) {
                        valueSet = [NSMutableSet setWithArray:value];
                    }else if ([value isKindOfClass:[NSSet class]]){
                        valueSet = ((NSSet *)value);
                    }
                    if (meta->_genericCls) {
                        NSMutableSet *set = [NSMutableSet new];
                        for (id one in valueSet) {
                            if ([one isKindOfClass:meta->_genericCls]) {
                                [set addObject:one];
                            }else if ([one isKindOfClass:[NSDictionary class]]){
                                Class cls = meta->_genericCls;
                                if (meta->_hasCustomClassFromDictionary) {
                                    cls = [cls modelCustomClassForDictionary:one];
                                }
                                NSObject *newOne = [cls new];
                                [newOne modelSetWithDictionary:one];
                                if (newOne) [set addObject:newOne];
                            }
                        }
                        msgSend(set);
                    }else{
                        if (meta->_nstype == YYEncodingTypeNSSet) {
                            msgSend(valueSet);
                        }else{
                            msgSend(((NSSet *)valueSet).mutableCopy);
                        }
                    }
                    
                }
                default:
                    break;
            }
        }
    }else{
        BOOL isNull = (value == (id)kCFNull);
        switch (meta->_type & YYEncodingTypeMask) {
            case YYEncodingTypeObject:
            {
                if (isNull) {
                    msgSend((id)nil);
                }else if ([value isKindOfClass:meta->_cls] || !meta->_cls){
                    msgSend(value)
                }else if ([value isKindOfClass:[NSDictionary class]]){
                    NSObject *one = nil;
                    if (meta->_getter) {
                        one = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model, meta->_getter);
                    }
                    if (one) {
                        [one modelSetWithDictionary:value];
                    }else{
                        Class cls = meta->_cls;
                        if (meta-> _hasCustomClassFromDictionary) {
                            cls = [cls modelCustomClassForDictionary:value];
                            if (!cls) cls = meta->_genericCls;
                        }
                        one = [cls new];
                        [one modelSetWithDictionary:value];
                        msgSend((id)one);
                    }
                }
            }
                break;
            case YYEncodingTypeClass:
                if (isNull) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,meta->_setter,(Class)NULL);
                }else{
                    Class cls = nil;
                    if ([value isKindOfClass:[NSString class]]) {
                        cls = NSClassFromString(value);
                        if (cls) {
                               ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,meta->_setter,(Class)cls);
                        }
                    }else{
                        cls = object_getClass(value);
                        if (cls) {
                            if (class_isMetaClass(cls)) {
                                  ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,meta->_setter,(Class)value);
                                
                            }
                        }
                    }
                }
                break;
            case YYEncodingTypeSEL:
            {
                if (isNull) {
                        ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,meta->_setter,(SEL)NULL);
                }else if([value isKindOfClass:[NSString class]]){
                    SEL sel = NSSelectorFromString(value);
                    if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,meta->_setter,(SEL)sel);
                    
                }
            }
                break;
            case YYEncodingTypeBlock:
                if (isNull) {
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())NULL);
                }else if ([value isKindOfClass:YYNSBlockClass()]){
                    ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, meta->_setter, (void (^)())value);
                }
                break;
            case YYEncodingTypeStruct:
            case YYEncodingTypeUnion:
            case YYEncodingTypeCArray:
            {
                if ([value isKindOfClass:[NSValue class]]) {
                    const char *valueType = ((NSValue *)value).objCType;
                    const char *metaType = meta->_info.typeEncoding.UTF8String;
                    if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                        [model setValue:value forKey:meta->name];
                    }
                }
            }
                break;
            case YYEncodingTypePointer:
            case YYEncodingTypeCString:
            {
                if (isNull) {
                    ((void (*)(id, SEL, void *))(void *)objc_msgSend)((id)model, meta->_setter, (void *)NULL);
                }else if ([value isKindOfClass:[NSValue class]]){
                    NSValue *nsValue = value;
                    if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                        ((void (*)(id, SEL, void *))(void *)objc_msgSend)((id)model, meta->_setter, nsValue.pointerValue);
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}



/**
 设置key-value到model
 */
static void ModelSetWithDictionaryFunction(const void *_key, const void *_value, void *_context){
    ModelSetContext *context = _context;
    __unsafe_unretained _JJModelMeta *meta = (__bridge _JJModelMeta *)(context->modelMeta);
    __unsafe_unretained _JJModelPropertyMeta *propertyMeta = [meta->_mapper objectForKey:(__bridge id)(_key)];
    __unsafe_unretained id model = (__bridge id)(context->model);
    while (propertyMeta) {
        if (propertyMeta->_setter) {
            ModelSetValueForProperty(model, (__bridge __unsafe_unretained id)_value, propertyMeta);
        }
        propertyMeta = propertyMeta->_next;
    }
}

/**
 设置字典到model
 */
static void ModelSetWithPropertyMetaArrayFunction(const void *_propertyMeta, void *_context){
    ModelSetContext *context = _context;
    __unsafe_unretained NSDictionary *dictionary = (__bridge NSDictionary *)(context->dictionary);
    __unsafe_unretained _JJModelPropertyMeta *propertyMeta = (__bridge _JJModelPropertyMeta *)(_propertyMeta);
    if (!propertyMeta->_setter) return;
    id value = nil;
    
    if (propertyMeta->_mappedToKeyArray) {
        value = YYValueForMultiKeys(dictionary, propertyMeta->_mappedToKeyArray);
    }else if (propertyMeta->_mappedToKeyPath){
        value = YYValueForKeyPath(dictionary, propertyMeta->_mappedToKeyPath);
    }else{
        value = [dictionary objectForKey:propertyMeta->_mappedToKey];
    }
    
    if (value) {
        __unsafe_unretained id model = (__bridge id)(context->model);
        ModelSetValueForProperty(model, value, propertyMeta);
    }
}




@implementation NSObject (JJModel)

+ (NSDictionary *)_jj_dictionaryWithJSON:(id)json
{
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    }else if ([json isKindOfClass:[NSString class]]){
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([json isKindOfClass:[NSData class]]){
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
    }
    return dic;
}

+ (instancetype)modelWithJSON:(id)json
{
    NSDictionary *dic = [self _jj_dictionaryWithJSON:json];
    return [self modelWithDictionary:dic];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    
    Class cls = [self class];
    //获取元类对象
    _JJModelMeta *modelMeta = [_JJModelMeta metaWithClass:cls];
    if (modelMeta->_hasCustomClassFromDictionary) {
        cls = [cls modelCustomClassForDictionary:dictionary]?:cls;
    }
    
    NSObject *one = [cls new];
    if ([one modelSetWithDictionary:dictionary]) return one;
    return nil;
    
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic
{
    if (!dic || dic == (id)kCFNull) return NO;
    if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    
    _JJModelMeta *modelMeta = [_JJModelMeta metaWithClass:object_getClass(self)];
    if (modelMeta->_keyMapperCount == 0) return NO;
    
    if (modelMeta-> _hasCustomWillTransformFromDictionary) {
        dic = [((id<JJModel>)self) modelCustomWillTransformFromDictionary:dic];
        if (![dic isKindOfClass:[NSDictionary class]]) return NO;
    }
    
    ModelSetContext context = {0};
    context.modelMeta = (__bridge void *)(modelMeta);
    context.model = (__bridge void *)(self);
    context.dictionary = (__bridge void *)(dic);
    
    if (modelMeta ->_keyMapperCount >= CFDictionaryGetCount((CFDictionaryRef)dic)){
        CFDictionaryApplyFunction((CFDictionaryRef)dic, ModelSetWithDictionaryFunction, &context);
        if (modelMeta ->_keyPathPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_keyPathPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_keyPathPropertyMetas)),ModelSetWithPropertyMetaArrayFunction, &context);
        }
        if (modelMeta ->_multiKeysPropertyMetas) {
            CFArrayApplyFunction((CFArrayRef)modelMeta->_multiKeysPropertyMetas, CFRangeMake(0, CFArrayGetCount((CFArrayRef)modelMeta->_multiKeysPropertyMetas)), ModelSetWithPropertyMetaArrayFunction, &context);
        }
        
    }else{
        CFArrayApplyFunction((CFArrayRef)modelMeta->_allPropertyMetas, CFRangeMake(0, modelMeta->_keyMapperCount), ModelSetWithPropertyMetaArrayFunction, &context);
    }
    
    if (modelMeta->_hasCustomTransformToDictionary) {
          return [((id<JJModel>)self) modelCustomTransformFromDictionary:dic];
    }
    
    return YES;
}



@end
