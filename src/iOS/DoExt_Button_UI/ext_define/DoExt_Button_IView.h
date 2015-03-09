//
//  TYPEID_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "doJsonNode.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"

@protocol DoExt_Button_IView <NSObject>

@required
- (void)change_text:(NSString *)newValue;
- (void)change_fontColor:(NSString *)newValue;
- (void)change_fontSize:(NSString *)newValue;
- (void)change_fontStyle:(NSString *)newValue;
- (void)change_radius:(NSString *)newValue;
- (void)change_bgImage:(NSString *)newValue;

- (BOOL)InvokeSyncMethod:(NSString *)_methodName :(doJsonNode *)_dictParas :(id<doIScriptEngine>) _scriptEngine :(doInvokeResult *)_invokeResult;

- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (doJsonNode *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName;

@end
