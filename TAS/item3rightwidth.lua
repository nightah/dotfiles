--�A�C�e��3���̉E�ړ��Z�oLua�����b�N�}���Q

--�����e�L�X�g���擾����
function get_width_str(DefaultWidth,Width,Visible,Arm)
	--�A�C�e��3�������݂���Ƃ�
	if((Visible == 0x86 or Visible == 0xC6) and Arm == 0xB)then
		return string.format(" %03d",Width)
	--���݂��Ȃ��Ƃ�
	else
		return string.format("*%03d",DefaultWidth)
	end
end

--�������擾����
function get_width(DefaultWidth,Width,Visible,Arm)
	--�A�C�e��3�������݂���Ƃ�
	if((Visible == 0x86 or Visible == 0xC6) and Arm == 0xB)then
		return Width
	--���݂��Ȃ��Ƃ�
	else
		return DefaultWidth
	end
end

--�E�q���g���擾����
function get_right(Seed,MaxFrame,Width)
	local RightText = ""
	for i = 0,MaxFrame,1 do
		Seed = Seed + 0x27
		if(Seed > 0xFF)then
			RightText = RightText .. "|"
			Seed = Seed - 0x100
			Width = Width + 2
		else
			RightText = RightText .. "."
			Width = Width + 1
		end
	end
	return string.format("%s %d",RightText,Width)
end


--CSV���o�͂��邩
local output_csv_flag = false

--CSV���o�͂���ő�t���[����
local max_csv_frame = 100

--�V�[�h���Ƃ�max_csv_frame�t���[���̍���CSV���o�͂���
function output_csv(FileName,Seed,DefaultHeight,Height,Visible,Arm)

	local NowHeight = 0

	--�A�C�e��3�������݂���Ƃ�
	if((Visible == 0x82 or Visible == 0xC2) and Arm == 0xB)then
		NowHeight = Height
	--���݂��Ȃ��Ƃ�
	else
		NowHeight = DefaultHeight
	end

	--�o��
	fp = io.open (FileName,"w")

	--�w�b�_
	fp:write(" ,")
	for i= 0,max_csv_frame,1 do
		fp:write(string.format("%d,",i))
	end
	fp:write("\n")

	--�V�[�h���Ƃ̍������o��
	format = ""
	for i = 0,255,1 do
		if(Seed == i)then
			format = "%d!,%s\n"
		else
			format = "%d,%s\n"
		end
		fp:write(string.format(format,i,get_height_csv(NowHeight,i)))
	end

	--����
	fp:close()

	output_csv_flag = false
end

--�V�[�h�ɑΉ�����max_csv_frame�t���[������CSV�e�L�X�g���擾����
function get_width_csv(Width,Seed)
	width_csv = ""
	for i = 0,max_csv_frame,1 do
		Seed = Seed + 0x27
		if(Seed > 0xFF)then
			Seed = Seed - 0x100
			Width = Width + 2
		else
			Width = Width + 1
		end
		if(Width <= 0)then
			break
		end
		width_csv = width_csv .. Width .. ","
	end
	return width_csv
end


--���t���[�����{�^����ۑ����邩
local max_bakinp_frame = 20
--�{�^�������΂炭���������Ă��邩�A�܂��͈�u���������`�F�b�N
function holding_key(inp,bakinp,key)

	if((inp[key] == false or inp[key] == nil) and bakinp[2][key] == true)then
		return true
	end
	for i = 1,max_bakinp_frame,1 do
		if(bakinp[i][key]~=true)then
			return false
		end
	end
	return true
end

--���t���[�����E�q���g��\�����邩
local right_display_frame = 20
--CSV�Z�[�u���̕����\��
local output_msg_frame = false

gui.register(function()

	--���ݑ������̕���
	local Arm = memory.readbyte(0xA9)

	--���ׂẴA�C�e��3���̃f�t�H���g�ƂȂ鍂��
	local DefaultWidth = memory.readbyte(0x4a0)

	--�A�C�e��3���̍���
	local Width = {}
	Width[1] = memory.readbyte(0x464)
	Width[2] = memory.readbyte(0x463)
	Width[3] = memory.readbyte(0x462)

	--�V�[�h
	local Seed = {}
	Seed[1] = memory.readbyte(0x484)
	Seed[2] = memory.readbyte(0x483)
	Seed[3] = memory.readbyte(0x482)

	--����
	local Visible = {}
	Visible[1] = memory.readbyte(0x424)
	Visible[2] = memory.readbyte(0x423)
	Visible[3] = memory.readbyte(0x422)

	--�����Z�o
	local Item3Width = {}
	Item3Width[1] = get_width_str(DefaultWidth,Width[1],Visible[1],Arm)
	Item3Width[2] = get_width_str(DefaultWidth,Width[2],Visible[2],Arm)
	Item3Width[3] = get_width_str(DefaultWidth,Width[3],Visible[3],Arm)

	--�㏸���[���Z�o
	local Item3Move = {}
	Item3Move[1] = get_right(Seed[1],right_display_frame,get_width(DefaultWidth,Width[1],Visible[1],Arm))
	Item3Move[2] = get_right(Seed[2],right_display_frame,get_width(DefaultWidth,Width[2],Visible[2],Arm))
	Item3Move[3] = get_right(Seed[3],right_display_frame,get_width(DefaultWidth,Width[3],Visible[3],Arm))

	--�o��
	gui.text(5,0, string.format("Item3->:Width($464-462) %df",right_display_frame))
	gui.text(5,10, string.format("1st->:%s(%03d) %s",Item3Width[1],Seed[1],Item3Move[1]))
	gui.text(5,20,string.format("2nd->:%s(%03d) %s",Item3Width[2],Seed[2],Item3Move[2]))
	gui.text(5,30,string.format("3rd->:%s(%03d) %s",Item3Width[3],Seed[3],Item3Move[3]))

	--CSV�o��
	if(output_csv_flag == true)then
		output_csv("Item3_1st.csv",Seed[1],DefaultWidth,Width[1],Visible[1],Arm)
		output_csv("Item3_2nd.csv",Seed[2],DefaultWidth,Width[2],Visible[2],Arm)
		output_csv("Item3_3rd.csv",Seed[3],DefaultWidth,Width[3],Visible[3],Arm)
	end

	
	--���͂̎擾
	local inp = input.get()
	local input = inp

	--���͂̃o�b�N�A�b�v�l������
	if(bakinp == nil)then
		bakinp = {}
	end
	for i = 1,max_bakinp_frame,1 do
		if(bakinp[i] == nil)then
			bakinp[i] = {}
		end
	end

	--�{�^���̃o�b�N�A�b�v
	for i = max_bakinp_frame,1,-1 do
		if(i == 1)then
			bakinp[1] = input
		else
			bakinp[i] = bakinp[i-1]
		end
	end


	--S�{�^�����������Ƃ�CSV�o��
	if(inp.S == true and (bakinp.S == nil or bakinp.S == false))then
		output_csv_flag = true
		output_msg_frame = movie.framecount()
	end

	--CSV�o�͂����炵�΂炭�̊ԃ��b�Z�[�W�\��
	if(output_msg_frame ~= false)then
		if(movie.framecount() < (output_msg_frame + 60))then
			gui.text(5,40, "output csv file")
		end
	end

	--P�{�^�����������Ƃ��㏸�q���g�\������
	if(holding_key(inp,bakinp,"P")) then
		right_display_frame = right_display_frame + 1
		if(right_display_frame > 40)then
			right_display_frame = 40
		end
	end
	
	--M�{�^�����������Ƃ��㏸�q���g�\������
	if(holding_key(inp,bakinp,"O"))then
		right_display_frame = right_display_frame - 1
		if(right_display_frame < 0)then
			right_display_frame = 0
		end
	end

	--1stSeed+1
	if(holding_key(inp,bakinp,"Y"))then
		memory.writebyte(0x4c4,memory.readbyte(0x4c4)+0x01)
	end
	--1stSeed-1
	if(holding_key(inp,bakinp,"H"))then
		memory.writebyte(0x4c4,memory.readbyte(0x4c4)-0x01)
	end

	--2ndSeed+1
	if(holding_key(inp,bakinp,"U"))then
		memory.writebyte(0x4c3,memory.readbyte(0x4c3)+0x01)
	end
	--2ndSeed-1
	if(holding_key(inp,bakinp,"J"))then
		memory.writebyte(0x4c3,memory.readbyte(0x4c3)-0x01)
	end

	--3rdSeed+1
	if(holding_key(inp,bakinp,"I"))then
		memory.writebyte(0x4c2,memory.readbyte(0x4c2)+0x01)
	end
	--3rdSeed-1
	if(holding_key(inp,bakinp,"K"))then
		memory.writebyte(0x4c2,memory.readbyte(0x4c2)-0x01)
	end

end)


while true do
	emu.frameadvance()
end