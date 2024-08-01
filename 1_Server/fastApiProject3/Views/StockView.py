from fastapi import APIRouter
from Controller.StockController import StockController

router = APIRouter()


@router.get("/")
async def root():
    return {"message": "Stockholm Syndrome"}

@router.get("/stock/{symbol}/data")
async def stock_all_data(symbol: str = None, start_date: str = None, end_date: str = None):

    return StockController.get_stock_data(symbol, start_date, end_date)