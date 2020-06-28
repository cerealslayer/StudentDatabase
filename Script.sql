drop database if exists db3710;

/*
 create database 
*/
create database db3710;

/*
 create the table inside the database
*/
CREATE TABLE db3710.Proffesor (
    ID INT PRIMARY KEY NOT NULL,
    FirstName CHAR(30) NOT NULL,
    LastName CHAR(50) NOT NULL
);
CREATE TABLE db3710.Student (
    ID INT PRIMARY KEY NOT NULL,
    FirstName CHAR(30) NOT NULL,
    LastName CHAR(30) NOT NULL
);

CREATE TABLE db3710.Program (
    ID INT PRIMARY KEY NOT NULL,
    Name CHAR(30) NOT NULL,
    CourseID1 CHAR(30),
    CourseID2 CHAR(30),
    CourseID3 CHAR(30),
    CourseID4 CHAR(30),
    CourseID5 CHAR(30)
);

create table db3710.StudentProgram (
ProgramID INT NOT NULL,
StudentID INT NOT NULL,

constraint Student
foreign key(StudentID) references db3710.Student(ID),

constraint Program
foreign key(ProgramID) references db3710.Program(ID)

);


CREATE TABLE db3710.Course (
    ID INT primary key NOT NULL,
    Name CHAR(30) NOT NULL
);

CREATE TABLE db3710.Grade (
CourseID INT NOT NULL,
StudentID INT NOT NULL,
Grade int check (Grade>= 0 and Grade <= 100),

constraint Course
foreign key(CourseID) references db3710.Course(ID),

constraint Student1
foreign key(StudentID) references db3710.Student(ID)

);
CREATE TABLE db3710.CourseSemester (
CourseID INT NOT NULL,
Year INT NOT NULL check (Year>= 1990),
Semester CHAR(30) NOT NULL check(Semester = 'fall' or Semester = 'winter'),

constraint Course1
foreign key(CourseID) references db3710.Course(ID)

);

CREATE TABLE db3710.CourseProffesor (
CourseID INT NOT NULL,
Year Int not null,
Semester CHAR(30) NOT NULL,
ProffesorID INT NOT NULL,


constraint Course2
foreign key(CourseID) references db3710.Course(ID),

constraint Proffesor
foreign key(ProffesorID) references db3710.Proffesor(ID)

);

/*
insert students into  student Table
*/
insert into db3710.Student values('125612','Eric','cartman');
insert into db3710.Student values('125267','gandalf','the grey');
insert into db3710.Student values('126341','legolas','lego man');

/*
insert courses into course table
*/
insert into db3710.Course values('3710','Database');
insert into db3710.Course values('3610','Design');
insert into db3710.Course values('4650','Archite');
/*
insert the courses into a specific semester
*/
insert into db3710.CourseSemester values('3710','2020','fall');
insert into db3710.CourseSemester values('4650','2010','winter');
insert into db3710.CourseSemester values('3610','2030','fall');

/*
insert students matching id field (2nd) into grade table and give them grades for courses 
*/
insert into db3710.Grade values('3710','125612','70');
insert into db3710.Grade values('4650','125612','70');
insert into db3710.Grade values('4650','125267','50');
insert into db3710.Grade values('3610','126341','80');

/*
insert proffesors into proffesor table
*/
insert into db3710.Proffesor values('213123','Dr','DegreeManGuy');
insert into db3710.Proffesor values('2131','Dr.StrangeLove','Or how i learned to stop worring and love the bomb');
insert into db3710.Proffesor values('223','Dr','Evil');
/*
insert proffesors to teach a course given a semester
*/
insert into db3710.CourseProffesor values('3710','2020','fall','213123');
insert into db3710.CourseProffesor values('4650','2010','winter','2131');
insert into db3710.CourseProffesor values('3610','2030','fall','213123');

/*
insert up to five courses into a program
*/
insert into db3710.Program values('10','CS','3710','3610','4650','','');

/*
insert students into program
*/
insert into db3710.StudentProgram values('10','125612');
insert into db3710.StudentProgram values('10','125267');

/*
 transcript view, insert students such that they are in a course, make sure the course has the semester such that a proffesor is teaching that course
and insert him
*/
CREATE VIEW db3710.Transcript AS
    SELECT 
        s.ID as StudentID,
        s.FirstName,
        s.LastName,
        c.ID,
        c.Name,
        cs.Year,
        cs.Semester,
        g.Grade,
        p.FirstName as ProffesorFirstName,
		p.LastName as ProffesorLastName

    FROM
        db3710.Student s
        inner join db3710.Grade g
        on s.ID = g.StudentID
        INNER JOIN db3710.Course c
		ON c.ID = g.CourseID
        inner join db3710.CourseSemester cs
        on c.ID = cs.CourseID 
        inner join db3710.CourseProffesor cp
        on c.ID = cp.CourseID and cp.Year = cs.Year and cp.Semester = cs.Semester
		inner join db3710.Proffesor p
		on cp.ProffesorID = p.ID;
        
        

SELECT 
    *
FROM
    db3710.Transcript;
    
/*
insert a proffesor and the courses he was teaching that semester. get the students that took that class as a count
*/
  CREATE VIEW db3710.TeachingProfile AS
    SELECT 
        p.ID as ProffesorID,
        p.FirstName,
        p.LastName,
        c.ID as CourseID,
        c.Name,
        cs.Year,
        cs.Semester,
        count(s.ID) as Enrollment
    FROM
        db3710.Proffesor p
        inner join db3710.CourseProffesor cp
        on p.ID = cp.ProffesorID
        INNER JOIN db3710.Course c
		ON c.ID = cp.CourseID
        inner join db3710.CourseSemester cs
        on c.ID = cs.CourseID and cp.Year = cs.Year and cp.Semester = cs.Semester
        inner join db3710.Grade g
        ON g.CourseID = c.ID
        inner join db3710.Student s
        on g.StudentID = s.ID
        
        group by s.ID;
        
        

SELECT 
    *
FROM
    db3710.TeachingProfile;

/*
 get the intersection of students and the students enrolled in a program, insert all the courses that belong to the program
get the grade such that the student did not take the course (not in grade table) or that students grade is less than 60 as needed courses
*/
   CREATE VIEW db3710.Audit AS
    SELECT 
        s.ID as StudentID,
        s.FirstName as StudentFirstName,
        s.LastName as StudentLastName,
        p.ID,
        p.Name as ProgramName,
        c.ID AS neededCourse
    FROM
        db3710.Student s
        inner join db3710.StudentProgram sp
        on s.ID = sp.StudentID
        INNER JOIN db3710.Program p
		ON sp.ProgramID = p.ID
        inner join db3710.Course c
        on c.ID = p.CourseID1 OR c.ID = p.CourseID2 OR c.ID = p.CourseID3 OR c.ID = p.CourseID4 OR c.ID = p.CourseID5
        left join db3710.Grade g
        on c.ID = g.CourseID and s.ID = g.StudentID
        where (g.CourseID is null and g.StudentID is null) or g.Grade < '60';

		

       
        
        

SELECT 
    *
FROM
    db3710.Audit order by StudentID;
  