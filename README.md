## optimizeDbBeforeStartup option Breaks dynamodb local

When using dynamodb-local with the -optimizeDbBeforeStartup option enabled you can insert duplicate items in a table that have the same hash key.

This ends up breaking operations for the table with the following exception  being thrown:

```
lms-dynamodb-local-optimized_1     | Apr 06, 2021 3:36:55 PM com.almworks.sqlite4java.Internal log
lms-dynamodb-local-optimized_1     | WARNING: [sqlite] SQLiteDBAccess$14@1b2b33ec: job exception
lms-dynamodb-local-optimized_1     | com.amazonaws.services.dynamodbv2.local.shared.exceptions.LocalDBAccessException: Given key conditions were not unique. Returned: [{val=AttributeValue: {S:i'm 1 item}, .pk=AttributeValue: {B:java.nio.HeapByteBuffer[pos=0 lim=72 cap=72]}}] and [{val=AttributeValue: {S:i'm 2 item}, .pk=AttributeValue: {B:java.nio.HeapByteBuffer[pos=0 lim=72 cap=72]}}].
lms-dynamodb-local-optimized_1     |    at com.amazonaws.services.dynamodbv2.local.shared.access.LocalDBUtils.ldAccessFail(LocalDBUtils.java:799)
lms-dynamodb-local-optimized_1     |    at com.amazonaws.services.dynamodbv2.local.shared.access.sqlite.SQLiteDBAccessJob.getRecordInternal(SQLiteDBAccessJob.java:224)
lms-dynamodb-local-optimized_1     |    at com.amazonaws.services.dynamodbv2.local.shared.access.sqlite.SQLiteDBAccess$14.doWork(SQLiteDBAccess.java:1555)
lms-dynamodb-local-optimized_1     |    at com.amazonaws.services.dynamodbv2.local.shared.access.sqlite.SQLiteDBAccess$14.doWork(SQLiteDBAccess.java:1551)
lms-dynamodb-local-optimized_1     |    at com.amazonaws.services.dynamodbv2.local.shared.access.sqlite.AmazonDynamoDBOfflineSQLiteJob.job(AmazonDynamoDBOfflineSQLiteJob.java:117)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteJob.execute(SQLiteJob.java:372)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteQueue.executeJob(SQLiteQueue.java:534)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteQueue.queueFunction(SQLiteQueue.java:667)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteQueue.runQueue(SQLiteQueue.java:623)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteQueue.access$000(SQLiteQueue.java:77)
lms-dynamodb-local-optimized_1     |    at com.almworks.sqlite4java.SQLiteQueue$1.run(SQLiteQueue.java:205)
lms-dynamodb-local-optimized_1     |    at java.lang.Thread.run(Thread.java:748)
lms-dynamodb-local-optimized_1     |
```

Table definition

```
> aws dynamodb describe-table --table-name b-pk-table --endpoint-url http://localhost:8001 --region=us-east-1 --profile local
{
    "Table": {
        "AttributeDefinitions": [
            {
                "AttributeName": ".pk",
                "AttributeType": "B"
            }
        ],
        "TableName": "b-pk-table",
        "KeySchema": [
            {
                "AttributeName": ".pk",
                "KeyType": "HASH"
            }
        ],
        "TableStatus": "ACTIVE",
        "CreationDateTime": 1617722286.083,
        "ProvisionedThroughput": {
            "LastIncreaseDateTime": 0.0,
            "LastDecreaseDateTime": 0.0,
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 0,
            "WriteCapacityUnits": 0
        },
        "TableSizeBytes": 176,
        "ItemCount": 2,
        "TableArn": "arn:aws:dynamodb:ddblocal:000000000000:table/b-pk-table",
        "BillingModeSummary": {
            "BillingMode": "PAY_PER_REQUEST",
            "LastUpdateToPayPerRequestDateTime": 1617722286.083
        }
    }
}
```

scan of the table after testing

```
> aws dynamodb scan --table-name b-pk-table --endpoint-url http://localhost:8001 --region=us-east-1 --profile local
{
    "Items": [
        {
            "val": {
                "S": "i'm 1 item"
            },
            ".pk": {
                "B": "U1h3UURsMGpYazZuZi9GZnljc3hnemxrWm1Oa09EZG1MVGxqWXpNdE5HRXpPQzFpTUdZMkxXRTNPRGhoTkRBelpHTmlaUT09"
            }
        },
        {
            "val": {
                "S": "i'm 2 item"
            },
            ".pk": {
                "B": "U1h3UURsMGpYazZuZi9GZnljc3hnemxrWm1Oa09EZG1MVGxqWXpNdE5HRXpPQzFpTUdZMkxXRTNPRGhoTkRBelpHTmlaUT09"
            }
        }
    ],
    "Count": 2,
    "ScannedCount": 2,
    "ConsumedCapacity": null
}
```

### Steps to recreate

```
docker-compose up
insert-data.sh 
## observe your docker logs for the optimized db, it will have exceptions
## the unoptimized db will not.  
## The un-optimized db has only 1 record with a val of "i'm 4 item"
## The optimized db has 2 records with the same hash key but vals of "i'm 1 item" and "i'm 2 item"
```

