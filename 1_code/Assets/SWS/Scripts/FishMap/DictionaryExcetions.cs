using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class DictionaryExcetions
{
    public static T Get<T>(this Dictionary<string, object> instance, string name)
    {
        return (T)instance[name];
    }

}