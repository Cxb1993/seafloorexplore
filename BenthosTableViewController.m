//
//  BenthosTableViewController.m
//  Molecules
//
//  The source code for Molecules is available under a BSD license.  See License.txt for details.
//
//  Created by Brad Larson on 6/30/2008.
//
//  This controller manages the root table of molecules that are stored on the device

#import "BenthosTableViewController.h"
#import "BenthosRootViewController.h"
#import "BenthosFolderViewController.h"
#import "Benthos.h"
#import "BenthosAppDelegate.h"
#import "BenthosLibraryTableCell.h"
#import "NSFileManager+Tar.h"
#import "BenthosGLViewController.h"
#import "JSGCDDispatcher.h"
#import "BackgroundProcessingFile.h"

@implementation BenthosTableViewController

#pragma mark -
#pragma mark Initialization and breakdown

- (id)initWithStyle:(UITableViewStyle)style initialSelectedMoleculeIndex:(NSInteger)initialSelectedMoleculeIndex;
{
	if ((self = [super initWithStyle:style])) 
	{        
        self.title = NSLocalizedStringFromTable(@"Models", @"Localized", nil);
		selectedIndex = initialSelectedMoleculeIndex;
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moleculeDidFinishDownloading:) name:@"MoleculeDidFinishDownloading" object:nil];

		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
		
		if ([BenthosAppDelegate isRunningOniPad])
		{
//			self.tableView.backgroundColor = [UIColor blackColor];
//			tableTextColor = [[UIColor whiteColor] retain];
			self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

			UIBarButtonItem *downloadButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(displayMoleculeDownloadView)];
			self.navigationItem.leftBarButtonItem = downloadButtonItem;
			[downloadButtonItem release];
		}
		else
		{
//			tableTextColor = [[UIColor blackColor] retain];
			UIBarButtonItem *modelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"3D Model", @"Localized", nil) style:UIBarButtonItemStylePlain target:self action:@selector(switchBackToGLView)];
			self.navigationItem.leftBarButtonItem = modelButtonItem;
			[modelButtonItem release];
		}
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateUntarProgress:)
                                                     name:@"UntarProgress"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addNewBGTask:)
                                                     name:@"NewBGTask"
                                                   object:nil];
	

    }
	return self;
}

- (void)viewDidLoad;
{
	[super viewDidLoad];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		//		self.tableView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.054f alpha:1.0f];
		self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.rowHeight = 50.0;
        
//        CAGradientLayer *shadowGradient = [BenthosTableViewController shadowGradientForSize:CGSizeMake(320.0f, self.navigationController.view.frame.size.height)];
//		[self.navigationController.view.layer setMask:shadowGradient];
//		self.navigationController.view.layer.masksToBounds = NO;
	}
	else
	{
		self.tableView.backgroundColor = [UIColor whiteColor];
	}	
}
-(void) viewDidAppear:(BOOL)animated{
	[self.tableView reloadData];

}
- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[tableTextColor release];
	[molecules release];
	[super dealloc];
}

#pragma mark -
#pragma mark View switching

- (IBAction)switchBackToGLView;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleView" object:nil];
}

- (IBAction)displayMoleculeDownloadView;
{
    BenthosFolderViewController *folderViewController = [[BenthosFolderViewController alloc] initWithStyle:UITableViewStylePlain];
    folderViewController.molecules = molecules;
    folderViewController.decompressingfiles = decompressingfiles;

    [self.navigationController pushViewController:folderViewController animated:YES];
    [folderViewController release];


}
-(void) showError:(NSError *)error{
    if(error != nil)
    {
        [[[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                     message:[error localizedFailureReason]
                                    delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                           otherButtonTitles:nil] autorelease] show];
    }

}
-(void)addNewBGTask:(NSNotification *)note
{

    dispatch_async(dispatch_get_main_queue(), ^{
    
    
    if (note != nil){
        NSDictionary *userDict = [note userInfo];
        
        NSString *basename =[[userDict objectForKey:@"filename"] stringByDeletingPathExtension];
        BackgroundProcessingFile *curProg = [[BackgroundProcessingFile alloc] initWithName:basename];
        NSLog(@"Added Progress %@\n",basename);
        [decompressingfiles addObject:curProg];
        [curProg release];
        
        
        NSLog(@"Setup new %@\n",basename);
        /*curProg.progressView.progress = 0.0;
               
        curProg.downloadStatusText.text = [NSString stringWithFormat:@"Waiting to Decompress"];*/
        [self.tableView reloadData];
        
        
    }
    });

}

-(void)updateUntarProgress:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
 
        
        if (note != nil){
            NSDictionary *userDict = [note userInfo];
            
            float progress=[[userDict objectForKey:@"progress"] floatValue];
            NSString *basename =[[userDict objectForKey:@"filename"] stringByDeletingPathExtension];
            BackgroundProcessingFile *curProg=nil;
            for(BackgroundProcessingFile *file in decompressingfiles){
                if([basename isEqualToString:[file filenameWithoutExtension]]){
                    curProg=file;
                    break;
                }
                    
            }
            if(curProg == nil)
            {
                //NSLog(@"No valid file for %@\n",basename);
                return;
            }
           /* if(curProg == nil){
                curProg = [[BackgroundProcessingFile alloc] initWithName:basename];
                NSLog(@"Added Progress %@\n",basename);
                [decompressingfiles addObject:curProg];
                [curProg release];
            }*/
                
           //  NSLog(@"Progress %f %@\n",progress,basename);
            curProg.progressView.progress = progress;
            NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
            [formatter setMaximumFractionDigits:2];
            [formatter setMinimumFractionDigits:2];
            [formatter setMinimumIntegerDigits:1];
            
            [formatter setFormatWidth:3];
            [formatter setPaddingCharacter:@" "];
            
          //  curProg.text = [NSString stringWithFormat:@"Extract %@: %@%%", basename,[formatter stringFromNumber: [NSNumber numberWithDouble: progress*100.0]]];
            // NSLog(@"Progress %@ : %.2f%%\n",filename,progress*100.0);
           // [self.tableView reloadData];

            
        }
    });
    
}

-(void)addMolAndShow:(Benthos *)newMolecule{
    for(BackgroundProcessingFile *file in decompressingfiles){
        if([[newMolecule filenameWithoutExtension] isEqualToString:[file filenameWithoutExtension]]){
            [decompressingfiles removeObject:file];
            break;
        }
        
    }

    [molecules addObject:newMolecule];
    [newMolecule release];
    
    if(    UIApplicationStateActive== [[UIApplication sharedApplication] applicationState]){
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            selectedIndex = ([molecules count] - 1);
            
            [self.delegate selectedMoleculeDidChange:selectedIndex];            
        }else{
            
            if ([molecules count] == 1)
            {
                [self.delegate selectedMoleculeDidChange:0];
            }
        }
    }
    [self.tableView reloadData];
    //		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([molecules count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];		

    [self.navigationController popToViewController:self animated:YES];

}

- (void)moleculeDidFinishDownloading:(NSNotification *)note;
{
    if ([note object] == nil)
    {
        [self.navigationController popToViewController:self animated:YES];
        return;
    }
    NSString *filename = [note object];
    //NSLog(@"filename %@\n",filename);
    if([filename length] ==0)
    {
        [self.navigationController popToViewController:self animated:YES];
        return;
    }

    [[JSGCDDispatcher sharedDispatcher] dispatchOnSerialQueue:^{
        //NSLog(@"Unarchive Block Executed On %s", dispatch_queue_get_label(dispatch_get_current_queue()));
    //dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
	NSError *error=nil;
         Benthos *newMolecule=nil;
	if([BenthosAppDelegate processArchive:filename error:&error]){
        
         newMolecule=[[Benthos alloc] initWithModel:[[note userInfo] objectForKey:@"model"] database:self.database];
                
    }else{
         dispatch_async(dispatch_get_main_queue(), ^{ [self showError:error];               
             [[NSNotificationCenter defaultCenter] postNotificationName:@"MoleculeFailedDownloading" object:nil];});
 
    }
         if (newMolecule == nil)
         {
             NSMutableDictionary* details = [NSMutableDictionary dictionary];
             [details setValue:NSLocalizedStringFromTable(@"Error in downloaded file", @"Localized", nil) forKey:NSLocalizedDescriptionKey];
             [details setValue:NSLocalizedStringFromTable(@"The model file is either corrupted or not of a supported format", @"Localized", nil) forKey:NSLocalizedFailureReasonErrorKey];
             
             // populate the error object with the details
             error = [NSError errorWithDomain:@"benthos" code:200 userInfo:details];
             dispatch_async(dispatch_get_main_queue(), ^{ [self showError:error]; });
             
             // Delete the corrupted or sunsupported file
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsDirectory = [paths objectAtIndex:0];
             
             error = nil;
             if(        [[NSFileManager defaultManager]  fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:filename]]){

             if (![[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:&error])
             {
                 
                /* NSMutableDictionary* details = [NSMutableDictionary dictionary];
                 [details setValue:NSLocalizedStringFromTable(@"Could not delete file", @"Localized", nil) forKey:NSLocalizedDescriptionKey];
                 [details setValue:[documentsDirectory stringByAppendingPathComponent:filename] forKey:NSLocalizedFailureReasonErrorKey];
                 // populate the error object with the details
                 error = [NSError errorWithDomain:@"benthos" code:200 userInfo:details];*/
                 dispatch_async(dispatch_get_main_queue(), ^{ [self showError:error]; });
                 
             }
                 NSLog(@"Removing corrupt file %@\n",filename );

             }
             error = nil;
             NSString *folder=[filename stringByDeletingPathExtension];
             if(        [[NSFileManager defaultManager]  fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:folder]]){

             if (![[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:folder] error:&error])
             {
                 /*NSMutableDictionary* details = [NSMutableDictionary dictionary];
                 [details setValue:NSLocalizedStringFromTable(@"Could not delete file", @"Localized", nil) forKey:NSLocalizedDescriptionKey];
                 [details setValue:[documentsDirectory stringByAppendingPathComponent:folder] forKey:NSLocalizedFailureReasonErrorKey];

                 // populate the error object with the details
                 error = [NSError errorWithDomain:@"benthos" code:200 userInfo:details];*/
                 dispatch_async(dispatch_get_main_queue(), ^{ [self showError:error];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"MoleculeFailedDownloading" object:nil];
                 });
             }
             NSLog(@"Removing corrupt folder %@\n",folder );
             }
             
             
         }
         else
         {
             NSLog(@"Non Startup Decompress Finished %@\n",filename);

             dispatch_async(dispatch_get_main_queue(), ^{ [self addMolAndShow:newMolecule]; });
         }			

     }];
    
    if([decompressingfiles count] >0){
        NSLog(@"filename %@\n",filename);
        NSString *basename =[filename stringByDeletingPathExtension];
        BackgroundProcessingFile *curProg = [[BackgroundProcessingFile alloc] initWithName:basename];
        [decompressingfiles addObject:curProg];
        [curProg release];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoleculeFailedDownloading" object:nil];
        [self.navigationController popToViewController:self animated:YES];
        
    }

}

#pragma mark -
#pragma mark Table customization

+ (CAGradientLayer *)glowGradientForSize:(CGSize)gradientSize;
{
	CAGradientLayer *newGlow = [[[CAGradientLayer alloc] init] autorelease];
	//	self.tableView.rowHeight = 20.0f + MAXHEIGHTFOREQUATIONSINTABLEVIEW;
	
	CGRect newGlowFrame = CGRectMake(0, 0, gradientSize.width, gradientSize.height);
	newGlow.frame = newGlowFrame;
//	CGColorRef topColor = [UIColor colorWithRed:0.5585f green:0.7695f blue:1.0f alpha:0.33f].CGColor;
//	CGColorRef middleColor = [UIColor colorWithRed:0.5585f green:0.7695f blue:1.0f alpha:0.0f].CGColor;
//	CGColorRef bottomColor = [UIColor colorWithRed:0.5585f green:0.672f blue:1.0f alpha:0.14f].CGColor;
//	CGColorRef topColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.33f].CGColor;
	CGColorRef topColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f].CGColor;
	CGColorRef middleColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f].CGColor;
	CGColorRef bottomColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.08f].CGColor;
	newGlow.colors = [NSArray arrayWithObjects:(id)(topColor), (id)(middleColor), (id)(bottomColor), nil];
	return newGlow;
}

+ (CAGradientLayer *)shadowGradientForSize:(CGSize)gradientSize;
{
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.startPoint = CGPointMake(1.0f, 0.5);
	newShadow.endPoint = CGPointMake(0.9f, 0.5);
	
	CGRect newShadowFrame = CGRectMake(0, 0, gradientSize.width, gradientSize.height);
	newShadow.frame = newShadowFrame;
	CGColorRef rightColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
	CGColorRef leftColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f].CGColor;
	newShadow.colors = [NSArray arrayWithObjects:(id)(rightColor), (id)(leftColor), nil];
	return newShadow;
}

#pragma mark -
#pragma mark Table view data source delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell;
	NSInteger index = [indexPath row];
	//NSLog(@"Number of inprogress %d %x\n",[decompressingfiles count],(int)decompressingfiles);
    if ([BenthosAppDelegate isRunningOniPad])
		index++;
	//printf("index %d %d \n",index,selectedIndex);
	if (index == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"Download"];
		if (cell == nil) 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Download"] autorelease];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                cell.backgroundColor = [UIColor blackColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            
		}		
		
		cell.textLabel.text = NSLocalizedStringFromTable(@"Download new Models", @"Localized", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIColor blackColor];
	}else{
        
        NSString *typeString;
        
        if (index <= [molecules count]){
            typeString=NSLocalizedStringFromTable(@"InProgress", @"Localized", nil);
        }else{
            typeString= @"Models";
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:typeString];
        if (cell == nil) 
        {
            cell = [[[BenthosLibraryTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:typeString] autorelease];
            
            
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                cell.backgroundColor = [UIColor blackColor];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CAGradientLayer *glowGradientLayer = [BenthosTableViewController glowGradientForSize:CGSizeMake(self.view.frame.size.width, 50.0)];
                [(BenthosLibraryTableCell *)cell setHighlightGradientLayer:glowGradientLayer];
                
                [cell.layer insertSublayer:glowGradientLayer atIndex:10];
            }
            else
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
            
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if ((index - 1) == selectedIndex)
            {
                cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.73 blue:0.95 alpha:1.0];
                
                if (![(BenthosLibraryTableCell *)cell isSelected])
                {
                    CAGradientLayer *glowGradient = [(BenthosLibraryTableCell *)cell highlightGradientLayer];
                    CGColorRef topColor = [UIColor colorWithRed:0.5f green:0.7f blue:1.0f alpha:0.6f].CGColor;
                    CGColorRef middleColor = [UIColor colorWithRed:0.5f green:0.7f blue:1.0f alpha:0.1f].CGColor;
                    CGColorRef bottomColor = [UIColor colorWithRed:0.5585f green:0.672f blue:1.0f alpha:0.30f].CGColor;
                    glowGradient.colors = [NSArray arrayWithObjects:(id)(topColor), (id)(middleColor), (id)(bottomColor), nil];
                    
                    [(BenthosLibraryTableCell *)cell setIsSelected:YES];
                }
            }
            else
            {
                cell.textLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
                
                if ([(BenthosLibraryTableCell *)cell isSelected])
                {
                    CAGradientLayer *glowGradient = [(BenthosLibraryTableCell *)cell highlightGradientLayer];
                    CGColorRef topColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.20f].CGColor;
                    CGColorRef middleColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f].CGColor;
                    CGColorRef bottomColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.08f].CGColor;
                    glowGradient.colors = [NSArray arrayWithObjects:(id)(topColor), (id)(middleColor), (id)(bottomColor), nil];
                    
                    [(BenthosLibraryTableCell *)cell setIsSelected:NO];
                }
            }   
        }
        else
        {
            if ((index - 1) == selectedIndex)
            {
                cell.textLabel.textColor = [UIColor blueColor];
            }
            else
            {
                cell.textLabel.textColor = [UIColor blackColor];
            }
        }
        
        
        
        if (index <= [molecules count])
        {
            if(molecules == nil || index-1 >= [molecules count] || [molecules objectAtIndex:(index-1)] == nil){
                NSLog(@"Error trying to acess null molecule %d\n",[molecules count]);
                return cell;
            }
            //      int l=[[molecules objectAtIndex:(index-1)] numberOfAtoms];
            //printf("Fail Val 0x%x %d\n",(int)[molecules objectAtIndex:(index-1)], l);
            //printf("%d\n",index-1);
            //NSString *fileNameWithoutExtension = [[molecules objectAtIndex:(index-1)] filenameWithoutExtension];
            cell.textLabel.text = [[molecules objectAtIndex:(index-1)] title];
            
            cell.detailTextLabel.text = [[molecules objectAtIndex:(index-1)] desc];
            
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }else{
            cell.userInteractionEnabled=NO;
           /* cell = [tableView dequeueReusableCellWithIdentifier:NSLocalizedStringFromTable(@"InProgress", @"Localized", nil)];
            if (cell == nil) 
            {		
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSLocalizedStringFromTable(@"InProgress", @"Localized", nil)] autorelease];
            }
            */
            int idx= index-[molecules count] -1;
            if(idx >= [decompressingfiles count]){
                NSLog(@"Freak out %d %d %d\n",idx,[molecules count],[decompressingfiles count]);
                return cell;
            }
            BackgroundProcessingFile * file=[decompressingfiles objectAtIndex:idx];
            if(file == nil)
            {
                NSLog(@"Freakout %d\n",idx);
            }
            
            //        cell.textLabel.text=file.downloadStatusText.text;
            float widthMargin=0.05;
            float heightMargin=0.75;
            CGRect textframe = CGRectMake(CGRectGetMinX(cell.contentView.bounds)+widthMargin*CGRectGetWidth(cell.contentView.bounds),
                                          0.0f,
                                          CGRectGetWidth(cell.contentView.bounds)-((2*widthMargin)* CGRectGetWidth(cell.contentView.bounds)),
                                          CGRectGetHeight(cell.contentView.bounds)*heightMargin);
            CGRect progframe = CGRectMake(CGRectGetMinX(cell.contentView.bounds)+widthMargin*CGRectGetWidth(cell.contentView.bounds), 
                                          CGRectGetHeight(cell.contentView.bounds)*heightMargin, CGRectGetWidth(cell.contentView.bounds)-((2*widthMargin)* CGRectGetWidth(cell.contentView.bounds)),
                                          CGRectGetHeight(cell.contentView.bounds)*1.0-heightMargin);
            
            float buttonwidth=20.0f;
            CGRect buttonframe = CGRectMake(CGRectGetWidth(cell.contentView.bounds) -buttonwidth-10.0, 8.0f, buttonwidth, buttonwidth);
            
            [file progressView].frame=progframe;
            cell.textLabel.frame=textframe;
            cell.textLabel.text=[file text];
            [file spinningIndicator].frame=buttonframe;
            [file spinningIndicator].hidden=YES;
            
            [cell.contentView addSubview:[file progressView]];
            //[cell.contentView addSubview:[file downloadStatusText]];
            [cell.contentView addSubview:[file spinningIndicator]];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            
            
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if ([BenthosAppDelegate isRunningOniPad])
	{
		return [molecules count]+ [decompressingfiles count];
	}
	else
	{		
		return ([molecules count] + [decompressingfiles count]+ 1);
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger index = [indexPath row];
	if ([BenthosAppDelegate isRunningOniPad])
	{
		index++;
        indexPath = [NSIndexPath indexPathForRow:index inSection:[indexPath section]];
	}
	
	if (index == 0)
	{
		[self displayMoleculeDownloadView];
	}
	else
	{
		selectedIndex = (index - 1);
		
		[self.delegate selectedMoleculeDidChange:(index - 1)];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[tableView reloadData];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSInteger index = [indexPath row];
	if ([BenthosAppDelegate isRunningOniPad])
		index++;
	
	if (index == 0)
		[self displayMoleculeDownloadView];
	else
	{
		// Display detail view for the protein
		BenthosDetailViewController *detailViewController = [[BenthosDetailViewController alloc] initWithStyle:UITableViewStyleGrouped andMolecule: [molecules objectAtIndex:(index - 1)]];
		
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
		
	}
}

// Make sure that the "Download new molecules" item is not deletable
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
	if ([BenthosAppDelegate isRunningOniPad])
	{
        if([indexPath row] >= [molecules count])
            return  UITableViewCellEditingStyleNone;
        
		return UITableViewCellEditingStyleDelete;
        
	}
	else
	{
		if ([indexPath row] == 0)
		{
			return UITableViewCellEditingStyleNone;
		}
		else if(([indexPath row]-1) >= [molecules count])
        {
            return  UITableViewCellEditingStyleNone;
            
        }else
		{
			return UITableViewCellEditingStyleDelete;
		}
	}	
}

// Manage deletion of a protein from disk
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger index = [indexPath row];
	if ([BenthosAppDelegate isRunningOniPad])
	{
		index++;
	}
	
	if (index == 0) // Can't delete the Download new molecules item
	{
		return;
	}
    
    if(index > [molecules count])
        return;
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        //[mapViewController removeModel:[molecules objectAtIndex:(index - 1)]];
		[[molecules objectAtIndex:(index - 1)] deleteMolecule];
		[molecules removeObjectAtIndex:(index - 1)];
		if ( (index - 1) == selectedIndex )
		{
			if ([molecules count] < 1)
			{
				[self.delegate selectedMoleculeDidChange:0];
			}
			else
			{
				selectedIndex = 0;
				[self.delegate selectedMoleculeDidChange:0];
			}
		}
		else if ( (index - 1) < selectedIndex )
		{
			selectedIndex--;
		}
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Accessors

@synthesize delegate;
@synthesize database;
@synthesize molecules;
@synthesize selectedIndex;
@synthesize decompressingfiles;

@end
