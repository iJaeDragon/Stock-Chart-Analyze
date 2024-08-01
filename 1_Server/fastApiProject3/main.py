from fastapi import FastAPI
from Scheduler.StockDataCollection import start_scheduler, shutdown_scheduler
from Views.StockView import *

app = FastAPI()


@app.on_event("startup")
def on_startup():
    start_scheduler()


@app.on_event("shutdown")
def on_shutdown():
    shutdown_scheduler()


app.include_router(router)
