//
//  TYPEID_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_Button_IView.h"
#import "do_Button_UIModel.h"
#import "doIUIModuleView.h"

@interface do_Button_UIView : UIButton<do_Button_IView,doIUIModuleView>
//可根据具体实现替换UIView
{
    @private
    __weak do_Button_UIModel *model;
}

@end
