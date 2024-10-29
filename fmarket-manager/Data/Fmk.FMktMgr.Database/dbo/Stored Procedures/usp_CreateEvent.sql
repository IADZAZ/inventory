-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-10-25
-- Description:	Create an Event based on an EventTemplate.
-- =============================================
-- EXEC [dbo].[usp_CreateEvent] '2024-10-17', 4, 3, 'DUser';
CREATE PROCEDURE [dbo].[usp_CreateEvent]

	@EventDate date,
	@EventDefinitionIdOrCode nvarchar(25),
	@VendorPersonId int,
	@UpdateBy nvarchar(255) = NULL,
	@BothSpace nvarchar(255) = NULL,
	@PettyCash decimal(18,2) = NULL
	
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY
	DECLARE @ErrMsg nvarchar(255);

	DECLARE @SPName nvarchar(1000) = '['+OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']';
	PRINT CONCAT('This Name: ''', @SPName, '''');

	PRINT CONCAT('@EventDate: ''', @EventDate, '''');
	PRINT CONCAT('@EventDefinitionIdOrCode: ''', @EventDefinitionIdOrCode, '''');
	PRINT CONCAT('@VendorPersonId: ''', @VendorPersonId, '''');
	PRINT CONCAT('@UpdateBy: ''', @UpdateBy, '''');
	PRINT CONCAT('@BothSpace: ''', @BothSpace, '''');
	PRINT CONCAT('@PettyCash: ''', @PettyCash, '''');

	-- Validate @EventDate.
	IF(@EventDate IS NULL) SET @EventDate = DATEADD(day, 1, GETDATE());

	-- Set/validate EventDefinition.
	DECLARE @EventDefinitionId int = (SELECT [Id] FROM [dbo].[EventDefinition] WHERE [Id] = @EventDefinitionIdOrCode OR [Code] = @EventDefinitionIdOrCode);
	IF(@EventDefinitionId IS NULL) BEGIN
		SET @ErrMsg = 'Passed int @EventDefinitionIdOrCode does not point to an existing EventDefinition.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Set/validate Vendor (Person).
	DECLARE @PersonId int = (SELECT [Id] FROM [dbo].[Person] WHERE [Id] = @VendorPersonId);
	IF(@VendorPersonId IS NULL) BEGIN
		SET @ErrMsg = 'Passed int @VendorPersonId does not point to an existing Person.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	IF(@UpdateBy IS NULL) SET @UpdateBy = CONCAT('{', @SPName, '}');

	-- Create Event.
	INSERT INTO [dbo].[Event] ([EventDefinitionId], [EventDate], [VendorPersonId], [BoothSpace], [PettyCash], [LastUpdateBy])
		SELECT	[Id], 
				(CONCAT(@EventDate, ' ', CONVERT (time, [ScheduledStartTime]), ' ', DATENAME(tzoffset, [ScheduledStartTime]))),
				@PersonId,
				COALESCE(@BothSpace, [DefaultBoothSpace]),
				COALESCE(@PettyCash, [DefaultPettyCash]),
				@UpdateBy
		FROM	[dbo].[EventDefinition]
		WHERE	[Id] = @EventDefinitionId;
	DECLARE @EventId int = SCOPE_IDENTITY();
	
	-- Create EventProducts.
	INSERT INTO [dbo].[EventProduct] ([EventId], [ProductId], [TargetQuantity], [StartQuantity], [DiscountAmount], [LastUpdateBy])
		SELECT	@EventId, [ProductId], [Quantity], [Quantity], 0.00, @UpdateBy
		FROM	[dbo].[EventDefinitionProduct]
		WHERE	[EventDefinitionId] = @EventDefinitionId;


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