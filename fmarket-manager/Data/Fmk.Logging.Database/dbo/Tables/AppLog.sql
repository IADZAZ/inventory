CREATE TABLE [dbo].[AppLog] (
    [Id]            INT                IDENTITY (1, 1) NOT NULL,
    [Message]       NVARCHAR (MAX)      NULL,
    [Severity]      TINYINT            NULL,
    [DateCreated]   DATETIMEOFFSET (7) NULL,
    [Exception]     NVARCHAR (MAX)      NULL,
    [MachineName]   NVARCHAR (100)      NULL,
    [App]           NVARCHAR (50)       NULL,
    [SourceContext] NVARCHAR (100)      NULL,
    [DataContext]   NVARCHAR (100)      NULL,
    [User]          NVARCHAR (100)      NULL,
    [CorrelationId] UNIQUEIDENTIFIER   NULL,
    CONSTRAINT [PK_dboAppLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

