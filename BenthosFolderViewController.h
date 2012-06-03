//
//  BenthosFolderViewController.h
//  Molecules
//
//  The source code for Molecules is available under a BSD license.  See License.txt for details.
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
    
    NSString *urlbasepath;
    NSMutableData *folderData;
    NSMutableArray *molecules;
    NSOperationQueue *parseQueue;

    
}
@property (nonatomic, retain) NSMutableData *folderData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing earthquake data
@property(readwrite,retain) NSMutableArray *molecules;


// Performing search
- (void)processSearchResultsAppendingNewData:(BOOL)appendData;
- (void)processResults;
- (void)addFolder:(NSNotification *)notif ;
- (void)addFolderToList:(NSArray *)folders ;

@end
