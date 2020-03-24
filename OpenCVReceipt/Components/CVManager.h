//
//  CVManager.h
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>


@interface CVManager: NSObject
+ (CVManager *)shared;

-(UIImage *) stitchWithOpenCV:(NSArray *) images;
-(UIImage *) startTest:(UIImage *)pimage1 image2:(UIImage *)pimage2;

@end
