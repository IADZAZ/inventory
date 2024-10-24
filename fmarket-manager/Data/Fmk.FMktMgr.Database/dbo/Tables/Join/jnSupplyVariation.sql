CREATE TABLE [dbo].[jnSupplyVariation] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [SupplyId]       INT                NOT NULL,
    [VariationId]       INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnSupplyVariation_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnSupplyVariation_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnSupplyVariation] PRIMARY KEY CLUSTERED ([SupplyId] ASC, [VariationId] ASC),
    CONSTRAINT [FK_PAR_dbojnSupplyVariation_VariationId_dboVariation_Id] FOREIGN KEY ([VariationId]) REFERENCES [dbo].[Variation] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnSupplyVariation_SupplyId_dboSupply_Id] FOREIGN KEY ([SupplyId]) REFERENCES [dbo].[Supply] ([Id]) ON DELETE CASCADE
);