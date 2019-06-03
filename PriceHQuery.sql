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
		--,CreateDate as PredictDate
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
		and Period = 1 
		and Source = 'huobi' 
		and DATEPART(MINUTE, CreateDate) = 0
		and Pair in ('BTCUSDT', 'ETHUSDT')
	--order by Pair, CreateDate
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
		   from [MarketAnalysis].[dbo].[KLineData1H] B 
		   where A.DataDate < B.DataDate and B.Market = A.Market and B.Pair = A.Pair 
		   order by B.DataDate
		 ) as PriceTrend
	from [MarketAnalysis].[dbo].[KLineData1H] A
	where Market = 0 and Pair in ( 1, 0)
	--order by Pair, DataDate
) b on a.Pair1 = b.Pair2 and FORMAT(a.CreateDate, 'yyyyMMddHH') = FORMAT(b.DataDate, 'yyyyMMddHH')







