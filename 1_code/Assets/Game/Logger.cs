using System;
using UnityEngine;

/// <summary>
/// Unity Debug.Log 输出时的回调实现
/// </summary>
public static class LoggerHandler
{
    private static System.IO.StreamWriter writer = null;
    private static bool isDebugBuild = true;

    public static void Init()
    {
        Debug.unityLogger.logEnabled = true;
        Debug.unityLogger.filterLogType = LogType.Log;
        Application.logMessageReceivedThreaded += HandleLog;

        if (isDebugBuild)
        {
            Debug.unityLogger.filterLogType = LogType.Log;
            string path = Application.persistentDataPath + "/unitylog/";
            if (!System.IO.Directory.Exists(path))
            {
                System.IO.Directory.CreateDirectory(path);
            }

            //path += DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss") + ".txt";
            path += "log.txt";
            if (System.IO.File.Exists(path))
            {
                //System.IO.FileInfo file = new System.IO.FileInfo(path);
                //if (file.Length > 1024 * 1024 * 200)
                System.IO.File.Delete(path);
            }
            writer = System.IO.File.AppendText(path);
            writer.WriteLine("========================================启动时间：" + DateTime.Now + "===================================\n");
            Debug.LogWarning("日志路径:" + path);
            writer.Flush();
        }
    }

    public static void CloseStreamWriter()
    {
        if (writer != null)
        {
            writer.Flush();
            writer.Close();
            writer = null;
        }
    }

    private static void HandleLog(string logString, string stackTrace, LogType type)
    {
        LoggerHandler.WriteLog(logString, stackTrace, type);
    }

    private static void WriteLog(string logString, string stackTrace, LogType type)
    {

        if (isDebugBuild)
        {
            string log = string.Format("[{0}][{1}] {2} \n {3} \n",
                                        type.ToString(),
                                        System.DateTime.Now.ToString("HH:mm:ss"),
                                        logString,
                                        stackTrace);

            if (writer != null)
            {
                writer.WriteLine(log);
                writer.Flush();
            }
        }
    }
}