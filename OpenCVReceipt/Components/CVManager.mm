//
//  CVManager.m
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc.hpp>
#import "CVManager.h"

using namespace cv;
using namespace std;

static void UIImageToMat(UIImage *image, cv::Mat &mat) {
    
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    CGImageRef imageRef = image.CGImage;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, CV_RGBA2BGR);
    
    mat = mat8uc3;
}

static UIImage *MatToUIImage(cv::Mat &mat) {
    
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, CV_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, CV_BGR2RGB);
    }
    
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}


@implementation CVManager

static CVManager *_instance            = nil;

vector<Mat> imgs;
bool try_use_gpu = false;

void OptimizeSeam(Mat& img1, Mat& trans, Mat& dst);

typedef std::set<std::pair<int,int> > MatchesSet;

typedef struct
{
    Point2f left_top;
    Point2f left_bottom;
    Point2f right_top;
    Point2f right_bottom;
}four_corners_t;

four_corners_t corners;

void CalcCorners(const Mat& H, const Mat& src)
{
    double v2[] = { 0, 0, 1 };
    double v1[3];
    Mat V2 = Mat(3, 1, CV_64FC1, v2);
    Mat V1 = Mat(3, 1, CV_64FC1, v1);
    
    V1 = H * V2;

    cout << "V2: " << V2 << endl;
    cout << "V1: " << V1 << endl;
    corners.left_top.x = v1[0] / v1[2];
    corners.left_top.y = v1[1] / v1[2];
    
    v2[0] = 0;
    v2[1] = src.rows;
    v2[2] = 1;
    V2 = Mat(3, 1, CV_64FC1, v2);
    V1 = Mat(3, 1, CV_64FC1, v1);
    V1 = H * V2;
    corners.left_bottom.x = v1[0] / v1[2];
    corners.left_bottom.y = v1[1] / v1[2];
    
    v2[0] = src.cols;
    v2[1] = 0;
    v2[2] = 1;
    V2 = Mat(3, 1, CV_64FC1, v2);
    V1 = Mat(3, 1, CV_64FC1, v1);
    V1 = H * V2;
    corners.right_top.x = v1[0] / v1[2];
    corners.right_top.y = v1[1] / v1[2];
    
    v2[0] = src.cols;
    v2[1] = src.rows;
    v2[2] = 1;
    V2 = Mat(3, 1, CV_64FC1, v2);
    V1 = Mat(3, 1, CV_64FC1, v1);
    V1 = H * V2;
    corners.right_bottom.x = v1[0] / v1[2];
    corners.right_bottom.y = v1[1] / v1[2];
    
}

+ (CVManager *)shared{
    if (_instance == nil){
        _instance = [[CVManager alloc] init];
    }
    return _instance;
}

-(UIImage *) stitchWithOpenCV:(NSArray *) images{
    for (UIImage *image in images) {
        Mat cvimage;
        UIImageToMat(image,cvimage);
        imgs.push_back(cvimage);
    }
    NSLog(@"imgs count %d",imgs.size());
    
    Stitcher stitcher = Stitcher::createDefault(try_use_gpu);

    detail::OrbFeaturesFinder *featureFinder = new detail::OrbFeaturesFinder();
    stitcher.setFeaturesFinder(featureFinder);
    
    detail::BestOf2NearestMatcher *matcher = new detail::BestOf2NearestMatcher(false, 0.5f);
    stitcher.setFeaturesMatcher(matcher);
    
    stitcher.setBundleAdjuster(new detail::BundleAdjusterRay());
    
    SphericalWarper*  cw = new SphericalWarper();
    stitcher.setWarper(cw);
    
    Mat pano;

    Stitcher::Status status = stitcher.estimateTransform(imgs);
    if (status != Stitcher::OK){
        cout << "Can't stitch images, error code = " << int(status) << endl;
         return nil;
    }
    status = stitcher.composePanorama(pano);
    if (status != Stitcher::OK){
            cout << "Can't stitch images, error code = " << int(status) << endl;
            return nil;
     }
    
    return MatToUIImage(pano);
}

-(UIImage *) startTest:(UIImage *)pimage1 image2:(UIImage *)pimage2{
    
    Mat image01,image02,output;
    UIImageToMat(pimage1, image01);
    UIImageToMat(pimage2, image02);

    Mat image1, image2;
    cvtColor(image01, image1, CV_RGB2GRAY);
    cvtColor(image02, image2, CV_RGB2GRAY);
    
    Ptr<FeatureDetector> detector = ORB::create(3000);
    vector<KeyPoint> keyPoint1, keyPoint2;
    detector->detect(image1, keyPoint1);
    detector->detect(image2, keyPoint2);

    DescriptorExtractor   Descriptor;
    Ptr<DescriptorExtractor> descriptorExtractor = ORB::create();
    Mat imageDesc1, imageDesc2;

    descriptorExtractor->compute(image1, keyPoint1, imageDesc1);
    descriptorExtractor->compute(image2, keyPoint2, imageDesc2);

    
    Ptr<DescriptorMatcher> matcher = makePtr<FlannBasedMatcher>(makePtr<flann::LshIndexParams>(12, 20, 2));
    
    vector<vector<DMatch> > matchePoints;
    vector<DMatch> GoodMatchePoints;
    
    MatchesSet matches;
    
    vector<Mat> train_desc(1, imageDesc1);
    matcher->add(train_desc);
    matcher->train();
    
    matcher->knnMatch(imageDesc2, matchePoints, 2);
    
    for (int i = 0; i < matchePoints.size(); i++)
    {
        if (matchePoints[i][0].distance < 0.5 * matchePoints[i][1].distance)
        {
            GoodMatchePoints.push_back(matchePoints[i][0]);
            matches.insert(make_pair(matchePoints[i][0].queryIdx, matchePoints[i][0].trainIdx));
        }
    }
    cout<<"\n1->2 matches: " << GoodMatchePoints.size() << endl;
    
    Mat first_match;
    drawMatches(image02, keyPoint2, image01, keyPoint1, GoodMatchePoints, first_match);
    
    vector<Point2f> imagePoints1, imagePoints2;

    for (int i = 0; i<GoodMatchePoints.size(); i++)
    {
        imagePoints2.push_back(keyPoint2[GoodMatchePoints[i].queryIdx].pt);
        imagePoints1.push_back(keyPoint1[GoodMatchePoints[i].trainIdx].pt);
    }

    Mat homo = findHomography(imagePoints1, imagePoints2, CV_RANSAC);
    cout << "\n" << homo << endl << endl;

    CalcCorners(homo, image01);
    cout << "left_top:" << corners.left_top << endl;
    cout << "left_bottom:" << corners.left_bottom << endl;
    cout << "right_top:" << corners.right_top << endl;
    cout << "right_bottom:" << corners.right_bottom << endl;

    Mat imageTransform1, imageTransform2;
    warpPerspective(image01, imageTransform1, homo, cv::Size(MAX(corners.right_top.x, corners.right_bottom.x), image02.rows));

    int dst_width = imageTransform1.cols;
    int dst_height = image02.rows;

    Mat dst(dst_height, dst_width, CV_8UC3);
    dst.setTo(0);

    imageTransform1.copyTo(dst(cv::Rect(0, 0, imageTransform1.cols, imageTransform1.rows)));
    image02.copyTo(dst(cv::Rect(0, 0, image02.cols, image02.rows)));

    OptimizeSeam(image02, imageTransform1, dst);
    return MatToUIImage(dst);
}

void OptimizeSeam(Mat& img1, Mat& trans, Mat& dst)
{
    int start = MIN(corners.left_top.x, corners.left_bottom.x);
    
    double processWidth = img1.cols - start;
    int rows = dst.rows;
    int cols = img1.cols;
    double alpha = 1;
    for (int i = 0; i < rows; i++)
    {
        uchar* p = img1.ptr<uchar>(i);
        uchar* t = trans.ptr<uchar>(i);
        uchar* d = dst.ptr<uchar>(i);
        for (int j = start; j < cols; j++)
        {
            if (t[j * 3] == 0 && t[j * 3 + 1] == 0 && t[j * 3 + 2] == 0) {
                alpha = 1;
            } else {
                alpha = (processWidth - (j - start)) / processWidth;
            }
            
            d[j * 3] = p[j * 3] * alpha + t[j * 3] * (1 - alpha);
            d[j * 3 + 1] = p[j * 3 + 1] * alpha + t[j * 3 + 1] * (1 - alpha);
            d[j * 3 + 2] = p[j * 3 + 2] * alpha + t[j * 3 + 2] * (1 - alpha);
            
        }
    }
}

@end
