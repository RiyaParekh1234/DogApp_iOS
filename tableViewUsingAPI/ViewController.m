//
//  ViewController.m
//  tableViewUsingAPI
//
//  Created by FT42 on 04/07/23.
//

#import "ViewController.h"
#import "DogInfoTable+CoreDataClass.h"
#import "DogInfoTable+CoreDataProperties.h"
//#import <AFNetworking/AFNetworking.h>
//#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DogInfoTable"];
    self.dogDetailsArray = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _tableView.dataSource = self;
    
    _dogInfo = [[NSMutableDictionary alloc] init];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchDataFromAPI) object:nil];
    [thread start];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        [self fetchDataFromAPI];
//    });
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([_delegate respondsToSelector:@selector(persistentContainer)]) {
        context = _delegate.persistentContainer.viewContext;
    }
    return context;
}

- (void)fetchDataFromAPI {
    NSString *urlString = @"https://dog.ceo/api/breeds/list/all";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
//    ================================= using NSOperationQueue =================================
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            NSLog(@"Response = %@", responseDictionary);
            
            NSDictionary *dict = responseDictionary[@"message"];
            NSManagedObjectContext *context = [self managedObjectContext];
            for (NSString *keys in dict) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DogInfoTable"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dogBreedName = %@", keys];
                NSArray *duplicates = [context executeFetchRequest:fetchRequest error:&error];
                if (duplicates.count > 0) {
                    NSLog(@"duplicates found");
                } else {
                    [self fetchDogImage:keys];
                }
            }
            
            if (![context save:&jsonError]) {
                NSLog(@"Error: cannot save data %@ %@", jsonError, [jsonError localizedDescription]);
            }
            [self.tableView reloadData];
        }
    }];
    [task resume];
    
//    ================================= using Data Task =================================
//    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Error encountered");
//            return;
//        }
//
//        NSError *jsonError;
//        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//
//        if (jsonError) {
//            NSLog(@"JSON error encountered");
//            return;
//        }
//
//        NSDictionary *dict = responseDict[@"message"];
//
//        NSManagedObjectContext *context = [self managedObjectContext];
//        for (NSString *keys in dict) {
//
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DogInfoTable"];
//            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dogBreedName = %@", keys];
//            NSArray *duplicates = [context executeFetchRequest:fetchRequest error:&error];
//            if (duplicates.count > 0) {
//                NSLog(@"duplicates found");
//            } else {
//                [self fetchDogImage:keys];
//            }
//        }
//
//        NSError *saveError = nil;
//        if (![context save:&saveError]) {
//            NSLog(@"Error: cannot save data %@ %@", saveError, [saveError localizedDescription]);
//        }
//
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    }];
//
//    [dataTask resume];
}

- (void)fetchDogImage: (NSString *)breed {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *urlString = [NSString stringWithFormat:@"https://dog.ceo/api/breed/%@/images/random",breed];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    //    ================================= using NSOperationQueue =================================
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            NSURL *imageURL = [NSURL URLWithString:responseDictionary[@"message"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            DogInfoTable *dogBreed = [NSEntityDescription insertNewObjectForEntityForName:@"DogInfoTable" inManagedObjectContext:context];
            [dogBreed setValue:breed forKey:@"dogBreedName"];
            [dogBreed setValue:imageData forKey:@"dogBreedImage"];
            
            [self.dogDetailsArray addObject:dogBreed];
            if (![context save:&jsonError]) {
                NSLog(@"Error occurred");
            }
        }
    }];
    [task resume];
    //    ================================= using Data Task =================================
    /*
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error encountered");
            return;
        }
        
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            NSLog(@"JSON error encountered");
            return;
        }
        
        NSURL *imageURL = [NSURL URLWithString:responseDict[@"message"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        DogInfoTable *dogBreed = [NSEntityDescription insertNewObjectForEntityForName:@"DogInfoTable" inManagedObjectContext:context];
        [dogBreed setValue:breed forKey:@"dogBreedName"];
        [dogBreed setValue:imageData forKey:@"dogBreedImage"];
        
        [self.dogDetailsArray addObject:dogBreed];
        
        NSError *saveError = nil;
        if (![context save:&saveError]) {
            NSLog(@"Error: cannot save %@ %@", saveError, [saveError localizedDescription]);
        }
        
        
    }];
    [dataTask resume];
     */
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell== nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    DogInfoTable *dog = [self.dogDetailsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dog valueForKey:@"dogBreedName"];
    cell.imageView.image = [UIImage imageWithData:[dog valueForKey:@"dogBreedImage"]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dogDetailsArray.count;
}
@end
