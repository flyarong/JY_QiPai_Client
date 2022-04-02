using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

namespace LuaFramework
{
    public class LuaBehaviourScroll : View
    {
        [NoToLua]
        [HideInInspector]
        public string ab_name = "";             //ab包的名称（通过PanelManager创建时才会被赋值）
        [NoToLua]
        public string luaTableName = "";        //预制体对应的lua脚本名称
        public LuaTable luaTable = null;
        private Dictionary<string, LuaFunction> buttons = new Dictionary<string, LuaFunction>();
        private Dictionary<string, LuaFunction> inputFields = new Dictionary<string, LuaFunction>();

        protected void Awake()
        {
            object[] retVals = Util.CallMethod(luaTableName, "Bind");
            if (retVals != null && retVals.Length == 1)
            {
                luaTable = retVals[0] as LuaTable;
                luaTable["gameObject"] = gameObject;
                luaTable["transform"] = transform;
                luaTable["behaviour"] = this;
            }
            Util.CallMethod(luaTableName, "Awake", luaTable);
        }

        protected void Start()
        {
            Util.CallMethod(luaTableName, "Start", luaTable);
        }
        void ScrollCellIndex(int idx)
        {
            string name = "Cell " + idx.ToString();
            gameObject.name = name;
            Util.CallMethod(luaTableName, "ScrollCellIndex", idx);
        }

        public LuaTable GetLuaTable()
        {
            return luaTable;
        }

        [NoToLua]
        public void SetParams(LuaTable params_table)
        {
            if (params_table == null)
                return;

            luaTable.SetTable("params", params_table);
        }

        /// <summary>
        /// 添加单击事件
        /// </summary>
        public void AddClick(GameObject go, LuaFunction luafunc, LuaTable self = null)
        {
            if (go == null || luafunc == null)
            {
                Debug.LogErrorFormat("AddClick go={0} luafunc={1};", go, luafunc);
                return;
            }
            if (buttons.ContainsKey(go.name))
            {
                buttons.Remove(go.name);
            }
            buttons.Add(go.name, luafunc);
            go.GetComponent<Button>().onClick.AddListener(
                delegate ()
                {
                    if (self != null)
                        luafunc.Call(self, go);
                    else
                        luafunc.Call(luaTable, go);
                }
            );
        }

        /// <summary>
        /// 删除单击事件
        /// </summary>
        /// <param name="go"></param>
        public void RemoveClick(GameObject go)
        {
            if (go == null) return;
            LuaFunction luafunc = null;
            if (buttons.TryGetValue(go.name, out luafunc))
            {
                luafunc.Dispose();
                luafunc = null;
                buttons.Remove(go.name);
            }
        }

        /// <summary>
        /// 清除单击事件
        /// </summary>
        public void ClearClick()
        {
            foreach (var de in buttons)
            {
                if (de.Value != null)
                {
                    de.Value.Dispose();
                }
            }
            buttons.Clear();
        }

        /// <summary>
        /// 添加输入结束事件
        /// </summary>
        public void AddEndEdit(GameObject go, LuaFunction luafunc, LuaTable self = null)
        {
            if (go == null || luafunc == null)
            {
                Debug.LogErrorFormat("AddClick go={0} luafunc={1};", go, luafunc);
                return;
            }
            inputFields.Add(go.name, luafunc);
            go.GetComponent<InputField>().onEndEdit.AddListener(
                delegate
                {
                    if (self != null)
                        luafunc.Call(self, go);
                    else
                        luafunc.Call(luaTable, go);
                }
            );
        }

        /// <summary>
        /// 删除输入结束事件
        /// </summary>
        /// <param name="go"></param>
        public void RemoveEndEdit(GameObject go)
        {
            if (go == null) return;
            LuaFunction luafunc = null;
            if (inputFields.TryGetValue(go.name, out luafunc))
            {
                luafunc.Dispose();
                luafunc = null;
                inputFields.Remove(go.name);
            }
        }


        /// <summary>
        /// 清除输入结束事件
        /// </summary>
        public void ClearEndEdit()
        {
            foreach (var de in inputFields)
            {
                if (de.Value != null)
                {
                    de.Value.Dispose();
                }
            }
            inputFields.Clear();
        }
        //-----------------------------------------------------------------
        protected void OnDestroy()
        {
            ClearClick();
            Util.CallMethod(luaTableName, "OnDestroy", luaTable);

            Util.ClearMemory();
            Debug.Log("~" + name + " was destroy!");

            if (luaTable != null)
                luaTable.Dispose();
        }
    }
}