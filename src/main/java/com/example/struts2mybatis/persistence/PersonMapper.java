package com.example.struts2mybatis.persistence;

import com.example.struts2mybatis.model.Person;
import java.util.List;

public interface PersonMapper {
    List<Person> findAll();

    Person findById(Integer id);

    int insertPerson(Person person);

    int updatePerson(Person person);

    int deletePerson(Integer id);
}
