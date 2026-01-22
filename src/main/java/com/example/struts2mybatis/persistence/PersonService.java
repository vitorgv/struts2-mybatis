package com.example.struts2mybatis.persistence;

import com.example.struts2mybatis.model.Person;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.Objects;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;

public class PersonService {
    private final SqlSessionFactory sqlSessionFactory;

    public PersonService() {
        this.sqlSessionFactory = MyBatisUtil.getSqlSessionFactory();
    }

    public List<Person> findAll() {
        try (SqlSession session = sqlSessionFactory.openSession()) {
            return session.getMapper(PersonMapper.class).findAll();
        }
    }

    public Person findById(Integer id) {
        if (id == null) {
            return null;
        }
        try (SqlSession session = sqlSessionFactory.openSession()) {
            return session.getMapper(PersonMapper.class).findById(id);
        }
    }

    public void save(Person person) {
        Objects.requireNonNull(person, "person must not be null");
        Integer id = person.getId();
        enrichDerivedFields(person);
        try (SqlSession session = sqlSessionFactory.openSession(true)) {
            PersonMapper mapper = session.getMapper(PersonMapper.class);
            if (id == null) {
                LocalDateTime now = LocalDateTime.now();
                person.setInsertTimestamp(now);
                person.setUpdateTimestamp(now);
                mapper.insertPerson(person);
            } else {
                person.setUpdateTimestamp(LocalDateTime.now());
                mapper.updatePerson(person);
            }
        }
    }

    public void delete(Integer id) {
        if (id == null) {
            return;
        }
        try (SqlSession session = sqlSessionFactory.openSession(true)) {
            session.getMapper(PersonMapper.class).deletePerson(id);
        }
    }

    private void enrichDerivedFields(Person person) {
        LocalDate birthDate = person.getBirthDate();
        if (birthDate != null) {
            person.setAge(Period.between(birthDate, LocalDate.now()).getYears());
        }
    }
}
