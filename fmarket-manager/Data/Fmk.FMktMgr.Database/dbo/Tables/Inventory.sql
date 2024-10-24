CREATE TABLE [dbo].[Inventory] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [SupplyId]        INT                NOT NULL,
    [Quantity]        INT                NOT NULL,
    [LastCost]        DECIMAL (18, 3)    NOT NULL,
    [OverrideCost]    DECIMAL (18, 3)    NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboInventory_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboInventory_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboInventory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboInventory_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id])
);

