CREATE TABLE [adm].[DbValue] (
    [Id]          INT                IDENTITY (1, 1) NOT NULL,
    [Key]         NVARCHAR (50)      NOT NULL,
    [Value]       NVARCHAR (1000)    NOT NULL,
    [DateCreated] DATETIMEOFFSET (7) CONSTRAINT [DF_admDbValue_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
    CONSTRAINT [PK_admDbValue] PRIMARY KEY CLUSTERED ([Id] ASC)
);

