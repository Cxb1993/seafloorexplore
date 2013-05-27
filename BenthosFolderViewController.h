//
//  BenthosFolderViewController.h
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

@interface BenthosFolderViewController : UITableViewController
{
	NSMutableArray *downloadaleFolderList;
	NSMutableData *downloadedFileContents;
	NSURLConnection *searchResultRetrievalConnection, *nextResultsRetrievalConnection;
	BOOL searchCancelled,  isRetrievingCompoundNames;
    
    NSMutableData *folderData;
    NSMutableArray *models;
    NSOperationQueue *parseQueue;
    NSMutableArray *decompressingfiles;

    
}
@property (nonatomic, retain) NSMutableData *folderData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing earthquake data
@property(readwrite,retain) NSMutableArray *models;
@property(readwrite,retain) NSMutableArray *decompressingfiles;


// Performing search
- (void)processSearchResultsAppendingNewData:(BOOL)appendData;
- (void)processResults;
- (void)addFolder:(NSNotification *)notif ;
- (void)addFolderToList:(NSArray *)folders ;

@end
