
# Flyway

- [Flyway](#flyway)
  - [1. Flyway CLI / Gradle](#1-flyway-cli--gradle)
    - [1.1 Flyway란?](#11-flyway란)
    - [1.2 Play with CLI](#12-play-with-cli)
      - [1.2.1 Install](#121-install)
    - [1.2.2 Verify Installation](#122-verify-installation)
    - [1.3 How to use Flyway](#13-how-to-use-flyway)
      - [1.3.1 Validate](#131-validate)
      - [1.3.2 Migrate](#132-migrate)
      - [1.3.3 Info](#133-info)
      - [1.3.4 Baseline](#134-baseline)
      - [1.3.5 Clean](#135-clean)
    - [1.4 How works Flyway](#14-how-works-flyway)
      - [1.4.1 flyway\_schema\_history Table](#141-flyway_schema_history-table)
        - [flyway\_schema\_history 예시](#flyway_schema_history-예시)
    - [1.5. Play With Gradle](#15-play-with-gradle)
      - [1.5.1 build.gradle](#151-buildgradle)
  - [2. Integrate to CI](#2-integrate-to-ci)

## 1. Flyway CLI / Gradle

이 실습에서는 H2 DB를 실행시키고 그 위에서 직접 명령어를 실행해가며 변화를 파악해보는 과정으로 진행한다.

### 1.1 Flyway란?

Flyway: 데이터베이스 마이그레이션 도구

마이그레이션: 데이터베이스의 스키마(schema)를 한 버전에서 다른 버전으로 업그레이드하거나 변경하는 과정이다.

### 1.2 Play with CLI

#### 1.2.1 Install

```shell
brew install flyway
```

### 1.2.2 Verify Installation

```shell
flyway -v
```

### 1.3 How to use Flyway

- [Flyway CLI and API - Commnads](https://documentation.red-gate.com/fd/commands-184127446.html)
- [Flyway with Gradle](https://documentation.red-gate.com/fd/quickstart-gradle-184127577.html)

#### 1.3.1 Validate

마이그레이션 스크립트와 데이터베이스의 현재 상태를 비교하여 일치하는지 확인하는 과정이다. 불일치를 찾아내서 실수나 오류가 발생하기 전에 미리 알려준다.

특히, 각 파일은 checksum을 통해 고유성을 보장하므로 변경을 감지할 수 있다.

![flyway-validate](../../images/workshop/flyway-validate.png)

```shell
./gradlew flywayValidate
flyway validate
```

#### 1.3.2 Migrate

데이터베이스에 반영하는 과정이다. 순차적으로 실행하며, 이 버전은 메타테이블(flyway_schema_history)에 기록된다.

![flyway-migrate](../../images/workshop/flyway-migrate.png)

```shell
./gradlew flywayMigrate
flyway migrate
```

#### 1.3.3 Info

현재 데이터베이스의 마이그레이션 상태에 대한 상세한 정보를 제공한다. 적용된 것과 적용될 것을 비교하여 나타내며 실패한 마이그레이션은 해당 정보를 표현해준다.

![flyway-info](../../images/workshop/flyway-info.png)

```shell
./gradlew flywayInfo
flyway info
```

#### 1.3.4 Baseline

기존에 있던 데이터베이스에 flyway를 도입할 때 사용한다.

![flyway-baseline](../../images/workshop/flyway-baseline.png)

```shell
./gradlew flywayBaseline
flyway baseline
```

#### 1.3.5 Clean

데이터베이스 내의 모든 스키마, 테이블, 뷰, 저장 프로시저, 함수, 트리거 등을 삭제하여 데이터베이스를 초기 상태로 되돌리는 기능이다. 운영에서 사용하면 안되기 때문에 나름의 안전장치가 포함되어있다.

![flyway-clean](../../images/workshop/flyway-clean.png)

```shell
./gradlew flywayClean
flyway -cleanDisabled="false" clean
```

### 1.4 How works Flyway

1. flyway_schema_history Table을 찾는다.

   ![flyway-works1](../../images/workshop/flyway-works1.png)

2. 없으므로 새로 생성한다. 이제 상태를 추적하는 상태가 되었다.

   ![flyway-works2](../../images/workshop/flyway-works2.png)

3. 마이그레이션을 하기 위해 번호를 기준으로 마이그레이션을 정렬 하고 순서대로 적용한다.

   ![flyway-works3](../../images/workshop/flyway-works3.png)

4. `flyway_schema_history` 테이블에 적용된 마이그레이션을 기록한다.

   ![flyway-works4](../../images/workshop/flyway-works4.png)

5. 또 다른 최신 버전으로 이행을 해 본다. 보류 중인 마이그레이션을 준비한다. 여기에서는 refactoring을 위해 table 2개를 삭제하는 migration을 예로 든다.

   ![flyway-works5](../../images/workshop/flyway-works5.png)

6. 실행하면 마이그레이션을 적용한다.

   ![flyway-works6](../../images/workshop/flyway-works6.png)

7. 결과를 기록한다. 버전이 계속 쌓이는것에 주목할 필요가 있다.

   ![flyway-works7](../../images/workshop/flyway-works7.png)

#### 1.4.1 flyway_schema_history Table

flyway_schema_history 테이블은 Flyway가 데이터베이스 마이그레이션을 관리하는 데 사용하는 중요한 메타데이터 테이블이다.

이 테이블에는 실행된 마이그레이션 스크립트의 이력이 저장되며, Flyway는 이 정보를 사용하여 데이터베이스의 현재 스키마 버전을 파악하고, 어떤 마이그레이션 스크립트가 이미 적용되었는지, 어떤 스크립트가 아직 적용되지 않았는지 등을 결정한다.

**주목해야 할 내용**

- 버전 관리와 순서: version과 installed_rank를 통해 마이그레이션의 순서와 적용된 버전을 쉽게 파악할 수 있다. 이 정보를 사용하여 데이터베이스 스키마의 현재 상태를 확인하고, 필요한 마이그레이션 작업을 계획할 수 있다.
- 무결성 검증: checksum 컬럼을 통해 마이그레이션 파일의 변경 여부를 확인할 수 있다. 이는 마이그레이션 파일이 변경되었을 때 데이터베이스의 무결성에 영향을 줄 수 있기 때문에 중요하다.
- 문제 해결: 마이그레이션 적용 과정에서 문제가 발생했다면, success 컬럼을 확인하여 어떤 마이그레이션이 실패했는지 파악할 수 있다. execution_time과 installed_on 정보를 통해 문제 발생 시점과 소요 시간을 알 수 있으며, 이를 통해 트러블슈팅이 가능하다.

##### flyway_schema_history 예시

| installed_rank | version | description                                  | type | script                                              | checksum    | installed_by | installed_on          | execution_time | success |
|---|---|---|---|---|---|----|---|---|---|
| 1 | 0.1     | init schema | SQL  | V0_1__init schema.sql | -1315154208 | flyway | 58:21.5 | 502 | TRUE    |
| 2 | 0.2 | CREATE batch setting main | SQL | V0_2__CREATE_batch_setting_main.sql | 1604764197  | flyway | 05:16.5 | 80  | TRUE |
| 3 | 0.3 | ALTER XX TABLES ADD COLUMNS BY V | SQL | V0_3__ALTER_XX_TABLES_ADD_COLUMNS_BY_V.sql | -884138263  | flyway | 53:36.2 | 919 | TRUE |
| 4 | 0.4 | ALTER XX TABLES RENAME FINAL UPDATE TIMESTAMP | SQL | V0_4__ALTER_XX_TABLES_RENAME_FINAL_UPDATE_TIMESTAMP.sql | -1577194743 | flyway | 20:53.2 | 243 | TRUE |
| 5 | 0.5 | ALTER table setting batch schedule main | SQL | V0_5__ALTER_table_setting_batch_schedule_main.sql | -1239577890 | flyway | 13:23.3 | 91  | TRUE |

### 1.5. Play With Gradle

Spring Boot과 통합하기 위해 Gradle plugin이 준비되어 있다. 이를 통해 빌드 스크립트에 마이그레이션을 쉽게 추가할 수 있으며, 쉽게 빌드 프로세스에 통합할 수 있다.

#### 1.5.1 build.gradle

```groovy
```


## 2. Integrate to CI

CI에서 Flyway Script의 검증과 예상되는 결과에 대한 리뷰 과정이 필요하다. 이 목적을 달성하기 위해 Flyway에서는 validate 와 info기능을 가지고 있다.

Github Action에서 간단한 리뷰 Gate를 만들어본다.

CI 예시
