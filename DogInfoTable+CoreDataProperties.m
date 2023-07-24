//
//  DogInfoTable+CoreDataProperties.m
//  tableViewUsingAPI
//
//  Created by FT42 on 04/07/23.
//
//

#import "DogInfoTable+CoreDataProperties.h"

@implementation DogInfoTable (CoreDataProperties)

+ (NSFetchRequest<DogInfoTable *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"DogInfoTable"];
}

@dynamic dogBreedName;
@dynamic dogBreedImage;

@end
