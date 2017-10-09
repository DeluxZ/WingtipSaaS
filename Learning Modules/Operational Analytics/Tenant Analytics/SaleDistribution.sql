-- Percentage of events and corresponding percentage of tickets sold.
CREATE VIEW [dbo].[TicketSalesDistribution]
AS
SELECT DISTINCT V.VenueName
	  ,E.EventName
	  ,TotalTicketsSold = COUNT(*) OVER (Partition by EventName+VenueName)
	  ,PercentTicketsSold = cast(cast(COUNT(*) OVER (Partition by EventName+VenueName) as float)/cast(V.VenueCapacity as float)*100 as int)
FROM [dbo].[fact_Tickets] T
JOIN [dbo].[dim_Venues] V
ON V.VenueId = T. VenueId
JOIN [dbo].[dim_Events] E
ON E.EventId = T. EventId AND E.VenueId = T.VenueId
GO

-- Aggregate for daily sales for all events
CREATE VIEW [dbo].[DailySalesByEvent]
AS
SELECT VenueName
	  ,EventName
	  ,SaleDay = (60-DaysToGo)
      ,RunningTicketsSoldTotal = cast((cast(MAX(RunningTicketsSold) as float)/VenueCapacity)*100 as int)
	  ,Event = VenueName+'+'+EventName
FROM (
SELECT V.VenueName
	  ,E.EventName
	  ,DaysToGo = T.DaysToGo
      ,RunningTicketsSold = COUNT(*) OVER (Partition by EventName+VenueName Order by T.PurchaseDateID)
	  ,V.VenueCapacity
FROM [dbo].[fact_Tickets] T
JOIN [dbo].[dim_Venues] V
ON V.VenueId = T. VenueId
JOIN [dbo].[dim_Events] E
ON E.EventId = T. EventId AND E.VenueId = T.VenueId
JOIN [dbo].[dim_Dates] D
ON  D.PurchaseDateID = T.PurchaseDateID
)A
GROUP BY VenueName
		,EventName
		,DaysToGo
		,VenueCapacity
GO