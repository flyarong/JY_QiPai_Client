-- 创建时间:2021-01-18
return {
    tasks = 
    {
        [1] =
        {
            index = 1,
            content = "每邀请1位好友下载并登陆游戏",
            reward_txt = "抽奖券*3",
            reward_icon = "xnsmt_img_cjq",
            task_id = 21675,
        },
        [2] =
        {
            index = 2,
            content = "完成推广问卷考核",
            reward_txt = "抽奖券*3",
            reward_icon = "xnsmt_img_cjq",
            task_id = 21674,
            is_goto_faq = 1,
        },
        [3] =
        {
            index = 3,
            content = "累计邀请10位好友",
            reward_txt = "抽奖券*3",
            reward_icon = "xnsmt_img_cjq",
            level = 1,
            total = 10,
            task_id = 21676,
        },
        [4] =
        {
            index = 4,
            content = "累计邀请20位好友",
            reward_txt = "抽奖券*5",
            reward_icon = "xnsmt_img_cjq",
            level = 2,
            total = 20,
            task_id = 21676,
        },
        [5] =
        {
            index = 5,
            content = "累计邀请35位好友",
            reward_txt = "抽奖券*8",
            reward_icon = "xnsmt_img_cjq",
            level = 3,
            total = 35,
            task_id = 21676,
        },
        [6] =
        {
            index = 6,
            content = "累计邀请50位好友",
            reward_txt = "抽奖券*15",
            reward_icon = "xnsmt_img_cjq",
            level = 4,
            total = 50,
            task_id = 21676,
        },
        [7] =
        {
            index = 7,
            content = "累计邀请75位好友",
            reward_txt = "抽奖券*20",
            reward_icon = "xnsmt_img_cjq",
            level = 5,
            total = 75,
            task_id = 21676,
        },
        [8] =
        {
            index = 8,
            content = "累计邀请100位好友",
            reward_txt = "抽奖券*30",
            reward_icon = "xnsmt_img_cjq",
            level = 6,
            total = 100,
            task_id = 21676,
        },
    },
    lottery_rewards = 
    {
        [1] = 
        {
            index = 1,
            name = "鲸币宝箱",
            icon = "pay_icon_gold9",
            tips = {"鲸币","1000~10万鲸币"},
            award_id = {13141,13149,13157},
            is_real = 0
        },
        [2] = 
        {
            index = 2,
            name = "福卡宝箱",
            icon = "activity_icon_fdx",
            tips = {"福卡","0.1~10福卡"},
            award_id = {13142,13150,13158},
            is_real = 0
        },
        [3] = 
        {
            index = 3,
            name = "茅台碎片",
            icon = "activity_icon_mtsp",
            tips = {"茅台碎片","随机获得1~10个"},
            award_id = {13143,13151,13159},
            is_real = 0
        },
        [4] = 
        {
            index = 4,
            name = "茅台碎片",
            icon = "activity_icon_mtsp",
            tips = {"茅台碎片","随机获得10~50个"},
            award_id = {13144,13152,13160},
            is_real = 0
        },
        [5] = 
        {
            index = 5,
            name = "茅台碎片",
            icon = "activity_icon_mtsp",
            tips = {"茅台碎片","随机获得50~100个"},
            award_id = {13145,13153,13161},
            is_real = 0
        },
        [6] = 
        {
            index = 6,
            name = "30福卡",
            icon = "ad_2znjnk_icon_fk3",
            tips = {"福卡","可在兑换商城购买实物"},
            award_id = {13146,13154,13162},
            is_real = 0
        },
        [7] = 
        {
            index = 7,
            name = "100福卡",
            icon = "ad_2znjnk_icon_fk3",
            tips = {"福卡","可在兑换商城购买实物"},
            award_id = {13147,13155,13163},
            is_real = 0
        },
        [8] = 
        {
            index = 8,
            name = "飞天茅台",
            icon = "activity_icon_gzmt",
            tips = {"茅台酒","飞天茅台"},
            award_id = {13148,13156,13164},
            is_real = 1
        },
    },
    questions = 
    {
        [1] = 
        {
            index = 1,
            content = "1.邀请1位好友，最高可获得多少钱？",
            choose = {"112元","136元","141元"},
            answer = 3,
        },
        [2] = 
        {
            index = 2,
            content = "2.被邀请好友兑换2福卡，我可得多少？",
            choose = {"2元","3元","4元"},
            answer = 2,
        },
        [3] = 
        {
            index = 3,
            content = "3.被邀请好友进入千元赛前96名，我可得多少？",
            choose = {"5元","6元","7元"},
            answer = 1,
        },
        [4] = 
        {
            index = 4,
            content = "4.被邀请好友购买所有全返礼包，我可得多少？",
            choose = {"111元","122元","133元"},
            answer = 3,
        },
        [5] = 
        {
            index = 5,
            content = "5.推广收益可直接提取到什么地方？",
            choose = {"银行卡","微信","支付宝"},
            answer = 3,
        }
    },
    collect_rewards =
    {
        [1] = 
        {
            index = 1,
            collect_num = 10,
            reward = "1万鲸币",
            icon = "pay_icon_gold3",
        },
        [2] = 
        {
            index = 2,
            collect_num = 80,
            reward = "10福卡",
            icon = "ad_2znjnk_icon_fk3",
            tips = {"福卡","可在兑换商城购买实物"}
        },
        [3] = 
        {
            index = 3,
            collect_num = 200,
            reward = "20万鲸币",
            icon = "pay_icon_gold4",
        },
        [4] = 
        {
            index = 4,
            collect_num = 500,
            reward = "50福卡",
            icon = "ad_2znjnk_icon_fk3",
            tips = {"福卡","可在兑换商城购买实物"}
        },
        [5] = 
        {
            index = 5,
            collect_num = 1000,
            reward = "飞天茅台",
            icon = "activity_icon_gzmt",
            tips = {"茅台酒","飞天茅台"}
        },

    }

}