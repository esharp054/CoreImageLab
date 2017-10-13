//
//  OpenCVBridgeSub.m
//  ImageLab
//
//  Created by Eric Larson on 10/4/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSubClass.h"

#import "AVFoundation/AVFoundation.h"

#define ARRAY_SIZE 100


using namespace cv;

@interface OpenCVBridgeSubClass()
@property (nonatomic) cv::Mat image;
@property (nonatomic) float* avgBlue;
@property (nonatomic) float* avgRed;
@property (nonatomic) float* avgGreen;
@property (nonatomic) int counter;
@property (nonatomic) bool displayText;
@property (nonatomic) bool cameraCover;
@property (atomic) cv::CascadeClassifier faceClassifier;
@property (atomic) cv::CascadeClassifier eyesClassifier;
@property (atomic) cv::CascadeClassifier mouthClassifier;
@property (atomic) cv::CascadeClassifier smileClassifier;
@end

@implementation OpenCVBridgeSubClass
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).


-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    switch (self.processType) {
        case 1:
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"xml"];
            self.faceClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.faceClassifier.detectMultiScale(image_copy, objects);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            
            self.image = image;
            break;
        }
        case 2:
        {
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"eye" ofType:@"xml"];
            self.eyesClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.eyesClassifier.detectMultiScale(image_copy, objects);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            self.image = image;
            break;
        }
        case 3:
        {
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Mouth" ofType:@"xml"];
            self.mouthClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.mouthClassifier.detectMultiScale(image_copy, objects);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            self.image = image;
            break;
        }
        case 4:
        {
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"smile" ofType:@"xml"];
            self.smileClassifier = cv::CascadeClassifier([filePath UTF8String]);
            
            cvtColor(image, image_copy, CV_BGRA2GRAY);
            vector<cv::Rect> objects;
            
            // run classifier
            // error if this is not set!
            self.smileClassifier.detectMultiScale(image_copy, objects);
            
            // display bounding rectangles around the detected objects
            for( vector<cv::Rect>::const_iterator r = objects.begin(); r != objects.end(); r++)
            {
                cv::rectangle( image, cvPoint( r->x, r->y ), cvPoint( r->x + r->width, r->y + r->height ), Scalar(0,0,255,255));
            }
            //image already in the correct color space
            self.image = image;
            break;
        }
            
        default:
            break;
    }
    
}

@end

