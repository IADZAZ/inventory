CREATE TABLE [dbo].[lkAddressType] (
    [Id]              SMALLINT           IDENTITY (1, 1) NOT NULL,
    [Code]            NVARCHAR (10)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbolkAddressType_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbolkAddressType_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbolkAddressType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [U_dbolkAddressType_Code] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [U_dbolkAddressType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

