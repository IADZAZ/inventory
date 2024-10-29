-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-10-28
-- Description:	Record addition to inventory (purchase).
-- =============================================
-- EXEC [dbo].[usp_PurchaseInventory] 1, 1, 200, 623.15, 1, 'Hank';
CREATE PROCEDURE [dbo].[usp_PurchaseInventory]

	@SupplyId nvarchar(25),
	@LocationId nvarchar(25),
	@Quantity int,
	@TotalCost decimal(18,2),
	@SupplyCompanyId int = NULL,
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
	PRINT CONCAT('@Quantity: ''', @Quantity, '''');
	PRINT CONCAT('@TotalCost: ''', @TotalCost, '''');
	PRINT CONCAT('@SupplyCompanyId: ''', @SupplyCompanyId, '''');
	PRINT CONCAT('@UpdateBy: ''', @UpdateBy, '''');
	PRINT ' --'
	
	DECLARE @CostPer decimal(18,2) = @TotalCost / CAST(@Quantity as decimal(18,2));

	PRINT CONCAT('@CostPer: ''', @CostPer, '''');

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
	
	-- Validate SupplyCompany.
	IF((@SupplyCompanyId IS NOT NULL) AND (NOT EXISTS((SELECT [Id] FROM [dbo].[Company] WHERE [Id] = @SupplyCompanyId AND [DateDeactivated] IS NULL)))) BEGIN
		SET @ErrMsg = 'Passed in @SupplyCompanyId does not point to an active Company.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate Quantity.
	IF(@Quantity IS NULL OR @Quantity < 1) BEGIN
		SET @ErrMsg = 'Passed int @Quantity is missing or less than 1.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Validate TotalCost.
	IF(@TotalCost IS NULL OR @TotalCost < 0.01) BEGIN
		SET @ErrMsg = 'Passed int @TotalCost is missing or less than 0.01.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	
	-- Value for LastUpdateBy.
	IF(@UpdateBy IS NULL) SET @UpdateBy = CONCAT('{', @SPName, '}');

	-- Create or update Inventory record for passed in Supply.
	DECLARE @InventoryId int = (SELECT TOP 1 [Id] FROM [dbo].[Inventory] WHERE [SupplyId] = @SupplyId)
	PRINT CONCAT('@InventoryId: ''', @InventoryId, '''');
	IF (@InventoryId IS NULL) BEGIN
		INSERT INTO [dbo].[Inventory] ([SupplyId], [Quantity], [LastCost], [OverrideCost], [LastUpdateBy])
			VALUES	(@SupplyId, @Quantity, @CostPer, @CostPer, @UpdateBy);
	END ELSE BEGIN
		UPDATE	[dbo].[Inventory]
		SET		[Quantity] = [Quantity] + @Quantity,
				[LastCost] = @CostPer,
				--[OverrideCost] = (CASE WHEN [OverrideCost] IS NULL THEN @CostPer ELSE [OverrideCost] END)
				[LastUpdateBy] = @UpdateBy
		WHERE	[Id] = @InventoryId;
	END

	-- Create or update InventoryLocation record for passed in Supply.
	DECLARE @InventoryLocationId int = (	SELECT TOP 1 [Id] 
											FROM	[dbo].[InventoryLocation] 
											WHERE	[SupplyId] = @SupplyId AND [LocationId] = @LocationId);
	PRINT CONCAT('@InventoryLocationId: ''', @InventoryLocationId, '''');
	IF (@InventoryLocationId IS NULL) BEGIN
		INSERT INTO [dbo].[InventoryLocation] ([SupplyId], [Quantity], [LocationId], [LastUpdateBy])
			VALUES	(@SupplyId, @Quantity, @LocationId, @UpdateBy);
	END ELSE BEGIN
		UPDATE	[dbo].[InventoryLocation]
		SET		[Quantity] = [Quantity] + @Quantity,
				[LastUpdateBy] = @UpdateBy
		WHERE	[Id] = @InventoryLocationId;
	END
	
	-- Add an InventoryTransaction to record this transaction.
	DECLARE @InvTranTypeId smallint = (SELECT [Id] FROM [dbo].[lkInventoryTransactionType] WHERE [Code] = 'PRCHS');
	INSERT INTO [dbo].[InventoryTransaction] ([InventoryTransactionTypeId], [SupplyId], [SupplyCompanyId], [Quantity], [Cost], [LastUpdateBy])
		VALUES	(@InvTranTypeId, @SupplyId, @SupplyCompanyId, @Quantity, @CostPer, @UpdateBy);


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