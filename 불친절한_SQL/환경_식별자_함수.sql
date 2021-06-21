-- USER
-- 로그인한 사용자의 이름을 반환
SELECT USER AS C1 FROM DUAL;

-- UID
-- 로그인한 사용자의 ID를 반환한다
SELECT UID AS C1 FROM DUAL;

-- _USERS 뷰에서 동일한 결과를 조회할 수 있다
SELECT USERNAME, USER_ID FROM USER_USERS;

--SYS_GUID()
-- 전역 고유 식별자를 16바이트 RAW값으로 반환한다.
SELECT SYS_GUID() AS C1 FROM DUAL;

-- SYS_CONTEXT('namespace','parameter'[,length])
-- namespace에 속한 parameter 값을 반환한다.
/**
  parameter
  -server
  SERVER_HOST : 인스턴스가 실행되고 있는 서버의 호스트 명
  IP_ADDRESS : 클라이언트가 접속되어 있는 기기의 IP주소
  -db,instance
  DB_UNIQUE_NAME : 데이터베이스 명(DB_UNIZUE_NAME 초기화 파라미터)
  DB_NAME : 데이터베이스 명 (DB_NAME 초기화 파라미터)
  DB_DOMAIN : 데이터베이스 도메인(DB_DOMAIN 초기화 파라미터)
  INSTANCE : 인스턴스 번호
  INSTANCE_NAME : 인스턴스 이름
  -client
  HOST : 클라이언트 호스트 명
  OS_USER : 클라이언트 OS 사용자
  TERMINAL : 클라이언트 OS 식별자
  CLIENT_PROGRAM_NAME : 클라이언트 프로그램
  -session
  SID : 세션 ID
  SESSION_USER : 세션 사용자(로그인 사용자)
  CURRENT_USER : 현재 권한이 활성화된 사용자
  CURRENT_SCHEMA : 현재 권한이 활성화된 스키마
  -language, NLS
  LANG : 언어 약자
  LANGUAGE : 언어와 지역, 데이터베이스 캐릭터 셋
  NLS_CALENDAR : 달력
  NLS_CURRENCY : 통화
  NLS_DATE_FORMAT : 날짜 형식
  NLS_DATE_LANGUAGE : 날짜 언어
  NLS_SORT : 언어 정렬 기준
  NLS_TERRITORY : 지역
  -service, program, client
  SERVICE_NAME : 서비스 명
  MODULE : 프로그램 모듈
  ACTION : 프로그램 모듈의 액션
  CLIENT_INFO : 클라이언트 정보
  CLIENT_IDENTIFIER : 클라이언트 식별자
 */
select sys_context('userenv','server_host') as c1,
       sys_context('userenv','ip_address') as c2
from dual;

select sys_context('userenv','db_unique_name') as c1,
       sys_context('userenv','db_name') as c2,
       sys_context('userenv','db_domain') as c3,
       sys_context('userenv','instance') as c4,
       sys_context('userenv','instance_name') as c5
from dual;

select sys_context('userenv','host') as c1,
       sys_context('userenv','os_user') as c2,
       sys_context('userenv','terminal') as c3,
       sys_context('userenv','client_program_name') as c4
from dual;

select sys_context('userenv','sid') as c1,
       sys_context('userenv','session_user') as c2,
       sys_context('userenv','current_user') as c3,
       sys_context('userenv','current_schema') as c4
from dual;

select sys_context('userenv','lang') as c1,
       sys_context('userenv','language') as c2,
       sys_context('userenv','nls_calendar') as c3,
       sys_context('userenv','nls_currency') as c4,
       sys_context('userenv','nls_date_format') as c5,
       sys_context('userenv','nls_date_language') as c6,
       sys_context('userenv','nls_sort') as c7,
       sys_context('userenv','nls_territory') as c8
from dual;

select sys_context('userenv','service_name') as c1,
       sys_context('userenv','module') as c2,
       sys_context('userenv','action') as c3,
       sys_context('userenv','client_info') as c4,
       sys_context('userenv','client_identifier') as c5
from dual;

-- V$SQLFN_ 뷰
-- 오라클 데이터베이스는 내장 SQL 함수와 관련된 동적 성능 뷰를 제공한다

-- V$SQLFN_METADATA 뷰에서 SQL 함수에 대한 정보를 조회할 수 있다
select func_id, name, minargs, maxargs, datatype, version from V$SQLFN_METADATA;

-- V$SQLFN_ARG_METADATA 뷰에서 SQL 함수의 인수에 대한 정보를 조회할 수 있다
select func_id, argnum, datatype from v$sqlfn_arg_metadata;