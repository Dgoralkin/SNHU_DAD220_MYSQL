-- DAD 220 Project Two - Daniel Gorelkin Feb/22/2024

-- Show existing databases.
SHOW DATABASES;

-- Delete existing database before building a new one.
DROP DATABASE IF EXISTS QuantigrationUpdates;

-- Initial database "QuantigrationUpdates".
CREATE DATABASE QuantigrationUpdates;
SHOW DATABASES;

-- Choose database to work with.
USE QuantigrationUpdates;

-- Create table "Collaborators".
CREATE TABLE Collaborators (
  CollaboratorID int NOT NULL,
  FirstName varchar(25) DEFAULT NULL,
  LastName varchar(25) DEFAULT NULL,
  Street varchar(50) DEFAULT NULL,
  City varchar(50) DEFAULT NULL,
  State varchar(25) DEFAULT NULL,
  ZipCode varchar(10) DEFAULT NULL,
  Telephone varchar(15) DEFAULT NULL,
  PRIMARY KEY (CollaboratorID)
);

-- Show the table's "Collaborators" specs.
DESCRIBE Collaborators;

-- Create table "Orders".
CREATE TABLE Orders (
  OrderID int NOT NULL,
  CustomerID int NOT NULL,
  SKU varchar(20) DEFAULT NULL,
  Description varchar(75) DEFAULT NULL,
  PRIMARY KEY (OrderID),
  KEY CustomerID (CustomerID),
  CONSTRAINT Orders_errorOnFk FOREIGN KEY (CustomerID) REFERENCES Collaborators (CollaboratorID) ON DELETE CASCADE ON UPDATE RESTRICT
);

-- Show the table's "Orders" specs.
DESCRIBE Orders;

-- Create table "RMA".
CREATE TABLE RMA (
  RMAID int NOT NULL,
  OrderID int NOT NULL,
  Step varchar(50) DEFAULT NULL,
  Status varchar(15) DEFAULT NULL,
  Reason varchar(15) DEFAULT NULL,
  PRIMARY KEY (RMAID),
  KEY OrderID (OrderID),
  CONSTRAINT RMA_errorOnFk FOREIGN KEY (OrderID) REFERENCES Orders (OrderID) ON DELETE CASCADE ON UPDATE RESTRICT
);

-- Show the table's "RMA" specs.
DESCRIBE RMA;

-- Read directory path
SELECT @@secure_file_priv;

-- Load data from CSV file "customers.csv" into the table Customers.
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv' 
LOAD DATA INFILE '/home/codio/workspace/customers.csv'
INTO TABLE Collaborators 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 ROWS;

SELECT * FROM Collaborators
LIMIT 1;

-- Load data from CSV file "orders.csv" into the table "Orders".
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv' 
LOAD DATA INFILE '/home/codio/workspace/orders.csv'
INTO TABLE Orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 ROWS;

SELECT * FROM Orders
LIMIT 1;

-- Load data from CSV file "rma.csv" into the table "RMA".
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rma.csv'
LOAD DATA INFILE '/home/codio/workspace/rma.csv'
INTO TABLE RMA 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 0 ROWS;

SELECT * FROM RMA
LIMIT 1;

-- ********** Module 7 **********

-- Shows total number of returned items
SELECT COUNT(RMAID) AS TotalNumOfReturns FROM RMA;

-- Show a list of states that have returns
SELECT COUNT(DISTINCT State) AS StatesWithReturns FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID;

-- Shows Number Of Returns by their reason and their percentage(rounded)
SELECT Reason, COUNT(*) AS NumOfReturns, ROUND((COUNT(*) / (SELECT COUNT(RMAID) FROM RMA) * 100)) AS PercentageOfReturns
FROM RMA
Group BY Reason
ORDER BY NumOfReturns DESC;

-- Validate SKUs are correlated with item's description
SELECT COUNT(*) AS NumOfOrders, SKU, Description FROM Orders
GROUP BY Description, SKU
ORDER BY Description DESC;

-- Shows Returns by State with % of returnes
SELECT State, COUNT(*) AS Frequency, (COUNT(*) / (SELECT COUNT(RMAID) FROM RMA) * 100) AS PercentageOfReturns
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
GROUP BY State
ORDER BY Frequency DESC;

-- Shows the total of all RMAs
SELECT COUNT(RMAID) AS total_RMAs FROM RMA;

-- Shows the amount of returned products and their percentage.
SELECT Description, COUNT(*) AS Returns, (COUNT(*) / (SELECT COUNT(RMAID) FROM RMA) * 100) AS ReturnPercentage 
FROM Orders INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
GROUP BY Description
ORDER BY Returns DESC;

-- Create View Table "ItemReturnPercentage"
CREATE VIEW ItemReturnPercentage AS
SELECT Description, COUNT(*) AS Returns, (COUNT(*) / (SELECT COUNT(RMAID) FROM RMA) * 100) AS ReturnPercentage 
FROM Orders INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
GROUP BY Description
ORDER BY Returns DESC;

-- Show Average of return rate
SELECT AVG(ReturnPercentage) AS AverageReturnRate FROM ItemReturnPercentage;

-- Show all returned items that their return rate is above the average.
SELECT * FROM ItemReturnPercentage AS ITMRT
WHERE ReturnPercentage > (SELECT AVG(ReturnPercentage) FROM ItemReturnPercentage);

/* Shows the return number of the "Basic Switch 10/100/1000 BaseT 48 port" and
	"Enterprise Switch 40GigE SFP+ 48 port" from each state. */
SELECT State, Description, COUNT(*) AS Returnes
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Orders.Description LIKE '%Basic Switch 10/100/1000 BaseT 48 port%'
OR Orders.Description LIKE '%Enterprise Switch 40GigE SFP+ 48 port%'
GROUP BY State, Description
ORDER BY State, Description, Returnes DESC;

-- Shows what items were returned from "Massachusetts".
SELECT Description, COUNT(*) AS Returnes
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE State LIKE '%Massachusetts%'
GROUP BY Description
ORDER BY Returnes DESC;

-- Perform the same sample for "Alabama".
SELECT Description, COUNT(*) AS Returnes
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE State LIKE '%Alabama%'
GROUP BY Description
ORDER BY Returnes DESC;

-- ****************** Analyzis of Massachusetts ****************************

-- Remove view table "ReturnesState" If exists.
DROP VIEW IF EXISTS QuantigrationUpdates.ReturnesState;

-- Create view table "ReturnesState" that stores the total number of returns from each state.
CREATE VIEW ReturnesState AS
SELECT State, COUNT(*) AS Returns
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
GROUP BY State
ORDER BY Returns DESC;

-- Show how many items in total were returned from MA.
SELECT Returns FROM ReturnesState 
WHERE State LIKE '%Massachusetts%';

-- Remove view table "MA_ReturnBreakDown" If exists.
DROP VIEW IF EXISTS QuantigrationUpdates.MA_ReturnBreakDown;

-- Create view table that srores the reasons and percentage for the returns rates from Massachusetts.
CREATE VIEW MA_ReturnBreakDown AS
SELECT Reason, COUNT(*) AS NumOfReturns, ((COUNT(*) / (SELECT Returns FROM ReturnesState 
WHERE State LIKE '%Massachusetts%')) * 100) AS ReturnPercent
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Collaborators.State LIKE '%Massachusetts%'
Group BY Reason
ORDER BY NumOfReturns DESC;

-- Show Table MA_ReturnBreakDown of reason for returnes from MA.
SELECT * FROM MA_ReturnBreakDown;

-- Shows the number of the total "defective" returns from MA.
SELECT NumOfReturns FROM MA_ReturnBreakDown
WHERE Reason LIKE '%Defective%';

-- Show data on why "Basic Switch 10/100/1000 BaseT 48 port" were returned from MA.
SELECT Reason, COUNT(*) AS NumOfReturns, ((COUNT(*) / (SELECT NumOfReturns FROM MA_ReturnBreakDown
WHERE Reason LIKE '%Defective%')) * 100) AS ReturnPercent
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Orders.Description LIKE '%Basic Switch 10/100/1000 BaseT 48 port%'
AND Collaborators.State LIKE '%Massachusetts%'
Group BY Reason
ORDER BY Reason, NumOfReturns DESC;

-- ****************** Analyzis of Alabama ****************************

-- Show how many items in total were returned from AL.
SELECT Returns FROM ReturnesState 
WHERE State LIKE '%Alabama%';

-- Remove view table "AL_ReturnBreakDown" If exists.
DROP VIEW IF EXISTS QuantigrationUpdates.AL_ReturnBreakDown;

-- Shows the reasons for high returns rates from Alabama.
CREATE VIEW AL_ReturnBreakDown AS
SELECT Reason, COUNT(*) AS NumOfReturns, ((COUNT(*) / (SELECT Returns FROM ReturnesState 
WHERE State LIKE '%Alabama%')) * 100) AS ReturnPercent
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Collaborators.State LIKE '%Alabama%'
Group BY Reason
ORDER BY NumOfReturns DESC;

-- Show Table AL_ReturnBreakDown of reason for returnes from MA;
SELECT * FROM AL_ReturnBreakDown;

-- Shows the number of "defective" returns from Alabama
SELECT NumOfReturns FROM AL_ReturnBreakDown
WHERE Reason LIKE '%Defective%';

-- Show data on why "Basic Switch 10/100/1000 BaseT 48 port" wsa returned from MA.
SELECT Reason, COUNT(*) AS NumOfReturns, ((COUNT(*) / (SELECT NumOfReturns FROM MA_ReturnBreakDown
WHERE Reason LIKE '%Defective%')) * 100) AS ReturnPercent
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Orders.Description LIKE '%Basic Switch 10/100/1000 BaseT 48 port%'
AND Collaborators.State LIKE '%Massachusetts%'
Group BY Reason
ORDER BY Reason, NumOfReturns DESC;

-- Show data on why "Basic Switch 10/100/1000 BaseT 48 port" wsa returned from AL.
SELECT Reason, COUNT(*) AS NumOfReturns, ((COUNT(*) / (SELECT NumOfReturns FROM AL_ReturnBreakDown
WHERE Reason LIKE '%Defective%')) * 100) AS ReturnPercent
FROM Orders
INNER JOIN RMA ON RMA.OrderID = Orders.OrderID
INNER JOIN Collaborators ON Collaborators.CollaboratorID = Orders.CustomerID
WHERE Orders.Description LIKE '%Basic Switch 10/100/1000 BaseT 48 port%'
AND Collaborators.State LIKE '%Alabama%'
Group BY Reason
ORDER BY Reason, NumOfReturns DESC;