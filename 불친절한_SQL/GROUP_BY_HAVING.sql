-- group by 절에 null 이나 ()를 기술하면 전체 행이 하나의 행 그룹으로 처리된다
select sum(sal) as c1 from emp where sal > 2000 group by ();

-- 아래 쿼리는 to_char 함수를 사용하여 입사 연도별 sal의 합계값을 집계한다
select to_char(hiredate,'YYYY') as hiredate, sum(sal) as sal
from EMP
group by to_char(hiredate,'YYYY')
order by 1;

-- 집계함수를 사용한 쿼리는 where 절을 만족하는 행이 없더라도 하나의 행을 반환하지만, group by절을 사용하면 결과각 반환되지 않는다.
select nvl(max('Y'),'N') as yn from emp where empno = 9999 group by empno;

-- keep 절도 group by 절과 함께 사용할 수 있다.
select deptno,
       min(hiredate) as c1,
       min(hiredate) keep (dense_rank first order by sal) as c2
from emp
group by deptno
order by 1;


-- group by 절의 확장 기능


-- ROLLUP(expression_list [, expression_list]...)
-- 지정한 표현식의 계층별 소계와 총계를 집계한다
select deptno, count(*) as c1
from emp
where sal > 2000
group by rollup (deptno)
order by 1;


--CUBE(expression_list [, expression_list]...)
-- 지정한 표현식의 모든 조합을 집계한다
select deptno, job, count(*) as c1
from emp
where sal > 2000
group by cube(deptno, job)
order by 1, 2;


-- GROUPING SETS ({rollup_cube_clause | grouping_expression_list})
-- 지정한 행 그룹으로 행을 집계
select deptno, job, count(*) as c1
from emp
where sal > 2000
group by grouping sets(deptno, job)
order by 1,2;

select deptno, job, count(*) as c1
from emp
where sal > 2000
group by grouping sets(deptno, rollup (job))
order by 1,2;


--조합 열
-- 조합 열은 하나의 단위로 처리되는 열의 조합이다
select deptno, job, count(*) as c1
from emp
where sal > 2000
group by rollup ((deptno,job))
order by 1,2;

-- 연결 그룹
select deptno, job, count(*) as c1
from emp
where sal > 2000
group by deptno, rollup(job)
order by 1,2;


--관련 함수

--GROUPING(expr)
-- expr이 행 그룹에 포함되면 0, 포함되지 않으면 1을 반환
select deptno, job, count(*) as c1, grouping(deptno) as g1, grouping(job) as g2
from emp
where sal > 2000
group by rollup(deptno, job)
order by 1, 2;

-- GROUPING_ID(expr [,expr]...)
-- GROUPING 함수의 결과 값을 연결한 값의 비트 벡터에 해당하는 숫자 값을 반환한다
select decode(grouping_id(deptno,job),3,'TOTAL',to_char(deptno)) as detpno,
       decode(grouping_id(deptno, job),1,'ALL',job) as job,
       count(*) as c1,
       grouping(deptno) as g1, grouping(job) as g2,
       grouping_id(deptno, job) as gi,
       bin_to_num(GROUPING(deptno),grouping(job)) as bn
from EMP
where sal > 2000
group by rollup (deptno,job)
order by 6,1,2;

--GROUP_ID()
-- 중복되지 않은 행 그룹은 0, 중복된 행 그룹은 1을 반환한다. 중복된 행 그룹을 제거할 때 사용할 수 있다
select deptno, job, count(*) as c1, group_id() as gi
from emp
where sal > 2000
group by deptno, rollup (deptno, job)
-- having을 사용하면 중복된 행 그룹을 제외할 수 있다.
select deptno, job, count(*) as c1, group_id() as gi
from emp
where sal > 2000
group by deptno, rollup (deptno, job)
having group_id() = 0;