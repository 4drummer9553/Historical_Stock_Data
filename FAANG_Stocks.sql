-- Add a new column to Amazon table to show a simplified date format without time.
ALTER TABLE dbo.Amazon_Historical_StockPrice
Add DateConverted Date;

Update dbo.Amazon_Historical_StockPrice
SET DateConverted = CONVERT(Date,Date)

Select *
From dbo.Amazon_Historical_StockPrice
Order by 1 desc

-- Add a new column to Apple table to show a simplified date format without time.
ALTER TABLE dbo.Apple_Historical_StockPrice
Add DateConverted Date;

Update dbo.Apple_Historical_StockPrice
SET DateConverted = CONVERT(Date,Date)

Select *
From dbo.Apple_Historical_StockPrice
Order by 1 desc

-- Add a new column to Facebook table to show a simplified date format without time.
ALTER TABLE dbo.Facebook_Historical_StockPrice
Add DateConverted Date;

Update dbo.Facebook_Historical_StockPrice
SET DateConverted = CONVERT(Date,Date)

Select *
From dbo.Facebook_Historical_StockPrice
Order by 1 desc

-- Add a new column to Google table to show a simplified date format without time.
ALTER TABLE dbo.Google_Historical_StockPrice
Add DateConverted Date;

Update dbo.Google_Historical_StockPrice
SET DateConverted = CONVERT(Date,Date)

Select *
From dbo.Google_Historical_StockPrice
Order by 1 desc

-- Add a new column to Netflix table to show a simplified date format without time.
ALTER TABLE dbo.Netflix_Historical_StockPrice
Add DateConverted Date;

Update dbo.Netflix_Historical_StockPrice
SET DateConverted = CONVERT(Date,Date)

Select *
From dbo.Netflix_Historical_StockPrice
Order by 1 desc

-- View change in stock price between the adjusted closing price and the opening price for Netflix for each day
Select DateConverted, Opening, [Adj Close], ([Adj Close] - Opening) as PriceChange
From dbo.Netflix_Historical_StockPrice
Order by 1 desc

-- View the difference in closing prices on days where it was adjusted. Only Apple had adjusted closing prices.
Select DateConverted, Closing, [Adj Close], ([Adj Close]-Closing) as OverNightTradingDifference
From dbo.Apple_Historical_StockPrice
Where [Adj Close] <> Closing

-- Use joins to see the volume of stock traded each day for each company.
Select Ama.DateConverted, Ama.Volume as AmazonVolume, App.Volume as AppleVolume, Fac.Volume as FacebookVolume, Goo.Volume as GoogleVolume, Net.Volume as NetflixVolume
From dbo.Amazon_Historical_StockPrice Ama
Join dbo.Apple_Historical_StockPrice App
	On Ama.DateConverted = App.DateConverted
Join dbo.Facebook_Historical_StockPrice Fac
	On Ama.DateConverted = Fac.DateConverted
Join dbo.Google_Historical_StockPrice Goo
	On Ama.DateConverted = Goo.DateConverted
Join dbo.Netflix_Historical_StockPrice Net
	On Ama.DateConverted = Net.DateConverted
Order by 1 desc

-- Use CTE with case statement to find the largest gain among all stocks each day

With MaximumGain (DateConverted, AmazonChange, AppleChange, FacebookChange, GoogleChange, NetflixChange)
as
(
Select Ama.DateConverted, Ama.[Adj Close]-Ama.Opening, App.[Adj Close]-App.Opening, Fac.[Adj Close]-Fac.Opening, Goo.[Adj Close] - Goo.Opening, Net.[Adj Close]-Net.Opening 
From HistoricalStockData..Amazon_Historical_StockPrice Ama
Join HistoricalStockData..Apple_Historical_StockPrice App
	On Ama.DateConverted = App.DateConverted
Join dbo.Facebook_Historical_StockPrice Fac
	On Ama.DateConverted = Fac.DateConverted
Join dbo.Google_Historical_StockPrice Goo
	On Ama.DateConverted = Goo.DateConverted
Join dbo.Netflix_Historical_StockPrice Net
	On Ama.DateConverted = Net.DateConverted
)

-- The case statement will not work if the tables contain null values. Fortunately, all values are present in the tables.
Select *,(Select
    Case
        When AmazonChange >= AppleChange AND AmazonChange >= FacebookChange AND AmazonChange >= GoogleChange AND AmazonChange >= NetflixChange Then AmazonChange
        When AppleChange >= AmazonChange AND AppleChange >= FacebookChange AND AppleChange >= GoogleChange AND AppleChange >= NetflixChange Then AppleChange
        When FacebookChange >= AppleChange AND FacebookChange>= AmazonChange AND FacebookChange >= GoogleChange AND FacebookChange >= NetflixChange Then FacebookChange
		When GoogleChange >= AppleChange AND GoogleChange >= FacebookChange AND GoogleChange >= AmazonChange AND GoogleChange >= NetflixChange Then GoogleChange
        Else                                        NetflixChange
    End as LargestGain) as LargestGain
From MaximumGain
Order by 1 desc

-- Use temp table with case statement to find the largest gain among all stocks each day
DROP Table if exists #MaxGain
Create Table #MaxGain
(
	Date datetime,
	AmazonChange float,
	AppleChange float,
	FacebookChange float,
	GoogleChange float,
	NetflixChange float,
)

Insert into #MaxGain
Select Ama.DateConverted, Ama.[Adj Close]-Ama.Opening, App.[Adj Close]-App.Opening, Fac.[Adj Close]-Fac.Opening, Goo.[Adj Close] - Goo.Opening, Net.[Adj Close]-Net.Opening 
From HistoricalStockData..Amazon_Historical_StockPrice Ama
Join HistoricalStockData..Apple_Historical_StockPrice App
	On Ama.DateConverted = App.DateConverted
Join dbo.Facebook_Historical_StockPrice Fac
	On Ama.DateConverted = Fac.DateConverted
Join dbo.Google_Historical_StockPrice Goo
	On Ama.DateConverted = Goo.DateConverted
Join dbo.Netflix_Historical_StockPrice Net
	On Ama.DateConverted = Net.DateConverted

-- The case statement will not work if the tables contain null values. Fortunately, all values are present in the tables.
Select *, (Select
    Case
        When AmazonChange >= AppleChange AND AmazonChange >= FacebookChange AND AmazonChange >= GoogleChange AND AmazonChange >= NetflixChange Then AmazonChange
        When AppleChange >= AmazonChange AND AppleChange >= FacebookChange AND AppleChange >= GoogleChange AND AppleChange >= NetflixChange Then AppleChange
        When FacebookChange >= AppleChange AND FacebookChange>= AmazonChange AND FacebookChange >= GoogleChange AND FacebookChange >= NetflixChange Then FacebookChange
		When GoogleChange >= AppleChange AND GoogleChange >= FacebookChange AND GoogleChange >= AmazonChange AND GoogleChange >= NetflixChange Then GoogleChange
        Else                                        NetflixChange
    End as LargestGain) as LargestGain
From #MaxGain
Order by 1 desc

-- Create view showing the largest gain among all stocks each day.
Create View AllGains as
Select Ama.DateConverted as DateConverted, Ama.[Adj Close]-Ama.Opening as AmazonChange, 
	App.[Adj Close]-App.Opening as AppleChange, Fac.[Adj Close]-Fac.Opening as FacebookChange, Goo.[Adj Close] - Goo.Opening GoogleChange, Net.[Adj Close]-Net.Opening as NetflixChange
From HistoricalStockData..Amazon_Historical_StockPrice Ama
Join HistoricalStockData..Apple_Historical_StockPrice App
	On Ama.DateConverted = App.DateConverted
Join dbo.Facebook_Historical_StockPrice Fac
	On Ama.DateConverted = Fac.DateConverted
Join dbo.Google_Historical_StockPrice Goo
	On Ama.DateConverted = Goo.DateConverted
Join dbo.Netflix_Historical_StockPrice Net
	On Ama.DateConverted = Net.DateConverted
	
-- The case statement will not work if the tables contain null values. Fortunately, all values are present in the tables.
Select *, (Select
    Case
        When AmazonChange >= AppleChange AND AmazonChange >= FacebookChange AND AmazonChange >= GoogleChange AND AmazonChange >= NetflixChange Then AmazonChange
        When AppleChange >= AmazonChange AND AppleChange >= FacebookChange AND AppleChange >= GoogleChange AND AppleChange >= NetflixChange Then AppleChange
        When FacebookChange >= AppleChange AND FacebookChange>= AmazonChange AND FacebookChange >= GoogleChange AND FacebookChange >= NetflixChange Then FacebookChange
		When GoogleChange >= AppleChange AND GoogleChange >= FacebookChange AND GoogleChange >= AmazonChange AND GoogleChange >= NetflixChange Then GoogleChange
        Else                                        NetflixChange
    End as LargestGain) as LargestGain
From AllGains
Order by 1 desc


--Drop View AllGains