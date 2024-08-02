from datetime import datetime
def is_valid_datetime(date_str):
    try:
        # 문자열을 datetime 객체로 변환 시도
        datetime.strptime(date_str, "%Y%m%d%H")
        return True
    except ValueError:
        # 변환 실패 시 False 반환
        return False