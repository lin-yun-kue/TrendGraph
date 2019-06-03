select *
	,(case
		when A.PredictResult = 0 then 0
		when A.PredictResult = B.PriceTrend then 1
		else -1
	  end) as PredictIsCorrect
from (
	select 
		Pair as Pair1
		,Long
		,Consolidation
		,Short
		,CreateDate
		--,DATEADD(DAY, 1, CreateDate) as PredictDate
		,(case 
			when Long > Consolidation and Long > Short then 1
			when Consolidation > Long and Consolidation > Short then 0
			else -1
		  end) as PredictResult
		,(case 
			when Long > Consolidation and Long > Short then Long
			when Consolidation > Long and Consolidation > Short then 0
			else Short * -1
		 end) as PredictRate
	from [MarketPriceAnalysis].[dbo].[SummaryTrend]
	where Code = 0 
		and Period = 2
		and Source = 'huobi' 
		and DATEPART(HOUR, CreateDate) = 23
		and Pair in ('BTCUSDT', 'ETHUSDT')
) a
inner join (
	select 
		case
			when Pair=0 then 'BTCUSDT'
			when Pair=1 then 'ETHUSDT'
		end as Pair2
		,ClosePrice
		,DataDate
		,( select top(1)
		   case
			when A.ClosePrice - B.ClosePrice > 0 then -1
			else 1
		   end
		   from [MarketAnalysis].[dbo].[KLineData1D] B 
		   where A.DataDate < B.DataDate and B.Market = A.Market and B.Pair = A.Pair 
		   order by B.DataDate
		 ) as PriceTrend
	from [MarketAnalysis].[dbo].[KLineData1D] A
	where Market = 0 and Pair in ( 1, 0)
) b on a.Pair1 = b.Pair2 and FORMAT(a.CreateDate, 'yyyyMMdd') = FORMAT(b.DataDate, 'yyyyMMdd')




--select TOP(1) *
--from [MarketAnalysis].[dbo].[KLineData1D] B 
--where '2019-03-17 00:00:00.000' < B.DataDate and B.Market = 0 and B.Pair = 0
--order by B.DataDate 


