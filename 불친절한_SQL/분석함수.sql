-- emp table을 두 번 접근하기 때문에 비효율적
select a.empno, a.sal, b.sal as c1, a.sal / b.sal as c2
from emp a,(select deptno, sum(sal) as sal from emp group by deptno) b
where a.deptno = 10 and b.deptno = a.deptno
order by 1;
-- 분석함수를 사용하여 효율을 높인다
select empno, sal, sum(sal) over() as c1, ratio_to_report(sal) over() as c2
from emp
where deptno = 10
order by 1;


/**
  집계함수에 over 키워드를 기술하면 분석 함수로 동작

  analytic_function ([arguments]) over (analytic_clause)

  analytic_clause는 query partition clause, order by clause, windowing clause로 구성된다
  [query_partition_clause][order_by_clause [windowing_clause]]
 */

 -- QUERY PARTITION CLAUSE
/**
  PARTITION BY expr [, expr]...

  - expr로 파티션을 지정할 수 있다.
  - 파티션은 행 그룹과 유사
  - 분석을 위한 정적 그룹으로 생각할 수 있음
  - query partition 절을 생략하면 전체 행이 하나의 파티션으로 동작
 */
select empno, job, sal,
       sum(sal) over ( partition by job ) as c1,
       sum(sal) over () as c2
from emp
where DEPTNO = 30
order by 2, 1;


-- ORDER BY CLAUSE
/**
  ORDER BY expr [ASC|DESC] [NULLS FIRST | NULLS LAST] [,expr [ASC|DESC] [NULLS FIRST | NULLS LAST] ...]
 */
select empno, sal, sum(sal) over (ORDER BY SAL, EMPNO) as c1
from EMP
where deptno = 30
order by 2, 1;


-- WINDOWING CLAUSE
/**
  {ROWS | RANGE}
    {BETWEEN {UNBOUNDED PRECEDING | CURRENT ROW | value_expr {PRECEDING | FOLLOWING}}
        AND {UNBOUNDED FOLLOWING | CURRENT ROW | value_expr {PRECEDING | FOLLOWING}}
  | {UNBOUNDED PRECEDING | CURRENT ROW | value_expr PRECEDING}}

  파티션의 윈도우를 직접 지정할 수 있다
  윈도우는 파티션 내의 동적 그룹으로 생각할 수 있다

  ROWS와 RANGE의 동작방식
  ROWS
  윈도우 기준 : 물리적 행
  동일한 정렬 값 : 다른 값을 반환
  value_expr 계산 : 정렬 행의 위치
  RANGE
  윈도우 기준 : 논리적 범위
  동일한 정렬 값 : 같은 값을 반환
  value_expr 계산 : 정렬 값

  WINDOWING 절을 지정하지 않았을 때의 기본값은 RANGE UNBOUNDED PRECEDING 이다
  따라서 현재 행에서 위로 끝까지가 윈도우의 범위이다.
 */

-- 정렬 값이 고유하고 윈도우에 value_expr을 사용하지 않으면 ROWS 방식과 RANGE 방식은 동일한 결과를 반환한다
select empno, ename, sal,
       sum(sal) over ( order by sal rows unbounded preceding) as c1,
       sum(SAL) over (order by sal range unbounded preceding ) as c2,
       sum(SAL) over (order by sal, empno rows unbounded preceding) as c3,
       sum(SAL) over (order by sal, empno range unbounded preceding ) as c4
from emp
where DEPTNO = 30
order by 3,1;

-- 아래쿼리는 파티션과 윈도우를 모두 지정했다.
-- 정적 그룹인 파티션 내에서 동적 그룹인 윈도우로 값이 집계된다
select job, hiredate, sal,
       sum(sal) over(partition by job order by HIREDATE) as c1
from emp
where deptno = 30
order by 1,2;


-- keep 키워드
-- keep 키워드를 사용하면 analytic clause에 query partition clause만 사용할 수 있다
select ename, job, sal, comm, max(comm) keep ( dense_rank first order by sal ) over ( partition by job) as c1
from emp
where deptno = 30
order by 2,3,4;


-- 주의사항
-- range 방식에 value_expr을 지정하면 order by 절에 숫자 값이나 날짜 값을 사용해야 한다
select job, sal, sum(sal) over ( order by
    job range 1 preceding ) as c1
from EMP
where deptno = 30;

-- range 방식에 value_expr을 지정하면 정렬 표현식을 1개만 사용할 수 있다.
select job, sal, sum(SAL) over ( order by sal, comm range 1 preceding ) as c1
from EMP
where deptno = 30;

-- 정렬 표현식이 날짜 값인 경우 value_expr에  숫자 값과 인터벌 값을 사용할 수 있다
select hiredate, sal,
       sum(SAL) over (order by hiredate range 90 preceding ) as c1,
       sum(SAL) over ( order by HIREDATE range interval '3' month preceding ) as c2
from emp a
where deptno = 30
order by 1;

-- 아래 쿼리는 where 절에 분석 함수를 사용하여 에러가 발생했다
-- 분석 함수는 select 절과 order by 절에 사용할 수 있다.
select deptno, ename, sal
from emp
where sum(SAL) over ( partition by DEPTNO) >= 10000;

--인라인 뷰를 사용하면 where 절에서 분석 함수의 결과 값을 사용할 수 있다
select deptno, ename, sal, c1
from (select a.*, sum(a.sal) over (partition by a.deptno) as c1 from emp a)
where c1 >= 10000
order by 1,2;

-- 아래 쿼리의 c2,c3 열에 사용한 분석 함수는 그룹핑이 완료뒨 후 수행된다
select deptno,
       sum(sal) as c1, sum(sum(sal)) over (  ) as c2, count(*) over () as c3
from emp
group by deptno
order by 1;

-- 아래와 같이 인라인 뷰를 통해 집계 쿼리와 분석 함수를 분리하는 편이 가독성 측면에서 바람직하다
select deptno, c1, sum(c1) over (  ) as c2, count(*) over () as c3
from (select deptno, sum(sal) as c1 from emp group by deptno)
order by 1;

-- 분석 함수로 결과 집합을 생성한 후 중복 값을 제거하기 위해 distinct 키워드를 사용했다
select distinct deptno, sum(sal) over(partition by deptno) as c1
from emp;

-- 행 그룹으로 집계할 경우에는 분석 함수가 아닌 group by 절을 사용해야 한다
select deptno, sum(sal) as c2 from emp group by deptno;