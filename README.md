# S3-to-DynamoDB-to-Redshift-Data-Pipeline
This project automates the process of loading data from a CSV file stored in an S3 bucket into DynamoDB using an AWS Lambda function. It subsequently copies the data from DynamoDB to an Amazon Redshift cluster for analysis. Additionally, it demonstrates how to access external data using Redshift Spectrum and unload data back to S3.

## Prerequisites

-  AWS Account

-  AWS CLI configured

-  Basic understanding of AWS services (S3, DynamoDB, Lambda, Redshift)

-  Python 3.x installed (for local testing, if needed)

### Architectural Diagram Description

The architectural diagram illustrate the following components:

1.  **S3 Bucket:** The starting point where the CSV file is stored.

2.  **AWS Lambda:** The function that triggers on file upload to S3 and loads data into DynamoDB.

3.  **DynamoDB Table:** Where the crime data is stored.

4.  **Redshift Cluster:** Where data is copied from DynamoDB for analysis.

5.  **Redshift Spectrum:** Accessing external data stored in another S3 bucket.

6.  **Data Analysis:** Queries executed on the data in Redshift.

7.  **S3 Bucket for Unloading:** Where the unloaded data is stored.

![S3-to-DynamoDB-to-Redshift-Data-Pipeline](https://github.com/user-attachments/assets/876c230d-bffd-4389-ba99-0b3c119a2523)

## Setup Instructions

**Step 1: Set Up S3 Bucket**

1. **Create an S3 Bucket:**

  *  Go to the S3 console.
  
  *  Create a new bucket (e.g., my-crimes-data-bucket).

2. **Upload CSV File:**

  *  Upload the crime data CSV file to your S3 bucket.

**Step 2: Create DynamoDB Table**

1. **Create DynamoDB Table:**

  *  Go to the DynamoDB console.

  *  Create a table named Chicagocrimes with:

     -  Primary Key: id (Type: Number)

**Step 3: Create IAM Role for Lambda**

1. **Create IAM Role:**

  *  Go to the IAM console.
    
  *  Create a new role with the following permissions:

      *  AmazonS3ReadOnlyAccess
      *  AmazonDynamoDBFullAccess
      *  CloudWatchLogsFullAccess

**Step 4: Create Lambda Function**

1. **Create the Lambda Function:**

  *  Go to the Lambda console.
    
  *  Create a new function:
    
      *  Runtime: Python 3.x
      
      *  Execution role: Use the IAM role created in Step 3.

2. **Add S3 Trigger:**

  *  Configure the function to be triggered when a new object is created in your S3 bucket.

3. **Update Lambda Function Code:**

  *  Use the following code for your Lambda function:

    import json
    import csv
    import boto3
    
    def lambda_handler(event, context):
        region = 'us-east-1'
        record_list = []
        try:
            s3 = boto3.client('s3')
            dynamodb = boto3.client('dynamodb', region_name=region)
            bucket = event['Records'][0]['s3']['bucket']['name']
            key = event['Records'][0]['s3']['object']['key']
            
            print('Bucket:', bucket, 'Key:', key)
            csv_file = s3.get_object(Bucket=bucket, Key=key)
            record_list = csv_file['Body'].read().decode('utf-8').split('\n')
            csv_reader = csv.reader(record_list, delimiter=',', quotechar='"')
            
            firstrecord = True
            for row in csv_reader:
                if firstrecord:
                    firstrecord = False
                    continue
                
                # Extract row data
                id = row[0]
                case_number = row[1]
                date = row[2]
                block = row[3]
                iucr_code = row[4]
                location_desc = row[5]
                arrest = row[6]
                domestic = row[7]
                beat_num = row[8]
                district_code = row[9]
                ward_no = row[10]
                community_code = row[11]
                fbi_code = row[12]
                x_coordinate = row[13]
                y_coordinate = row[14]
                year = row[15]
                date_of_update = row[16]
                latitude = row[17]
                longitude = row[18]
                location = row[19]
                
                print('id:', id)
                
                # Add item to DynamoDB
                dynamodb.put_item(
                    TableName='Chicagocrimes',
                    Item={
                        'id': {'N': str(id)},
                        'case_number': {'S': str(case_number)},
                        'date': {'S': str(date)},
                        'block': {'S': str(block)},
                        'iucr_code': {'S': str(iucr_code)},
                        'location_desc': {'S': str(location_desc)},
                        'arrest': {'S': str(arrest)},
                        'domestic': {'S': str(domestic)},
                        'beat_num': {'N': str(beat_num)},
                        'district_code': {'N': str(district_code)},
                        'ward_no': {'N': str(ward_no)},
                        'community_code': {'N': str(community_code)},
                        'fbi_code': {'S': str(fbi_code)},
                        'x_coordinate': {'S': str(x_coordinate)},
                        'y_coordinate': {'S': str(y_coordinate)},
                        'year': {'N': str(year)},
                        'date_of_update': {'S': str(date_of_update)},
                        'latitude': {'S': str(latitude)},
                        'longitude': {'S': str(longitude)},
                        'location': {'S': str(location)}
                    }
                )
        except Exception as e:
            print(str(e))
        
        return {
            'statusCode': 200,
            'body': json.dumps('CSV to DynamoDB success')
        }

4. **Adjust Settings:**

  *  Increase the timeout and memory settings as needed (up to 15 minutes and 10 GB).

**Step 5: Load Data into Redshift**

1. **Create IAM Role for Redshift:**

  *  Create a role with policies for S3 full access and DynamoDB read access.

2. **Create Redshift Cluster:**

  *  Go to the Redshift console.

  *  Create a cluster and associate the IAM role created earlier.

3. **Create Table in Redshift:**

  *  Use the Query Editor to create a table for the crime data:
 
    CREATE TABLE crimedata (
        id INTEGER,
        arrest VARCHAR,
        beat_num INTEGER,
        block VARCHAR,
        case_number VARCHAR,
        community_code INTEGER,
        date VARCHAR,
        date_of_update VARCHAR,
        district_code INTEGER,
        domestic VARCHAR,
        fbi_code VARCHAR,
        iucr_code VARCHAR,
        latitude REAL,
        location VARCHAR,
        location_desc VARCHAR,
        longitude REAL,
        ward_no INTEGER,
        x_coordinate INTEGER,
        y_coordinate INTEGER,
        year INTEGER
    );

4. **Copy Data from DynamoDB to Redshift:**

  *  Execute the following command:

    COPY crimedata 
    FROM 'dynamodb://Chicagocrimes' 
    IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME' 
    READRATIO 50;

**Step 6: Perform Data Analysis**

1. **Analytical Queries:**

**Use Case 1:**

    SELECT date, COUNT(case_number) 
    FROM crimedata 
    GROUP BY date 
    ORDER BY date 
    LIMIT 20;

**Use Case 2:**

    SELECT date, district_code, COUNT(case_number) 
    FROM crimedata 
    GROUP BY date, district_code 
    ORDER BY date, district_code;

**Step 7: Use Spectrum to Access External Data**

1. **Create External Schema and Table:**

       CREATE EXTERNAL SCHEMA spectrum 
       FROM DATA CATALOG 
       DATABASE 'spectrum_crime_db' 
       IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME';
       
       CREATE EXTERNAL TABLE spectrum.disct_info (
           DISTRICT_CODE INTEGER,
           DISTRICT_NAME VARCHAR,
           ADDRESS VARCHAR,
           CITY VARCHAR,
           STATE VARCHAR,
           ZIP INTEGER,
           WEBSITE VARCHAR,
           PHONE VARCHAR,
           FAX VARCHAR,
           TTY VARCHAR,
           X_COORDINATE REAL,
           Y_COORDINATE REAL,
           LATITUDE REAL,
           LONGITUDE REAL,
           LOCATION VARCHAR
       )
       ROW FORMAT DELIMITED 
       FIELDS TERMINATED BY ',' 
       STORED AS TEXTFILE 
       LOCATION 's3://YOUR_BUCKET_NAME/Spectrum-Store/';

2. **Query the Spectrum Table:**

       SELECT COUNT(*) FROM spectrum.disct_info;
       SELECT * FROM spectrum.disct_info;

3. **Join Queries:**

       SELECT date, spectrum.disct_info.DISTRICT_NAME, COUNT(case_number) 
       FROM crimedata 
       JOIN spectrum.disct_info 
       ON crimedata.district_code = spectrum.disct_info.DISTRICT_CODE 
       GROUP BY date, spectrum.disct_info.DISTRICT_NAME 
       ORDER BY date, spectrum.disct_info.DISTRICT_NAME;

**Step 8: Unload Data from Redshift to S3**

1. **Create a New S3 Bucket for Unloading Data.**

2. **Unload Command:**

       UNLOAD ('SELECT * FROM crimedata WHERE district_code = 25') 
       TO 's3://YOUR_BUCKET_NAME' 
       IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME' 
       PARALLEL OFF;

3. **Check S3 Bucket for Unloaded Data.**

**Notes:**

  -  Replace YOUR_ACCOUNT_ID and YOUR_ROLE_NAME with your specific AWS account ID and role name.

  -  Customize the S3 bucket names and paths as needed for your implementation.
