drop table t1 purge;

create table t1 (c1 number, c2 number);
create table t2 (c1 number);
create table t3 (c1 number);
create table t4 (c1 number);

insert into t1 values(1, 1);
insert into t1 values(2, 2);
insert into t1 values(3, 3);
insert into t2 values(1);
insert into t2 values(2);
insert into t2 values(4);
insert into t3 values(1);
insert into t3 values(2);
insert into t3 values(3);
insert into t4 values(1);
insert into t4 values(3);
insert into t4 values(4);
commit;

-- outer 기준 반대쪽에 (+)기호를 기술
select a.c1 as a, b.c1 as b from t1 a, t2 b where b.c1(+) = a.c1 order by 1;

-- outer 기준의 일반조건이 존재하면 예상하는 결과가 나온다
select a.c1 as a, b.c1 as b from t1 a, t2 b where a.c1 > 1 --조건 1
and b.c1(+) = a.c1 -- 조건 2
order by 1;

-- 아우터 기준이 아닌 일반 조건에 (+) 기호를 기술하지 않으면 아우터 조인이 이너 조인으로 변경된다
select a.c1 as a, b.c1 as b from t1 a, t2 b where b.c1(+) = a.c1 -- 조건1
and b.c1 > 1 -- 조건 2
order by a.c1;

-- 일반조건에 (+) 기호를 기술하면 아우터 조인으로 조인된다.
-- (+)기호가 붙으면 해당 조건을 만족하지 않으면 null로 값이 채워지게된다.
select a.c1 as a, b.c1 as b from t1 a, t2 b where b.c1(+) = a.c1 -- 조건1
and b.c1(+) > 1 -- 조건 2
order by a.c1;

--의도적으로 아우터 기준이 아닌 일반조건에 (+) 기호를 누락시키는 경우도 있다.
select a.c1 as a, b.c1 as b from t1 a, t2 b where b.c1(+) = a.c1 --조건 1
and b.c1 is null --조건 2
order by 1;

-- t1->t2->t3 순서로 아우터 조인한다
select a.c1 as a,b.c1 as b, c.c1 as c from t1 a, t2 b,t3 c
where b.c1(+) = a.c1 --조건 1
and c.c1(+) = b.c1 -- 조건2
order by a.c1;

-- 아우터 기준이 아닌 조인 조건에 (+) 기호가 누락되면 선행되는 모든 아우터 조인이 이너 조인으로 변경된다
-- t1,t2는 아우터 조인되었지만, t2,t3가 이너 조인되어 결국 t1,t2,t3는 이너 조인되고 마지막 t3,t4만 아우터 조인으로 조인되었다.
select a.c1 as a, b.c1 as b, c.c1 as c, d.c1 as d from t1 a, t2 b, t3 c, t4 d
where b.c1(+) = a.c1 -- 조건 1
and c.c1 = b.c1 -- 조건 2
and d.c1(+) = c.c1 -- 조건3
order by 1;

-- 아우터 조인은 몇 가지 제약 사항이 존재한다.
-- 아래 쿼리는 10.2.0.4 버전까지 에러가 발생
-- 10.2.0.5 버전부터는 에러가 발생하지 않음
select a.c1 as a, b.c1 as b
from t1 a, t2 b
where b.c1(+) = a.c1 and b.c1(+) in (1,4)
order by a.c1;

-- 그렇다고 ORA-01719 에러가 사라진 것은 아니다.
-- 아래 쿼리는 아우터 기준인 t1의 조인 열을 결정할 수 없기 때문에 10.2.0.5 이후 버전에서도 여전히 에러가 발생
select * from t1 a, t2 b where b.c1(+) in (a.c1,a.c2);

-- t1,t3를 카티션 곱한 결과로 t2를 아우터 조인하기 때문에 의도하지 않은 결과가 반환될 수 있다.
select a.c1 as a, b.c1 as b, c.c1 as c from t1 a, t2 b, t3 c where b.c1(+) = a.c1 and c.c1 = b.c1(+) order by 1,2,3;

--기술순서
--from 절
drop table t1 purge;
drop table t2 purge;
drop table t3 purge;

create table t1 (c1 number);
create table t2 (c1 number, c2 number);
create table t3 (c1 number, c2 number, c3 number);

insert into t1 values(1);
insert into t2 values(1,1);
insert into t2 values(1,2);
insert into t3 values(1,1,1);
insert into t3 values(1,2,1);
insert into t3 values(1,2,2);
insert into t3 values(1,2,3);
commit;

-- from 절의 테이블은 데이터의 논리적인 흐름에 따라 기술해야 한다.
-- 데이터의 모델에 따라 조인 순서를 결정하고, 업무 요건에 따라 조인 순서를 조정한다

-- t1->t2->t3 순서로 조인 수행
-- 데이터 모델의 상속 순서와 동일
-- 조인 단계에 따라 1->2->8 순서로 행이 늘어난다
-- 행이 늘어나는 만큼 조인 횟수도 증가한다
-- 조인은 행이 가장 적게 늘어나는 순서로 수행해야 하며, from 절의 테이블도 동일한 순서로 기술하는 편이 바람직 하다.
select * from t1 a, t2 b, t3 c
where b.c1 = a.c1 and c.c1 = b.c1;

-- t1->t3->t2 순서로 조인 수행
-- 1->4->8 순서로 행이 늘어남
-- 첫번째 쿼리보다 더 많은 횟수의 조인을 수행한다
select * from t1 a, t2 b, t3 c
where c.c1 = a.c1 and c.c1 = b.c1;

-- t2->t3->t1 순서로 조인 수행
-- 2->8->8 순서로 행이 늘어남
-- 두번째 쿼리보다 더 많은 횟수의 조인을 수행한다
select * from t1 a, t2 b, t3 c
where c.c1 = b.c1 and c.c1 = a.c1;

--아래 쿼리는 데이터 모델의 관계에 따라 t1->t2->t3 순서로 조인을 수행 했지만 t3 테이블에 일반조건(c.c3=2)이 존재.
-- 조인단계에 따라 1->2->2 순서로 행이 늘어남
select * from t1 a, t2 b, t3 c
where b.c1 = a.c1
and c.c1 = b.c1
and c.c3 = 2;

-- 아래와 같이 t1 -> t3 -> t2 로 조인 순서를 변경하면, 조인 단계에 따라 1->1->2 순서로 행이 늘어난다.
-- 일반 조건이 존재하는 경우 실제 행의 증감까지 고려할 필요가 있다
select * from t1 a, t3 c, t2 b
where c.c1 = a.c1
and c.c3 = 2
and b.c1 = c.c1;

-- 아우터 조인의 경우 아우터 기준을 from 절에 먼저 기술하는 편이 바람직 하다


-- where 절
/**
  from 절에 첫 번째로 기술된 테이블의 일반 조건을 기술한 다음,
  from 절에 기술된 테이블의 순서에 따라 조인 조건과 일반 조건의 순서로 조건을 기술한다.
  조인 조건은 가능한 PK와 FK 순서대로 기술하고,
  먼저 조회된 테이블의 값이 입력되는 형태로 작성한다
 */
-- 규칙에 따라 where 절을 작성한 예
-- where 절의 작성 순서와 데이터의 논리적인 흐름이 일치한다
select a.ename, b.dname
from emp a, dept b
where a.job = 'CLERK' -- 일반(a)
and a.sal >= 1000     -- 일반(a)
and b.deptno = a.deptno -- 조인 (b=a)
and b.loc = 'DALLAS';  -- 일반 (b)

-- where절의 작성 순서와 데이터의 논리적인 흐름이 일치하지 않은 예
select a.ename, b.dname
from emp a, dept b
where b.deptno = a.deptno
and a.job = 'CLERK'
and a.sal >= 1000
and b.loc = 'DALLAS';


-- 파티션 아우터 조인
-- PARTITION BY (expr [, expr]...)
-- expr로 파티션을 생성한 후 파티션을 기준으로 아우터 조인을 수행한다
drop table t1 purge;
drop table t2 purge;

create table t1 (c1 number);
create table t2 (c1 number, c2 varchar2(1));

insert into t1 values(1);
insert into t1 values(2);
insert into t1 values(3);
insert into t2 values(1,'A');
insert into t2 values(2,'B');
commit;

-- outer join
select a.c1 as ac1, b.c1 as bc1, b.c2 as bc2
from t1 a left outer join t2 b on b.c1 = a.c1;

-- partition outer join
-- 아래 쿼리는 b.c1열, 그 밑의 쿼리는 b.c2 열을 파티션으로 지정
select a.c1 as ac1, b.c1 as bc1, b.c2 as bc2
from t1 a left outer join t2 b partition by (b.c1) on b.c1 = a.c1;

select a.c1 as ac1, b.c1 as bc1, b.c2 as bc2
from t1 a left outer join t2 b partition by (b.c2) on b.c1 = a.c1;


-- 활용 예제

/**
  필수 관계는 inner join으로, 선택 관계는 outer join로 수행해야 조인 기준이 모두 반환된다
  필수 관계라도 일반 조건이 존재하면 아우터 조인으로 조인해야 조인 기준이 모두 반환된다
  하나의 조인 조건에 조인할 테이블의 여러 열이 기술되면 쿼리의 성능이 저하될 수 있다
 */
drop table t1 purge;
drop table t2 purge;
drop table t3 purge;

create table t1 (c1 number);
create table t2 (c1 number, c2 varchar2(1));
create table t3 (c1 varchar2(1));

insert into t1 values(1);
insert into t1 values(2);
insert into t1 values(3);
insert into t2 values(1,'A');
insert into t2 values(2,'B');
insert into t2 values(2,'A');
insert into t2 values(3,'B');
insert into t3 values('A');
insert into t3 values('B');
commit;

select * from t1 a left outer join t2 b on a.c1=b.c1;

select * from (t1 a cross join t3 b) left outer join t2 c on (c.c1 = a.c1 and c.c2 = b.c1)
order by 2,1;

select * from t1 a left outer join t2 b partition by (b.c2) on a.c1 = b.c1;