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
search depth first by empno set so
select lv, empno, lpad(' ',lv-1,' ')||ename as ename, mgr, empno_p, rt, pt,
       case when lv- lead(lv) over(order by so) < 0 then 0 else 1 end as lf -- connect_by_isleaf
from w1
order by so;


-- 계층 정렬
/*
 재귀 서브 쿼리 팩토링은 계층 정렬을 위한 search 절을 제공한다
 breadth 방식과 depth 방식을 사용할 수 있으며, first by 뒤에 기술된 c_alias에 따라 행이 정렬된다
 ordering_column은 정렬 순번이 반환될 열을 지정한다

 SEARCH {DEPTH | BREADTH} FIRST BY c_alias [, c_alias] ... SET ordering_column

 BREADTH : 자식 행을 반환하기 전에 형제 행을 반환(기본값)
 DEPTH : 형제 행을 반환하기 전에 자식 행을 반환 (= 계층 쿼리 절)
 */
-- breadth 방식
with w1 (empno, ename, mgr, lv) as (
    select empno, ename, mgr, 1 as lv from emp where mgr is null
    union all
    select c.empno, c.ename, c.mgr, p.lv + 1 as lv
    from w1 p, emp c
    where c.mgr = p.empno
)
search breadth first by empno set so
select lv, empno, lpad(' ', lv - 1, ' ') || ename as ename, mgr, so
from w1
order by so;
-- depth 방식
with w1 (empno, ename, mgr, lv) as (
    select empno, ename, mgr, 1 as lv from emp where mgr is null
    union all
    select c.empno, c.ename, c.mgr, p.lv + 1 as lv
    from w1 p, emp c
    where c.mgr = p.empno
)
search depth first by empno set so
select lv, empno, lpad(' ', lv - 1, ' ') || ename as ename, mgr, so
from w1
order by so;

-- 루프 처리
/*
 재귀 서브 쿼리 팩토링은 루프 처리를 위한 cycle절을 제공한다
 cycle 절은 상위 노드에 동일한 c_alias 값이 존재하면 루프가 발생한 것으로 인식한다

 CYCLE c_alias [, c_alias] ... SET cycle_mark_c_alias TO cycle_value DEFAULT no_cycle_value

 c_alias [, c_alias] : 루프 여부를 확인할 열
 cycle_mark_c_alias : 루프 여부를 반환할 열
 cycle_value : 루프가 발생한 경우 반환할 값
 no_cycle_value : 루프가 발생하지 않은 경우 반환할 값
 */
with w1 (empno, ename, mgr, lv) as (
    select empno, ename, mgr, 1 as lv from emp where mgr is null
    union all
    select c.empno, c.ename, c.mgr, p.lv + 1 as lv
    from w1 p, emp_l c
    where c.mgr = p.empno
)
search depth first by empno set so
cycle empno set ic to '1' default '0'
select lv, empno, lpad(' ', lv - 1, ' ') || ename as ename, mgr, ic
from w1
order by so;

-- 재귀 서브 쿼리 팩토링은 계층 전개와 무관한 열로도 루프 여부를 확인할 수 있다
with w1 (empno, ename, mgr,deptno, lv) as (
    select empno, ename, mgr,deptno, 1 as lv from emp where mgr is null
    union all
    select c.empno, c.ename, c.mgr,c.deptno, p.lv + 1 as lv
    from w1 p, emp c
    where c.mgr = p.empno
)
search depth first by empno set so
cycle deptno set ic to '1' default '0'
select lv, empno, lpad(' ', lv - 1, ' ') || ename as ename, mgr, ic
from w1
order by so;


-- 고급 주제

-- 노드 제거
-- connect by 절이나 where 절에 조건을 기술하면 조건을 만족하지 않는 노드를 제거할 수 있다
-- 계층 전개 시점에 제거되기 때문에 조건을 만족하지 않는 노드 뿐만 아니라 하위 노드들도 함께 제거된다
select level as lv, empno, lpad(' ',level-1,' ')||ename as ename, mgr
from emp
start with mgr is null
connect by mgr = prior empno
and empno <> 7698;

--where절에 기술하면 해당 노드만 제거되는데 이는 connect by 절이 수행된 후 where절이 수행되기 때문이다
select level as lv, empno, lpad(' ',level-1,' ')||ename as ename, mgr
from emp
where empno <> 7698
start with mgr is null
connect by mgr = prior empno;


-- 다중 루트 노드
-- 계층 쿼리 절은 1개 이상의 루트 노드를 가질 수 있다
select level as lv, empno, lpad(' ',level-1,' ')||ename as ename, mgr
from emp
start with job = 'MANAGER'
connect by mgr = prior empno;

-- 아래 쿼리는 20 번 부서에 부하가 없는 사원으로 루트 노드를 생성하고, 역방향으로 계층을 전개한다
select level as lv, a.empno, lpad(' ',level-1,' ')|| a.ename as ename, a.mgr
from emp a
start with a.deptno = 20
and not exists(select 1 from emp x where x.mgr = a.empno)
connect by a.empno = prior a.mgr;


-- 다중 속성 순환 관계
-- 순환관계는 1개 이상의 속성을 관계 속성으로 가질 수 있다
drop table emp_c purge;

create table emp_c as
    select 1 as compno, a.*, 1 as pcompno from emp a union all
    select 2 as compno, a.*, 2 as pcompno from emp a;

-- 순환관계이므로 고유식별자는 compno,empno이고 상속받는 외래 식별자는 pcompno,mgr이다
select compno, empno, ename,mgr,pcompno from emp_c;

-- connect by 절에 순환 관계 속성을 모두 기술해야 의도한 결과를 얻을 수 있다
select level as lv, empno, lpad(' ',level-1,' ')|| ename as ename, mgr
from emp_c
start with compno = 1 and mgr is null
                          connect by pcompno = prior compno and mgr = prior empno;


drop table emp_h purge;

create table emp_h as
    select '205001' as ym, a.* from emp a union all
    select '205002' as ym, a.* from emp a;

-- emp_h 테이블은 다중 속성 순환 관계를 가지지는 않는다
-- 동일한 이력 시점의 계층을 전개하기 위해서는 connect by 절에 ym='205001'조건을 기술해야한다
-- 순환 관계를 가지는 테이블의 월별 이력 테이블에 대한 관계는 모호한 면이 있다
select level as lv,ym, empno, lpad(' ',level-1,' ')|| ename as ename, mgr
from emp_h
start with ym = '205001' and mgr is null
                             connect by ym = '205001' and mgr = prior empno;

-- 월별 이력에 대한 계층 쿼리는 아래와 같이 인라인 뷰를 사용하는 편이 명시적이다
select level as lv,ym, empno, lpad(' ',level-1,' ')|| ename as ename, mgr
from (select * from emp_h where ym = '205001')
start with mgr is null
           connect by mgr = prior empno;


-- 계층 쿼리와 조인
-- 계층 쿼리는 세 가지 방식으로 조인을 수행할 수 있다

-- 아래 쿼리는 계층을 전개한 후 조인을 수행한다. 일나인 뷰를 사용한 조인과 동일하다
select a.lv, a.empno, a.ename, b.dname
from (select level as lv, empno, lpad(' ', level - 1, ' ') || ename as ename, deptno, rownum as rn
    from emp
    start with mgr is null
               connect by mgr = prior empno) a, dept b
where b.deptno = a.deptno
order by a.rn;

-- 아래 쿼리는 조인을 수행한 수 계층을 전개한다
-- b.loc = 'NEW YORK' 조건처럼 계층을 전개할 대상을 먼저 정의해야 할 경우 사용할 수 있다
select level as lv, empno, lpad(' ', level - 1, ' ') || ename as ename, deptno, dname
    from (select a.*, b.dname
        from emp a, dept b
        where b.deptno = a.deptno
        and b.loc = 'NEW YORK')
start with mgr is null
           connect by mgr = prior empno;

--where 절에 조인 조건을 기술하면 조인을 수행한 후 계층을 전개한다
-- 위 쿼리처럼 인라인 뷰를 사용하는 편이 명시적이다
select level as lv, a.empno, lpad(' ', level - 1, ' ') || a.ename as ename, a.deptno, b.dname
from emp a, dept b
where b.deptno = a.deptno
start with a.mgr is null
           connect by a.mgr = prior a.empno;

-- 아래 쿼리는 계층 전개 시점에 조인을 수행한다
-- 계층 전개중 노드를 제한해야 할 때 사용할 수 있다
select level as lv, a.empno, lpad(' ', level - 1, ' ') || a.ename as ename, a.deptno, b.dname
from emp a, dept b
start with a.mgr is null and b.deptno = a.deptno
connect by a.mgr = prior a.EMPNO
and b.deptno = a.deptno
and b.loc = 'DALLAS';


-- 활용 예제

-- 순번 생성
-- 계층 쿼리를 사용하여 순번을 가진 테이블을 생성할 수 있다
-- 행 복제 시 해당 기법을 활용할 수 있다

-- start with절을 생략했기 때문에 dual 테이블의 전체 행이 루트 노드로 생성된다
-- dual 테이블이 1행이므로 루트 노드가 1행으로 생성되고, 1행과 1행을 카티션 곱한 결과는 1행이므로 level <= 100 조건을 만족할 때 까지 1행씩 레벨이 증가한다
select level as lv from dual connect by level <= 100;

-- 아래와 같이 xmltable 함수를 사용해도 동일한 결과를 얻을 수 있다
select rownum as rn from xmltable ('1 to 100');

-- 변경 이력
-- 값의 변경 이력을 확인할 수 있다
drop table t1 purge;
create table t1(
    ym varchar2(6), --연월
    bf varchar2(4), --변경 전 코드
    af varchar2(4)  --변경 후 코드
);

insert into t1 values('205001','A','B');
insert into t1 values('205001','I','J');
insert into t1 values('205001','X','Y');
insert into t1 values('205004','B','C');
insert into t1 values('205004','J','K');
insert into t1 values('205007','C','D');
COMMIT;

-- 아래 쿼리는 코드의 최종 변경 코드를 조회한다
-- start with 절이 생략되어 전체 행이 루트 노드로 생성된다
select bf, af, ym
from (select ym, connect_by_root bf as bf, af, connect_by_isleaf as lf
    from t1
    connect by bf = prior af)
where lf = 1
order by 1;

-- 아래 쿼리는 최초 코드의 변경 정보를 조회한다
-- 최초 코드로 루트 노드를 생성하기 위해 start with 절에서 변경 전 코드가 존재하지 않는 행을 조회한 후 순방향으로 계층을 전개했다
select bf,cd,ym,cn
from (select connect_by_root bf as bf,
             substr(sys_connect_by_path(af,','),2) as cd,
             substr(sys_connect_by_path(ym,','),2) as ym,
             level as cn,
             connect_by_isleaf as lf
    from t1 a
    start with not exists (select 1 from t1 x where x.af = a.bf)
    connect by bf = prior af
    )
where lf = 1
order by 1;

-- 아래 쿼리는 최종 코드의 변경 정보를 조회한다.
-- 최종 코드로 루트 노드를 생성하기 위해 start with 절에서 변경후 코드가 존재하지 않는 행을 조회한 후 역방향으로 계층을 전개했다
select af,cd,ym,cn
from (select connect_by_root af as af,
             substr(sys_connect_by_path(af,','),2) as cd,
             substr(sys_connect_by_path(ym,','),2) as ym,
             level as cn,
             connect_by_isleaf as lf
    from t1 a
    start with not exists (select 1 from t1 x where x.bf = a.af)
    connect by af = prior bf
    )
where lf = 1
order by 1;


-- 생성 순서
-- 계층 쿼리를 사용하면 순차적으로 계산되는 계정의 생성 순서를 결정할 수 있다
drop table t1 purge;
create table t1(
    cd varchar2(1), -- 계정
    c1 varchar2(1), -- 계산계정1
    c2 varchar2(1), -- 계산계정2
    c3 varchar2(1), -- 계산계정3
    c4 varchar2(1) -- 계산계정4
);

insert into t1 values('A','B','C','D','E');
insert into t1 values('B','F','G','H',NULL);
insert into t1 values('C','I','J',NULL,NULL);
insert into t1 values('D','K',NULL,NULL,NULL);
insert into t1 values('E','B','C',NULL,NULL);
insert into t1 values('F','C','D',NULL,NULL);
COMMIT;

-- 계정은 계산계정으로 계산되기 때문에 계산계정들이 미리 존재해 있어야 한다
select cd, max(level) as lv
from t1 a
start with not exists(select 1 from t1 x where x.cd in (a.c1,a.c2,a.c3,a.c4))
connect by prior cd in (c1,c2,c3,c4)
group by cd
order by 2,1;

-- 위 쿼리의 connect by 절은 아래와 같이 해석된다
-- connect by (c1 = prior cd or c2 = prior cd or c3 = prior cd or c4 = prior cd)


-- 누적 연산
-- 재귀 서브 쿼리 팩토링을 사용하면 상위 노드의 값을 누적 연산할 수 있다
with w1(empno, ename, mgr, sal,lv,c1) as (
    select empno, ename, mgr, sal, 1 as lv, sal as c1
    from emp
    where mgr is null
    union all
    select c.empno, c.ename, c.mgr, c.sal, p.lv + 1 as lv, p.c1 + c.sal as c1
    from w1 p, emp c
    where c.mgr = p.empno
)
search depth first by empno set so
select lv, empno, lpad(' ', lv - 1, ' ') || ename as ename, mgr, sal, c1
from w1
order by so;

-- 계층 쿼리 절은 부모 노드의 값만 참조할 수 있기 때문에 누적 연산이 불가능하다
select level as lv, empno, lpad(' ', level - 1, ' ')||ename as ename, mgr,
       sal, sal+ prior sal as c1
from emp
start with mgr is null
           connect by mgr = prior empno;