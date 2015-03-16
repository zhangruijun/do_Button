//
//  TYPEID_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Camera_SM.h"

#import "doJsonNode.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import "doIApp.h"
#import "doISourceFS.h"
#import "doIOHelper.h"
#import "doCallBackTask.h"
#import "doIPage.h"
#import "doUIModuleHelper.h"

@interface do_Camera_SM ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    int imageWidth;
    int imageHeight;
    int imageQuality;
    BOOL isCut;
}
@property (nonatomic, strong) NSString * myCallbackFuncName;
@property (nonatomic, strong) doInvokeResult * myInvokeResult;
@property (nonatomic, strong) id<doIScriptEngine> myScriptEngine;

@end

@implementation do_Camera_SM
#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
     doJsonNode *_dictParas = [parms objectAtIndex:0];
     在节点中，获取对应的参数
     NSString *title = [_dictParas GetOneText:@"title" :@"" ];
     说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
     doInvokeResult *_invokeResult = [parms objectAtIndex:2];
     回调信息
     如：（回调一个字符串信息）
     [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
     NSString *_callbackName = [parms objectAtIndex:2];
     在合适的地方进行下面的代码，完成回调
     新建一个回调对象
     doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
     填入对应的信息
     如：（回调一个字符串）
     [_invokeResult SetResultText: @"异步方法完成"];
     [_scritEngine Callback:_callbackName :_invokeResult];
 */
#pragma mark - 实现异步方法
- (void)capture:(NSArray *)params
{
    doJsonNode * _dicParas = [params objectAtIndex:0];
    self.myScriptEngine = [params objectAtIndex:1];
    self.myCallbackFuncName = [params objectAtIndex:2];
    self.myInvokeResult = [[doInvokeResult alloc]init:nil];
    //图片宽度
    imageWidth = [_dicParas GetOneInteger:@"width" :-1];
    //图片高度
    imageHeight = [_dicParas GetOneInteger:@"height" :-1];
    //清晰度1-100
    imageQuality = [_dicParas GetOneInteger:@"quality" :100];
    imageQuality = imageQuality > 100 ? 100 : imageQuality;
    imageQuality = imageQuality < 1 ? 1 : imageQuality;
    //是否启动中间裁剪界面
    isCut = [_dicParas GetOneBoolean:@"iscut" :NO];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController * pickerVC = [[UIImagePickerController alloc]init];
        pickerVC.delegate = self;
        
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        if(isCut)
        {
            pickerVC.allowsEditing = YES;
            pickerVC.showsCameraControls = YES;
        }
        pickerVC.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        pickerVC.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        
        pickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        id<doIPage> pageModel = _myScriptEngine.CurrentPage;
        UIViewController * currentVC = (UIViewController *)pageModel.PageView;
        [currentVC presentViewController:pickerVC animated:YES completion:^{
            NSLog(@"跳转成功!");
        }];
    }else{
        [[doServiceContainer Instance].LogEngine WriteError:nil:@"当前设备不支持相机功能",nil];
    }
}

#pragma mark - 私有方法，支持对外方法的实现
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage * image = nil;
    if([mediaType isEqualToString:@"public.image"] && picker.sourceType==UIImagePickerControllerSourceTypeCamera){
        NSData * imageData;
        @try {
            if(isCut)
            {
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            }
            else
            {
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            
            CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*(image.size.height/image.size.width));
            if(imageWidth>0)
                size = CGSizeMake(imageWidth, size.height);
            if(imageHeight>0)
                size = CGSizeMake(size.width, imageHeight);
            image = [doUIModuleHelper imageWithImageSimple:image scaledToSize:size];
            
            if(UIImagePNGRepresentation(image) == nil)
            {
                imageData = UIImageJPEGRepresentation(image, imageQuality / 100.0);
            }else{
                imageData = UIImagePNGRepresentation(image);
            }
            image = [UIImage imageWithData:imageData];
            
            //写入本地
            NSString * sourceFSRootPath = _myScriptEngine.CurrentApp.SourceFS.RootPath;
            NSString * fileName = [NSString stringWithFormat:@"%@.png",[doUIModuleHelper stringWithUUID]];
            NSString * filePath = [NSString stringWithFormat:@"%@/%@",sourceFSRootPath,fileName];
            
            [doIOHelper WriteAllBytes:filePath :imageData];
            [_myInvokeResult SetResultText:[NSString stringWithFormat:@"data://temp/%@",fileName]];
        }
        @catch (NSException *exception) {
            [_myInvokeResult SetException:exception];
        }
        @finally {
            [_myScriptEngine Callback:_myCallbackFuncName :_myInvokeResult];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        _myInvokeResult = nil;
        _myScriptEngine = nil;
    } ];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_myInvokeResult SetError:@"拍照取消"];
    [_myScriptEngine Callback:_myCallbackFuncName :_myInvokeResult];
    [picker dismissViewControllerAnimated:YES completion:^{
        _myInvokeResult = nil;
        _myScriptEngine = nil;
    } ];
}

@end
