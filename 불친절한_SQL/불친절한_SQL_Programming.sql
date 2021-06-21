-- v$database뷰에서 데이터베이스에 대한 정보 조회
select dbid, name, created, platform_name from v$database;

-- v$instance 뷰 에서 인스턴스에 대한 정보를 조회
-- 인스턴스가 하나만 조회되면 single 서버, 2개 이상 조회되면 RAC다.
select instance_number, instance_name, version, startup_time, status from v$instance;

-- v$option 뷰에서도 RAC 여부를 확인할 수 있다
select value from v$option where parameter = 'Real Application Clusters';

select * from V$BGPROCESS;

-- ({스키마}.{테이블}.{열})
select system.dept.deptno from system.DEPT;

--SAMPLE 절
--테이블을 샘플링하여 조회
--SAMPLE [BLOCK] (SAMPLE_PERCENT) [SEED (SEED_VALUE)]
SELECT * FROM DEPT SAMPLE (50);

--인용 방식의 문자 리터럴
-- quote_delimiter는 [],{},<>,()등을 사용할 수 있다.
--{Q|q} 'quote_delimiter c[c] quote_delimiter'
select q'[2'B]' as c1, q'[{[3c]}]' as c2 from dual;

-- sqlplus 명령어인 col ... for ... 를 사용하여 열 포맷을 설정할 수 있다
-- 열의 길이를 5로 설정
-- col c1 for A5;
-- 숫자 열 포맷
-- col c1 for 9.99;
-- col c2 for 0999.99;
-- col c3 for 999.99;
-- col c4 for 990.990
-- col c5 for 9,990.990;

--날짜 리터럴
--날짜 값을 지정
alter session set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT  = 'YYYY-MM-DD HH24:MI:SS.FF';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF TZH:TZM';

SELECT DATE '2050-01-01' AS C1, TO_DATE('2050-01-01 23:59:59', 'YYYY-MM-DD HH24:MI:SS') AS C2 FROM DUAL;
SELECT TIMESTAMP '2050-01-01 23:59:59.999999999' AS C1 FROM DUAL;
SELECT TIMESTAMP '2050-01-01 23:59:59.999999999 +09:00' AS C1 FROM DUAL;

--인터벌 리터럴
--시간의 간격을 지정
--INTERVAL 'integer [- integer]' (YEAR | MONTH} [(precision)] [TO {YEAR | MONTH}]
SELECT INTERVAL '99' YEAR AS C1
, INTERVAL  '99' MONTH AS C2
, INTERVAL '99-11' YEAR TO MONTH AS C3
FROM DUAL;

SELECT INTERVAL '99' DAY AS C1,
INTERVAL '164000.999999999' SECOND(1,9) AS C2,
       INTERVAL '9 23:59:59.999999999' DAY(1) TO SECOND(9) AS C3,
       INTERVAL '239:59' HOUR(1) TO MINUTE AS C4 FROM DUAL;

--날짜 산술 연산
SELECT DATE '2050-01-31' + 31 AS C1, --31일 더함
       DATE '2050-01-31' + (1/24/60/60) AS C2, -- 1초 더함
       DATE '2050-01-31' + INTERVAL '1' SECOND AS C3 -- 1초 더함(INTERVAL를 사용하는게 가독성이 좋음)
FROM DUAL;

SELECT TIMESTAMP '2050-01-31 23:59:59.999999999'+ 31 AS C1, -- 소수점 이하 초가 유실
       TIMESTAMP '2050-01-31 23:59:59.999999999'+ INTERVAL '31' DAY AS C2 -- 소수점 이하 초가 유지
FROM DUAL;

-- 2월 31일은 존재하지 않기 때문에 에러가 발생
SELECT DATE '2050-01-31'+INTERVAL '1' MONTH AS C1 FROM DUAL;
-- ADD_MONTH 사용
SELECT ADD_MONTHS(DATE '2050-01-31',1) AS C1 FROM DUAL;

SELECT DATE '2050-01-02' - DATE'2050-01-01' AS C1, --숫자값 반환
       TIMESTAMP '2050-01-02 00:00:00' - TIMESTAMP '2050-01-01 00:00:00' AS C2, --인터벌 값 반환
       INTERVAL '2' DAY - INTERVAL '1' DAY AS C3 --인터벌 값 반환
FROM DUAL;

--ROWID
--데이터베이스에서 행을 식별할 수 있는 고유 값
SELECT DEPTNO, ROWID AS C1 FROM DEPT;

--HINT
SELECT NAME,INVERSE,VERSION FROM V$SQL_HINT WHERE VERSION LIKE '19%';

--LTRIM
--SET의 순서에 상관없이 문자가 제거됨
SELECT LTRIM('ABC','BA') AS C2 FROM DUAL;

--SUBSTR
--바이트 단위로 자를 때 SUBSTRB를 쓴다
SELECT SUBSTR('가234',4) AS C1, SUBSTRB('가234',4) AS C2 FROM DUAL;

--TRANSLATE
SELECT TRANSLATE('AAABBC','AB','1') AS C1,-- A는1, B는NULL과 일치
       TRANSLATE('AAABBC','AB','1 ') AS C2,-- A는1 B는공백과 일치
       TRANSLATE('AAABBC','AB','123') AS C3-- A는1 B는2와 일치 3은 일치되는 것이 없으므로 생략
FROM DUAL;

WITH W1 AS (
    SELECT 'A' AS C1
    FROM DUAL
    UNION ALL
    SELECT 'B' AS C1
    FROM DUAL
)
SELECT C1, TRANSLATE(C1,'AB','CD') AS C2 FROM W1;

--INSTR
--INSTR(string,substring[,position[,occurrence]])
--string의 position에서 우측으로 occurrence번째 substring의 시작 위치를 반환한다.
--position이 음수인 경우 position에서 좌측으로 substring을 검색한다
SELECT INSTR('ABABABAB','AB') AS C1,
       INSTR('ABABABAB','AC') AS C2,
       INSTR('ABABABAB','AB',9) AS C3,
       INSTR('ABABABAB','AB',1,2) AS C4,
       INSTR('ABABABAB','AB',3,2) AS C5,
       INSTR('ABABABAB','AB',-1,2) AS C6,
       INSTR('ABABABAB','AB',-3,2) AS C7
FROM DUAL;

--ROUND(n1[,n2])
--n2가 양수면 소수부, 음수면 정수부를 반올림한다
SELECT ROUND(15.59) AS C1, ROUND(15.59,1) AS C2, ROUND(15.59,-1) AS C3
FROM DUAL;
--TRUNC(N1,[,N2])
--N1을 N2자리로 버린다. N2가 양수면 소수부, 음수면 정수부를 버린다
SELECT TRUNC(15.59) AS C1, TRUNC(15.59,1) AS C2, TRUNC(15.59,-1) AS C3
FROM DUAL;

--MOD(N1,N2)
--N1을 N2로 나눈 나머지 반환 N2가 0이면 N1을 반환
--공식
--N1-(N2*FLOOR(N1/N2))
--REMAINDER(N1,N2)
--N1을 N2로 나눈 나머지를 반환 N2가 0이면 에러가 발생
--공식
--N1-(N2*ROUND(N1/N2))

SELECT MOD(11,4) AS C1, MOD(11,-4) AS C2, MOD(-11,4) AS C3, MOD(-11,-4) AS C4, MOD(11,0) AS C5 FROM DUAL;
SELECT REMAINDER(11,4) AS C1, REMAINDER(11,-4) AS C2, REMAINDER(-11,4) AS C3, REMAINDER(-11,-4) AS C4 FROM DUAL;

--WIDTH_BUCKET
--WIDTH_BUCKET(EXPR,MIN_VALUE,MAX_VALUE,NUM_BUCKETS)
--MIN_VALUE~MAX_VALUE의 범위에 대해 NUM_BUCKETS개의 버킷을 생성한 후 EXPR이 속한 버킷을 반환한다. 버킷은 반개구간(SEMI-OPEN INTERVAL)으로 생성
--EXPR이 MIN 미만이면0, MAX 초과면 NUM_BUCKETS+1값을 반환한다
WITH W1 AS (SELECT LEVEL AS C1 FROM DUAL CONNECT BY LEVEL <= 6)
SELECT C1, WIDTH_BUCKET(C1,2,6,2) AS C2 FROM W1;

--NEXT_DAY(DATE,CHAR)
--date 이후 char에 지정된 요일에 해당하는 가장 가까운 날짜 값을 반환
--일월화수목금토 == 1234567
SELECT NEXT_DAY(DATE '2050-01-01', '월') AS C1 FROM DUAL;
SELECT NEXT_DAY(DATE '2050-01-01', 2) AS C1 FROM DUAL;

--LAST_DAY(DATE)
--월말일을 반환
SELECT LAST_DAY(DATE '2050-02-15') AS C1
FROM DUAL;

--ADD_MONTHS(DATE,INTEGER)
--INTEGER 달을 더한 값이 반환
SELECT ADD_MONTHS(DATE '2050-01-15', -1) AS C1,
       ADD_MONTHS(DATE '2050-01-31',1) AS C2,
       ADD_MONTHS(DATE '2050-02-28', 1) AS C3
FROM DUAL;

--월말일 처리(PL/SQL)
CREATE OR REPLACE FUNCTION fnc_add_months(i_date IN DATE, i_integer IN NUMBER)
RETURN DATE
IS
    l_date DATE := ADD_MONTHS(i_date,i_integer);
BEGIN
    RETURN CASE
        WHEN TO_CHAR(i_date,'DD') < TO_CHAR(l_date,'DD')
        THEN i_date + NUMTOYMINTERVAL(i_integer,'MONTH')
        ELSE l_date
        END;
end fnc_add_months;

SELECT FNC_ADD_MONTHS(DATE '2050-01-15', -1) AS C1,
       FNC_ADD_MONTHS(DATE '2050-01-31',1) AS C2,
       FNC_ADD_MONTHS(DATE '2050-02-28', 1) AS C3
FROM DUAL;

--MONTH_BETWEEN(DATE1,DATE2)
--DATE1과 DATE2 사이의 개월 수를 반환한다. 서로 일자가 같거나 모두 월말일이면 정수, 그렇지 않으면 일자수를 31로 나눈 값을 반환.
--DATE2가 DATE1보다 크면 음수를 반환
SELECT MONTHS_BETWEEN(DATE '2050-04-15', DATE '2050-01-15') AS C1,
       MONTHS_BETWEEN(DATE '2050-04-30', DATE '2050-01-31') AS C2,
       MONTHS_BETWEEN(DATE '2050-04-30', DATE '2050-01-15') AS C3,
       MONTHS_BETWEEN(DATE '2050-01-15', DATE '2050-04-30') AS C4
FROM DUAL;
--2000년 기준의 근속 연수
SELECT ENAME, TRUNC(MONTHS_BETWEEN(DATE '2000-01-01',HIREDATE)/12) AS C1
FROM EMP;

--EXTRACT({YEAR|MONTH|DAY|HOUR|MINUTE|SECOND} FROM EXPR)
-- EXPR에서 날짜 정보를 추출한다
WITH W1 AS(SELECT TIMESTAMP '2050-01-02 12:34:56.789' AS DT FROM DUAL)
SELECT EXTRACT(YEAR FROM DT) AS C1,
        EXTRACT(MONTH FROM DT) AS C2,
        EXTRACT(DAY FROM DT) AS C3,
        EXTRACT(HOUR FROM DT) AS C4,
        EXTRACT(MINUTE FROM DT) AS C5,
        EXTRACT(SECOND FROM DT) AS C6
FROM W1;

--ROUND(date,[,fmt])
--fmt를 기준으로 date를 반올림 한다. fmt의 기본값은 DD다
WITH W1 AS (SELECT TO_DATE('2051-08-16 12:31:31','YYYY-MM-DD HH24:MI:SS') AS DT FROM DUAL)
SELECT ROUND(DT) AS C1, ROUND(DT,'W') AS C2 FROM W1;

--TRUNC(DATE,[,FMT])
--FMT를 기준으로 DATE를 버린다. FMT는 ROUND함수와 동일
WITH W1 AS (SELECT TO_DATE('2051-08-16 12:31:31','YYYY-MM-DD HH24:MI:SS') AS DT FROM DUAL)
SELECT TRUNC(DT) AS C1, TRUNC(DT,'DD') AS C2 FROM W1;

--소수점 이하 초의 유실
--DATE 타입을 반환하는 날짜 함수에 TIMESTAMP 값을 사용하면 소수점 이하 초가 유실된다
WITH W1 AS (SELECT TIMESTAMP '2050-01-01 23:59:59.123456789' AS DT FROM DUAL)
SELECT NEXT_DAY(DT,2) AS C1,
       CAST(NEXT_DAY(DT,2) AS TIMESTAMP) + NUMTODSINTERVAL(TO_CHAR(DT,'FF9')*1E-9,'SECOND') AS C2 FROM W1;

--변환함수
--CHAR와 VARCHAR2는 다른 모든 타입으로 변환 가능
--CHAR와 VARCHAR2가 아닌 다른 모든 타입은 CHAR와 VARCHAR2로만 변환가능

/**
  데이터 타입 변환 우선순위
  1 : DATE,INTERVAL
  2 : NUMBER
  3 : CHAR, VARCHAR2, CLOB
  4 : 기타
 */

--TO_CHAR(N[,FMT[,'nlsparam']])
/**
  FMT
  0 : 앞쪽이나 뒷쪽에 0을 출력
  9 : 한자리 숫자
  , : 구분자
  . : 소수점
  S : 부호(양수:+,음수:-)
 */

SELECT TO_CHAR(12,'0') AS C1, TO_CHAR(12,'00') AS C2,
       TO_CHAR(12,'000') AS C3, TO_CHAR(12,'9') AS C4,
       TO_CHAR(12,'99') AS C5, TO_CHAR(12,'999') AS C6,
       TO_CHAR(1,'9') AS C7, TO_CHAR(1,'S9') AS C8,
       TO_CHAR(-1,'9') AS C9, TO_CHAR(-1,'S9') AS C10,
       TO_CHAR(1234.5,'9,999') AS C11, TO_CHAR(1234.5,'9,990.00') AS C12,
       TO_CHAR(1234.5,'999G999G990D00') AS C13, --G 구분자 D 소수점
       TO_CHAR(1,'9$') AS C14 ,TO_CHAR(1,'9L') AS C15 , --L 로컬 통화 기호
       TO_CHAR(1,'9U') AS C16 , TO_CHAR(1,'9C') AS C17 , --U 이중 통화 기호 C 국제 통화 기호
       TO_CHAR(1234.5,'FM999,999,990.00') AS C18 --FM 양측 공백 제거
FROM DUAL;

--TO_CHAR({datetime | interval}[,fmt[,'nlsparam']])
--datetime,interval값을 fmt 형식의 문자 값으로 변환
--반드시 포맷을 지정해야 서버 기준 포맷에 휘둘리지 않음
SELECT TO_CHAR(DATE '2050-01-01') AS C1 FROM DUAL;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
/**
  [- / , . ; :] :문장부호
  "text" : 텍스트
  YYYY : 년
  MM : 월
  DD : 일
  HH : 시(12시간)
  HH24 : 시(24시간)
  MI : 분
  SS : 초
  FF[1...9] : 소수점 이하 초
  AM,PM : 오전,오후
  Q : 연중 분기(1~4)
  WW : 연중 주(1~53)
  DDD : 연중 일자(1~365)
  W : 월중 주(1~5)
  SSSSS : 자정 이후 초(0~86399)
  MONTH : 월 이름
  MON : 월 약자
  DAY : 요일 이름
  DY : 요일 약자
  D : 요일 숫자
  IYYY : ISO 기준 연도
  IW : ISO 기준 연중 주
 */
WITH W1 AS (SELECT TO_DATE('2050-01-02 12:34:56','YYYY-MM-DD HH24:MI:SS') AS DT FROM DUAL)
SELECT TO_CHAR(DT,'YYYYMMDD') AS C1,
       TO_CHAR(DT,'HH24"H" MI"M" SS"S"') AS C2
FROM W1;

--TO_NUMBER(EXPR[,FMT[,'nlsparam']])
--fmt형식의 expr을 숫자 값으로 변환한다
SELECT TO_NUMBER('+1,234.50') AS C1 FROM DUAL; -- 문자값에 구분자가 포함되어 있어 에러가 발생
SELECT TO_NUMBER('+123450') AS C1 FROM DUAL; --부호는 포함되어 있어도 에러발생 X
SELECT TO_NUMBER('+1,234.50','S999,999.00') AS C1 FROM DUAL;--포맷을 지정해 줘야함

--TO_DATE(CHAR[,FMT[,'nlsparam']])
--fmt 형식의 char를 DATE 값으로 변환한다.
--포맷을 지정하지 않으면 NLS_DATE_FORMAT 파라미터에 따라 에러가 발생할 수 있다.
SELECT TO_DATE('20050102123456','YYYYMMDDHH24MISS') AS C1,
       TO_DATE('2050-1-2 3:4:5','YYYY-MM-DD HH24-MI-SS') AS C2 --FMT이 정확하게 일치하지 않아도 데이터가 변환됨
       --TO_DATE('2050-1-2 3:4:5','FXYYYY-MM-DD HH24-MI-SS') AS C3 FX는 엄격한 데이터 변환에 활용한다
FROM DUAL;

--TO_TIMESTAMP(CHAR[,FMT[,'nlsparam']])
--fmt 형식의 char를 TIMESTAMP 값으로 변환한다
SELECT TO_TIMESTAMP('2050-01-02 12:34:56.789','YYYY-MM-DD HH24:MI:SS.FF3') AS C1 FROM DUAL;

--TO_YMINTERVAL('{sql_format | ym_iso_format}')
--문자값을 YEAR TO MONTH 인터벌 값으로 변환한다
 /**
   FORMAT
   sql_format : [+|-]years-months
   ym_iso_format : [-]P[years Y][months M]
  */
SELECT TO_YMINTERVAL('1-11') AS C1, TO_YMINTERVAL('P1Y11M') AS C2 FROM DUAL;

--TO_DSINTERVAL('{sql_format | ds_iso_format}')
--문자 값을 DAY TO SECOND 인터벌 값으로 변환
/**
  FORMAT
  sql_format : [+|-]days hours:minutes:seconds[.frac_secs]
  ds_iso_format : [-]P[days D][T[hours H][minutes M][seconds[.frac_secs]S]]
 */
SELECT TO_DSINTERVAL('1 23:59:59.999999999') AS C1,
       TO_DSINTERVAL('P1DT23H59M59.999999999S') AS C2 FROM DUAL;

--NUMTOMINTERVAL(n,'interval_unit')
--n을 YEAR TO MONTH 인터벌 값으로 변환한다
SELECT NUMTOYMINTERVAL(2,'YEAR') AS C1, NUMTOYMINTERVAL(23,'MONTH') AS C2 FROM DUAL;

--NUMTODSINTERVAL(n,'interval_unit')
--n을 DAY TO SECOND 인터벌 값으로 변환한다
SELECT NUMTODSINTERVAL(10,'DAY') AS C1, NUMTODSINTERVAL(24,'HOUR') AS C2,
       NUMTODSINTERVAL(60,'MINUTE') AS C3, NUMTODSINTERVAL(60,'SECOND') AS C4,
       NUMTODSINTERVAL(0.1,'SECOND') AS C5
FROM DUAL;
--NUMTODSINTERVAL을 사용하지 않았을 때
WITH W1 AS (SELECT TO_DATE('2050-01-02 12:34:56','YYYY-MM-DD HH24:MI:SS') - TO_DATE('2050-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') AS C1 FROM DUAL)
SELECT C1,
       SUBSTR(NUMTODSINTERVAL(C1,'DAY'),9,11) AS C2, --소수점 잘라냄
       TO_CHAR(TRUNC(C1),'FM00')||' '
        ||TO_CHAR(TRUNC(MOD(C1*24,24)),'FM00')||':'
        ||TO_CHAR(TRUNC(MOD(C1*24*60,60)),'FM00')||':'
        ||TO_CHAR(TRUNC(MOD(C1*24*60*60,60)),'FM00') AS C3
FROM W1;

--CAST(expr AS type_name[,fmt[,'nlsparam']])
--expr을 type_name에 지정한 데이터 타입으로 변환한다
--fmt는 12.2버전부터 사용할 수 있다
/**
  type_name
  NUMBER,DATE,TIMESTAMP,TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH LOCAL TIME ZONE
 */
SELECT CAST('123' AS VARCHAR2(5)) AS C1,
       CAST('123.456' AS NUMBER(6,3)) AS C2,
       CAST('2050-01-02' AS DATE) AS C3,
       CAST('2050-01-02 12:34:56' AS TIMESTAMP(2)) AS C4,
       CAST('2050-01-02 12:34:56 +08:00' AS TIMESTAMP(2) WITH TIME ZONE) AS C5,
       CAST('+1,234.50' AS NUMBER(7,2),'S999,990.00') AS C6 --fmt
FROM DUAL;

--VALIDATE_CONVERSION(expr AS type_name [,fmt[,'nlsparam']])
--12.2버전부터 사용 가능
--expr을 type_name에 지정한 데이터 타입으로 변환할 수 있으면 1, 변환할 수 없으면 0을 반환한다. expr이 0이면 1을 반환
/**
  type_name
  NUMBER,DATE,TIMESTAMP,TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH LOCAL TIME ZONE,
  INTERVAL YEAR TO MONTH, INTERVAL DAY TO SECOND
 */
SELECT VALIDATE_CONVERSION('20500131' AS DATE,'YYYYMMDD') AS C1,
       VALIDATE_CONVERSION('20500132' AS DATE, 'YYYYMMDD') AS C2
FROM DUAL;

--변환함수의 신규 기능
--에러가 발생할 경우 반환할 RETURN_VALUE를 지정할 수 있다
--TO_DATE,TO_TIMESTAMP,TO_TIMESTAMP_TZ,TO_DSINTERVAL,TO_YMINTERVAL,CAST함수에 사용 가능
SELECT TO_DATE('205012' DEFAULT '999912' ON CONVERSION ERROR,'YYYYMM') AS C1,
       TO_DATE('205013' DEFAULT '999912' ON CONVERSION ERROR, 'YYYYMM') AS C2
FROM DUAL;

--DECODE(expr,search,result[,search,result]...[,default])
--expr과 search가 일치하면 result, 모두 일치하지 않으면 default 반환
SELECT DECODE(1,1,1,2) AS C1 FROM DUAL;
SELECT DECODE(1,2,1,'A') AS C1 FROM DUAL; -- result와 default의 데이터 타입은 첫번째 result의 데이터 타입과 동일해야한다
--result가 null이면 VARCHAR2 타입으로 평가된다
SELECT DECODE(2,1,NULL,9) AS C1, --VARCHAR2
       DECODE(2,1,TO_NUMBER(NULL),9) AS C2 --NUMBER
FROM DUAL;
--중첩 DECODE의 가독성 높이기
SELECT DECODE(deptno||dname||loc,'30SALESCHICAGO','Y') AS C1 FROM DEPT;
--숫자 값에 결합 연산자를 사용하면 암시적 데이터 변환이 발생하므로 아래 쿼리처럼 CASE 표현식을 사용하는 편이 바람직 하다
SELECT CASE WHEN DEPTNO = 30 AND DNAME = 'SALES' AND LOC = 'CHICAGO' THEN 'Y' END AS C1 FROM DEPT;

--DUMP(expr[,return_fmt[,start_position[,length]]])
--expr의 데이터 타입과 바이트 길이를 return_fmt 형태로 반환한다
/**
  return_fmt
  8 : 8진수
  9 : 10진수
  16 : 16진수
  17 : 문자의 각 바이트
  return_fmt에 1000을 더하면 캐릭터 셋이 포함된 결과를 반환한다
 */
--데이터 타입 코드는 따로 찾아보자
SELECT DUMP('ABC',16) AS C1, DUMP('ABC',1016,2,2) AS C2 FROM DUAL;

--VSIZE(expr)
--expr의 바이트 크기를 반환
SELECT VSIZE(12345) AS C1, VSIZE('ABC') AS C2,
       VSIZE('가나다') AS C3, VSIZE(SYSDATE) AS C4,
       VSIZE(SYSTIMESTAMP) AS C5, VSIZE(TRUNC(SYSTIMESTAMP)) AS C6
FROM DUAL;

--ORA_HASH(expr[,max_bucket[,seed_value]])
--expr의 해시 값을 반환한다.
--max_bucket은 0~4294967295의 범위를 지정할 수 있고 기본값은 4294967295다.
--seed_value도 동일한 범위를 가지며 기본값은 0이다
SELECT ORA_HASH(123) AS C1, ORA_HASH(123,100) AS C2,
       ORA_HASH(123,100,100) AS C3 FROM DUAL;

--STANDARD_HASH(expr[,'method'])
--method에 지정한 해시 알고리즘으로 생성한 expr의 해시 값을 반환한다
/**
  method
  SHA1,SHA256,SHA384,SHA512,MD5
 */
SELECT STANDARD_HASH(123,'SHA256') AS C1 FROM DUAL;