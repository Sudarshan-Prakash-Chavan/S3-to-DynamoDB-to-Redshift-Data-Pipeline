--On internal table
--Use Case 1:
SELECT date, COUNT(case_number) 
FROM crimedata 
GROUP BY date 
ORDER BY date 
LIMIT 20;

--Use Case 2:
SELECT date, district_code, COUNT(case_number) 
FROM crimedata 
GROUP BY date, district_code 
ORDER BY date, district_code;

--On External Table:
--Query 1:
SELECT COUNT(*) FROM spectrum.disct_info;
SELECT * FROM spectrum.disct_info;


--Query 2:
SELECT date, spectrum.disct_info.DISTRICT_NAME, COUNT(case_number) 
FROM crimedata 
JOIN spectrum.disct_info 
ON crimedata.district_code = spectrum.disct_info.DISTRICT_CODE 
GROUP BY date, spectrum.disct_info.DISTRICT_NAME 
ORDER BY date, spectrum.disct_info.DISTRICT_NAME;
