CREATE TABLE [dbo].[jnPersonContactItem] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [PersonId]        INT                NOT NULL,
    [ContactItemId]   INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnPersonContactItem_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnPersonContactItem_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnPersonContactItem] PRIMARY KEY CLUSTERED ([PersonId] ASC, [ContactItemId] ASC),
    CONSTRAINT [FK_PAR_dbojnPersonContactItem_ContactItemId_dboContactItem_Id] FOREIGN KEY ([ContactItemId]) REFERENCES [dbo].[ContactItem] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnPersonContactItem_PersonId_dboPerson_Id] FOREIGN KEY ([PersonId]) REFERENCES [dbo].[Person] ([Id]) ON DELETE CASCADE
);