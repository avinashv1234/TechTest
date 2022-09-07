
Query for the below requirement:

Resulting schema:
- id, serial
- dt_report, date (yyyy-mm-dd), the date of report (i.e. the date of the relevant trades)
- login_hash, text
- server_hash, text
- symbol, text
- currency, text
- sum_volume_prev_7d, double, sum of volume traded by login/server/symbol in previous 7 days including current dt_report
- sum_volume_prev_all, double, sum of volume traded by login/server/symbol all previous days including current dt_report
- rank_volume_symbol_prev_7d, int, dense rank of most volume traded by login/symbol in previous 7 days including current dt_report
- rank_count_prev_7d, int, dense rank of most trade count traded by login in previous 7 days including current dt_report
- sum_volume_2020_08, double, sum of volume traded by login/server/symbol for August 2020 only, up to and including current dt_report
- date_first_trade, timestamp, datetime of first trade by login/server/symbol, up to and including current dt_report
- row_number, int, row number ordered by dt_report/login/server/symbol

Return a row for every combination of dt_report/login/server/symbol for every day in June,
July, August and September 2020. Your method should work even if there is no data on a
particular day in this period with in the data.

Please run this query on users that exist in the users table only. Please include enabled
accounts only. Please return the data in order of rum_number DESC.

 

Data Catalog:
login_hash - hashed user login ID
ticket_hash - hashed trade ID
server_hash - hashed machine ID (note that logins and tickets belong to servers)
symbol - financial instrument being traded
digits - number of significant digits after the decimal place
cmd - 0 = buy, 1 = sell
volume - size of the trade
open_time - open time of the trade
open_price - open time of the trade
close_time - close time of the trade (epoch means trade is still open)
contractsize - size of a single contract of the financial instrument
country_hash - hash of the country of the user
currency - denomination of the account currency
enable - if the login account is enabled or not
 


SELECT
ROW_NUMBER() OVER () AS ID ,
DATE(T.OPEN_TIME ) AS DT_REPORT,
U.LOGIN_HASH,
U.SERVER_HASH,
T.SYMBOL,
U.CURRENCY,
SUM(T.VOLUME) OVER ( ORDER BY U.LOGIN_HASH,U.SERVER_HASH,T.SYMBOL ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS SUM_VOLUME_PREV_7D,
SUM(T.VOLUME) OVER ( ORDER BY U.LOGIN_HASH,U.SERVER_HASH,T.SYMBOL ROWS UNBOUNDED PRECEDING ) AS SUM_VOLUME_PREV_ALL,
DENSE_RANK() OVER ( ORDER BY MAX(T.VOLUME), U.LOGIN_HASH,T.SYMBOL ROWS BETWEEN 7 PRECEDING AND CURRENT ROW ) AS RANK_VOLUME_SYMBOL_PREV_7D,
DENSE_RANK() OVER ( ORDER BY U.LOGIN_HASH ROWS BETWEEN 7 PRECEDING AND CURRENT ROW ) AS RANK_COUNT_PREV_7D,
SUM(CASE WHEN DATE(T.OPEN_TIME) BETWEEN '2020-08-01' AND '2020-08-31' THEN T.VOLUME ELSE NULL END)
	OVER ( ORDER BY U.LOGIN_HASH,U.SERVER_HASH,T.SYMBOL ROWS UNBOUNDED PRECEDING )
	AS SUM_VOLUME_2020_08,
MIN(DATE(T.OPEN_TIME )) OVER ( ORDER BY U.LOGIN_HASH,U.SERVER_HASH,T.SYMBOL ) AS DATE_FIRST_TRADE,
ROW_NUMBER() OVER (ORDER BY DATE(T.OPEN_TIME ) ,U.LOGIN_HASH,U.SERVER_HASH,T.SYMBOL) AS ROW_NUMBER

FROM TRADES T
RIGHT JOIN USERS U ON
T.LOGIN_HASH = U.LOGIN_HASH
WHERE U.ENABLE = 1
GROUP  BY DATE(T.OPEN_TIME ),
U.LOGIN_HASH,
U.SERVER_HASH,
T.SYMBOL,
U.CURRENCY,
T.VOLUME
ORDER BY ROW_NUMBER DESC; 