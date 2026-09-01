-- ============================================================================
-- Smart Index Defragmentation Engine
-- Reorganizes indexes with 10–30% fragmentation; Rebuilds indexes > 30%.
-- ============================================================================

SET NOCOUNT ON;

DECLARE @TableName NVARCHAR(256);
DECLARE @IndexName NVARCHAR(256);
DECLARE @Fragmentation FLOAT;
DECLARE @SQL NVARCHAR(MAX);

DECLARE IndexCursor CURSOR FOR
SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') s
JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE s.avg_fragmentation_in_percent > 10.0 
  AND i.name IS NOT NULL
  AND s.page_count > 1000; -- Ignore small tables

OPEN IndexCursor;
FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Fragmentation <= 30.0
    BEGIN
        -- Low log impact
        SET @SQL = 'ALTER INDEX [' + @IndexName + '] ON [' + @TableName + '] REORGANIZE;';
        PRINT 'REORGANIZE (' + CAST(ROUND(@Fragmentation, 2) AS VARCHAR(10)) + '%): ' + @TableName;
    END
    ELSE
    BEGIN
        -- Higher log impact; rebuilds in-place
        SET @SQL = 'ALTER INDEX [' + @IndexName + '] ON [' + @TableName + '] REBUILD WITH (ONLINE = OFF);';
        PRINT 'REBUILD (' + CAST(ROUND(@Fragmentation, 2) AS VARCHAR(10)) + '%): ' + @TableName;
    END

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;
END

CLOSE IndexCursor;
DEALLOCATE IndexCursor;
GO
