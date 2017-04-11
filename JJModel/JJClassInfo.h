//
//  JJClassInfo.h
//  JJModel
//
//  Created by 吴孜健 on 17/3/27.
//  Copyright © 2017年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface JJClassInfo : NSObject



/**<如果类被改变（例如添加了一个方法）你需要调用这个方法来更新类信息的缓存，调用之后，‘needUpdate’将会返回YES，然后你需要调用‘classInfoWithClass’或者‘classInfoWithClassName’来获取更新后的类信息*/
- (BOOL)setNeedUpdate;

/**<如果返回的是YES，你需要调用‘classInfoWithClass’或者‘classInfoWithClassName’来获取更新后的类信息
    @return 类是否需要更新
 */
- (BOOL)needUpdate;

@end
