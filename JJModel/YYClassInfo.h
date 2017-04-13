//
//  JJClassInfo.h
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

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

YYEncodingType YYEncodingGetType(const char *typeEncoding);

@interface YYClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;/**<ivar 结构体*/
@property (nonatomic, strong, readonly) NSString *name; /**<ivar 名字*/
@property (nonatomic, assign, readonly) ptrdiff_t offset; /**<ivar 偏移量*/
@property (nonatomic, strong, readonly) NSString *typeEncoding; /**<type 编码*/
@property (nonatomic, assign, readonly) YYEncodingType type; /**<ivar type*/

/**<创建并返回一个ivar
    @param ivar ivar结构体
    @return A new object,出现错误则返回nil
 */
- (instancetype)initWithIvar:(Ivar)ivar;

@end


@interface YYClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; /**<成员变量结构体*/
@property (nonatomic, strong, readonly) NSString *name;/**<类属性名*/
@property (nonatomic, assign, readonly) YYEncodingType type;/**<类属性*/
@property (nonatomic, strong, readonly) NSString *typeEncoding;/**<编码值*/
@property (nonatomic, strong, readonly) NSString *ivarName;/**<ivarName*/
@property (nullable, nonatomic, assign, readonly) Class cls; /**<可能为nil*/
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *>protocols;/**<可能为nil*/
@property (nonatomic, assign, readonly) SEL getter;//nonnull;
@property (nonatomic, assign, readonly) SEL setter;//nonnull;

@end

@interface YYClassInfo : NSObject


/**<如果类被改变（例如添加了一个方法）你需要调用这个方法来更新类信息的缓存，调用之后，‘needUpdate’将会返回YES，然后你需要调用‘classInfoWithClass’或者‘classInfoWithClassName’来获取更新后的类信息*/
- (BOOL)setNeedUpdate;

/**<如果返回的是YES，你需要调用‘classInfoWithClass’或者‘classInfoWithClassName’来获取更新后的类信息
    @return 类是否需要更新
 */
- (BOOL)needUpdate;

@end
