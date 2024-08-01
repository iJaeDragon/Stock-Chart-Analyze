import redis
from typing import List, Optional
from Model.StockModel import StockModel
from config import settings
from datetime import datetime

r = redis.Redis(host=settings.redis_ip, port=settings.redis_port, db=settings.redis_db)

class StockController:

    @staticmethod
    def get_stock_data() -> List[StockModel]:
        # Redis에서 모든 데이터 가져오기
        stock_data = r.lrange('stock_data', 0, -1)
        # JSON으로 변환
        return [StockModel.parse_raw(data) for data in stock_data]

    @staticmethod
    def put_stock_data(stock: StockModel):
        # StockModel 객체를 JSON으로 변환
        stock_json = stock.json()

        # Redis에 추가
        date_obj = datetime.strptime(stock.date, "%Y-%m-%d %H:%M:%S")
        date = date_obj.strftime("%Y-%m-%d")

        r.rpush('stock_data', stock_json)