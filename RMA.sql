SHOW TABLES;

-- Show all data from table RMA.
SELECT * FROM RMA;

-- Shows Number Of Returns by their reason
SELECT COUNT(*) AS NumOfReturns, Reason FROM RMA
Group BY Reason
ORDER BY NumOfReturns DESC;

-- Shows all returns by their Step
SELECT COUNT(*) AS NumOfReturns, Step FROM RMA
Group BY Step
ORDER BY NumOfReturns DESC;

-- Shows all returns by their Status
SELECT COUNT(*) AS NumOfReturns, Status FROM RMA
Group BY Status
ORDER BY NumOfReturns DESC;

-- Shows Number Of Returns by their reason and Status
SELECT COUNT(*) AS NumOfReturns, Reason, Status, Step FROM RMA
Group BY Reason, Status, Step
ORDER BY NumOfReturns DESC;

-- Shows details of wierd return in RMA table.
SELECT OrderID FROM RMA
WHERE Reason LIKE '%Defective%' AND Status LIKE 'Pending';

-- Shows all details of a wierd return in Orders table.
SELECT CustomerID FROM Orders WHERE OrderID = (SELECT OrderID FROM RMA
WHERE Reason LIKE '%Defective%' AND Status LIKE 'Pending');

-- Shows all details of the customer behind the wierd order.
SELECT * FROM Collaborators WHERE CollaboratorID = (SELECT CustomerID FROM Orders WHERE OrderID = (SELECT OrderID FROM RMA
WHERE Reason LIKE '%Defective%' AND Status LIKE 'Pending'));

