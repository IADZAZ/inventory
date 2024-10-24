CREATE TABLE [dbo].[Variation] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [VariationTypeId] INT                NOT NULL,
    [Code]            NVARCHAR (25)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboVariation_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboVariation_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboVariation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboVariation_VariationTypeId_dboVariationType_Id] FOREIGN KEY ([VariationTypeId]) REFERENCES [dbo].[VariationType] ([Id])
);

