
-- [ 5장 1강 ] EXPLAIN 결과 해석 실습문 

/*
============================================================
과제. JOIN + 정렬 실행계획 해석
============================================================

[문제 3-1] 고객 주문 조회 실행계획 분석

[문제 설명]
고객 주문 정보를 조회하면서
주문일 기준으로 정렬하는 쿼리의 실행계획을 분석하세요.

이번 문제에서는 실행계획에서
Scan → Join → Sort 흐름을 직접 확인하는 것이 핵심입니다.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 customers를 customer_id 기준으로 JOIN하세요.
2. 2023년 주문만 조회하세요.
3. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
4. 결과를 order_date DESC로 정렬하세요.
5. EXPLAIN ANALYZE를 적용하세요.
6. 실행계획에서 다음 항목을 확인하세요.
   - orders Scan 방식
   - customers Scan 방식
   - Join 방식
   - Sort
   - estimated rows
   - actual rows
   - Execution Time
7. 실행계획을 아래에서 위로 읽으면서 실제 처리 흐름을 설명하세요.
8. 가장 먼저 확인할 병목 후보 노드를 하나 선택하고 이유를 작성하세요.
9. 다음 질문에 답하세요.
   Q1. Scan 노드에서는 무엇을 확인해야 하나요?
   Q2. Join 노드에서는 무엇을 확인해야 하나요?
   Q3. Sort 노드에서는 무엇을 확인해야 하나요?
   Q4. Seq Scan이 나타났다고 해서 무조건 잘못된 실행계획이라고 할 수 있나요?

[제출 결과]
- 전체 SQL
- EXPLAIN ANALYZE 결과
- 실행 흐름
- 병목 후보
- Q1~Q4 답변
*/

-- [코드 작성란]

-- # 1 ~ 5
EXPLAIN ANALYZE
SELECT o.order_id, o.order_date,
    c.customer_id, c.city 
FROM orders o 
JOIN customers c
    ON o.customer_id = c.customer_id 
WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'
ORDER BY order_date DESC ;

'''
7. 실행계획을 아래에서 위로 읽으면서 실제 처리 흐름을 설명하세요.
- customers와 orders를 각각 Seq Scan한 뒤, 
- customer_id 기준으로 Hash Join을 한다.
- 그 후 order_date를 내림차순으로 Sort하여 결과를 반환한다.


8. 가장 먼저 확인할 병목 후보 노드를 하나 선택하고 이유를 작성하세요.
- Sort 노드
- external merge가 발생하고 디스크 2136kB를 사용해 메모리 부족에 따른 디스크 정렬이 발생했다.


9. 다음 질문에 답하세요.
   Q1. Scan 노드에서는 무엇을 확인해야 하나요?
    - Scan 방식(Seq/Index), 실제 처리 행 수, Removed by Filter 행 수를 확인한다.

   Q2. Join 노드에서는 무엇을 확인해야 하나요?
    - Join 방식과 Join 조건을 확인한다.


   Q3. Sort 노드에서는 무엇을 확인해야 하나요?
    - Sort 방식, 불필요한 정렬이 존재하는지 확인한다.


   Q4. Seq Scan이 나타났다고 해서 무조건 잘못된 실행계획이라고 할 수 있나요?
    - 아니다.
    - 조회 대상 행이 많거나 테이블이 작으면 Seq Scan이 더 효율적일 수 있다.
    - 옵티마이저가 더 유리하다고 판단하는 방식을 비교하여 Scan 방식을 결정한다.
'''

-- [ 5장 2강 ] 쿼리 재작성 전후 실행계획 실습 문제

/*
============================================================
과제. JOIN 쿼리의 날짜 인덱스 적용 전후 개선 효과 분석
============================================================

[문제 3-1] 고객 도시 정보를 포함한 특정 기간 주문 조회 튜닝 결과 보고

[문제 설명]
운영 리포트에서 2023년 12월 주문과 고객 도시 정보를 함께 조회하고,
최근 주문부터 확인하는 쿼리를 반복적으로 사용한다고 가정합니다.

orders와 customers를 customer_id 기준으로 JOIN한 상태에서
먼저 현재 실행계획을 기준값으로 기록한 뒤,
orders.order_date 인덱스를 추가하여 동일한 JOIN 쿼리를 다시 측정하세요.

마지막에는 Scan → Join → Sort 흐름과 실행계획 변화,
실행시간 개선 효과와 한계를 간단한 비교 보고서 형태로 정리하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. 기존 idx_orders_order_date 인덱스가 있다면 삭제하세요.
2. orders와 customers를 customer_id 기준으로 JOIN하세요.
3. 다음 기간의 주문만 조회하세요.

   orders.order_date >= DATE '2023-12-01'
   orders.order_date <  DATE '2024-01-01'

4. 다음 컬럼을 출력하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
5. 결과를 orders.order_date DESC로 정렬하세요.
6. 인덱스 생성 전 EXPLAIN ANALYZE 결과에서 다음 항목을 기록하세요.
   - orders 스캔 방식
   - customers 스캔 방식
   - Join 방식
   - JOIN 조건
   - Sort 여부
   - total cost
   - actual rows
   - Execution Time
7. orders.order_date에 idx_orders_order_date 인덱스를 생성하세요.
8. 동일한 JOIN 쿼리에 다시 EXPLAIN ANALYZE를 적용하세요.
9. 개선 후 동일한 항목을 기록하세요.
10. Join 노드가 개선 전후에 어떻게 달라졌는지 확인하세요.
    - Join 방식이 변경되었는지
    - Join 입력 행 수가 달라졌는지
    - Join 노드의 cost 또는 actual time이 달라졌는지
11. 실행시간 감소율을 다음 식으로 계산하세요.

   (개선 전 Execution Time - 개선 후 Execution Time)
   / 개선 전 Execution Time * 100

12. 다음 형식으로 비교 결과를 정리하세요.

   항목                  개선 전        개선 후
   ----------------------------------------------------
   orders 스캔 방식
   customers 스캔 방식
   Join 방식
   JOIN 조건
   Sort 여부
   Join 노드 변화
   total cost
   actual rows
   Execution Time
   실행시간 감소율

13. 다음 질문에 답하세요.
    Q1. 인덱스 추가 후에도 Sort가 남을 수 있나요?
    Q2. 인덱스를 추가했는데 옵티마이저가 Seq Scan을 계속 선택한다면 어떤 의미인가요?
    Q3. Join 방식이 변경되었다고 해서 반드시 성능이 개선되었다고 말할 수 있나요?
    Q4. 이번 결과만으로 모든 날짜 JOIN 조회에 order_date 인덱스가 항상 효과적이라고 결론 내릴 수 있나요?
14. 실습 종료 후 idx_orders_order_date 인덱스를 삭제하세요.

[제출 결과]
- 전체 JOIN SQL
- 개선 전 EXPLAIN ANALYZE
- CREATE INDEX 문
- 개선 후 EXPLAIN ANALYZE
- Scan / Join / Sort 비교표
- JOIN 조건 확인
- Join 노드 전후 변화 해석
- 실행시간 감소율
- Q1~Q4 답변
- DROP INDEX 문
*/

-- [코드 작성란]

-- # 1. 기존 idx_orders_order_date 인덱스가 있다면 삭제하세요.
DROP INDEX IF EXISTS idx_orders_order_date ;


-- # 2 ~ 5 (인덱스 생성 전)
EXPLAIN ANALYZE
SELECT o.order_id, o.order_date ,
    c.customer_id, c.city 
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id 
WHERE o.order_date >= '2023-12-01' AND o.order_date < '2024-01-01' 
ORDER BY order_date DESC ;
   
-- # 7. orders.order_date에 idx_orders_order_date 인덱스를 생성하세요.
   CREATE INDEX idx_orders_order_date ON orders(order_date) ;
   
-- # 8. 동일한 JOIN 쿼리에 다시 EXPLAIN ANALYZE를 적용하세요.
EXPLAIN ANALYZE
SELECT o.order_id, o.order_date ,
    c.customer_id, c.city 
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id 
WHERE o.order_date >= '2023-12-01' AND o.order_date < '2024-01-01' 
ORDER BY order_date DESC ;

-- 14. 실습 종료 후 idx_orders_order_date 인덱스를 삭제하세요.
DROP INDEX idx_orders_order_date ;


'''
12. 다음 형식으로 비교 결과를 정리하세요.

   항목                  개선 전        개선 후
   ----------------------------------------------------
   orders 스캔 방식     Seq Scan        Index Scan
   customers 스캔 방식  Seq Scan        Seq Scan
   Join 방식           Hash Join       Hash join
   JOIN 조건  o.customer_id = c.customer_id / o.customer_id = c.customer_id
   Sort 여부              O               O
   Join 노드 변화  Hash Join + Gather Merge / Hash Join
   total cost           8032.25         4071.25
   actual rows          6344            6344
   Execution Time       39.162 ms         28.120 ms
   실행시간 감소율             -           29.10 %

13. 다음 질문에 답하세요.
    Q1. 인덱스 추가 후에도 Sort가 남을 수 있나요?
        - 남을 수 있다. 
        - 인덱스의 정렬 후에도 order by조건과 맞지 않거나 다시 정렬해야하는 경우에 sort연산이 발생할 수 있다.    


    Q2. 인덱스를 추가했는데 옵티마이저가 Seq Scan을 계속 선택한다면 어떤 의미인가요?
        - 옵티마이저가 판단했을 때 인덱스를 사용하는 것보다 
        - Seq Scan으로 테이블 전체를 읽는 것이 더 효율적이라고 판단했다는 의미이다.
        - 조회해야 할 데이터의 비율이 매우 크거나, 테이블 크기가 작거나, 인덱스 사용 비용이 더 높은 경우에는 인덱스가 존재해도 Seq Scan을 사용할 수 있다.
        - 인덱스가 존재한다고 해서 항상 인덱스 스캔이 사용되는 것은 아니다.
    
    Q3. Join 방식이 변경되었다고 해서 반드시 성능이 개선되었다고 말할 수 있나요?
        - 아니요. 실제 성능 개선 여부는 Execution Time, Rows Removed by Filter 등을 함께 비교해야한다.

    Q4. 이번 결과만으로 모든 날짜 JOIN 조회에 order_date 인덱스가 항상 효과적이라고 결론 내릴 수 있나요?
        - 아니요. 데이터의 분포 변화, 테이블 크기 변화, 조건의 변화 등에 따라 인덱스의 효과는 달라질 수 있다.

'''
/*
