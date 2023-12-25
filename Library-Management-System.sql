---Cau 1
drop proc sp_ThongtinDocgia
create proc sp_ThongtinDocgia @madocgia smallint
as
begin
	if exists (select * from nguoilon n where n.ma_docgia = @madocgia)	
		select * from nguoilon n, docgia d where n.ma_docgia = d.ma_docgia and n.ma_docgia = @madocgia	
	else	
		select * from treem t, docgia d where t.ma_docgia = d.ma_docgia and t.ma_docgia = @madocgia	
end
go
exec sp_ThongtinDocgia 1 
---Cau 2
drop proc sp_ThongtinDausach
create proc sp_ThongtinDausach @isbn int
as
	if exists (select isbn from DauSach where isbn=@isbn)
		select ds.isbn, ds.ma_tuasach, ds.ngonngu,ds.bia,ds.trangthai,ts.tuasach,ts.tacgia,ts.tomtat,(select count(*) as 'So luong' from CuonSach cs where cs.isbn=@isbn and cs.tinhtrang='N') from DauSach ds,TuaSach ts where ds.isbn=@isbn and ds.ma_tuasach=ts.ma_tuasach
	else print 'Khong ton tai ma dau sach nay'
go

---Cau 3
create proc sp_ThongtinNguoilonDangmuon
as
begin
	select d.ma_docgia, d.ho, d.tenlot, d.ten, d.NgaySinh
	from docgia as d,QuaTrinhMuon as q, nguoilon as n
	where d.ma_docgia = q.ma_docgia and n.ma_docgia = d.ma_docgia and q.ngay_tra is null
end
go
---Cau4
create proc sp_ThongtinNguoilonQuahan
as
begin
	select d.ma_docgia, d.ho, d.tenlot, d.ten, d.NgaySinh
	from docgia as d, muon as m
	where d.ma_docgia = m.ma_docgia and datediff(day,GetDate(),m.ngay_hethan) > 14
end
go
---Cau5
create proc sp_DocgiaCoTreEmMuon
as
begin
	select d.ma_docgia, d.sonha, d.duong, d.quan, d.dienthoai, d.han_sd
	from nguoilon as d, muon as m, treem as t
	where d.ma_docgia = m.ma_docgia and t.ma_docgia = m.ma_docgia and t.ma_docgia_nguoilon = d.ma_docgia
end
go
---Cau 6
create proc sp_CapnhatTrangthaiDausach @isbn int
as
begin
	if (exists(select c.isbn from cuonsach c where c.isbn = @isbn and tinhtrang = 'Y'))
	begin
		update dausach
		set trangthai = 'Y'
		where isbn = @isbn
	end
	else
	begin
		update dausach
		set trangthai = 'N'
		where isbn = 'N'
	end
end
go

--Cau 7
drop proc sp_ThemTuaSach
create proc sp_ThemTuaSach
@tuasach nvarchar(63),
@tacgia nvarchar(31),
@tomtat ntext
as
begin	
	declare @mats int
	@mats = 1
	while (@mats = (select ma_tuasach from tuasach where ma_tasach = @mats))
	begin
		set @mats = @mats + 1		
	end
		
	if (not exists(select * from tuasach where tuasach = @tuasach or tacgia = @tacgia or tomtat like @tomtat))
	begin
		insert into tuasach(ma_tuasach,tuasach,tacgia,tomtat) values(@mats,@tuasach,@tacgia,@tomtat)
	end
	else
		print('Thong tin sach da ton tai')
		
end
go
--Cau 8
create proc sp_Themcuonsach
AS @isbn
Begin 
@isbn int 
AS
BEGIN 
	DEclare @macuonsach smallint
	Set @macuonsach=1
	While(Exisrts(select *
			FROM cuonsach cs
			where cs.isbn=@isbn AND
			cs.ma_cuonsach=@macuonsach))
	Begin
		Set @macuonsach=@macuonsach+1
	End 
	Insert into cuonsach (isbn,macuonsach,tinhtrang) 
	Values(@isbn,@mamuonsach,'Y')
	Update dausach set trangthai='Y'
	Where isbn=@isbn
End
go
--Cau 9
create proc sp_Themtuasach
@ho varchar(15),
@tenlot varchar(15),
@sonha varchar(15),
@duong varchar,
@dt char
as
begin 
	declare @mdg smallint 
	set @mdg=1
	while(@mdg=(select ma_docgia from where ma_docgia=@mdg))
	begin	
		set @mdg=@mdg+1
	end
	insert into docgia(ma_docgia,ho,tenlot,ten,ngaysinh)
	values(@mdg,@ho,@tenlot,@ten,@ngaysinh)
If(DATEDIFF(yyyy,@ngaysinh,gatedate())<18)
	begin print N'doc gia nay chua du tuoi'
end
else 
	begin 
		insert into nguoilon(ma_docgia,sonha,duong,quan,dienthoai,han_sd)
		values(@mdg,@sonha,@duong,@quan,@dt,set @hansudung=DateAdd(yy,1,getdate())
	end
end
go
--Cau 10
create proc sp_ThemTreem
@ho varchar(15),
@tenlot char(1),
@ten varchar(15),
@ngaysinh smalldatetime,
@madgnl smallint
as
begin 
	declare	@madocgia smallint
	set @madocgia=1
	while(exists(Select *
	   	   	 	 From docgia d
	         	 Where d.ma_docgia=@madocgia)) 
		set @madocgia=@madocgia+1
	Insert into docgia(ma_docgia,ho,tenlot,ten,ngaysinh) values(@madocgia,@ho,@tenlot,@ten,@ngaysinh)		
	if((Select count(ma_docgia)
   	   	From treem
		Where ma_docgia_nguoilon=@madgnl)>=2)
		print 'khong the them duoc nua' 
	else
		Insert into TREEM(ma_docgia,ma_docgia_nguoilon) values(@madocgia,@madgnl)		
end
--Cau 11
create procedure sp_XoaDocGia
@madg smallint
as
begin
	delete from dangky where ma_docgia=@madg
	delete from quatrinhmuon where ma_docgia=@madg
	if(exists(select * 
			  from nguoilon
			  where ma_docgia=@madg))
		begin
			while(exists(select *
					     from treem
					     where ma_docgia_nguoilon=@madg))
  				delete from treem where ma_docgia_nguoilon=@madg
			if(exists(select *
				print 'Khong the xoa doc gia nay.'
			else
				begin
					delete from treem where ma_docgia=@madg
					delete from treem where ma_docgia=@madg	
				end
	end		
end
go
--Cau 13
create procedure sp_TraSach
	@isbn int,
	@macs smallint,
	@madg smallint,
	@ngaygiotra smalldatetime,
	@tiendatra money,
	@tiencoc money,
	@ghichu nvarchar(255)
as
begin
	declare	@songaytre smallint
	set @songaytre=0
	set @songaytre=(select datediff(dy,ngay_hethan,@ngaygiotra)	
					from muon 
					where isbn=@isbn and ma_cuonsach=@macs and ma_docgia=@madg)
	if(@songaytre>0)
	begin
		print 'So tien phat:'
		print @songaytre*1000
	end

	declare	@ngaymuon smalldatetime
	declare	@ngayhh smalldatetime
	Select @ngaymuon=ngayGio_muon, @ngayhh=ngay_hethan
	from muon
	where isbn=@isbn and ma_cuonsach=@macs and ma_docgia=@madg

	insert into quatrinhmuon values (@isbn,@macs,@ngaymuon,@madg,@ngayhh,
								@ngaygiotra,@songaytre*1000,@tiendatra,@tiencoc,@ghichu)
	delete from muon where isbn=@isbn and ma_cuonsach=@macs and ma_docgia=@madg
end
go
--Cau 12
create proc sp_MuonSach
@ma_docgia smallint,
@ma_cuonsach smallint
as
begin
	declare @isbn int
	--Kiem tra xem doc gia co dang muon cuon sach ma minh muon muon khong
	if (not exists(select ma_docgia from muon where ma_docgia = @ma_docgia and ma_cuonsach = @ma_cuonsach))
	--Ok
	begin
		select @isbn = isbn from cuonsach where ma_cuonsach = @ma_cuonsach
		--Kiem tra cuon sach nay co the muon dc khong
		if (not exists(select ma_cuonsach from cuonsach where ma_cuonsach = @ma_cuonsach and tinhtrang = 'y'))
		begin
			declare @slsachdangmuon int
			--Lay so luong sach ma doc gia dang muon
			select @slsachdangmuon = count(*) from muon where ma_docgia = @ma_docgia	
			--Kiem tra doc gia phai la nguoi lon hay tre em			
			if (exists(select ma_docgia from nguoilon where ma_docgia = @ma_docgia))
			--Neu la nguoi lon		
			begin		
				declare @slsachtreem int			
				--Lay so luong sach tre em cua doc gia bao tro dang muon
				select @slsachtreem = count(*) from treem t, muon m where t.ma_docgia = m.ma_docgia and t.ma_docgia_nguoilon = @ma_docgia
				--Cong cac sach ma nhung tre em doc gia bao lanh muon voi sach doc gia dang muon
				set @slsachdangmuon = @slsachdangmuon + @slsachtreem
				if (@slsachdangmuon >= 5)
				begin
					print('Khong the muon sach vi vi pham QD4')
					return
				end
				else
				begin
					insert into muon(isbn,ma_cuonsach,ma_docgia,ngay_muon,ngay_hethan) values(@isbn,@ma_cuonsach,@ma_docgia,getdate(),dateadd(day,14,getdate()))
					print('Them thanh cong')
				end
			end
			--Neu la tre em
			else
			begin
				if (@slsachdangmuon < 1)
				begin
					insert into muon(isbn,ma_cuonsach,ma_docgia,ngay_muon,ngay_hethan) values(@isbn,@ma_cuonsach,@ma_docgia,getdate(),dateadd(day,14,getdate()))
					print('Them thanh cong')
				end
				else
				begin
					print('Khong the muon sach vi pham QD5')
					return
				end
			end
		end
		else
		begin
			print('Cuon sach nay da het. Chung toi se dang ky cuon sach nay cho doc gia')
			insert into dangky(isbn,ma_docgia,ngay_dk) values(@isbn,@ma_docgia,getdate())
			return
		end
	end
	else
		print('Sang nay dang duoc doc gia muon')
end
