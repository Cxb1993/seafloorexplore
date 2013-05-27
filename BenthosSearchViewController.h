//
//  BenthosSearchViewController.h
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
//  Created by Brad Larson on 7/22/2008.
//
//  This handles the keyword searching functionality of the Protein Data Bank

#import <UIKit/UIKit.h>
#import "BenthosTableViewController.h"
#import "BenthosDownloadController.h"
#import "IconDownloader.h"

@interface BenthosSearchViewController : UITableViewController <UIScrollViewDelegate, IconDownloaderDelegate>
{
	NSMutableArray *downloadaleModelList;
	NSMutableData *downloadedFileContents;
	NSURLConnection *searchResultRetrievalConnection;
	BOOL searchCancelled, isDownloading, isRetrievingCompoundNames;
    NSInteger indexOfDownloadingModel;
    
    BenthosDownloadController *downloadController;
    NSMutableString *currentXMLElementString;
    NSXMLParser *searchResultsParser;
   //NSString *urlbasepath;
    NSMutableData *modelData;
    NSURL *listURL;
    NSMutableArray *models;
    NSMutableArray *decompressingfiles;

    NSMutableDictionary *imageDownloadsInProgress;  // the set of 
    NSOperationQueue *parseQueue;

    
}
@property (nonatomic, retain) NSMutableData *modelData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing earthquake data
@property (nonatomic, retain) NSURL *listURL;     
@property(readwrite,retain) NSMutableArray *models;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property(readwrite,retain) 	NSMutableArray *downloadaleModelList;
@property(readwrite,retain) NSMutableArray *decompressingfiles;

// Performing search
- (void)processSearchResultsAppendingNewData:(BOOL)appendData;
- (void)processHTMLResults;
- (void)addModels:(NSNotification *)notif ;
- (void)modelFailedDownloading:(NSNotification *)note;
- (void)addModelsToList:(NSArray *)mod ;
- (id)initWithStyle:(UITableViewStyle)style andURL:(NSURL*)url andTitle:(NSString*)title;

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
