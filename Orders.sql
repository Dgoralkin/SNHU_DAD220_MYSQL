SELECT * FROM Orders;

-- Num Of Orders
SELECT COUNT(*) AS NumOfOrders FROM Orders;

-- All orders By SKU
SELECT SKU, Description, COUNT(*) AS Ordered FROM Orders
GROUP BY SKU, Description
ORDER BY Ordered DESC;
