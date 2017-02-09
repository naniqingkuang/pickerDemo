//
//  ViewController.m
//  pickerDemo
//
//  Created by 猪猪 on 2017/2/7.
//  Copyright © 2017年 猪猪. All rights reserved.
//

#import "ViewController.h"
#import "NXPhotoPickerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NXPhotoPickerViewController * pickerVC = [NXPhotoPickerViewController getNXPhotoPickerVC];
    pickerVC.maxSelectedNum = 9;
    pickerVC.minSelectedNum = 0;
    pickerVC.showOrder = NXPhotoPickerShowOrderDesc;
    pickerVC.aseetDelegate = self;
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:pickerVC];
    [self showViewController:pickerVC sender:nil];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
