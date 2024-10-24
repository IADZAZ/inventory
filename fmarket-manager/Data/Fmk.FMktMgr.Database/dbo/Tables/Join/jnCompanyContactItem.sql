CREATE TABLE [dbo].[jnCompanyContactItem] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [CompanyId]       INT                NOT NULL,
    [ContactItemId]   INT                NOT NULL,
    [DateCreated]     DATETIMEOFFSET (7) CONSTRAINT [DF_dbojnCompanyContactItem_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    [LastUpdateBy]    NVARCHAR (50)      CONSTRAINT [DF_dbojnCompanyContactItem_LastUpdateBy] DEFAULT ('{system}') NOT NULL,
    [DateDeactivated] DATETIMEOFFSET (7) NULL,
    CONSTRAINT [PK_dbojnCompanyContactItem] PRIMARY KEY CLUSTERED ([CompanyId] ASC, [ContactItemId] ASC),
    CONSTRAINT [FK_PAR_dbojnCompanyContactItem_CompanyId_dboCompany_Id] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[Company] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PAR_dbojnCompanyContactItem_ContactItemId_dboContactItem_Id] FOREIGN KEY ([ContactItemId]) REFERENCES [dbo].[ContactItem] ([Id]) ON DELETE CASCADE
);