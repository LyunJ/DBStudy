select ename, deptno, job from emp where not (deptno = 30 or job = 'CLERK');
-- 위의 쿼리의 가독성을 높여보자
select ename, deptno, job from emp where deptno <> 30 and job <> 'CLERK';


--in

-- 아래의 쿼리를 사용하면 목록을 1000개 까지만 지정할 수 있다
select * from emp where deptno in (1,2,3,4);
-- 다중 열을 사용하면 1000개 이상을 지정할 수 있다
select * from emp where (1,deptno) in ((1,1),(1,2));
--하지만 쿼리가 길어지면 library cache에 부하가 발생할 수 있다
--해법
create or replace type ntt_varchar2 is table of varchar2 (4000);
create or replace function fnc_split(i_val in varchar2, i_del in varchar2 default ',')
    return ntt_varchar2 pipelined
is
    l_tmp varchar2 (32767) := i_val || i_del;
    l_pos pls_integer;
begin
    loop
        l_pos := instr(l_tmp, i_del);
        exit when nvl(l_pos,0) = 0;
        pipe row (substr (l_tmp,1,l_pos - 1));
        l_tmp := substr(l_tmp, l_pos + 1);
    end loop;
end fnc_split;


variable v1 varchar2(100);

exec :v1 := '10,20';

select empno,ename,deptno
from EMP
where deptno in (select column_value from table (fnc_split(:v1)));


-- like
-- 필터링 안됨
with w1 as (select 'ABC' as c1 from dual union all select 'A%C' as c1 from dual)
select c1 from w1 where c1 like '_\%_';
-- 필터링 됨
--escape 문자를 지정해 줘야 한다
with w1 as (select 'ABC' as c1 from dual union all select 'A%C' as c1 from dual)
select c1 from w1 where c1 like '_\%_' escape '\';

-- ||로 문자열과 변수를 연결하여 like함수 사용 가능
select ename from emp where 'AGENT SMITH' like '%' || ename || '%';
-- 성능 개선 버전
select ename from emp where instr('AGENT SMITH',ename) > 0;


alter session set nls_date_format = 'YYYY-MM-DD';
--문자 타입이 아닌 열에 like 연산자를 사용하면 암시적 데이터 변환이 발생한다
select ename, hiredate from emp where hiredate like '1980%';
alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';

--LNNVL(condition)
-- condition이 false나 unknown(null)이면 true, true면 false를 반환한다
-- where절과 case 표현식에 사용할 수 있다
-- LNNVL은 in 조건문 사용 불가
select ename, comm from emp where lnnvl(comm <> 0);

/**
  조건 우선순위

  연산자
  비교조건(=,<>,>,<,>=,<=)
  IN,LIKE,BETWEEN,NULL 조건
  논리 조건(NOT)
  논리 조건(AND)
  논리 조건(OR)
 */


-- 열 가공
-- WHERE절의 열을 가공하면 쿼리의 성능이 저하될 수 있다.
-- 열을 가공하면 해당 열이 선두인 인덱스를 사용할 수 없다
-- 가급적 열을 가공하지 말자

-- 산술 연산이 행의 개수만큼 수행됨
select * from EMP where sal * 12 >= 36000;
-- 산술 연산을 수행한 결과로 조건을 평가
select * from emp where sal >= 36000 / 12;

-- 결합 연산자로 열을 가공
select * from emp where deptno || job = '10CLERK';
-- and 조건을 사용해야 한다
select * from emp where deptno = 10 and job = 'CLERK';

-- substr 함수를 사용한다
select * from emp where substr(ename, 1, 1)='A';
-- like 조건을 사용하는 편이 바람직하다
select * from emp where ename like 'A%';

-- like 조건의 패턴 양측에 특수문자(%,_)를 사용한 경우 like 조건보다 instr 함수를 사용하는 편이 성능 측면에서 유리할 수 있다
-- instr 사용
select * from emp where instr(ename, 'ON') > 0;
-- like 사용
select * from emp where ename like '%ON%';

-- hiredate에 to_char 함수를 사용
select * from emp where to_char(hiredate,'YYYYMMDD') = '19870713';
-- 이 쿼리로 변경할 수 있지만 hiredate에 시간이 포함되어 있으면 쿼리의 결과가 달라진다
select * from emp where hiredate = date '1987-07-13';
-- 이렇게 작성해야 동일한 결과를 보장할 수 있다
select hiredate from emp where hiredate >= date '1987-07-13' and hiredate < date '1987-07-13' + 1;

-- where 절에 case 표현식 사용
select empno, ename, mgr, deptno from emp where case deptno when 10 then empno else mgr end = 7839;
-- 위 쿼리처럼 case 표현식에 다수의 열을 사용하는 경우 쿼리의 성능이 저하될 수 있다.
-- 아래와 같이 작성하자
select empno, ename, mgr, deptno from emp where ((deptno = 10 and empno = 7839) or (deptno <> 10 and mgr = 7839));
-- deptno 열이 널을 허용하면 다음과 같이 작성하자
select empno, ename, mgr, deptno from emp where((deptno = 10 and empno = 7839) or (lnnvl (deptno = 10) and mgr = 7839));

select ename, deptno, sal from emp where sal >= case deptno when 20 then 3000 when 30 then 2000 else 0 end;
-- 위 쿼리는 아래와 같이 작성할 수 있다. 쿼리가 다소 길어졌지만 논리적인 해석이 가능하다
select ename, deptno, sal from emp where ((deptno = 20 and sal >= 3000) or (deptno = 30 and sal >= 2000) or (deptno not in (20, 30) and sal >= 0));
-- deptno 열이 널을 허용한다면 아래와 같이 작성해야한다
select ename, deptno, sal from emp where ((deptno = 30 and sal >= 3000) or (deptno = 30 and sal >= 2000) or ((deptno not in (20, 30) or deptno is null) and sal > 0));

