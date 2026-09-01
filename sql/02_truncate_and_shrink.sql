-- ============================================================================
-- SQL Server Log Recovery & Maintenance Script
-- Use Case: Reclaims disk space from bloated transaction log files (.ldf)
-- ============================================================================

SET NOCOUNT ON;

DECLARE @DatabaseName NVARCHAR(128) = DB_NAME();
DECLARE @LogFileName NVARCHAR(128);
DECLARE @TargetSizeMB INT = 2048; -- Target shrink size (e.g., 2 GB)

-- Retrieve the logical name of the primary log file
SELECT TOP 1 @LogFileName = name 
FROM sys.master_files 
WHERE database_id = DB_ID() AND type = 1;

PRINT 'Starting log recovery for database: ' + @DatabaseName;
PRINT 'Target Log File Logical Name: ' + @LogFileName;

-- Check recovery model
DECLARE @RecoveryModel NVARCHAR(60);
SELECT @RecoveryModel = recovery_model_desc 
FROM sys.databases 
WHERE name = @DatabaseName;

PRINT 'Current Recovery Model: ' + @RecoveryModel;

-- If Simple Recovery, checkpoint to commit inactive log portions
IF @RecoveryModel = 'SIMPLE'
BEGIN
    PRINT 'Executing CHECKPOINT to flush log buffer...';
    CHECKPOINT;
END

-- Execute DBCC SHRINKFILE to reclaim disk space
IF @LogFileName IS NOT NULL
BEGIN
    PRINT 'Shrinking log file ' + @LogFileName + ' to ' + CAST(@TargetSizeMB AS VARCHAR(10)) + ' MB...';
    DBCC SHRINKFILE (@LogFileName, @TargetSizeMB);
    PRINT 'Log shrink operation completed successfully.';
END
ELSE
BEGIN
    RAISERROR('Could not determine logical log file name.', 16, 1);
END
GO
