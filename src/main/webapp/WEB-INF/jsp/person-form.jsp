<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><s:if test="person.id == null">Create Person</s:if><s:else>Edit Person</s:else></title>
    <style>
        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f8fafc;
            margin: 0;
            padding: 2rem;
        }
        .card {
            max-width: 640px;
            margin: 0 auto;
            background: #fff;
            padding: 2rem;
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.2);
        }
        h1 {
            margin-top: 0;
        }
        .form-grid {
            display: grid;
            gap: 1rem;
        }
        label {
            font-weight: 600;
            display: block;
            margin-bottom: 0.35rem;
        }
        .text-input {
            width: 100%;
            padding: 0.6rem 0.75rem;
            border-radius: 8px;
            border: 1px solid #cbd5f5;
            font-size: 1rem;
        }
        .actions {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            margin-top: 1rem;
        }
        button, a.button-link {
            border: none;
            padding: 0.65rem 1.25rem;
            border-radius: 999px;
            cursor: pointer;
            font-weight: 600;
        }
        button.primary {
            background: #2563eb;
            color: #fff;
        }
        a.button-link {
            text-decoration: none;
            background: #e2e8f0;
            color: #1f2937;
            display: inline-flex;
            align-items: center;
        }
        .error {
            color: #b91c1c;
            font-size: 0.85rem;
            margin-top: 0.35rem;
        }
    </style>
</head>
<body>
<div class="card">
    <h1><s:if test="person.id == null">Create Person</s:if><s:else>Edit Person</s:else></h1>

    <s:form action="person-save" method="post" cssClass="form-grid" theme="simple">
        <s:hidden name="person.id" value="%{person.id}"/>

        <div>
            <label for="name">Name</label>
            <input type="text" id="name" name="person.name" class="text-input" placeholder="Jane" required="required"
                   value='<s:property value="person.name" escapeHtml="true"/>'/>
            <s:fielderror fieldName="person.name" cssClass="error"/>
        </div>

        <div>
            <label for="surname">Surname</label>
            <input type="text" id="surname" name="person.surname" class="text-input" placeholder="Doe" required="required"
                   value='<s:property value="person.surname" escapeHtml="true"/>'/>
            <s:fielderror fieldName="person.surname" cssClass="error"/>
        </div>

        <div>
            <label for="birthDate">Birth Date</label>
            <input type="date" id="birthDate" name="person.birthDate" class="text-input" required="required"
                   value='<s:property value="person.birthDate"/>'/>
            <s:fielderror fieldName="person.birthDate" cssClass="error"/>
        </div>

        <div>
            <label for="age">Calculated Age</label>
                 <input type="number" id="age" name="person.age" class="text-input" readonly
                     value='<s:property value="person.age"/>'/>
        </div>

        <div class="actions">
            <s:url var="cancelUrl" action="persons"/>
            <a class="button-link" href="${cancelUrl}">Cancel</a>
            <button type="submit" class="primary">Save</button>
        </div>
    </s:form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const birthDateInput = document.getElementById('birthDate');
        const ageInput = document.getElementById('age');

        function calculateAge() {
            const birthDate = birthDateInput.value;
            if (!birthDate) {
                ageInput.value = '';
                return;
            }

            const birth = new Date(birthDate);
            const today = new Date();
            let age = today.getFullYear() - birth.getFullYear();
            const monthDiff = today.getMonth() - birth.getMonth();
            
            // Adjust age if birthday hasn't occurred yet this year
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
                age--;
            }

            ageInput.value = age >= 0 ? age : '';
        }

        // Calculate on page load if birth date exists
        calculateAge();

        // Recalculate whenever birth date changes
        birthDateInput.addEventListener('change', calculateAge);
        birthDateInput.addEventListener('input', calculateAge);
    });
</script>
</body>
</html>
