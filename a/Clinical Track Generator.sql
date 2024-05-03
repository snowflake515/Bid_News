USE Wellness_eCastEMR_Data
DROP Table Wellness_eCastEMR_Data.dbo.tempTBots
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
CREATE TABLE Wellness_eCastEMR_Data.[dbo].[tempTBots](
	[tempTBots_ID] [int] IDENTITY(1,1) NOT NULL,
	[TBot] varchar(10) )
CREATE INDEX tempTBots_idx
  ON Wellness_eCastEMR_Data.dbo.tempTBots(TBot)

PRINT 'Got the Encounter_ID and now filling up temp table...'
SET ANSI_PADDING OFF
DECLARE @Patient_ID INT, @Encounter_ID INT, @n INT, @max INT, 
        @CTrackName Varchar(50), @CTrackQty Varchar(50), @CTrackFreq Varchar(50),
		@CTrackMaster_ID INT, @TDate DATE, @SortOrder SMALLINT

SELECT @Encounter_ID	= 654681
SELECT @Patient_ID		= 1000641403

UPDATE Wellness_DataArchive.dbo.CTracksHistory
SET Hidden		= 1 WHERE 
Patient_ID		= @Patient_ID AND 
Encounter_ID	= @Encounter_ID

SELECT @TDate			= GetDate() 
INSERT INTO Wellness_eCastEMR_Data.[dbo].[tempTBots]
SELECT CONCAT(TM.TML3_TBotMaster_ID,'-',TM.TML3_TBotData) FROM Wellness_eCastEMR_Data.dbo.ETL3 ET
JOIN Wellness_eCastEMR_Template.dbo.TML3 TM ON ET.TML3_ID = TM.TML3_ID
JOIN eCastMaster.dbo.TBotMaster TB ON TM.TML3_TBotMaster_ID = TB.TBotMaster_ID
WHERE ET.Encounter_ID	= @Encounter_ID
SELECT @n = 1
SELECT @max = COUNT(*) FROM Wellness_DataArchive.dbo.CTracksMaster
WHILE @n <= @max
  BEGIN
	  SELECT  
	    @CTrackMaster_ID	= CTrackMaster_ID,
		@CTrackName			= CTrackName,
		@CTrackQty			= CTrackQty,
		@CTrackFreq			= CTrackFreq,
		@SortOrder			= SortOrder
		FROM Wellness_DataArchive.dbo.CTracksMaster WHERE CTrackMaster_ID = @n
	    SELECT TBot FROM Wellness_DataArchive.dbo.CTracksMasterTBots TB WHERE TB.CTracksMaster_ID = @n
        INTERSECT
        SELECT TBot FROM Wellness_eCastEMR_Data.dbo.TempTBots TTB
		IF @@ROWCOUNT <> 0
		  BEGIN
		    PRINT 'Adding the Clinical Track to CTracksHistory'
			INSERT INTO Wellness_DataArchive.dbo.CTracksHistory
			(CTrackMaster_ID,Patient_ID,Encounter_ID,CTrackDate,CTrackQty,CTrackFreq,SortOrder,Hidden)
			VALUES
			(@CTrackMaster_ID,@Patient_ID,@Encounter_ID,@TDate,@CTrackQty,@CTrackFreq,@SortOrder,0)
		  END
    SELECT @n = @n + 1
  END

SELECT CTM.CTrackMaster_ID,CTM.CTrackName,CTH.CTrackQty,CTH.CTrackFreq,CTH.SortOrder
FROM Wellness_DataArchive.dbo.CTracksHistory CTH
JOIN Wellness_DataArchive.dbo.CTracksMaster CTM
ON CTH.CTrackMaster_ID = CTM.CTrackMaster_ID
WHERE Patient_ID = @Patient_ID AND Encounter_ID = @Encounter_ID AND 
(CTH.Hidden IS NULL or CTH.Hidden = 0)
ORDER BY CTH.SortOrder

