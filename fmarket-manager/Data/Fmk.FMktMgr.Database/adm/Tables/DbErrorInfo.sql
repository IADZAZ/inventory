CREATE TABLE [adm].[DbErrorInfo] (
    [Id]               INT                IDENTITY (1, 1) NOT NULL,
    [Number]           INT                NOT NULL,
    [Severity]         INT                NOT NULL,
    [State]            INT                NULL,
    [CallingProcudure] NVARCHAR (255)     NULL,
    [ErrorProcedure]   NVARCHAR (255)     NULL,
    [Line]             INT                NULL,
    [Message]          NVARCHAR (3000)    NOT NULL,
    [XactState]        INT                NOT NULL,
    [ContextInfo]      VARBINARY (128)    NULL,
    [DateCreated]      DATETIMEOFFSET (7) CONSTRAINT [DF_admDbErrorInfo_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    CONSTRAINT [PK_admDbErrorInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);

