COPY crimedata 
FROM 'dynamodb://Chicagocrimes' 
IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME' 
READRATIO 50;
