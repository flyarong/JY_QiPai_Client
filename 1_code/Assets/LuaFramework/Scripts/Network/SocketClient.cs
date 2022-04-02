using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;
using LuaFramework;
using System.Runtime.InteropServices;

public enum DisType
{
    Exception,
    Disconnect,
}

public class SocketClient
{
    private TcpClient client = null;
    //private NetworkStream outStream = null;
    private MemoryStream memStream;
    private BinaryReader reader;

    private const int MAX_READ = 65*1024;
    private byte[] byteBuffer = new byte[MAX_READ];

    // Use this for initialization
    public SocketClient()
    {
    }

    /// <summary>
    /// 注册代理
    /// </summary>
    public void OnRegister()
    {
        memStream = new MemoryStream();
        reader = new BinaryReader(memStream);
    }

    /// <summary>
    /// 移除代理
    /// </summary>
    public void OnRemove()
    {
        this.Close();
        reader.Close();
        memStream.Close();
    }



    /// <summary>
    /// 主动触发异常断开连接 会发送断线异常消息
    /// </summary>
    public void DestroyConnect()
    {
        OnDisconnected(DisType.Exception, " initiative DestroyConnect ");
    }


    /// <summary>
    /// 连接服务器
    /// </summary>
    void ConnectServer(string _address)
    {
        if(client!=null)
        {
            return;
        }

        try
        {
            string[] arr = _address.Split(':');
            string host = arr[0];
            int port = int.Parse(arr[1]);

			IPAddress[] address = Dns.GetHostAddresses(host);
			if (address.Length == 0)
            {
                Debug.LogError("host invalid");
                return;
            }

			if (address[0].AddressFamily == AddressFamily.InterNetworkV6)
            {
                client = new TcpClient(AddressFamily.InterNetworkV6);
				Debug.Log("[Network] is IPV6 " + _address);
            }
            else
            {
                client = new TcpClient(AddressFamily.InterNetwork);
				Debug.Log("[Network] is IPV4 " + _address);
            }

			client.SendTimeout = 1000;
			client.ReceiveTimeout = 1000;
			client.NoDelay = true;
			Debug.LogFormat("begin connect server:host={0} port={1}", host, port);
			client.BeginConnect(host, port, new AsyncCallback(OnConnect), null);
        }
        catch (Exception e)
        {
            Close();
            Debug.LogError(e.Message);
        }
    }

    /// <summary>
    /// 连接上服务器
    /// </summary>
    void OnConnect(IAsyncResult asr)
    {
        try
        {
            Debug.LogFormat("end connect server");
            //outStream = client.GetStream();
            client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
            NetworkManager.AddEvent(Protocal.Connect, null);
        }
        catch(Exception e)
        {
            OnDisconnected(DisType.Exception, e.Message + "\n" + e.StackTrace);
        }
    }

    /// <summary>
    /// 写数据
    /// </summary>
    void WriteMessage(byte[] message)
    {
        MemoryStream ms = null;
        using (ms = new MemoryStream())
        {
            ms.Position = 0;
            BinaryWriter writer = new BinaryWriter(ms);

            //前2个字节写入消息长度，sproto传输时长度信息都使用大端数据
            ushort msglen = (ushort)message.Length;
            byte[] len_data = System.BitConverter.GetBytes(msglen);    //得到小端字节序数组
            Array.Reverse(len_data);                                   //反转数组转成大端。

            writer.Write(len_data);
            writer.Write(message);
            writer.Flush();
            if (client != null && client.Connected)
            {
                //NetworkStream stream = client.GetStream();
                byte[] payload = ms.ToArray();
                int length = client.Client.Send(payload, payload.Length, SocketFlags.None);
                //client.Client.Send(payload, 0, payload.Length, new AsyncCallback(OnWrite), null);
                //Debug.LogFormat("send message data, len={0}", length);
            }
            else
            {
                Debug.LogError("client.connected----->>false");
            }
        }
    }

    /// <summary>
    /// 读取消息
    /// </summary>
    void OnRead(IAsyncResult asr)
    {
        int bytesRead = 0;
        try
        {
            if (client != null)
            {
                lock (client.GetStream())
                {
                    //读取字节流到缓冲区
                    bytesRead = client.GetStream().EndRead(asr);
                }
                if (bytesRead < 1)
                {
                    //包尺寸有问题，断线处理
                    OnDisconnected(DisType.Disconnect, "bytesRead < 1");
                    return;
                }
                OnReceive(byteBuffer, bytesRead);   //分析数据包内容，抛给逻辑层
                lock (client.GetStream())
                {
                    //分析完，再次监听服务器发过来的新消息
                    Array.Clear(byteBuffer, 0, byteBuffer.Length);   //清空数组
                    client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
                }
            }
        }
        catch (Exception ex)
        {
            //PrintBytes();
            OnDisconnected(DisType.Exception, ex.Message + "\n" + ex.StackTrace);
        }
    }

    /// <summary>
    /// 丢失链接
    /// </summary>
    void OnDisconnected(DisType dis, string msg)
    {
        Close();   //关掉客户端链接
        int protocal = dis == DisType.Exception ?
        Protocal.Exception : Protocal.Disconnect;
        //ByteBuffer buffer = new ByteBuffer();
        //buffer.WriteShort((ushort)protocal);
        NetworkManager.AddEvent(protocal, null);
        Debug.LogError("Connection was closed by the server:>" + msg + " Distype:>" + dis);
    }

    //规定转换起始位置和长度
    public static void ReverseBytes(byte[] bytes, int start, int len)
    {
        int end = start + len - 1;
        byte tmp;
        int i = 0;
        for (int index = start; index < start + len / 2; index++, i++)
        {
            tmp = bytes[end - i];
            bytes[end - i] = bytes[index];
            bytes[index] = tmp;
        }
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    void OnReceive(byte[] bytes, int length)
    {
        DateTime dt = DateTime.Now;
        // Debug.LogFormat("<color=pink>OnReceive time:{0}:{1}</color>",
        //                                 dt.ToLongTimeString().ToString(),
        //                                 dt.Millisecond.ToString());

        memStream.Seek(0, SeekOrigin.End);
        memStream.Write(bytes, 0, length);
        //Reset to beginning
        memStream.Seek(0, SeekOrigin.Begin);
        while (RemainingBytes() > 2)
        {
            //前2个字节消息长度，sproto传输时长度信息都使用大端数据
            ushort temp = reader.ReadUInt16();
            var array = BitConverter.GetBytes(temp);
            Array.Reverse(array);
            ushort messageLen = BitConverter.ToUInt16(array, 0);

            // string str = Util.byteToHexStr(bytes);
            //Debug.LogFormat("OnReceive:length={0} messageLen={1} data={2}", length, messageLen, str);

            if (RemainingBytes() >= messageLen)
            {
                //MemoryStream ms = new MemoryStream();
                //BinaryWriter writer = new BinaryWriter(ms);
                //writer.Write(reader.ReadBytes(messageLen));
                //ms.Seek(0, SeekOrigin.Begin);
                OnReceivedMessage(messageLen);
            }
            else
            {
                //Back up the position two bytes
                memStream.Position = memStream.Position - 2;
                break;
            }
        }
        //Create a new stream with any leftover bytes
        byte[] leftover = reader.ReadBytes((int)RemainingBytes());
        memStream.SetLength(0);     //Clear
        memStream.Write(leftover, 0, leftover.Length);

        dt = DateTime.Now;
        // Debug.LogFormat("<color=pink>ParseOver time:{0}:{1}</color>",
        //                                 dt.ToLongTimeString().ToString(),
        //                                 dt.Millisecond.ToString());
    }

    /// <summary>
    /// 剩余的字节
    /// </summary>
    private long RemainingBytes()
    {
        return memStream.Length - memStream.Position;
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    /// <param name="ms"></param>
    void OnReceivedMessage(MemoryStream ms)
    {
        BinaryReader r = new BinaryReader(ms);
        byte[] message = r.ReadBytes((int)(ms.Length - ms.Position));
        //int msglen = message.Length;

        //var str = Util.byteToHexStr(message);
        //Debug.LogFormat("OnReceivedMessage:msglen={0} data={1}", message.Length, str);

        //ByteBuffer buffer = new ByteBuffer(message);
        //int mainId = buffer.ReadShort();
        NetworkManager.AddEvent(Protocal.Message, message);
    }

    void OnReceivedMessage(ushort len)
    {
        //LuaByteBuffer data = new LuaInterface.LuaByteBuffer(reader.ReadBytes(len));
        //int msglen = message.Length;

        //var str = Util.byteToHexStr(message);
        //Debug.LogFormat("OnReceivedMessage:msglen={0} data={1}", message.Length, str);

        //ByteBuffer buffer = new ByteBuffer(message);
        //int mainId = buffer.ReadShort();
        NetworkManager.AddEvent(Protocal.Message, reader.ReadBytes(len));
    }


    /// <summary>
    /// 会话发送
    /// </summary>
    void SessionSend(byte[] bytes)
    {
        WriteMessage(bytes);
    }

    /// <summary>
    /// 关闭链接
    /// </summary>
    public void Close()
    {
        memStream.SetLength(0);
        if (client != null)
        {
            if (client.Connected)
            {
                client.Close();
            }
            client = null;
        }
    }

    /// <summary>
    /// 发送连接请求
    /// </summary>
    public void SendConnect()
    {
        ConnectServer(AppConst.SocketAddress);
    }

    /// <summary>
    /// 发送消息
    /// </summary>
    public void SendMessage(ByteBuffer buffer)
    {
        SessionSend(buffer.ToBytes());
        buffer.Close();
    }

    public void SendMessage(byte[] bytes)
    {
        SessionSend(bytes);
    }
}
