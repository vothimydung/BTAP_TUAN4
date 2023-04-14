
USE QLBANHANG

---c�u1
--a. Th�m d? li?u cho b?ng

INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('NV04', 'V? Th? M? Dung', 'N?', N'Qu?ng Ng?i', '0982623123', 'ntt@example.com', 'K? to�n')

BACKUP DATABASE [QLBANHANG] TO DISK = 'D:\BTAP_TUAN1.bak' WITH INIT

------b.Th�m d? li?u cho b?ng 

INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('NV05', 'Nguy?n Th? T�', 'N?', 'Ha Noi', '098467528', 'nt@example.com', 'V?t t�')

BACKUP DATABASE [QLBANHANG] TO DISK = 'D:\BTAP_TUAN1.bak' WITH DIFFERENTIAL

-----c.-----------

ALTER DATABASE [QLBANHANG] SET RECOVERY FULL;
BACKUP DATABASE [QLBANHANG] TO DISK='D:\BTAP_TUAN1.bak';

INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES
('NV06', 'L� V�n Luy?n', 'Nam', 'Qu?ng Ng?i', '0325648974', 'levanluyen@gmail.com', 'Marketing');

BACKUP LOG [QLBANHANG] TO DISK = 'D:\BTAP_TUAN1.bak' WITH INIT

-----d-------------

INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
VALUES ('NV07', 'Nguy?n V�n Tu?n', 'Nam', 'Ha Tinh', '09547634201', 'vt@example.com', 'K? to�n')

BACKUP LOG [QLBANHANG] TO DISK = 'D:\BTAP_TUAN1.bak' WITH NOINIT

--c�u 2

--a

DROP DATABASE QLBANHANG
 
--b
RESTORE DATABASE QLBANHANG 
FROM DISK = 'D:\BTAP_TUAN1.bak'
WITH STANDBY = 'D:\BTAP_TUAN1_undo.bak'