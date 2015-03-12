//
//  TYPEID_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "DoExt_Button_UIView.h"

#import "doInvokeResult.h"
#import "doIPage.h"
#import "doIScriptEngine.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doTextHelper.h"
#import "doUIContainer.h"
#import "doISourceFS.h"
#import "doIPage.h"
#import "doDefines.h"
#import "doIOHelper.h"

@implementation DoExt_Button_UIView
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    model = (typeof(model)) _doUIModule;
    
    [self addTarget:self action:@selector(fingerTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(fingerDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(fingerUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(fingerUp:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
//销毁所有的全局对象
- (void) OnDispose
{
    model = nil;
    //自定义的全局属性
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:model];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_text:(NSString *)newValue{
    [self setTitle:newValue forState:UIControlStateNormal];
}
- (void)change_fontColor:(NSString *)newValue{
    [self setTitleColor:[doUIModuleHelper GetColorFromString:newValue :[UIColor blackColor]] forState:UIControlStateNormal];
}
- (void)change_fontSize:(NSString *)newValue{
    UIFont * font = self.titleLabel.font;
    if (font == nil) {
        font = [UIFont systemFontOfSize:[[model GetProperty:@"fontSize"].DefaultValue intValue]];
    }
    int _intFontSize = [doUIModuleHelper GetDeviceFontSize:[[doTextHelper Instance] StrToInt:newValue :[[model GetProperty:@"fontSize"].DefaultValue intValue]] :model.XZoom :model.YZoom];
    self.titleLabel.font = [font fontWithSize:_intFontSize];//z012
}
- (void)change_fontStyle:(NSString *)newValue{
    
    NSRange range = {0,[self.titleLabel.text length]};
    NSMutableAttributedString *str = [self.titleLabel.attributedText mutableCopy];
    [str removeAttribute:NSUnderlineStyleAttributeName range:range];
    self.titleLabel.attributedText = str;
    
    float fontSize = self.titleLabel.font.pointSize;//The receiver’s point size, or the effective vertical point size for a font with a nonstandard matrix. (read-only)
    
    if([newValue isEqualToString:@"normal"]){
        self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    }else if([newValue isEqualToString:@"bold"]){
        self.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    }else if([newValue isEqualToString:@"italic"]){
        self.titleLabel.font = [UIFont italicSystemFontOfSize:fontSize];
    }else if([newValue isEqualToString:@"underline"]){
        if (self.titleLabel.text == nil) {
            return;
        }
        
        NSMutableAttributedString * content = [[NSMutableAttributedString alloc]initWithString:self.titleLabel.text];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        self.titleLabel.attributedText = content;
    }
}
- (void)change_radius:(NSString *)newValue{
    
    self.layer.cornerRadius = [[doTextHelper Instance] StrToInt:newValue :0] * model.CurrentUIContainer.InnerXZoom;
    self.layer.masksToBounds = YES;
    
}
- (void)change_bgImage:(NSString *)newValue{
    
    NSString * imgPath = [doIOHelper GetLocalFileFullPath:model.CurrentPage.CurrentApp :newValue];
    UIImage * img = [UIImage imageWithContentsOfFile:imgPath];
    [self setBackgroundImage:img forState:UIControlStateNormal];
}

#pragma mark - event
-(void)fingerTouch:(DoExt_Button_UIView *) _doButtonView
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touch":_invokeResult];
}
-(void)fingerDown:(DoExt_Button_UIView *) _doButtonView
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchdown":_invokeResult];
}

-(void)fingerUp:(DoExt_Button_UIView *) _doButtonView
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:model.UniqueKey];
    [model.EventCenter FireEvent:@"touchup":_invokeResult];
}

#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :model : _changedValues ];
}
- (BOOL)InvokeSyncMethod:(NSString *)_methodName :(doJsonNode *)_dictParas :(id<doIScriptEngine>) _scriptEngine :(doInvokeResult *)_invokeResult
{
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dictParas :_scriptEngine :_invokeResult];
}

- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (doJsonNode *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return model;
}

@end
