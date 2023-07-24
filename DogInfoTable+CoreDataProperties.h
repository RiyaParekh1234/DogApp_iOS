//
//  DogInfoTable+CoreDataProperties.h
//  tableViewUsingAPI
//
//  Created by FT42 on 04/07/23.
//
//

#import "DogInfoTable+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DogInfoTable (CoreDataProperties)

+ (NSFetchRequest<DogInfoTable *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *dogBreedName;
@property (nullable, nonatomic, retain) NSData *dogBreedImage;

@end

NS_ASSUME_NONNULL_END
