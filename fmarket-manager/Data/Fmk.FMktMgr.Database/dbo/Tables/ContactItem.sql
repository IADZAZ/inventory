CREATE TABLE [dbo].[ContactItem] (
    [Id]                INT                IDENTITY (1, 1) NOT NULL,
    [ContactItemTypeId] SMALLINT           NOT NULL,
    [Value]             NVARCHAR (255)     NOT NULL,
    [Memo]              NVARCHAR (500)     NULL,
    [FlexData]          NVARCHAR (MAX)     NULL,
    [DateCreated]       DATETIMEOFFSET (7) CONSTRAINT [DF_dboContactItem_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]      NVARCHAR (255)     CONSTRAINT [DF_dboContactItem_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated]   DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dboContactItem] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_REF_dboContactItem_ContactItemTypeId_dbolkContactItemType_Id] FOREIGN KEY ([ContactItemTypeId]) REFERENCES [dbo].[lkContactItemType] ([Id])
);

