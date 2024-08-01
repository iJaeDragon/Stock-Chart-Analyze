from fastapi import APIRouter
from Controller.StockController import StockController

router = APIRouter()


@router.get("/")
async def root():
    return {"message": "Stockholm Syndrome"}

@router.get("/stock/{symbol}/all")
async def stock_all_data(symbol: str):

    return StockController.get_stock_data()