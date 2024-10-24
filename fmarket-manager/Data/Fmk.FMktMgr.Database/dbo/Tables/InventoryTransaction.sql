CREATE TABLE [dbo].[InventoryTransaction] (
    [Id]                         INT                IDENTITY (1, 1) NOT NULL,
    [InventoryTransactionTypeId] SMALLINT           NOT NULL,
    [SupplyId]                   INT                NOT NULL,
    [SupplyCompanyId]            INT                NULL,
    [Quantity]                   INT                NOT NULL,
    [Cost]                       DECIMAL (18, 3)    NULL,
    [Description]                NVARCHAR (500)     NULL,
    [FlexData]                   NVARCHAR (MAX)     NULL,
    [DateCreated]                DATETIMEOFFSET (7) CONSTRAINT [DF_dboInventoryTransaction_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]               NVARCHAR (255)     CONSTRAINT [DF_dboInventoryTransaction_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated]            DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboInventoryTransaction] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboInventoryTransaction_InventoryTransactionTypeId_dbolkInventoryTransactionType_Id] FOREIGN KEY ([InventoryTransactionTypeId]) REFERENCES [dbo].[lkInventoryTransactionType] ([Id]),
    CONSTRAINT [FK_REF_dboInventoryTransaction_SupplyCompanyId_dboCompany_Id] FOREIGN KEY ([SupplyCompanyId]) REFERENCES [dbo].[Company] ([Id]),
    CONSTRAINT [FK_REF_dboInventoryTransaction_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id])
);

