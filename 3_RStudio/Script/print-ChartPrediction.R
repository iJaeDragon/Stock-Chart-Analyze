# 필요한 패키지 설치 및 로드
if (!require(forecast)) install.packages("forecast")
if (!require(httr)) install.packages("httr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(jsonlite)) install.packages("jsonlite")

library(httr)
library(ggplot2)
library(jsonlite)
library(forecast)

# 파일 저장 경로
saveDir <- "C:/Users/rhkgk/Documents/chartImage"

# API Info
apiServerIp <- "127.0.0.1"
apiServerPort <- "8000"

# 파라미터 심볼&날짜 설정
symbol <- "BTCUSDT"
start_date <- "2024-08-02"
end_date <- "2024-08-03"

# API 엔드포인트 URL 설정
url <- paste0("http://", apiServerIp, ":", apiServerPort, "/stock/", symbol, "/data?start_date=", start_date, "&end_date=", end_date)

# GET 요청
response <- GET(url)

# 응답 상태 코드 확인
if (status_code(response) == 200) {
  # 응답 본문을 JSON으로 변환
  data_list <- content(response, "parsed")
  
  # 리스트를 데이터 프레임으로 변환
  data_frame <- do.call(rbind, lapply(data_list, as.data.frame))
  
  # date 컬럼을 날짜-시간 형식으로 변환
  data_frame$date <- as.POSIXct(paste0(data_frame$date, " 00:00:00"), format="%Y-%m-%d %H:%M:%S", tz = "UTC")
  
  # 데이터 확인
  # print(head(data_frame))
  
  # 시계열 데이터 생성 (1초 간격으로 수집된 데이터)
  # 1시간의 데이터를 3600개의 1초 포인트로 구성
  ts_data <- ts(data_frame$price, start = c(1), frequency = 3600)
  
  # ARIMA 모델 적합
  fit <- auto.arima(ts_data)
  
  # 모델 요약 출력
  summary(fit)
  
  # 예측 기간 설정 (30분 = 1800개의 1초 포인트)
  forecasted <- forecast(fit, h = 1800)
  
  # 예측된 데이터 프레임 생성
  forecast_df <- data.frame(
    date = seq(max(data_frame$date) + 1, by = "1 sec", length.out = 1800),
    price = as.numeric(forecasted$mean)
  )
  
  # 원본 데이터와 예측 데이터를 함께 시각화
  plot <- ggplot() +
    geom_line(data = data_frame, aes(x = date, y = price), color = "blue") +
    geom_line(data = forecast_df, aes(x = date, y = price), color = "red") +
    labs(title = "BTCUSDT Price and Forecast over Time", x = "Time", y = "Price (USD)") +
    theme_minimal() +
    scale_x_datetime(date_labels = "%Y-%m-%d %H:%M:%S", date_breaks = "1 hour") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
  
  # 그래프를 화면에 출력
  print(plot)
  
  # 현재 시간 정보를 파일 이름에 포함
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0(saveDir, "/BTCUSDT_Price_Forecast_", timestamp, ".png")
  
  # 그래프를 지정한 디렉토리와 파일명으로 저장
  ggsave(filename = filename, plot = plot, width = 10, height = 6, dpi = 300)
  
} else {
  cat("Error: Failed to retrieve data\n")
}