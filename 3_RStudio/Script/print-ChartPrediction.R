# 필요한 패키지 설치 및 로드
if (!require(forecast)) install.packages("forecast")
if (!require(httr)) install.packages("httr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(jsonlite)) install.packages("jsonlite")

library(httr)
library(ggplot2)
library(jsonlite)
library(forecast)

# 날짜 설정
symbol <- "BTCUSDT"
start_date <- "2024-08-02"
end_date <- "2024-08-03"

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
  
  # date 컬럼을 날짜-시간 형식으로 변환 (임시로 날짜만 사용하여 시간 00:00:00으로 설정)
  data_frame$date <- as.POSIXct(paste0(data_frame$date, " 00:00:00"), format="%Y-%m-%d %H:%M:%S", tz = "UTC")
  
  # 데이터 확인
  print(head(data_frame))
  
  # 시계열 데이터 생성 (5초 간격으로 수집된 데이터)
  # 1시간의 데이터를 720개의 5초 포인트로 구성
  ts_data <- ts(data_frame$price, start = c(1), frequency = 60 * 60 / 5)
  
  # ARIMA 모델 적합
  fit <- auto.arima(ts_data)
  
  # 모델 요약 출력
  summary(fit)
  
  # 예측 기간 설정 (1시간 = 720개의 5초 포인트)
  forecasted <- forecast(fit, h = 720)
  
  # 예측된 데이터 프레임 생성
  forecast_df <- data.frame(
    date = seq(max(data_frame$date) + 5, by = "5 sec", length.out = 720),
    price = as.numeric(forecasted$mean)
  )
  
  # 원본 데이터와 예측 데이터를 함께 시각화
  ggplot() +
    geom_line(data = data_frame, aes(x = date, y = price), color = "blue") +
    geom_line(data = forecast_df, aes(x = date, y = price), color = "red") +
    labs(title = "BTCUSDT Price and Forecast over Time", x = "Time", y = "Price (USD)") +
    theme_minimal() +
    scale_x_datetime(date_labels = "%Y-%m-%d %H:%M:%S", date_breaks = "1 hour") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
} else {
  cat("Error: Failed to retrieve data\n")
} 