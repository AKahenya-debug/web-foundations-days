# School Database Design

## 1. Tables

### Students

The students table stores information about each student. It contains a student ID, name and email address. The student ID is the primary key, and the email address must be unique so that two students cannot register with the same email.

### Courses

The courses table stores information about the courses offered by the school. It contains a course ID, course name and an optional description. The course ID is the primary key.

### Enrolments

The enrolments table records which students are enrolled in which courses. It contains an enrolment ID, student ID, course ID and grade. The student ID and course ID are foreign keys referencing the students and courses tables. A unique constraint on the combination of student ID and course ID prevents duplicate enrolments.

## 2. Relationships

There is a one-to-many relationship between students and enrolments because one student can have multiple enrolment records, but each enrolment belongs to one student.

There is also a one-to-many relationship between courses and enrolments because one course can have multiple enrolment records, but each enrolment refers to one course.

Students and courses have a many-to-many relationship. One student can take several courses, and one course can have several students. The enrolments table acts as a join table that connects students and courses. It is necessary because it resolves the many-to-many relationship and stores additional information, such as each student's grade for a particular course.

## 3. Recommended Index

I would add an index on the course ID in the enrolments table to improve queries that retrieve students enrolled in a particular course and queries that group enrolments by course.

```sql
CREATE INDEX idx_enrolments_course_id
ON enrolments(course_id);
```

This index can help SQLite find enrolment records for a course more efficiently as the database grows.

## 4. SQL or NoSQL?

I would choose SQL for this school system because the data is structured and has clear relationships between students, courses and enrolments. A relational database such as SQLite supports primary keys, foreign keys, unique constraints and joins, which help maintain accurate and consistent records. SQL also makes it easy to retrieve courses for a student, list students on a course and calculate enrolment totals. NoSQL could be useful for flexible or rapidly changing data structures, but a relational database is a better fit for this system.
