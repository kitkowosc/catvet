day2.
1. new funcionality can be add. f.e. owner which has lot of animals(patients)
2. also doctor can have access to data about specific pacient
3.

## Day 2 curl commands:

GET all patients:
curl -i localhost:8080/patients

GET unknown id -> 404:
curl -i localhost:8080/patients/999

POST valid cat -> 201:
curl -i -X POST localhost:8080/patients -H 'Content-Type: application/json' -d '{"name":"TestCat","breed":"tabby"}'

POST invalid cat (blank name) -> 400:
curl -i -X POST localhost:8080/patients -H 'Content-Type: application/json' -d '{"name":"","breed":""}'

PUT update existing patient:
curl -i -X PUT localhost:8080/patients/1 -H 'Content-Type: application/json' -d '{"name":"RyszardUpdated","breed":"cat"}'

DELETE patient -> 204:
curl -i -X DELETE localhost:8080/patients/1

## Day 3 curl commands:

addVisit for patient:
curl -s -X POST http://localhost:8080/patients/1/records 
-H 'Content-Type: application/json' 
-d '{"date":"2026-07-09","type":"0","notes":"gruby brzuszeczek"}