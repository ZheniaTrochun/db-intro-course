```mermaid
erDiagram
    DEPARTMENTS ||--o{ COURSES : "includes"
    COURSES ||--o{ ENROLLMENT : "has"
    STUDENTS ||--o{ ENROLLMENT : "enrolls via"
    VACANCIES ||--o{ APPLICATIONS : "receives"
    STUDENTS ||--o{ APPLICATIONS : "submits"
    STUDENTS |o--|| USERS : "linked to"
    USERS ||--o| DORM_ADMINS : "linked to"
    ROOMS |o--o{ STUDENTS : "houses"
    DORMS ||--|{ ROOMS : "contains"
    STUDENTS |o--o| PARKING_SLOTS : "uses"
    DORMS ||--o{ PARKING_SLOTS : "has"
    DORM_ADMINS |o--o{ PARKING_SLOTS : "uses"
    DORMS ||--O{ DORM_ADMINS : "managed by"

    DEPARTMENTS {
        int DepartmentID PK
        string DepartmentName
    }

    COURSES {
        int CourseID PK
        int DepartmentID FK
        string CourseTitle
    }

    ENROLLMENT {
        int EnrollmentID PK
        int StudentID FK
        int CourseID FK
        date EnrollmentDate
        string Grade
    }

    VACANCIES {
        int VacancyID PK
        string CompanyName
        string JobName
    }

    APPLICATIONS {
        int ApplicationID PK
        int StudentID FK
        int VacancyID FK
        date ApplicationDate
        string Status
    }

    STUDENTS {
        int StudentID PK
        int EnrollmentYear
        int RoomID FK
        enum Status
        int UserID FK
    }

    DORM_ADMINS {
        int AdminID PK
        int UserID FK
        int DormID FK
    }

    DORMS {
        int DormID PK
        string Address UK
    }

    ROOMS {
        int RoomID PK
        int DormID FK
        string RoomNumber
        int Floor
    }

    PARKING_SLOTS {
        int ParkingSlotID PK
        int StudentID FK
        int DormID FK
        int AdminID FK
        string SlotNumber
    }

    USERS {
        int UserID PK
        string FirstName
        string LastName
        string Email
        date DateOfBirth
        date RegistrationDate
        string Status
    }
```
