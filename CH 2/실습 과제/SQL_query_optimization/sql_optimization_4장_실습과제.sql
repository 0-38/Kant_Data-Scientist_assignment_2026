
-- [ 4장 1강 ] 윈도우 함수구조 실습문제

/*
============================================================
과제. 주문 상세 행을 유지하면서 고객별 구매금액 계산하기
============================================================

[문제 3-1] 고객별 총 구매금액을 윈도우 함수로 표시하기

[문제 설명]
고객별 총 구매금액을 계산하되,
각 주문 상품 행도 그대로 유지해야 합니다.

GROUP BY로 고객별 합계를 만들면 주문별·상품별 상세 행이 사라집니다.
이번에는 윈도우 함수를 이용해 상세 행을 유지하면서
고객별 총 구매금액을 같은 결과에서 확인하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id 기준으로 JOIN하세요.
2. 주문상품별 구매금액은 qty * price로 계산하세요.
3. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.customer_id
   - order_items.product_id
   - order_items.qty
   - order_items.price
   - item_amount
4. SUM(qty * price) OVER (PARTITION BY customer_id)를 사용하여
   customer_total_amount를 계산하세요.
5. 결과를 customer_id, order_id, product_id 순으로 정렬하세요.
6. 다음 질문에 답하세요.
   Q1. customer_total_amount가 같은 고객의 여러 행에서 반복되는 이유는 무엇인가요?
   Q2. GROUP BY로 같은 고객별 합계를 계산했다면 어떤 상세 정보가 사라지나요?
   Q3. 개별 주문상품과 고객별 총 구매금액을 동시에 봐야 하는 분석에서 윈도우 함수가 적합한 이유는 무엇인가요?
   Q4. 윈도우 함수에서 PARTITION BY, ORDER BY, 프레임은 각각 어떤 역할을 하나요?

[제출 결과]
- 전체 SQL
- 결과 확인
- Q1~Q4 답변
*/

-- [코드 작성란]

SELECT o.order_id, o.customer_id,
    oi.product_id, oi.qty, oi.price,
    oi.qty * oi.price AS item_amount,
    sum(oi.qty * oi.price) OVER (PARTITION BY customer_id) AS customer_total_amount
FROM orders o
JOIN order_items oi
    ON oi.order_id = o.order_id
ORDER BY customer_id, order_id, product_id ;


--6. 다음 질문에 답하세요.
--   Q1. customer_total_amount가 같은 고객의 여러 행에서 반복되는 이유는 무엇인가요?
    -- PARTITION BY customer_id로 같은 고객의 모든 주문상품 금액을 합산하고, 행을 축소하지 않기 때문에 각 행에 동일한 고객 총액이 반복된다.

--   Q2. GROUP BY로 같은 고객별 합계를 계산했다면 어떤 상세 정보가 사라지나요?
    -- order_id, product_id 등과 같은 컬럼으로 그룹화를 진행하기 때문에 
    -- qty, price 등의 상품별, 고객별 개별적인 주요 상세 정보가 사라진다.

--   Q3. 개별 주문상품과 고객별 총 구매금액을 동시에 봐야 하는 분석에서 윈도우 함수가 적합한 이유는 무엇인가요?
    -- 기존에 있던 행을 유지하면서 고객별 집계 결과를 각 행에 표시할 수 있기 때문이다.

--   Q4. 윈도우 함수에서 PARTITION BY, ORDER BY, 프레임은 각각 어떤 역할을 하나요?
    -- PARTITION BY : 계산할 그룹을 나눈다(그룹핑). 
    -- ORDER BY : 각 그룹 안에서 행의 순서를 정한다. 
    -- 프레임 : 현재 행을 기준으로 실제 계산에 포함할 행의 범위를 정한다.





-- [ 4장 2강 ] 순위 산출과 그룹 내 실습문제


/*
============================================================
과제. NTILE을 이용한 고객 구매등급 분류
============================================================

[문제 3-1] 고객을 구매금액 기준 4개 그룹으로 나누기

[문제 설명]
마케팅팀에서 고객별 총 구매금액을 기준으로
고객을 4개 그룹으로 나누려고 합니다.

구매금액이 높은 고객부터 정렬하고
NTILE(4)를 이용하여 전체 고객 수를 최대한 균등하게 4개 그룹으로 나누세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id 기준으로 JOIN하세요.
2. 고객별 총 구매금액을 SUM(qty * price)로 계산하세요.
3. 총 구매금액 컬럼명은 total_amount로 지정하세요.
4. NTILE(4)를 이용하여 구매금액이 높은 고객부터
   customer_group 1~4를 부여하세요.
5. 결과는 customer_group 오름차순,
   total_amount 내림차순으로 정렬하세요.
6. 각 customer_group별 고객 수를 확인하세요.
7. 각 customer_group별 평균 구매금액을 계산하세요.
8. 다음 질문에 답하세요.
   Q1. NTILE(4)는 금액 범위를 정확히 4등분하나요,
       아니면 고객 수를 기준으로 최대한 균등하게 나누나요?
   Q2. customer_group = 1은 어떤 고객군으로 해석할 수 있나요?
   Q3. 이 결과를 마케팅 업무에 어떻게 활용할 수 있나요?

[제출 결과]
- 고객별 총 구매금액 CTE
- NTILE(4) 적용 SQL
- 그룹별 고객 수
- 그룹별 평균 구매금액
- Q1~Q3 답변
*/

-- [코드 작성란]

-- 1 ~ 5
WITH customer_groups AS (
    SELECT 
        o.customer_id,
        sum(oi.qty * oi.price) AS total_amount,
        NTILE(4) OVER (ORDER BY sum(oi.qty * oi.price) DESC) AS customer_group
    FROM orders o 
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    GROUP BY customer_id
)
SELECT *
FROM customer_groups
ORDER BY customer_group ASC, total_amount DESC ;


--6. 각 customer_group별 고객 수를 확인하세요.
WITH customer_groups AS (
    SELECT 
        o.customer_id,
        sum(oi.qty * oi.price) AS total_amount,
        NTILE(4) OVER (ORDER BY sum(oi.qty * oi.price) DESC) AS customer_group
    FROM orders o 
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    GROUP BY customer_id
)
SELECT customer_group, count(*) AS customer_count
FROM customer_groups 
GROUP BY customer_group
ORDER BY customer_group ;


--7. 각 customer_group별 평균 구매금액을 계산하세요.
WITH customer_groups AS (
    SELECT 
        o.customer_id,
        sum(oi.qty * oi.price) AS total_amount,
        NTILE(4) OVER (ORDER BY sum(oi.qty * oi.price) DESC) AS customer_group
    FROM orders o 
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    GROUP BY customer_id
)
SELECT customer_group, round(avg(total_amount),3) AS avg_total_amount
FROM customer_groups 
GROUP BY customer_group
ORDER BY customer_group ;


--8. 다음 질문에 답하세요.
--   Q1. NTILE(4)는 금액 범위를 정확히 4등분하나요,
--       아니면 고객 수를 기준으로 최대한 균등하게 나누나요?
    -- 고객의 금액이 아닌 고객의 수를 기준으로 최대한 균등하게 4개의 그룹으로 나다.
    -- 각 그룹의 구매 금액 범위가 동일하지는 않다.


--   Q2. customer_group = 1은 어떤 고객군으로 해석할 수 있나요?
    -- 구매금액이 높은 상위 25% 고객군으로 분류할 수 있다.

--   Q3. 이 결과를 마케팅 업무에 어떻게 활용할 수 있나요?
    -- 구매금액 그룹별 차별화된 마케팅 전략을 수립할 수 있다.





-- [ 4장 3강 ] 누적합과 이전 행 실습문제
 /*
============================================================
과제. 누적매출과 전일 대비 증감률 분석
============================================================

[문제 3-1] 일별 매출 변화 리포트 만들기

[문제 설명]
운영 리포트에서 다음 정보를 한 번에 확인하려고 합니다.

- 일별 매출
- 해당 날짜까지 누적 매출
- 전일 매출
- 전일 대비 증감액
- 전일 대비 증감률

이번 강에서 배운 SUM() OVER와 LAG를 함께 사용하여
일별 매출 변화 리포트를 작성하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id로 JOIN하세요.
2. order_date별 daily_sales를 계산하세요.
3. daily_sales_summary CTE를 작성하세요.
4. 다음 값을 계산하세요.
   - running_total
   - prev_day_sales
   - day_over_day_diff
   - day_over_day_pct
5. 전일 대비 증감률은 다음 식을 사용하세요.

   (현재 매출 - 전일 매출) / 전일 매출 * 100

6. 전일 매출이 0인 경우 오류가 발생하지 않도록 NULLIF를 사용하세요.
7. 증감률은 ROUND(..., 2)를 이용해 소수 둘째 자리까지 표시하세요.
8. 결과를 order_date 오름차순으로 정렬하세요.
9. day_over_day_pct가 음수인 날짜만 별도로 조회하세요.
10. 다음 질문에 답하세요.
    Q1. 첫 번째 날짜의 증감률이 NULL이 되는 이유는 무엇인가요?
    Q2. NULLIF(prev_day_sales, 0)를 사용하는 이유는 무엇인가요?
    Q3. day_over_day_pct가 음수라는 것은 비즈니스적으로 무엇을 의미하나요?
    Q4. 하루의 감소만으로 매출 추세가 악화되었다고 단정하기 어려운 이유는 무엇인가요?

[제출 결과]
- 전체 일별 매출 변화 SQL
- 매출 감소 날짜 조회 SQL
- Q1~Q4 답변
*/

-- [코드 작성란]




/*
============================================================
실습 마무리
============================================================

아래 내용을 한 문단으로 정리하세요.

1. 누적합과 이동평균의 계산 범위는 어떻게 다른가요?
2. LAG와 LEAD는 각각 어떤 행을 참조하나요?
3. 전일 대비 증감률 계산에서 NULLIF가 필요한 이유는 무엇인가요?
4. 윈도우 함수 결과를 비즈니스 지표로 해석할 때 무엇을 주의해야 하나요?
*/
