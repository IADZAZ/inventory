CREATE TABLE [dbo].[VariationType] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [OrganizationId]  INT                NULL,
    [Code]            NVARCHAR (25)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboVariationType_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboVariationType_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboVariationType] PRIMARY KEY CLUSTERED ([Id] ASC)
);

