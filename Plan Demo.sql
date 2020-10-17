DBCC FREEPROCCACHE
GO

USE [StackOverflow2013]
GO

CREATE OR ALTER PROCEDURE dbo.GetUserCountForReputation
@Reputation int
AS
SELECT COUNT(1) FROM [StackOverflow2013].[dbo].[Users] WHERE [Reputation] > @Reputation
GO

EXEC [dbo].[GetUserCountForReputation] @Reputation = 50
EXEC [dbo].[GetUserCountForReputation] @Reputation = 150
EXEC [dbo].[GetUserCountForReputation] @Reputation = 15000
EXEC [dbo].[GetUserCountForReputation] @Reputation = 1500000

SELECT COUNT(1) FROM [StackOverflow2013].[dbo].[Users] WHERE [Reputation] > 50
SELECT COUNT(1) FROM [StackOverflow2013].[dbo].[Users] WHERE [Reputation] > 150
SELECT COUNT(1) FROM [StackOverflow2013].[dbo].[Users] WHERE [Reputation] > 15000
SELECT COUNT(1) FROM [StackOverflow2013].[dbo].[Users] WHERE [Reputation] > 1500000
