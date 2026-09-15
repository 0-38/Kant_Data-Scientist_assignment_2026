
/* [2장 1강] 인덱스 구조와 동작원리 실습문제

============================================================
과제. 범위 검색에서 B-Tree 인덱스 확인
============================================================


[문제 설명]
products.price에 B-Tree 인덱스를 생성하고
price가 100 이상 120 미만인 범위 조회의 실행계획을 비교하세요.

※ 필수 문제와 동일한 수준의 독립 실습입니다.

[요구사항]
1. products.price의 최솟값과 최댓값을 확인하세요.
2. idx_products_price 인덱스가 있다면 삭제하세요.
3. price >= 100 AND price < 120 조건에 EXPLAIN ANALYZE를 적용하세요.
4. 인덱스 생성 전 다음 항목을 기록하세요.
   - 스캔 방식 : Seq Scan
   - cost : 0.000 ... 205.00
   - actual rows : 35
   - Execution Time : 0.700 ms
5. products.price에 idx_products_price 인덱스를 생성하세요.
6. 동일한 SELECT문에 다시 EXPLAIN ANALYZE를 적용하세요.
7. 인덱스 생성 후 다음 항목을 기록하세요.
   - 스캔 방식 : Index Scan
   - cost : 4.72 .. 59.53
   - actual rows : 35
   - Execution Time : 0.062
8. 인덱스 생성 전후 결과를 비교하세요.
9. 실습이 끝나면 idx_products_price 인덱스를 삭제하세요.
10. 다음 질문에 답하세요.
    Q1. B-Tree 인덱스는 등호 검색 외에 어떤 비교 조건에 활용될 수 있나요?
    Q2. B-Tree 인덱스가 범위 검색에서 검색 범위를 줄일 수 있는 이유는 무엇인가요?
    Q3. 인덱스를 많이 만들수록 INSERT, UPDATE, DELETE 비용이 커질 수 있는 이유는 무엇인가요?

[제출 결과]
- MIN/MAX 확인 SQL
- DROP INDEX 문
- 인덱스 생성 전 EXPLAIN ANALYZE
- 개선 전 기록표
- CREATE INDEX 문
- 인덱스 생성 후 EXPLAIN ANALYZE
- 개선 후 기록표
- 전후 비교
- 최종 DROP INDEX 문
- Q1~Q3 답변
*/

-- [코드 작성란]

-- # 1
SELECT MIN(price), MAX(price)
FROM products ;


-- # 2. idx_products_price 인덱스가 있다면 삭제하세요.
DROP INDEX IF EXISTS idx_products_price ;


-- 3. price >= 100 AND price < 120 조건에 EXPLAIN ANALYZE를 적용하세요.

EXPLAIN ANALYZE 
SELECT *
FROM products
WHERE price >= 100 AND price < 120 ;

--4. 인덱스 생성 전 다음 항목을 기록하세요.
--   - 스캔 방식 : Seq Scan
--   - cost : 0.000 ... 205.00
--   - actual rows : 35
--   - Execution Time : 0.700 ms

-- 5. products.price에 idx_products_price 인덱스를 생성하세요.
CREATE INDEX idx_products_price ON products (price) ;


-- 6. 동일한 SELECT문에 다시 EXPLAIN ANALYZE를 적용하세요.
EXPLAIN ANALYZE 
SELECT *
FROM products
WHERE price >= 100 AND price < 120 ;

-- 7. 인덱스 생성 후 다음 항목을 기록하세요.
--   - 스캔 방식 : Index Scan
--   - cost : 4.72 .. 59.53
--   - actual rows : 35
--   - Execution Time : 0.062

-- 8. 인덱스 생성 전후 결과를 비교하세요.

-- | 항목 | 인덱스 생성 전 | 인덱스 생성 후 |
-- |-----|------------|-------------|
-- | 스캔 방식 | Seq Scan | Index Scan |
-- | cost | 0.000 .. 205.00 | 4.72 .. 59.53 |
-- | actual rows |   35 |          35 |
-- | Execution Time | 0.700 ms | 0.062 ms |


-- 9. 실습이 끝나면 idx_products_price 인덱스를 삭제하세요.
DROP INDEX IF EXISTS idx_products_price ;


-- 10. 다음 질문에 답하세요.
--    Q1. B-Tree 인덱스는 등호 검색 외에 어떤 비교 조건에 활용될 수 있나요?
		-- >, <, >=, <=와 같은 범위 비교 조건에도 활용할 수 있다. 
		-- BETWEEN과 같은 범위 검색에도 사용할 수 있다.

--    Q2. B-Tree 인덱스가 범위 검색에서 검색 범위를 줄일 수 있는 이유는 무엇인가요?
	-- B-Tree 인덱스는 데이터를 정렬된 구조로 관리하기 때문에 
	-- 조건에 해당하는 시작 위치를 빠르게 찾을 수 있다. 
	-- 이후 필요한 범위의 데이터만 순차적으로 확인하므로 
	-- 테이블 전체를 탐색하는 것보다 검색 범위를 줄일 수 있다.

--    Q3. 인덱스를 많이 만들수록 INSERT, UPDATE, DELETE 비용이 커질 수 있는 이유는 무엇인가요?
	-- INSERT, UPDATE, DELETE로 테이블의 데이터가 변경되면 
	-- 해당 데이터와 관련된 인덱스 정보도 함께 추가, 수정, 삭제해야 한다. 
	-- 따라서 인덱스가 많을수록 유지해야 할 인덱스가 증가하여 
	-- 데이터 변경 작업의 처리 비용과 시간이 커질 수 있다.




/*
 * [2장 2강] 인덱스 효과 실습문제
 * 
============================================================
과제. 작은 테이블의 인덱스 추가 여부 판단하기
============================================================

[문제 3-1] stores.city에 인덱스를 추가해야 할까?

[문제 설명]
매장 조회 기능에서 특정 도시의 매장을 검색한다고 가정합니다.

stores 테이블은 전체 데이터가 100행으로 매우 작고,
city 컬럼에는 몇 개의 도시만 반복해서 저장되어 있습니다.

실제 데이터 분포와 실행계획을 확인한 뒤
stores.city에 인덱스를 추가하는 것이 효과적인 선택인지 판단하세요.

※ 과제는 필수 문제와 동일한 수준입니다.
   새로운 인덱스 기법을 사용하는 것이 아니라
   이번 강에서 배운 판단 기준을 스스로 적용하는 문제입니다.

[요구사항]
1. stores 테이블의 전체 행 수를 조회하세요.
2. city의 고유값 수를 조회하세요.
3. city별 행 수와 전체에서 차지하는 비율을 조회하세요.
4. 기존 idx_stores_city 인덱스가 있다면 삭제하세요.
5. city = 'Mumbai' 조건에 EXPLAIN ANALYZE를 적용하세요.
6. stores.city에 idx_stores_city 인덱스를 생성하세요.
7. 같은 조건에 다시 EXPLAIN ANALYZE를 적용하세요.
8. 인덱스 생성 전후의 스캔 방식과 Execution Time을 비교하세요.
9. 다음 네 가지 기준으로 stores.city 인덱스의 적절성을 판단하세요.
   - 카디널리티
   - 선택도
   - 테이블 크기
   - 인덱스 유지 비용
10. 최종적으로 "인덱스 추가를 적극적으로 권장한다 / 우선순위가 낮다" 중 하나를 선택하고 근거를 작성하세요.
11. 실습 종료 후 idx_stores_city 인덱스를 삭제하세요.

[제출 결과]
- 데이터 분포 확인 SQL
- 인덱스 생성 전 EXPLAIN ANALYZE
- CREATE INDEX 문
- 인덱스 생성 후 EXPLAIN ANALYZE
- 네 가지 기준에 따른 판단
- 최종 결론
- DROP INDEX 문
*/

-- [코드 작성란]

-- 1. stores 테이블 전체 행 수 
-- 100개
SELECT COUNT(*) AS total_count
FROM stores;


-- 2. city 고유값 수
-- 4개
SELECT COUNT(DISTINCT city) AS city_unique_count
FROM stores;


-- 3. city별 행 수와 전체에서 차지하는 비율
SELECT
    city,
    COUNT(*) AS city_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS ratio_percent
FROM stores
GROUP BY city
ORDER BY city_count DESC;


-- 4. 기존 인덱스가 있다면 삭제
DROP INDEX IF EXISTS idx_stores_city;


-- 5. 인덱스 생성 전 EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT *
FROM stores
WHERE city = 'Mumbai';


-- 6. city 컬럼에 인덱스 생성
CREATE INDEX idx_stores_city
ON stores (city);


-- 7. 인덱스 생성 후 EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT *
FROM stores
WHERE city = 'Mumbai';



--8. 인덱스 생성 전후의 스캔 방식과 Execution Time을 비교하세요.

-- | 항목 | 인덱스 생성 전 | 인덱스 생성 후 | 
-- |-----|------------|-------------| 
-- | 스캔 방식 | Seq Scan | Seq Scan | 
-- | actual rows | 31 | 31 | 
-- | Rows Removed by Filter | 69 | 69 | 
-- | Execution Time | 0.055 ms | 0.193 ms |

--> 인덱스를 생성했지만 옵티마이저는 Seq Scan 사용했다.

--9. 다음 네 가지 기준으로 stores.city 인덱스의 적절성을 판단하세요.
--   - 카디널리티
--   - 선택도
--   - 테이블 크기
--   - 인덱스 유지 비용

-- city 컬럼은 중복 값이 많아 카디널리티가 낮고, Mumbai 조회 결과가 전체의 31%로 선택도도 높지 않다.
-- stores 테이블의 행 수가 약 100행으로 작아 Seq Scan만으로도 충분히 빠르게 조회할 수 있다.
-- 따라서 인덱스를 추가하게되면 저장 공간과 데이터를 추가하게 될 때 발생하는 인덱스 유지 비용을 고려하면 
-- 인덱스 추가는 고려해봐야할 사항이라고 판단된다.



--10. 최종적으로 "인덱스 추가를 적극적으로 권장한다 / 우선순위가 낮다" 중 하나를 선택하고 근거를 작성하세요.
---> 실제 실행계획에서 인덱스를 생성한 후에도 Index Scan이 아닌 Seq Scan을 사용하여 
---> 인덱스를 추가하면 인덱스의 저장공간과 속도 성능이 오히려 저하될 가능성이 존재하기 때문에
-----> 인덱스 추가의 우선순위는 낮다고 판단된다.


-- 11. 실습 종료 후 idx_stores_city 인덱스를 삭제하세요.
DROP INDEX idx_stores_city







