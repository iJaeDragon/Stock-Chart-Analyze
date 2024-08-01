from pydantic import BaseModel

class StockModel(BaseModel):
    symbol: str
    date: str
    price: float