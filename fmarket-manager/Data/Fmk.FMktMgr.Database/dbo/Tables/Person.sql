CREATE TABLE [dbo].[Person] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [PersonTypeId]    SMALLINT           NOT NULL,
    [FirstName]       NVARCHAR (50)      NOT NULL,
    [FirstNamePref]   NVARCHAR (50)      NULL,
    [LastName]        NVARCHAR (50)      NOT NULL,
    [LastNamePref]    NVARCHAR (50)      NULL,
    [GenderId]        SMALLINT           NOT NULL,
    [GenderPrefId]    SMALLINT           NULL,
    [DateOfBirth]     DATE               NULL,
    [CountryOfBirth]  NVARCHAR (50)      NULL,
    [TaxIdNumber]     NVARCHAR (50)      NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboPerson_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboPerson_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboPerson] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboPerson_GenderId_dbolkGender_Id] FOREIGN KEY ([GenderId]) REFERENCES [dbo].[lkGender] ([Id]),
    CONSTRAINT [FK_REF_dboPerson_GenderPrefId_dbolkGender_Id] FOREIGN KEY ([GenderPrefId]) REFERENCES [dbo].[lkGender] ([Id]),
    CONSTRAINT [FK_REF_dboPerson_PersonTypeId_dbolkPersonType_Id] FOREIGN KEY ([PersonTypeId]) REFERENCES [dbo].[lkPersonType] ([Id])
);

