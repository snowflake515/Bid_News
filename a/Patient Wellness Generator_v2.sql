/*	Patient Wellness Generator
	Code to find Patient Wellness Inclusion Data
	UPDATE:		05/12/2024	PAB		New

*/
--- For Repetitious Testing Only


DELETE FROM Wellness_DataArchive.dbo.PWHistory
/*
For your initialization
USE Wellness_eCastEMR_Data

SELECT TOP(10) * FROM Appointments ORDER BY Appointments_ID DESC

--- Hard-coded variables - need to be replaced with actual variables from your code
Appointments		508610
Patient				1004069571
Provider			3
Org					1

SELECT TOP(10) * FROM EncounterHistory ORDER BY Encounter_ID DESC
Encounter			656531

---This query is hard coded for the following variables..your code needs to grab the correct values and substitute them.
Appointments		508610
Patient				1004069571
Encounter			656531


*/

---SELECT * FROM Wellness_DataArchive.dbo.PWMaster
---SELECT * FROM Wellness_DataArchive.dbo.PWMasterTBots

PRINT 'Setting up temp tables...'
USE Wellness_eCastEMR_Data
GO
DROP Table Wellness_eCastEMR_Data.dbo.tempPWTBots
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE Wellness_eCastEMR_Data.[dbo].[tempPWTBots](
	[tempPWTBots_ID] [int] IDENTITY(1,1) NOT NULL,
	[TBot] varchar(10) )
GO
CREATE INDEX tempPWTBots_idx
  ON Wellness_eCastEMR_Data.dbo.tempPWTBots(TBot)
GO

---SELECT * FROM EncounterHistory ORDER BY Encounter_ID DESC
---SELECT * FROM EncounterHistory WHERE Encounter_ID = 656443 AND Patient_ID = 1004373998

PRINT 'Got the Encounter_ID and now filling up temp table...'
SET ANSI_PADDING OFF

DECLARE @Patient_ID INT, @Encounter_ID INT, @n INT, @max INT, 
        @PWCategory Varchar(50), @PWService Varchar(50), @PWCode Varchar(10),@PWBenefit Varchar(50),@PWNeeded SmallInt,
		@PWMaster_ID INT, @TDate DATE, @PWSortOrder SMALLINT

/* Calling code needs to run these two lines before calling this SQL Code */
SELECT @Encounter_ID	= 656531
SELECT @Patient_ID		= 1004069571


--- For LIVE Production (set Hidden Flags and get rid of Testing DELETE statement above)
PRINT 'Setting PWHistory flags...'
UPDATE Wellness_DataArchive.dbo.PWHistory
SET Hidden		= 1 WHERE 
Patient_ID		= @Patient_ID AND 
Encounter_ID	= @Encounter_ID

/* End of code needed by calling code */

/* This is a required value for PWHistory */
SELECT @TDate	= GetDate()  

/* This block will fetch the vitals and INSERT them into PWHistory*/
PRINT 'Inserting first 4 rows of PWHistory...'
SELECT * FROM Wellness_DataArchive.dbo.PWHistory
DELETE FROM Wellness_DataArchive.dbo.PWHistory
INSERT INTO Wellness_DataArchive.dbo.PWHistory
(PWMaster_ID, Patient_ID, Encounter_ID, PWDate, PWNeeded, PWValue, SortOrder, Hidden)
VALUES
(1,@Patient_ID,@Encounter_ID,@TDate,0,'Weight:    ',10,0),
(2,@Patient_ID,@Encounter_ID,@TDate,0,'Height:    ',20,0),
(3,@Patient_ID,@Encounter_ID,@TDate,0,'Systolic:  ',30,0),
(4,@Patient_ID,@Encounter_ID,@TDate,0,'Diastolic: ',40,0)
PRINT 'Now updating first 4 rows of PWHistory with correct vitals values...'
--- Weight
UPDATE PWH
SET PWH.PWValue = E3I.ETL3Input
FROM Wellness_DataArchive.dbo.PWHistory PWH
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL3Input E3I ON PWH.Encounter_ID = E3I.Encounter_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML3 T3 ON E3I.TML3_ID = T3.TML3_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML2 T2 ON T3.TML2_ID = T2.TML2_ID
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL1 E1 ON T2.TML1_ID = E1.TML1_ID
WHERE PWH.PWMaster_ID = 1
AND E1.Encounter_ID = @Encounter_ID
AND T2.TML2_HeaderMaster_ID = 33
AND T3.TML3_TBotMaster_ID = 424;
--- Height
UPDATE PWH
SET PWH.PWValue = E3I.ETL3Input
FROM Wellness_DataArchive.dbo.PWHistory PWH
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL3Input E3I ON PWH.Encounter_ID = E3I.Encounter_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML3 T3 ON E3I.TML3_ID = T3.TML3_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML2 T2 ON T3.TML2_ID = T2.TML2_ID
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL1 E1 ON T2.TML1_ID = E1.TML1_ID
WHERE PWH.PWMaster_ID = 2
AND E1.Encounter_ID = @Encounter_ID
AND T2.TML2_HeaderMaster_ID = 33
AND T3.TML3_TBotMaster_ID = 423;
--- Systolic
UPDATE PWH
SET PWH.PWValue = E3I.ETL3Input
FROM Wellness_DataArchive.dbo.PWHistory PWH
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL3Input E3I ON PWH.Encounter_ID = E3I.Encounter_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML3 T3 ON E3I.TML3_ID = T3.TML3_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML2 T2 ON T3.TML2_ID = T2.TML2_ID
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL1 E1 ON T2.TML1_ID = E1.TML1_ID
WHERE PWH.PWMaster_ID = 3
AND E1.Encounter_ID = @Encounter_ID
AND T2.TML2_HeaderMaster_ID = 33
AND T3.TML3_TBotMaster_ID = 425;
--- Diastolic
UPDATE PWH
SET PWH.PWValue = E3I.ETL3Input
FROM Wellness_DataArchive.dbo.PWHistory PWH
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL3Input E3I ON PWH.Encounter_ID = E3I.Encounter_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML3 T3 ON E3I.TML3_ID = T3.TML3_ID
INNER JOIN Wellness_eCastEMR_Template.dbo.TML2 T2 ON T3.TML2_ID = T2.TML2_ID
INNER JOIN Wellness_eCastEMR_Data.dbo.ETL1 E1 ON T2.TML1_ID = E1.TML1_ID
WHERE PWH.PWMaster_ID = 4
AND E1.Encounter_ID = @Encounter_ID
AND T2.TML2_HeaderMaster_ID = 33
AND T3.TML3_TBotMaster_ID = 426;


/* Mow insert rows into tempPWTBots */
PRINT 'Setting values in tempPWTBots...'
INSERT INTO Wellness_eCastEMR_Data.[dbo].[tempPWTBots]
SELECT CONCAT(TM.TML3_TBotMaster_ID,'-',TM.TML3_TBotData) FROM Wellness_eCastEMR_Data.dbo.ETL3 ET
JOIN Wellness_eCastEMR_Template.dbo.TML3 TM ON ET.TML3_ID = TM.TML3_ID
JOIN eCastMaster.dbo.TBotMaster TB ON TM.TML3_TBotMaster_ID = TB.TBotMaster_ID
WHERE ET.Encounter_ID	= @Encounter_ID


---SELECT * FROM Wellness_eCastEMR_Data.[dbo].[tempPWTBots]

--- You need to set the Hidden flags in PWHistory for this patient only
---SELECT * FROM Wellness_eCastEMR_Data.dbo.tempPWTBots ORDER BY TBot

PRINT 'Starting the loop through PWMaster...'
SELECT @n = 5  --- Skip first 4 rows which are Vitals
SELECT @max = COUNT(*) FROM Wellness_DataArchive.dbo.PWMaster
WHILE @n <= @max
  BEGIN
    PRINT 'Looping through PWMaster...'
	  --- Load up your variables for the INSERT into PWHistory
	  SELECT  
	    @PWMaster_ID		= PWMaster_ID,
		@PWCategory			= Category,
		@PWService			= Service,
		@PWCode 			= Code,
		@PWBenefit			= Benefit,
		@PWNeeded			= 0,
		@PWSortOrder		= SortOrder
		FROM Wellness_DataArchive.dbo.PWMaster WHERE PWMaster_ID = @n
      ---
	  --- Now run the INTERSECT of the two SELECTS and if the results is not zero you have a HIT - so then you INSERT that into PWHistory
	    SELECT TBot FROM Wellness_DataArchive.dbo.PWMasterTBots TB WHERE TB.PWMaster_ID = @n
        INTERSECT
        SELECT TBot FROM Wellness_eCastEMR_Data.dbo.TempPWTBots TTB
		--- Check to see if the INTERSECT resulted in some rows found.  You will write a row for every PWMaster record but it's the "PWNeeded" value that is 0/1
		IF @@ROWCOUNT <> 0  -- If you DID find a hit, you want to alert the patient that this category is needed this year
		  BEGIN  -- If you get here you want to set @PWNeeded to 1
		    SELECT @PWNeeded = 1
		  END
		PRINT 'Adding the Patient Wellness Item as "Required" or "Not Required" to PWHistory'
		INSERT INTO Wellness_DataArchive.dbo.PWHistory
		(PWMaster_ID,Patient_ID,Encounter_ID,PWDate,PWNeeded,PWValue,SortOrder,Hidden)
		VALUES
		(@PWMaster_ID,@Patient_ID,@Encounter_ID,@TDate,@PWNeeded,'',@PWSortOrder,0)
		--- Now you have ONE row in PWHistory matching every row in PWMaster, with the PWNeeded flags set either 0 or 1
    SELECT @n = @n + 1  -- Bump the counter that pushes through CTracksMaster's rows
  END
PRINT 'While Loop through PWMaster complete...'

/*  The "Magic Query"  - Run this manually to see the PWHistory table linked to the PWMaster table that gives you the values you need...

SELECT PWM.PWMaster_ID,PWM.Category,PWM.Service,PWM.Code,PWM.Benefit,PWH.PWValue,PWH.PWNeeded,PWM.SortOrder
FROM Wellness_DataArchive.dbo.PWHistory PWH
JOIN Wellness_DataArchive.dbo.PWMaster PWM
ON PWH.PWMaster_ID = PWM.PWMaster_ID
WHERE Patient_ID = 1004069571 AND Encounter_ID = 656531 AND
(PWH.Hidden IS NULL or PWH.Hidden = 0)
ORDER BY PWH.SortOrder

*/





