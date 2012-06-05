//
//  BackgroundProcessingFile.h
//  Benthos
//
//  Created by Matthew Johnson-Roberson on 6/4/12.
//  Copyright (c) 2012 Sunset Lake Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundProcessingFile : NSObject{
    NSString *filenameWithoutExtension;
    UIProgressView *progressView;
    UILabel *textLabel;
    UIActivityIndicatorView *spinningIndicator;
}
@property (nonatomic, retain) NSString *filenameWithoutExtension;
@property(nonatomic, retain)UIProgressView * progressView;
@property(nonatomic, retain)UILabel *textLabel;
@property(nonatomic, retain)UIActivityIndicatorView *spinningIndicator;

- (id)initWithName:(NSString *)name;

@end
