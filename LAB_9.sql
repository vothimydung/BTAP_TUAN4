

--câu 1

CREATE TRIGGER trg_Nhap
ON Nhap
AFTER INSERT
AS
BEGIN
	DECLARE @MaSP NVARCHAR(30), @MaNV NVARCHAR(30)
	DECLARE @SoLuongN INT, @DonGiaN FLOAT
	SELECT @MaSP = masp , @MaNV = manv, @SoLuongN = soluongN, @DonGiaN = dongiaN
	FROM inserted
	IF (NOT EXISTS(SELECT * FROM SANPHAM WHERE masp = @MaSP))
		BEGIN
			RAISERROR (N'Không tồn tại sản phẩm trong danh mục sản phẩm', 16,1)
			ROLLBACK TRANSACTION
		END
			IF(NOT EXISTS (SELECT * FROM NHANVIEN WHERE manv = @MaNV))
				BEGIN
					RAISERROR(N'Không tồn tại sản phẩm trong danh mục nhân viên',16,1)
					ROLLBACK TRANSACTION
				END
			ELSE
			IF(@SoLuongN <= 0 OR @DonGiaN <= 0)
				BEGIN
					RAISERROR(N'nhập sai số lượng và đơn giá', 16,1)
					ROLLBACK TRANSACTION
				END
			ELSE

				UPDATE Sanpham SET soluong = soluong + @SoLuongN
				FROM Sanpham WHERE masp = @MaSP
END
go

--câu 2

CREATE TRIGGER trg_Xuat
ON Xuat
AFTER INSERT
AS
BEGIN
	DECLARE @SoHĐX NVARCHAR(30), @MaSP NVARCHAR(30)
	DECLARE @MaNV NVARCHAR(30), @NgayXuat NVARCHAR(30)
	DECLARE @SoLuongX INT
	SELECT @SoHĐX = sohdx , @MaSP = masp, @MaNV = manv, @NgayXuat = ngayxuat, @SoLuongX = soluongX
	FROM inserted
	IF (NOT EXISTS(SELECT * FROM SANPHAM WHERE masp = @MaSP))
		BEGIN
			RAISERROR (N'Không tồn tại sản phẩm trong danh mục sản phẩm', 16,1)
			ROLLBACK TRANSACTION
		END
			IF(NOT EXISTS (SELECT * FROM NHANVIEN WHERE manv = @MaNV))
				BEGIN
					RAISERROR(N'Không tồn tại sản phẩm trong danh mục nhân viên',16,1)
					ROLLBACK TRANSACTION
				END
			ELSE
			IF(@SoLuongX > (SELECT soluong FROM Sanpham WHERE masp = @MaSP))
				BEGIN
					RAISERROR(N'Số lượng xuất vượt quá số lượng trong kho', 16,1)
					ROLLBACK TRANSACTION
				END
			ELSE

				UPDATE Sanpham SET soluong = soluong - @SoLuongX
				FROM Sanpham WHERE masp = @MaSP
END
go

--câu 3

CREATE TRIGGER capnhatSoluongXoaPhieuXuat
ON Xuat
AFTER DELETE
AS
BEGIN
    -- Cập nhật số lượng hàng trong bảng Sanpham tương ứng với sản phẩm đã xuất
    UPDATE Sanpham
    SET Soluong = Sanpham.Soluong + deleted.soluongX
    FROM Sanpham
    JOIN deleted ON Sanpham.Masp = deleted.Masp
END
--câu 4
go
CREATE TRIGGER capnhat_xuat_soluong_trigger
ON xuat
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra xem có ít nhất 2 bản ghi bị update hay không
    IF (SELECT COUNT(*) FROM inserted) < 2
    BEGIN
DECLARE @old_soluong INT, @new_soluong INT, @masp NVARCHAR(10)

        SELECT @masp = i.masp, @old_soluong = d.soluongX, @new_soluong = i.soluongX
        FROM deleted d INNER JOIN inserted i ON d.sohdx = i.sohdx AND d.masp = i.masp

        -- Kiểm tra số lượng xuất mới có nhỏ hơn số lượng tồn kho hay không
        IF (@new_soluong <= (SELECT soluong FROM sanpham WHERE masp = @masp))
        BEGIN
            UPDATE xuat SET soluongX = @new_soluong WHERE sohdx IN (SELECT sohdx FROM inserted)
            UPDATE sanpham SET soluong = soluong + @old_soluong - @new_soluong WHERE masp = @masp
        END
    END
END
go
--câu 5
go
CREATE TRIGGER tr_updateNhap
ON Nhap
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra số bản ghi thay đổi
    IF (SELECT COUNT(*) FROM inserted) > 1
    BEGIN
        RAISERROR('Chỉ được phép cập nhật 1 bản ghi tại một thời điểm', 16, 1)
        ROLLBACK
    END
    
    -- Kiểm tra số lượng nhập
    DECLARE @masp INT
    DECLARE @soluongN INT
    DECLARE @soluong INT
    
    SELECT @masp = i.masp, @soluongN = i.soluongN, @soluong = s.soluong
    FROM inserted i
    INNER JOIN Sanpham s ON i.masp = s.masp
    
    IF (@soluongN > @soluong)
    BEGIN
        RAISERROR('Số lượng nhập không được vượt quá số lượng hiện có trong kho', 16, 1)
        ROLLBACK
    END
    
    -- Cập nhật số lượng trong bảng Sanpham
    UPDATE Sanpham
    SET soluong = soluong + (@soluongN - (SELECT soluongN FROM deleted WHERE masp = @masp))
    WHERE masp = @masp
END

go
--câu 6
CREATE TRIGGER update_soluong_sp 
ON Nhap
AFTER DELETE
AS

BEGIN
    
    UPDATE Sanpham
    SET Soluong = Sanpham.Soluong - deleted.soluongN
    FROM Sanpham
    JOIN deleted ON Sanpham.Masp = deleted.Masp
END
go
