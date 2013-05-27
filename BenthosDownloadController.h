//
//  BenthosDownloadViewController.h
//  SeafloorExplore
//
//  Modified from Brad Larson's Molecules Project in 2011-2012 for use in The SeafloorExplore Project
//
//  Copyright (C) 2012 Matthew Johnson-Roberson
//
//  See COPYING for license details
//  
//  Molecules
//
//  The source code for Molecules is available under a BSD license.  See COPYING for details.
//
//  Created by Brad Larson on 7/2/2008.
//
//  This controller manages the pop-up modal view for downloading new models from the Protein Data Bank

#import <UIKit/UIKit.h>
#import "Model.h"
typedef enum { PUBCHEMSEARCH, PROTEINDATABANKSEARCH } BenthosSearchType;

@interface BenthosDownloadController : NSObject
{
    DownloadedModel *downloadingmodel;
	//NSMutableData *downloadedFileContents;
	long long downloadProgress;

	long long downloadFileSize;
	BOOL downloadCancelled;
	NSURLConnection *downloadConnection;
    
    UIProgressView *progressView;
    UILabel *downloadStatusText;
    UIButton *cancelDownloadButton;
    UIActivityIndicatorView *spinningIndicator;
    NSFileHandle *downloadingFileHandle;
}
@property(nonatomic,assign)BOOL isBackgrounded;
@property(nonatomic, retain)UIProgressView * progressView;
@property(nonatomic, retain)UILabel *downloadStatusText;
@property(nonatomic, retain)UIButton *cancelDownloadButton;
@property(nonatomic, retain)UIActivityIndicatorView *spinningIndicator;
@property(atomic, retain)NSURLConnection *downloadConnection;
@property(atomic, retain) NSFileHandle *downloadingFileHandle;


// Initialization and teardown
- (id)initWithDownloadedModel:(DownloadedModel *)model;
NSString* unitStringFromBytes(double bytes, uint8_t flags,int *exponent,int *width);
NSString* formatBytesNoUnit(double bytes, uint8_t flags,int exponent,int width);
- (void)downloadNewModel;
- (BOOL)downloadModel;
//- (void)connectionError:(NSError *)error;
//- (void)connectionFinish;
//- (void)progress:(NSInteger)bytesRead totalRead:(NSInteger)totalBytesRead totalFileBytes:(NSInteger)totalBytesExpectedToRead;
-(void)appHasGoneToForground;
-(void)appHasGoneToBackground;
- (void)downloadCompleted;
-(void) sendDownloadFinishedMsg:(NSString*)filename;
-(void)updateUntarProgress:(NSNotification *)note;
- (void)cancelDownload;

@end