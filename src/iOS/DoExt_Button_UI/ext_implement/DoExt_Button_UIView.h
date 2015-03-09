//
//  TYPEID_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoExt_Button_IView.h"
#import "DoExt_Button_UIModel.h"
#import "doIUIModuleView.h"

@interface DoExt_Button_UIView : UIButton<DoExt_Button_IView,doIUIModuleView>
//可根据具体实现替换UIView
{
    @private
    __weak DoExt_Button_UIModel *model;
}

@end
