# Person Registry Application - Project Overview

## What is this application?

This is a **Person Registry** - a digital address book that helps you keep track of people's information. Think of it like a modernized version of an old paper contact book, but instead of writing names and phone numbers, you store people's names, surnames, birth dates, and it automatically calculates their age.

## What can you do with it?

### 1. **View All People**
When you open the application, you see a table listing all the people you've added. The list shows:
- ID number (automatically assigned)
- Name and Surname
- Birth Date
- Current Age (automatically calculated)
- When the record was created
- When it was last updated

### 2. **Add New People**
Click the "Add Person" button to add someone new. You fill in:
- First name
- Last name
- Birth date

The application automatically calculates and displays their age as you type the birth date.

### 3. **Edit Existing Records**
Click "Edit" next to any person's name to update their information. You can change their name, surname, or birth date, and the age will update automatically.

### 4. **Remove People**
Click "Delete" to remove someone from the registry. The system will ask you to confirm before permanently deleting the record.

### 5. **Sort and Organize**
Click on any column header (ID, Name, Surname, Birth Date, Age, Created, Updated) to sort the entire list by that information. Click again to reverse the order. This helps you quickly find people or organize your list the way you want.

## Key Features

### 🎯 **User-Friendly**
- Clean, modern design
- Easy-to-read layout
- Simple buttons and forms
- Confirmation before deleting records

### 🧮 **Smart Age Calculation**
- Age updates automatically based on birth date
- Considers whether their birthday has passed this year
- No manual calculations needed

### 📊 **Flexible Sorting**
- Sort by any column with one click
- Automatically sorts by ID when you first open the page
- Visual arrows show which way the list is sorted

### 💾 **Persistent Storage**
- All information is saved in a database
- Data remains even after closing the application
- Timestamps show when records were created or modified

### 🎨 **Modern Interface**
- Responsive design
- Color-coded buttons (blue for actions, red for delete)
- Hover effects for better user experience
- Clean typography and spacing

## How it Works (Simplified)

1. **You visit the website** → The application shows you the list of people
2. **You click "Add Person"** → A form appears
3. **You fill in the details** → The system validates your input
4. **You click "Save"** → The information goes into the database
5. **You return to the list** → You see your new entry with all others

## Real-World Applications

This type of application can be adapted for:
- **Small Business**: Customer contact management
- **Schools**: Student registry
- **Clubs**: Member directory
- **Healthcare**: Patient records (with more fields)
- **Events**: Attendee tracking
- **Human Resources**: Employee directory

## Technical Highlights (Non-Technical Version)

- **Web-Based**: Works in your browser, no installation needed
- **Database-Backed**: All data is safely stored
- **Real-Time**: Changes appear immediately
- **Reliable**: Built with proven, stable technologies
- **Maintainable**: Clean code structure makes it easy to update or expand

## Project Status

✅ **Fully Functional**
- All CRUD operations work (Create, Read, Update, Delete)
- Sorting and age calculation implemented
- User interface polished and tested
- Ready for deployment

## Future Enhancements (Possible)

- Search functionality to find people quickly
- Export list to Excel or PDF
- Photo uploads for each person
- Email and phone number fields
- Categories or tags for grouping people
- Print-friendly view
