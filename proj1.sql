-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(ERA)
  FROM pitching; -- replace this line

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthyear
  FROM people
  WHERE weight > 300; -- replace this line

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE nameFirst LIKE '% %'
  ORDER BY nameFirst, nameLast ASC; -- replace this line

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height) as avg_height, COUNT(*) AS num_players
  FROM people
  GROUP BY birthYear
  ORDER BY birthYear ASC; -- replace this line

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height) as avg_height, COUNT(*) AS num_players
  FROM people
  GROUP BY birthYear
  HAVING avg_height > 70
  ORDER BY birthYear ASC; -- replace this line

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT t1.nameFirst, t1.nameLast, t1.playerID, t2.yearid
  FROM people AS t1 INNER JOIN 
  (SELECT * FROM halloffame
    WHERE inducted = 'Y') AS t2
  ON t1.playerID = t2.playerID
  ORDER BY 
	  t2.yearid DESC,
	  t1.playerID ASC; -- replace this line

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  WITH CA_collegeplayers AS (SELECT playerid AS playerID, t2.schoolID AS schoolID
    FROM collegeplaying AS t1 
    INNER JOIN (SELECT * FROM schools WHERE schoolState = 'CA') AS t2
    ON t1.schoolID = t2.schoolID), 

    playedcollege_CA AS (SELECT nameFirst, nameLast, t1.playerID AS playerID, schoolID
    FROM people AS t1
    INNER JOIN CA_collegeplayers AS t2
    ON t1.playerID = t2.playerID)

  SELECT nameFirst, nameLast, t1.playerID AS playerID, schoolID, yearid
  FROM playedcollege_CA AS t1
  INNER JOIN (SELECT * FROM halloffame
               WHERE inducted = 'Y') AS t2
  ON t1.playerID = t2.playerID
  ORDER BY 
	  yearid DESC,
    schoolID ASC,
	  playerID ASC; -- replace this line

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  WITH hof_inducted AS (SELECT t1.playerID AS playerID, nameFirst, nameLast
  FROM (SELECT * FROM halloffame WHERE inducted = 'Y') AS t1 INNER JOIN people
  ON t1.playerID = people.playerID)

  SELECT t1.playerID AS playerID, nameFirst, nameLast, schoolID
  FROM hof_inducted AS t1 LEFT JOIN collegeplaying AS t2
  ON t1.playerID = t2.playerID
  ORDER BY 
    playerID DESC,
    schoolID ASC; -- replace this line

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  WITH Top10AnnSlg AS(
    SELECT playerID,
    yearID,
    (((H-HR-H3B-H2B)+(2*H2B)+(3*H3B)+(4*HR))*1.0/AB) AS slg
    FROM batting
    GROUP BY playerID, yearID, teamID
    HAVING AB > 50
    ORDER BY 
      slg DESC,
      yearID ASC,
      playerID ASC
    LIMIT 10)

  SELECT people.playerID, nameFirst, nameLast, yearID, slg
  FROM people INNER JOIN Top10AnnSlg 
  ON people.playerID = Top10AnnSlg.playerID;
 -- replace this line



-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH LfBatting AS (
    SELECT playerID, 
    SUM(H) AS LH, 
    SUM(H2B) AS LH2B,
    SUM(H3B) AS LH3B,
    SUM(HR) AS LHR,
    SUM(AB) AS LAB
    FROM batting
    GROUP BY playerID
    HAVING LAB > 50),

    Top10LfSlug AS (
      SELECT playerID, 
      (((LH-LHR-LH3B-LH2B)+(2*LH2B)+(3*LH3B)+(4*LHR))*1.0/LAB) AS Lslg
      FROM LfBatting
      ORDER BY 
        Lslg DESC,
        playerID ASC
      LIMIT 10)

    SELECT people.playerID, nameFirst, nameLast, Lslg
    FROM Top10LfSlug INNER JOIN people
    ON Top10LfSlug.playerID = people.playerID;
    --replace this line


-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH LfBatting AS(
    SELECT playerID,
    SUM(H) AS LH,
    SUM(H2B) AS LH2B,
    SUM(H3B) AS LH3B,
    SUM(HR) AS LHR,
    SUM(AB) AS LAB
    FROM batting
    GROUP BY playerID
    HAVING LAB > 50),
    
    LfSlug AS (
      SELECT playerID,
      (((LH-LHR-LH3B-LH2B)+(2*LH2B)+(3*LH3B)+(4*LHR))*1.0/LAB) AS Lslg
      FROM LfBatting),

    AboveWMays AS (
      SELECT *
      FROM LfSlug
      WHERE Lslg > (SELECT Lslg FROM LfSlug WHERE playerID = 'mayswi01')
    )


    SELECT nameFirst, nameLast, Lslg
    FROM AboveWMays INNER JOIN people
    ON AboveWMays.playerID = people.playerID;
     -- replace this line


-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID,
  MIN(salary),
  MAX(salary),
  AVG(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID ASC-- replace this line
;


-- Helper table for 4ii
DROP TABLE IF EXISTS binids;
CREATE TABLE binids(binid);
INSERT INTO binids VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH summary2016 AS(
    SELECT yearID,
    MIN(salary) AS minSalary,
    MAX(salary) AS maxSalary
    FROM salaries
    WHERE yearID = 2016
    GROUP BY yearID), 

  binWidth AS (
    SELECT (maxSalary-minSalary)/10 AS width
    FROM summary2016),

  equalBins AS(
    SELECT binid, 
    
    CASE 
    WHEN binid = 0 THEN (SELECT minSalary FROM summary2016)
    WHEN binid = 1 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 2 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 3 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 4 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 5 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 6 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 7 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 8 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*binid)
    WHEN binid = 9 THEN ((SELECT maxSalary FROM summary2016)-(SELECT width FROM binWidth))
    ELSE 0
    END AS low,

    CASE 
    WHEN binid = 0 THEN ((SELECT minSalary FROM summary2016)+(SELECT width FROM binWidth))
    WHEN binid = 1 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 2 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 3 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 4 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 5 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 6 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 7 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 8 THEN (SELECT minSalary FROM summary2016) + ((SELECT width FROM binWidth)*(binid+1))
    WHEN binid = 9 THEN (SELECT maxSalary FROM summary2016)
    ELSE 0
    END AS high
    FROM binids),

  salaries2016 AS (SELECT * FROM salaries
    WHERE yearID = 2016
    AND salary >= (SELECT low FROM equalBins WHERE binid = 0)
  ),

  binnedSalaries AS (SELECT binid,
    COUNT(*) AS salaries_count
    FROM salaries2016 JOIN equalBins
    ON salary >= low
    AND CASE
    WHEN binid < 9 THEN high
    WHEN binid = 9 THEN high*high
    END > salary
    GROUP BY binid)

  SELECT equalBins.binid, low, high, salaries_count 
  FROM binnedSalaries INNER JOIN equalBins
  ON binnedSalaries.binid = equalBins.binid;
     -- replace this line


-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH salarySummary AS (SELECT yearID,
  MIN(salary) AS min_salary,
  MAX(salary) AS max_salary, 
  AVG(salary) AS avg_salary
  FROM salaries
  GROUP BY yearID)


  SELECT yearID,
  min_salary-LAG(min_salary, 1) OVER (ORDER BY yearID ASC) AS mindiff,
  max_salary-LAG(max_salary,1) OVER (ORDER BY yearID ASC) AS maxdiff,
  avg_salary-LAG(avg_salary,1) OVER (ORDER BY yearID ASC) AS avgdiff
  FROM salarySummary
  LIMIT (SELECT COUNT(*) FROM salarySummary) OFFSET 1;
 -- replace this line


-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS 
  WITH salarySummary AS (SELECT yearID,
  MIN(salary) AS min_salary,
  MAX(salary) AS max_salary, 
  AVG(salary) AS avg_salary
  FROM salaries
  GROUP BY yearID),

  maxsal00to01 AS (SELECT * FROM salaries
  WHERE salary = 
  CASE 
  WHEN yearID = 2000 THEN (SELECT max_salary FROM salarySummary WHERE yearID = 2000)
  WHEN yearID = 2001 THEN (SELECT max_salary FROM salarySummary WHERE yearID = 2001)
  END
  )

  SELECT people.playerID,
  nameFirst,
  nameLast,
  salary,
  yearID
  FROM maxsal00to01 INNER JOIN people 
  ON maxsal00to01 .playerID = people.playerID;-- replace this line

-- Question 4v
CREATE VIEW q4v(team, diffAvg)
 AS  
  WITH allstar2016 AS (SELECT *
    FROM allstarfull WHERE yearID = 2016)

  SELECT allstar2016.teamID, 
  MAX(salary)-MIN(salary) AS diffAvg
  FROM allstar2016 INNER JOIN (SELECT *
  FROM salaries WHERE yearID = 2016) AS t2
  ON allstar2016.playerID = t2.playerID
  GROUP BY allstar2016.teamID;
 -- replace this line


