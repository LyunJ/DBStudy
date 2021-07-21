-- PIVOT과 UNPIVOT절은 11.1버전부터 사용 가능하다
/*
 PIVOT [XML]
 (aggregate_function (expr) [[AS] alias]
 [, aggregate_function (expr) [[AS] alias]] ...
    FOR {column | (column [, column] ...)}
    IN({{{expr | (expr [, expr] ...)} [[AS] alias]} ...
        | subquery
        | ANY [, ANY]...
        })
    )

 aggregate_function : 집계할 열을 지정
 FOR 절 : PIVOT 할 열을 지정
 IN 절 : PIVOT 할 열 값을 지정
 */

-- PIVOT절은 집계함수와 FOR절에 지정되지 않은 열을 기준으로 집계되기 때문에 인라인 뷰를 통해 사용할 열을 지정해야 한다
select *
from (select job, deptno, sal from emp)
pivot (sum(sal) for deptno in (10,20,30))
order by 1;

select *
from (select job, to_char(hiredate, 'YYYY') as yyyy, deptno, sal from emp)
pivot (sum(sal) for deptno in (10,20,30))
order by 1, 2;

select *
from (select job, to_char(hiredate, 'YYYY') as yyyy, deptno, sal from emp)
pivot (sum(sal) as sal for deptno in (10 as d10,20 as d20,30 as d30))
order by 1, 2;

select job,d20_sal
from (select job, to_char(hiredate, 'YYYY') as yyyy, deptno, sal from emp)
pivot (sum(sal) as sal for deptno in (10 as d10,20 as d20,30 as d30))
order by 1, 2;

--PIVOT절은 다수의 집계함수를 지원한다
SELECT *
FROM (SELECT JOB, DEPTNO, SAL FROM EMP)
PIVOT (SUM(SAL) AS SAL, COUNT(*) AS CNT FOR DEPTNO IN (10 AS D10, 20 AS D20))
ORDER BY 1;

-- FOR절에도 다수의 열을 기술할 수 있다
SELECT * FROM (SELECT TO_CHAR(hiredate, 'YYYY') as yyyy, deptno, job, sal from emp)
pivot (sum(sal) as sal, count(*) as cnt
    for (deptno, job) in ((10,'ANALYST') AS d10a, (10, 'CLERK') AS d10C,
        (20,'ANALYST') AS d20a, (20,'CLERK') AS d20c))
order by 1;

-- pivot절에 xml 키워드를 기술하면 xml 포맷으로 결과가 반환된다.
-- xml 키워드를 사용하면 in 절에 서브 쿼리와 any 키워드를 사용할 수 있다
select *
from (select job, deptno, sal from emp)
pivot xml (sum(sal) as sal for deptno in (select deptno from dept))
order by 1;
-- any 키워드는 존재하는 값과 일치하는 와일드 카드로 동작한다
select *
from (select job, deptno, sal from emp)
pivot xml (sum(sal) as sal for deptno in (any))
order by 1;

--11.1 이전 버전
select job,
       sum(decode(deptno,10,sal)) as d10_sal,
       sum(decode(deptno,20,sal)) as d20_sal,
       sum(decode(deptno,30,sal)) as d30_sal
from emp
group by job
order by job;

-- unpivot절
/*
 UNPIVOT [{INCLUDE | EXCLUDE} NULLS]
 (  {column | (column [, col]...)}
 FOR {column | (column [, col]...)}
 IN ({column | (column [, col]...)} [as{literal | (literal [, literal]...)}]
 [, {column | (column [, col]...)} [as{literal | (literal [, literal]...)}] ]
    )
 )

 UNPIVOT column : UNPIVOT된 값이 들어갈 열을 지정
 FOR 절 : UNPIVOT된 값을 설명할 값이 들어갈 열을 지정
 IN 절 : UNPIVOT할 열과 설명할 값의 리터럴 값을 지정
 */

DROP TABLE t1 purge;

create table t1 as
    select job, d10_sal, d20_sal, d10_cnt, d20_cnt
from(select job, deptno, sal from emp where job in ('ANALYST','CLERK'))
pivot(sum(sal) as sal, count(*) as cnt for deptno in (10 as d10, 20 as d20));

select * from t1 order by job;

select job, deptno, SAL
from t1
unpivot(sal for deptno in (d10_sal, d20_sal))
where job = 'CLERK'
order by 1,2;

select job, deptno, SAL
from t1
unpivot(sal for deptno in (d10_sal as 10, d20_sal as 20))
where job = 'CLERK'
order by 1,2;

-- include nulls 키워드는 열의 값이 널인 행도 결과에 포함된다
select job, deptno, SAL
from t1
unpivot include nulls (sal for deptno in (d10_sal as 10, d20_sal as 20))
order by 1,2;

--unpivot 절도 다수의 열을 지정할 수 있다
select *
from t1
unpivot ((sal,cnt) for deptno in ((d10_sal,d10_cnt) as 10, (d20_sal,d20_cnt) as 20))
order by 1,2;

-- 다수의 별칭도 가능
select *
from t1
unpivot ((sal,cnt) for (deptno,dname) in ((d10_sal,d10_cnt) as (10,'ACCOUNTING'), (d20_sal,d20_cnt) as (20,'RESEARCH')))
order by 1,2;


-- PIVOT절과 UNPIVOT절을 함께 사용할 수도 있다.
-- PIVOT 절의 결과가 UNPIVOT 절에 인라인 뷰로 공급되는 방식이다.
-- INCLUDE NULLS 키워드로 파티션 아우터 조인의 동작을 구현할 수 있다
select *
from (select job, deptno, sal, comm from emp)
pivot (sum(sal) as sal, sum(comm) as comm for deptno in (10 as d10, 20 as d20, 30 as d30))
unpivot include nulls
((sal,comm) for deptno in ((d10_sal,d10_comm) as 10,
    (d20_sal, d20_comm) as 20,
    (d30_sal, d30_comm) as 30))
order by 1, 2;

-- 11.1 이전 버전에서는 카티션 곱을 사용하여 unpivot을 수행할 수 있다
select a.job,
       decode(b.lv, 1, 10, 2, 20) as deptno,
       decode(b.lv, 1, a.d10_sal, 2, a.d20_sal) as sal,
       decode(b.lv, 1, a.d10_cnt, 2, a.d20_cnt) as cnt
from t1 a,
     (select level as lv from dual connect by level <= 2) b
order by 1, 2;


-- dense_rank 함수를 사용하여 값이 아닌 순번으로 pivot 수행
with w1 as (
    select job, to_char(hiredate, 'YYYY') as hireyear, sum(sal) as sal
    from emp
    group by job, to_char(hiredate, 'YYYY'))
select *
from (select a.*, dense_rank () over(order by a.hireyear) as dr from w1 a)
pivot(max(hireyear), max(sal) as sal
    for dr in (1 as y1, 2 as y2, 3 as y3, 4 as y4, 5 as y5))
order by job;

-- 전체 열 unpivot
-- 테이블의 전체 열을 unpivot하여 값을 조회하거나 집계할 수 있다
-- in에 입력되는 값은 데이터 타입이 모두 동일해야한다
with w1 as(
    select to_char(empno) as empno, ename, job, to_char(mgr) as mgr,
           to_char(hiredate, 'YYYY-MM-DD') as hiredate, to_char(sal) as sal,
           to_char(comm) as comm, to_char(deptno) as deptno
    from emp
    where empno = 7788
)
select *
from w1
unpivot(value for column_name in (empno,ename,job,mgr,hiredate,sal,comm,deptno));

-- 열 값의 분포
select column_name, value, count(*) as cnt
from (select job, to_char(deptno) as deptno from emp)
unpivot (value for column_name in (job,deptno))
group by column_name, value
order by 1,2;