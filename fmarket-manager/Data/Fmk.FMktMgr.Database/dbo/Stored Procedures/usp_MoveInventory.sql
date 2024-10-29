-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-10-29
-- Description:	Record adjustment to inventory.
-- =============================================
-- EXEC [dbo].[usp_MoveInventory] 1, 2, 1, 11, NULL, 'James';
CREATE PROCEDURE [dbo].[usp_MoveInventory]

	@SupplyId nvarchar(25),
	@OldLocationId nvarchar(25),
	@NewLocationId nvarchar(25),
	@Quantity int,
	@Reason nvarchar(500) = NULL,
	@UpdateBy nvarchar(255) = NULL

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY
	DECLARE @ErrMsg nvarchar(255);

	DECLARE @SPName nvarchar(1000) = '['+OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']';
	PRINT CONCAT('This Name: ''', @SPName, '''');
	
	PRINT CONCAT('@SupplyId: ''', @SupplyId, '''');
	PRINT CONCAT('@OldLocationId: ''', @OldLocationId, '''');
	PRINT CONCAT('@NewLocationId: ''', @NewLocationId, '''');
	PRINT CONCAT('@Quantity: ''', @Quantity, '''');
	PRINT CONCAT('@Reason: ''', @Reason, '''');
	PRINT CONCAT('@UpdateBy: ''', @UpdateBy, '''');
	PRINT ' --'

	-- Validate Supply.
	IF(NOT EXISTS((SELECT [Id] FROM [dbo].[Supply] WHERE [Id] = @SupplyId AND [DateDeactivated] IS NULL))) BEGIN
		SET @ErrMsg = 'Passed in @SupplyId does not point to an active Supply.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate "Old" Location.
	IF(NOT EXISTS((SELECT [Id] FROM [dbo].[Location] WHERE [Id] = @OldLocationId AND [DateDeactivated] IS NULL))) BEGIN
		SET @ErrMsg = 'Passed in @OldLocationId does not point to an active Location.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate "New" Location.
	IF(NOT EXISTS((SELECT [Id] FROM [dbo].[Location] WHERE [Id] = @NewLocationId AND [DateDeactivated] IS NULL))) BEGIN
		SET @ErrMsg = 'Passed in @NewLocationId does not point to an active Location.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate Quantity.
	IF(@Quantity IS NULL OR @Quantity < 1) BEGIN
		SET @ErrMsg = 'Passed int @Quantity is missing or less than 1.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Value for LastUpdateBy.
	IF(@UpdateBy IS NULL) SET @UpdateBy = CONCAT('{', @SPName, '}');


	-- Update quantity on "Old" InventoryLocation record for passed in Supply.
	DECLARE @OldInventoryLocationId int = (	SELECT TOP 1 [Id] 
											FROM	[dbo].[InventoryLocation] 
											WHERE	[SupplyId] = @SupplyId AND [LocationId] = @OldLocationId);
	PRINT CONCAT('@OldInventoryLocationId: ''', @OldInventoryLocationId, '''');
	IF (@OldInventoryLocationId IS NULL) BEGIN
		SET @ErrMsg = 'No InventoryLocation record found for passed in @SupplyId and @OldInventoryLocationId.';
		RAISERROR (@ErrMsg, 16 , -1);
	END ELSE BEGIN
		UPDATE	[dbo].[InventoryLocation]
		SET		[Quantity] = [Quantity] - @Quantity,
				[LastUpdateBy] = @UpdateBy
		WHERE	[Id] = @OldInventoryLocationId;
	END

	
	-- Update quantity on "New" InventoryLocation record for passed in Supply.
	DECLARE @NewInventoryLocationId int = (	SELECT TOP 1 [Id] 
											FROM	[dbo].[InventoryLocation] 
											WHERE	[SupplyId] = @SupplyId AND [LocationId] = @NewLocationId);
	PRINT CONCAT('@NewInventoryLocationId: ''', @NewInventoryLocationId, '''');
	IF (@NewInventoryLocationId IS NULL) BEGIN
		INSERT INTO [dbo].[InventoryLocation] ([SupplyId], [Quantity], [LocationId], [LastUpdateBy])
			VALUES	(@SupplyId, @Quantity, @NewLocationId, @UpdateBy);
	END ELSE BEGIN
		UPDATE	[dbo].[InventoryLocation]
		SET		[Quantity] = [Quantity] + @Quantity,
				[LastUpdateBy] = @UpdateBy
		WHERE	[Id] = @NewInventoryLocationId;
	END

	-- Add an InventoryTransaction to record this transaction.
	DECLARE @InvTranTypeId smallint = (SELECT [Id] FROM [dbo].[lkInventoryTransactionType] WHERE [Code] = 'MOVE');
	INSERT INTO [dbo].[InventoryTransaction] ([InventoryTransactionTypeId], [SupplyId], [Quantity], [OldLocationId], [NewLocationId], [Description], [LastUpdateBy])
		VALUES	(@InvTranTypeId, @SupplyId, @Quantity, @OldLocationId, @NewLocationId, @Reason, @UpdateBy);


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