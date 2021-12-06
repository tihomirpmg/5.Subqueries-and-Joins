USE SoftUni
GO

/*---------------------------------------------------*/
SELECT TOP 5 e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText FROM Employees AS e
JOIN Addresses AS a
ON a.AddressID = e.AddressID
ORDER BY a.AddressID 

/*---------------------------------------------------*/
SELECT TOP 50 FirstName, LastName, t.Name AS Town, AddressText FROM Employees AS e
JOIN Addresses AS a
ON a.AddressID = e.AddressID
JOIN Towns AS t
ON t.TownID = a.TownID
ORDER BY FirstName, LastName

/*---------------------------------------------------*/
SELECT EmployeeID, FirstName, LastName, d.Name AS DepartmentName FROM Employees AS e
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID

/*---------------------------------------------------*/
SELECT TOP 5 e.EmployeeID, e.FirstName, e.Salary, d.Name AS DepartmentName FROM Employees AS e
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID

/*---------------------------------------------------*/
SELECT DISTINCT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e
RIGHT OUTER JOIN EmployeesProjects AS ep
ON e.EmployeeID NOT IN(SELECT DISTINCT EmployeeID FROM EmployeesProjects)
ORDER BY e.EmployeeID

/*---------------------------------------------------*/
SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS DeptName FROM Employees AS e
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID AND e.HireDate > '1999-01-01' AND (d.Name = 'Sales' OR d.Name = 'Finance')
ORDER BY e.HireDate

/*---------------------------------------------------*/
SELECT TOP 5 e.EmployeeID, e.FirstName, p.Name AS ProjectName FROM Employees AS e
JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p
ON ep.ProjectID = p.ProjectID AND p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

/*---------------------------------------------------*/
SELECT e.EmployeeID, e.FirstName,
	CASE
		WHEN p.StartDate >= '2005-01-01' THEN NULL
		ELSE p.Name
	END AS ProjectName
	 FROM Employees AS e
JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID AND e.EmployeeID = 24
JOIN Projects AS p
ON p.ProjectID = ep.ProjectID

/*---------------------------------------------------*/
SELECT e.EmployeeID, e.FirstName, e.ManagerID, e2.FirstName AS ManagerName FROM Employees AS e
JOIN Employees AS e2
ON e2.EmployeeID = e.ManagerID AND e.ManagerID IN(3, 7)
ORDER BY e.EmployeeID

/*---------------------------------------------------*/
SELECT TOP 50 e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	   CONCAT(e2.FirstName, ' ', e2.LastName) AS ManagerName, d.Name AS DepartmentName FROM Employees AS e
JOIN Employees AS e2
ON e2.EmployeeID = e.ManagerID
JOIN Departments AS d
ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID

/*---------------------------------------------------*/
SELECT MIN(AverageSalaryByDepartment) AS MinAverageSalary FROM
	(SELECT AVG(Salary) AS AverageSalaryByDepartment FROM Employees
	GROUP BY DepartmentID) AS AvgSalaries

/*---------------------------------------------------*/
USE Geography
GO

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Countries AS c
JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode AND c.CountryCode = 'BG'
JOIN Mountains AS m
ON m.Id = mc.MountainId
JOIN Peaks AS p
ON p.MountainId = mc.MountainId AND p.Elevation > 2835
ORDER BY p.Elevation DESC

/*---------------------------------------------------*/
SELECT c.CountryCode, COUNT(mc.MountainId) AS MountainRanges FROM Countries AS c
JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode AND c.CountryName IN ('United States', 'Russia', 'Bulgaria')
GROUP BY c.CountryCode

/*---------------------------------------------------*/
SELECT TOP 5 c.CountryName, r.RiverName FROM Rivers AS r
JOIN CountriesRivers AS rc
ON r.Id = rc.RiverId
RIGHT OUTER JOIN Countries AS c
ON c.CountryCode = rc.CountryCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName
/*---------------------------------------------------*/

SELECT rankedCurrencies.ContinentCode, rankedCurrencies.CurrencyCode, rankedCurrencies.Count
FROM (
SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS [Count], DENSE_RANK() OVER (PARTITION BY c.ContinentCode ORDER BY COUNT(c.CurrencyCode) DESC) AS [rank] 
FROM Countries AS c
GROUP BY c.ContinentCode, c.CurrencyCode) AS rankedCurrencies
WHERE rankedCurrencies.rank = 1 and rankedCurrencies.Count > 1
/*---------------------------------------------------*/
SELECT COUNT(c.CountryCode) AS [CountryCode]
FROM Countries AS c
LEFT OUTER JOIN MountainsCountries AS m ON c.CountryCode = m.CountryCode
WHERE m.MountainId IS NULL
/*---------------------------------------------------*/
SELECT TOP(5) c.CountryName, MAX(p.Elevation) AS [HighestPeakElevation], MAX(r.Length) AS [LongestRiverLength]
FROM Countries AS c
LEFT OUTER JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT OUTER JOIN Peaks AS p ON p.MountainId = mc.MountainId
LEFT OUTER JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT OUTER JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY [HighestPeakElevation] DESC, [LongestRiverLength] DESC, c.CountryName
/*---------------------------------------------------*/
SELECT TOP (5) WITH TIES c.CountryName, ISNULL(p.PeakName, '(no highest peak)') AS 'HighestPeakName', ISNULL(MAX(p.Elevation), 0) AS 'HighestPeakElevation', ISNULL(m.MountainRange, '(no mountain)')
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName, p.PeakName, m.MountainRange
ORDER BY c.CountryName, p.PeakName
