CREATE TABLE [dbo].[Location] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [LocationTypeId]  SMALLINT           NOT NULL,
    [Code]            NVARCHAR (25)      NOT NULL,
    [Name]            NVARCHAR (50)      NOT NULL,
    [Description]     NVARCHAR (255)     NULL,
    [FlexData]        NVARCHAR (MAX)     NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dboLocation_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (255)     CONSTRAINT [DF_dboLocation_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboLocation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [U_dboLocation_Code] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [U_dboLocation_Name] UNIQUE NONCLUSTERED ([Name] ASC),
    CONSTRAINT [FK_REF_dboLocation_LocationTypeId_dbolkLocationType_Id] FOREIGN KEY ([LocationTypeId]) REFERENCES [dbo].[lkLocationType] ([Id])
);

