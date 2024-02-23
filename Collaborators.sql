-- Shows a list of all the states with orders
SELECT DISTINCT State FROM Collaborators;
-- Create a view table AllStates
CREATE VIEW AllStates AS SELECT DISTINCT State FROM Collaborators;

-- Show all instances from All States.
SELECT * FROM AllStates;
SELECT COUNT(*) AS NumOfStates FROM AllStates;

SELECT State, COUNT(*) AS customers FROM Collaborators
GROUP BY State
ORDER BY customers DESC;