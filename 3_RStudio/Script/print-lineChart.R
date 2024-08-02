if (!require(httr)) install.packages("httr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(jsonlite)) install.packages("jsonlite")

# 패키지 로드
library(httr)
library(ggplot2)
library(jsonlite)

# API Info
apiServerIp <- "127.0.0.1"
apiServerPort <- "8000"

# 파라미터 심볼&날짜 설정
symbol <- "BTCUSDT"
start_date <- "2024080200"
end_date <- "2024080323"

# API 엔드포인트 URL 설정
url <- paste0("http://localhost:8000/stock/", symbol,"/data?start_date=", start_date, "&end_date=", end_date)

# GET 요청
response <- GET(url)

# 응답 상태 코드 확인
if (status_code(response) == 200) {
  # 응답 본문을 JSON으로 변환
  data_list <- content(response, "parsed")
  
  # 리스트를 데이터 프레임으로 변환
  data_frame <- do.call(rbind, lapply(data_list, as.data.frame))
  
  # date 컬럼을 날짜-시간 형식으로 변환
  data_frame$date <- as.POSIXct(data_frame$date, format="%Y-%m-%d %H:%M:%S")
  
  # 데이터 시각화 - 꺾은선 그래프
  ggplot(data_frame, aes(x = date, y = price)) +
    geom_line(color = "blue") +
    labs(title = "BTCUSDT Price over Time", x = "Time", y = "Price (USD)") +
    theme_minimal()
} else {
  cat("Error: Failed to retrieve data\n")
}