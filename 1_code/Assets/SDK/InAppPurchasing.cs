using LuaInterface;
using UnityEngine;
using UnityEngine.Purchasing;
using System.Collections.Generic;
using System.Reflection;
using System;
using UnityEngine.UI;
using System.Collections;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;

namespace LuaFramework
{
    public class InAppPurchasing : MonoBehaviour,IStoreListener
    {
        //IAP组件相关的对象，m_Controller里存储着商品信息
        private static IStoreController m_Controller;//存储商品信息
        private static  IAppleExtensions m_AppleExtensions;
    
        private static bool PurchaseAvailable = true;//IAP可用状态
        private static bool InternetAvailable;//是否初始化成功

        private static List<string> purchasIds = new List<string>();
		private static InAppPurchasing _instance;
		public static InAppPurchasing instance
		{
			get{
				if (_instance == null) {
					_instance =  AppFacade.Instance.GetManager<InAppPurchasing>(ManagerName.InAppPurchasing);
				}
                if (_instance == null) 
                {
                    _instance = GameObject.FindObjectOfType<InAppPurchasing>();
                }
                if (_instance == null)
                {
                    _instance =  AppFacade.Instance.AddManager<InAppPurchasing>(ManagerName.InAppPurchasing);
                    if (purchasIds != null || purchasIds.Count > 0)
                    {
                        _instance.InitUnityPurchase(purchasIds);
                    }
                    else
                    {
                        Util.CallMethod("MainLogic", "SetupAppPurchasing");
                    }
                }
				return _instance;
			}
		}

        public Action<string,string> myProcessPurchaseAction; //交易成功回调到lua层

        void Awake()
        {

        }
        public void StartUnityPurchase(List<String> idList)
        {
            if (idList != null)
            {
                purchasIds = idList;
            }
            //如果没有连击网络，关闭IAP功能
            if (Application.internetReachability == NetworkReachability.NotReachable)
            {
                PurchaseAvailable = false;
            }
            else
            {
                PurchaseAvailable = true;
                //如果没有初始化成功
                if (InternetAvailable == false)
                {
                    InitUnityPurchase(idList);//初始化
                }
            }
        }

        public void InitUnityPurchase(List<String> idList)//初始化方法
        {
            var module = StandardPurchasingModule.Instance();//标准采购模块
            var builder = ConfigurationBuilder.Instance(module);//配置模式
            //添加多个ID到builder里，ID命名方式建议字母+数字结尾，比如ShuiJing_1,ShuiJing_2，
            //注意ProductType的类型，Consumable是可以无限购买(比如水晶)，NonConsumable是只能购买一次(比如关卡)，Subscription是每月订阅(比如VIP)
            for (int i = 0; i < idList.Count; i++)
            {
                 builder.AddProduct(idList[i], ProductType.Consumable);
            }

            //开始初始化
            UnityPurchasing.Initialize(this, builder);
			Debug.Log("IAP Begin Initialize");
        }
        public void OnInitialized(IStoreController controller, IExtensionProvider extensions)//初始化成功回调
        {
            m_Controller = controller;
            m_AppleExtensions = extensions.GetExtension<IAppleExtensions>();
            m_AppleExtensions.RegisterPurchaseDeferredListener(OnDeferred);//登记 购买延迟 监听器
            
            //恢复交易 Restoring Transactions
            // extensions.GetExtension<IAppleExtensions> ().RestoreTransactions (result => {
            //     if (result) {
            //         // This does not mean anything was restored,
            //         // merely that the restoration process succeeded.
            //     } else {
            //         // Restoration failed.
            //     }
            // });

            //检查未完成订单
// #if SUBSCRIPTION_MANAGER
        Dictionary<string, string> introductory_info_dict = m_AppleExtensions.GetIntroductoryPriceDictionary();
// #endif
        Debug.Log("Available items:");
        foreach (var item in controller.products.all)
        {
            if (item.availableToPurchase)
            {
                Debug.Log(string.Join(" - ",
                    new[]
                    {
                        item.metadata.localizedTitle,
                        item.metadata.localizedDescription,
                        item.metadata.isoCurrencyCode,
                        item.metadata.localizedPrice.ToString(),
                        item.metadata.localizedPriceString,
                        item.transactionID,
                        item.receipt
                    }));
// #if INTERCEPT_PROMOTIONAL_PURCHASES
//                 // Set all these products to be visible in the user's App Store according to Apple's Promotional IAP feature
//                 // https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/PromotingIn-AppPurchases/PromotingIn-AppPurchases.html
//                 m_AppleExtensions.SetStorePromotionVisibility(item, AppleStorePromotionVisibility.Show);
// #endif

// #if SUBSCRIPTION_MANAGER
                // this is the usage of SubscriptionManager class
                if (item.receipt != null) {
                    if (item.definition.type == ProductType.Subscription) {
                        if (checkIfProductIsAvailableForSubscriptionManager(item.receipt)) {
                            string intro_json = (introductory_info_dict == null || !introductory_info_dict.ContainsKey(item.definition.storeSpecificId)) ? null : introductory_info_dict[item.definition.storeSpecificId];
                            SubscriptionManager p = new SubscriptionManager(item, intro_json);
                            SubscriptionInfo info = p.getSubscriptionInfo();
                            Debug.Log("product id is: " + info.getProductId());
                            Debug.Log("purchase date is: " + info.getPurchaseDate());
                            Debug.Log("subscription next billing date is: " + info.getExpireDate());
                            Debug.Log("is subscribed? " + info.isSubscribed().ToString());
                            Debug.Log("is expired? " + info.isExpired().ToString());
                            Debug.Log("is cancelled? " + info.isCancelled());
                            Debug.Log("product is in free trial peroid? " + info.isFreeTrial());
                            Debug.Log("product is auto renewing? " + info.isAutoRenewing());
                            Debug.Log("subscription remaining valid time until next billing date is: " + info.getRemainingTime());
                            Debug.Log("is this product in introductory price period? " + info.isIntroductoryPricePeriod());
                            Debug.Log("the product introductory localized price is: " + info.getIntroductoryPrice());
                            Debug.Log("the product introductory price period is: " + info.getIntroductoryPricePeriod());
                            Debug.Log("the number of product introductory price period cycles is: " + info.getIntroductoryPricePeriodCycles());
                        } else {
                            Debug.Log("This product is not available for SubscriptionManager class, only products that are purchase by 1.19+ SDK can use this class.");
                        }
                    } else {
                        Debug.Log("the product is not a subscription product");
                    }
                } else {
                    Debug.Log("the product should have a valid receipt");
                }
// #endif
            }
        }
        InternetAvailable = true;//初始化成功
		Debug.Log("IAP OnInitialized OK");
		Debug.Log("IAP 初始化成功");
        }
        public void OnInitializeFailed(InitializationFailureReason error)//初始化失败回调
        {
            InternetAvailable = false;
            if (error == InitializationFailureReason.PurchasingUnavailable)
            {
                LuaHelper.OnPurchasingUnavailable();
                Debug.Log("手机设置了禁止APP内购");
            }
			Debug.Log("IAP OnInitializeFailed:" + error.ToString());
        }
        public void OnPurchaseFailed(Product item, PurchaseFailureReason r)//购买失败回调
        {
            Debug.Log ("IAP失败,失败原因："+r.ToString());
            LuaHelper.OnPurchaseFailed();
        }
    
        public PurchaseProcessingResult ProcessPurchase(PurchaseEventArgs e)//购买成功回调
        {
			Debug.Log ("IAP ProcessPurchase");
            
            if (Application.platform == RuntimePlatform.IPhonePlayer ||
                Application.platform == RuntimePlatform.tvOS) {
                string transactionReceipt = m_AppleExtensions.GetTransactionReceiptForProduct (e.purchasedProduct);
				Debug.Log ("Receipt transaction: " + transactionReceipt);
                //这里的transactionReceipt是 Base64加密后的交易收据，将这个收据发送给远程服务器就会得到订单信息的 Json 数据

                string transactionID = e.purchasedProduct.transactionID;
				Debug.Log ("Receipt transactionID :" + transactionID);
                string definition_id = e.purchasedProduct.definition.id;
                Debug.Log("Receipt definition id :" + definition_id);

				LuaHelper.OnPurchaseCallback (transactionReceipt, transactionID, definition_id);

                //if (InAppPurchasing.instance.myProcessPurchaseAction != null){
                //    InAppPurchasing.instance.myProcessPurchaseAction(transactionReceipt,transactionID);
                //}
            }    

            m_PendingProducts.Add(e.purchasedProduct.definition.id);
            Debug.Log("Delaying confirmation of " + e.purchasedProduct.transactionID + " for severe.");
            return PurchaseProcessingResult.Pending;
        }
    
        private void OnDeferred(Product item)//购买延迟提示
        {
			print("bad net OnDeferred");
            LuaHelper.OnDeferred();
        }
    
        public bool OnPurchaseClicked(string purchasId)//发起购买函数，在你的商品按钮上拖这个方法进入
        {
			Debug.Log ("[Debug] Trace OnPurchaseClicked:" + purchasId);
			if (!InternetAvailable)
				return false;
            //InAppPurchasing.instance.myProcessPurchaseAction = action;
            m_Controller.InitiatePurchase(purchasId);
			return true;
        }


        //丢单问题处理----------------------------------------------------------
        private HashSet<string> m_PendingProducts = new HashSet<string>();
        public void ConfirmPendingPurchaseAfterDelay(Product p)
        {
            Debug.Log("Confirming purchase of " + p.transactionID);
            m_Controller.ConfirmPendingPurchase(p);
            m_PendingProducts.Remove(p.definition.id);
        }

        public void APPSeverConfirmPendingPurchase(string definition_id) {
            Product m_product = m_Controller.products.WithID(definition_id);
            //服务器验证
        if (Application.platform == RuntimePlatform.IPhonePlayer ||
            Application.platform == RuntimePlatform.tvOS) {
            //这里的transactionReceipt是 Base64加密后的交易收据，将这个收据发送给远程服务器就会得到订单信息的 Json 数据
            if (m_product != null){
                Debug.Log ("app sever confirm m_product transactionID :" + m_product.transactionID);
                //确认订单完成
                ConfirmPendingPurchaseAfterDelay(m_product);
            }
        }
    }

// #if SUBSCRIPTION_MANAGER
        private bool checkIfProductIsAvailableForSubscriptionManager(string receipt) {
        var receipt_wrapper = (Dictionary<string, object>)MiniJson.JsonDecode(receipt);
        if (!receipt_wrapper.ContainsKey("Store") || !receipt_wrapper.ContainsKey("Payload")) {
            Debug.Log("The product receipt does not contain enough information");
            return false;
        }
        var store = (string)receipt_wrapper ["Store"];
        var payload = (string)receipt_wrapper ["Payload"];

        if (payload != null ) {
            switch (store) {
            case GooglePlay.Name:
                {
                    var payload_wrapper = (Dictionary<string, object>)MiniJson.JsonDecode(payload);
                    if (!payload_wrapper.ContainsKey("json")) {
                        Debug.Log("The product receipt does not contain enough information, the 'json' field is missing");
                        return false;
                    }
                    var original_json_payload_wrapper = (Dictionary<string, object>)MiniJson.JsonDecode((string)payload_wrapper["json"]);
                    if (original_json_payload_wrapper == null || !original_json_payload_wrapper.ContainsKey("developerPayload")) {
                        Debug.Log("The product receipt does not contain enough information, the 'developerPayload' field is missing");
                        return false;
                    }
                    var developerPayloadJSON = (string)original_json_payload_wrapper["developerPayload"];
                    var developerPayload_wrapper = (Dictionary<string, object>)MiniJson.JsonDecode(developerPayloadJSON);
                    if (developerPayload_wrapper == null || !developerPayload_wrapper.ContainsKey("is_free_trial") || !developerPayload_wrapper.ContainsKey("has_introductory_price_trial")) {
                        Debug.Log("The product receipt does not contain enough information, the product is not purchased using 1.19 or later");
                        return false;
                    }
                    return true;
                }
            case AppleAppStore.Name:
            case AmazonApps.Name:
            case MacAppStore.Name:
                {
                    return true;
                }
            default:
                {
                    return false;
                }
            }
        }
        return false;
    }
// #endif
    }
}