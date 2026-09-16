
-- [3장 1강] CTE와 중접 서브쿼리 실습문제

/*
============================================================
과제. 여러 단계 분석을 CTE로 구조화하기
============================================================

[문제 3-1] 우수 고객의 도시별 구매금액 집계

[문제 설명]
운영팀에서 고객별 구매금액을 계산한 뒤,
총 구매금액이 50,000 이상인 우수 고객만 추려
도시별 우수 고객 수와 구매금액을 집계하려고 합니다.

이번 문제에서는 여러 단계의 로직을 CTE로 나누어
쿼리의 흐름을 명확하게 표현하세요.

※ 과제는 필수 문제와 동일한 수준입니다.
   새로운 SQL 문법을 사용하는 것이 아니라,
   이번 강에서 배운 CTE 구조화를 한 번 더 적용하는 문제입니다.

[요구사항]
1. 첫 번째 CTE customer_totals를 작성하세요.
   - orders와 order_items를 order_id 기준으로 JOIN
   - customer_id별 총 구매금액 계산
   - 총 구매금액 컬럼명은 total_amount
2. 두 번째 CTE high_value_customers를 작성하세요.
   - customer_totals에서 total_amount가 50,000 이상인 고객만 선택
3. high_value_customers와 customers를 customer_id 기준으로 JOIN하세요.
4. 도시별로 다음 값을 계산하세요.
   - 우수 고객 수: vip_customer_count
   - 우수 고객 총 구매금액: vip_total_amount
5. vip_total_amount가 높은 순서대로 정렬하세요.
6. 작성한 전체 CTE 쿼리에 EXPLAIN을 적용하여 실행계획을 확인하세요.
7. 실행계획에서 CTE가 본문에 인라인된 형태인지,
   별도의 CTE Scan이 나타나는지 확인하세요.
8. 다음 질문에 답하세요.
   Q1. 이 문제를 하나의 중첩 서브쿼리로 작성하는 것보다 CTE로 나누었을 때 어떤 장점이 있나요?
   Q2. customer_totals와 high_value_customers라는 이름은 각각 어떤 처리 단계를 의미하나요?
   Q3. 성능 차이가 거의 없다면 CTE와 중첩 서브쿼리 중 어떤 기준으로 구조를 선택하는 것이 좋나요?
   Q4. 이번 EXPLAIN 결과를 기준으로 CTE가 실제 실행 단계에서
       반드시 별도의 중간 결과로 저장되었다고 말할 수 있나요?
       실행계획을 근거로 설명하세요.

[제출 결과]
- 전체 CTE SQL
- 도시별 집계 결과
- EXPLAIN 실행계획
- CTE 인라인 또는 CTE Scan 여부 확인
- Q1~Q4 답변
*/

-- [코드 작성란]

-- # 1 ~ 6
EXPLAIN 
WITH customer_totals AS (
	SELECT o.customer_id, SUM(oi.qty * oi.price) AS total_amount
	FROM orders o
	JOIN order_items oi
		ON oi.order_id = o.order_id
	GROUP BY o.customer_id
),	
	high_value_customers AS (
		SELECT customer_id, total_amount
		FROM customer_totals
		WHERE total_amount >= 50000	
)	
SELECT 
	c.city, 
	count(*) AS vip_customer_count, 
	sum(h.total_amount) AS vip_total_amount  
FROM high_value_customers h
JOIN customers c
    ON c.customer_id = h.customer_id 
GROUP BY c.city 
ORDER BY vip_total_amount DESC ;

'''
8. 다음 질문에 답하세요.
   Q1. 이 문제를 하나의 중첩 서브쿼리로 작성하는 것보다 CTE로 나누었을 때 어떤 장점이 있나요?
	- 처리 단계를 나누어 작성할 수 있어 쿼리의 가독성이 좋아진다.	

   Q2. customer_totals와 high_value_customers라는 이름은 각각 어떤 처리 단계를 의미하나요?
	-- customer_totals는 고객별 총 구매금액 계산이고, 
	-- high_value_customers는 customer_totas 테이블에서 일정 금액 이상인 고객을 필터링하는 단계이다.
   
   Q3. 성능 차이가 거의 없다면 CTE와 중첩 서브쿼리 중 어떤 기준으로 구조를 선택하는 것이 좋나요?
	-- 성능이 비슷하다면 가독성, 재사용성, 유지보수성을 기준으로 선택하는 것이 좋다.

   Q4. 이번 EXPLAIN 결과를 기준으로 CTE가 실제 실행 단계에서
       반드시 별도의 중간 결과로 저장되었다고 말할 수 있나요?
       실행계획을 근거로 설명하세요.
	-- 말할 수 없다. 
	-- 실행계획에서 customer_totals가 Subquery Scan으로 통합되어 실행되고 있어, 
	-- 별도의 중간 결과를 반드시 물리적으로 저장했다고 볼 수 없다.
'''


-- [3장 2강] 다단계 테이블 결합 실습문제
/*
============================================================
과제. 주문-배송 복합 데이터셋 구성 및 결과 검증
============================================================

[문제 3-1] 모든 주문을 유지하면서 배송 정보 결합하기

[문제 설명]
물류 운영팀에서 모든 주문을 기준으로 배송 정보를 함께 확인하려고 합니다.

배송 정보가 없는 주문도 결과에서 사라지면 안 되므로,
적절한 JOIN 종류를 선택해야 합니다.

또한 조인 후 주문 수가 의도와 맞는지 검증해야 합니다.

※ 과제는 필수 문제와 동일한 수준입니다.
   이번 강에서 배운 JOIN 종류 선택과 결과 검증을 스스로 적용하는 문제입니다.

[요구사항]
1. orders를 기준 테이블로 사용하세요.
2. customers를 customer_id 기준으로 JOIN하세요.
3. shipments를 order_id 기준으로 연결하되,
   배송 정보가 없는 주문도 유지되도록 적절한 JOIN 종류를 사용하세요.
4. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
   - shipments.shipment_id
   - shipments.status
5. orders 전체 행 수를 확인하세요.
6. 최종 조인 결과의 전체 행 수를 확인하세요.
7. shipment_id가 NULL인 주문 수를 확인하세요.
8. order_id별 행 수를 GROUP BY하고,
   2행 이상 나타나는 주문이 있는지 확인하세요.
9. 다음 질문에 답하세요.
   Q1. shipments를 INNER JOIN이 아니라 LEFT JOIN으로 연결해야 하는 이유는 무엇인가요?
   Q2. shipment_id가 NULL인 행은 어떤 의미인가요?
   Q3. 조인 후 행 수가 orders보다 많아졌다면 어떤 관계나 데이터를 먼저 점검해야 하나요?
   Q4. 조인 결과 검증을 위해 행 수, 중복, NULL을 함께 확인해야 하는 이유는 무엇인가요?
   Q5. LEFT JOIN한 shipments의 status 조건을
       ON 절에 작성하는 경우와 WHERE 절에 작성하는 경우
       결과가 어떻게 달라질 수 있나요?

[제출 결과]
- 다단계 JOIN SQL
- orders 행 수
- 조인 후 행 수
- 배송 정보 없는 주문 수
- order_id 중복 검증
- Q1~Q5 답변
*/

-- [코드 작성란]

-- 1 ~ 4
SELECT o.order_id , o.order_date,
	c.customer_id, c.city,
	s.shipment_id, s.status 
FROM orders o 
JOIN customers c
	ON c.customer_id = o.customer_id
LEFT JOIN shipments s
	ON o.order_id = s.order_id ;


-- 5. orders 전체 행 수를 확인하세요.
-- (300,000개)
SELECT COUNT(*)
FROM orders ;


-- 6. 최종 조인 결과의 전체 행 수를 확인하세요.
-- (300,000개)
SELECT count(*)
FROM orders o 
JOIN customers c
	ON c.customer_id = o.customer_id
LEFT JOIN shipments s
	ON o.order_id = s.order_id ;


-- 7. shipment_id가 NULL인 주문 수를 확인하세요.
-- (0개)
SELECT count(*)
FROM orders o 
JOIN customers c
	ON c.customer_id = o.customer_id
LEFT JOIN shipments s
	ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL ;


-- 8. order_id별 행 수를 GROUP BY하고, 2행 이상 나타나는 주문이 있는지 확인하세요.
-- 2행 이상 나타나는 주문은 없다.
SELECT o.order_id, COUNT(*) AS rows_count
FROM orders o 
JOIN customers c
	ON c.customer_id = o.customer_id
LEFT JOIN shipments s
	ON o.order_id = s.order_id
GROUP BY o.order_id
HAVING COUNT(*) >= 2

'''
9. 다음 질문에 답하세요.
   Q1. shipments를 INNER JOIN이 아니라 LEFT JOIN으로 연결해야 하는 이유는 무엇인가요?
    -- 배송 정보가 없는 주문도 결과에 유지하기 위해 LEFT JOIN을 사용해야한다.

   Q2. shipment_id가 NULL인 행은 어떤 의미인가요?
    -- 해당 주문에 연결된 배송 정보가 없다는 의미이다.
    -- 1:N 관계로 테이블이 결합되기 떄문에 정보가 없는 데이터는 결측치로 구분된다.


   Q3. 조인 후 행 수가 orders보다 많아졌다면 어떤 관계나 데이터를 먼저 점검해야 하나요?
    -- shipments에 같은 order_id가 여러 개 존재하는 1:N 관계나 중복 데이터를 확인한다.

   Q4. 조인 결과 검증을 위해 행 수, 중복, NULL을 함께 확인해야 하는 이유는 무엇인가요?
    -- 조인으로 인해 생겨난 행 증가, 중복, 미연결 데이터를 함께 검증하기 위해서이다.

   Q5. LEFT JOIN한 shipments의 status 조건을
       ON 절에 작성하는 경우와 WHERE 절에 작성하는 경우
       결과가 어떻게 달라질 수 있나요?
    -- ON절에 작성하면 주문 행은 유지되고 조건에 맞지 않는 배송 정보만 NULL이 된다. 
    -- WHERE절에 작성하면 NULL 행이 제거되어 LEFT JOIN이 사실상 INNER JOIN처럼 동작할 수 있다.
'''









