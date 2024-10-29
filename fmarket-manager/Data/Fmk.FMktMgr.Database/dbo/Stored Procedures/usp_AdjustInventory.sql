-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-10-29
-- Description:	Record adjustment to inventory.
-- =============================================
-- EXEC [dbo].[usp_AdjustInventory] 1, 1, -15, 'dropped box of honey', 'Jan';
CREATE PROCEDURE [dbo].[usp_AdjustInventory]

	@SupplyId nvarchar(25),
	@LocationId nvarchar(25),
	@AdjustmentQuantity int,
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
	PRINT CONCAT('@LocationId: ''', @LocationId, '''');
	PRINT CONCAT('@AdjustmentQuantity: ''', @AdjustmentQuantity, '''');
	PRINT CONCAT('@Reason: ''', @Reason, '''');
	PRINT CONCAT('@UpdateBy: ''', @UpdateBy, '''');
	PRINT ' --'

	-- Validate Supply.
	IF(NOT EXISTS((SELECT [Id] FROM [dbo].[Supply] WHERE [Id] = @SupplyId AND [DateDeactivated] IS NULL))) BEGIN
		SET @ErrMsg = 'Passed in @SupplyId does not point to an active Supply.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate Location.
	IF(NOT EXISTS((SELECT [Id] FROM [dbo].[Location] WHERE [Id] = @LocationId AND [DateDeactivated] IS NULL))) BEGIN
		SET @ErrMsg = 'Passed in @LocationId does not point to an active Location.';
		RAISERROR (@ErrMsg, 16 , -1);
	END

	-- Validate AdjustmentQuantity.
	IF(@AdjustmentQuantity IS NULL OR @AdjustmentQuantity = 0) BEGIN
		SET @ErrMsg = 'Passed int @AdjustmentQuantity must be a positive or negative number.';
		RAISERROR (@ErrMsg, 16 , -1);
	END

	-- Value for LastUpdateBy.
	IF(@UpdateBy IS NULL) SET @UpdateBy = CONCAT('{', @SPName, '}');

	-- Update quantity on Inventory record for passed in Supply.
	DECLARE @InventoryId int = (SELECT TOP 1 [Id] FROM [dbo].[Inventory] WHERE [SupplyId] = @SupplyId);
	PRINT CONCAT('@InventoryId: ''', @InventoryId, '''');
	IF (@InventoryId IS NULL) BEGIN
		SET @ErrMsg = 'No Inventory record found for passed in @SupplyId.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	UPDATE	[dbo].[Inventory]
	SET		[Quantity] = [Quantity] + @AdjustmentQuantity, 
			[LastUpdateBy] = @UpdateBy
	WHERE	[Id] = @InventoryId;
	
	-- Update quantity on InventoryLocation record for passed in Supply.
	DECLARE @InventoryLocationId int = (	SELECT TOP 1 [Id] 
											FROM	[dbo].[InventoryLocation] 
											WHERE	[SupplyId] = @SupplyId AND [LocationId] = @LocationId);
	PRINT CONCAT('@InventoryLocationId: ''', @InventoryLocationId, '''');
	IF (@InventoryLocationId IS NULL) BEGIN
		SET @ErrMsg = 'No InventoryLocation record found for passed in @SupplyId and @LocationId.';
		RAISERROR (@ErrMsg, 16 , -1);
	END ELSE BEGIN
		UPDATE	[dbo].[InventoryLocation]
		SET		[Quantity] = [Quantity] + @AdjustmentQuantity,
				[LastUpdateBy] = @UpdateBy
		WHERE	[Id] = @InventoryLocationId;
	END

	-- Add an InventoryTransaction to record this transaction.
	DECLARE @InvTranTypeId smallint = (SELECT [Id] FROM [dbo].[lkInventoryTransactionType] WHERE [Code] = 'ADJ');
	INSERT INTO [dbo].[InventoryTransaction] ([InventoryTransactionTypeId], [SupplyId], [Quantity], [Description], [LastUpdateBy])
		VALUES	(@InvTranTypeId, @SupplyId, @AdjustmentQuantity, @Reason, @UpdateBy);


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