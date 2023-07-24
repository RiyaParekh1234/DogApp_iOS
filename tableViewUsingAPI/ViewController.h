//
//  ViewController.h
//  tableViewUsingAPI
//
//  Created by FT42 on 04/07/23.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableDictionary *dogInfo;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) AppDelegate *delegate;
@property (strong) NSMutableArray *dogDetailsArray;

@end

