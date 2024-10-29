CREATE TABLE [dbo].[SupplyChildSupply] (
    [Id]                  INT                IDENTITY (1, 1) NOT NULL,
    [SupplyId]            INT                NOT NULL,
    [ChildSupplyId]       INT                NOT NULL,
    [ChildSupplyQuantity] INT                CONSTRAINT [DF_dboSupplyChildSupply_ChildSupplyQuantity] DEFAULT ((1)) NOT NULL,
    [DateCreated]         DATETIMEOFFSET (7) CONSTRAINT [DF_dboSupplyChildSupply_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]        NVARCHAR (50)      CONSTRAINT [DF_dboSupplyChildSupply_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated]     DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboSupplyChildSupply] PRIMARY KEY CLUSTERED ([SupplyId] ASC, [ChildSupplyId] ASC),
    CONSTRAINT [FK_PAR_dboSupplyChildSupply_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id]),
    CONSTRAINT [FK_PAR_dboSupplyChildSupply_ChildSupplyId_dboSupply_Id] FOREIGN KEY ([ChildSupplyId]) REFERENCES [dbo].[Supply] ([Id])
);

