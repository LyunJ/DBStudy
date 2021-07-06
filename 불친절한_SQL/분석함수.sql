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


-- 순위 함수
-- 순위 집계함수와는 다르게 가상 데이터를 생성하지 않는다
select empno, ename, sal,
       row_number() over (order by sal) as c1,
       RANK() over(order by sal) as c2,
       dense_rank() over(order by sal) as c3
from emp
where deptno = 30
order by 2, 1;

-- ntile
/**
  ntile (expr) over ([query_partition_clause] order_by_clause)
  order_by_clause에 따라 행을 정렬하고 expr의 개수만큼 버킷을 생성한 후, 행에 해당하는 버킷 번호를 할당
 */

select sal,
       ntile(1) over (order by sal) as c1,
       ntile(2) over ( order by sal ) as c2,
       ntile(3) over ( order by sal ) as c2,
       ntile(4) over ( order by sal ) as c2,
       ntile(5) over ( order by sal ) as c2,
       ntile(6) over ( order by sal ) as c2,
       ntile(7) over ( order by sal ) as c2
from emp
where deptno = 30
order by 1;

-- ntile 함수로 생성한 버킷으로 행을 집계
select c1, count(*) as c2, sum(sal) as c3
from (select sal, ntile(4) over (order by sal) as c1 from emp where deptno = 30)
group by c1
order by c1;

-- row_number로 생성한 순번에 ceil 함수를 사용하면 다른 형태의 행 그룹을 생성할 수 있다
select c1, count(*) as c2, sum(SAL) as c3
from (select sal,
             ceil(row_number() over (order by sal, empno) / (count(*) over () / 4)) as c1
    from emp
    where deptno = 30)
group by c1
order by 1;

-- row_number로 생성한 순번에 mod함수를 사용하면 또 다른 형태의 행 그룹을 생성한다
select c1, count(*) as c2, sum(SAL) as c3
from (select sal,
             mod(row_number() over (order by sal, empno),4) as c1
    from emp
    where deptno = 30)
group by c1;

-- ntile과 ceil함수는 순차적인 행 그룹, mod함수는 순환적인 행 그룹이 생성된다


-- cume_dist
-- 누적분포
select sal,
       cume_dist() over ( order by sal) as c1,
       count(*) over (order by sal) / count(*) over (  ) as c2
from emp
where deptno = 30
order by sal;


-- percent_rank
-- 백분위 순위 값
-- 순위의 대상을 100건으로 가정했을 때의 상대 순위
select sal,
       percent_rank() over (order by sal) as c1,
       (rank() over (order by sal) - 1) / (count(*) over () - 1) as c2
from emp
where deptno = 30
order by 1;


-- ratio_to_report
-- expr의 합계에 대한 현재 expr의 비율을 반환
select sal,
       ratio_to_report(SAL) over () as c1,
       sal / sum(sal) over (  ) as c2
from emp
where deptno = 30
order by sal;


-- 기타함수



-- lag 함수
/*
 lag (value_expr [, offset [, default]]) [ignore nulls] over ([query_partition_clause] order_by_clause)
 현재 행에서 offset 이전 행의 value_expr을 반환한다.
 offset은 행 기준이면 기분값은 1이다
 default에 이전 행이 없을 경우 반환할 값을 지정할 수 있다
 default의 기본값은 널이다
 */
select hiredate, sal,
       lag(sal) over ( order by HIREDATE ) as c1,
       lag(sal,3) over ( order by hiredate ) as c2
from EMP
where deptno = 30
order by 1;
--  기본값이 999이므로 이전값이 없는 1행과 2행은 999가된다
-- ignore nulls 조건으로 null을 무시한 결과가 나온다
select ename, HIREDATE, COMM,
       lag(comm,2,999) ignore nulls over ( order by HIREDATE) as c1
from EMP
where deptno = 30
order by 2;

-- lead 함수
/*
 lead (value_expr [, offset [, default]]) [ignore nulls] over ([query_partition_clause] order_by_clause)
 현재 행에서 offset 이후 행의 value_expr을 반환한다.
 */
select hiredate, sal,
       lead(sal) over ( order by HIREDATE ) as c1,
       lead(sal,3) over ( order by hiredate ) as c2
from EMP
where deptno = 30
order by 1;

/*
 lag와 lead 함수를 쓸 때 주의할 점
 행 기준으로 동작하므로 분석 함수의 정렬 값이 고유하지 않으면 값이 무작위로 변경될 수 있다
 */
 select empno, ename, sal, comm,
        lead(comm) over ( order by SAL) as c1
from EMP
where deptno = 30
order by 3, 1;
-- james의 c1값이 변경되었다
 select empno, ename, sal, comm,
        lead(comm) over ( order by SAL) as c1
from EMP
where deptno = 30
order by 3, 2;
-- empno를 추가하여 정렬값을 고유하게 만들어 준다
 select empno, ename, sal, comm,
        lead(comm) over ( order by SAL, empno) as c1
from EMP
where deptno = 30
order by 3, 1;


--listagg함수
/*
 listagg(measure_expr [, 'deleimiter'][listagg_overflow_clause])
 within group (order_by_clause) [over query_partition_clause]
 measure_expr를 order_by_clause로 정렬한 후 delimiter로 구분하여 연결한 값을 반환
 delimiter의 기본값은 널이다
 */
select job, ename,
       listagg(ename,',') within group ( order by ENAME) over ( partition by job ) as c1
from emp
where deptno = 30
order by job, ename;


-- 활용 예제
-- 선분 이력 전환
drop table t1 purge;
create table t1 (cd varchar2(1), dt date, vl number);

insert into t1 values('A',date '2050-01-01',1);
insert into t1 values('A',date '2050-01-06',2);
insert into t1 values('A',date '2050-01-16',1);
insert into t1 values('A',date '2050-01-31',3);
commit;

-- 아래와 같이 lead 함수를 사용하면 점 이력을 선분 이력으로 변환할 수 있다
select cd, dt as bg_dt,
       lead(dt - 1, 1, date'9999-12-31') over (order by dt) as ed_dt, vl
from t1
order by 1,2;

-- 선분 이력 전환2
-- 월별 이력을 선분 이력으로 전환시켜보자
drop table t1 purge;
create table t1 (cd varchar2(1),ym varchar2(6), vl number);

insert into t1 values ('A','205001',1);
insert into t1 values ('A','205002',1);
insert into t1 values ('A','205003',2);
insert into t1 values ('A','205004',2);
insert into t1 values ('A','205005',2);
insert into t1 values ('A','205006',1);
insert into t1 values ('A','205007',1);
insert into t1 values ('A','205008',1);
insert into t1 values ('A','205009',1);
insert into t1 values ('A','205010',3);
insert into t1 values ('A','205011',3);
insert into t1 values ('A','205012',3);
commit;
-- row_number 함수로 생성한 순번의 차를 이용하여 행 그룹을 생성했다
select cd, min(ym) as bg_ym,
       case when max(r1) = max(cn) then '999912' else max(ym) end as ed_ym, vl
from (select a.*,
             count(*) over ( partition by a.cd ) as cn,
             row_number() over (partition by a.cd order by a.ym) as r1,
             row_number() over (partition by a.vl order by a.ym) as r2
    from t1 a)
group by cd,vl,r1-r2
order by 1,2;


-- 선분 이력 병합
drop table t1 purge;
create table t1 (cd varchar2(1),bg number, ed number, yn varchar2(1));

insert into t1 values ('A',1,2,'Y');
insert into t1 values ('A',2,3,'N');
insert into t1 values ('A',3,4,'N');
insert into t1 values ('A',4,5,'Y');
insert into t1 values ('A',5,6,'Y');
insert into t1 values ('A',6,7,'N');
insert into t1 values ('A',7,8,'N');
insert into t1 values ('A',8,9,'Y');
commit;

-- yn이 N인 행의 이력을 병합한다.
select cd, min(bg) as bg, max(ed) as ed, yn
from (select a.*,
             row_number() over ( partition by cd order by bg ) as r1,
             row_number() over (partition by cd,yn order by bg) as r2
    from t1 a)
group by cd, yn, case when yn = 'N' then r1 - r2 else r1 end
order by 1,2;


-- 행 패턴 검색
drop table t1 purge;
create table t1 (cd varchar2(1), dt date, vl number);

insert into t1 values ('A', date '2050-01-01', 100);
insert into t1 values ('A', date '2050-01-02', 200);
insert into t1 values ('A', date '2050-01-03', 300);
insert into t1 values ('A', date '2050-01-04', 400);
insert into t1 values ('A', date '2050-01-05', 500);
insert into t1 values ('A', date '2050-01-06', 400);
insert into t1 values ('A', date '2050-01-07', 500);
insert into t1 values ('A', date '2050-01-08', 600);
insert into t1 values ('A', date '2050-01-09', 700);
insert into t1 values ('A', date '2050-01-10', 500);
commit;

-- with 절에서 전일 대비 값(df)를 생성했다.
-- df 가 -1이면 하락, 0이면 유지, 1이면 상승
-- r1 은 cd 파티션의 순번, r2는 cd, df파티션의 순번이다
with w1 as (select a.*,
           nvl(sign(vl - lag(vl) over ( partition by cd order by dt )), 0) as df from t1 a)
select a.*,
       row_number() over (partition by cd order by dt) as r1,
       row_number() over (partition by cd, df order by dt) as r2
from w1 a
order by 1,2;

-- 가격이 3일 이상 상승한 구간을 조회
with w1 as (select a.*,
           nvl(sign(vl - lag(vl) over ( partition by cd order by dt )), 0) as df from t1 a)
select a.*
from (select a.*,
             count(*) over ( partition by cd, rn) as cn
    from (select a.*,
                 row_number() over (partition by cd order by dt) - row_number() over (partition by cd, df order by dt) as rn from w1 a) a where df = 1) a
where cn >= 3;

-- 아래와 같이 match_recognize 절을 사용하면 쿼리를 간결하게 작성할 수 있다.
select cd, dt, vl, cn
from t1
match_recognize (
    partition by cd order by dt
    measures final count(*) as cn
    all rows per match
    pattern (up{3,})
    define up as up.vl > prev (up.vl)
    )
order by cd,dt;


-- 선형 보간 (두 지점 사이의 값을 두 지점의 직선 거리에 따라 선형적으로 결정하는 방법이다)
drop table t1 purge;
create table t1 (cd varchar2(1), dt date, vl number);
insert into t1 values ('A', date'2050-01-01',100);
insert into t1 values ('A', date'2050-01-04',400);
insert into t1 values ('A', date'2050-01-08',800);
commit;

-- 선형 보간 수행.
-- 행 복제 기법을 사용하여 데이터가 존재하지 않는 구간의 행을 생성하고, lead 함수를 사용하여 보간 값을 계산한다
select a.dt + b.lv - 1 as dt,
       round(a.vl + (a.vl_df / a.dn) * (b.lv - 1), 2) as vl
from (select a.*,
             nvl(lead(a.vl) over ( order by a.dt ) - a.vl,0) as vl_df,
             nvl(lead(a.dt) over ( order by a.dt ) - a.dt, 1) as dn
    from t1 a) a,
     (select level as lv from dual connect by level <= 10) b
where b.lv <= a.dn
order by 1;