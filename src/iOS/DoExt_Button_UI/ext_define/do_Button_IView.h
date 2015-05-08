//
//  TYPEID_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "doIScriptEngine.h"
#import "doInvokeResult.h"

@protocol do_Button_IView <NSObject>

@required
- (void)change_text:(NSString *)newValue;
- (void)change_fontColor:(NSString *)newValue;
- (void)change_fontSize:(NSString *)newValue;
- (void)change_fontStyle:(NSString *)newValue;
- (void)change_radius:(NSString *)newValue;
- (void)change_bgImage:(NSString *)newValue;

@end
