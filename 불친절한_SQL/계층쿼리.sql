-- 계층 쿼리절
/*
 [START WITH condition] CONNECT BY [NOCYCLE] condition
 계층 쿼리절은 where 절 다음에 기술하며, from w러이 수행된 후 수행된다.
 start with 절과 connect by 절로 구성되며, start with 절이 수행된후 connect by 절이 수행된다
 start with 절은 생략이 가능하다

 start with 절 : 루트 노드를 생성하며 1번만 수행
 connect by 절 : 루트 노드의 하위 노드를 생성하며 조회 결과가 없을 때까지 반복 수행

 연산자
 PRIOR : 직전 상위 노드의 값을 반환
 CONNECT_BY_ROOT : 루트 노드의 값을 반환
 슈도 칼럼
 LEVEL : 현재 레벨을 반환
 CONNECT_BY_ISLEAF : 리프노드인 경우 1, 아니면 0을 반환
 CONNECT_BY_ISCYCLE : 루프가 발생한 경우 1, 아니면 0을 반환
 함수
 SYS_CONNECT_BY_PATH : 루트 노드에서 현재 노드까지의 경로를 반환
 */
select level as lv, empno, lpad(' ',level - 1, ' ') || ename as ename, mgr, prior empno as empno_p
from emp
start with mgr is null --mgr가 존재하지 않는 행
connect by mgr = prior empno; -- mgr가 부모 노드의 empno인 행


-- sys_connect_py_path 함수
/*
 SYS_CONNECT_BY_PATH (column, char)

 루트 노드에서 현재 노드까지의 column을 char로 구분하여 연결한 값을 반환
 column값에 char가 포함되어 있으면 ORA-30004에러, 연결한 값의 길이가 4000보다 길면 ORA-01489 에러가 발생한다
 */

select level as lv, empno, lpad(' ',level-1,' ') || ename as ename, mgr,
       connect_by_root ename as rt,
       connect_by_isleaf as lf,
       sys_connect_by_path(ename,',') as pt
from EMP
start with mgr is null
connect by mgr = prior empno;


-- 동작 원리
-- 루트노드를 생성 후 임시 테이블에 저장한 뒤 레벨별로 empno와 mgr를 비교하여 조인한 결과를 다시 임시테이블에 저장하는 방식


--전개 방향
/*
 순환 관계는 순방향 또는 역방향으로 전개할 수 있다
 순방향 전개와 역방향 전개는 데이터 모델 상의 전개 방향이 반대일 뿐 동작 원리는 같다.
 */
-- 아래 쿼리는 역방향으로 계층을 전개한다
-- 역방향 전개는 start with 절로 자식노드를 조회하고, connect by절을 통해 부모 노드로 계층을 전개한다
-- FK(mgr)에 prior연산자를 기술하여 현재 노드의 empno가 자식 노드의 mgr인 행을 조회한다
select level as lv, empno, lpad(' ',level-1,' ')||ename as ename, mgr
from emp
start with mgr is null
connect by mgr = prior empno;


-- 계층 정렬
-- 계층 쿼리 절은 형제 노드의 정렬을 위해 siblings 키워드를 제공한다

-- 계층 쿼리 절에 order by 절을 사용하면 계층 구조와 무관하게 행이 정렬된다
select level as lv, empno, lpad(' ', level - 1,' ')||ename as ename, mgr, sal
from EMP
start with mgr is null
           connect by mgr = prior empno
order by sal;

-- order by 절에 siblings 키워드를 사용하면 형제 노드 내에서만 행이 정렬되기 때문에 계층 구조를 유지한 채로 행을 정렬할 수 있다
select level as lv, empno, lpad(' ', level - 1,' ')||ename as ename, mgr, sal
from EMP
start with mgr is null
           connect by mgr = prior empno
order siblings by  sal;


-- 루프 처리
-- 부모 노드가 현재 노드의 자식 노드로 연결되면 루프가 발생한다
-- 계층 쿼리 절은 루프 처리를 위해 nocycle키워드와 connect_by_iscycle 슈도 칼럼을 제공한다
drop table emp_l purge;
create table emp_l as select empno, ename, nvl(mgr,7788) as mgr from emp;

select level as lv, empno, lpad(' ',level-1,' ') || ename as ename, mgr
from emp_l
start with empno = 7839
connect by mgr = prior empno;

-- nocycle키워드를 기술하면 루프가 발생한 노드를 전개하지 않는다
select level as lv, empno, lpad(' ',level-1,' ') || ename as ename, mgr,
       CONNECT_BY_ISCYCLE as ic
from emp_l
start with empno = 7839
connect by nocycle mgr = prior empno;

-- 재귀 서브 쿼리 팩토링 (11.2버전)
/*
 WITH query_name ([c_alias [,c_alias]...]) as (subquery) [search_clause] [cycle_clause]
 서브 쿼리는 UNION ALL 연산자로 구성된다
 UNION ALL 연산자의 상단 쿼리가 START WITH절, 하단 쿼리가 CONNECT BY 절의 역할을 수행한다
 WITH절에 정의한 서브 쿼리를 하단 쿼리와 조인함으로써 재귀적으로 조인이 수행되는 방식으로 동작한다

 기본적으로 계층 쿼리 절을 사용하고, 특별한 루프 처리나 상위 노드에 대한 누적 집계 등이 필요할 경우
 선택적으로 재귀 서브 쿼리 팩토링 기능을 사용하는것이 일반적이다
 */

with w1(empno, ename, mgr, lv)as(
    select empno, ename, mgr, 1 as lv
    from emp
    where mgr is null -- start with절
    union all
    select c.empno, c.ename, c.mgr, p.lv + 1 as lv
    from w1 p, emp c
    where c.mgr = p.empno --connect by 젚
)
select lv, empno, lpad(' ',lv-1,' ')||ename as ename, mgr from w1;

with w1(empno, ename, mgr, lv)as(
    select empno, ename, mgr, 1 as lv
    from emp
    where ename = 'ADAMS' -- start with절
    union all
    select c.empno, c.ename, c.mgr, p.lv + 1 as lv
    from w1 p, emp c
    where c.empno = p.mgr --connect by 젚
)
select lv, empno, lpad(' ',lv-1,' ')||ename as ename, mgr from w1;

--재귀 서브 쿼리 팩토링은 계층 정보를 조회하기 위한 연산자, 슈도칼럼, 함수를 제공하지 않는다
-- 아래 표현식으로 계층 정보를 조회할 수 있다
with w1(empno, ename, mgr, lv, empno_p,rt,pt)as(
    select empno, ename, mgr,
           1 as lv, -- level
           null as empno_p, -- prior
           ename as rt, -- connect_by_root
           ename as pt --sys_connect_by_path
    from emp
    where mgr is null -- start with절
    union all
    select c.empno, c.ename, c.mgr,
           p.lv + 1 as lv,
           p.empno as empno_p,
           p.rt,
           p.pt || ',' || c.ename as pt
    from w1 p, emp c
    where c.mgr = p.empno --connect by 젚
)
-- search depth first by empno set so
select lv, empno, lpad(' ',lv-1,' ')||ename as ename, mgr, empno_p, rt, pt
--        case when lv- lead(lv) over(order by so) < 0 then 0 else 1 end as lf -- connect_by_isleaf
from w1;
-- order by so;