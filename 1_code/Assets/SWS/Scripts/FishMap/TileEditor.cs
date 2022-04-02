#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.IO;

using UnityEngine;
using UnityEditor;

namespace TileEditor
{
    public class HELua : Editor
    {
        private const int BUILDER_CAPACITY = 2000;

        public static string Encode (object lua)
        {
            StringBuilder builder = new StringBuilder (BUILDER_CAPACITY);
            bool success = SerializeValue (lua, builder,-1);
            return (success ? builder.ToString () : null);
        }

        protected static bool SerializeValue(object value, StringBuilder builder, int t)
        {
            bool success = true;
            t = t + 1;
            if (value is string) {
                success = SerializeString ((string)value, builder);
            } else if (value is IDictionary) {
                success = SerializeObject ((IDictionary)value, builder,t);
            } else if (value is IList) {
                success = SerializeArray (value as IList, builder,t);
            } else if ((value is Boolean) && ((Boolean)value == true)) {
                builder.Append ("true");
            } else if ((value is Boolean) && ((Boolean)value == false)) {
                builder.Append ("false");
            } else if (value is ValueType) {
                success = SerializeNumber (Convert.ToDouble (value), builder);
            } else if (value == null) {
                builder.Append ("nil");
            } else {
                success = false;
            }

            return success;
        }

        protected static bool SerializeString(string aString, StringBuilder builder)
        {
            // builder.Append ("\"");

            char[] charArray = aString.ToCharArray ();
            for (int i = 0; i < charArray.Length; i++) {
                char c = charArray [i];
                if (c == '"') {
                    builder.Append ("\\\"");
                } else if (c == '\\') {
                    builder.Append ("\\\\");
                } else if (c == '\b') {
                    builder.Append ("\\b");
                } else if (c == '\f') {
                    builder.Append ("\\f");
                } else if (c == '\n') {
                    builder.Append ("\\n");
                } else if (c == '\r') {
                    builder.Append ("\\r");
                } else if (c == '\t') {
                    builder.Append ("\\t");
                } else {
                    int codepoint = Convert.ToInt32 (c);
                    if ((codepoint >= 32) && (codepoint <= 126)) {
                        builder.Append (c);
                    } else {
                        builder.Append ("\\u" + Convert.ToString (codepoint, 16).PadLeft (4, '0'));
                    }
                }
            }

            // builder.Append ("\"");
            return true;
        }

        protected static bool SerializeObject(IDictionary anObject, StringBuilder builder,int t)
        {
            builder.Append ("{\n");
            for (int i = 0; i < t; i++)
            {
                builder.Append ("\t");
            }
            IDictionaryEnumerator e = anObject.GetEnumerator ();

            bool first = true;
            while (e.MoveNext()) {
                string key = e.Key.ToString ();
                object value = e.Value;

                if (!first) {
                    builder.Append (", ");
                }
                int res;
                if (int.TryParse(key, out res))
                {
                    // key = (res + 1).ToString();
                    if (!first) {
                        builder.Append ("\n");
                        for (int i = 0; i < t; i++)
                        {
                            builder.Append ("\t");
                        }
                    }

                    builder.Append("[");
                    SerializeString (key, builder);
                    builder.Append ("]");  
                }
                else{
                    SerializeString (key, builder);
                }
               
                builder.Append (" = ");
                if (!SerializeValue(value, builder, t)) {
                    return false;
                }

                first = false;
            }
            builder.Append ("\n");
            for (int i = 0; i < t; i++)
            {
                builder.Append ("\t");
            }
            builder.Append ("}");
            return true;
        }

        protected static bool SerializeArray(IList anArray, StringBuilder builder,int t)
        {
            builder.Append ("{");
            bool first = true;
            for (int i = 1; i < anArray.Count + 1; i++) {
                object value = anArray [i - 1];
                if (!first) {
                    builder.Append (", ");
                }
                if (!SerializeValue(value, builder,t)) {
                    return false;
                }
                first = false;
            }
            builder.Append ("}");
            builder.Append ("------------------------");
            return true;
        }

        protected static bool SerializeNumber(Double number, StringBuilder builder)
        {
            builder.Append (Convert.ToString (number, CultureInfo.InvariantCulture));
            return true;
        }
    }
}
#endif