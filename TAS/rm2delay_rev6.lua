-- ディレイスクロール支援Lua rev.7
-- ディレイスクロール成功に必要な各種値を表示する

local pre_nmi_instructions = 0              -- 前半NMIの処理数
local end_pre_nmi_instructions = 0          -- 前半NMIの処理数(終了時）
local pre_nmi_record_flag = false           -- 前半NMIを記録するかどうか
local main_instructions = 0                 -- メインルーチンの処理数
local end_main_instructions = 0             -- メインルーチンの処理数(終了時）
local main_record_flag = false              -- メインルーチンを記録するかどうか
local next_nmi_position = 0                 -- 後半NMI後のNMI発生位置
local end_next_nmi_position = 0             -- 後半NMI後のNMI発生位置（終了時）
local next_nmi_record_flag = 0              -- 後半NMIの発生位置を記録するかどうか
local scroll_flag = false                   -- スクロールしたかどうか
local scroll_direction = 0x00               -- スクロール方向
local scroll_judge_flag = false             -- スクロール判定処理起動中かどうか
local nmi_mad_area_flag = false             -- NMIによってYがおかしくなる可能性があるバンク切り替え箇所にいるとき
local nmi_mad_y_record_flag = false         -- NMIによって狂ったYの値を記録するかどうか
local nmi_mad_y = 0                         -- NMIによって狂ったYの値
local sound_code_y = 0                      -- 通常時のサウンドコード
local ret_se_y = 0                          -- サウンドコードの結果生じると予想されるY
local stage_number = 0x00                   -- ステージ番号
local pre_scroll_instructions = 0           -- 前画面スクロールへの処理数
local pre_scroll_flag = false               -- 前画面スクロールへの処理数を記録するか
local next_scroll_instructions = 0          -- 次画面スクロールへの処理数
local next_scroll_flag = false              -- 次画面スクロールへの処理数を記録するか
local current_begin_screen_instrucitons = 0 -- 画面左端決定への処理数
local current_begin_screen_flag = false     -- 画面左端決定への処理数を記録するか

local pre_scroll_position = 0               -- 前画面スクロールへの処理数
local next_scroll_position = 0              -- 次画面スクロールへの処理数
local current_begin_screen_position = 0     -- 画面左端決定への処理数

local pre_scroll = {}
local next_scroll = {}
local current_begin_screen = {}
local pre_framecount = 0
local next_framecount = 0
local current_begin_framecount = 0
local main_framecount = 0

local old_framecount = 0
local new_framecount = 0

-- ステージごとのサウンドコードビットマスクテーブル
local se_bitmask = { -- array[14][32]
	{0x47,0x40,0x4a,0x40,0x20,0x20,0x00,0x88,0x80,0x80,0x80,0x80,0x80,0x04,0x00,0x00,
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- HeatMan
	{0x49,0x40,0x28,0x20,0x00,0x45,0x40,0x40,0x40,0x45,0x40,0x40,0x00,0x00,0x00,0xff,
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- AirMan
	{0x44,0x40,0x20,0x20,0x20,0x80,0x80,0x44,0x40,0x40,0x40,0x22,0x20,0x00,0x40,0x40,
		0x40,0x44,0x40,0x40,0x40,0x40,0x22,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff}, -- WoodMan
	{0x44,0x40,0x40,0x40,0x26,0x24,0x20,0x00,0x80,0x80,0x80,0x80,0x80,0x80,0x41,0x40,
		0x40,0x40,0x40,0x23,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- BubbleMan
	{0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x44,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x22,
		0x20,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- QuickMan
	{0x46,0x40,0x40,0x40,0x40,0x40,0x40,0x24,0x20,0x00,0x40,0x40,0x40,0x25,0x00,0x00,
		0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- FlashMan
	{0x49,0x40,0x28,0x20,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- MetalMan
	{0x80,0x80,0x81,0x80,0x80,0x80,0x81,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x21,0x20,
		0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- CrashMan
	{0x47,0x40,0x4a,0x40,0x20,0x20,0x00,0x88,0x80,0x80,0x80,0x80,0x80,0x04,0x00,0x00,
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- WilyStage1
	{0x49,0x40,0x28,0x20,0x00,0x45,0x40,0x40,0x40,0x45,0x40,0x40,0x00,0x00,0x00,0xff,
		0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- WilyStage2
	{0x44,0x40,0x20,0x20,0x20,0x80,0x80,0x44,0x40,0x40,0x40,0x22,0x20,0x00,0x40,0x40,
		0x40,0x44,0x40,0x40,0x40,0x40,0x22,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff}, -- WilyStage3
	{0x44,0x40,0x40,0x40,0x26,0x24,0x20,0x00,0x80,0x80,0x80,0x80,0x80,0x80,0x41,0x40,
		0x40,0x40,0x40,0x23,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- WilyStage4
	{0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x44,0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x22,
		0x20,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}, -- 8Boss
	{0x46,0x40,0x40,0x40,0x40,0x40,0x40,0x24,0x20,0x00,0x40,0x40,0x40,0x25,0x00,0x00,
		0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff}  -- FinalStage
}


local now_frame	= 0		-- ロード検出のためのフレームカウント(新）
local old_frame	= 0		-- ロード検出のためのフレームカウント(旧）


-- すべての命令実行に割り込み
-- TODO: 領域をしぼる、一括で処理しない？その他無駄な処理をしないような工夫
local function SubFunction()

	local pc = memory.getregister("pc")
	local b1 = memory.readbyte(pc)

	-- スクロールするかどうか
	if pc == 0x8196 and b1 == 0xa5 then

		-- $37を読む
		scroll_direction = memory.readbyte(0x37)

		-- メインルーチン記録終了
		main_record_flag = false
		end_main_instructions = main_instructions

		if scroll_direction > 0x00 then

			scroll_flag = true

			-- スクロール処理数の記録開始
			pre_scroll_flag = true
			next_scroll_flag = true
			current_begin_screen_flag = true
			
			-- C7A1を起点とするので+2
			pre_scroll_position = 2
			next_scroll_position = 2
			current_begin_screen_position = 2

			-- 既に対象となるNMIが発生していた場合
			if next_nmi_position < 0 then
				-- 後半NMIの発生位置記録終了(負方向)
				next_nmi_record_flag = 0
				end_next_nmi_position = next_nmi_position
			else
				-- 後半NMIの発生位置を記録開始する(正方向)
				next_nmi_record_flag = 1
				next_nmi_position = 0
			end
		else

			pre_scroll_position = -1
			next_scroll_position = -1
			current_begin_screen_position = -1
		
			next_nmi_record_flag = 0
			next_nmi_position = 0
		end

	-- ポーズ中
	elseif pc == 0xc0ba then

		main_record_flag = false
		next_nmi_record_flag = 0

	-- スクロールしなかった場合はスクロールしなかったときと同じ処理にする
	elseif pc == 0x82cc then

		scroll_flag = false

	-- NMI開始
	elseif pc == 0xcfed then

		if scroll_direction == 0x00 or not scroll_flag then

			-- 前半NMI記録開始
			pre_nmi_record_flag = true
			pre_nmi_instructions = 0

		end

		if scroll_direction ~= 0x00 then

			-- 後半NMIの発生位置を記録終了する(正方向)
			next_nmi_record_flag = 0
			end_next_nmi_position = next_nmi_position

			if(pre_scroll[pre_framecount] == true)then
				pre_scroll[pre_framecount] = next_nmi_position - pre_scroll_position
			end
			if(next_scroll[next_framecount] == true)then
				next_scroll[next_framecount] = next_nmi_position - next_scroll_position
			end
			if(current_begin_screen[current_begin_framecount] == true)then
				current_begin_screen[current_begin_framecount] = next_nmi_position - current_begin_screen_position
			end

			if next_nmi_position < 0 then
				next_nmi_position = 0
			end

		end

	-- NMI終了
	elseif pc == 0xd0d3 then

		if scroll_direction == 0x00 or not scroll_flag then

			-- メインルーチン中にNMI発生
			if main_record_flag then

				-- 後半NMIの発生位置を記録開始する(負方向）
				next_nmi_record_flag = -1
				next_nmi_position = 0

			end

			-- 前半NMI記録終了
			pre_nmi_record_flag = false
			end_pre_nmi_instructions = pre_nmi_instructions

			if next_nmi_record_flag ~= -1 then

				-- メインルーチン記録開始
				main_record_flag = true
				main_instructions = 0

			end

		end

		if scroll_direction ~= 0x00 then

			-- スクロール処理判定中の特定のエリアでNMI発生
			if scroll_judge_flag then
				if nmi_mad_area_flag then
					nmi_mad_y_record_flag = true
				end
			end
		end

	-- スクロール判定処理開始
	elseif (pc == 0x8286 and b1 == 0x88) or (pc == 0x829c and b1 == 0xa4) or pc == 0x8ee7 then

		scroll_judge_flag = true
		nmi_mad_y_record_flag = false


		-- 前画面スクロール
		if pc == 0x8286 then
			pre_scroll_flag = false
			pre_framecount = movie.framecount()

			if (next_nmi_record_flag == 0) then
				pre_scroll[pre_framecount] = next_nmi_position - pre_scroll_position
			else
				pre_scroll[pre_framecount] = true
			end

		-- 次画面スクロール
		elseif pc == 0x829c then
			next_scroll_flag = false
			next_framecount = movie.framecount()

			if (next_nmi_record_flag == 0) then
				next_scroll[next_framecount] = next_nmi_position - next_scroll_position
			else
				next_scroll[next_framecount] = true
			end

			-- 前画面スクロール判定を通っていない
			if pre_scroll_flag then
				pre_scroll_flag = false
				pre_scroll[pre_framecount] = false
			end

			-- $14決定処理は通らない
			current_begin_screen_flag = false
			current_begin_screen_position = -1
			current_begin_screen[next_framecount] = false

		-- 画面左端決定
		elseif pc == 0x8ee7 then
			current_begin_screen_flag = false
			current_begin_framecount = movie.framecount()

			if (next_nmi_record_flag == 0) then
				current_begin_screen[current_begin_framecount] = next_nmi_position - current_begin_screen_position
			else
				current_begin_screen[current_begin_framecount] = true
			end
			
			-- 次画面スクロール判定は通らない
			next_scroll_flag = false
			next_scroll_position = -1
			next_scroll[next_framecount] = false
		end

	-- スクロール判定処理終了
	elseif pc == 0x828a or (pc == 0x82a1 and b1 == 0x98) or pc == 0x8eec then

		scroll_judge_flag = false

	-- スクロール処理終了後または、死亡の場合
	elseif pc == 0x819d or pc == 0x82c5 then

		-- 前画面スクロール判定を通っていない
		if pre_scroll_flag then
			pre_scroll_flag = false
			pre_scroll_position = -1
		end

		-- 次画面スクロール判定を通っていない
		if next_scroll_flag then
			next_scroll_flag = false
			next_scroll_position = -1
		end

		-- 画面左端決定処理を通っていない
		if current_begin_screen_flag then
			current_begin_screen_flag = false
			current_begin_screen_position = -1
		end

	-- ここでNMIが発生するとYが狂う可能性があるエリア開始
	elseif pc == 0xc006 then

		nmi_mad_area_flag = true

	-- ここでNMIが発生するとYが狂う可能性があるエリア終了
	elseif pc == 0xc019 then

		nmi_mad_area_flag = false

	-- スクロール判定終了
	elseif pc == 0xc7b1 then

		-- 異常が発生したYを記録
		if nmi_mad_y_record_flag then
			nmi_mad_y_record_flag = false
			nmi_mad_y = memory.getregister("y")
		end

	-- サウンドコード出力
	elseif pc == 0xd0c0 then

		-- ステージ番号取得
		stage_number = memory.readbyte(0x2A)

		-- サウンドコード取得
		sound_code_y = memory.getregister("y")

		-- サウンドコードの結果出力されると予想されるY
		ret_se_y = se_bitmask[stage_number+1][sound_code_y+1]

	else

		-- 前半NMI計測
		if pre_nmi_record_flag then
			pre_nmi_instructions = pre_nmi_instructions + 1
		end

		-- メインルーチン計測
		if main_record_flag then
			main_instructions = main_instructions + 1
		end

		-- 後半NMI記録開始(事前発生）
		if next_nmi_record_flag == -1 then
			next_nmi_position = next_nmi_position - 1
		-- 後半NMI記録開始(事後発生）
		elseif next_nmi_record_flag == 1 then
			next_nmi_position = next_nmi_position + 1
		end

		if pre_scroll_flag then
			pre_scroll_position = pre_scroll_position + 1
		end

		if next_scroll_flag then
			next_scroll_position = next_scroll_position + 1
		end
		
		if current_begin_screen_flag then
			current_begin_screen_position = current_begin_screen_position + 1
		end

	end

end




local EmuYFix = -8 ; --エミュレータによるY方向の補正

local function BOX(x1,y1,x2,y2,c1,c2)
	gui.box( x1 , y1+EmuYFix , x2 , y2+EmuYFix , c1 , c2 ) ;
end --function BOX
local function TEXT(x,y,t)
	gui.text( x , y+EmuYFix , t ) ;
end --function TEXT



local DestTable =
{
	0x1ECFED , "NMI" , "" , "" ,
	0x1ED08A , "Audio" , "" , "" ,
	0x1ED0C3 , "-" , "" , "" ,
	0x1C81B3 , "F-Wait" , "" , "" ,
	0x1C8171 , "ItemProc" , "" , "" ,
	0x1C8178 , "SubProc" , "" , "" ,
	0x1C8181 , "SetupWallAttr" , "" , "" ,
	0x1C8184 , "RockProc" , "" , "" ,
	0x1C8187 , "RockWepProc" , "" , "" ,
	0x1C818A , "PlaceObj" , "" , "" ,
	0x1C818D , "BossProc" , "" , "" ,
	0x1C8190 , "ObProc" , "" , "" ,
	0x1C926F , "Obj10" , "" , "" ,
	0x1C926F , "Obj11" , "" , "" ,
	0x1C926F , "Obj12" , "" , "" ,
	0x1C926F , "Obj13" , "" , "" ,
	0x1C926F , "Obj14" , "" , "" ,
	0x1C926F , "Obj15" , "" , "" ,
	0x1C926F , "Obj16" , "" , "" ,
	0x1C926F , "Obj17" , "" , "" ,
	0x1C926F , "Obj18" , "" , "" ,
	0x1C926F , "Obj19" , "" , "" ,
	0x1C926F , "Obj1A" , "" , "" ,
	0x1C926F , "Obj1B" , "" , "" ,
	0x1C926F , "Obj1C" , "" , "" ,
	0x1C926F , "Obj1D" , "" , "" ,
	0x1C926F , "Obj1E" , "" , "" ,
	0x1C926F , "Obj1F" , "" , "" ,
	0x1C92A1 , "-" , "" , "" ,
	0x1C8193 , "Sprite" , "" , "" ,
	0x1C8196 , "RoomScroll" , "" , "" ,
	0x1C81B0 , "P-Wait" , "" , "" ,
	0xFFFFFF , "END"
} ;

local AddrPrg8  = 0x69 ;
local AddrPrgA  = 0x69 ;
local AddrPrgCf = 0x1E0000 ;
local DPrgVal8  = 0 ;
local DPrgValA  = 1 ;
local PrgvalMul = 2 ;

local OutTable = {} ;
local DestPos = 0 ;
local SizeOfTable = 0 ;

local NextAddrL = DestTable[1] ;
local NextAddr  = AND(NextAddrL,0xFFFF) ;
local Cycle = 0 ;


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

	iScX = memory.readbyte(0x20)*256+memory.readbyte(0x1F) ;
	iScY = 0 ;

	local WepCnt = 0
	for iCnt=0 , 0x1F , 1 do
		iFlg = memory.readbyte(0x0420+iCnt) ;
		if( iFlg>=0x80 ) then
			if( iCnt<0x10 and iCnt~= 1 and iCnt~= 0 ) then
				WepCnt = WepCnt + 1
			end
		end
	end


	for iCnt=0 , 0x1F , 1 do
		local iFlg , iX , iY ;
		iX = memory.readbyte(0x0440+iCnt)*256+memory.readbyte(0x0460+iCnt) ;
		iY = memory.readbyte(0x04A0+iCnt) ;
		iX = iX - iScX ;
		iY = iY - iScY ;

		iFlg = memory.readbyte(0x0420+iCnt) ;
		if( iFlg>=0x80 ) then
			local iT , iHP ;
			iT  = memory.readbyte(0x0400+iCnt) ;
			iHP = memory.readbyte(0x06C0+iCnt) ;

			if( iCnt<0x10 and iCnt~= 1 ) then

				--RockProc
				if(iCnt == 0 and OutTable[8]~=nil )then
					iHP = OutTable[8]
				end
				--Wepon
				if(iCnt > 1 and OutTable[9]~=nil)then
					iHP = math.floor(OutTable[9]/WepCnt)
				end

				local iHitSizeX , iHitSizeY ;
				local iTmp ;
				iTmp = memory.readbyte(0x0590+iCnt) ;
				iTmp = memory.readbyte(0xD4DC+iTmp) ;
				iHitSizeX = memory.readbyte(0xD4E1+iTmp)-0xC  + 4 ;
				iHitSizeY = memory.readbyte(0xD581+iTmp)-0x14 + 4 ;
				BOX( iX-iHitSizeX , iY-iHitSizeY , iX+iHitSizeX , iY+iHitSizeY , "clear" , "red" ) ;
				if(iHP ~= nil)then
				TEXT( iX , iY , string.format(
					"%02X\n%d",iT,iHP
				 )) ;
				end
			else
				local iTmp , iHitSizeX , iHitSizeY ;
				iTmp = memory.readbyte(0x06E0+iCnt) ;
				iHitSizeX = math.max(0, memory.readbyte(0xD501+iTmp) - 4 ) ;
				iHitSizeY = math.max(0, memory.readbyte(0xD5A1+iTmp) - 4 ) ;
				BOX( iX-iHitSizeX , iY-iHitSizeY , iX+iHitSizeX , iY+iHitSizeY , "clear" ,  "green" ) ;
				if( iCnt~= 1 )then
				else
					iT = memory.readbyte(0xB3) ;
				end --if

				local instructinos = 0
				for cnt=0,SizeOfTable-1,1 do
					local label = DestTable[cnt*4+1+1] ;
					if( label ~= ""  and label~= nil )then
						if(string.sub(label, 0, 3) == "Obj")then
							if(iCnt == tonumber(string.sub(label , 4,5),16))then
							 	instructinos = OutTable[(cnt+1)%SizeOfTable]
							end
						end
					end
				end

				if(instructinos ~= nil)then
					TEXT( iX , iY , string.format(
						"%02X\n%d\n",iT,instructinos
					 )) ;
				end
			end --if
		end --if
	end --for iCnt
end --function

gui.register(function()

	FuncMain() ;	

	-- X座標取得
	local RockX  = math.floor((memory.readbyte(0x460)*256+memory.readbyte(0x480))/256.0 * 1000)/1000
	-- Xスピード取得
	local RockXS = math.floor((memory.readbytesigned(0x600)*256+memory.readbyte(0x620))/256.0 * 1000)/1000
	-- Y座標取得
	local RockY  = math.floor((memory.readbyte(0x4a0)*256+memory.readbyte(0x4c0))/256.0 * 1000)/1000
	-- Yスピード取得
	local RockYS = math.floor((memory.readbytesigned(0x640)*256+memory.readbyte(0x660))/256.0 * 1000)/1000


	-- PRESCRL決定
	local framecount = pre_framecount
	if(pre_scroll[pre_framecount] == true) then
		framecount = pre_framecount - 1
	else
		framecount = pre_framecount
	end
	if(pre_scroll[framecount] == nil or pre_scroll[framecount] == false) then
		prescrl = "-"
	else
		prescrl = tostring(pre_scroll[framecount]).."("..tostring(framecount).."f)"
	end

	-- NEXTSCRL決定
	framecount = next_framecount
	if(next_scroll[next_framecount] == true) then
		framecount = next_framecount - 1
	else
		framecount = next_framecount
	end
	if(next_scroll[framecount] == nil or next_scroll[framecount] == false) then
		nextscrl = "-"
	else
		nextscrl =tostring(next_scroll[framecount]).."("..tostring(framecount).."f)"
	end

	-- $14SET決定
	framecount = current_begin_framecount
	if(current_begin_screen[current_begin_framecount] == true) then
		framecount = current_begin_framecount - 1
	else
		framecount = current_begin_framecount
	end
	if(current_begin_screen[framecount] == nil or current_begin_screen[framecount] == false) then
		current_set = "-"
	else
		current_set = tostring(current_begin_screen[framecount]).."("..tostring(framecount).."f)"
	end

	local xadj, yadj = 0, 10
	gui.text(xadj,5 +yadj,"X:"..RockX.."("..RockXS..")")
	gui.text(xadj,13+yadj,"Y:"..RockY.."("..RockYS..")")
	gui.text(xadj,21+yadj,"PNMI:"..end_pre_nmi_instructions)
	gui.text(xadj,29+yadj,"MAIN:"..end_main_instructions)
	gui.text(xadj,37+yadj,"Total:"..tostring(end_pre_nmi_instructions + end_main_instructions).."("..movie.framecount().."f)")
	gui.text(xadj,45+yadj,"PRE:"..tostring(prescrl))
	gui.text(xadj,53+yadj,"NEXT:"..tostring(nextscrl))
	gui.text(xadj,61+yadj,"$14:"..tostring(current_set))
	gui.text(xadj,69+yadj,"MadSE:"..string.format("%X", nmi_mad_y))
	gui.text(xadj,77+yadj,"SE:"..string.format("%2X(%2X)", sound_code_y, ret_se_y))

	if(OutTable[8] ~= nil)then
		gui.text(xadj,85+yadj,"ROCK:"..tostring(OutTable[8]))
	end

	if(OutTable[9] ~= nil)then
		gui.text(xadj,93+yadj,"WEPON:"..tostring(OutTable[9]))
	end

	ty = 101 ;
	tx = 0 ;
	for cnt=0,SizeOfTable-1,1 do
		if( SizeOfTable==0 )then
			break ;
		end

		local label = DestTable[cnt*4+1+1] ;
		if( label ~= ""  and label~= nil )then
			local output = ""

			if(string.sub(label, 0, 3) == "Obj")then
				local iCnt = tonumber(string.sub(label , 4,5),16)
				if(iCnt ~= nil)then
					local iFlg = memory.readbyte(0x0420+iCnt);
					if(iFlg >=0x80)then
						iT  = memory.readbyte(0x0400+iCnt) ;
						output = string.format("%X",iT) 

						if(OutTable[(cnt+1)%SizeOfTable] ~= nil) then
							output = output .. ":" .. OutTable[(cnt+1)%SizeOfTable];
						else
							output = output .. ":0";
						end

						gui.text( tx, ty+yadj , output) ;
						ty = ty + 8 ;
					end
				end
			end
		end
	end


end)

while true do
	now_frame = movie.framecount()
	if(old_frame ~= now_frame - 1) then
		pre_scroll = {}
		next_scroll = {}
		current_begin_screen = {}
	end
	emu.frameadvance()
	old_frame = now_frame
end