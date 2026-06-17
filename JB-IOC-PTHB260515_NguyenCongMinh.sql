-- CREATE DATABASE EduSmartDB;

CREATE SCHEMA EduSmart;

SET search_path TO EduSmart;

CREATE TABLE Students
(
    Ma_HV     VARCHAR(10) PRIMARY KEY,
    Ho_Ten    VARCHAR(100) NOT NULL,
    Email     VARCHAR(100) UNIQUE,
    SDT       VARCHAR(15),
    Ngay_Sinh DATE
);

CREATE TABLE Courses
(
    Ma_KH       VARCHAR(10) PRIMARY KEY,
    Ten_KH      VARCHAR(100) NOT NULL,
    The_Loai    VARCHAR(50),
    Hoc_Phi     NUMERIC(12, 2) CHECK (Hoc_Phi > 0),
    So_Luong_HV INT DEFAULT 0
);

CREATE TABLE Enrollments
(
    Ma_DK        VARCHAR(10) PRIMARY KEY,
    Ma_HV        VARCHAR(10) NOT NULL,
    Ma_KH        VARCHAR(10) NOT NULL,
    Ngay_Dang_Ky DATE DEFAULT CURRENT_DATE,
    Trang_Thai   VARCHAR(50),
    FOREIGN KEY (Ma_HV) REFERENCES Students (Ma_HV),
    FOREIGN KEY (Ma_KH) REFERENCES Courses (Ma_KH)
);

CREATE TABLE Payments
(
    Ma_TT       VARCHAR(10) PRIMARY KEY,
    Ma_DK       VARCHAR(10) NOT NULL,
    Phuong_thuc VARCHAR(50),
    Ngay_TT     DATE,
    So_tien     NUMERIC(12, 2) CHECK (so_tien >= 0),
    FOREIGN KEY (Ma_DK) REFERENCES Enrollments (Ma_DK)
);

INSERT INTO students (Ma_HV, Ho_Ten, Email, SDT, Ngay_Sinh)
VALUES ('S001', 'Nguyen Van An', 'an.n@example.com', '0981234567', '1999-10-11'),
       ('S002', 'Tran Thi Binh', 'binh.t@example.com', '0902345678', '1992-01-02'),
       ('S003', 'Le Minh Chau', 'chau.l@example.com', '0913456789', '2001-11-02'),
       ('S004', 'Pham Quoc Dat', 'dat.p@example.com', '0984567890', '1998-02-11'),
       ('S005', 'Vo Thanh Em', 'em.v@example.com', '0935678901', '1998-03-02');

INSERT INTO Courses (Ma_KH, Ten_KH, The_Loai, Hoc_Phi)
VALUES ('C001', 'Python Basic', 'Lập trình', 1200000),
       ('C002', 'Digital Mkt', 'Marketing', 850000),
       ('C003', 'Data Analysis', 'Phân tích dữ liệu', 1500000),
       ('C004', 'UI/UX Design', 'Thiết kế', 1000000),
       ('C005', 'Advanced Java', 'Lập trình', 1800000);

INSERT INTO Enrollments (Ma_DK, Ma_HV, Ma_KH, Trang_Thai, Ngay_Dang_Ky)
VALUES ('EN001', 'S001', 'C001', 'Đang học', '2025-06-01'),
       ('EN002', 'S002', 'C001', 'Hoàn thành', '2025-06-02'),
       ('EN003', 'S003', 'C001', 'Hoàn thành', '2025-06-03'),
       ('EN004', 'S004', 'C002', 'Đã Huỷ', '2025-06-04'),
       ('EN005', 'S005', 'C003', 'Đang học', '2025-06-05');

INSERT INTO Payments (Ma_TT, Ma_DK, Phuong_thuc, Ngay_TT, So_tien)
VALUES ('PA001', 'EN001', 'Credit Card', '2025-06-01', 1200000),
       ('PA002', 'EN002', 'E-Wallet', '2025-06-02', 1200000),
       ('PA003', 'EN003', 'Bank Transfer', '2025-06-04', 1200000),
       ('PA004', 'EN004', 'Credit Card', '2025-06-05', 850000);


-- IV thao tác nghiệp vụ
-- bài 1 Cập nhật học phí

UPDATE Courses
SET Hoc_Phi = Hoc_Phi * 0.8
WHERE The_Loai ILIKE 'Lập trình';

-- bai 2 Hủy đăng ký học

-- vì bảng Enrollments va bang payments có chứa FOREIGN KEY nên sẽ phải xóa trước rồi mới có thể xóa được bảng FOREIGN KEY chỉ đến
-- sẽ phải xóa theo thứ tự là payments > enrollments > students

DELETE
FROM Payments
WHERE (SELECT Ma_DK FROM Enrollments WHERE Ma_HV ILIKE 'S001') = Ma_DK;

DELETE
FROM Enrollments
WHERE Ma_hv ILIKE 'S001';

DELETE
FROM students
WHERE Ma_HV ILIKE 'S001';

-- bai 3 Báo cáo danh sách đã thanh toán

SELECT e.Ma_DK,
       s.ho_ten,
       c.Ten_KH,
       p.Ngay_TT,
       p.So_tien
FROM students s
         JOIN Enrollments e
              ON e.Ma_HV = s.Ma_HV
         JOIN Payments p
              ON p.Ma_DK = e.Ma_DK
         JOIN Courses c
              ON c.Ma_KH = e.Ma_KH
ORDER BY Ngay_TT DESC;

-- bai 4 Tìm kiếm học viên quên thông tin

SELECT Ma_HV,
       Ho_Ten,
       SDT
FROM students s
WHERE SDT ILIKE '098%'
  AND EXTRACT(YEAR FROM Ngay_Sinh) = 1998;

-- bai 5  Hiển thị danh sách lên Web (Phân trang)
SELECT Ma_KH,
       Ten_KH,
       Hoc_Phi
FROM Courses
LIMIT 2 OFFSET 2;

-- V  Báo cáo & phân tích nghiệp vụ
-- bai 1 Xuất biên lai tổng hợp:

SELECT s.Ma_HV,
       s.ho_ten,
       c.Ten_KH,
       COALESCE(p.So_tien, 0) tien_thanh_toan
--        p.So_tien
FROM students s
         JOIN Enrollments e
              ON e.Ma_HV = s.Ma_HV
         LEFT JOIN Payments p
                   ON p.Ma_DK = e.Ma_DK
         JOIN Courses c
              ON c.Ma_KH = e.Ma_KH;

-- bai 2 Tính KPI & Khóa học "Best-seller"
SELECT c.Ma_KH,
       c.Ten_KH,
       count(e.Ma_DK) tong_luot_dang_ky,
       sum(p.So_tien) tong_doanh_thhu
FROM Courses c
         JOIN Enrollments e
              ON e.Ma_KH = c.Ma_KH
         JOIN Payments p
              ON e.Ma_DK = p.Ma_DK
GROUP BY c.Ma_KH, c.Ten_KH
HAVING count(e.Ma_DK) >= 2;

-- bai 3 Thanh tra học phí (Nợ cước)
SELECT e.Ma_DK,
       s.Ma_HV,
       s.ho_ten,
       e.Ngay_Dang_Ky
FROM students s
         JOIN Enrollments e
              ON s.Ma_HV = e.Ma_HV
         LEFT JOIN Payments p
                   ON p.Ma_DK = e.Ma_DK
WHERE p.Ma_TT IS NULL;

-- bai 4  Phân tích khách hàng thân thiết (VIP)

SELECT s.Ma_HV,
       s.ho_ten,
       s.email,
       sum(p.So_tien) tong_tien_da_thanh_toan
FROM students s
         JOIN Enrollments e
              ON s.Ma_HV = e.Ma_HV
         LEFT JOIN Payments p
                   ON p.Ma_DK = e.Ma_DK
GROUP BY s.Ma_HV, s.ho_ten
HAVING sum(p.So_tien) > 1000000;

-- VI View, Trigger, Function/Procedure – Hướng nghiệp vụ thực tế

-- bai 1 View: Khóa học mới ghi danh
CREATE OR REPLACE VIEW vw_RecentEnrollments
AS
SELECT s.ho_ten,
       c.Ten_KH,
       e.Ngay_Dang_Ky,
       e.Trang_Thai
FROM Students s
         JOIN Enrollments e
              ON s.Ma_HV = e.Ma_HV
         JOIN courses c
              On c.Ma_KH = e.Ma_KH
WHERE e.Ngay_Dang_Ky >= '2025-06-01'
ORDER BY e.Ngay_Dang_Ky DESC;

SELECT *
FROM vw_RecentEnrollments;


-- bai 2 View: Doanh thu khóa học cao

CREATE OR REPLACE VIEW vw_HighRevenueCourses
AS
SELECT c.Ten_KH,
       c.The_Loai,
       sum(p.So_tien) tong_doanh_thu
FROM courses c
         JOIN Enrollments e
              ON e.Ma_KH = c.Ma_KH
         JOIN Payments p
              ON p.Ma_DK = e.Ma_DK
GROUP BY c.Ma_KH
HAVING sum(p.So_tien) > 1000000;

SELECT *
FROM vw_HighRevenueCourses;

-- bai 3 Trigger: Kiểm tra logic ngày thanh toán

CREATE OR REPLACE FUNCTION check_payment_date()
    RETURNS TRIGGER
AS
$$
DECLARE
    v_ngay_dang_ky DATE ;
BEGIN
    SELECT ngay_dang_ky
    INTO v_ngay_dang_ky
    FROM Enrollments
    WHERE Ma_DK = new.ma_dk;

    IF new.ngay_tt < v_ngay_dang_ky
    THEN
        RAISE EXCEPTION 'ngay thanh toan khong phu hop';
    end if;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$ language plpgsql;

CREATE OR REPLACE TRIGGER tg_check_payment_date
    BEFORE INSERT OR UPDATE
    ON payments
    FOR EACH ROW
EXECUTE FUNCTION check_payment_date();

-- test insert
INSERT INTO payments(ma_tt, ma_dk, phuong_thuc, ngay_tt, so_tien)
values ('PA005', 'EN005', 'Credit Card', '2025-06-01', 1200000);
-- test update
UPDATE payments
SET Ngay_TT = '2025-06-01'
WHERE Ma_TT = 'PA004';


-- bai 4 Trigger: Cập nhật sĩ số lớp học
CREATE OR REPLACE FUNCTION update_student_count()
    RETURNS TRIGGER
AS
$$
BEGIN

    UPDATE Courses
    SET so_luong_hv = so_luong_hv + 1
    WHERE Ma_KH = new.ma_kh;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$ language plpgsql;

CREATE OR REPLACE TRIGGER tg_update_student_count
    AFTER INSERT
    ON Enrollments
    FOR EACH ROW
EXECUTE FUNCTION update_student_count();

-- test
INSERT INTO students (Ma_HV, Ho_Ten, Email, SDT, Ngay_Sinh)
VALUES ('S001', 'Nguyen Van An', 'an.n@example.com', '0981234567', '1999-10-11');

INSERT INTO Enrollments (Ma_DK, Ma_HV, Ma_KH, Trang_Thai, Ngay_Dang_Ky)
VALUES ('EN001', 'S001', 'C001', 'Đang học', '2025-06-01');


-- bai 5 Procedure: Thêm khóa học mới
CREATE OR REPLACE PROCEDURE sp_add_course(p_ma_kh VARCHAR(10), p_ten_kh VARCHAR(100), p_the_loai VARCHAR(100),
                                          p_hoc_phi NUMERIC(12, 2))
    LANGUAGE plpgsql
AS
$$
BEGIN

    INSERT INTO courses(ma_kh, ten_kh, the_loai, hoc_phi)
    VALUES (p_ma_kh, p_ten_kh, p_the_loai, p_hoc_phi);

END;
$$;
-- test
CALL sp_add_course('C006', 'test1', 'test2', 121212);

-- bai 6 Procedure: Chuyển đổi khóa học

CREATE OR REPLACE PROCEDURE sp_switch_course(p_ma_dk varchar(10), p_ma_kh_moi VARCHAR(10))
    language plpgsql
AS
$$
DECLARE
    v_ma_kh_cu VARCHAR(10);
BEGIN
    SELECT Ma_KH
    INTO v_ma_kh_cu
    FROM Enrollments
    WHERE p_ma_dk = Ma_DK;

    UPDATE courses
    SET so_luong_hv = So_Luong_HV - 1
    WHERE Ma_KH = v_ma_kh_cu;

    UPDATE courses
    SET so_luong_hv = So_Luong_HV + 1
    WHERE Ma_KH = p_ma_kh_moi;

    UPDATE Enrollments
    SET Ma_KH = p_ma_kh_moi
    WHERE Ma_DK = p_ma_dk;

END ;
$$;

CALL sp_switch_course('EN001', 'C002');
