/*
 오라클은 세 가지 방식의 top-n 쿼리를 사용할 수 있다.
 rownum방식, 분석 함수 방식, row limiting

 top-n쿼리는 시스템 성능에 미치는 영향이 크기 때문에 작성 표준을 신중하게 결정해야 한다
 현재까지는 rownum방식을 가장 많이 사용하고 있다
 */

 -- rownum방식
-- rownum 슈도 컬럼은 행이 반환되는 순서대로 순번을 반환한다
select empno, sal, rownum as rn from emp;

-- 아래 쿼리는 결과가 반환되지 않는다
-- rownum 슈도 컬럼은 1부터 시작하고 행이 반환될 때마다 순번이 증가하기 때문에 rownum = 2 조건은 항상 false다
-- 항상 <, > 를 사용하자
-- rownum 슈도 칼럼을 where절에 직접 기술하지 않으면 count stopkey 오퍼레이션이 동작하지 않아 성능이 저하될 수 있다
select empno, sal, rownum as rn from emp where rownum =2;

-- 무작위로 n개의 행을 조회해야 하는 경우 order by 절에 dbms_random.value 함수를 사용할 수 있다
select empno, sal
from (select empno, sal from emp order by dbms_random.value)
where rownum <= 3;

-- 위 쿼리는 문맥전환(context switching)에 의한 성능 저하가 발생할 수 있다
-- dbms_random.value 함수 대신 ora_hash 함수는 사용하면 쿼리의 성능을 개선할 수 있다
-- 테이블의 크기가 크다면 sample 절 사용도 고려할 수 있다
select empno, sal
from (select empno, sal
    from emp -- sample block(1)
    order by ora_hash(empno, to_char(systimestamp,'FF9'),
        to_char(systimestamp,'FF9')))
where rownum <= 3;

-- 아래의 쿼리는 중첩 서브 쿼리에 rownum 슈도 칼럼을 사용했다.
-- 중첩 서브 쿼리는 세미 조인으로 수행될 수 있기 때문에 rownum 슈도 칼럼을 사용할 필요가 없다.
select a.*
from dept a
where exists(select 1 from emp x where x.deptno = a.deptno and rownum <= 1);
-- 아래와 같이 작성하는 것이 성능상 이득이다
-- 중첩 서브 쿼리에 rownum 슈도 컬럼을 사용하면 쿼리변환에 제한이 생겨 쿼리의 성능이 저하될 수 있다
select a.*
from dept a
where exists (select 1 from emp x where x.deptno = a.deptno);

-- 아래의 좌측 쿼리의 사칼라 서브 쿼리는 임의의 값을 반환한다
select a.deptno,
       (select x.empno
           from emp x
           where x.deptno = a.deptno and rownum <= 1
           order by x.empno desc) as empno
from dept a;
-- 아래처럼 스칼라 서브 쿼리에 max 함수를 사용해야 한다
select a.deptno,
       (select max(x.empno)
           from emp x
           where x.deptno = a.deptno) as empno
from dept a;

-- 스칼라 서브 쿼리의 정렬 조건이 반환 값과 다른 경우 아래와 같이 keep 절을 사용해야 한다
select a.deptno,
       (select max(x.empno) keep (dense_rank  first order by sal desc)
           from emp x
           where x.deptno = a.deptno) as empno
from dept a;
-- keep 절을 사용하면 쿼리의 성능이 저하될 수 있다
-- index range scan 오퍼레이션이 동작하지 않기 때문에 쿼리의 성능이 저하될 수 있다
select a.deptno,
       (select x.empno
           from (select empno, deptno
               from emp
               order by sal desc, empno desc) x
           where x.deptno = a.deptno and rownum <= 1) as empno
from dept a;
-- 12.1 버전부터는 아래와 같이 작성할 수 있다
select a.deptno,
       (select x.empno
           from (select empno, deptno
               from emp x
                where x.deptno = a.deptno
               order by x.sal desc, x.empno desc) x
           where rownum <= 1) as empno
from dept a;


-- 분석 함수 방식
-- 분석함수 방식의 top-n쿼리는 window sort pushed rank 오퍼레이션으로 동작한다
-- count 함수를 사용하면 해당 오퍼레이션으로 동작할 수 없기 때문에 성능이 저하될 수 있다
-- 아래는 row_number 함수를 사용한 top-n쿼리이다
select *
from (select empno, sal,
             row_number () over(order by sal, empno) as rn
    from emp)
where rn <= 5
order by sal, empno;


-- row limiting 절
-- ansi 표준
-- 12.1 버전부터 row limiting절로 top-n 쿼리를 작성할 수 있다
/*
 ORDER BY 절 후에 기술한다
 ROW 와 ROWS는 구분하지 않음
 [OFFSET offset {ROW|ROWS}]
 [FETCH {FIRST|NEXT} [{rowcount|percent PERCENT}] {ROW|ROWS}{ONLY | WITH TIES}]
 OFFSET offset : 건너뛸 행의 개수
 FETCH : 반환할 행의 개수나 백분율을 지정
 ONLY : 지정된 행의 개수나 백분율 만큼 행을 반환
 WITH TIES : 마지막 행에 대한 동순위를 포함해서 반환
 */
select empno, sal from emp order by sal, empno fetch first 5 rows only;

-- OFFSET 만 기술하면 건너뛴 행 이후의 전체 행이 반환된다
select empno, sal from emp order by sal, empno offset 5 rows;

--percent 키워드를 사용하면 반환할 행의 백분율을 지정할 수 있다
-- 전체 행에 대한 비율을 계산해야 하기 때문에 쿼리의 성능이 저하될 수 있다
select empno, sal from emp order by sal, empno fetch first 25 percent rows only;


-- 고급 주제
-- top-n 쿼리와 조인

-- 조인후 top-n처리
-- emp 테이블이 14건이므로 조인을 14번 수행하고, 2건의 결과를 반환
-- emp 테이블과 dept 테이블은 조인차수가 M:1이고, 아우터 조인으로 조인했기 때문에 emp 테이블을 top-n 처리한 후 dept 테이블을 조인해도 동일한 결과를 얻을 수 있다
-- 예제의 경우 emp 테이블이 dept 테이블에 대해 필수 관계를 가지므로 이너 조인으로 조인해도 결과가 동일
select empno, sal, deptno, dname
from (select a.empno, a.sal, a.deptno, b.dname
    from emp a, dept b
    where b.deptno(+) = a.deptno
    order by a.sal, a.empno)
where rownum <= 2;
-- 위의 쿼리와 동일하지만 조인이 2번만 수앻되므로 성능 측면에서 유리하다
select a.empno, a.sal, a.deptno, b.dname
from (select *
    from (select empno, sal, deptno from emp order by sal, empno)
    where rownum <= 2) a,
     dept b
where b.deptno(+) = a.deptno
order by a.sal, a.empno;

-- 1개의 열만 조회할 경우 top-n 처리 후 스칼라 서브 쿼리를 수행할 수 있다
select a.empno, a.sal, a.deptno,
       (select x.dname from dept x where x.deptno = a.deptno) as dname
from (select empno, sal, deptno from emp order by sal, empno) a
where rownum <= 2;

-- 아래 쿼리는 top-n 처리 후 조인하는 방식으로 변경할 수 없다
-- emp테이블이 dept 테이블에 대해 필수 관계를 가지더라도 b.loc = 'DALLAS' 조건에 의해 인라인 뷰의 결과 집합이 달라질 수 있다
select empno, sal, deptno, dname
from (select a.empno, a.sal, a.deptno, b.dname
    from emp a, dept b
    where b.deptno = a.deptno and b.loc = 'DALLAS'
    order by a.sal, a.empno)
where rownum <= 2;
-- 아래에서 그 사실을 확인할 수 있다
select a.empno, a.sal, a.deptno, b.dname
from (select * from (select empno, sal, deptno from emp order by sal, empno) where rownum <= 2) a,
     dept b
where b.deptno(+) = a.deptno and
      b.loc(+) = 'DALLAS'
order by a.sal, a.empno;


-- top-n 쿼리와 union all 연산자
-- 결과 집합을 정렬해야 하므로 소트 부하가 발생할 수 있다
select *
from (select 1 as tp, deptno as no, dname as name from DEPT
    union all
    select 2 as tp, deptno as no, ename as name from emp
    order by tp, no)
where rownum <= 3;
-- union all 연산자는 순차적으로 수행된다
-- tp에 의해 기술 순서와 정렬 순서가 동일하므로 아래 쿼리처럼 데이터 집합 별로 top-n 처리를 수행하면 소트 부하를 경감시킬 수 있다
-- 아래 쿼리는 emp 테이블을 읽지 않고 결과를 반환한다
-- dept 테이블 쿼리 실행 후 where절 실행 + emp 테이블 쿼리 실행 후 where 절 실행 이라서 rownum <=3을 보고 쿼리를 바로 종료하는듯
select *
from (select *
from (select 1 as tp, deptno as no, dname as name from DEPT order by no)
where ROWNUM <= 3
    union all
    select *
from (select 2 as tp, deptno as no, ename as name from emp order by no)
where rownum <=3)
where rownum <= 3;