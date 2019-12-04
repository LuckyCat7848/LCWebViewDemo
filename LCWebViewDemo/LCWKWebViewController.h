//
//  LCWKWebViewController.h
//  LCWebViewDemo
//
//  Created by 张猫猫 on 2019/11/29.
//  Copyright © 2019 ehi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 消除使用performSelector时的警告 */
#define kSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface LCWKWebViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
