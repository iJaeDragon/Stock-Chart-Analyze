import redis
from typing import List, Optional
from Model.StockModel import StockModel
from config import settings
from datetime import datetime

r = redis.Redis(host=settings.redis_ip, port=settings.redis_port, db=settings.redis_db)

# stock 데이터의 key 형태는 stock:{symbol}:{date} 형태로 들어간다.
# *symbol 코인 구분
# *date 날짜 구분


class StockController:

    @staticmethod
    def get_stock_data(symbol: str, start_date: str, end_date: str) -> List[StockModel]:

        num_start_date = int(start_date.replace("-", ""))
        num_end_date = int(end_date.replace("-", ""))

        if symbol is None:
            return "symbol이 입력되지 않았습니다."
        elif start_date is None:
            return "start_date가 입력되지 않았습니다."
        elif end_date is None:
            return "end_date 입력되지 않았습니다."
        elif num_start_date > num_end_date:
            return "start_date가 end_date 클 수 없습니다."

        all_stock_data = []

        for current_date in range(num_start_date, num_end_date+1):

            # Redis에서 모든 데이터 가져오기
            stock_data = r.lrange(f'stock:{symbol}:{current_date}', 0, -1)

            for data in stock_data:
                all_stock_data.append(data)

        # JSON으로 변환
        return [StockModel.parse_raw(data) for data in all_stock_data]

    @staticmethod
    def put_stock_data(stock: StockModel):
        # StockModel 객체를 JSON으로 변환
        stock_json = stock.json()

        # Redis에 추가
        date_obj = datetime.strptime(stock.date, "%Y-%m-%d %H:%M:%S")
        date = date_obj.strftime("%Y%m%d")

        r.rpush(f'stock:{stock.symbol}:{date}', stock_json)