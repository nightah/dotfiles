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

--=----
-- ���ׂĂ̖��ߎ��s�Ɋ��荞��
-- TODO: �̈�����ڂ�A�ꊇ�ŏ������Ȃ��H���̑����ʂȏ��������Ȃ��悤�ȍH�v
memory.registerexec(0x8000, 0x8000, function(address)

	local pc = address -- memory.getregister("pc")
	local b1 = memory.readbyte(pc)

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

end)

gui.register(function()
	
	-- X���W�擾
	local RockX  = math.floor((memory.readbyte(0x480)*256+memory.readbyte(0x4A0))/256.0 * 1000)/1000
	-- X�X�s�[�h�擾
	local RockXS = math.floor((memory.readbytesigned(0x4F9)*256+memory.readbyte(0x510))/256.0 * 1000)/1000
	-- Y���W�擾
	local RockY  = math.floor((memory.readbyte(0x600)*256+memory.readbyte(0x620))/256.0 * 1000)/1000
	-- Y�X�s�[�h�擾
	local RockYS = math.floor((memory.readbytesigned(0x680)*256+memory.readbyte(0x660))/256.0 * 1000)/1000

	-- ���݂̃o���N�擾
	local current_bank = memory.readbyte(0x42)
	local current_frame = movie.framecount()

	local xadj, yadj = 0, 5
	gui.text(5+xadj,5+yadj, "X      ->:"..RockX.."("..RockXS..")")
	gui.text(5+xadj,15+yadj,"Y      ->:"..RockY.."("..RockYS..")")
	-- �s���\��
	gui.text(5+xadj,25+yadj,"PRE    ->:"..tostring(water_pre_instructions) .. "(" .. tostring(water_pre_frame) .. ")")
	gui.text(5+xadj,35+yadj,"NEXT   ->:"..tostring(water_next_instructions) .. "(" .. tostring(water_next_frame) .. ")")
	gui.text(5+xadj,45+yadj,"ENMYBNK->:"..tostring(enemy_bank).."(" .. tostring(water_pre_frame) .. ")")
	gui.text(5+xadj,55+yadj,"CRNTBNK->:"..tostring(current_bank).."(" .. tostring(current_frame) .. ")")
end)



while true do
	emu.frameadvance()
end
