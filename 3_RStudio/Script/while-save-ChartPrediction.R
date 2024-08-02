# 실행할 R 스크립트 파일 경로
script_path <- "C:/Users/rhkgk/Documents/GitHub/Stock-Chart-Analyze/3_RStudio/Script/print-ChartPrediction.R"

# 무한 루프를 시작합니다.
while(TRUE) {
  # 스크립트를 실행합니다.
  source(script_path)
  
  # 5초 대기합니다.
  Sys.sleep(5)
}