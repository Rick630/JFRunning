//
//  CFJourneyDao.h
//  JFRunning
//
//  Created by Rick on 1/19/17.
//  Copyright © 2017 RIck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CFJourney.h"
#import "Journey+CoreDataClass.h"
#define DB_PAGE_SIZE   10

@interface CFJourneyDao : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (readonly, strong, nonatomic) NSManagedObjectModel *objectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *coordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

- (void)insertJourney:(CFJourney *)journey;
- (void)deleteJourney:(CFJourney *)journey;
- (NSArray<CFJourney *> *)queryWithPage:(NSInteger)page;
@end
