-- 집합 연산자(set operator)
-- 집합 연산자는 데이터 집합을 연결한다는 점에서 조인과 유사하게 동작
-- 조인은 데이터 집합을 수직으로 연결하고, 집합 연산자는 데이터 집합을 수평으로 연결한다

drop table t1 purge;
drop table t2 purge;

create table t1 (c1 varchar2 (1) not null, c2 number);
create table t2 (c1 varchar2 (1) not null, c2 number);

insert into t1 (c1,c2) values ('A',1);
insert into t1 (c1,c2) values ('A',2);
insert into t1 (c1,c2) values ('B',1);
insert into t1 (c1,c2) values ('B',2);
insert into t1 (c1,c2) values ('Z',null);
insert into t2 (c1,c2) values ('B',1);
insert into t2 (c1,c2) values ('B',1);
insert into t2 (c1,c2) values ('B',2);
insert into t2 (c1,c2) values ('C',2);
insert into t2 (c1,c2) values ('Z',null);
commit;


-- union all
-- 중복에 관계없이 모든 행을 합친다
select c1,c2 from t1
union all
select c1,c2 from t2;

--union
-- 중복이 제거된 합집합을 생성.
-- 중복 값을 제거하기 위해 정렬이 발생
select c1 from t1
union
select c1 from t2;

-- union all 을 해도 결과가 같다.
-- 불필요한 소트가 발생하지 않도록 union all 연산자를 사용해야한다
-- 즉 데이터 집합이 중복되지 않으면 union all을 사용하여 불필요한 소트를 막는다
select '1' as tp, empno, ename from emp where job='ANALYST'
union
select '2' as tp, empno, ename from emp where sal = 3000;

-- intersect
-- 중복 값이 제거된 교집합을 생성한다
-- 소트 발생
select c1 from t1
intersect
select c1 from t2;

-- minus
-- 중복 값이 제거된 차집합을 생성
-- 소트 발생
select c1 from t1
minus
select c1 from t2;


-- 주의사항
-- 연결 되는 열의 개수가 다름
select c1,c2 from t1
union all
select c1 from t2;

-- 연결되는 열의 데이터 타입이 다름
select c1,c2 from t1
union all
select c2,c1 from t2;

-- 잡합 연산자를 사용한 쿼리는 order by 절을 쿼리의 마지막에 1번만 기술해야한다
select c1,c2 from t1 union all
select c1,c2 from t2
order by c1,c2;

-- union all 연산자의 경우 인라인 부에서 데이터를 정렬한 후 데이터 집합을 연결할 수 있다
-- 각각의 데이터 집합이 정렬된 상태로 연결된다.
-- union, intersect, minus연산자는 연결한 데이터 집합의 중복을 제거하기 때문에 아래의 기법을 사용할 수 없다
select c1,c2 from (select * from t1 order by c1,c2)
union all
select c1,c2 from(select * from t2 order by c1,c2);

--minus->union all->minus 순서로 집합 연산을 수행
select c1,c2 from t1 minus
select c1,c2 from t2 union all
select c1,c2 from t2 minus
select c1,c2 from t1;

-- 괄호를 사용하면 연산 순서를 조정할 수 있다
(select c1,c2 from t1 minus
select c1,c2 from t2) union all
(select c1,c2 from t2 minus
select c1,c2 from t1);

-- 아래 쿼리는 위 쿼리보다 명시적이다( 인라인뷰를 사용해보자)
select * from (select c1,c2 from t1 minus select c1,c2 from t2) union all
select * from (select c1,c2 from t2 minus select c1,c2 from t1);


-- 활용예제
-- OR 조건 성능 개선
-- or 조건을 사용한 쿼리는 다수의 조건으로 인해 쿼리의 성능이 저하될 수 있다.
-- union all 연산자로 데이터 집합을 분리함으로써 쿼리의 성능을 개선한다
-- 인덱스 구성에 따라 쿼리의 성능이 저하될 수도 있다
-- 옵티마이저가 내부적인 판단으로 union all 연산자를 사용한 쿼리로 변환하기도 한다

select ename,sal,deptno
from emp
where ((deptno = 10 and sal >= 2000) or (deptno = 20 and sal >= 3000));

-- 아래와 같이 or 조건을 union all 연산자로 변경할 수 있다
-- deptno가 다르기 때문에 데이터 집합이 중복되지 않는다
select ename, sal, deptno from emp where deptno = 10 and sal >= 2000 union all
select ename, sal, deptno from emp where deptno = 20 and sal >= 3000;

-- full outer join 성능 개선
-- 11.1 이전 버전에서 full outer join을 수행하면 조인이 여러 번 수행되어 쿼리의 성능이 저하되었다
-- 성능 개선을 위해 full outer join을 union all 연산자로 변경하는 기법을 사용

select coalesce(a.c1,b.c1) as c1, a.c2 as t1, b.c2 as t2
from (select c1, sum(c2) as c2 from t1 group by c1) a
full outer join
    (select c1 ,sum(c2) as c2 from t2 group by c1) b
on b.c1=a.c1
order by 1;

-- 아래 쿼리는 위 쿼리와 동일하다
-- full outer join이 1:1의 차수인 경우에만 union all 연산자로 변경할 수 있다
select c1, sum(t1) as t1, sum(t2) as t2
from (select c1,c2 as t1 ,null as t2 from t1
    union all
    select c1, null as t1, c2 as t2 from t2)
group by c1
order by 1;


-- intersect 성능 개선
-- 소트를 피하기 위해 다른 쿼리문으로 변경
-- 널을 허용하는 열은 lnnvl함수를 사용
select c1,c2 from t1
intersect
select c1,c2 from t2;

select distinct a.c1,a.c2
from t1 a
where exists(select 1
    from t2 x
    where x.c1 = a.c1
    and lnnvl(x.c2<>a.c2));

-- minus 성능 개선
-- 서브쿼리를 사용하면 열이 많을수록 쿼리가 길어지는 단점이 있다
select c1,c2 from t1
minus
select c1,c2 from t2;

select distinct a.c1, a.c2
from t1 a
where not exists(select 1
    from t2 x
    where x.c1 = a.c1 and lnnvl(x.c2 <> a.c2));