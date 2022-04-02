ext_require_audio("Game.game_EliminateCS.Lua.audio_csxxl_config","csxxl")
EliminateCSLogic = {}
package.loaded["Game.game_EliminateCS.Lua.eliminate_cs_algorithm"] = nil
require "Game.game_EliminateCS.Lua.eliminate_cs_algorithm"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSModel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSModel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSGamePanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSGamePanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSObjManager"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSObjManager"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSAnimManager"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSAnimManager"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSPartManager"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSPartManager"

package.loaded["Game.game_EliminateCS.Lua.EliminateCSDesPrefab"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSDesPrefab"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSMoneyPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSMoneyPanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSHelpPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSHelpPanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSButtonPrefab"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSButtonPrefab"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSClearPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSClearPanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSInfoPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSInfoPanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSProgPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSProgPanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSZDGamePanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSZDGamePanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSZPGamePanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSZPGamePanel"
package.loaded["Game.game_EliminateCS.Lua.EliminateCSZiPanel"] = nil
require "Game.game_EliminateCS.Lua.EliminateCSZiPanel"

local M = EliminateCSLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateCSGamePanel",
}
local cur_panel

local updateDt = 1
local update
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "eliminate_jh"
--构建正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_xxl_caishen_enter_game_response"] = M.xxl_caishen_enter_game_response
    lister["model_xxl_caishen_quit_game_response"] = M.xxl_caishen_quit_game_response
    lister["model_xxl_caishen_all_info"] = M.xxl_caishen_all_info
    lister["model_xxl_caishen_all_info_error"] = M.xxl_caishen_all_info_error

    lister["ReConnecteServerSucceed"] = M.on_reconnect_msg
    lister["DisconnectServerConnect"] = M.on_network_error_msg

    lister["EnterForeGround"] = M.on_backgroundReturn_msg
    lister["EnterBackGround"] = M.on_background_msg
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

local function SendRequestAllInfo(data)
    if EliminateCSModel.data and EliminateCSModel.data.model_status == EliminateCSModel.Model_Status.gameover then
        M.xxl_caishen_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateCSModel.data.limitDealMsg = {xxl_caishen_all_info_response = true}
        if M.is_test then
            local data = M.GetTestData()
            Event.Brocast("xxl_caishen_all_info_response","xxl_caishen_all_info_response",data)
        else
            Network.SendRequest("xxl_caishen_all_info",nil,"正在请求数据")
        end
    end
end

function M.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end
function M.clearViewMsgRegister(registerName)
    dump(debug.traceback(  ), "<color=red>移除监听</color>")
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function M.change_panel(panelName)
    dump(panelName, "<color=yellow>change_panel</color>")
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end

    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == panelNameMap.hall then
            MainLogic.ExitGame()
            --GameManager.GotoUI({gotoui = "game_MiniGame"})
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = EliminateCSGamePanel.Create()}
        end
    end
end

function M.xxl_caishen_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_caishen_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_caishen_all_info()
    --取消限制消息
    EliminateCSModel.data.limitDealMsg = nil
    dump(EliminateCSModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateCSModel.data.model_status == nil or EliminateCSModel.data.model_status == EliminateCSModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateCSModel.data.model_status == EliminateCSModel.Model_Status.gaming then
        --游戏界面
        go_to = panelNameMap.game
    end
    
    if go_to then
        M.change_panel(go_to)
    end
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end

--消息错误，回到大厅
function M.xxl_caishen_all_info_error()
    M.change_panel(panelNameMap.hall)
end

--断线重连相关**************
--状态错误处理
function M.eliminate_status_error_msg()
    --断开view model
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo("status_error")
    EliminateCSGamePanel.ExitTimer()
end
--游戏后台重进入消息
function M.on_backgroundReturn_msg()
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo("backgroundReturn")
end
--游戏后台消息
function M.on_background_msg()
    cancelViewMsgRegister()
    EliminateCSGamePanel.ExitTimer()
end
--游戏网络破损消息
function M.on_network_error_msg()
    cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function M.on_network_repair_msg()
end
--游戏网络状态差
function M.on_network_poor_msg()
end
--游戏重新连接消息
function M.on_reconnect_msg()
    --请求ALL数据
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    SendRequestAllInfo("reconnect")
end

--断线重连相关**************
function M.Update()
    
end

--初始化
function M.Init(isNotSendAllInfo)

    --初始化model
    local model = EliminateCSModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateCSObjManager.Init()
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    M.change_panel(panelNameMap.game)
    --请求ALL数据
    if not isNotSendAllInfo then
        SendRequestAllInfo("Init")
    end
end

function M.Exit()
    update:Stop()
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    EliminateCSModel.Exit()
end

M.is_test_state = false
M.xc_state = EliminateCSModel.xc_state.nor

M.is_test = false
function M.GetTestData()
    local data =  {
        --[[
        result = 0,
        type = "nor",
        --断线重连
        total_jindan_xiaochu_value_one={
            [1]=9600,
            [2]=3600,
            [3]=3600,
            [4]=3600,
            [5]=3600,
          },
          zadan_item_vec={
            [1]=1,
            [2]=2,
            [3]=3,
            [4]=1,
            [5]=3,
            [6]=1,
          },
          sky_girl_extra_rate=330,
          tnsh_all_data={
            all_money=396000,
            xc_data="1352223431125315224115413221315112313232325132511552222322135352532242415242352232121512535152511235242323313422324432143522522415255211553453325414115524322042342100225135005142220022242300102000002020000030", 
            change_data="3230555525401353031022231540512244300151344005532423144213333231145122310125142303100301110402052143231511113132151313131151523312051020012141440311142112001342310045433400000013243522213233410502100001312231034244341211211201512431022531001224425051004151000355430221000204431402223343130141142100134133100123113100152250323111512100032200140322204213300003213053534131444145141241451221200440100105124112103230222003101221012125351005433310030533241311022315310204425312041355230532304132141321313421302321153402152355424103022002313310332313213535111210121521302142024132404101022153123132333512225101412224031023423423513221314343444241",            
            all_rate=330,
          },
          all_jindan_value=17528400,
          sky_girl_type=1,
          xc_data="6213355366222313666611136313366563212561232625516611255266112351632213341322366153225111512354115424144142244411214231442515220423633600616255006135350016405100665050006620200012401000130000002000000010000000200000003000000030000000300000006000000010000000100000001000000050000000300000003000000030000000300000003000000030000000100000001000000010000000200000003000000020000000",          
          jindan_word_vec={
            [1]=3,
            [2]=2,
            [3]=4,
            [4]=2,
            [5]=1,
          },
          all_money=921600,
          all_rate=800,
        index = 6,
        --]]

        all_jindan_value               = 144770,
        all_money                      = 5616000,
        all_rate                       = 600,
        jindan_word_vec = {
            [1] = 2,
            [2] = 2,
            [3] = 4,
            [4] = 1,
            [5] = 3,
        },
        result                         = 0,
        sky_girl_extra_rate            = 350,
        sky_girl_type                  = 3,
        tnsh_all_data = {
            all_money   = 3360000,
            all_rate    = 350,
            change_data = "2352244312001333245044203100313013502320222031402100003212000523551111211233151523451110312211101521513021221415342153242313313111111110254311123202322220002315120100113010434203021214300221212110001113104211213011013210245100002243000022202320242112300005",
            xc_data     = "452343325311451224312511325144514311552143114251114444123133311311121353311321431135114422551311514331322335141534554553501141420013211200514423001111110011322200121111005322020011100100322002001110000032000000510000002200000030000000200000",
        },         
        total_jindan_xiaochu_value_one =  {
            [1] = 28800,
            [2] = 28800,
            [3] = 28800,
            [4] = 28800,
            [5] = 28800,
        },
        type                           = "nor",
        xc_data                        = "554344415561224461556543662265246326511123362311111333221122312661233253361136302146221045312140121112200046122000421220006412200024131000636000006610000064600000245000001050000050200000203000001020000000100000005000000060000000200000002000000020000000200000005000",
        zadan_item_vec = {
            [1] = 3,
            [2] = 3,
            [3] = 2,
            [4] = 1,
            [5] = 1,
            [6] = 3,
        }
    }
    return data
end

function M.GetTestDataNor()
    local data =  {
        --正常开奖
        -- result = 0,
        -- all_money = 7500,
        -- all_rate=750,
        -- all_jindan_value = 23040000,
        -- xc_data="115511111115166116666666141321163611414234256242522543345115434551124512134141121621351033643330446236104442134051656440546560605025304030113010304350603011502010135000101120001011200040151000402320004031200060502000600010002000300060001000400030003000100060001000400010003000300030005000",
        -- jindan_word_vec={2,1,4,3},
        -- total_jindan_xiaochu_value_one={70,30,30,30},
        -- zadan_item_vec={2,1,2,1,3,2},
        -- sky_girl_type=2,
        -- sky_girl_extra_rate=310,
        -- tnsh_all_data={
        --     all_money = 3000,
        --     all_rate=310,
        --     xc_data="1332121211521442535541111225511513153544112111215142311241113111533521433211525334354512341545321511555241145331153154151252313132214522141515152531133441543433221113542323411304151225052131450102511203031324040425350001315100024202000113040005240100003002000050030000100500002001000010020000200300000004",
        --     change_data="0400010000400050040053214325022153250230420000000424302102222005000214034503230000000305321231032104231210031131211234453123225052211215014412423345541340214342314314505410344123310012443434454152412314022231231001313110151114010140251214520125533100251432524003133320013414010043211121041213403531012102220432032413151040414152210212004013240143012100001032130004400134244403110003150424354203144122114430003010100003101000032010030551110200312514130252315210053144212131222210001122204254553045335453432513332420231130003112124123105050000005000020500000052001010022001005320100022000222000520220300502500000010000000110400011040450303000333002020300052205000003500040330440003100300510030350510000050000050053004040300404000003411010300010000000000002203005020303000500000000500005555000005555005005300000044400500040005504404045005055403000544400050000000153000050500040050000000000104030010000002000234000030450100000422103004000100000200001000240102222020052322005023232055111001020002000020200000000000000000000220220",
        -- },
        ----
        -- total_jindan_xiaochu_value_one={
        --     [1]=3600,
        --     [2]=3600,
        --     [3]=3600,
        --     [4]=3600,
        --     [5]=3600,
        --     [6]=3600,
        --   },
        --   zadan_item_vec={
        --     [1]=2,
        --     [2]=3,
        --     [3]=3,
        --     [4]=2,
        --     [5]=3,
        --   },
        --   sky_girl_extra_rate=180,
        --   tnsh_all_data={
        --     change_data="1233343321330044021300150000003404443244033144230241124102112124030441420130150104134413000551320222412104200312043000110123222151053403250223021112521441500021015110023212212032341012221241413221210434511201211134150452415220213133000214553224225403432121",
        --     all_money=216000,
        --     all_rate=180,
        --     xc_data="3251535555212255153422511331114213535515112233251153323525535332142211231123412212111323355423233431131011125430311133301221233051333200125553005411110031252400123131004342420055151300112120002233300043045000110110002203200031053000530100001102000022040000350100004002000010030000200500003001000050020000100400002000000030000000400000001000000020000000300000005000000010000000200000003000000040000000",
        --   },
        --   all_jindan_value=23040000,
        --   sky_girl_type=3,
        --   xc_data="6622336411266364613663641552331123323131166225331166255162336111141543341631432312124211106663130026463400031110000611100002410000010600000101000005040000000500",
        --   jindan_word_vec={
        --     [1]=3,
        --     [2]=4,
        --     [3]=3,
        --     [4]=1,
        --     [5]=3,
        --     [6]=2,
        --   },
        --   all_money=360000,
        --   all_rate=300,
        --   result=0,

        --天女散花，掉落花瓣后没有可消的但还有花瓣要掉落
        -- total_jindan_xiaochu_value_one={
        --     [1]=9600,
        --     [2]=3600,
        --     [3]=3600,
        --     [4]=3600,
        --     [5]=3600,
        --   },
        --   zadan_item_vec={
        --     [1]=1,
        --     [2]=2,
        --     [3]=3,
        --     [4]=1,
        --     [5]=3,
        --     [6]=1,
        --   },
        --   sky_girl_extra_rate=330,
        --   tnsh_all_data={
        --     all_money=396000,
        --     xc_data="1352223431125315224115413221315112313232325132511552222322135352532242415242352232121512535152511235242323313422324432143522522415255211553453325414115524322042342100225135005142220022242300102000002020000030", 
        --     change_data="3230555525401353031022231540512244300151344005532423144213333231145122310125142303100301110402052143231511113132151313131151523312051020012141440311142112001342310045433400000013243522213233410502100001312231034244341211211201512431022531001224425051004151000355430221000204431402223343130141142100134133100123113100152250323111512100032200140322204213300003213053534131444145141241451221200440100105124112103230222003101221012125351005433310030533241311022315310204425312041355230532304132141321313421302321153402152355424103022002313310332313213535111210121521302142024132404101022153123132333512225101412224031023423423513221314343444241",            
        --     all_rate=330,
        --   },
        --   all_jindan_value=17528400,
        --   sky_girl_type=1,
        --   xc_data="6213355366222313666611136313366563212561232625516611255266112351632213341322366153225111512354115424144142244411214231442515220423633600616255006135350016405100665050006620200012401000130000002000000010000000200000003000000030000000300000006000000010000000100000001000000050000000300000003000000030000000300000003000000030000000100000001000000010000000200000003000000020000000",          
        --   jindan_word_vec={
        --     [1]=3,
        --     [2]=2,
        --     [3]=4,
        --     [4]=2,
        --     [5]=1,
        --   },
        --   all_money=921600,
        --   all_rate=800,
        --   result=0,

        -- all_money=64800,
        -- zadan_item_vec={
        -- },
        -- sky_girl_extra_rate=0,
        -- all_jindan_value=16154400,
        -- tnsh_all_data={
        -- },
        -- xc_data="2111163351135212134113666411113611121123111123215165141111111261333513011133500111234001042110020310200100000001",
        -- jindan_word_vec={
        -- },
        -- sky_girl_type=0,
        -- result=0,
        -- all_rate=54,

            --  all_jindan_value               = 480,
            --  all_money                      = 3870,
            --  all_rate                       = 400,
            --  jindan_word_vec = {
            --      [1] = 1,
            --      [2] = 3,
            --      [3] = 2,
            --      [4] = 4,
            --  },
            --  result                         = 0,
            --  sky_girl_extra_rate            = 310,
            --  sky_girl_type                  = 3,
            --  tnsh_all_data = {
            --      all_money   = 3100,
            --      all_rate    = 310,
            --      change_data = "0201131405224125021212350221413300041303330352122203342142033132500021235313153132313212112321111412313100001120141342312330132025121202453121244523121402023144050002540210253225300013510003221352333431333135111313101414333235225140120001550000000153435004",
            --      xc_data     = "1215541111515353121435221351225111122135225143223153142335522142215213113253221324255121454311414221211333511551412132153222112213332213115511233231220110540102401100010022000200110001003000000010000000100000",
            --  },
            --  total_jindan_extra_rate        = 13,
            --  total_jindan_xiaochu_value_one = {
            --      [1] = 30,
            --      [2] = 40,
            --      [3] = 30,
            --      [4] = 30,
            --  },
            --  xc_data                        = "366642523145136162453362651132612111616123256111133362323365122201621215014211210412224101064121050653210003151600002336000021110000003600000031000000130000001300000010000000100000001000000010000000100000001000000010000000400000005000000020",
            --  zadan_item_vec = {
            --      [1] = 1,
            --      [2] = 3,
            --      [3] = 3,
            --      [4] = 2,
            --      [5] = 2,
            --      [6] = 3,
            --  }

                 all_jindan_value               = 988800,
                 all_money                      = 6038400,
                 all_rate                       = 650,
                 jindan_word_vec = {
                     [1] = 3,
                     [2] = 4,
                     [3] = 1,
                     [4] = 2,
                     [5] = 4,
                 },
                 result                         = 0,
                 sky_girl_extra_rate            = 300,
                 sky_girl_type                  = 3,
                 tnsh_all_data = {
                     all_money   = 2880000,
                     all_rate    = 300,
                     change_data = "3231200023130000140000000102345020004030020000005413000223214025444435003030445113450214441401511140204521403004424020011532230112311124231152421232142553212013330250242304102024023130152321203041313112121312403121212112341255241231434323122524142120003112",
                     xc_data     = "135135555343111114222333213411431333121325322223141422251331524321115531553145154333123551143321542553210515332301115145011143110125034301120311035005040150050005100200040005000000010000000200",
                 },
                 total_jindan_extra_rate        = 21,
                 total_jindan_xiaochu_value_one = {
                     [1] = 48000,
                     [2] = 28800,
                     [3] = 67200,
                     [4] = 28800,
                     [5] = 28800,
                 },
                 xc_data                        = "666664436163251161336511112433111344116416664366665343663642221531236313112526131112561321251635220116312501565125040610110001301200032011000520010001100100016000000200",
                 zadan_item_vec = {
                     [1] = 2,
                     [2] = 3,
                     [3] = 1,
                     [4] = 3,
                     [5] = 1,
                     [6] = 3,
                 }

    }
    return data
end

function M.GetTestDataZP()
    local data =  {
        result = 0,
        --转盘开奖
        index = 6,
        all_money = 3000,
        all_rate=310,
        all_jindan_value = 23040000,
        xc_data="1332121211521442535541111225511513153544112111215142311241113111533521433211525334354512341545321511555241145331153154151252313132214522141515152531133441543433221113542323411304151225052131450102511203031324040425350001315100024202000113040005240100003002000050030000100500002001000010020000200300000004",
        change_data="0400010000400050040053214325022153250230420000000424302102222005000214034503230000000305321231032104231210031131211234453123225052211215014412423345541340214342314314505410344123310012443434454152412314022231231001313110151114010140251214520125533100251432524003133320013414010043211121041213403531012102220432032413151040414152210212004013240143012100001032130004400134244403110003150424354203144122114430003010100003101000032010030551110200312514130252315210053144212131222210001122204254553045335453432513332420231130003112124123105050000005000020500000052001010022001005320100022000222000520220300502500000010000000110400011040450303000333002020300052205000003500040330440003100300510030350510000050000050053004040300404000003411010300010000000000002203005020303000500000000500005555000005555005005300000044400500040005504404045005055403000544400050000000153000050500040050000000000104030010000002000234000030450100000422103004000100000200001000240102222020052322005023232055111001020002000020200000000000000000000220220",
}
    return data
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("xxl_caishen_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            DOTweenManager.KillAllStopTween()
            if not call then
                M.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return M
