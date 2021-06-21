select *
from emp;

select player_name as "App le", position 위치, height as 위치, height as 키, weight as 몸무게
from player; /*alias*/

select player_name as 선수명, height - weight as "키-몸무게"
from player;

select player_name as 선수명, round(weight / ((height / 100) * (height / 100)), 2) as "bmi 비만지수"
from player; /* round 함수 : 반올림 함수 */

select player_name || ' 선수, ' || height || ' cm, ' || weight || ' kg' as 체격정보
from player;
select concat(player_name, ' 선수, ', height, ' cm, ', weight, ' kg') as 체격정보
from player; /* concat은 2개의 인자만 입력가능하지만 여러개도 가능하긴 한 듯 하다*/

select length('SQL Expert') as len
from dual;

select *
from dual;

select concat(PLAYER_NAME, ' 축구선수') as 선수명
from player;
select player_name || ' 축구선수' as 선수명
from player;

select STADIUM_ID, ddd || ')' || tel as tel, length(ddd || '-' || tel) as t_len
from stadium;

select ceil(30.1)
from dual;

select sysdate
from dual;

select ename                        as 사원명,
       hiredate                     as 입사일자,
       extract(year from hiredate)  as 입사년도,
       extract(month from hiredate) as 입사월,
       extract(day from hiredate)   as 입사일
from emp;
select ename                                as 사원명,
       hiredate                             as 입사일자,
       to_number(to_char(hiredate, 'YYYY')) as 입사년도,
       to_number(to_char(hiredate, 'MM'))   as 입사월,
       to_number(to_char(hiredate, 'DD'))   as 입사일
from emp;

select to_char(sysdate, 'YYYY/MM/DD') as 날짜, to_char(sysdate, 'YYYY. MON, DAY') as 문자형
from dual;

select to_char(123456789 / 1200, '$999,999,999.99') as 환율반영달러, to_char(123456789, 'L999,999,999') as 원화
from dual; --to_char(x,'$nnn,nnn') n은 자리수 하나하나를 나타낸다

select team_id as 팀ID, to_number(ZIP_CODE1, '999') + to_number(ZIP_CODE2, '999') as 우편번호합
from team;
select *
from team;

select ename,
       case
           when sal > 2000 then sal
           else 2000
           end as revised_salary
from emp;

select LOC,
       case loc
           when 'NEW YORK' then 'EAST'
           when 'BOSTON' then 'EAST'
           when 'CHICAGO' then 'CENTER'
           when 'DALLAS' then 'CENTER'
           else 'ETC'
           end as area
from dept;

SELECT ENAME,
       CASE
           WHEN SAL >= 3000 THEN 'HIGH'
           WHEN SAL >= 1000 THEN 'MID'
           ELSE 'LOW'
           END AS SALARY_GRADE
FROM EMP;

SELECT ENAME,
       SAL,
       CASE
           WHEN SAL >= 2000 THEN 1000
           ELSE (CASE WHEN SAL >= 1000 THEN 500 ELSE 0 END)
           END AS BONUS
FROM EMP;

SELECT NVL(NULL, 'NVL-OK') AS NVL_TEST
FROM DUAL;
SELECT NVL('NOT NULL', 'NVL-OK') AS NVL_TEST
FROM DUAL;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, NVL(POSITION, '없음') AS NL포지션
FROM PLAYER
WHERE TEAM_ID = 'K08';
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, CASE WHEN POSITION IS NULL THEN '없음' ELSE POSITION END AS NL포지션
FROM PLAYER
WHERE TEAM_ID = 'K08';

SELECT ENAME AS 사원명, SAL AS 월급, COMM AS 커미션, (SAL * 12) + COMM AS 연봉A, (SAL * 12) + NVL(COMM, 0) AS 연봉B
FROM EMP;

SELECT MGR
FROM EMP
WHERE ENAME = 'SCOTT';
SELECT MGR
FROM EMP
WHERE ENAME = 'KING';
SELECT NVL(MGR, 9999) AS MGR
FROM EMP
WHERE ENAME = 'KING';

SELECT MGR
FROM EMP
WHERE ENAME = 'JSC';
SELECT NVL(MGR, 9999) AS MGR
FROM EMP
WHERE ENAME = 'JSC';
SELECT MAX(MGR) AS MGR
FROM EMP
WHERE ENAME = 'JSC';
SELECT NVL(MAX(MGR), 9999) AS MGR
FROM EMP
WHERE ENAME = 'JSC';

SELECT ENAME, EMPNO, MGR, NULLIF(MGR, 7698) AS NUIF
FROM EMP;

SELECT ENAME, COMM, COALESCE(COMM, SAL) AS COAL
FROM EMP;
SELECT ENAME, COMM, CASE WHEN COMM IS NULL THEN (CASE WHEN SAL IS NULL THEN NULL ELSE SAL END) ELSE COMM END AS COAL
FROM EMP;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID IN ('K02', 'K07');

SELECT ENAME, JOB, DEPTNO
FROM EMP
WHERE (JOB, DEPTNO) IN (('MANAGER', 20), ('CLERK', 30)); --이것과 아래의 쿼리 결과는 서로 다르니 주의
SELECT ENAME, JOB, DEPTNO
FROM EMP
WHERE JOB IN ('MANAGER', 'CLERK')
  AND DEPTNO IN (20, 30);

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION LIKE 'MF';
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE PLAYER_NAME LIKE '장%';
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE PLAYER_NAME LIKE '장_호';

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE HEIGHT BETWEEN 170 AND 180;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
  AND POSITION <> 'MF'
  AND NOT HEIGHT BETWEEN 175 AND 185;

SELECT COUNT(*)              AS 전체행수,
       COUNT(HEIGHT)         AS 키건수,
       MAX(HEIGHT)           AS 최대키,
       MIN(HEIGHT)           AS 최소키,
       ROUND(AVG(HEIGHT), 2) AS 평균키
FROM PLAYER;

SELECT POSITION              AS 포지션,
       COUNT(*)              AS 인원수,
       COUNT(HEIGHT)         AS 키대상,
       MAX(HEIGHT)           AS 최대키,
       MIN(HEIGHT)           AS 최소키,
       ROUND(AVG(HEIGHT), 2) AS 평균키
FROM PLAYER
GROUP BY POSITION;

SELECT POSITION AS 포지션, ROUND(AVG(HEIGHT), 2) AS 평균키
FROM PLAYER
GROUP BY POSITION
HAVING AVG(HEIGHT) >= 180;

SELECT ENAME AS 사원명, DEPTNO AS 부서번호, EXTRACT(MONTH FROM HIREDATE) AS 입사월, SAL AS 급여
FROM EMP;

SELECT ENAME                           AS 사원명,
       DEPTNO                          AS 부서번호,
       CASE MONTH WHEN 1 THEN SAL END  AS M01,
       CASE MONTH WHEN 2 THEN SAL END  AS MO2,
       CASE MONTH WHEN 3 THEN SAL END  AS M03,
       CASE MONTH WHEN 4 THEN SAL END  AS MO4,
       CASE MONTH WHEN 5 THEN SAL END  AS M05,
       CASE MONTH WHEN 6 THEN SAL END  AS MO6,
       CASE MONTH WHEN 7 THEN SAL END  AS M07,
       CASE MONTH WHEN 8 THEN SAL END  AS MO8,
       CASE MONTH WHEN 9 THEN SAL END  AS M09,
       CASE MONTH WHEN 10 THEN SAL END AS M10,
       CASE MONTH WHEN 11 THEN SAL END AS M11,
       CASE MONTH WHEN 12 THEN SAL END AS M12
FROM (SELECT ENAME, DEPTNO, EXTRACT(MONTH FROM HIREDATE) AS MONTH, SAL FROM EMP);

SELECT DEPTNO                      AS 부서번호,
       AVG(DECODE(MONTH, 1, SAL))  AS M01,
       AVG(DECODE(MONTH, 2, SAL))  AS MO2,
       AVG(DECODE(MONTH, 3, SAL))  AS M03,
       AVG(DECODE(MONTH, 4, SAL))  AS MO4,
       AVG(DECODE(MONTH, 5, SAL))  AS M05,
       AVG(DECODE(MONTH, 6, SAL))  AS MO6,
       AVG(DECODE(MONTH, 7, SAL))  AS M07,
       AVG(DECODE(MONTH, 8, SAL))  AS MO8,
       AVG(DECODE(MONTH, 9, SAL))  AS M09,
       AVG(DECODE(MONTH, 10, SAL)) AS M10,
       AVG(DECODE(MONTH, 11, SAL)) AS M11,
       AVG(DECODE(MONTH, 12, SAL)) AS M12
FROM (SELECT DEPTNO, EXTRACT(MONTH FROM HIREDATE) AS MONTH, SAL FROM EMP)
GROUP BY DEPTNO;

SELECT TEAM_ID,
       NVL(SUM(CASE POSITION WHEN 'FW' THEN 1 END), 0) AS FW,
       NVL(SUM(CASE POSITION WHEN 'MF' THEN 1 END), 0) AS MF,
       NVL(SUM(CASE POSITION WHEN 'DF' THEN 1 END), 0) AS DF,
       NVL(SUM(CASE POSITION WHEN 'GK' THEN 1 END), 0) AS GK,
       COUNT(*)                                        AS SUM
FROM PLAYER
GROUP BY TEAM_ID;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버
FROM PLAYER
ORDER BY 선수명 DESC;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버
FROM PLAYER
WHERE BACK_NO IS NOT NULL
ORDER BY 3 DESC, 2, 1;



SELECT EMPNO, ENAME
FROM EMP
ORDER BY MGR; --SELECT절에 없는 COLUMN을 사용하여 정렬

SELECT EMPNO
FROM (SELECT EMPNO, ENAME FROM EMP ORDER BY MGR);

SELECT JOB, SUM(SAL)
FROM EMP
GROUP BY JOB
HAVING SUM(SAL) > 5000
ORDER BY SUM(SAL);

SELECT PLAYER.PLAYER_NAME AS 선수명, TEAM.TEAM_NAME AS 소속팀명
FROM PLAYER,
     TEAM
WHERE TEAM.TEAM_ID = PLAYER.TEAM_ID;
SELECT PLAYER.PLAYER_NAME AS 선수명, TEAM.TEAM_NAME AS 소속팀명
FROM PLAYER
         INNER JOIN TEAM ON TEAM.TEAM_ID = PLAYER.TEAM_ID;

SELECT A.PLAYER_NAME AS 선수명, A.POSITION AS 포지션, B.REGION_NAME AS 연고지, B.TEAM_NAME AS 팀명, C.STADIUM_NAME AS 구장명
FROM PLAYER A,
     TEAM B,
     STADIUM C
WHERE B.TEAM_ID = A.TEAM_ID
  AND C.STADIUM_ID = B.STADIUM_ID
ORDER BY 선수명;

SELECT A.STADIUM_NAME, A.STADIUM_ID, A.SEAT_COUNT, A.HOMETEAM_ID, B.TEAM_NAME
FROM STADIUM A,
     TEAM B
WHERE B.TEAM_ID(+) = A.HOMETEAM_ID
ORDER BY A.HOMETEAM_ID;

SELECT A.EMPNO, A.ENAME, B.DEPTNO, B.DNAME
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO;
SELECT A.EMPNO, A.ENAME, B.DEPTNO, B.DNAME
FROM EMP A
         INNER JOIN DEPT B ON B.DEPTNO = A.DEPTNO;

SELECT A.EMPNO, A.ENAME, DEPTNO, B.DNAME
FROM EMP A
         NATURAL JOIN DEPT B;

CREATE TABLE DEPT_TEMP AS
SELECT *
FROM DEPT;
UPDATE DEPT_TEMP
SET DNAME = 'CONSULTING'
WHERE DNAME = 'RESEARCH';
UPDATE DEPT_TEMP
SET DNAME = 'MARKETING'
WHERE DNAME = 'SALES';
SELECT *
FROM DEPT_TEMP;

SELECT *
FROM DEPT A
         NATURAL INNER JOIN DEPT_TEMP B;
SELECT *
FROM DEPT A
         JOIN DEPT_TEMP B ON B.DEPTNO = A.DEPTNO AND B.DNAME = A.DNAME AND B.LOC = A.LOC;

SELECT *
FROM DEPT A
         JOIN DEPT_TEMP B USING (DEPTNO);

SELECT *
FROM DEPT A
         JOIN DEPT_TEMP B USING (LOC, DEPTNO);

SELECT A.EMPNO, A.DEPTNO, B.DNAME, C.DNAME AS NEW_DNAME
FROM EMP A
         JOIN DEPT B ON B.DEPTNO = A.DEPTNO
         JOIN DEPT_TEMP C ON C.DEPTNO = B.DEPTNO;
SELECT A.EMPNO, A.DEPTNO, B.DNAME, C.DNAME AS NEW_DNAME
FROM EMP A,
     DEPT B,
     DEPT_TEMP C
WHERE B.DEPTNO = A.DEPTNO
  AND C.DEPTNO = B.DEPTNO;

SELECT A.ENAME, B.DNAME
FROM EMP A
         CROSS JOIN DEPT B
ORDER BY A.ENAME;

/**
  단일 행 서브쿼리
 */
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버
FROM PLAYER
WHERE TEAM_ID = (SELECT TEAM_ID
                 FROM PLAYER
                 WHERE PLAYER_NAME = '정남일')
ORDER BY PLAYER_NAME;

SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버
FROM PLAYER
WHERE HEIGHT <= (SELECT AVG(HEIGHT)
                 FROM PLAYER)
ORDER BY PLAYER_NAME;

/**
  다중 행 서브 쿼리
 */

SELECT REGION_NAME AS 연고지명, TEAM_NAME AS 팀명, E_TEAM_NAME AS 영문팀명
FROM TEAM
WHERE TEAM_ID = (SELECT TEAM_ID
                 FROM PLAYER
                 WHERE PLAYER_NAME = '정현수')
ORDER BY TEAM_NAME;

SELECT REGION_NAME AS 연고지명, TEAM_NAME AS 팀명, E_TEAM_NAME AS 영문팀명
FROM TEAM
WHERE TEAM_ID IN (SELECT TEAM_ID
                  FROM PLAYER
                  WHERE PLAYER_NAME = '정현수')
ORDER BY TEAM_NAME;

/**
  다중 칼럼 서브 쿼리
 */

SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE (TEAM_ID, HEIGHT) IN (SELECT TEAM_ID, MIN(HEIGHT)
                            FROM PLAYER
                            GROUP BY TEAM_ID)
ORDER BY TEAM_ID, PLAYER_NAME;

/**
  연관 서브 쿼리
 */

SELECT B.TEAM_NAME AS 팀명, A.PLAYER_NAME AS 선수명, A.POSITION AS 포지션, A.BACK_NO AS 백넘버, A.HEIGHT AS 키
FROM PLAYER A,
     TEAM B
WHERE A.HEIGHT < (SELECT AVG(X.HEIGHT)
                  FROM PLAYER X
                  WHERE X.TEAM_ID = A.TEAM_ID
                  GROUP BY X.TEAM_ID)
  AND B.TEAM_ID = A.TEAM_ID
ORDER BY 선수명;

SELECT A.STADIUM_ID AS ID, A.STADIUM_NAME AS 경기장명
FROM STADIUM A
WHERE EXISTS(SELECT 1
             FROM SCHEDULE X
             WHERE X.STADIUM_ID = A.STADIUM_ID
               AND X.SCHE_DATE BETWEEN '20120501' AND '20120502');

/**
  SELECT 절에 서브 쿼리 사용하기
 */
-- 스칼라 서브 쿼리라고도 함
-- 메인 쿼리가 반복될때마다 서브쿼리가 반복수행됨
SELECT A.PLAYER_NAME                           AS 선수명,
       A.HEIGHT                                AS 키,
       ROUND((SELECT AVG(X.HEIGHT)
              FROM PLAYER X
              WHERE X.TEAM_ID = A.TEAM_ID), 3) AS 팀평균키
FROM PLAYER A;

/**
  FROM 절에 서브 쿼리 사용하기
 */
-- 인라인 뷰라고 함
-- 인라인 뷰에서는 ORDER BY 절이 사용가능하다.
SELECT B.TEAM_NAME AS 팀명, A.PLAYER_NAME AS 선수명, A.BACK_NO AS 백넘버
FROM (SELECT TEAM_ID, PLAYER_NAME, BACK_NO
      FROM PLAYER
      WHERE POSITION = 'MF') A
   , TEAM B
WHERE B.TEAM_ID = A.TEAM_ID
ORDER BY 선수명;

-- ORDER BY 절 사용 예
SELECT PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM (SELECT PLAYER_NAME, POSITION, BACK_NO, HEIGHT
      FROM PLAYER
      WHERE HEIGHT IS NOT NULL
      ORDER BY HEIGHT DESC)
WHERE ROWNUM <= 5;

/**
  HAVING 절에서 서브 쿼리 사용하기
 */

SELECT A.TEAM_ID AS 팀코드, B.TEAM_NAME AS 팀명, ROUND(AVG(A.HEIGHT), 3) AS 평균키
FROM PLAYER A,
     TEAM B
WHERE B.TEAM_ID = A.TEAM_ID
GROUP BY A.TEAM_ID, B.TEAM_NAME
HAVING AVG(A.HEIGHT) < (SELECT AVG(X.HEIGHT)
                        FROM PLAYER X
                        WHERE X.TEAM_ID IN (SELECT TEAM_ID
                                            FROM TEAM
                                            WHERE TEAM_NAME = '삼성블루윙즈'));

/**
  VIEW
 */

CREATE VIEW V_PLAYER_TEAM AS
SELECT A.PLAYER_NAME, A.POSITION, A.BACK_NO, B.TEAM_ID, B.TEAM_NAME
FROM PLAYER A,
     TEAM B
WHERE B.TEAM_ID = A.TEAM_ID;

CREATE VIEW V_PLAYER_TEAM_FILTER AS
SELECT PLAYER_NAME, POSITION, BACK_NO, TEAM_NAME
FROM V_PLAYER_TEAM
WHERE POSITION IN ('GK', 'MF');

SELECT PLAYER_NAME, POSITION, BACK_NO, TEAM_ID, TEAM_NAME
FROM V_PLAYER_TEAM
WHERE PLAYER_NAME LIKE '황%';

SELECT PLAYER_NAME, POSITION, BACK_NO, TEAM_ID, TEAM_NAME
FROM (SELECT A.PLAYER_NAME, A.POSITION, A.BACK_NO, B.TEAM_ID, B.TEAM_NAME
      FROM PLAYER A,
           TEAM B
      WHERE B.TEAM_ID = A.TEAM_ID)
WHERE PLAYER_NAME LIKE '황%';

DROP VIEW V_PLAYER_TEAM;

DROP VIEW V_PLAYER_TEAM_FILTER;

/**
  집합 연산자
 */

SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
UNION
SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K07';
-- WHERE 절을 적절히 사용하여 위와 같은 결과를 만들어 낼 수 있음
SELECT DISTINCT --UNION은 중복된 결과를 없애주므로 DISTINCT 를 사용하여 같은 결과를 만들어 준다
                TEAM_ID     AS 팀코드,
                PLAYER_NAME AS 선수명,
                POSITION    AS 포지션,
                BACK_NO     AS 백넘버,
                HEIGHT      AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
   OR TEAM_ID = 'K07';

SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
UNION
SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION = 'GK';
-- 중복된 결과를 출력해보자
SELECT 팀코드, 선수명, 포지션, 백넘버, 키, COUNT(*) AS 중복수
FROM (SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
      FROM PLAYER
      WHERE TEAM_ID = 'K02'
      UNION ALL
      SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
      FROM PLAYER
      WHERE POSITION = 'GK')
GROUP BY 팀코드, 선수명, 포지션, 백넘버, 키
HAVING COUNT(*) > 1;

SELECT 'P' AS 구분코드, POSITION AS 포지션, ROUND(AVG(HEIGHT), 3) AS 평균키
FROM PLAYER
GROUP BY POSITION
UNION ALL
SELECT 'T' AS 구분코드, TEAM_ID AS 팀명, ROUND(AVG(HEIGHT), 3) AS 평균키
FROM PLAYER
GROUP BY TEAM_ID
ORDER BY 1;

SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE TEAM_ID = 'K02'
MINUS
SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER
WHERE POSITION = 'MF'
ORDER BY 1, 2, 3, 4, 5;

SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER A
WHERE TEAM_ID = 'K02'
INTERSECT
SELECT TEAM_ID AS 팀코드, PLAYER_NAME AS 선수명, POSITION AS 포지션, BACK_NO AS 백넘버, HEIGHT AS 키
FROM PLAYER A
WHERE POSITION = 'GK'
ORDER BY 1, 2, 3, 4, 5;


/**
  그룹함수
 */
--ROLLUP함수
SELECT B.DNAME, A.JOB, COUNT(*) AS EMP_CNT, SUM(A.SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY B.DNAME, A.JOB
ORDER BY B.DNAME, A.JOB;
--ROLLUP 함수를 사용
SELECT B.DNAME, A.JOB, COUNT(*) AS EMP_CNT, SUM(A.SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (A.JOB, B.DNAME);
--ROLLUP + ORDER BY
SELECT B.DNAME, A.JOB, COUNT(*) AS EMP_CNT, SUM(A.SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (B.DNAME, A.JOB)
ORDER BY B.DNAME, A.JOB;

--GROUPING 함수
SELECT B.DNAME,
       GROUPING(B.DNAME) AS DNAME_GRP,
       A.JOB,
       GROUPING(A.JOB)   AS JOB_GRP,
       COUNT(*)          AS EMP_CNT,
       SUM(A.SAL)        AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (B.DNAME, A.JOB);

--GROUPING + CASE
SELECT CASE GROUPING(B.DNAME) WHEN 1 THEN 'ALL DEPARTMENTS' ELSE B.DNAME END AS DNAME,
       CASE GROUPING(A.JOB) WHEN 1 THEN 'ALL JOBS' ELSE A.JOB END            AS JOB,
       COUNT(*)                                                              AS EMP_CNT,
       SUM(A.SAL)                                                            AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (B.DNAME, A.JOB)
ORDER BY B.DNAME, A.JOB;
--ORACLE DECODE 사용
SELECT DECODE(GROUPING(B.DNAME), 1, 'ALL DEPARTMENTS', B.DNAME) AS DNAME,
       DECODE(GROUPING(A.JOB), 1, 'ALL JOBS', A.JOB)            AS JOB,
       COUNT(*)                                                 AS EMP_CNT,
       SUM(A.SAL)                                               AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (B.DNAME, A.JOB)
ORDER BY B.DNAME, A.JOB;

--ROLLUP 함수 일부 사용
SELECT DECODE(GROUPING(B.DNAME), 1, 'ALL DEPARTMENTS', B.DNAME) AS DNAME,
       DECODE(GROUPING(A.JOB), 1, 'ALL JOBS', A.JOB)            AS JOB,
       COUNT(*)                                                 AS EMP_CNT,
       SUM(A.SAL)                                               AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY B.DNAME, ROLLUP (A.JOB)
ORDER BY B.DNAME, A.JOB;

--ROLLUP 함수 결합 칼럼 사용
SELECT B.DNAME, A.JOB, A.MGR, COUNT(*) AS EMP_CNT, SUM(A.SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY ROLLUP (B.DNAME, (A.JOB, A.MGR))
ORDER BY B.DNAME, A.JOB, A.MGR;

/**
  CUBE
 */
--결합 가능한 모든 값에 대해 다차원 집계를 생성
--ROLLUP에 비해 시스템에 많은 부담을 줌
SELECT DECODE(GROUPING(B.DNAME), 1, 'ALL DEPARTMENTS', B.DNAME) AS DNAME,
       DECODE(GROUPING(A.JOB), 1, 'ALL JOBS', A.JOB)            AS JOB,
       COUNT(*)                                                 AS EMP_CNT,
       SUM(A.SAL)                                               AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY CUBE (B.DNAME, A.JOB)
ORDER BY B.DNAME, A.JOB;

/**
  GROUPING SETS
 */
SELECT DNAME, 'ALL JOBS' AS JOB, COUNT(*) AS EMP_CNT, SUM(SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY DNAME
UNION ALL
SELECT 'ALL DEPARTMENTS' AS DNAME, JOB, COUNT(*) AS EMP_CNT, SUM(SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY JOB

--GROPING SETS 사용
SELECT DECODE(GROUPING(B.DNAME), 1, 'ALL DEPARTMENTS', B.DNAME) AS DNAME,
       DECODE(GROUPING(A.JOB), 1, 'ALL JOBS', A.JOB)            AS JOB,
       COUNT(*)                                                 AS EMP_CNT,
       SUM(A.SAL)                                               AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY GROUPING SETS (B.DNAME, A.JOB)
ORDER BY B.DNAME, A.JOB;
-- GROUPING SETS의 인수들은 평등한 관계이므로 순서를 바꾸어도 같은 결과가 나온다
SELECT DECODE(GROUPING(B.DNAME), 1, 'ALL DEPARTMENTS', B.DNAME) AS DNAME,
       DECODE(GROUPING(A.JOB), 1, 'ALL JOBS', A.JOB)            AS JOB,
       COUNT(*)                                                 AS EMP_CNT,
       SUM(A.SAL)                                               AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY GROUPING SETS (A.JOB, B.DNAME)
ORDER BY B.DNAME, A.JOB;

SELECT B.DNAME, A.JOB, A.MGR, COUNT(*) AS EMP_CNT, SUM(A.SAL) AS SAL_SUM
FROM EMP A,
     DEPT B
WHERE B.DEPTNO = A.DEPTNO
GROUP BY GROUPING SETS ((B.DNAME, A.JOB, A.MGR), ( B.DNAME, A.JOB), ( A.JOB, A.MGR));

/**
  RANK
 */
--하나의 SQL문장에 ORDER BY SAL DESC조건과 PARTITION BY JOB 조건이 충돌하였기 때문에 ORDER BY SAL DESC로 정렬됨
SELECT JOB,
       ENAME,
       SAL,
       RANK() OVER (ORDER BY SAL DESC)                  AS ALL_RK,
       RANK() OVER (PARTITION BY JOB ORDER BY SAL DESC) AS JOB_RK
FROM EMP;
-- 조건을 하나만 넣었을 때에는 충돌이 일어나지 않음
SELECT JOB, ENAME, SAL, RANK() OVER (PARTITION BY JOB ORDER BY SAL DESC) AS JOB_RK
FROM EMP;
--DENSE_RANK
SELECT JOB
     , ENAME
     , SAL
     , RANK() OVER (ORDER BY SAL DESC)       AS RK
     , DENSE_RANK() OVER (ORDER BY SAL DESC) AS DR
FROM EMP;
--ROW_NUMBER
SELECT JOB
     , ENAME
     , SAL
     , RANK() OVER (ORDER BY SAL DESC)       AS RK
     , ROW_NUMBER() OVER (ORDER BY SAL DESC) AS RN
FROM EMP;

/**
  일반 집계 함수
 */
--SUM
SELECT MGR, ENAME, SAL, SUM(SAL) OVER (PARTITION BY MGR) AS SAL_SUM
FROM EMP;
--누적합
SELECT MGR, ENAME, SAL, SUM(SAL) OVER (PARTITION BY MGR ORDER BY SAL RANGE UNBOUNDED PRECEDING) AS SAL_SUM
FROM EMP;
--MAX
SELECT MGR, ENAME, SAL, MAX(SAL) OVER (PARTITION BY MGR) AS MAX_SAL
FROM EMP;
--MAX값을 가지는 행만 출력 (성능 저하)
SELECT MGR, ENAME, SAL
FROM (SELECT MGR, ENAME, SAL, MAX(SAL) OVER (PARTITION BY MGR) AS MAX_SAL FROM EMP)
WHERE SAL = MAX_SAL;
--MAX값을 가지는 행만 출력 (성능 향상)
SELECT MGR, ENAME, SAL
FROM (SELECT MGR, ENAME, SAL, RANK() OVER (PARTITION BY MGR ORDER BY SAL) AS SAL_RK FROM EMP)
WHERE SAL_RK = 1;
--MIN
SELECT MGR, ENAME, HIREDATE, SAL, MIN(SAL) OVER (PARTITION BY MGR ORDER BY HIREDATE) AS MIN_SAL
FROM EMP;
--AVG
SELECT MGR,
       ENAME,
       HIREDATE,
       SAL,
       ROUND(AVG(SAL) OVER (PARTITION BY MGR ORDER BY HIREDATE ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)) AS AVG_SAL
FROM EMP;
--COUNT
SELECT ENAME, SAL, COUNT(*) OVER (ORDER BY SAL RANGE BETWEEN 50 PRECEDING AND 150 FOLLOWING) AS EMP_CNT
FROM EMP;

/**
   그룹 내 행 순서 함수
 */
--FIRST_VALUE
SELECT DEPTNO,
       ENAME,
       SAL,
       FIRST_VALUE(ENAME) OVER (PARTITION BY DEPTNO ORDER BY SAL DESC ROWS UNBOUNDED PRECEDING) AS ENAME_FV
FROM EMP;

SELECT DEPTNO,
       ENAME,
       SAL,
       FIRST_VALUE(ENAME) OVER (PARTITION BY DEPTNO ORDER BY SAL DESC, ENAME ROWS UNBOUNDED PRECEDING) AS ENAME_FV
FROM EMP;
--LAST_VALUE
SELECT DEPTNO,
       ENAME,
       SAL,
       LAST_VALUE(ENAME)
                  OVER (PARTITION BY DEPTNO ORDER BY SAL DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS ENAME_LV
FROM EMP;
--LAG 이전 몇 번째 행의 값을 가져온다
SELECT ENAME, HIREDATE, SAL, LAG(SAL) OVER (ORDER BY HIREDATE) AS LAG_SAL
FROM EMP
WHERE JOB = 'SALESMAN';

SELECT ENAME, HIREDATE, SAL, LAG(SAL, 2, 0) OVER (ORDER BY HIREDATE) AS LAG_SAL
FROM EMP
WHERE JOB = 'SALESMAN';
--LEAD 이후 몇 번째 행의 값을 가져온다
SELECT ENAME, HIREDATE, LEAD(HIREDATE, 1) OVER (ORDER BY HIREDATE) AS LEAD_HIREDATE
FROM EMP
WHERE JOB = 'SALESMAN';

/**
  그룹 내 비율 함수
 */
--RATIO_TO_REPORT 백분율
SELECT ENAME, SAL, ROUND(RATIO_TO_REPORT(SAL) over (), 2) AS SAL_PR
FROM EMP
WHERE JOB = 'SALESMAN';
--PERCENT_RANK 랭크 백분율
SELECT DEPTNO, ENAME, SAL, PERCENT_RANK() OVER (PARTITION BY DEPTNO ORDER BY SAL DESC) AS PR
FROM EMP;
--CUME_DIST 누적 백분율
SELECT DEPTNO, ENAME, SAL, CUME_DIST() OVER (PARTITION BY DEPTNO ORDER BY SAL DESC) AS CD
FROM EMP;
--NTILE
SELECT ENAME, SAL, NTILE(4) OVER ( ORDER BY SAL DESC) AS NT
FROM EMP;

/**
  TOP N QUERY
 */
--ROWNUM
SELECT ENAME, SAL
FROM (SELECT ENAME, SAL FROM EMP ORDER BY SAL DESC)
WHERE ROWNUM <= 3;
--ROW LIMITING
SELECT EMPNO, SAL
FROM EMP
ORDER BY SAL, EMPNO FETCH FIRST 5 ROWS ONLY;
-- OFFSET
SELECT EMPNO, SAL
FROM EMP
ORDER BY SAL, EMPNO
OFFSET 5 ROWS;

/**
  계층형 질의와 셀프 조인
 */
SELECT WORKER.EMPNO AS 사원번호, WORKER.ENAME AS 사원명, MANAGER.ENAME AS 관리자명
FROM EMP WORKER,
     EMP MANAGER
WHERE MANAGER.EMPNO = WORKER.MGR;
--JONES의 자식노드 조회
SELECT B.EMPNO, B.ENAME, B.MGR
FROM EMP A,
     EMP B
WHERE A.ENAME = 'JONES'
  AND B.MGR = A.EMPNO;
--JONES의 자식의 자식노드 조회
SELECT C.EMPNO, C.ENAME, C.MGR
FROM EMP A,
     EMP B,
     EMP C
WHERE A.ENAME = 'JONES'
  AND B.MGR = A.EMPNO
  AND C.MGR = B.EMPNO;
--SMITH의 부모 노드 조회
SELECT B.EMPNO, B.ENAME, B.MGR
FROM EMP A,
     EMP B
WHERE A.ENAME = 'SMITH'
  AND B.EMPNO = A.MGR;

SELECT C.EMPNO, C.ENAME, C.MGR
FROM EMP A,
     EMP B,
     EMP C
WHERE A.ENAME = 'SMITH'
  AND B.EMPNO = A.MGR
  AND C.EMPNO = B.MGR;

/**
  계층형 질의
 */
SELECT LEVEL AS LV, LPAD(' ', (LEVEL - 1) * 2) || EMPNO AS EMPNO, MGR, CONNECT_BY_ISLEAF AS ISLEAF
FROM EMP
START WITH MGR IS NULL
CONNECT BY MGR = PRIOR EMPNO;
--사원 D로부터 상위관리자를 찾는 역방향 전개
SELECT LEVEL AS LV, LPAD(' ', (LEVEL - 1) * 2) || EMPNO AS EMPNO, MGR, CONNECT_BY_ISLEAF AS ISLEAF
FROM EMP
START WITH EMPNO = 7876
CONNECT BY EMPNO = PRIOR MGR;
--SYS_CONNECT_BY_PATH, CONNECT_BY_ROOT
SELECT CONNECT_BY_ROOT (EMPNO) AS ROOT_EMPNO, SYS_CONNECT_BY_PATH(EMPNO, ',') AS PATH, EMPNO, MGR
FROM EMP
START WITH MGR IS NULL
CONNECT BY MGR = PRIOR EMPNO;

/**
  PIVOT AND UNPIVOT
 */
SELECT *
FROM (SELECT JOB, DEPTNO, SAL FROM EMP)
    PIVOT (SUM(SAL) FOR DEPTNO IN (10,20,30))
ORDER BY 1;

SELECT *
FROM (SELECT TO_CHAR(HIREDATE, 'YYYY') AS YYYY, JOB, DEPTNO, SAL FROM EMP)
    PIVOT (SUM(SAL) FOR DEPTNO IN (10,20,30))
ORDER BY 1, 2;

SELECT *
FROM (SELECT JOB, DEPTNO, SAL FROM EMP) PIVOT (SUM(SAL) AS SAL FOR DEPTNO IN (10 AS D10, 20 AS D20, 30 AS D30))
ORDER BY 1;

SELECT JOB, D20_SAL
FROM (SELECT JOB, DEPTNO, SAL FROM EMP)
    PIVOT (SUM(SAL) AS SAL FOR DEPTNO IN (10 AS D10, 20 AS D20, 30 AS D30))
WHERE D20_SAL > 2500
ORDER BY 1;

SELECT *
FROM (SELECT JOB, DEPTNO, SAL FROM EMP)
    PIVOT (SUM(SAL) AS SAL, COUNT(*) AS CNT FOR DEPTNO IN (10 AS D10, 20 AS D20))
ORDER BY 1;

SELECT *
FROM (SELECT TO_CHAR(HIREDATE, 'YYYY') AS YYYY, JOB, DEPTNO, SAL FROM EMP)
    PIVOT (SUM(SAL) AS SAL, COUNT(*) AS CNT FOR (DEPTNO,JOB) IN ((10, 'ANALYST') AS D10A,(10, 'CLERK') AS D10C,(20, 'ANALYST') AS D20A,(20, 'CLERK') AS D20C))
ORDER BY 1;

--UNPIVOT
DROP TABLE T1 PURGE;

CREATE TABLE T1 AS
SELECT JOB, D10_SAL, D20_SAL, D10_CNT, D20_CNT
FROM (SELECT JOB, DEPTNO, SAL FROM EMP WHERE JOB IN ('ANALYST', 'CLERK'))
    PIVOT (SUM(SAL) AS SAL, COUNT(*) AS CNT FOR DEPTNO IN (10 AS D10, 20 AS D20));

SELECT *
FROM T1
ORDER BY JOB;

SELECT JOB, DEPTNO, SAL
FROM T1 UNPIVOT (SAL FOR DEPTNO IN (D10_SAL, D20_SAL))
ORDER BY 1, 2;

SELECT JOB, DEPTNO, SAL
FROM T1 UNPIVOT (SAL FOR DEPTNO IN (D10_SAL AS 10, D20_SAL AS 20));

SELECT JOB, DEPTNO, SAL
FROM T1 UNPIVOT INCLUDE NULLS (SAL FOR DEPTNO IN (D10_SAL AS 10, D20_SAL AS 20))
ORDER BY 1, 2;

SELECT LEVEL AS LV
FROM DUAL
CONNECT BY LEVEL <= 2;

/**
  정규 표현식
 */
--POSIX 연산자
SELECT REGEXP_SUBSTR('AAB', 'A.B')  AS C1,
       REGEXP_SUBSTR('ABB', 'A.B')  AS C2,
       REGEXP_SUBSTR('ACB', 'A.B')  AS C3,
       REGEXP_SUBSTR('ADDB', 'A.B') AS C4
FROM DUAL;

SELECT REGEXP_SUBSTR('A', 'A|B')    AS C1,
       REGEXP_SUBSTR('B', 'A|B')    AS C2,
       REGEXP_SUBSTR('C', 'A|B')    AS C3,
       REGEXP_SUBSTR('AB', 'AB|CD') AS C4,
       REGEXP_SUBSTR('CD', 'AB|CD') AS C5,
       REGEXP_SUBSTR('BC', 'AB|CD') AS C6,
       REGEXP_SUBSTR('AA', 'A|AA')  AS C7,
       REGEXP_SUBSTR('AA', 'AA|A')  AS C8
FROM DUAL;

SELECT REGEXP_SUBSTR('A|B', 'A|B')  AS C1,
       REGEXP_SUBSTR('A|B', 'A\|B') AS C2
FROM DUAL;

SELECT REGEXP_SUBSTR('AB' || CHR(10) || 'CD', '^.', 1, 1) AS C1,
       REGEXP_SUBSTR('AB' || CHR(10) || 'CD', '^.', 1, 2) AS C2,
       REGEXP_SUBSTR('AB' || CHR(10) || 'CD', '.$', 1, 1) AS C3,
       REGEXP_SUBSTR('AB' || CHR(10) || 'CD', '.$', 1, 2) AS C4
FROM DUAL;

SELECT REGEXP_SUBSTR('AC', 'AB?C')   AS C1,
       REGEXP_SUBSTR('ABC', 'AB?C')  AS C2,
       REGEXP_SUBSTR('ABBC', 'AB?C') AS C3,
       REGEXP_SUBSTR('AC', 'AB*C')   AS C4,
       REGEXP_SUBSTR('ABC', 'AB*C')  AS C5,
       REGEXP_SUBSTR('ABBC', 'AB*C') AS C6,
       REGEXP_SUBSTR('AC', 'AB+C')   AS C7,
       REGEXP_SUBSTR('ABC', 'AB+C')  AS C8,
       REGEXP_SUBSTR('ABBC', 'AB+C') AS C9
FROM DUAL;

SELECT REGEXP_SUBSTR('AB', 'A{2}')      AS C1,
       REGEXP_SUBSTR('AAB', 'A{2}')     AS C2,
       REGEXP_SUBSTR('AAB', 'A{3,}')    AS C3,
       REGEXP_SUBSTR('AAAB', 'A{3,}')   AS C4,
       REGEXP_SUBSTR('AAAB', 'A{4,5}')  AS C5,
       REGEXP_SUBSTR('AAAAB', 'A{4,5}') AS C6
FROM DUAL;

SELECT REGEXP_SUBSTR('ABXAB', '(AB|CD)X\1') AS C1,
       REGEXP_SUBSTR('CDXCD', '(AB|CD)X\1') AS C2,
       REGEXP_SUBSTR('ABXEF', '(AB|CD)X\1') AS C3,
       REGEXP_SUBSTR('ABABAB', '(.*)\1+')   AS C4,
       REGEXP_SUBSTR('ABCABC', '(.*)\1+')   AS C5,
       REGEXP_SUBSTR('ABCABD', '(.*)\1+')   AS C6
FROM DUAL;

SELECT REGEXP_SUBSTR('AC', '[AB]C')  AS C1,
       REGEXP_SUBSTR('BC', '[AB]C')  AS C2,
       REGEXP_SUBSTR('CC', '[AB]C')  AS C3,
       REGEXP_SUBSTR('AC', '[^AB]C') AS C4,
       REGEXP_SUBSTR('BC', '[^AB]C') AS C5,
       REGEXP_SUBSTR('CC', '[^AB]C') AS C6
FROM DUAL;

SELECT REGEXP_SUBSTR('1A', '[0-9][A-Z]')   AS C1,
       REGEXP_SUBSTR('9Z', '[0-9][A-Z]')   AS C2,
       REGEXP_SUBSTR('aA', '[^0-9][^A-Z]') AS C3,
       REGEXP_SUBSTR('Aa', '[^0-9][^A-Z]') AS C4
FROM DUAL;

SELECT REGEXP_SUBSTR('gF1,', '[[:digit:]]')  AS C1,
       REGEXP_SUBSTR('gF1,', '[[:alpha:]]')  AS C2,
       REGEXP_SUBSTR('gF1,', '[[:lower:]]')  AS C3,
       REGEXP_SUBSTR('gF1,', '[[:upper:]]')  AS C4,
       REGEXP_SUBSTR('gF1,', '[[:alnum:]]')  AS C5,
       REGEXP_SUBSTR('gF1,', '[[:xdigit:]]') AS C6,
       REGEXP_SUBSTR('gF1,', '[[:punct:]]')  AS C7
FROM DUAL;

--PERL 정규 표현식 연산자
SELECT REGEXP_SUBSTR('(650) 555-0100', '^\(\d{3}\) \d{3}-\d{4}$') AS C1,
       REGEXP_SUBSTR('605-555-0100', '^\(\d{3}\) \d{3}-\d{4}$')   AS C2,
       REGEXP_SUBSTR('b2b', '\w\d\D')                             AS C3,
       REGEXP_SUBSTR('b2_', '\w\d\D')                             AS C4,
       REGEXP_SUBSTR('b22', '\w\d\D')                             AS C5
FROM DUAL;

SELECT REGEXP_SUBSTR('jdoe@company.co.uk', '\w+@\w+(\.\w+)+') AS C1,
       REGEXP_SUBSTR('jdoe@company', '\w+@\w+(\.\w+)+')       AS C2,
       REGEXP_SUBSTR('to: bill', '\w+\W\s\w+')                AS C3,
       REGEXP_SUBSTR('to bill', '\w+\W\s\w+')                 AS C4
FROM DUAL;

SELECT REGEXP_SUBSTR('AAAA', 'A??AA')     AS C1,
       REGEXP_SUBSTR('AAAA', 'A?AA')      AS C2,
       REGEXP_SUBSTR('XAXBXC', '\w*?X\w') AS C3,
       REGEXP_SUBSTR('XAXBXC', '\w*X\w')  AS C4,
       REGEXP_SUBSTR('ABXCXD', '\w+?X\w') AS C5,
       REGEXP_SUBSTR('ABXCXD', '\w+X\w')  AS C6
FROM DUAL;

SELECT REGEXP_SUBSTR('AAAA', 'A{2}?')    AS C1,
       REGEXP_SUBSTR('AAAA', 'A{2}')     AS C2,
       REGEXP_SUBSTR('AAAAA', 'A{2,}?')  AS C3,
       REGEXP_SUBSTR('AAAAA', 'A{2,}')   AS C4,
       REGEXP_SUBSTR('AAAAA', 'A{2,4}?') AS C5,
       REGEXP_SUBSTR('AAAAA', 'A{2,4}')  AS C6
FROM DUAL;

SELECT REGEXP_SUBSTR('AAB', 'A.B') AS C1,
       REGEXP_SUBSTR('AAB', 'A.B') AS C2,
       REGEXP_SUBSTR('ACB', 'A.B') AS C3,
       REGEXP_SUBSTR('ADC', 'A.B') AS C4
FROM DUAL;

/**
  정규 표현식 조건과 함수
 */
--REGEXP_LIKE 조건
SELECT FIRST_NAME, LAST_NAME
FROM HR.EMPLOYEES
WHERE REGEXP_LIKE(FIRST_NAME, '^Ste(v|ph)en$');

SELECT PHONE_NUMBER,
       REGEXP_REPLACE(PHONE_NUMBER, '([[:digit:]]{3})\.([[:digit:]]{3})\.([[:digit:]]{4})\.', '(\1) \2-\3') AS C1
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID IN (144, 145);
--REGEXP_SUBSTR
SELECT REGEXP_SUBSTR('http://www.example.com/products', 'http://([[:alnum:]]+\.?){3,4}/?') AS C1
FROM DUAL;

SELECT REGEXP_SUBSTR('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 1) AS C1,
       REGEXP_SUBSTR('1234567890', '(123)(4(56)(78))', 1, 1, 'i', 4) AS C2
FROM DUAL;

--REGEXP_INSTR
SELECT REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 1) AS C1,
       REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 2) AS C2,
       REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 4) AS C3
FROM DUAL;

--REGEXP_COUNT
SELECT REGEXP_COUNT('123123123123123', '123', 1) AS C1,
       REGEXP_COUNT('123123123123', '123', 3)    AS C2
FROM DUAL;

/**
  DML
 */
--INSERT
INSERT INTO PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION, HEIGHT, WEIGHT, BACK_NO)
VALUES ('2002007', '박지성', 'K07', 'MF', 178, 73, 7);

INSERT INTO PLAYER
VALUES ('2002010', '이청용', 'K07', '', 'BlueDragon', '2002', 'MF', '17', NULL, NULL, '1', 180, 69);
-- 마지막으로 입력한 ID + 1로 설정할 때
INSERT INTO PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID)
VALUES ((SELECT TO_CHAR(MAX(TO_NUMBER(PLAYER_ID)) + 1) FROM PLAYER), '홍길동', 'K06');
--서브 쿼리를 이용한 다중 행 INSERT 문
INSERT INTO TEAM(TEAM_ID, REGION_NAME, TEAM_NAME, ORIG_YYYY, STADIUM_ID)
SELECT REPLACE(TEAM_ID, 'K', 'A') AS TEAM_ID,
       REGION_NAME,
       REGION_NAME || ' 올스타'      AS TEAM_NAME,
       2019                       AS ORIG_YYYY,
       STADIUM_ID
FROM TEAM
WHERE REGION_NAME IN ('성남', '인천');

INSERT INTO PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION)
SELECT 'A' || SUBSTR(PLAYER_ID, 2) AS PLAYER_ID,
       PLAYER_NAME,
       REPLACE(TEAM_ID, 'K', 'A')  AS TEAM_ID,
       POSITION
FROM PLAYER
WHERE TEAM_ID IN ('K04', 'K08');

--UPDATE
UPDATE PLAYER
SET POSITION = 'MF'
WHERE POSITION IS NULL;

UPDATE TEAM A
SET A.ADDRESS = (SELECT X.ADDRESS FROM STADIUM X WHERE X.HOMETEAM_ID = A.TEAM_ID)
WHERE A.ORIG_YYYY > 2000;
--UPDATE SUBQUERY
UPDATE STADIUM A
SET (A.DDD, A.TEL) = (SELECT X.DDD, X.TEL FROM TEAM X WHERE X.TEAM_ID = A.HOMETEAM_ID);

UPDATE STADIUM A
SET (A.DDD, A.TEL) = (SELECT X.DDD, X.TEL FROM TEAM X WHERE X.TEAM_ID = A.HOMETEAM_ID);

UPDATE STADIUM A
SET (A.DDD, A.TEL) = (SELECT X.DDD, X.TEL FROM TEAM X WHERE X.TEAM_ID = A.HOMETEAM_ID)
WHERE EXISTS(SELECT 1 FROM TEAM X WHERE X.TEAM_ID = A.HOMETEAM_ID);

MERGE INTO STADIUM T
USING TEAM S
ON (T.TEAM_ID = S.HOMETEAM_ID)
WHEN MATCHED THEN
    UPDATE
    SET T.DDD = S.DDD,
        T.TEL = S.TEL;

/**
  MERGE
 */
CREATE TABLE TEAM_TMP AS
SELECT NVL(B.TEAM_ID, 'K' || ROW_NUMBER() OVER (ORDER BY B.TEAM_ID, A.STADIUM_ID)) AS TEAM_ID,
       SUBSTR(A.STADIUM_NAME, 1, 2)                                                AS REGION_NAME,
       SUBSTR(A.STADIUM_NAME, 1, 2) || NVL2(B.TEAM_NAME, 'FC', '시티즌')              AS TEAM_NAME,
       A.STADIUM_ID,
       A.DDD,
       A.TEL
FROM STADIUM A,
     TEAM B
WHERE B.STADIUM_ID(+) = A.STADIUM_ID;

MERGE INTO TEAM T
USING TEAM_TMP S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN MATCHED THEN
    UPDATE
    SET T.REGION_NAME = S.REGION_NAME,
        T.TEAM_NAME   = S.TEAM_NAME,
        T.DDD         = S.DDD,
        T.TEL         = S.TEL
WHEN NOT MATCHED THEN
    INSERT (T.TEAM_ID, T.REGION_NAME,
            T.TEAM_NAME, T.STADIUM_ID, T.DDD, T.TEL)
    VALUES (S.TEAM_ID, S.REGION_NAME, S.TEAM_NAME, S.STADIUM_ID, S.DDD, S.TEL);

MERGE INTO TEAM T
USING (SELECT *
       FROM TEAM_TMP
       WHERE REGION_NAME IN ('성남', '부산', '대구', '전주')) S
ON (T.TEAM_ID = S.TEAM_ID)
WHEN MATCHED THEN
    UPDATE
    SET T.REGION_NAME = S.REGION_NAME,
        T.TEAM_NAME   = S.TEAM_NAME,
        T.DDD         = S.DDD,
        T.TEL         = S.TEL
WHEN NOT MATCHED THEN
    INSERT (T.TEAM_ID, T.REGION_NAME,
            T.TEAM_NAME, T.STADIUM_ID, T.DDD, T.TEL)
    VALUES (S.TEAM_ID, S.REGION_NAME, S.TEAM_NAME, S.STADIUM_ID, S.DDD, S.TEL);

SELECT CASE WHEN 'K' IN (NULL,'K') THEN 1 ELSE 0 END AS "CHECK"
FROM DUAL;