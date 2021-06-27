/**
  중첩 서브 쿼리(nested subquery) : where 절, having 절
  스칼라 서브 쿼리(scalar subquery) : select 절
  인라인 뷰(inline view) : from 절
 */

drop table t1 purge;
drop table t2 purge;

create table t1 (c1 number not null, c2 number not null);
create table t2(c1 number not null, c2 number);

insert into t1 values (1,2);
insert into t1 values (2,1);
insert into t1 values (2,3);
insert into t1 values (3,4);
insert into t2 values (1,2);
insert into t2 values (2,3);
insert into t2 values (2,null);
commit;
-- 중첩 서브 쿼리

-- 비상관 서브 쿼리
-- 메인 쿼리와 관계가 없는 서브 쿼리
-- 단일 행 비상관 서브 쿼리
select * from t1 where c1 = (select max(c1) as c1 from t2);
-- 다중 행 비상관 서브 쿼리
select * from t1 where c1 in (select c1 from t2);
-- 중복값이 자동으로 무시된다 distinct 필요 없음
select * from t1 where c1 in (select distinct c1 from t2);

-- not in 조건
select * from t1 where c1 not in (select c1 from t2);
-- 아래 쿼리는 t2의 c2열에 널이 존재하기 때문에 결과가 반환되지 않는다
-- c2 <> 2 and c2 <> 3 and null -> and null은 항상 unknown이기 때문에 결과가 반환되지 않는다
select * from t1 where c2 not in (select c2 from t2);
-- 사용 가능한 쿼리
select * from t1 where c2 not in (select c2 from t2 where c2 is not null);


-- 상관 서브 쿼리
-- 메인 쿼리와 관계가 있는 서브 쿼리

-- 단일 행 상관 서브 쿼리
select a.* from t1 a where a.c2 = (select max(x.c2) from t2 x where x.c1 = a.c1);

-- 다중 행 상관 서브 쿼리

-- exists 조건
select a.* from t1 a where exists(select 1 from t2 x where x.c1 = a.c1);

-- 쿼리의 특정 행을 무조건 반환해야 할 경우
select a.*
from t1 a
where exists(select 1 from dual where a.c1 = 2 union all
                select 1 from t2 x where x.c2 = a.c2) ;

/**
  in 조건은 서브 쿼리를 먼저 조회하여 메인 쿼리에 값을 공급한다
  exists 조건은 메인 쿼리를 먼저 조회하여 서브 쿼리로 존재 여부를 확인한다
  in 조건과 exists 조건은 결과가 항상 같다
  하지만 not in조건과 not exists 조건은 서브 쿼리의 널 존재 여부에 따라 결과가 달라질 수 있다

  not exists 조건은 다중 열에 널이 존재하더라도 정상적인 결과를 반환한다
  not in 조건보다 not exists 조건을 사용하는 편이 바람직 하다
 */
select * from t1 where c2 in (select c2 from t2);
select * from t1 a where exists(select 1 from t2 x where a.c2 = x.c2);

select * from t1 where c2 not in (select c2 from t2);
select * from t1 a where not exists(select 1 from t2 x where x.c2 = a.c2)

select * from t1 where (c1,c2) not in (select c1,c2 from t2);
select a.* from t1 a where not exists(select 1 from t2 x where a.c1 = x.c1 and a.c2 = x.c2);


-- 스칼라 서브 쿼리
-- select 절에 사용하는 서브 쿼리
-- 스칼라는 단일 값을 의미한다
select a.c1, (select max(x.c2) from t2 x where x.c1 = a.c1) as c2 from t1 a;
-- 스칼라 서브 쿼리에서 다중 행이 반환되면 에러가 발생한다
select (select x.c2 from t2 x where x.c1 = a.c1) as c2 from t1 a;

-- 스칼라 서브 쿼리에서 값을 연결한 후, 인라인 뷰 밖에서 연결한 값을 분리하는 기법을 사용하면 emp 테이블을 1번만 조회할 수 있다.
select deptno, dname,
       to_number(regexp_substr(sal,'[^,]+',1,1)) as sal_min,
       to_number(regexp_substr(sal,'[^,]+',1,2)) as sal_max
from (select a.deptno, a.dname,
             (select min(x.sal) || ',' || max(x.sal)
                 from emp x
                 where x.deptno = a.deptno) as sal
    from dept a);

-- 인라인 뷰
-- from 절에 사용하는 서브 쿼리
-- 인라인 뷰는 쿼리에서 즉시 처리되는 뷰를 의미한다
/**
  단순 뷰 : 결과 집합의 변경이 없음
  복합 뷰 : 결과 집합의 변경이 있을 수 있음 (distinct 키워드, group by 절)
 */
-- 단순 인라인 뷰
select a.dname, b.ename
from (select * from dept where loc = 'DALLAS') a,
     (select * from emp where job = 'CLERK') b
where b.deptno = a.deptno;

-- 복합 인라인 뷰
-- 복합 인라인 뷰를 사용하면 조인 차수를 1:1로 만들 수 있다
select a.dname, b.sal
from dept a,
     (select deptno, sum(sal) as sal from emp group by deptno) b
where b.deptno = a.deptno;


-- 사용기준
/**
  조인 : 조인 기준의 행이 줄어들거나 늘어날 수 있음
  중첩 서브 쿼리 : 메인 쿼리의 행이 줄어들 수 있지만 늘어나지는 않음
  스칼라 서브 쿼리 : 메인 쿼리의 행이 변하지 않음
  인라인 뷰 : 메인 쿼리의 행이 줄어들거나 늘어날 수 있음 (조인과 동일)
 */
-- 중첩 서브 쿼리
-- 서브쿼리로 메인 쿼리의 결과 집합을 제한할 때 사용
-- exists 조건은 조인되는 값의 종류가 적고, 서브 쿼리 테이블의 크기가 클 때 유용하다.
-- 그렇지 않다면 아래와 같이 인라인 뷰를 사용하는 편이 성능 측면에서 유리하다
select a.deptno, a.dname
from dept a
where exists(select 1 from emp x where x.deptno = a.deptno);

select a. deptno, a.dname
from dept a, (select distinct deptno from emp) b
where a.deptno = b.deptno;

-- 위 쿼리를 조인으로 변경하면 메인 쿼리의 행이 M으로 늘어나기 때문에 distinct 키워드로 중복 값을 제거해야 한다. 성능 측면에서 비효율적
select distinct a.deptno, a.dname from dept a, emp b where b.DEPTNO = a.DEPTNO;

-- 아래 쿼리는 메인 쿼리와 서브 쿼리의 조인 차수가 M:1이기 때문에 중첩 서브 쿼리를 사용할 필요가 없다
select a.empno, a.ename from emp a where exists(select 1 from dept x where x.deptno = a.deptno);

-- 아래와 같이 조인으로 변경해도 결과가 동일하다.
-- exists 조건은 메인 쿼리와 서브 쿼리의 조인 차수가 1:M일 때 사용하는 것이 일반적이다
select a.empno, a.ename from emp a, dept b where a.deptno = b.deptno;

--not exists 조건은 메인 쿼리와 서브 쿼리의 조인 차수에 관계없이 모두 사용할 수 있다
select a.deptno, a.dname
from dept a
where not exists(select 1 from emp x where x.deptno = a.deptno);

-- not exists 조건은 아래와 같이 아우터 조인으로도 작성할 수 있지만 가독성과 성능 측면에서 not exists 조건을 사용하는 편이 바람직 하다
select a.deptno, a.dname
from dept a, (select distinct deptno from emp) b
where b.deptno(+) = a.deptno
and b.deptno is null;

-- 아래 쿼리는 not exists 조건과 다른 결과를 반환한다
select a.deptno, a.dname
from dept a, (select distinct deptno from emp ) b
where b.deptno <> a.deptno;


-- 스칼라 서브 쿼리
-- 서브 쿼리로 단일 값을 조회할 때 사용

-- 메인쿼리(dept)와 서브쿼리(emp)의 조인 차수가 1:M이지만 메인 쿼리의 행이 변경되지 않는다.
-- 조인에 실패한 행은 널을 반환한다.
select a.deptno, a.dname,
       (select min(sal) from emp x where x.deptno = a.deptno) as sal_min,
       (select max(sal) from emp x where x.deptno = a.deptno) as sal_max
from dept a;

-- 스칼라 서브 쿼리는 조인되는 값의 종류가 적고, 서브 쿼리 테이블의 크기가 클 때 유용하다.
-- 그렇지 않다면 아래와 같이 인라인 뷰로 변경하는 편이 성능 측면에서 유리하다
select a.deptno, a.dname, b.sal_min, b.sal_max
from dept a,
     (select deptno, min(sal) as sal_min, max(sal) as sal_max from emp group by deptno) b
where b.deptno(+) = a.deptno;

-- 위 쿼리는 아래 쿼리로 변경할 수 있다
-- 메인 쿼리의 행이 변경되지 않아야 하므로 아우터 조인으로 조인해야 한다
select a.deptno, a.dname, min(sal) as sal_min, max(sal) as sal_max
from dept a, emp b
where b.DEPTNO(+) = a.deptno
group by a.deptno, a.dname;

-- 아래 쿼리는 메인 쿼리와 서브 쿼리의 조인 차수가 M:1이기 때문에 스칼라 서브 쿼리를 사용할 필요가 없다.
-- 스칼라 서브 쿼리는 메인 쿼리와 서브 쿼리의 조인 차수가 1:M일 때 사용하는 것이 일반적이다
-- 스칼라 서브 쿼리의 캐싱 기능을 통한 성능 개선은 논외
select a.empno, a.ename,
       (select x.dname from dept x where x.deptno = a.deptno) as dname
from emp a;

-- 위 쿼리는 아래 쿼리와 결과가 동일
select a.empno, a.ename, b.dname from emp a, dept b
where b.deptno = a.deptno;

-- 필수 관계라도 스칼라 서브 쿼리에 일반 조건이 존재 하면 아우터 조인으로 조인해야 한다
select a. empno, a.ename,
       (select x.dname
           from dept x
           where x.deptno = a.deptno and x.loc = 'DALLAS') as dname
from emp a;
-- 위의 쿼리는 아래로 변경해야 동일한 결과를 얻을 수 있다
select a.empno, a.ename, b.dname
from emp a, dept b
where b.deptno(+) = a.deptno and b.loc(+) = 'DALLAS';

--아래의 쿼리는 메인 쿼리에 일반조건이 존재
select a. empno, a.ename,
       (select x.dname
           from dept x
           where x.deptno = a.deptno and a.job = 'CLERK') as dname
from emp a;
--위의 쿼리는 아래처럼 바꿀 수 있다
select a. empno, a.ename,b.dname
from emp a left outer join dept b on a.job = 'CLERK' and b.deptno = a.deptno;


-- 인라인 뷰
-- 복합뷰는 인라인 뷰로 새로운 결과 집합을 만들거나 조인 차수를 1:1관계로 만들 때 사용한다
-- 단순 뷰는 조인 순서를 제어하거나 반복되는 표현식을 제거할 때 사용할 수 있다

-- 아래 쿼리는 sal + NVL(comm,0) 표현식이 반복 사용되고 있다
select deptno,
       min(sal + nvl(comm,0)) as sal_min,
       max(sal + nvl(comm,0)) as sal_max
from emp
group by deptno;
-- 단순 뷰를 사용하면 표현식을 한번만 기술할 수 있다
select deptno, min(sal), max(sal)
from (select deptno, sal + nvl(comm,0) as sal from emp)
group by deptno;


-- with 절

-- SUBQUERY FACTORING절
-- 인라인 뷰와 유사하게 동작하지만 가독성을 높일 수 있는 장점이 있다
with w1 as (select deptno, sum(sal) as sal from emp group by deptno)
select a.deptno, b.dname, a.sal
from w1 a, dept b
where b.deptno = a.deptno;

-- subquery factoring절에 기술한 서브 쿼리를 2번 이상 사용하면 서브 쿼리의 결과 집합이 임시 영역에 저장된다
-- 12.2 버전부터 크기가 큰 결과집합이 임시 영역에 저장될 때의 성능 저하 개선을 위해 결과 집합을 메모리(PGA)에 먼저 저장하고, 공간이 부족한 경우 임시 영역(disk)를 사용하도록 기능이 개선되었다
with w1 as (select deptno, sum(sal ) as sal from emp group by deptno)
, w2 as (select sum(sal) as sal from w1)
select a.deptno, a.dname, b.sal, (b.sal/c.sal)*100 as rt
from dept a, w1 b, w2 c
where b.deptno = a.deptno;


-- 신규 기능
-- lateral 인라인 뷰
-- lateral 인라인 뷰를 사용하면 인라인 뷰에 메인 쿼리의 열을 기술할 수 있다

-- 아래 쿼리는 인라인 뷰에 메인 쿼리의 열을 기술했기 때문에 에러가 발생했다.
select a.dname,b.empno,b.ename
from dept a,
     (select x.* from emp x where x.deptno = a.deptno) b;

-- lateral 인라인 뷰를 사용하면 인라인 뷰에 메인 쿼리의 열을 기술할 수 있다
select a.deptno, a.dname, b.empno, b.ename
from dept a,
     lateral ( select x.* from emp x where x.deptno = a.deptno ) b;

-- lateral 인라인 뷰 뒤에 (+) 기호를 기술하면 아우터 조인으로 조인된다
select a.deptno, a.dname, b.empno, b.ename
from dept a,
     lateral ( select x.* from emp x where x.deptno = a.deptno )(+) b;

-- lateral 인라인 뷰에 group by 절이 없는 집계함수를 사용하면 메인 쿼리의 모든 행이 반환된다
-- group by 절이 없는 집계함수는 항상 결과를 반환하기 때문이다
select a.deptno, a.dname, b.sal
from dept a,
     lateral ( select sum(x.sal) as sal from emp x where x.deptno = a.deptno ) b;

--group by 절을 기술하면 의도한 결과를 얻을 수 있다
select a.deptno, a.dname, b.sal
from dept a,
     lateral ( select sum(x.sal) as sal from emp x where x.deptno = a.deptno group by (deptno)) b;

-- cross apply절
-- cross join의 변형이다
-- lateral 인라인 뷰의 이너 조인과 결과가 동일하다
select a.deptno, a.dname, b.empno, b.ename
from dept a
cross apply (select x.* from emp x where x.deptno = a.deptno) b;


-- outer apply절
--left outer join 의 변형이다
-- lateral 인라인 뷰의 아우터 조인과 결과가 동일하다
select a.deptno, a.dname, b.empno, b.ename
from dept a
outer apply (select x.* from emp x where x.deptno = a.deptno) b;


--기존 동작 변화
--신규 기능에 의해 기존 서브 쿼리의 동작에도 변화가 생김
-- 12.1 이전 버전까지 서브 쿼리의 서브 쿼리에 메인 쿼리의 조건을 기술하면 에러가 발생했다
-- 12.1 버전 부터 에러 발생하지 않음
select a.deptno, a.dname
from dept a
where exists(select 1
    from (select count(*) as cn from emp x where x.deptno = a.deptno)
    where cn >= 5);

-- 위 쿼리는 아래와 같이 작성하는 편이 바람직 하다
select a.deptno, a.dname
from dept a
where exists(select 1 from emp x where x.deptno = a.deptno having count(*)>=5);

--스칼라 서브쿼리도 서브쿼리의 서브쿼리에 메인 쿼리의 조건을 기술 할 수 있다
select a.deptno, a.dname,
       (select max(sal) as sal
           from (select avg(x.sal) as sal
               from emp x
               where x.deptno = a.deptno)) as sal
from dept a;

-- 위의 쿼리도 아래처럼 작성하는 편이 낫다
select a.deptno, a.dname,
       (select avg(x.sal) as sal
           from emp x
           where x.deptno = a.deptno
           group by x.deptno) as sal
from dept a;

select a.deptno,a.dname, avg(b.sal)
from dept a left outer join emp b on a.deptno = b.deptno
group by a.DEPTNO,a.dname;