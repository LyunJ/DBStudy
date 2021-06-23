/**
  ORDER BY {expr | position | c_alias} [ASC|DESC] [NULLS FIRST | NULLS LAST]
  [,{expr | position | c_alias} [ASC|DESC] [NULLS FIRST | NULLS LAST]] ....
  ASC : 오름차순
  DESC : 내림차순
  NULLS FIRST : 널을 앞쪽으로 정렬(내림차순 정렬시 기본값)
  NULLS LAST : 널을 뒤쪽으로 정렬(오름차순 정렬시 기본값)
 */

-- order by 절의 열을 가공하면 쿼리의 성능이 저하될 수 있다. 정렬할 데이터가 크지 않을때만 사용해야함

-- order by 절에 decode 함수나 case 표현식을 사용하면 조건에 따라 다른 정렬 기준을 지정할 수 있다
-- manager, clerk 순으로 정렬하고 sal를 오름차준으로 정렬
select job, sal from emp where deptno = 20
order by decode(job,'MANAGER',1,'CLERK',2),sal;

-- 결과를 deptno로 정렬하되 deptno가 10인 행은 sal를 내림차순, deptno가 30인 행은 comm과 sal를 오름차순으로 정렬
select deptno, sal, comm from emp where deptno in (10,30)
order by deptno,
         decode(deptno, 10, sal) desc,
         decode(deptno, 30, comm),
         sal;

-- 캐릭터 셋에 따라 특수문자, 숫자, 영문, 한글의 정렬 순서가 달라질 수 있다
select * from t1;
drop table t1 purge;
create table t1 (c1 varchar2(10));

insert into t1 values ('@');
insert into t1 values ('!');
insert into t1 values ('2');
insert into t1 values ('1');
insert into t1 values ('B');
insert into t1 values ('A');
insert into t1 values ('나');
insert into t1 values ('가');
commit;
-- 특수문자와 숫자가 먼저 정렬되고, 다음으로 영문, 한글의 순서로 결과가 정렬된다
select c1 from t1 order by c1;

-- 정규표현식을 사용하면 정렬 순서를 변경할 수 있다
select c1 from t1
order by regexp_instr(c1, '^[^[:punct:][:digit:][:lower:][:upper:]]') desc,
         regexp_instr(c1,'^[[:lower:][:upper:]]') desc,
         regexp_instr(c1,'^[[:digit:]]') desc,
         regexp_instr(c1,'^[[:punct:]]') desc,
         c1;

