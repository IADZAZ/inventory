CREATE TABLE [adm].[TableAudit] (
    [Id]          INT                IDENTITY (1, 1) NOT NULL,
    [DbUser]      NVARCHAR (255)     NOT NULL,
    [UpdateBy]    NVARCHAR (255)     NOT NULL,
    [AuditType]   NCHAR (1)          NOT NULL,
    [TableName]   NVARCHAR (255)     NOT NULL,
    [UniqueId]    BIGINT             NOT NULL,
    [RowCount]    INT                NOT NULL,
    [AuditJson]   NVARCHAR (MAX)     NOT NULL,
    [DateCreated] DATETIMEOFFSET (7) CONSTRAINT [DF_admTableAudit_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    CONSTRAINT [PK_admTableAudit] PRIMARY KEY CLUSTERED ([Id] ASC)
);