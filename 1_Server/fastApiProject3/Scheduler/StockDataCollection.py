from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
import pytz
import requests
from Model.StockModel import StockModel
from Controller.StockController import StockController

scheduler = BackgroundScheduler()

def scheduled_task():

    url = "https://api.binance.com/api/v3/ticker/price"
    params = {
        "symbol": "BTCUSDT"
    }
    response = requests.get(url, params=params)
    data = response.json()


    # 현재 한국 시간 가져오기 # 한국 표준시(KST) 시간대 생성
    kst_now = datetime.now(pytz.timezone('Asia/Seoul'))
    formatted_time = kst_now.strftime('%Y-%m-%d %H:%M:%S')

    curInfo = StockModel(symbol=data['symbol'], date=formatted_time, price=data['price'])

    StockController.put_stock_data(curInfo)

def start_scheduler():
    scheduler.add_job(scheduled_task, 'interval', seconds=5)  # 5초마다 실행
    scheduler.start()

def shutdown_scheduler():
    scheduler.shutdown()