CREATE TABLE Churn (
   		id  SERIAL,
		CustomerID BIGINT,
		Surname Varchar(50),
		CreditScore INT,
		Geography Varchar(50),
		Gender Varchar(10),
		Age int,
		Tenure smallint,
		Balance int,
		NumOfProducts smallint,
		HasCrCard smallint,
		IsActiveMember smallint,
		EstimatedSalary int,
		Exited smallint
		
);

ALTER TABLE Churn
ALTER COLUMN Balance TYPE numeric(12,2),
ALTER COLUMN  EstimatedSalary TYPE numeric(12,2);