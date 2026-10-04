import pandas as pd
import streamlit as st
from statsmodels.tsa.arima.model import ARIMA

st.title('Bike Sharing 시계열 예측')

st.write('월별 자전거 대여량을 확인하고 미래 값을 예측합니다.')

uploaded_file = st.file_uploader('CSV 파일을 업로드 하세요(Bike_Sharing_Demand.csv).', type='csv')

if uploaded_file is not None:
    data = pd.read_csv(uploaded_file)
    data['datetime'] = pd.to_datetime(data['datetime'])
    data = data.sort_values('datetime')

    # month 컬럼 생성
    data['month'] = data['datetime'].dt.to_period('M').dt.to_timestamp()

    # month별로 그룹화하여 대여량 계산
    monthly = data.groupby('month', as_index=False)['count'].sum()
    monthly = monthly.set_index('month')

    # 데이터 확인
    st.write('월별 자전거 대여량')
    st.dataframe(monthly)

    st.write('시간에 따른 월별 대여량 변화')
    st.line_chart(monthly['count'])

    # 예측 기간 선택
    forecast_period = st.selectbox('예측 기간을 선택하세요.', [1, 3, 6])

    # ARIMA 모델 학습
    set_arima_model = ARIMA(monthly['count'], order=(2, 1, 1))
    arima_model = set_arima_model.fit()

    # 미래 값 예측
    forecast = arima_model.forecast(steps=forecast_period)

    # 미래 날짜 생성
    future_dates = pd.date_range(
            start=(monthly.index[-1] + pd.DateOffset(months=1)),
            periods=forecast_period, 
            freq="MS"
    )

    # 예측결과 생성
    forecast_data = pd.DataFrame({
            "date": future_dates,
            "predicted": forecast.values
        })

    forecast_data = forecast_data.set_index("date")

    # 예측 결과 출력
    st.write("미래 예측 결과")
    st.dataframe(forecast_data)

    # 실제값과 예측값을 그래프로 비교
    actual_data = monthly[["count"]].rename(columns={"count": "actual"})

    chart_data = pd.concat([actual_data, forecast_data],axis=1)

    st.write("실제 데이터와 미래 예측")
    st.line_chart(chart_data)