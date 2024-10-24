
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
-- EXEC [dbo].[usp_Template] 'here';
CREATE PROCEDURE [dbo].[usp_Template]

	@Parameter1 nvarchar(255)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY
	DECLARE @ErrMsg nvarchar(255);

	DECLARE @SPName nvarchar(1000) = '['+OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']';
	PRINT CONCAT('This Name: ''', @SPName, '''');

	PRINT CONCAT('Parameter Value: ''', @Parameter1, '''');

	-- Validate inputs.
	IF(@Parameter1 IS NULL) BEGIN
		-- No need to validate unique version as this field has a unique constraint.
		SET @ErrMsg = 'Passed in @Parameter1 can not be null.';
		RAISERROR (@ErrMsg, 16 , -1);
	END

	--DECLARE @n int=1, @d int=0, @x int; SET @x=@n/@d;

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