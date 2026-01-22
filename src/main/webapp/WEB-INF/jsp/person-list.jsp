<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Person Registry</title>
    <style>
        :root {
            font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
            color: #1a1a1a;
            background-color: #f3f4f6;
        }
        body {
            margin: 0;
            padding: 2rem;
            background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
        }
        .container {
            max-width: 960px;
            margin: 0 auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.2);
            padding: 2rem 2.5rem 3rem;
        }
        h1 {
            margin-top: 0;
            font-size: 2rem;
            letter-spacing: -0.02em;
        }
        .actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        a.button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.6rem 1rem;
            background: #2563eb;
            color: #fff;
            border-radius: 999px;
            text-decoration: none;
            font-weight: 600;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
            font-size: 0.95rem;
        }
        thead {
            background: #0f172a;
            color: #fff;
        }
        th, td {
            padding: 0.75rem 0.5rem;
            text-align: left;
        }
        th.sortable {
            cursor: pointer;
            user-select: none;
            position: relative;
            padding-right: 1.5rem;
        }
        th.sortable:hover {
            background: #1e293b;
        }
        th.sortable::after {
            content: '⇅';
            position: absolute;
            right: 0.5rem;
            opacity: 0.5;
        }
        th.sortable.asc::after {
            content: '↑';
            opacity: 1;
        }
        th.sortable.desc::after {
            content: '↓';
            opacity: 1;
        }
        tbody tr:nth-child(even) {
            background: #f9fafb;
        }
        .table-actions {
            display: flex;
            gap: 0.5rem;
        }
        .table-actions form {
            margin: 0;
        }
        button.delete {
            border: none;
            background: #dc2626;
            color: #fff;
            padding: 0.35rem 0.65rem;
            border-radius: 6px;
            cursor: pointer;
        }
        a.edit-link {
            color: #2563eb;
            text-decoration: none;
            font-weight: 600;
        }
        .messages {
            margin-bottom: 1rem;
        }
        .messages .success {
            background: #d1fae5;
            color: #065f46;
            padding: 0.75rem 1rem;
            border-radius: 8px;
            margin-bottom: 0.5rem;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="actions">
        <h1>Person Registry</h1>
        <s:url var="createUrl" action="person-input"/>
        <a class="button" href="${createUrl}">Add Person</a>
    </div>

    <div class="messages">
        <s:actionmessage cssClass="success"/>
    </div>

    <table>
        <thead>
        <tr>
            <th class="sortable" data-column="id">ID</th>
            <th class="sortable" data-column="name">Name</th>
            <th class="sortable" data-column="surname">Surname</th>
            <th class="sortable" data-column="birthDate">Birth Date</th>
            <th class="sortable" data-column="age">Age</th>
            <th class="sortable" data-column="created">Created</th>
            <th class="sortable" data-column="updated">Updated</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <s:if test="persons.size() == 0">
            <tr>
                <td colspan="8">No persons available.</td>
            </tr>
        </s:if>
        <s:iterator value="persons">
            <tr>
                <td><s:property value="id"/></td>
                <td><s:property value="name"/></td>
                <td><s:property value="surname"/></td>
                <td><s:property value="birthDate"/></td>
                <td><s:property value="age"/></td>
                <td><s:property value="insertTimestamp"/></td>
                <td><s:property value="updateTimestamp"/></td>
                <td>
                    <div class="table-actions">
                        <s:url var="editUrl" action="person-input">
                            <s:param name="id" value="%{id}"/>
                        </s:url>
                        <a class="edit-link" href="${editUrl}">Edit</a>
                        <s:form action="person-delete" method="post">
                            <s:hidden name="id" value="%{id}"/>
                            <button type="submit" class="delete" onclick="return confirm('Delete this record?');">Delete</button>
                        </s:form>
                    </div>
                </td>
            </tr>
        </s:iterator>
        </tbody>
    </table>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const table = document.querySelector('table');
        const headers = table.querySelectorAll('th.sortable');
        const tbody = table.querySelector('tbody');
        let currentSort = { column: null, direction: 'asc' };

        headers.forEach(header => {
            header.addEventListener('click', function() {
                const column = this.dataset.column;
                
                // Toggle direction if same column, otherwise default to asc
                if (currentSort.column === column) {
                    currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
                } else {
                    currentSort.column = column;
                    currentSort.direction = 'asc';
                }

                // Remove sort indicators from all headers
                headers.forEach(h => h.classList.remove('asc', 'desc'));
                
                // Add current sort indicator
                this.classList.add(currentSort.direction);

                // Sort the rows
                sortTable(column, currentSort.direction);
            });
        });

        function sortTable(column, direction) {
            const rows = Array.from(tbody.querySelectorAll('tr')).filter(row => {
                // Only include rows with data (skip empty state message)
                return row.cells.length > 1 && row.cells[0].textContent.trim() !== 'No persons available.';
            });

            if (rows.length === 0) return;

            const columnIndex = Array.from(headers).findIndex(h => h.dataset.column === column);

            rows.sort((a, b) => {
                const aVal = a.cells[columnIndex].textContent.trim();
                const bVal = b.cells[columnIndex].textContent.trim();

                let comparison = 0;
                
                // Check if numeric (ID and Age columns)
                if (column === 'id' || column === 'age') {
                    const aNum = parseInt(aVal) || 0;
                    const bNum = parseInt(bVal) || 0;
                    comparison = aNum - bNum;
                }
                // Check if date/datetime
                else if (column === 'birthDate' || column === 'created' || column === 'updated') {
                    const aDate = new Date(aVal);
                    const bDate = new Date(bVal);
                    comparison = aDate - bDate;
                }
                // String comparison
                else {
                    comparison = aVal.localeCompare(bVal);
                }

                return direction === 'asc' ? comparison : -comparison;
            });

            // Clear tbody and re-append sorted rows
            tbody.innerHTML = '';
            rows.forEach(row => tbody.appendChild(row));
        }

        // Sort by ID ascending on page load
        const idHeader = Array.from(headers).find(h => h.dataset.column === 'id');
        if (idHeader) {
            currentSort.column = 'id';
            currentSort.direction = 'asc';
            idHeader.classList.add('asc');
            sortTable('id', 'asc');
        }
    });
</script>
</body>
</html>
