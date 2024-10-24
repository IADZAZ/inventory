CREATE TABLE [dbo].[lkEventRentType] (
    [Id]              SMALLINT           IDENTITY (1, 1) NOT NULL,
    [Code]            NVARCHAR (10)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbolkEventRentType_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbolkEventRentType_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbolkEventRentType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [U_dbolkEventRentType_Code] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [U_dbolkEventRentType_Name] UNIQUE NONCLUSTERED ([Name] ASC)
);

