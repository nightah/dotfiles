-- �f�B���C�����x��Lua rev.1
-- �f�B���C���������ɕK�v�Ȋe��l��\��

---D582:NMI�I��
---�@�@�b�i�O���������v���j
---D89B:�G�ǂݍ��ݎ��̃o���N�؂�ւ��ӏ�
---�@�@�b�i�㔼�������v���j
---D4A8:NMI�J�n

local water_pre_frame = 0         ---���ߐ����擾�����Ƃ��̃t���[��
local water_pre_flag = 0          ---�X�N���[���J�E���g���L�^���邩
local water_pre_temp = 0          ---���������L�^
local water_pre_instructions = 0  ---�o�͏�����

local water_next_frame = 0         ---���ߐ����擾�����Ƃ��̃t���[��
local water_next_flag = 0          ---�X�N���[���J�E���g���L�^���邩
local water_next_temp = 0          ---���������L�^
local water_next_instructions = 0  ---�o�͏�����

local enemy_bank = 0               ---�������������ꍇ�ɓǂ܂��Ɨ\�z�����o���N

local object_framecount
local ObjectType = {}
local ObjectAddress = {}
local EnemyAddress = 0
local NewObjectType = {}
local NewObjectAddress = {}


local EmuYFix = -8; --�G�~�����[�^�ɂ��Y�����̕␳
local function BOX(x1,y1,x2,y2,c1,c2)
	gui.box( x1 , y1+EmuYFix , x2 , y2+EmuYFix , c1 , c2 ) ;
end --function BOX
local function TEXT(x,y,t)
	gui.text( x , y+EmuYFix , t ) ;
end --function TEXT


local DestTable =
{
	0x0ED4A8 , "NMI" , "" , "" ,
	0x0ED54C , "Audio" , "" , "" ,
	0x0ED56E , "-" , "" , "" ,
	0x0A91CC , "F-Wait" , "" , "" ,
	0x0A915E , "?" , "" , "" ,
	0x0A9165 , "Pause" , "" , "" ,
	0x0A9187 , "?" , "" , "" ,
	0x0A918A , "Rockman" , "" , "" ,
	0x0A918D , "?" , "" , "" ,
	0x0A919A , "-" , "" , "" ,
	0x0A91A7 , "Weapon?" , "" , "" ,
	0x0A91AA , "Boss" , "" , "" ,
	0x0A91B3 , "HitProc>R" , "" , "" ,
	0x0A91B6 , "HitProc>E" , "" , "" ,
	0x0A91B9 , "?" , "" , "" ,
	0x0A98F2 , "Obj02" , "" , "" ,
	0x0A98F2 , "Obj03" , "" , "" ,
	0x0A98F2 , "Obj04" , "" , "" ,
	0x0A98F2 , "Obj05" , "" , "" ,
	0x0A98F2 , "Obj06" , "" , "" ,
	0x0A98F2 , "Obj07" , "" , "" ,
	0x0A98F2 , "Obj08" , "" , "" ,
	0x0A98F2 , "Obj09" , "" , "" ,
	0x0A98F2 , "Obj0A" , "" , "" ,
	0x0A98F2 , "Obj0B" , "" , "" ,
	0x0A98F2 , "Obj0C" , "" , "" ,
	0x0A98F2 , "Obj0D" , "" , "" ,
	0x0A98F2 , "Obj0E" , "" , "" ,
	0x0A98F2 , "Obj0F" , "" , "" ,
	0x0A98F2 , "Obj10" , "" , "" ,
	0x0A98F2 , "Obj11" , "" , "" ,
	0x0A98F2 , "Obj12" , "" , "" ,
	0x0A98F2 , "Obj13" , "" , "" ,
	0x0A98F2 , "Obj14" , "" , "" ,
	0x0A98F2 , "Obj15" , "" , "" ,
	0x0A98F2 , "Obj16" , "" , "" ,
	0x0A98F2 , "Obj17" , "" , "" ,
	0x0A98F2 , "Obj18" , "" , "" ,
	0x0A98F2 , "Obj19" , "" , "" ,
	0x0A98F2 , "Obj1A" , "" , "" ,
	0x0A98F2 , "Obj1B" , "" , "" ,
	0x0A98F2 , "Obj1C" , "" , "" ,
	0x0A98F2 , "Obj1D" , "" , "" ,
	0x0A98F2 , "Obj1E" , "" , "" ,
	0x0A9995 , "Obj1F" , "" , "" ,
	0x0A91BC , "?" , "" , "" ,
	0x0A91BF , "Sprite" , "" , "" ,
	0x0A91C2 , "?" , "" , "" ,
	0x0A91C9 , "P-Wait" , "" , "" ,
	0xFFFFFF , "END"
} ;

local AddrPrg8  = 0x42 ;
local AddrPrgA  = 0x42 ;
local AddrPrgCf = 0x0E0000 ;
local DPrgVal8  = 0 ;
local DPrgValA  = 1 ;
local PrgvalMul = 2 ;

local OutTable = {} ;
local DestPos = 0 ;
local SizeOfTable = 0 ;

local NextAddrL = DestTable[1] ;
local NextAddr  = AND(NextAddrL,0xFFFF) ;
local Cycle = 0 ;


--=----
-- ���ׂĂ̖��ߎ��s�Ɋ��荞��
-- TODO: �̈�����ڂ�A�ꊇ�ŏ������Ȃ��H���̑����ʂȏ��������Ȃ��悤�ȍH�v
local function SubFunction()
	local pc = memory.getregister("pc")
	local b1 = memory.readbyte(pc)


	--LoadEnemies
	if (pc == 0xD896 and b1 == 0xA5) then
		ObjectType = {}

	--LoadEnemies_Forward,LoadEnemies_Backward
	elseif (pc == 0xd8f0 or pc == 0xd94d) and b1 == 0xb1 then
		
		local current_room = memory.readbyte(0x07)*256 + memory.readbyte(0x06)
		local RegisterY = memory.getregister("y")
		EnemyAddress = current_room + RegisterY

	--SpawnObject
	elseif pc == 0xd9e7 and b1 == 0x9d then

		local ObjectNumber = memory.readbyte(0x02)
		local RegisterX = memory.getregister("x")
		local array_key = 0x6E0 + RegisterX
		
		ObjectType[array_key] = ObjectNumber
		ObjectAddress[array_key] = EnemyAddress

		NewObjectType = ObjectType
		NewObjectAddress = ObjectAddress
		object_framecount = movie.framecount()
	end



	--NMI�I��
	if pc == 0xd582 then

		if(water_pre_flag == 0)then
			water_pre_flag = 1
		end

	--LoadEnemy Bank�؂�ւ�����
	elseif pc == 0xd89b and b1 == 0xa9 then

		--���O�̃o���N���擾
		enemy_bank = memory.readbyte(0x42)

		if(water_pre_flag == 1)then
			water_pre_flag = 0
			water_pre_instructions = water_pre_temp
			water_pre_temp = 0
			water_pre_frame = movie.framecount()
		end
		
		if(water_next_flag == 0)then
			water_next_flag = 1
		end

	--NMI�J�n
	elseif pc == 0xd4a8 then

		--LoadEnemy Bank�؂�ւ������ɓ��B����O��2�x�ڂ�NMI���������ꍇ�͏�����
		if(water_pre_flag == 1)then
			water_pre_flag = 0
			water_pre_temp = 0
		end

		if(water_next_flag == 1)then
			water_next_flag = 0
			water_next_instructions = water_next_temp
			water_next_temp = 0
			water_next_frame = movie.framecount()
		end

	else

		--�������L�^
		if(water_pre_flag == 1)then

			water_pre_temp = water_pre_temp + 1

		end

		--�������L�^
		if(water_next_flag == 1)then

			water_next_temp = water_next_temp + 1

		end

	end

end

local function MainFunction(add,size)
	SubFunction()

	Cycle = Cycle + 1 ;
	if( add ~= NextAddr ) then
		return ;
	end --if

	local LongAddr ;
	if( add < 0xA000 ) then
		LongAddr = OR( (memory.readbyte( AddrPrg8 )*PrgvalMul+DPrgVal8)*0x10000 , add ) ;
	elseif( add < 0xC000 ) then
		LongAddr = OR( (memory.readbyte( AddrPrgA )*PrgvalMul+DPrgValA)*0x10000 , add ) ;
	elseif( add < 0xE000 ) then
		LongAddr = OR( AddrPrgCf , add ) ;
	else
		LongAddr = OR( AddrPrgCf+0x10000 , add ) ;
	end --if
	
	if( LongAddr ~= NextAddrL ) then
		return ;
	end --if

	local CurOPCycle ;
	CurOPCycle = 1 ;
	OutTable[math.floor(DestPos/4)] = Cycle - CurOPCycle ;
	Cycle = CurOPCycle ;

	DestPos = DestPos + 4 ;
	if( DestTable[DestPos+1] == 0xFFFFFF ) then
		SizeOfTable = math.floor(DestPos/4) ;
		DestPos = 0 ;
	end --if
	NextAddrL = DestTable[DestPos+1] ;
	NextAddr  = AND(NextAddrL,0xFFFF) ;

end --function
memory.registerexec( 0x0000 , 0x10000 , MainFunction ) ;


local function FuncMain()
	local iCnt ;
	local iScX , iScY ;

	iScX = memory.readbyte(0x1B)*256+memory.readbyte(0x1A) ;
	iScY = 0 ;

	for iCnt=0 , 0x1F , 1 do
		local iFlg , iX , iY ;
		iX = memory.readbyte(0x0460+iCnt)*256+memory.readbyte(0x0480+iCnt) ;
		iY = memory.readbyte(0x0600+iCnt) ;
		iX = iX - iScX ;
		iY = iY - iScY ;

		iFlg = memory.readbyte(0x0420+iCnt) ;
		if( iY<0xF8 ) then
			local iT , iPT , iHR , iHP , iDmg ;
			iT  = memory.readbyte(0x0400+iCnt) ;
			iPT = memory.readbyte(0x06E0+iCnt) ;
			if( iT==0xFF )then
				iHR = iPT + 0x83 ;
				iDmg = memory.readbyte(0xFEBD+iPT) ;
			else
				iHR = iT ;
				iDmg = memory.readbyte(0xFEEF+memory.readbyte(0xAC)) ;
				if( iCnt==1 )then
					iDmg = 4 ;
				end --if
			end --if
			iHP = memory.readbyte(0x06C0+iCnt) ;
			
			local iHW , iHH ;
			iHW = memory.readbyte(0xFAE9+iHR) ;
			iHH = memory.readbyte(0xFBB7+iHR) ;


			local instructions = 0
			for cnt=0,SizeOfTable-1,1 do
				local label = DestTable[cnt*4+1+1] ;
				if( label ~= ""  and label~= nil )then
					if(string.sub(label, 0, 3) == "Obj")then
						if(iCnt == tonumber(string.sub(label , 4,5),16))then
						 	instructions = OutTable[(cnt+1)%SizeOfTable]
						end
					end
				end
			end

			if( iCnt<0x10 and iCnt~= 1 ) then
				--RockProc
				if(iCnt == 0)then
					instructions = OutTable[8]
				end

				BOX( iX-iHW , iY-iHH , iX+iHW , iY+iHH , "clear" , "red" ) ;
				TEXT( iX , iY , string.format(
					"%02X\n%d",iT,instructions
				 )) ;
			else
				BOX( iX-iHW , iY-iHH , iX+iHW , iY+iHH , "clear" , "green" ) ;
				TEXT( iX , iY , string.format(
					"%02X\n%d",iPT,instructions
				 )) ;
			end

		end --if
	end --for iCnt
end --function


gui.register(function()
	FuncMain()

	-- X���W�擾
	local RockX  = math.floor((memory.readbyte(0x480)*256+memory.readbyte(0x4A0))/256.0 * 1000)/1000
	-- X�X�s�[�h�擾
	local RockXS = math.floor((memory.readbytesigned(0x4C0)*256+memory.readbyte(0x4E0))/256.0 * 1000)/1000
	-- Y���W�擾
	local RockY  = math.floor((memory.readbyte(0x600)*256+memory.readbyte(0x620))/256.0 * 1000)/1000
	-- Y�X�s�[�h�擾
	local RockYS = math.floor((memory.readbytesigned(0x680)*256+memory.readbyte(0x660))/256.0 * 1000)/1000

	-- ���݂̃o���N�擾
	local current_bank = memory.readbyte(0x42)
	local current_frame = movie.framecount()

	local xadj, yadj = 0, 5
	gui.text(xadj,5+yadj, "X:"..RockX.."("..RockXS..")")
	gui.text(xadj,13+yadj,"Y:"..RockY.."("..RockYS..")")
	gui.text(xadj,21+yadj,"PRE->:"..tostring(water_pre_instructions) .. "(" .. tostring(water_pre_frame) .. ")")
	gui.text(xadj,29+yadj,"NEXT->:"..tostring(water_next_instructions) .. "(" .. tostring(water_next_frame) .. ")")

	--�I�u�W�F�N�g�ԍ��o��
	i=1
	for j,k in pairs(NewObjectType) do
		local outputstr = string.format("[%X]->%X(%x) %df",j,k,NewObjectAddress[j],object_framecount)
		gui.text(xadj,(37+(i*8))+yadj,outputstr)
		i=i+1
	end

	gui.text( 200, 0 , "Wepon:"..OutTable[11],"red") ;
	gui.text( 200, 8 , "Hit>R:"..OutTable[13],"red") ;
	gui.text( 200, 16, "Hit>E:"..OutTable[14],"red") ;

	ty = 24 ;
	tx = 210 ;
	for cnt=0,SizeOfTable-1,1 do
		if( SizeOfTable==0 )then
			break ;
		end --if

		local tmp ;
		local label ;
		tmp = OutTable[(cnt+1)%SizeOfTable] ;
		label = DestTable[cnt*4+1+1] ;
		if( label ~= "" )then
			if(string.sub(label, 0, 3) == "Obj")then
				local ObjectNum = tonumber(string.sub(label , 4,5),16)
				local iCnt = tonumber(string.sub(label , 4,5),16)
				local iY = memory.readbyte(0x0600+iCnt) ;
				local iT  = memory.readbyte(0x0400+iCnt) ;
				local iPT = memory.readbyte(0x06E0+iCnt) ;
				if(iCnt ~= nil and  iY<0xF8 )then
					if(ObjectNum < 0x10)then
						gui.text( tx, ty , string.format("%X:%d",iT,tmp) ,"red") ;
					else
						gui.text( tx, ty , string.format("%X:%d",iPT,tmp) ,"green") ;
					end

					ty = ty + 8 ;
				end
			end
		end --if
	end --for

	if(water_next_instructions == 1)then
		emu.pause()
	end

end)


while true do
	emu.frameadvance()
end
