//
//  FMDBHelper.m
//  Team Wurzel
//
//  Created by Ralf Schleicher on 30.12.13.
//  Copyright (c) 2013 Team Wurzel. All rights reserved.
//

#import "FMDBORMHelper.h"
#import "FMResultSet.h"

@interface FMDBORMHelper ()
+(bool)isClassConform:(Class)classRepresentation;
@end

/*!
 * This class provides general helper methods for objects which implement the FMDBORMTableProtocol
 */
@implementation FMDBORMHelper
/*!
 * Tests the class on conformity to the FMDBORMTableProtocol.
 *
 * @param classRepresentation # the class to test for conformity
 * @return conformity bool
 */
+(bool)isClassConform:(Class)classRepresentation {
    if (![classRepresentation conformsToProtocol:@protocol(FMDBORMTableProtocol)]) {
        [NSException raise:@"ImplementationError" format:@"Class does not implement the FMDBORMTableProtocol. You can't use your class with the FMDBORMHelper without implementing it."];
        return NO;
    }
    return YES;
}

/*!
 * Creates a CREATE TABLE statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)createStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    NSString *tableName = [classRepresentation tableName];
    NSDictionary *mapping = [classRepresentation mapping];

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSString* item in mapping) {
        [arr addObject:[mapping objectForKey:item]];
    }
    NSString* mappingString = [arr componentsJoinedByString:@", "];
    NSString* create = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS `%@` (%@)", tableName, mappingString];
    return create;
}

/*!
 * Creates a DROP TABLE statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)dropStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    NSString *tableName = [classRepresentation tableName];
    return [NSString stringWithFormat:@"DROP TABLE IF EXISTS `%@`", tableName];
}

/*!
 * Creates a SELECT FROM statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)selectStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    // get tablename and mapping
    NSString *tableName = [classRepresentation tableName];
    NSDictionary *mapping = [classRepresentation mapping];
    
    // maps the variables to the columnnames and values and saves it into a array of appropriate size
    NSMutableArray *keyListArray = [[NSMutableArray alloc] initWithCapacity:mapping.count];
    for (NSString* item in mapping) {
        FMDBORMColumn *column = [mapping objectForKey:item];
        [keyListArray addObject:[NSString stringWithFormat:@"`%@`", column.name]];
    }
    
    // assemble the whole statement
    NSString *mappingString = [keyListArray componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"SELECT %@ FROM `%@`", mappingString, tableName];
}

/*!
 * Creates a INSERT INTO statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)insertStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    // get tablename and mapping
    NSString *tableName = [classRepresentation tableName];
    NSDictionary *mapping = [classRepresentation mapping];
    
    // maps the variables to the columnnames and values and saves it into a array of appropriate size
    NSMutableArray *keyListArray = [[NSMutableArray alloc] initWithCapacity:mapping.count - 1];
    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:mapping.count - 1];
    for (NSString* item in mapping) {
        FMDBORMColumn *column = [mapping objectForKey:item];
        // we don't want the primary key item to be mapped so we test for it
        if ([column.extraModifier containsObject:FMDBORMExtraPrimaryKey]) {
            continue;
        }

        [keyListArray addObject:[NSString stringWithFormat:@"`%@`", column.name]];
        [valueArray addObject:@"?"];
    }
    
    // create the whole statement
    NSString *keyMappingString = [keyListArray componentsJoinedByString:@", "];
    NSString *valueMappingString = [valueArray componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"INSERT INTO `%@` (%@) VALUES(%@)", tableName, keyMappingString, valueMappingString];
}

/*!
 * Creates a UPDATE statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)updateStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    // get tablename and mapping
    NSString *tableName = [classRepresentation tableName];
    NSDictionary *mapping = [classRepresentation mapping];
    
    // maps the variables to the columnnames and values and saves it into a array of appropriate size
    NSMutableArray *keyValueListArray = [[NSMutableArray alloc] init];
    for (NSString* item in mapping) {
        FMDBORMColumn *column = [mapping objectForKey:item];
        // we don't want the primary key item to be mapped so we test for it
        if ([column.extraModifier containsObject:FMDBORMExtraPrimaryKey]) {
            continue;
        }

        [keyValueListArray addObject:[NSString stringWithFormat:@"`%@` = ?", column.name]];
    }
    
    // create the whole statement
    NSString *mappingString = [keyValueListArray componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"UPDATE `%@` SET %@", tableName, mappingString];
}

/*!
 * Creates a DELETE FROM statement for the given class representation
 *
 * @param classRepresentation # the class to use for statement
 * @return the sqlite statement
 */
+(NSString *)deleteStatementForClass:(Class)classRepresentation {
    if (![self isClassConform:classRepresentation]) {
        return @"";
    }
    
    // create the whole statement
    NSString *tableName = [classRepresentation tableName];
    return [NSString stringWithFormat:@"DELETE FROM `%@`", tableName];
}

@end
