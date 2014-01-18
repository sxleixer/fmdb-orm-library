# fmdb-orm-library
fmdb-orm-library is an iOS (probably even MacOS, thus not tested yet) ORM library. It is taking the FMDB SQLite Database Handler to the next level. And perfectly integrates the ORM approach into the FMDatabase environments generating a minimum of object handling overhead by caching frequently used parts.

The library uses ARC so if you want to use it in a non-ARC project you will have to set the compiler-flag <code>-fobjc-arc</code> to the FMDBORM[...]-Classes.

## What does it do?
fmdb-orm-library defines a protocol to interact with every database type you'd like to.
Already integrated into the Library is a prototype class called <code>FMDBORMModel</code>. By subclassing this class you can define and map new objects for interaction with the underlying SQLLite database.

## How to do it?
Clone the library into your project and add the <code>FMDBLibrary</code> folder into your project file. You will also have to add the fmdb library. Either you do it by cloning it from their repository or you use the copy included in the <code>Frameworks/fmdb</code> folder which definetly works with the current version.

Create a subclass of <code>FMDBORMModel</code>.
By default every entity inheriting from that prototype class already has a field named <code>uid</code> which identifies the object in your database table.

Override the class method <code>+(NSString*)tablename</code> which returns the name of your table. The name has to conform to the SQLLite standard of the underlying database.

Override the class method <code>+(NSDictionary)mapping</code> like shown below.
Assuming there is a property <code>entityKey</code> of type <code>NSString</code> present.
```objective-c
+(NSDictionary)mapping {
 NSMutableDictionary *mapping = [NSMutableDictionary dictionaryWithDictionary:[super mapping]];

 [mapping setObject:[[FMDBORMColumn alloc] initWithColumnName:@"entity_key" andType:FMDBORMTypeText andExtraModifier:@[FMDBORMExtraUnique] forKey:@"entityKey"];

 return mapping;
}
```
You don't have to care about performance because this part will be called once and then be cached.

If you're in the opinion that your model is ready to use, you finally habe to override the Methode <code>+(BOOL)isAbstract</code> as follows.
```objective-c
+(BOOL)isAbstract {
 return NO;
}
```

## Creating, updating, deleting rows
Assuming that there is a Model named <code>Bike</code> with mapped properties <code>NSInteger speed, NSString *facturer, CGFloat frameHeight, NSDate *factoringDate, NSData *image</code>.
```objective-c
FMDatabaseQueue *queue = ...

[queue inDatabase:^(FMDatabase db) {
 Bike *stevens = [[Bike alloc] init];
 stevens.facturer = @"Stevens";
 stevens.frameHeight = 1.2;
 stevens.factoringDate = [NSDate now];
 stevens.image = UIPNGDataRepresentation([[UIImage alloc] initWithContentsOfFile:@"filepath"]);
 // Creates or updates the object
 [stevens put:db];
 ...
 // Delete the object
 [stevens erase:db];
}
```

## How to tweak the standard model?
If you're working with for example Google App Engine you soon will find the standard model to be inappropriate. But since the model is highly flexible you can override some methods to achieve your desired goal.
