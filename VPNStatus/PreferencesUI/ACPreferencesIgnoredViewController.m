//
//  ACPreferencesIgnoredViewController.m
//
//  Created by Alexandre Colucci on 12.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACPreferencesIgnoredViewController.h"
#import "ACPreferences.h"

@interface ACPreferencesIgnoredViewController () <NSTableViewDataSource, NSTextFieldDelegate>

@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSTableView *ignoredSSIDsTableView;
@property (weak) IBOutlet NSButton *ignoredSSIDsRemoveButton;

@property (weak) IBOutlet NSTableView *ignoredVPNsTableView;
@property (weak) IBOutlet NSButton *ignoredVPNsRemoveButton;

@property (strong) NSMutableArray<NSString *> *ignoredSSIDs;
@property (strong) NSMutableArray<NSString *> *ignoredVPNs;

@end


@implementation ACPreferencesIgnoredViewController

- (instancetype)initViewController
{
    self = [super initWithNibName:@"ACPreferencesIgnoredView" bundle:nil];
    if (self)
    {
		self.ignoredSSIDs = [[[ACPreferences sharedPreferences] ignoredSSIDs] mutableCopy];
		self.ignoredVPNs = [[[ACPreferences sharedPreferences] ignoredVPNs] mutableCopy];
    }
    
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateIgnoredSSIDsRemoveButtons];
	[self updateIgnoredVPNsRemoveButtons];
}

-(NSString*)identifier
{
    return [[self title] lowercaseString];
}

-(NSString*)title
{
    return @"Ignored";
}


// MARK: - Ignored SSIDs

- (void)saveIgnoredSSIDsToPrefs
{
	[[ACPreferences sharedPreferences] setIgnoredSSIDs:self.ignoredSSIDs];
}

-(void)reloadIgnoredSSIDs
{
	[self.ignoredSSIDsTableView reloadData];
	[self updateIgnoredSSIDsRemoveButtons];
}

-(void)updateIgnoredSSIDsRemoveButtons
{
	[self.ignoredSSIDsRemoveButton setEnabled:([self.ignoredSSIDsTableView selectedRow] >= 0)];
}

-(IBAction)doAddSSIDs:(id)sender
{
	[self.ignoredSSIDs addObject:@""];
	[self saveIgnoredSSIDsToPrefs];
	[self reloadIgnoredSSIDs];

	NSInteger numberOfRows = [self.ignoredSSIDs count];
	if(numberOfRows >= 1)
	{
		[self.ignoredSSIDsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(numberOfRows-1)] byExtendingSelection:NO];
		[self.ignoredSSIDsTableView scrollRowToVisible:numberOfRows-1];

		NSTableCellView *selectedView = (NSTableCellView *)[self.ignoredSSIDsTableView viewAtColumn:0 row:(numberOfRows-1) makeIfNecessary:YES];
		[selectedView.textField selectText:self];
		[[selectedView.textField currentEditor] setSelectedRange:NSMakeRange([[selectedView.textField stringValue] length], 0)];
	}
}

-(IBAction)doRemoveSSIDs:(id)sender
{
	NSInteger selectedRow = [self.ignoredSSIDsTableView selectedRow];
	if(selectedRow >= 0 && selectedRow < [self.ignoredSSIDs count])
	{
		[self.ignoredSSIDs removeObjectAtIndex:selectedRow];
		[self saveIgnoredSSIDsToPrefs];
		[self reloadIgnoredSSIDs];
	}
}

// MARK: - Ignored VPNs

- (void)saveIgnoredVPNsToPrefs
{
	[[ACPreferences sharedPreferences] setIgnoredVPNs:self.ignoredVPNs];
}

-(void)reloadIgnoredVPNs
{
	[self.ignoredVPNsTableView reloadData];
	[self updateIgnoredVPNsRemoveButtons];
}

-(void)updateIgnoredVPNsRemoveButtons
{
	[self.ignoredVPNsRemoveButton setEnabled:([self.ignoredVPNsTableView selectedRow] >= 0)];
}

-(IBAction)doAddVPN:(id)sender
{
	[self.ignoredVPNs addObject:@""];
	[self saveIgnoredVPNsToPrefs];
	[self reloadIgnoredVPNs];

	NSInteger numberOfRows = [self.ignoredVPNs count];
	if(numberOfRows >= 1)
	{
		[self.ignoredVPNsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(numberOfRows-1)] byExtendingSelection:NO];
		[self.ignoredVPNsTableView scrollRowToVisible:numberOfRows-1];

		NSTableCellView *selectedView = (NSTableCellView *)[self.ignoredVPNsTableView viewAtColumn:0 row:(numberOfRows-1) makeIfNecessary:YES];
		[selectedView.textField selectText:self];
		[[selectedView.textField currentEditor] setSelectedRange:NSMakeRange([[selectedView.textField stringValue] length], 0)];
	}
}

-(IBAction)doRemoveVPN:(id)sender
{
	NSInteger selectedRow = [self.ignoredVPNsTableView selectedRow];
	if(selectedRow >= 0 && selectedRow < [self.ignoredVPNs count])
	{
		[self.ignoredVPNs removeObjectAtIndex:selectedRow];
		[self saveIgnoredVPNsToPrefs];
		[self reloadIgnoredVPNs];
	}
}

// MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if(tableView == self.ignoredSSIDsTableView)
	{
		return [self.ignoredSSIDs count];
	}
	else if(tableView == self.ignoredVPNsTableView)
	{
		return [self.ignoredVPNs count];
	}
	else
	{
		return 0;
	}
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
	if(tableView == self.ignoredSSIDsTableView)
	{
		NSTableCellView *cellView = (NSTableCellView*)[tableView makeViewWithIdentifier:@"SSIDsRegexID" owner:nil];
		if(row >= 0 && row < [self.ignoredSSIDs count])
		{
			NSString *theString = [self.ignoredSSIDs objectAtIndex:row];
			cellView.textField.stringValue = theString;
			cellView.textField.toolTip = theString;
			cellView.textField.textColor = NSColor.textColor;

			if ([theString length] > 0)
			{
				// Check if the regex is valid or not
				NSError *error = nil;
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:theString options:0 error:&error];
				if(regex == nil)
				{
					cellView.textField.textColor = NSColor.systemRedColor;
					cellView.textField.toolTip = @"This string is an invalid regular expression.";
				}
			}
		}
		else
		{
			cellView.textField.stringValue = @"";
			cellView.textField.toolTip = nil;
			cellView.textField.textColor = NSColor.textColor;
		}
		
		cellView.textField.delegate = self;
		return cellView;
	}
	else if(tableView == self.ignoredVPNsTableView)
	{
		NSTableCellView *cellView = (NSTableCellView*)[tableView makeViewWithIdentifier:@"VPNRegexID" owner:nil];
		if(row >= 0 && row < [self.ignoredVPNs count])
		{
			NSString *theString = [self.ignoredVPNs objectAtIndex:row];
			cellView.textField.stringValue = theString;
			cellView.textField.toolTip = theString;
			cellView.textField.textColor = NSColor.textColor;

			if ([theString length] > 0)
			{
				// Check if the regex is valid or not
				NSError *error = nil;
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:theString options:0 error:&error];
				if(regex == nil)
				{
					cellView.textField.textColor = NSColor.systemRedColor;
					cellView.textField.toolTip = @"This string is an invalid regular expression.";
				}
			}
		}
		else
		{
			cellView.textField.stringValue = @"";
			cellView.textField.toolTip = nil;
			cellView.textField.textColor = NSColor.textColor;
		}
		
		cellView.textField.delegate = self;
		return cellView;
	}
	else
	{
		return nil;
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateIgnoredSSIDsRemoveButtons];
	[self updateIgnoredVPNsRemoveButtons];
}

// MARK: - NSTextFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
	NSTextField *textField = (NSTextField*)[notification object];
	if(textField != nil)
	{
		NSInteger ignoredSSIDsRow = [self.ignoredSSIDsTableView rowForView:textField];
		if(ignoredSSIDsRow >= 0 && ignoredSSIDsRow < [self.ignoredSSIDs count])
		{
			NSString *newSSID = textField.stringValue;
			[self.ignoredSSIDs replaceObjectAtIndex:ignoredSSIDsRow withObject:newSSID];
			[self saveIgnoredSSIDsToPrefs];
			[self reloadIgnoredSSIDs];
		}
		
		NSInteger ignoredVPNsRow = [self.ignoredVPNsTableView rowForView:textField];
		if(ignoredVPNsRow >= 0 && ignoredVPNsRow < [self.ignoredVPNs count])
		{
			NSString *newVPN = textField.stringValue;
			[self.ignoredVPNs replaceObjectAtIndex:ignoredVPNsRow withObject:newVPN];
			[self saveIgnoredVPNsToPrefs];
			[self reloadIgnoredVPNs];
		}
	}
}

@end
