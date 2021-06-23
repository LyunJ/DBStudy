-- 집계함수는 다중 값을 단일 값으로 집계하는 함수
-- 다중 행 함수로 부르기도 한다
-- 집계함수를 사용한 쿼리는 where절을 만족하는 행이 없더라도 하나의 행을 반환한다
-- 단, group by 절이나 having 절을 사용하면 결과가 반환되지 않는다

-- 기본함수
/**
  count(*) : 모든 행의 개수
  count(expr) : null 이 아닌 expr의 개수
  count(distinct expr) : null이 아닌 고유한 expr의 개수
 */
select count(*),count(comm),count(distinct deptno) from emp;

/**
  max(expr)
 */
-- null
select max('Y') as c1 from emp where empno = 0;
-- 데이터의 존재 여부를 확인할 때 사용할 수 있다
select nvl(max('Y'),'N') as c1 from emp where empno = 0;

/**
  sum([distinct | all] expr)
 */

-- 1열,2열은 산술연산에 널이 사용됐기 때문에 널이 반환
-- 3열,4열은 결과는 동일하지만 nvl함수가 3열은 28회, 4열은 2회 수행되어 4열이 성능측면에서 효율적
-- 5열은 의도하지 않은 결과가 반환
select sum(sal+comm) as c1,
       sum(sal) + sum(comm) as c2,
       sum(nvl(sal,0)) + sum(nvl(comm,0)) as c3,
       nvl(sum(sal),0) + nvl(sum(comm),0) as c4,
       nvl(sum(sal)+sum(comm),0) as c5
from emp
where deptno = 10;

-- c1열은 산술연산자, c2열은 단항 연산자(-)를 사용
select sum(case when deptno in (10,20) then sal end)
         - sum(case when deptno = 30 then sal end) as c1,
       sum(case when deptno in (10,20) then sal when deptno = 30 then -sal end) as c2
from emp;


-- 통계함수

/**
  stddev([distinct | all] expr)
  expr의 표준편차를 반환
  */
select stddev(sal) as c1 from emp;

/**
  variance([distinct | all] expr)
  expr의 분산을 반환
  */
select variance(sal) as c1 from emp;

/**
  stats_mode(expr)
  expr의 최빈값을 반환한다
 */
select stats_mode(sal) as c1 from emp;


-- 순위함수
-- expr로 가상의 행을 생성하고, 가상의 행에 해당하는 순위를 반환한다

/**
  rank(expr [, expr]...) within group (order by expr [,expr]...)
  expr에 대한 순위를 반환.
  expr이 동일하면 동순위를 부여하고, 다음 순위는 동순위의 수만큼 건너뛴다
 */
select rank(1500) within group (order by sal) as c1,
       rank(1500,500) within group(order by sal, comm) as c2
from emp
where deptno = 30;

/**
  dense_rank(expr [, expr]...) within group (order by expr [,expr]...)
  expr에 대한 순위를 반환하되, expr이 동일하면 동순위를 부여하고, 다음 순위는 동순위에 이어서 부여한다
 */
select dense_rank(1500) within group (order by sal) as c1,
       dense_rank(1500,500) within group(order by sal, comm) as c2
from emp
where deptno = 30;

/**
  cume_dist(expr [, expr]...) within group (order by expr [,expr]...)
  expr의 누적 분포 값을 반환한다. 누적 분포값은 0<y<=1의 범위를 가진다
 */
select cume_dist(1500) within group (order by sal) as c1,
       cume_dist(1500,500) within group(order by sal, comm) as c2
from emp
where deptno = 30;

/**
  percent_rank(expr [, expr]...) within group (order by expr [,expr]...)
  expr의 백분위 순위 값을 반환
  백분위 순위 값은 0<=y<=1의 범위를 가진다
 */
select percent_rank(1500) within group (order by sal) as c1,
       percent_rank(1500,500) within group(order by sal, comm) as c2
from emp
where deptno = 30;


-- 분포함수
-- 분포모형에 따른 분포 값을 반환

/**
  percentile_cont (expr) within group (order by expr)
  연속 분포 모형에서 expr에 해당하는 백분위 값을 반환
  expr은 0~1의 범위를 지정할 수 있다
 */
select percentile_cont(0.5) within group (order by sal) as c1,
       percentile_cont(0.5) within group (order by hiredate) as c2
from emp
where deptno=30;

/**
  percentile_disc (expr) within group (order by expr)
  이산 분포 모형에서 expr에 해당하는 백분위 값을 반환한다.
  expr은 0~1의 범위를 지정할 수 있다
 */
select percentile_disc(0.5) within group (order by sal) as c1,
       percentile_disc(0.5) within group (order by hiredate) as c2
from emp
where deptno=30;

/**
  median(expr)
  연속 분포 모형의 중앙값을 반환한다
  percentile_cont(0.5) 표현식과 결과가 동일
 */
select median(sal) as c1 from emp where DEPTNO=30;


-- 기타함수
/**
  listagg (measure_expr [, 'delimiter'] [listagg_overflow_clause]) within group(order_by_clause)
  measure_expr를 order_by_clause로 정렬한 후 delimiter로 구분하여 연결한 값을 반환.
  delimiter의 기본값은 NULL
 */
select listagg(ename, ',') within group ( order by ename) as c1
from emp
where deptno = 30;

-- 연결된 문자열이 4000자보다 길면 에러 발생
with w1 as (select 'X' as c1 from dual connect by level <= 4001)
select listagg(c1) within group(order by null) as c1 from w1;

-- 12.2 버전부터 listagg overflow절을 사용하면 4000자 이상의 문자열을 처리할 수 있다
-- ON OVERFLOW {ERROR | {TRUUNCATE ['truncation-indicator' [{WITH | WITHOUT} COUNT]}
/**
  ON OVERFLOW ERROR : 문자열이 4000자보다 길면 에러를 발생시킴 (기본값)
  ON OVERFLOW TRUNCATE : 문자열이 4000자보다 길면 문자열을 잘라냄
  truncation-indicator : 줄임 기호를 지정 (기본값은 ...)
  WITH COUNT : 잘려진 문자수를 표시함(기본값)
  WITHOUT COUNT : 잘려진 문자수를 표시하지 않음
 */
with w1 as (select 'X' as c1 from dual connect by level <= 4001)
select listagg(c1 on overflow truncate) within group(order by null) as c1 from w1;


-- keep 키워드
-- keep 키워드를 사용하면 행 그룹의 최저 또는 최고 순위 행으로 집계를 수행할 수 있다.
-- 기본함수와 일부 통계함수에 사용할 수 있다

/**
  aggregate_function KEEP (DENSE_RANK {FIRST | LAST} ORDER BY expr)
  DENSE_RANK FIRST : 정렬된 행 그룹에서 최저 순위 행을 지정
  DENSE_RANK LAST : 정렬된 행 그룹에서 최고 순위 행을 지정
 */
-- sal을 기준으로 최저 순위 행은  smith, 최고 순위 행은 ford와 scott이다
select ename, sal, hiredate from emp where deptno = 20 order by 2,3,1;

-- 아래는 keep 절을 사용한 쿼리다.
-- c1,c2열은 최저 순위 행, c3,c4 열은 최고 순위 행을 각각 min,max 함수로 집계한다
select min(hiredate) keep (dense_rank first order by sal) as c1,
       max(hiredate) keep (dense_rank first order by sal) as c2,
       min(hiredate) keep (dense_rank last order by sal) as c3,
       max(hiredate) keep (dense_rank last order by sal) as c4
from emp
where deptno = 20;