-- Crea la tabella del registro degli errori
IF OBJECT_ID('dbo.error_log', 'U') IS NULL
    CREATE TABLE dbo.error_log (
        error_log_id    INT IDENTITY PRIMARY KEY,
        error_time      DATETIME2 DEFAULT SYSDATETIME(),
        error_number    INT,
        error_severity  INT,
        error_state     INT,
        error_procedure NVARCHAR(200),
        error_line      INT,
        error_message   NVARCHAR(MAX)
    );
