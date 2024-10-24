CREATE TABLE [dbo].[InventoryLocation] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [SupplyId]        INT                NOT NULL,
    [Quantity]        INT                NOT NULL,
    [LocationId]      INT                NOT NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboInventoryLocation_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboInventoryLocation_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboInventoryLocation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboInventoryLocation_LocationId_dboLocation_Id] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[Location] ([Id]),
    CONSTRAINT [FK_REF_dboInventoryLocation_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id])
);

