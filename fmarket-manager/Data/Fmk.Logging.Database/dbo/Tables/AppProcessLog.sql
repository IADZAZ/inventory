CREATE TABLE [dbo].[AppProcessLog] (
    [Id]             INT                IDENTITY (1, 1) NOT NULL,
    [Message]        NVARCHAR (MAX)      NULL,
    [Severity]       TINYINT            NULL,
    [DateCreated]    DATETIMEOFFSET (7) NULL,
    [Exception]      NVARCHAR (MAX)      NULL,
    [MachineName]    NVARCHAR (100)      NULL,
    [App]            NVARCHAR (50)       NULL,
    [SourceContext]  NVARCHAR (100)      NULL,
    [AppProcessGuid] UNIQUEIDENTIFIER   NULL,
    [AppProcessName] NVARCHAR (255)      NULL,
    [AppProcess]     NVARCHAR (2000)     NULL,
    [ElapsedSeconds] INT                NULL,
    CONSTRAINT [PK_dboAppProcessLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

