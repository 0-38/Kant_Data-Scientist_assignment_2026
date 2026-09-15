
-- [1장 2강] 실행계획 실습문제

/*
 

============================================================
과제. order_items 실행계획 해석
============================================================

[문제 설명]
order_items에서 product_id가 100인 주문상품을 조회하고,
EXPLAIN과 EXPLAIN ANALYZE를 이용해 실행계획을 직접 분석하세요.

※ 새로운 최적화 기법을 적용하는 문제가 아니라,
   필수 문제에서 배운 실행계획 읽기 방법을 반복 적용하는 문제입니다.

[요구사항]
1. order_items에서 product_id = 100인 행을 조회하세요.
2. 다음 컬럼을 출력하세요.
   - order_item_id
   - order_id
   - product_id
   - qty
   - price
3. 같은 SELECT문에 EXPLAIN을 적용하세요.
4. 같은 SELECT문에 EXPLAIN ANALYZE를 적용하세요.
5. 다음 항목을 확인해 기록하세요.
   - 스캔 방식
   - cost의 시작 비용
   - cost의 총 비용
   - 예상 rows
   - actual rows
   - Rows Removed by Filter
   - Execution Time
6. 예상 rows와 actual rows를 비교하여
   옵티마이저의 예상이 실제 결과와 어느 정도 일치하는지 설명하세요.
7. 다음 질문에 답하세요.
   Q1. 가장 먼저 확인해야 할 데이터 접근 방식은 무엇인가요?
   Q2. Seq Scan은 테이블의 데이터를 어떤 방식으로 확인하나요?

[제출 결과]
- SELECT문
- EXPLAIN SQL
- EXPLAIN ANALYZE SQL
- 주요 실행계획 항목
- 예상 rows와 actual rows 비교
- Q1~Q2 답변
*/

-- [코드 작성란]

  
-- 1~4. EXPLAIN, EXPLAIN ANALYZE 을 적용하세요.

-- 실행 1
EXPLAIN 
SELECT *
FROM order_items
WHERE product_id = 100 ;


-- 실행 2
EXPLAIN ANALYZE 
SELECT *
FROM order_items
WHERE product_id = 100 ;

-- # 5 다음 항목을 확인해 기록하세요.
'''
| 항목 | EXPLAIN | EXPLAIN ANALYZE |
|-----|---------|-----------------|
| 스캔 방식 | Parallel Seq Scan | Parallel Seq Scan |
| cost 시작 비용 | 0.00 | 				0.00 |
| cost 총 비용 | 6947.00 | 6947.00 |
| 예상 rows | 25 | 25 |
| actual rows | X | 16 |
| Rows Removed by Filter | X | 199,984 |
| Execution Time | X | 140.471 ms |
'''

-- # 6. 예상 rows와 actual rows를 비교하여 옵티마이저의 예상이 실제 결과와 어느 정도 일치하는지 설명하세요.
-- 예상 rows는 25개, actual rows는 16개로 옵티마이저가 실제 결과보다 많은 행이 반환되었다.
---> 실제 행 수보다 높 옵티마이저는 예상했지만 비슷하다고 볼 수 있다.

-- # 7. 다음 질문에 답하세요.
	  -- Q1. 가장 먼저 확인해야 할 데이터 접근 방식은 무엇인가요?
		-- 실행 계획에서 테이블에 접근할 때 Seq Scan인지 Index Scan인지 확인해야 한다.


	  -- Q2. Seq Scan은 테이블의 데이터를 어떤 방식으로 확인하나요?
		-- 테이블의 데이터를 처음부터 끝까지 모두 확인후 조건에 맞는 데이터를 반환한다.

