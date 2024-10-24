-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-02-10
-- Description:	Creates an enum for a lookup table.
-- =============================================
-- EXEC [adm].[usp_GetCSharpEnum] 'dbo', 'lkDonorType';
CREATE PROCEDURE [adm].[usp_GetCSharpEnum]

	@TableSchema nvarchar(50),
	@TableName nvarchar(255)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY


	IF (LEFT(@TableName, 2) != 'lk') BEGIN
		RAISERROR('Passed in @TableName must begin with "lk".', 16, 1) --change to > 10
		RETURN --exit now
	END

	DECLARE	@EnumName nvarchar(100) = SUBSTRING(@TableName, 3, 255);

	PRINT 'public enum ' + @EnumName + '{';

DECLARE @TSql nvarchar(max) = '
DECLARE @Result nvarchar(max) = '''';
SELECT @Result = @Result + ''
	'' + [ColumnName] + '' = '' + CAST([Id] as nvarchar(20)) + '',''
FROM	(	SELECT	[Id], [ColumnName] = REPLACE(REPLACE([Name], '' '', ''''), '','', '''')
			FROM	[' + @TableSchema + '].[' + @TableName + '] ) LK
ORDER BY [Id];
SET @Result = SUBSTRING(@Result, 3, 10000);
SET @Result = REPLACE(@Result, ''.'', '''');
SET @Result = REPLACE(@Result, ''-'', '''');
SET @Result = REPLACE(@Result, ''_'', '''');
SET @Result = REPLACE(@Result, ''/'', '''');
SET @Result = REPLACE(@Result, ''\'', '''');
SET @Result = REPLACE(@Result, ''&'', '''');
SET @Result = REPLACE(@Result, ''('', '''');
SET @Result = REPLACE(@Result, '')'', '''');
SET @Result = REPLACE(@Result, ''+'', '''');
PRINT @Result;';
EXEC sp_executesql @TSql;

	PRINT '}';


EXIT_HANDLER:
END TRY
BEGIN CATCH
	IF (XACT_STATE()=-1 OR XACT_STATE()=1) ROLLBACK TRANSACTION;
	DECLARE @ErrStr nvarchar(4000);
	EXEC [adm].[usp_HandleError] @@PROCID, @ErrStr OUTPUT;
	THROW;
END CATCH
IF ((XACT_STATE())=1) COMMIT TRANSACTION;
END