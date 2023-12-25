--cau 1
create procedure sp_ThongtinDocgia
	@madg smallint
as
begin
	if(exists(select * from nguoilon nl where nl.ma_docgia=@madg))--neu @madg ton tai trong bang nguoi lon
		begin
			select *
			from docgia dg, nguoilon nl
			where dg.ma_docgia=nl.ma_docgia and dg.ma_docgia=@madg
		end
	else
		if(exists(select * from treem te where te.ma_docgia=@madg))
			begin
				select *
				from docgia dg,treem te
				where dg.ma_docgia=te.ma_docgia and dg.ma_docgia=@madg
			end
end
go

drop proc sp_ThongtinDocgia
exec sp_ThongtinDocgia 3

--Cau 2
create procedure sp_ThongtinDausach
	@isbn smallint
as
begin
	select ds.isbn, ds.ngonngu, ds.bia, ds.trangthai, ts.ma_tuasach, ts.TuaSach, ts.tacgia, ts.tomtat, count(*)
	from CuonSach cs, DauSach ds, TuaSach ts
	where cs.tinhtrang='y' and @isbn=ds.isbn and ds.isbn=cs.isbn and ds.ma_tuasach=ts.ma_tuasach
	group by ds.isbn, ds.ngonngu, ds.bia, ds.trangthai, ds.ma_tuasach, ds.tuasach, ds.tacgia, ds.tomtat
end
go

drop proc sp_ThongtinDausach

--Cau 3
create procedure sp_ThongtinNguoilonDangmuon
as
begin
	select distinct dg.ho+' '+dg.tenlot+' '+dg.ten,dg.ngaysinh,nl.sonha,nl.duong,nl.quan,nl.dienthoai,nl.han_sd
	from docgia dg,nguoilon nl,muon m
	where dg.ma_docgia=nl.ma_docgia and dg.ma_docgia=m.ma_docgia and nl.ma_docgia=m.ma_docgia
end
go

drop proc sp_ThongtinNguoilonDangmuon
exec sp_ThongtinNguoilonDangmuon



--Cau 4
create proc sp_ThongtinNguoilonQuahan
as
begin
	select distinct dg.ho+' '+dg.tenlot+' '+dg.ten as [Ho Ten],dg.ngaysinh
	from docgia dg,muon m,nguoilon nl
	where dg.ma_docgia =m.ma_docgia and nl.ma_docgia=m.ma_docgia and m.ma_docgia=nl.ma_docgia and (datediff(day,m.ngay_hethan,getdate())>14)
end
go


drop proc sp_ThongtinNguoilonQuaHan
exec sp_ThongtinNguoilonQuaHan

--Cau 5
alter proc sp_DocgiaCoTreEmMuon
as
begin
	select  distinct dg.ho+' '+dg.tenlot+' '+dg.ten as [Ho Ten          ],dg.ngaysinh 
	from docgia dg,muon m,treem te
	where dg.ma_docgia=te.ma_docgia_nguoilon and
	(dg.ma_docgia in (select dg.ma_docgia from muon m where m.ma_docgia=dg.ma_docgia)) and
	(te.ma_docgia in (select te.ma_docgia from muon m where m.ma_docgia=te.ma_docgia))
end
go

drop proc sp_DocgiaCoTreEmMuon
exec sp_DocgiaCoTreEmMuon


--Cau 6
alter proc sp_CapnhatTrangthaiDauSach
	@isbn smallint
as
begin
	if(exists(select cs.isbn from cuonsach cs where cs.isbn=@isbn))
		update dausach set dausach.trangthai ='y' where dausach.isbn=@isbn
	else
		update dausach set dausach.trangthai = 'n' where dausach.isbn=@isbn
end
go

exec sp_CapnhatTrangthaiDauSach 5



--Cau 7
alter proc sp_ThemTuaSach
	@tuasach nvarchar(63),
	@tacgia nvarchar(31),
	@tomtat ntext
as
begin
	--tim vi tri thoa QD 1
	declare @i int
	set @i=1
	while(exists(select ts.ma_tuasach from tuasach ts where ts.ma_tuasach=@i))
		set @i=@i+1
	if(not exists(select * from tuasach ts where ts.tomtat like @tomtat and ts.tacgia like @tacgia and
					ts.tuasach like @tuasach))
		insert into tuasach(ma_tuasach,tuasach,tacgia,tomtat) values(@i,@tuasach,@tacgia,@tomtat)
end
go

exec sp_ThemTuaSach 'Lap Trinh','Vu hoa Thai','mon hoc ua thich cua sv'


--Cau 8
alter proc sp_ThemCuonSach
	@isbn int
as
begin
	--xac dinh ma_cuonsach
	declare @i int
	set @i=1
	while(exists(select cs.ma_cuonsach from cuonsach cs where cs.ma_cuonsach=@i))
		set @i=@i+1
	--kiem tra @isbn nguoi dung nhap vao co trong dau sach hay chua
	if(exists(select * from dausach ds where ds.isbn=@isbn))
	begin
		insert into cuonsach(isbn,ma_cuonsach,tinhtrang) values(@isbn,@i,'y')
		update dausach set trangthai='y' where dausach.isbn=@isbn
	end
end
go

exec sp_ThemCuonSach 1

--Cau 9
	
alter proc sp_ThemNguoiLon
	@ho nvarchar(15),
	@tenlot nvarchar(1),
	@ten nvarchar(15),
	@ngaysinh smalldatetime,	
	@sonha nvarchar(63),
	@duong nvarchar(15),
	@quan nvarchar(2),
	@dienthoai nvarchar(13),
	@han_sd smalldatetime
as
begin
	--xac dinh ma_docgia thoa QD 2
	declare @i smallint
	set @i=1
	while(exists(select * from docgia dg where dg.ma_docgia=@i))
		set @i=@i+1
	insert into docgia(ma_docgia,ho,tenlot,ten,ngaysinh) values(@i,@ho,@tenlot,@ten,@ngaysinh)
	if(datediff(year,@ngaysinh,getdate())>=18)
		insert into nguoilon(ma_docgia,sonha,duong,quan,dienthoai,han_sd) values (@i,@sonha,@duong,@quan,@dienthoai,@han_sd)
	else
		print 'Doc Gia nay chua du tuoi'
		return
end
go

exec sp_ThemNguoiLon 'Lam','Kieu','Mai','08/08/2000','70','Hung Vuong a','10','0905081188','2/2/2007'



--Cau 10
	
alter proc sp_ThemTreEm
	@ho nvarchar(15),
	@tenlot nvarchar(1),
	@ten nvarchar(15),
	@ngaysinh smalldatetime,
	@madgnl smallint
as
begin
	--xac dinh ma_docgia thoa QD 2
	declare @i smallint
	set @i=1
	while(exists(select * from docgia dg where dg.ma_docgia=@i))
		set @i=@i+1
	insert into docgia(ma_docgia,ho,tenlot,ten,ngaysinh) values(@i,@ho,@tenlot,@ten,@ngaysinh)
	if((select count(*) from treem te where @madgnl=te.ma_docgia_nguoilon)<2)
		insert into treem(ma_docgia,ma_docgia_nguoilon) values(@i,@madgnl)
	else
		print 'Doc gia nguoi lon nay da bao lanh qua so luong tre e quy dinh'
		return
end
go

exec sp_ThemTreEm 'Nguyen','Thi','Buoi','1/1/2000','13'


--Cau 11
alter proc sp_XoaDocGia
	@mdg smallint
as
begin
	if(not exists(select * from muon m where m.ma_docgia=@mdg))
	begin
		delete dangky from dangky dk where dk.ma_docgia=@mdg
		delete quatrinhmuon from quatrinhmuon qtm where qtm.ma_docgia=@mdg
			--kiem tra doc gia nay co phai la doc gia nguoi lon khong
		if(exists(select * from nguoilon nl where nl.ma_docgia=@mdg))
		begin
			--kiem tra doc gia nguoi lon nay co bao lanh cho doc gia tre e nao khong
			if(exists(select * from treem te where te.ma_docgia_nguoilon=@mdg))
				delete treem from treem te where te.ma_docgia_nguoilon=@mdg
		end
			--kiem tra doc gia nguoi lon nay co muon sach hay khong
		if(exists(select * from muon m where m.ma_docgia=@mdg))
		begin
			print 'Doc gia nguoi lon nay dang muon sach cua thu vien'
			return
		end
		else
			begin	
				delete nguoilon from nguoilon nl where nl.ma_docgia=@mdg
				delete docgia from docgia dg where dg.ma_docgia=@mdg
			end
	end
end
go

exec sp_XoaDocGia 99

--Cau 12
alter proc sp_MuonSach
	@mdg smallint,
	--@ngayhhthe smalldatetime,
	@isbn int,
	@macs smallint
as		
begin
	--kiem tra doc gia co dang muon cuon sach nao cung loai hay khong
	if(not exists(select * from muon m where m.isbn=@isbn and m.ma_docgia=@mdg))
	begin
		--kiem tra loai sach nay co con cuon sach nao trong thu vien hay khong
		if(exists(select * from cuonsach cs where cs.tinhtrang='y' and cs.isbn=@isbn and cs.ma_cuonsach=@macs))
		begin--con co the cho muon sach nay => thuc hien viec cho muon sach
			--xac dinh doc gia la nguoi lon hay tre em
			if(exists(select nl.ma_docgia from nguoilon nl where nl.ma_docgia=@mdg))	--neu doc gia la nguoi lon
			begin
				declare @sosach smallint
				set @sosach=(select count(*) from muon m where m.ma_docgia=@mdg)+
							(select count(*) from muon m where m.ma_docgia in(select te.ma_docgia_nguoilon from treem te where te.ma_docgia_nguoilon=@mdg))
				if(@sosach<5)--thong bao viec muon sach thanh cong
				begin
					insert into muon(isbn,ma_cuonsach,ma_docgia,ngay_muon,ngay_hethan) values(@isbn,@macs,@mdg,getdate(),getdate()+14)
					update cuonsach set tinhtrang='n' where cuonsach.isbn=@isbn and cuonsach.ma_cuonsach=@macs
					print 'Cho muon sach thanh cong'
				end
				else
					begin	
						if(@sosach>=5)
						begin
							print 'Khong the cho muon sach vi vi pham quy dinh 4 va 5'
							return
						end
					end
			end
			else	--neu doc gia la tre em
				begin
					--declare @sosach smallint
					set @sosach=(select count(*) from muon m where m.ma_docgia=@mdg)
					if(@sosach<1)
					begin
						insert into muon(isbn,ma_cuonsach,ma_docgia,ngay_muon,ngay_hethan) values(@isbn,@macs,@mdg,getdate(),getdate()+14)
						update cuonsach set tinhtrang='n' where cuonsach.isbn=@isbn and cuonsach.ma_cuonsach=@macs
						print 'cho muon sach thanh cong'
						return
					end
					else
						begin
							print 'vi pham quy dinh 5'
							return
						end
				end
		end
		else--khong con sach de muon nua -> chuyen thanh dang ky sach
			begin
				print 'sach nay dang duoc muon het roi, ban hay dang ky muon sach'
				insert into dangky(isbn,ma_docgia,ngay_dk,ghichu) values (@isbn,@mdg,getdate(),'dadangky')
				return
			end
	end
	else
		begin
			print 'Doc gia nay da muon mot cuon sac nhu the nay roi'
			return
		end
end
go

exec sp_MuonSach '100','3','1'


--Cau 13
create proc sp_TraSach
	@isbn int,
	@mdg smallint,
	@mcs smallint,
	@tien_datra int,
	@tien_datcoc int,
	@ghichu nvarchar(255)

as
begin
	--xac dinh so tien phat
	declare @sntrehan smallint
	declare @tmp smalldatetime
	declare @sotienphat int
	set @tmp=(select ngay_hethan
			  from muon 
			  where muon.ma_cuonsach=@mcs and muon.ma_docgia=@mdg)
	set @sntrehan=datediff(day,@tmp,getdate())
	if(@sntrehan>0)
		set @sotienphat=@sntrehan*1000
		--them vao bang qua trinh muon
		declare @ngay_muon smalldatetime
		declare @ngay_hethan smalldatetime
		set @ngay_muon=(select m.ngay_muon from muon m where m.isbn=@isbn and m.ma_cuonsach=@mcs)
		set @ngay_hethan=(select m.ngay_hethan from muon m where m.isbn=@isbn and m.ma_cuonsach=@mcs)
		insert into quatrinhmuon(isbn,ma_cuonsach,ngay_muon,ma_docgia,ngay_hethan,ngay_tra,tien_muon,tien_datra,tien_datcoc,ghichu)
					values(@isbn,@mcs,@ngay_muon,@mdg,@ngay_hethan,getdate(),@sotienphat,@tien_datra,@tien_datcoc,@ghichu)
			--xoa bang muon
		delete m from muon m where m.isbn=@isbn and m.ma_cuonsach=@mcs and m.ma_docgia=@mdg
	return
end
go

drop proc sp_TraSach
exec sp_TraSach '2','1'

