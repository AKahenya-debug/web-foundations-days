


CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    student_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);


CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL UNIQUE
);


CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,

    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),

    UNIQUE (student_id, course_id)
);


INSERT INTO students (student_id, student_name, email) VALUES
(1, 'Anne Karanja', 'anne@gmail.com'),
(2, 'Brian Otieno', 'brian@gmail.com'),
(3, 'Carol Wanjiku', 'carol@gmail.com'),
(4, 'David Kamau', 'david@gmail.com');

INSERT INTO courses (course_id, course_name) VALUES
(1, 'Business Administration'),
(2, 'Computer Science'),
(3, 'Health Science');


INSERT INTO enrolments
    (enrolment_id, student_id, course_id, grade)
VALUES
(1, 1, 1, 'A'),
(2, 1, 2, 'B'),
(3, 2, 1, 'B'),
(4, 2, 3, 'A'),
(5, 3, 2, 'A');

SELECT s.student_name, c.course_name, e.grade
FROM students AS s
JOIN enrolments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE s.student_name = 'Anne Karanja';

SELECT s.student_name, c.course_name, e.grade
FROM students AS s
JOIN enrolments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE c.course_name = 'Business Administration';

SELECT c.course_name,
       COUNT(e.student_id) AS number_of_students
FROM courses AS c
LEFT JOIN enrolments AS e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name;

SELECT s.student_id, s.student_name, s.email
FROM students AS s
LEFT JOIN enrolments AS e ON s.student_id = e.student_id
WHERE e.enrolment_id IS NULL;

UPDATE enrolments
SET grade = 'A'
WHERE enrolment_id = 2;

SELECT enrolment_id, student_id, course_id, grade
FROM enrolments
WHERE enrolment_id = 2;

CREATE INDEX idx_enrolments_course_id
ON enrolments(course_id);
