package com.example.struts2mybatis.action;

import com.example.struts2mybatis.model.Person;
import com.example.struts2mybatis.persistence.PersonService;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionSupport;
import java.util.List;
import java.util.Map;

public class PersonAction extends ActionSupport {
    private static final long serialVersionUID = 1L;
    private static final String FLASH_MESSAGE_KEY = "flashMessage";

    private final PersonService personService = new PersonService();
    private List<Person> persons;
    private Person person = new Person();
    private Integer id;

    public String list() {
        Map<String, Object> session = ActionContext.getContext().getSession();
        Object message = session.remove(FLASH_MESSAGE_KEY);
        if (message instanceof String text && !text.isBlank()) {
            addActionMessage(text);
        }
        persons = personService.findAll();
        return SUCCESS;
    }

    public String input() {
        if (id != null) {
            Person existing = personService.findById(id);
            if (existing == null) {
                addActionError("Person not found.");
                persons = personService.findAll();
                return ERROR;
            }
            person = existing;
        }
        return INPUT;
    }

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
        if (hasFieldErrors()) {
            return INPUT;
        }
        personService.save(person);
        ActionContext.getContext().getSession().put(FLASH_MESSAGE_KEY, "Person saved successfully.");
        return SUCCESS;
    }

    public String delete() {
        personService.delete(id);
        ActionContext.getContext().getSession().put(FLASH_MESSAGE_KEY, "Person removed successfully.");
        return SUCCESS;
    }

    public List<Person> getPersons() {
        return persons;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Person getPerson() {
        return person;
    }

    public void setPerson(Person person) {
        this.person = person;
    }
}
