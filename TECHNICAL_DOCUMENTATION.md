# Struts2 and MyBatis Technical Reference

## Table of Contents
1. [Apache Struts2](#apache-struts2)
2. [MyBatis](#mybatis)
3. [Integration Patterns](#integration-patterns)
4. [Project Architecture](#project-architecture)
5. [Configuration Details](#configuration-details)
6. [Best Practices](#best-practices)
7. [Common Patterns](#common-patterns)

---

## Apache Struts2

### Overview

Apache Struts2 is an enterprise-grade MVC web application framework built on the WebWork framework and extending the Struts 1.x architecture. It uses a Front Controller pattern implemented through filters rather than servlets.

**Version Used**: 6.3.0 (as of this project)

### Core Architecture

#### Request Processing Flow

```
HTTP Request
    ↓
StrutsPrepareAndExecuteFilter (/*)
    ↓
ActionMapper (determines action)
    ↓
ActionProxy (invocation wrapper)
    ↓
ActionInvocation (interceptor chain + action execution)
    ↓
Interceptors (stack execution)
    ↓
Action.execute() or specific method
    ↓
Result (view rendering)
    ↓
HTTP Response
```

#### Key Components

**1. Actions**
Actions are POJOs that handle requests. Unlike Struts 1, they don't need to extend any base class.

```java
public class PersonAction extends ActionSupport {
    private Person person = new Person();
    private Integer id;
    
    // Action method
    public String save() {
        personService.save(person);
        return SUCCESS;
    }
    
    // Getters/setters for parameters
    public Person getPerson() { return person; }
    public void setPerson(Person person) { this.person = person; }
}
```

**Key Points**:
- Thread-safe by default (new instance per request)
- Parameters bound via OGNL (Object-Graph Navigation Language)
- Supports method-specific validation
- Can return multiple result types

**2. Interceptors**

Struts2 uses interceptor stacks for cross-cutting concerns:

```xml
<interceptor-stack name="defaultStack">
    <interceptor-ref name="exception"/>
    <interceptor-ref name="alias"/>
    <interceptor-ref name="servletConfig"/>
    <interceptor-ref name="i18n"/>
    <interceptor-ref name="prepare"/>
    <interceptor-ref name="chain"/>
    <interceptor-ref name="modelDriven"/>
    <interceptor-ref name="fileUpload"/>
    <interceptor-ref name="checkbox"/>
    <interceptor-ref name="staticParams"/>
    <interceptor-ref name="params"/>
    <interceptor-ref name="conversionError"/>
    <interceptor-ref name="validation"/>
    <interceptor-ref name="workflow"/>
</interceptor-stack>
```

**Common Interceptors**:
- `params`: Binds request parameters to action properties
- `validation`: Executes validation logic
- `workflow`: Handles validation errors
- `exception`: Catches and maps exceptions
- `modelDriven`: Pushes model object onto value stack

**3. Value Stack and OGNL**

The Value Stack is a stack of objects (action, model, etc.) accessible via OGNL:

```jsp
<%-- Access action property --%>
<s:property value="person.name"/>

<%-- Navigate object graph --%>
<s:property value="person.birthDate.year"/>

<%-- Call methods --%>
<s:if test="person.age > 18">
    <s:property value="person.getName().toUpperCase()"/>
</s:if>
```

**Value Stack Structure**:
```
[Top]
- Action context
- Action instance
- Model object (if ModelDriven)
- Request parameters
[Bottom]
```

**4. Results**

Results determine response generation:

```xml
<action name="person-save" class="PersonAction" method="save">
    <!-- Redirect to another action -->
    <result name="success" type="redirectAction">persons</result>
    
    <!-- Forward to JSP -->
    <result name="input">/WEB-INF/jsp/person-form.jsp</result>
    
    <!-- JSON response -->
    <result name="json" type="json"/>
</action>
```

**Result Types**:
- `dispatcher` (default): Forward to JSP/HTML
- `redirectAction`: Redirect to another action (PRG pattern)
- `redirect`: HTTP redirect to URL
- `chain`: Chain to another action (same request)
- `stream`: Stream binary data
- `json`: Serialize to JSON

### Configuration

#### struts.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE struts PUBLIC 
    "-//Apache Software Foundation//DTD Struts Configuration 6.0//EN" 
    "https://struts.apache.org/dtds/struts-6.0.dtd">

<struts>
    <!-- Development mode for debugging -->
    <constant name="struts.devMode" value="true"/>
    
    <!-- Package definition -->
    <package name="default" extends="struts-default" namespace="/">
        
        <!-- Empty action for root mapping -->
        <action name="">
            <result type="redirectAction">persons</result>
        </action>
        
        <!-- CRUD actions -->
        <action name="persons" 
                class="com.example.struts2mybatis.action.PersonAction" 
                method="list">
            <result>/WEB-INF/jsp/person-list.jsp</result>
        </action>
        
        <action name="person-input" 
                class="com.example.struts2mybatis.action.PersonAction" 
                method="input">
            <result name="input">/WEB-INF/jsp/person-form.jsp</result>
            <result name="error">/WEB-INF/jsp/person-list.jsp</result>
        </action>
        
        <action name="person-save" 
                class="com.example.struts2mybatis.action.PersonAction" 
                method="save">
            <result name="success" type="redirectAction">persons</result>
            <result name="input">/WEB-INF/jsp/person-form.jsp</result>
        </action>
        
        <action name="person-delete" 
                class="com.example.struts2mybatis.action.PersonAction" 
                method="delete">
            <result name="success" type="redirectAction">persons</result>
        </action>
    </package>
</struts>
```

#### web.xml

```xml
<filter>
    <filter-name>struts2</filter-name>
    <filter-class>
        org.apache.struts2.dispatcher.filter.StrutsPrepareAndExecuteFilter
    </filter-class>
</filter>

<filter-mapping>
    <filter-name>struts2</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

### Validation

**Method-based validation** using `validate<MethodName>()`:

```java
public class PersonAction extends ActionSupport {
    
    public void validateSave() {
        if (person.getName() == null || person.getName().isBlank()) {
            addFieldError("person.name", "Name is required");
        }
        if (person.getSurname() == null || person.getSurname().isBlank()) {
            addFieldError("person.surname", "Surname is required");
        }
        if (person.getBirthDate() == null) {
            addFieldError("person.birthDate", "Birth date is required");
        }
    }
    
    public String save() {
        // This executes only if validateSave() passed
        if (hasFieldErrors()) {
            return INPUT;
        }
        personService.save(person);
        return SUCCESS;
    }
}
```

**XML-based validation** (PersonAction-person-save-validation.xml):

```xml
<!DOCTYPE validators PUBLIC 
    "-//Apache Struts//XWork Validator 1.0.3//EN"
    "http://struts.apache.org/dtds/xwork-validator-1.0.3.dtd">
    
<validators>
    <field name="person.name">
        <field-validator type="requiredstring">
            <message>Name is required</message>
        </field-validator>
    </field>
    
    <field name="person.birthDate">
        <field-validator type="required">
            <message>Birth date is required</message>
        </field-validator>
    </field>
</validators>
```

### Tag Library

Struts2 provides comprehensive JSP tags:

```jsp
<%@ taglib prefix="s" uri="/struts-tags" %>

<!-- Form tags -->
<s:form action="person-save" method="post" theme="simple">
    <s:hidden name="person.id"/>
    <s:textfield name="person.name" label="Name"/>
    <s:textfield name="person.surname" label="Surname"/>
    <s:textfield name="person.birthDate" type="date"/>
    <s:submit value="Save"/>
</s:form>

<!-- URL generation -->
<s:url var="editUrl" action="person-input">
    <s:param name="id" value="%{id}"/>
</s:url>
<a href="${editUrl}">Edit</a>

<!-- Iteration -->
<s:iterator value="persons">
    <s:property value="name"/> - <s:property value="age"/>
</s:iterator>

<!-- Conditionals -->
<s:if test="persons.size() > 0">
    <table>...</table>
</s:if>
<s:else>
    <p>No data</p>
</s:else>

<!-- Messages -->
<s:actionmessage/>
<s:actionerror/>
<s:fielderror fieldName="person.name"/>
```

---

## MyBatis

### Overview

MyBatis is a SQL mapping framework that eliminates much of the JDBC boilerplate code while providing fine-grained control over SQL. Unlike full ORMs like Hibernate, MyBatis takes a SQL-first approach.

**Version Used**: 3.5.15

### Core Concepts

#### 1. SqlSessionFactory

The entry point for MyBatis, created once per application:

```java
public class MyBatisUtil {
    private static SqlSessionFactory sqlSessionFactory;
    
    static {
        try {
            String resource = "mybatis-config.xml";
            InputStream inputStream = Resources.getResourceAsStream(resource);
            sqlSessionFactory = new SqlSessionFactoryBuilder()
                .build(inputStream);
        } catch (IOException e) {
            throw new RuntimeException("Failed to initialize MyBatis", e);
        }
    }
    
    public static SqlSession getSqlSession() {
        return sqlSessionFactory.openSession();
    }
}
```

#### 2. SqlSession

Thread-unsafe, short-lived object for executing mapped statements:

```java
public class PersonService {
    
    public List<Person> findAll() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            return mapper.findAll();
        }
    }
    
    public void save(Person person) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            if (person.getId() == null) {
                mapper.insert(person);
            } else {
                mapper.update(person);
            }
            session.commit();
        }
    }
}
```

**Important**: Always use try-with-resources or manual close to prevent connection leaks.

#### 3. Mappers

Interface-based mappers define database operations:

```java
public interface PersonMapper {
    List<Person> findAll();
    Person findById(Integer id);
    void insert(Person person);
    void update(Person person);
    void delete(Integer id);
}
```

### Configuration

#### mybatis-config.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration 
    PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-config.dtd">

<configuration>
    <!-- Settings -->
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <setting name="useGeneratedKeys" value="true"/>
        <setting name="cacheEnabled" value="true"/>
        <setting name="logImpl" value="SLF4J"/>
    </settings>
    
    <!-- Type aliases -->
    <typeAliases>
        <package name="com.example.struts2mybatis.model"/>
    </typeAliases>
    
    <!-- Type handlers for Java 8+ date/time -->
    <typeHandlers>
        <package name="org.apache.ibatis.type"/>
    </typeHandlers>
    
    <!-- Environment (can have multiple) -->
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="org.h2.Driver"/>
                <property name="url" 
                    value="jdbc:h2:mem:persondb;INIT=RUNSCRIPT FROM 'classpath:db/schema.sql'"/>
                <property name="username" value="sa"/>
                <property name="password" value=""/>
                <property name="poolMaximumActiveConnections" value="10"/>
                <property name="poolMaximumIdleConnections" value="5"/>
            </dataSource>
        </environment>
    </environments>
    
    <!-- Mapper registration -->
    <mappers>
        <mapper resource="mappers/PersonMapper.xml"/>
    </mappers>
</configuration>
```

#### Mapper XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper 
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.example.struts2mybatis.mapper.PersonMapper">

    <!-- Result map for complex mappings -->
    <resultMap id="PersonResultMap" type="Person">
        <id property="id" column="id"/>
        <result property="name" column="name"/>
        <result property="surname" column="surname"/>
        <result property="birthDate" column="birth_date"/>
        <result property="age" column="age"/>
        <result property="insertTimestamp" column="insert_timestamp"/>
        <result property="updateTimestamp" column="update_timestamp"/>
    </resultMap>
    
    <!-- SELECT queries -->
    <select id="findAll" resultMap="PersonResultMap">
        SELECT id, name, surname, birth_date, age, 
               insert_timestamp, update_timestamp
        FROM person
        ORDER BY id
    </select>
    
    <select id="findById" parameterType="int" resultMap="PersonResultMap">
        SELECT id, name, surname, birth_date, age,
               insert_timestamp, update_timestamp
        FROM person
        WHERE id = #{id}
    </select>
    
    <!-- INSERT with auto-generated keys -->
    <insert id="insert" parameterType="Person" 
            useGeneratedKeys="true" keyProperty="id">
        INSERT INTO person (name, surname, birth_date, age)
        VALUES (#{name}, #{surname}, #{birthDate}, #{age})
    </insert>
    
    <!-- UPDATE -->
    <update id="update" parameterType="Person">
        UPDATE person
        SET name = #{name},
            surname = #{surname},
            birth_date = #{birthDate},
            age = #{age},
            update_timestamp = CURRENT_TIMESTAMP
        WHERE id = #{id}
    </update>
    
    <!-- DELETE -->
    <delete id="delete" parameterType="int">
        DELETE FROM person WHERE id = #{id}
    </delete>
    
    <!-- Dynamic SQL example -->
    <select id="search" resultMap="PersonResultMap">
        SELECT * FROM person
        <where>
            <if test="name != null">
                AND name LIKE CONCAT('%', #{name}, '%')
            </if>
            <if test="minAge != null">
                AND age >= #{minAge}
            </if>
            <if test="maxAge != null">
                AND age &lt;= #{maxAge}
            </if>
        </where>
        ORDER BY id
    </select>
</mapper>
```

### Advanced Features

#### Dynamic SQL

```xml
<!-- Choose/When/Otherwise (switch-case) -->
<select id="findByCondition" resultType="Person">
    SELECT * FROM person
    WHERE 1=1
    <choose>
        <when test="id != null">
            AND id = #{id}
        </when>
        <when test="name != null">
            AND name = #{name}
        </when>
        <otherwise>
            AND 1=1
        </otherwise>
    </choose>
</select>

<!-- For-each (IN clause) -->
<select id="findByIds" resultType="Person">
    SELECT * FROM person
    WHERE id IN
    <foreach item="id" collection="list" open="(" separator="," close=")">
        #{id}
    </foreach>
</select>

<!-- Set (for UPDATE) -->
<update id="updateSelective" parameterType="Person">
    UPDATE person
    <set>
        <if test="name != null">name = #{name},</if>
        <if test="surname != null">surname = #{surname},</if>
        <if test="birthDate != null">birth_date = #{birthDate},</if>
    </set>
    WHERE id = #{id}
</update>
```

#### Type Handlers

Custom type handlers for special conversions:

```java
@MappedTypes(LocalDate.class)
@MappedJdbcTypes(JdbcType.DATE)
public class LocalDateTypeHandler extends BaseTypeHandler<LocalDate> {
    
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, 
                                    LocalDate parameter, JdbcType jdbcType) 
                                    throws SQLException {
        ps.setDate(i, Date.valueOf(parameter));
    }
    
    @Override
    public LocalDate getNullableResult(ResultSet rs, String columnName) 
                                      throws SQLException {
        Date date = rs.getDate(columnName);
        return date != null ? date.toLocalDate() : null;
    }
    
    @Override
    public LocalDate getNullableResult(ResultSet rs, int columnIndex) 
                                      throws SQLException {
        Date date = rs.getDate(columnIndex);
        return date != null ? date.toLocalDate() : null;
    }
    
    @Override
    public LocalDate getNullableResult(CallableStatement cs, int columnIndex) 
                                      throws SQLException {
        Date date = cs.getDate(columnIndex);
        return date != null ? date.toLocalDate() : null;
    }
}
```

#### Caching

**First-level cache** (session-scoped, enabled by default):
- Automatically caches objects within a single SqlSession
- Cleared on commit/rollback or explicit clearCache()

**Second-level cache** (mapper-scoped, opt-in):

```xml
<mapper namespace="com.example.mapper.PersonMapper">
    <cache 
        eviction="LRU"
        flushInterval="60000"
        size="512"
        readOnly="true"/>
    
    <select id="findAll" resultType="Person" useCache="true">
        SELECT * FROM person
    </select>
</mapper>
```

---

## Integration Patterns

### Layered Architecture

```
┌─────────────────────────────────────┐
│   Presentation Layer (JSP + Tags)   │
├─────────────────────────────────────┤
│   Controller Layer (Struts Actions) │
├─────────────────────────────────────┤
│   Service Layer (Business Logic)    │
├─────────────────────────────────────┤
│   Persistence Layer (MyBatis)       │
├─────────────────────────────────────┤
│   Database (H2/MySQL/PostgreSQL)    │
└─────────────────────────────────────┘
```

### Dependency Flow

```java
// Action -> Service -> Mapper pattern

// 1. Action (Controller)
public class PersonAction extends ActionSupport {
    private final PersonService personService = new PersonService();
    private Person person = new Person();
    
    public String save() {
        personService.save(person);
        addActionMessage("Person saved successfully");
        return SUCCESS;
    }
}

// 2. Service (Business Logic)
public class PersonService {
    
    public void save(Person person) {
        calculateAge(person);
        
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            
            if (person.getId() == null) {
                mapper.insert(person);
            } else {
                mapper.update(person);
            }
            
            session.commit();
        }
    }
    
    private void calculateAge(Person person) {
        if (person.getBirthDate() != null) {
            int age = Period.between(person.getBirthDate(), 
                                    LocalDate.now()).getYears();
            person.setAge(age);
        }
    }
}

// 3. Mapper (Data Access)
public interface PersonMapper {
    void insert(Person person);
    void update(Person person);
}
```

### Flash Messages Pattern

```java
// Post-Redirect-Get (PRG) pattern for flash messages

public class PersonAction extends ActionSupport {
    private static final String FLASH_MESSAGE_KEY = "flashMessage";
    
    // After save, store message in session
    public String save() {
        personService.save(person);
        ActionContext.getContext().getSession()
            .put(FLASH_MESSAGE_KEY, "Person saved successfully.");
        return SUCCESS; // redirects via struts.xml
    }
    
    // On list page, retrieve and clear message
    public String list() {
        Map<String, Object> session = ActionContext.getContext().getSession();
        Object message = session.remove(FLASH_MESSAGE_KEY);
        if (message instanceof String text && !text.isBlank()) {
            addActionMessage(text);
        }
        persons = personService.findAll();
        return SUCCESS;
    }
}
```

---

## Project Architecture

### Directory Structure

```
struts2/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/struts2mybatis/
│       │       ├── action/
│       │       │   └── PersonAction.java
│       │       ├── converter/
│       │       │   ├── LocalDateConverter.java
│       │       │   └── LocalDateTimeConverter.java
│       │       ├── mapper/
│       │       │   └── PersonMapper.java
│       │       ├── model/
│       │       │   └── Person.java
│       │       ├── persistence/
│       │       │   ├── MyBatisUtil.java
│       │       │   └── PersonService.java
│       │       └── util/
│       ├── resources/
│       │   ├── db/
│       │   │   └── schema.sql
│       │   ├── mappers/
│       │   │   └── PersonMapper.xml
│       │   ├── mybatis-config.xml
│       │   └── struts.xml
│       └── webapp/
│           ├── WEB-INF/
│           │   ├── jsp/
│           │   │   ├── person-form.jsp
│           │   │   └── person-list.jsp
│           │   └── web.xml
│           └── index.jsp
├── pom.xml
└── README.md
```

### Component Responsibilities

**Actions**: Handle HTTP requests, coordinate service calls, prepare responses
**Services**: Contain business logic, transaction boundaries
**Mappers**: Define data access interface
**Models**: Represent domain entities (POJOs)
**Converters**: Handle type conversion for Struts parameters
**Utils**: Provide cross-cutting utilities

---

## Configuration Details

### Maven Dependencies

```xml
<dependencies>
    <!-- Struts2 Core -->
    <dependency>
        <groupId>org.apache.struts</groupId>
        <artifactId>struts2-core</artifactId>
        <version>6.3.0</version>
    </dependency>
    
    <!-- MyBatis -->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.5.15</version>
    </dependency>
    
    <!-- MyBatis JSR310 (Java 8 Date/Time) -->
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis-typehandlers-jsr310</artifactId>
        <version>1.0.2</version>
    </dependency>
    
    <!-- H2 Database -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <version>2.2.224</version>
    </dependency>
    
    <!-- Servlet API -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

### Type Converters

Struts2 requires custom converters for Java 8+ date types:

```java
// xwork-conversion.properties
java.time.LocalDate=com.example.struts2mybatis.converter.LocalDateConverter
java.time.LocalDateTime=com.example.struts2mybatis.converter.LocalDateTimeConverter

// LocalDateConverter.java
public class LocalDateConverter extends StrutsTypeConverter {
    
    @Override
    public Object convertFromString(Map context, String[] values, Class toClass) {
        if (values != null && values.length > 0 && values[0] != null) {
            try {
                return LocalDate.parse(values[0]);
            } catch (DateTimeParseException e) {
                return null;
            }
        }
        return null;
    }
    
    @Override
    public String convertToString(Map context, Object o) {
        if (o instanceof LocalDate) {
            return o.toString();
        }
        return "";
    }
}
```

---

## Best Practices

### Struts2 Best Practices

1. **Use ActionSupport** for convenience methods and i18n support
2. **Implement validation methods** instead of relying solely on XML
3. **Use redirectAction** result type for POST operations (PRG pattern)
4. **Leverage interceptors** for cross-cutting concerns
5. **Keep actions thin** - business logic belongs in services
6. **Use theme="simple"** for custom form layouts
7. **Explicitly set result names** instead of relying on defaults
8. **Disable devMode** in production
9. **Use constant names** in struts.xml for configuration
10. **Profile interceptor stack** for performance tuning

### MyBatis Best Practices

1. **Always close SqlSession** using try-with-resources
2. **Use connection pooling** (POOLED datasource type)
3. **Enable camelCase mapping** (mapUnderscoreToCamelCase)
4. **Leverage result maps** for complex object graphs
5. **Use dynamic SQL** to avoid multiple mapper methods
6. **Commit explicitly** for writes (auto-commit is false)
7. **Batch operations** for bulk inserts/updates
8. **Use pagination** for large result sets
9. **Enable logging** during development
10. **Configure appropriate cache** strategies

### Security Best Practices

1. **Validate all inputs** server-side
2. **Use parameterized queries** (MyBatis does this by default)
3. **Escape output** in JSPs
4. **Implement CSRF protection** via tokens
5. **Keep Struts2 updated** for security patches
6. **Disable dynamic method invocation**
7. **Use strict method access** (excludeMethods/includeMethods)
8. **Validate file uploads** strictly
9. **Set proper error pages** in production
10. **Use HTTPS** for sensitive operations

---

## Common Patterns

### CRUD Operations

```java
// Service layer with complete CRUD
public class PersonService {
    
    public List<Person> findAll() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            return session.getMapper(PersonMapper.class).findAll();
        }
    }
    
    public Person findById(Integer id) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            return session.getMapper(PersonMapper.class).findById(id);
        }
    }
    
    public void save(Person person) {
        calculateAge(person);
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            if (person.getId() == null) {
                mapper.insert(person);
            } else {
                mapper.update(person);
            }
            session.commit();
        }
    }
    
    public void delete(Integer id) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            session.getMapper(PersonMapper.class).delete(id);
            session.commit();
        }
    }
}
```

### Pagination

```xml
<!-- MyBatis mapper with pagination -->
<select id="findPage" resultMap="PersonResultMap">
    SELECT * FROM person
    ORDER BY id
    LIMIT #{pageSize} OFFSET #{offset}
</select>

<select id="count" resultType="long">
    SELECT COUNT(*) FROM person
</select>
```

```java
// Service with pagination support
public class PersonService {
    
    public Page<Person> findPage(int pageNumber, int pageSize) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            
            int offset = (pageNumber - 1) * pageSize;
            List<Person> persons = mapper.findPage(offset, pageSize);
            long total = mapper.count();
            
            return new Page<>(persons, pageNumber, pageSize, total);
        }
    }
}
```

### Transaction Management

```java
// Service method with transaction
public void transferData(Integer fromId, Integer toId) {
    SqlSession session = MyBatisUtil.getSqlSession();
    try {
        PersonMapper mapper = session.getMapper(PersonMapper.class);
        
        // Multiple operations in one transaction
        Person fromPerson = mapper.findById(fromId);
        Person toPerson = mapper.findById(toId);
        
        // Business logic
        fromPerson.setSomeField(value);
        toPerson.setSomeField(value);
        
        mapper.update(fromPerson);
        mapper.update(toPerson);
        
        session.commit(); // Commit all or nothing
    } catch (Exception e) {
        session.rollback(); // Rollback on error
        throw new RuntimeException("Transfer failed", e);
    } finally {
        session.close();
    }
}
```

---

## Performance Optimization

### Struts2 Performance

- Use `preparable` interceptor for efficient data loading
- Implement `ModelDriven` for cleaner parameter binding
- Configure static content caching
- Minimize interceptor stack where possible
- Use `chain` result sparingly (prefer redirects)

### MyBatis Performance

- Enable second-level cache for read-heavy operations
- Use `fetchType="lazy"` for associations
- Batch INSERT/UPDATE operations
- Use `select *` sparingly - specify columns
- Configure appropriate pool sizes
- Enable statement caching

---

## Testing

### Unit Testing Actions

```java
@Test
public void testSaveAction() {
    PersonAction action = new PersonAction();
    Person person = new Person();
    person.setName("Test");
    person.setSurname("User");
    person.setBirthDate(LocalDate.of(1990, 1, 1));
    
    action.setPerson(person);
    String result = action.save();
    
    assertEquals(Action.SUCCESS, result);
    assertTrue(action.getActionMessages().size() > 0);
}
```

### Integration Testing MyBatis

```java
@Test
public void testPersonMapper() {
    try (SqlSession session = MyBatisUtil.getSqlSession()) {
        PersonMapper mapper = session.getMapper(PersonMapper.class);
        
        Person person = new Person();
        person.setName("Test");
        person.setSurname("User");
        person.setBirthDate(LocalDate.of(1990, 1, 1));
        
        mapper.insert(person);
        session.commit();
        
        assertNotNull(person.getId());
        
        Person found = mapper.findById(person.getId());
        assertEquals("Test", found.getName());
    }
}
```

---

## Troubleshooting

### Common Issues

**Struts2**:
- **Null parameters**: Check OGNL expression and getter/setter names
- **404 on actions**: Verify namespace and action name in struts.xml
- **Validation not working**: Check method naming (validate<Method>)
- **Session attributes**: Use ActionContext.getContext().getSession()

**MyBatis**:
- **Connection leaks**: Always close SqlSession
- **Mapper not found**: Check mapper registration in config
- **Type handler issues**: Verify JDBC type matches Java type
- **Commit not working**: Explicit commit() required for DML

---

## References

- [Struts2 Documentation](https://struts.apache.org/core-developers/)
- [MyBatis Documentation](https://mybatis.org/mybatis-3/)
- [Struts2 Security Bulletins](https://struts.apache.org/security/)
- [MyBatis GitHub](https://github.com/mybatis/mybatis-3)
