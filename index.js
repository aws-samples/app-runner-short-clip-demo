var compression = require('compression')
const express = require('express');
const app = express();
app.use(compression());
const port = 3000;



var AWS = require("aws-sdk");

AWS.config.update({
    region: process.env.AWS_REGION
});

var dynamodbClient = new AWS.DynamoDB.DocumentClient();

app.get('/', (req, res) => {
    var table = process.env.DYNAMODB_DEMO_TABLE;
    var params = {
        TableName: table,
        Key: {
            name: 'counter'
        },
        UpdateExpression: "set counter_count = counter_count + :val",
        ExpressionAttributeValues: {
            ":val": 1
        },
        ReturnValues: "UPDATED_NEW"
    };

    dynamodbClient.update(params, function (err, data) {
        if (err) {
            console.log("Working in %s on table %s", process.env.AWS_REGION, process.env.DYNAMODB_DEMO_TABLE);
            console.log(JSON.stringify(err, undefined, 2));
            res.send('Error reaching dynamodb');
        } else {
            console.log("Incremented counter to: " + data.Attributes.counter_count);
            res.send('Page Impressions: ' + data.Attributes.counter_count + '<br>Version 3');
        }
    });
})


app.listen(port, () => {
    console.log(`app listening at ${port}`);
    console.log(`working in region ${process.env.AWS_REGION} on dynamodb table ${process.env.DYNAMODB_DEMO_TABLE}`)
});
