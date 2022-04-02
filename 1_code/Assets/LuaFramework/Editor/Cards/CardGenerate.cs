using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class CardGenerate
{
    private static Dictionary<string, Sprite> textures = new Dictionary<string, Sprite>();

    [MenuItem("Tools/Prefab/CardsGenerate", false, 200)]
    public static void Generate()
    {
		string prefab_cards_folder = "Assets/Game/normal_ddz_common/Prefab/Cards/";
        string prefab_dzcards_folder = "Assets/Game/normal_ddz_common/Prefab/DzCards/";
		string sprite_folder = "Assets/Game/normal_ddz_common/Image/poker_element";
        string editor_prefab_folder = "Assets/LuaFramework/Editor/Cards/";

        //删除旧的预制体
        string[] old_prefabs = Directory.GetFiles(prefab_cards_folder, "*.*", SearchOption.TopDirectoryOnly);
        foreach (var s in old_prefabs)
        {
            File.Delete(s);
        }
        AssetDatabase.Refresh();

        GameObject CardJQK = AssetDatabase.LoadAssetAtPath(editor_prefab_folder + "CardJQK.prefab", typeof(GameObject)) as GameObject;
        GameObject CardJok = AssetDatabase.LoadAssetAtPath(editor_prefab_folder + "CardJok.prefab", typeof(GameObject)) as GameObject;
        GameObject CardNumber = AssetDatabase.LoadAssetAtPath(editor_prefab_folder + "CardNumber.prefab", typeof(GameObject)) as GameObject;
        GameObject DZCard = AssetDatabase.LoadAssetAtPath(editor_prefab_folder + "DZCard.prefab", typeof(GameObject)) as GameObject;

        textures.Clear();
        string[] sprites_path = Directory.GetFiles(sprite_folder, "*.png", SearchOption.TopDirectoryOnly);
        foreach (var s in sprites_path)
        {
            var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(s);
            textures.Add(sprite.name, sprite);
        }

        GameObject cards = null;
        GameObject dz_cards = null;
        string[] num_array = { "poker_icon_nb", "poker_icon_nb", "poker_icon_nr", "poker_icon_nr" };
        string[] color_array = { "poker_spade", "poker_plum", "poker_block", "poker_heart" };
        string tex_num, tex_min_color, tex_big_color, new_cards_path, new_dzcards_path;
        for (int i = 3; i <= 15; i++)
        {
            for (int j = 0; j < num_array.Length; j++)
            {
                int index = (i - 3) * num_array.Length + j + 1;

                tex_num = num_array[j] + i;
                tex_min_color = color_array[j];
                tex_big_color = color_array[j];
                new_cards_path = string.Format("{0}item_{1}.prefab", prefab_cards_folder, index);

                //创建普通poker
                if (i >= 11 && i <= 13) //J Q K 大图标不一样
                {
                    tex_big_color = tex_big_color + i;
                    cards = PrefabUtility.CreatePrefab(new_cards_path, CardJQK);
                }
                else
                {
                    cards = PrefabUtility.CreatePrefab(new_cards_path, CardNumber);
                }
                FillCard(cards, tex_num, tex_min_color, tex_big_color);
                EditorUtility.SetDirty(cards);

                //创建地主底牌
                new_dzcards_path = string.Format("{0}dz_item_{1}.prefab", prefab_dzcards_folder, index);
                dz_cards = PrefabUtility.CreatePrefab(new_dzcards_path, DZCard);
                FillDZCard(dz_cards, tex_num, tex_min_color);
                EditorUtility.SetDirty(dz_cards);
            }
        }

        CreateJok(prefab_cards_folder, prefab_dzcards_folder, CardJok, DZCard, 53, "poker_icon_joker_b", "poker_icon_joker_b1");  //小鬼
        CreateJok(prefab_cards_folder, prefab_dzcards_folder, CardJok, DZCard, 54, "poker_icon_joker_r", "poker_icon_joker_r1");  //大鬼

        //保存修改
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static void CreateJok(string pcf, string pdzcf, GameObject card_prefab, GameObject dzcard_prefab, int poker_value, string num, string big_color)
    {
        string new_cards_path = string.Format("{0}item_{1}.prefab", pcf, poker_value);
        var card = PrefabUtility.CreatePrefab(new_cards_path, card_prefab);
        FillCard(card, num, "", big_color);
        EditorUtility.SetDirty(card);

        string new_dzcards_path = string.Format("{0}dz_item_{1}.prefab", pdzcf, poker_value);
        var dzcard = PrefabUtility.CreatePrefab(new_dzcards_path, dzcard_prefab);
        FillDZCard(dzcard, num, big_color);
        var img_min_color = dzcard.transform.Find("ImgNum").GetComponent<Image>();
        img_min_color.transform.localScale = new Vector3(0.55f, 0.55f);
        img_min_color.SetNativeSize();
        EditorUtility.SetDirty(dzcard);
    }

    private static void FillCard(GameObject go, string num, string min_color, string big_color)
    {
        Debug.LogFormat("{0} || {1} || {2} || {3}", go.name, num, min_color, big_color);

        if (num != "")
        {
            var img_num = go.transform.Find("Card/ImgNum").GetComponent<Image>();
            img_num.sprite = textures[num];
        }

        if (min_color != "")
        {
            var img_min_color = go.transform.Find("Card/ImgType").GetComponent<Image>();
            img_min_color.sprite = textures[min_color];
        }

        if (big_color != "")
        {
            var img_big_color = go.transform.Find("Card/ImgTypeBig").GetComponent<Image>();
            img_big_color.sprite = textures[big_color];
        }
    }

    private static void FillDZCard(GameObject go, string num, string min_color)
    {
        var img_num = go.transform.Find("ImgNum").GetComponent<Image>();
        img_num.sprite = textures[num];

        var img_min_color = go.transform.Find("ImgColor").GetComponent<Image>();
        img_min_color.sprite = textures[min_color];
    }
}
