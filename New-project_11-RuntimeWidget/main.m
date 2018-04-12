//
//  main.m
//  New-project_11-RuntimeWidget
//
//  Created by Geraint on 2018/4/11.
//  Copyright © 2018年 kilolumen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <objc/runtime.h> // 运行时系统
#import <objc/message.h> // 运行时系统中的  消息传递API

/*
 runtime(运行时系统)，是一套基于C语言API,包含在 <objc/runtime.h>和<objc/message.h>中，运行时系统的功能是在运行期间(而不是编译期或其他时机)通过代码去动态的操作类(获取类的内部信息和动态操作类的成员),如创建一个新类、为某个类添加一个新的方法或者为某个类添加实例变量、属性，或者交换两个方法的实现、获取类的属性列表、方法列表等
 */


/*
 示例4：动态创建类并添加方法
 
 1、使用运行时系统API以动态方式创建类的步骤：
 2、定义了一个方法的实例参数
 3、创建并注册了一个类
 4、创建了一个类实例
 5、以动态方式向该实例添加了一个变量

*/

// 定义了一个函数，使用该函数可以向类中添加方法：
//  用于显示选择器的方法实现函数
static void display(id self,SEL _cmd) {
    NSLog(@"Invoking method with selector %@ on %@ instance",
          NSStringFromSelector(_cmd),[self class]);
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        // 创建一个类对
        Class WidgetClass = objc_allocateClassPair([NSObject class], "Widget", 0);
        
        // 向这个类添加一个方法
        const char *types = "v@:";
        class_addMethod(WidgetClass, @selector(display), (IMP)display, types);
        
        // 向这个类添加一个实例变量
        const char *height = "height";
        class_addIvar(WidgetClass, height, sizeof(id), rint(log2(sizeof(id))), @encode(id));
        
        // 注册这个类
        objc_registerClassPair(WidgetClass);
        
        // 创建一个Widget实例，并设置实例变量的值
        id widget = [[WidgetClass alloc] init];
        id value = [NSNumber numberWithInt:15];
        [widget setValue:value forKey:[NSString stringWithUTF8String:height]];
        NSLog(@"Widget instance height = %@",[widget valueForKey:[NSString stringWithUTF8String:height]]);
        
        // 向widget实例发送一条消息
        /*[iOS] objc_msgSend报错解决：
            第一种解决方案： 注意：在目前版本的Xcode中，需要将 Apple LLVM X.X（版本号） - Preprocessing 中的 Enable Strict Checking of objc_msgSend Calls 设置为No，不然编译会失败。
         
          报错：  objc_msgSend(widget, NSSelectorFromString(@"display"));
         第二种解决方案：(把上面的一行代码改成下面这一行)
        ((void (*) (id, SEL)) (void *)objc_msgSend)(widget,NSSelectorFromString(@"display"));
         */
        
        //objc_msgSend(widget, NSSelectorFromString(@"display"));
        ((void (*) (id, SEL)) (void *)objc_msgSend)(widget,NSSelectorFromString(@"display"));
        
        
        // 以动态方式向widget实例添加一个变量 (关联对象)
        NSNumber *width = [NSNumber numberWithInt:10];
        objc_setAssociatedObject(widget, @"width", width, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // 获取该变量的值并显示它
        id result = objc_getAssociatedObject(widget, @"width");
        NSLog(@"Widget instance width = %@",result);
        
        
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
