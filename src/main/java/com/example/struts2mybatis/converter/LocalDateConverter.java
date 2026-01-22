package com.example.struts2mybatis.converter;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import org.apache.struts2.util.StrutsTypeConverter;

public class LocalDateConverter extends StrutsTypeConverter {
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public Object convertFromString(@SuppressWarnings("rawtypes") java.util.Map context, String[] values,
            @SuppressWarnings("rawtypes") Class toClass) {
        if (values == null || values.length == 0 || values[0] == null || values[0].isBlank()) {
            return null;
        }
        try {
            return LocalDate.parse(values[0], FORMATTER);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Invalid date format, expected yyyy-MM-dd", ex);
        }
    }

    @Override
    public String convertToString(@SuppressWarnings("rawtypes") java.util.Map context, Object o) {
        if (o instanceof LocalDate localDate) {
            return FORMATTER.format(localDate);
        }
        return "";
    }
}
