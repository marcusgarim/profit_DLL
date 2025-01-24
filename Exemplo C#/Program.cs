using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Runtime.InteropServices;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

namespace ProfitDLL
{
    #region Struturas para exemplo
    public struct CandleTrade
    {
        public CandleTrade(double close, double vol, double open, double max, double min, int qtd, string asset, DateTime date)
        {
            Close = close;
            Vol = vol;
            Qtd = qtd;
            Asset = asset;
            Date = date;
            Open = open;
            Max = max;
            Min = min;
        }

        public double Close { get; set; }
        public double Vol { get; set; }
        public double Max { get; set; }
        public double Min { get; set; }
        public double Open { get; set; }
        public int Qtd { get; set; }
        public string Asset { get; set; }
        public DateTime Date { get; set; }
    }
    public struct Trade
    {
        public Trade(double price, double vol, int qtd, string asset, string date)
        {
            Price = price;
            Qtd = qtd;
            Asset = asset;
            Date = date;
            Vol = vol;
        }

        public double Price { get; }
        public double Vol { get; }
        public int Qtd { get; }
        public string Asset { get; }
        public string Date { get; }
    }
    #endregion

    partial class DLLConnector
    {
        private const string dll_path = @"ProfitDLL.dll";   // @Preencher com o caminho da DLL

        // TActionType = (atAdd = 0, atEdit = 1, atDelete = 2, atDeleteFrom = 3, atFullBook = 4);
        #region Types
        public struct TGroupOffer
        {
            public int Qtd { get; set; }
            public Int64 OfferID { get; set; }
            public int Agent { get; set; }
            public double Price { get; set; }
            public string Date { get; set; }

            public TGroupOffer(double price, int qtd, int agent, Int64 offerId, string date)
            {
                this.Qtd = qtd;
                this.Price = price;
                this.Agent = agent;
                this.OfferID = offerId;
                this.Date = date;
            }
        };

        public struct TGroupPrice
        {
            public int Qtd { get; set; }
            public int Count { get; set; }
            public double Price { get; set; }

            public TGroupPrice(double price, int count, int qtd)
            {
                this.Qtd = qtd;
                this.Price = price;
                this.Count = count;
            }
        }
        public struct TPosition
        {
            public int CorretoraID;
            public string AccountID;
            public string Titular;
            public string Ticker;
            public int IntradayPosition;
            public double Price;
            public double AvgSellPrice;
            public int SellQtd;
            public double AvgBuyPrice;
            public int BuyQtd;
            public int CustodyD1;
            public int CustodyD2;
            public int CustodyD3;
            public int Blocked;
            public int Pending;
            public int Allocated;
            public int Provisioned;
            public int QtdPosition;
            public int Available;

            public override string ToString()
            {
                return $"Corretora: {CorretoraID}, AccountID: {AccountID}, Titular: {Titular}, Ticker: {Ticker}, IntradayPosition: {IntradayPosition}, Price: {Price}, AvgSellPrice: {AvgSellPrice}, AvgBuyPrice: {AvgBuyPrice}, BuyQtd: {BuyQtd}, SellQtd: {SellQtd}";
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct TAssetID
        {
            [MarshalAs(UnmanagedType.LPWStr)]
            public string Ticker;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string Bolsa;
            public int Feed;
        };
        #endregion

        #region obj garbage KeepAlive
        public static TAssetListCallback _assetListCallback = new TAssetListCallback(AssetListCallback);
        public static TAssetListInfoCallback _assetListInfoCallback = new TAssetListInfoCallback(AssetListInfoCallback);
        public static TAssetListInfoCallbackV2 _assetListInfoCallbackV2 = new TAssetListInfoCallbackV2(AssetListInfoCallbackV2);
        public static TStateCallback _stateCallback = new TStateCallback(StateCallback);
        public static TNewTradeCallback _newTradeCallback = new TNewTradeCallback(NewTradeCallback);
        public static TNewDailyCallback _newDailyCallback = new TNewDailyCallback(NewDailyCallback);
        public static TPriceBookCallback _priceBookCallback = new TPriceBookCallback(PriceBookCallback);
        public static TOfferBookCallback _offerBookCallback = new TOfferBookCallback(OfferBookCallback);
        public static TNewHistoryCallback _newHistoryCallback = new TNewHistoryCallback(NewHistoryCallback);
        public static TProgressCallBack _progressCallBack = new TProgressCallBack(ProgressCallBack);
        public static TNewTinyBookCallBack _newTinyBookCallBack = new TNewTinyBookCallBack(NewTinyBookCallBack);
        public static THistoryCallBack _historyCallBack = new THistoryCallBack(HistoryCallBack);
        public static TAccountCallback _accountCallback = new TAccountCallback(AccountCallback);
        public static TOrderChangeCallBack _orderChangeCallBack = new TOrderChangeCallBack(OrderChangeCallBack);
        public static TOrderChangeCallBackV2 _orderChangeCallBackV2 = new TOrderChangeCallBackV2(OrderChangeCallBackV2);
        public static TChangeStateTickerCallback _changeStateTickerCallback = new TChangeStateTickerCallback(ChangeStateTickerCallback);
        public static TTheoreticalPriceCallback _theoreticalPriceCallback = new TTheoreticalPriceCallback(TheoreticalPriceCallback);
        public static TAdjustHistoryCallbackV2 _adjustHistoryCallbackV2 = new TAdjustHistoryCallbackV2(AdjustHistoryCallbackV2);
        #endregion

        #region variables
        public static Queue<Trade> Traders = new Queue<Trade>();
        private static readonly object TradeLock = new object();

        public static Queue<Trade> HistTraders = new Queue<Trade>();
        private static readonly object HistLock = new object();

        public static List<TGroupPrice> m_lstPriceSell = new List<TGroupPrice>();
        public static List<TGroupPrice> m_lstPriceBuy = new List<TGroupPrice>();

        public static List<TGroupOffer> m_lstOfferSell = new List<TGroupOffer>();
        public static List<TGroupOffer> m_lstOfferBuy = new List<TGroupOffer>();

        public static bool bAtivo = false;
        public static bool bMarketConnected = false;

        static readonly CultureInfo provider = CultureInfo.InvariantCulture;
        #endregion

        #region consts
        private const string dateFormat = "dd/MM/yyyy HH:mm:ss.fff";
        #endregion

        #region Error Codes

        //////////////////////////////////////////////////////////////////////////////
        // Error Codes
        public const int NL_OK = 0x00000000;  // OK
        public const int NL_INTERNAL_ERROR = unchecked((int)0x80000001);  // Internal error
        public const int NL_NOT_INITIALIZED = unchecked((int)0x80000002);  // Not initialized
        public const int NL_INVALID_ARGS = unchecked((int)0x80000003);  // Invalid arguments
        public const int NL_WAITING_SERVER = unchecked((int)0x80000004);  // Aguardando dados do servidor


        #endregion

        #region Delegates

        ////////////////////////////////////////////////////////////////////////////////
        // WARNING: Não utilizar funções da dll dentro do CALLBACK
        ////////////////////////////////////////////////////////////////////////////////
        //Callback do stado das diferentes conexões
        public delegate void TStateCallback(int nResult, int result);
        ////////////////////////////////////////////////////////////////////////////////
        //Callback com informações marketData
        public delegate void TNewTradeCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType, int bIsEdit);
        public delegate void TNewDailyCallback(TAssetID TAssetIDRec, [MarshalAs(UnmanagedType.LPWStr)] string date, double sOpen, double sHigh, double sLow, double sClose, double sVol, double sAjuste, double sMaxLimit, double sMinLimit, double sVolBuyer, double sVolSeller, int nQtd, int nNegocios, int nContratosOpen, int nQtdBuyer, int nQtdSeller, int nNegBuyer, int nNegSeller);
        public delegate void TNewHistoryCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType);
        public delegate void TProgressCallBack(TAssetID assetId, int nProgress);
        public delegate void TNewTinyBookCallBack(TAssetID assetId, double price, int qtd, int side);

        ////////////////////////////////////////////////////////////////////////////////
        //Callback de alteração em ordens

        public delegate void TChangeCotation(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double sPrice);

        public delegate void TAssetListCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strName);

        public delegate void TAdjustHistoryCallbackV2(TAssetID assetId,
            double dValue,
            [MarshalAs(UnmanagedType.LPWStr)] string adjustType,
            [MarshalAs(UnmanagedType.LPWStr)] string strObserv,
            [MarshalAs(UnmanagedType.LPWStr)] string dtAjuste,
            [MarshalAs(UnmanagedType.LPWStr)] string dtDeliber,
            [MarshalAs(UnmanagedType.LPWStr)] string dtPagamento,
            int nFlags,
            double dMult);

        public delegate void TAssetListInfoCallback(
            TAssetID assetId,
            [MarshalAs(UnmanagedType.LPWStr)] string strName,
            [MarshalAs(UnmanagedType.LPWStr)] string strDescription,
            int nMinOrderQtd,
            int nMaxOrderQtd,
            int nLote,
            int stSecurityType,
            int ssSecuritySubType,
            double sMinPriceInc,
            double sContractMultiplier,
            [MarshalAs(UnmanagedType.LPWStr)] string validityDate,
            [MarshalAs(UnmanagedType.LPWStr)] string strISIN);

        public delegate void TAssetListInfoCallbackV2(
            TAssetID assetId,
            [MarshalAs(UnmanagedType.LPWStr)] string strName,
            [MarshalAs(UnmanagedType.LPWStr)] string strDescription,
            int nMinOrderQtd,
            int nMaxOrderQtd,
            int nLote,
            int stSecurityType,
            int ssSecuritySubType,
            double sMinPriceInc,
            double sContractMultiplier,
            [MarshalAs(UnmanagedType.LPWStr)] string validityDate,
            [MarshalAs(UnmanagedType.LPWStr)] string strISIN,
            [MarshalAs(UnmanagedType.LPWStr)] string strSetor,
            [MarshalAs(UnmanagedType.LPWStr)] string strSubSetor,
            [MarshalAs(UnmanagedType.LPWStr)] string strSegmento);

        public delegate void TChangeStateTickerCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strDate, int nState);

        public delegate void TTheoreticalPriceCallback(TAssetID assetId, double dTheoreticalPrice, Int64 nTheoreticalQtd);

        public delegate void THistoryCallBack(TAssetID AssetID, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date);

        public delegate void TOrderChangeCallBack(TAssetID assetId, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date,
            [MarshalAs(UnmanagedType.LPWStr)] string TextMessage);

        public delegate void TOrderChangeCallBackV2(TAssetID assetId, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, int nValidity, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date,
            [MarshalAs(UnmanagedType.LPWStr)] string LastUpdate,
            [MarshalAs(UnmanagedType.LPWStr)] string CloseDate,
            [MarshalAs(UnmanagedType.LPWStr)] string ValidityDate,
            [MarshalAs(UnmanagedType.LPWStr)] string TextMessage);

        ////////////////////////////////////////////////////////////////////////////////
        //Callback com a lista de contas
        public delegate void TAccountCallback(int nCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string CorretoraNomeCompleto,
            [MarshalAs(UnmanagedType.LPWStr)] string AccountID,
            [MarshalAs(UnmanagedType.LPWStr)] string NomeTitular);

        ////////////////////////////////////////////////////////////////////////////////
        //Callback com informações marketData
        public delegate void TPriceBookCallback(TAssetID assetId, int nAction, int nPosition, int Side, int nQtd, int nCount, double sPrice, IntPtr pArraySell, IntPtr pArrayBuy);

        public delegate void TOfferBookCallback(TAssetID assetId, int nAction, int nPosition, int Side, int nQtd, int nAgent, Int64 nOfferID, double sPrice, int bHasPrice, int bHasQtd, int bHasDate, int bHasOfferID, int bHasAgent,
            [MarshalAs(UnmanagedType.LPWStr)] string date,
            IntPtr pArraySell, IntPtr pArrayBuy);

        #endregion

        #region DLL Functions
        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int DLLInitializeMarketLogin(
            [MarshalAs(UnmanagedType.LPWStr)] string activationKey,
            [MarshalAs(UnmanagedType.LPWStr)] string user,
            [MarshalAs(UnmanagedType.LPWStr)] string password,
            TStateCallback stateCallback,
            TNewTradeCallback newTradeCallback,
            TNewDailyCallback newDailyCallback,
            TPriceBookCallback priceBookCallback,
            TOfferBookCallback offerBookCallback,
            TNewHistoryCallback newHistoryCallback,
            TProgressCallBack progressCallBack,
            TNewTinyBookCallBack newTinyBookCallBack);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int DLLInitializeLogin(
            [MarshalAs(UnmanagedType.LPWStr)] string activationKey,
            [MarshalAs(UnmanagedType.LPWStr)] string user,
            [MarshalAs(UnmanagedType.LPWStr)] string password,
            TStateCallback stateCallback,
            THistoryCallBack historyCallBack,
            TOrderChangeCallBack orderChangeCallBack,
            TAccountCallback accountCallback,
            TNewTradeCallback newTradeCallback,
            TNewDailyCallback newDailyCallback,
            TPriceBookCallback priceBookCallback,
            TOfferBookCallback offerBookCallback,
            TNewHistoryCallback newHistoryCallback,
            TProgressCallBack progressCallBack,
            TNewTinyBookCallBack newTinyBookCallBack);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetServerAndPort(
            [MarshalAs(UnmanagedType.LPWStr)] string strServer,
            [MarshalAs(UnmanagedType.LPWStr)] string strPort);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int GetServerClock(
            ref double serverClock,
            ref int nYear, ref int nMonth, ref int nDay, ref int nHour, ref int nMin, ref int nSec, ref int nMilisec);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int GetLastDailyClose(
            [MarshalAs(UnmanagedType.LPWStr)] string strTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string strBolsa,
            ref double dClose,
            int bAdjusted);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern IntPtr GetPosition(
            [MarshalAs(UnmanagedType.LPWStr)] string accountID,
            [MarshalAs(UnmanagedType.LPWStr)] string corretora,
            [MarshalAs(UnmanagedType.LPWStr)] string ticker,
            [MarshalAs(UnmanagedType.LPWStr)] string bolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetChangeCotationCallback(TChangeCotation a_ChangeCotation);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetAssetListCallback(TAssetListCallback AssetListCallback);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetAssetListInfoCallback(TAssetListInfoCallback AssetListInfoCallback);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetAssetListInfoCallbackV2(TAssetListInfoCallbackV2 AssetListInfoCallbackV2);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetChangeStateTickerCallback(TChangeStateTickerCallback a_changeStateTickerCallback);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetTheoreticalPriceCallback(TTheoreticalPriceCallback a_theoreticalPriceCallback);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetAdjustHistoryCallbackV2(TAdjustHistoryCallbackV2 AdjustHistoryCallbackV2);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetOrderChangeCallbackV2(TOrderChangeCallBackV2 OrderChangeCallbackV2);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SetEnabledLogToDebug(int bEnabled);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SubscribeTicker(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int UnsubscribeTicker(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SubscribePriceBook(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int UnsubscribePriceBook(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SubscribeOfferBook(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int UnsubscribeOfferBook(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SubscribeAdjustHistory(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int GetHistoryTrades(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa,
            [MarshalAs(UnmanagedType.LPWStr)] string dtDateStart,
            [MarshalAs(UnmanagedType.LPWStr)] string dtDateEnd);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int FreePointer(IntPtr pointer, int nSize);


        ////////////////////////////////////////////////////////////////////////////////
        // Roteamento
        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern Int64 SendStopBuyOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa,
            double sPrice, double sStopPrice, int nAmount);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern Int64 SendStopSellOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa,
            double sPrice, double sStopPrice, int nAmount);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SendChangeOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcClOrdID,
            double sPrice, int nAmount);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SendCancelOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SendCancelAllOrders(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int SendCancelOrders(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern Int64 SendZeroPosition(
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcIDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcTicker,
            [MarshalAs(UnmanagedType.LPWStr)] string pwcBolsa,
            [MarshalAs(UnmanagedType.LPWStr)] string sSenha,
            double sPrice);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern long SendBuyOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string IDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string IDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string Senha,
            [MarshalAs(UnmanagedType.LPWStr)] string Ticker,
            [MarshalAs(UnmanagedType.LPWStr)] string Bolsa,
            double sPrice, int nAmount);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern long SendSellOrder(
            [MarshalAs(UnmanagedType.LPWStr)] string IDAccount,
            [MarshalAs(UnmanagedType.LPWStr)] string IDCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string Senha,
            [MarshalAs(UnmanagedType.LPWStr)] string Ticker,
            [MarshalAs(UnmanagedType.LPWStr)] string Bolsa,
            double sPrice, int nAmount);

        [DllImport(dll_path, CallingConvention = CallingConvention.StdCall)]
        public static extern int GetOrder([MarshalAs(UnmanagedType.LPWStr)] string clOrdId);
        #endregion

        #region Client Functions : TODO
        public static void HistoryCallBack(TAssetID assetId, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date)
        {
            Console.WriteLine("historyCallBack: nProfitID=" + nProfitID + " ticker = " + assetId.Ticker + " Qtd=" + nQtd + " Price=" + sPrice);
        }

        ////////////////////////////////////////////////////////////////////////////////
        //Callback de alterãção em ordens
        public static void ChangeCotationCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double sPrice)
        {
            Console.WriteLine("changeCotationCallback: " + assetId.Ticker + " : " + date + " : " + sPrice);
        }

        public static void AssetListCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strName)
        {
            if (string.IsNullOrWhiteSpace(strAssetListFilter) || strAssetListFilter == assetId.Ticker)
            {
                Console.WriteLine($"AssetListCallback: {assetId.Ticker} : {strName}");
            }
        }

        public static void AssetListInfoCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strName, [MarshalAs(UnmanagedType.LPWStr)] string strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote, int stSecurityType, int ssSecuritySubType, double sMinPriceInc, double sContractMultiplier,
            [MarshalAs(UnmanagedType.LPWStr)] string validityDate, [MarshalAs(UnmanagedType.LPWStr)] string strISIN)
        {
            if ((string.IsNullOrWhiteSpace(strAssetListFilter) && !string.IsNullOrWhiteSpace(strISIN)) || strAssetListFilter == assetId.Ticker)
            {
                Console.WriteLine($"AssetListInfoCallback: {assetId.Ticker} : {strName} - {strDescription} : ISIN: {strISIN}");
            }
        }

        public static void AssetListInfoCallbackV2(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strName, [MarshalAs(UnmanagedType.LPWStr)] string strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote, int stSecurityType, int ssSecuritySubType, double sMinPriceInc, double sContractMultiplier,
            [MarshalAs(UnmanagedType.LPWStr)] string validityDate, [MarshalAs(UnmanagedType.LPWStr)] string strISIN, [MarshalAs(UnmanagedType.LPWStr)] string strSetor, [MarshalAs(UnmanagedType.LPWStr)] string strSubSetor, [MarshalAs(UnmanagedType.LPWStr)] string strSegmento)
        {
            if ((string.IsNullOrWhiteSpace(strAssetListFilter) && !string.IsNullOrWhiteSpace(strISIN)) || strAssetListFilter == assetId.Ticker)
            {
                Console.WriteLine($"AssetListInfoCallback: {assetId.Ticker} : {strName} - {strDescription} : ISIN: {strISIN} - Setor: {strSetor}");
            }
        }

        public static void OrderChangeCallBack(TAssetID assetId, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date,
            [MarshalAs(UnmanagedType.LPWStr)] string TextMessage)
        {
            Console.WriteLine("orderChangeCallBack: nProfitID=" + nProfitID + " ticker = " + assetId.Ticker + " Qtd=" + nQtd + " Price=" + sPrice + " Date=" + DateTime.Now);
        }

        public static void OrderChangeCallBackV2(TAssetID assetId, int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side, int nValidity, double sPrice, double sStopPrice, double sAvgPrice, long nProfitID,
            [MarshalAs(UnmanagedType.LPWStr)] string TipoOrdem,
            [MarshalAs(UnmanagedType.LPWStr)] string Conta,
            [MarshalAs(UnmanagedType.LPWStr)] string Titular,
            [MarshalAs(UnmanagedType.LPWStr)] string ClOrdID,
            [MarshalAs(UnmanagedType.LPWStr)] string Status,
            [MarshalAs(UnmanagedType.LPWStr)] string Date,
            [MarshalAs(UnmanagedType.LPWStr)] string LastUpdate,
            [MarshalAs(UnmanagedType.LPWStr)] string CloseDate,
            [MarshalAs(UnmanagedType.LPWStr)] string ValidityDate,
            [MarshalAs(UnmanagedType.LPWStr)] string TextMessage)
        {
            Console.WriteLine("orderChangeCallBackV2: nProfitID=" + nProfitID + " ticker = " + assetId.Ticker + " Qtd=" + nQtd + " Price=" + sPrice + " Date=" + DateTime.Now + " Validity=" + ValidityDate);
        }

        public static void ChangeStateTickerCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string strDate, int nState)
        {
            Console.WriteLine("changeStateTickerCallback: ticker=" + assetId.Ticker + " Date=" + strDate + " nState=" + nState);
        }

        ////////////////////////////////////////////////////////////////////////////////
        //Callback com a lista de contas
        public static void AccountCallback(int nCorretora,
            [MarshalAs(UnmanagedType.LPWStr)] string CorretoraNomeCompleto,
            [MarshalAs(UnmanagedType.LPWStr)] string AccountID,
            [MarshalAs(UnmanagedType.LPWStr)] string NomeTitular)
        {
            WriteAtPos(0, 10, $"AccountCallback: {AccountID} - {NomeTitular}");
        }

        public static void PriceBookCallback(TAssetID assetId, int nAction, int nPosition, int Side, int nQtd, int nCount, double sPrice, IntPtr pArraySell, IntPtr pArrayBuy)
        {
            List<TGroupPrice> lstBook;

            if (pArraySell != IntPtr.Zero)
            {
                DescriptaPriceArray(pArraySell, m_lstPriceSell);
            }

            if (pArrayBuy != IntPtr.Zero)
            {
                DescriptaPriceArray(pArrayBuy, m_lstPriceBuy);
            }

            if (Side == 0)
                lstBook = m_lstPriceBuy;
            else
                lstBook = m_lstPriceSell;

            TGroupPrice newPrice = new TGroupPrice(sPrice, nCount, nQtd);

            switch (nAction)
            {
                case 0:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                            lstBook.Insert(lstBook.Count - nPosition, newPrice);
                    }
                    break;
                case 1:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                        {
                            TGroupPrice currentPrice = lstBook[lstBook.Count - 1 - nPosition];
                            newPrice.Qtd += currentPrice.Qtd;
                            newPrice.Count += currentPrice.Count;
                        }
                    }
                    break;
                case 2:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                            lstBook.RemoveAt(lstBook.Count - nPosition - 1);
                    }
                    break;
                case 3:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                            lstBook.RemoveRange(lstBook.Count - nPosition - 1, nPosition + 1);
                    }
                    break;
                case 4:
                    {
                        if (pArraySell != IntPtr.Zero)
                        {
                            DescriptaPriceArray(pArraySell, m_lstPriceSell);
                        }

                        if (pArrayBuy != IntPtr.Zero)
                        {
                            DescriptaPriceArray(pArrayBuy, m_lstPriceBuy);
                        }
                    }
                    break;
                default: break;
            }
        }

        public static void OfferBookCallback(TAssetID assetId, int nAction, int nPosition, int Side, int nQtd, int nAgent, Int64 nOfferID, double sPrice, int bHasPrice, int bHasQtd, int bHasDate, int bHasOfferID, int bHasAgent,
            [MarshalAs(UnmanagedType.LPWStr)] string date,
            IntPtr pArraySell, IntPtr pArrayBuy)
        {
            List<TGroupOffer> lstBook;

            if (Side == 0)
                lstBook = m_lstOfferBuy;
            else
                lstBook = m_lstOfferSell;

            TGroupOffer offer = new TGroupOffer(sPrice, nQtd, nAgent, nOfferID, date);

            switch (nAction)
            {
                case 0:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                        {
                            lstBook.Insert(lstBook.Count - nPosition, offer);
                        }
                    }
                    break;
                case 1:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                        {
                            TGroupOffer currentOffer = lstBook[lstBook.Count - 1 - nPosition];
                            if (bHasQtd != 0)
                                currentOffer.Qtd += offer.Qtd;
                            if (bHasPrice != 0)
                                currentOffer.Price = offer.Price;
                            if (bHasOfferID != 0)
                                currentOffer.OfferID = offer.OfferID;
                            if (bHasAgent != 0)
                                currentOffer.Agent = offer.Agent;
                            if (bHasDate != 0)
                                currentOffer.Date = offer.Date;
                            lstBook[lstBook.Count - 1 - nPosition] = currentOffer;
                        }
                    }
                    break;
                case 2:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                            lstBook.RemoveAt(lstBook.Count - nPosition - 1);
                    }
                    break;
                case 3:
                    {
                        if (nPosition >= 0 && nPosition < lstBook.Count)
                            lstBook.RemoveRange(lstBook.Count - nPosition - 1, nPosition + 1);
                    }
                    break;
                case 4:
                    {
                        if (pArraySell != IntPtr.Zero)
                        {
                            DescriptaOfferArray(pArraySell, m_lstOfferSell);
                        }

                        if (pArrayBuy != IntPtr.Zero)
                        {
                            DescriptaOfferArray(pArrayBuy, m_lstOfferBuy);
                        }
                    }
                    break;
                default: break;
            }
        }

        public static void NewTradeCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType, int bIsEdit)
        {
            WriteAtPos(0, 5, $"NewTradeCallback: {assetId.Ticker}: {date} ({tradeNumber}) {price} {qtd}");
        }

        public static void NewDailyCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, double sOpen, double sHigh, double sLow,
            double sClose, double sVol, double sAjuste, double sMaxLimit, double sMinLimit, double sVolBuyer,
            double sVolSeller, int nQtd, int nNegocios, int nContratosOpen, int nQtdBuyer, int nQtdSeller, int nNegBuyer, int nNegSeller)
        {
            WriteAtPos(0, 6, $"NewDailyCallback: {assetId.Ticker}: {date} {sOpen} {sHigh} {sLow} {sClose}");
        }

        public static void ProgressCallBack(TAssetID assetId, int nProgress)
        {
            Console.WriteLine("progressCallBack");
        }

        public static void NewTinyBookCallBack(TAssetID assetId, double price, int qtd, int side)
        {
            var sideName = side == 0 ? "buy" : "sell";
            WriteAtPos(0, 7, $"NewTinyBookCallBack: {assetId.Ticker}: {sideName} {price} {qtd}");
        }

        public static void NewHistoryCallback(TAssetID assetId, [MarshalAs(UnmanagedType.LPWStr)] string date, uint tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType)
        {
            WriteAtPos(0, 8, $"NewHistoryCallback: {assetId.Ticker}: {date} ({tradeNumber}) {price} {qtd}");
        }

        public static void TheoreticalPriceCallback(TAssetID assetId, double dTheoreticalPrice, Int64 nTheoreticalQtd)
        {
            WriteAtPos(0, 9, $"TheoreticalPriceCallback: {assetId.Ticker}: {dTheoreticalPrice}");
        }

        public static void AdjustHistoryCallbackV2(TAssetID assetId,
            double dValue,
            [MarshalAs(UnmanagedType.LPWStr)] string adjustType,
            [MarshalAs(UnmanagedType.LPWStr)] string strObserv,
            [MarshalAs(UnmanagedType.LPWStr)] string dtAjuste,
            [MarshalAs(UnmanagedType.LPWStr)] string dtDeliber,
            [MarshalAs(UnmanagedType.LPWStr)] string dtPagamento,
            int nFlags,
            double dMult)
        {
            WriteAtPos(0, 10, $"AdjustHistoryCallbackV2: {assetId.Ticker}: Value={dValue} Type={adjustType}");
        }

        public static void StateCallback(int nConnStateType, int result)
        {

            if (nConnStateType == 0)
            { // notificacoes de login
                if (result == 0)
                {
                    WriteAtPos(0, 0, "Login: Conectado");
                }
                if (result == 1)
                {
                    WriteAtPos(0, 0, "Login: Invalido");
                }
                if (result == 2)
                {
                    WriteAtPos(0, 0, "Login: Senha invalida");
                }
                if (result == 3)
                {
                    WriteAtPos(0, 0, "Login: Senha bloqueada");
                }
                if (result == 4)
                {
                    WriteAtPos(0, 0, "Login: Senha Expirada");
                }
                if (result == 200)
                {
                    WriteAtPos(0, 0, "Login: Erro Desconhecido");
                }
            }
            if (nConnStateType == 1)
            { // notificacoes de broker
                if (result == 0)
                {
                    WriteAtPos(0, 1, "Broker: Desconectado");
                }
                if (result == 1)
                {
                    WriteAtPos(0, 1, "Broker: Conectando");
                }
                if (result == 2)
                {
                    WriteAtPos(0, 1, "Broker: Conectado");
                }
                if (result == 3)
                {
                    WriteAtPos(0, 1, "Broker: HCS Desconectado");
                }
                if (result == 4)
                {
                    WriteAtPos(0, 1, "Broker: HCS Conectando");
                }
                if (result == 5)
                {
                    WriteAtPos(0, 1, "Broker: HCS Conectado");
                }
            }

            if (nConnStateType == 2)
            { // notificacoes de login no Market
                if (result == 0)
                {
                    WriteAtPos(0, 2, "Market: Desconectado");
                }
                if (result == 1)
                {
                    WriteAtPos(0, 2, "Market: Conectando");
                }
                if (result == 2)
                {
                    WriteAtPos(0, 2, "Market: csConnectedWaiting");
                }
                if (result == 3)
                {
                    bMarketConnected = false;
                    WriteAtPos(0, 2, "Market: Não logado");
                }
                if (result == 4)
                {
                    bMarketConnected = true;
                    WriteAtPos(0, 2, "Market: Conectado");
                }
            }

            if (nConnStateType == 3)
            { // notificacoes de login no Market
                if (result == 0)
                {
                    //Atividade: Valida
                    bAtivo = true;
                    WriteAtPos(0, 3, "Profit: Notificação de Atividade Valida");
                }
                else
                {
                    //Atividade: Invalida
                    bAtivo = false;
                    WriteAtPos(0, 3, "Profit: Notificação de Atividade Invalida");
                }
            }

            if (bAtivo && bMarketConnected)
            {
                Console.SetCursorPosition(9, 12);
            }
        }

        public static void ServerClockPrint()
        {
            double serverClock = 0.0;
            int year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0, mili = 0;
            GetServerClock(ref serverClock, ref year, ref month, ref day, ref hour, ref min, ref sec, ref mili);
            Console.WriteLine($"Server Clock: {hour}:{min}:{sec}.{mili}");
        }

        public static void DescriptaPriceArray(IntPtr pRetorno, List<TGroupPrice> lstPrice)
        {
            lstPrice.Clear();

            byte[] header = new byte[128];
            Marshal.Copy(pRetorno, header, 0, 128);

            var qtd = BitConverter.ToInt32(header, 0);
            var tam = BitConverter.ToInt32(header, 4);
            var pos = 8;

            byte[] pBuffer = new byte[tam];
            Marshal.Copy(pRetorno, pBuffer, 0, tam);

            Console.WriteLine($"PriceBook: Qtd {qtd} Tam {tam}");

            for (int i = 0; i < qtd; i++)
            {
                var group = new TGroupPrice();

                group.Price = BitConverter.ToDouble(pBuffer, pos);
                pos += 8;

                group.Qtd = BitConverter.ToInt32(pBuffer, pos);
                pos += 4;

                group.Count = BitConverter.ToInt32(pBuffer, pos);
                pos += 4;

                //Console.WriteLine($"Price {group.Price} Qtd {group.Qtd} Count {group.Count}");
                lstPrice.Add(group);
            }

            FreePointer(pRetorno, pos);
        }

        public static void DescriptaOfferArray(IntPtr pRetorno, List<TGroupOffer> lstOffer)
        {
            lstOffer.Clear();

            int len = 128;
            byte[] header = new byte[len];
            Marshal.Copy(pRetorno, header, 0, len);

            var qtd = BitConverter.ToInt32(header, 0);
            var tam = BitConverter.ToInt32(header, 4);

            byte[] pBuffer = new byte[tam];
            Marshal.Copy(pRetorno, pBuffer, 0, tam);

            Console.WriteLine($"OfferBook: Qtd {qtd} Tam {tam}");

            var pos = 8;
            for (int i = 0; i < qtd; i++)
            {
                var offer = new TGroupOffer();

                offer.Price = BitConverter.ToDouble(pBuffer, pos);
                pos += 8;

                offer.Qtd = BitConverter.ToInt32(pBuffer, pos);
                pos += 4;

                offer.Agent = BitConverter.ToInt32(pBuffer, pos);
                pos += 4;

                offer.OfferID = BitConverter.ToInt64(pBuffer, pos);
                pos += 8;

                var length = BitConverter.ToUInt16(pBuffer, pos);
                pos += 2;

                var builder = new StringBuilder();
                for (int j = pos; j < pos + length; j++)
                {
                    builder.Append((char)pBuffer[j]);
                }

                var strAux = builder.ToString();
                pos += length;

                offer.Date = strAux;

                lstOffer.Add(offer);

                //Console.WriteLine($"Price {offer.Price} Qtd {offer.Qtd} Date {offer.Offer}");
            }

            FreePointer(pRetorno, pos);
        }
        private static string ExtractStringFromStream(byte[] stream, int index)
        {
            int at = index;
            var length = BitConverter.ToUInt16(stream, at);
            at += 2;

            var builder = new StringBuilder();
            for (int j = at; j < at + length; j++)
            {
                builder.Append((char)stream[j]);
            }

            return builder.ToString();
        }

        private static void RequestPosition(string AccountID, string Corretora)
        {
            string input;

            do
            {
                Console.Write("Insira o codigo do ativo e clique enter: ");
                input = Console.ReadLine().ToUpper();
            } while (!Regex.IsMatch(input, "[^:]+:[A-Za-z0-9]"));

            var split = input.Split(':');
            strAssetListFilter = split[0].Trim();
            string bolsa = split[1].Trim();

            IntPtr posReturn = GetPosition(AccountID, Corretora, strAssetListFilter, bolsa);
            if (posReturn != IntPtr.Zero)
            {
                int len = 128;
                byte[] header = new byte[len];
                Marshal.Copy(posReturn, header, 0, len);

                var qtd = BitConverter.ToInt32(header, 0);
                var tam = BitConverter.ToInt32(header, 4);

                byte[] pBuffer = new byte[tam];
                Marshal.Copy(posReturn, pBuffer, 0, tam);

                var at = 8;
                for (int i = 0; i < qtd; ++i)
                {
                    var position = new TPosition();

                    position.CorretoraID = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.AccountID = ExtractStringFromStream(pBuffer, at);
                    at += (2 + position.AccountID.Length);

                    position.Titular = ExtractStringFromStream(pBuffer, at);
                    at += (2 + position.Titular.Length);

                    position.Ticker = ExtractStringFromStream(pBuffer, at);
                    at += (2 + position.Ticker.Length);

                    position.IntradayPosition = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Price = BitConverter.ToDouble(pBuffer, at);
                    at += 8;

                    position.AvgSellPrice = BitConverter.ToDouble(pBuffer, at);
                    at += 8;

                    position.SellQtd = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.AvgBuyPrice = BitConverter.ToDouble(pBuffer, at);
                    at += 8;

                    position.BuyQtd = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.CustodyD1 = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.CustodyD2 = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.CustodyD3 = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Blocked = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Pending = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Allocated = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Provisioned = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.QtdPosition = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    position.Available = BitConverter.ToInt32(pBuffer, at);
                    at += 4;

                    WriteAtPos(0, 9, $"Position: {position}");
                }
            }
        }
        #endregion

        #region Exemplo de execucao

        static string strAssetListFilter;

        private static void SubscribeAsset()
        {
            //Selecionar ativo para callback

            string input;

            do
            {
                Console.Write("Insira o codigo do ativo e clique enter: ");
                input = Console.ReadLine().ToUpper();
            } while (!Regex.IsMatch(input, "[^:]+:[A-Za-z0-9]"));

            var split = input.Split(':');

            var retVal = SubscribeTicker(split[0], split[1]);

            if (retVal == NL_OK)
            {
                Console.WriteLine("Subscribe com sucesso");
            }
            else
            {
                Console.WriteLine($"Erro no subscribe: {retVal}");
            }
        }

        private static void UnsubscribeAsset()
        {
            //Selecionar ativo para callback

            string input;

            do
            {
                Console.Write("Insira o codigo do ativo e clique enter: ");
                input = Console.ReadLine().ToUpper();
            } while (!Regex.IsMatch(input, "[^:]+:[A-Za-z0-9]"));

            var split = input.Split(':');

            var retVal = UnsubscribeTicker(split[0], split[1]);

            if (retVal == NL_OK)
            {
                Console.WriteLine("Subscribe com sucesso");
            }
            else
            {
                Console.WriteLine($"Erro no subscribe: {retVal}");
            }
        }

        private static void RequestHistory()
        {
            string input;

            do
            {
                Console.Write("Insira o codigo do ativo e clique enter (ex. PETR4:B): ");
                input = Console.ReadLine().ToUpper();
            } while (!Regex.IsMatch(input, "[^:]+:[A-Za-z0-9]"));

            var split = input.Split(':');

            var retVal = GetHistoryTrades(split[0], split[1], DateTime.Today.ToString(dateFormat), DateTime.Now.ToString(dateFormat));

            if (retVal == NL_OK)
            {
                Console.WriteLine("GetHistoryTrades com sucesso");
            }
            else
            {
                Console.WriteLine($"Erro no GetHistoryTrades: {retVal}");
            }
        }

        public static void RequestOrder()
        {
            Console.WriteLine("Informe um ClOrdId: ");
            var retVal = GetOrder(Console.ReadLine());

            if (retVal == NL_OK)
            {
                Console.WriteLine("GetOrder com sucesso");
            }
            else
            {
                Console.WriteLine($"Erro no GetOrder: {retVal}");
            }
        }

        private static int StartDLL(string key, string user, string password)
        {
            GC.KeepAlive(_newTinyBookCallBack);
            GC.KeepAlive(_progressCallBack);
            GC.KeepAlive(_newHistoryCallback);
            GC.KeepAlive(_offerBookCallback);
            GC.KeepAlive(_priceBookCallback);
            GC.KeepAlive(_newDailyCallback);
            GC.KeepAlive(_newTradeCallback);
            GC.KeepAlive(_stateCallback);
            GC.KeepAlive(_historyCallBack);
            GC.KeepAlive(_orderChangeCallBack);
            GC.KeepAlive(_orderChangeCallBackV2);
            GC.KeepAlive(_accountCallback);
            GC.KeepAlive(_assetListInfoCallback);
            GC.KeepAlive(_assetListCallback);
            GC.KeepAlive(_assetListInfoCallbackV2);
            GC.KeepAlive(_theoreticalPriceCallback);

            GC.Collect();
            GC.WaitForPendingFinalizers();

            int retVal;
            bool bRoteamento = true;
            if (bRoteamento)
            {
                retVal = DLLInitializeLogin(key, user, password, _stateCallback, _historyCallBack, _orderChangeCallBack, _accountCallback, _newTradeCallback, _newDailyCallback, _priceBookCallback, _offerBookCallback, _newHistoryCallback, _progressCallBack, _newTinyBookCallBack);
            }
            else
            {
                retVal = DLLInitializeMarketLogin(key, user, password, _stateCallback, _newTradeCallback, _newDailyCallback, _priceBookCallback, _offerBookCallback, _newHistoryCallback, _progressCallBack, _newTinyBookCallBack);
            }

            if (retVal != NL_OK)
            {
                Console.WriteLine($"Erro na inicialização: {retVal}");
            }
            else
            {
                retVal = SetAssetListInfoCallbackV2(_assetListInfoCallbackV2);

                if (retVal != NL_OK)
                {
                    Console.WriteLine($"Erro no SetAssetListInfoCallbackV2: {retVal}");
                }
            }

            return retVal;
        }

        public static void Main(string[] args)
        {
            Console.WriteLine("Press any key to continue");
            Console.ReadLine();

            string key = "";    // Preencher com activation key
            string user = "";      // Preencher com usuário (email ou documento)
            string password = ""; // Preencher com senha
            if (args.Length != 0)
            {
                key = args[0];
            }
            if (StartDLL(key, user, password) != NL_OK)
            {
#if DEBUG
                Console.ReadLine();
#endif
                return;
            }

            var terminate = false;
            while (!terminate)
            {
                try
                {
                    if (bMarketConnected && bAtivo)
                    {
                        lock (writeLock)
                        {
                            Console.SetCursorPosition(0, 12);
                            Console.Write("Comando:" + new string(' ', Console.BufferWidth));
                            Console.SetCursorPosition(9, 12);
                        }

                        SetAdjustHistoryCallbackV2(AdjustHistoryCallbackV2);
                        SetOrderChangeCallbackV2(OrderChangeCallBackV2);

                        var input = Console.ReadLine();
                        switch (input)
                        {
                            case "subscribe":
                                SubscribeAsset();
                                break;
                            case "unsubscribe":
                                UnsubscribeAsset();
                                break;
                            case "request history":
                                RequestHistory();
                                break;
                            case "request order":
                                RequestOrder();
                                break;
                            case "exit":
                                terminate = true;
                                break;
                            default:
                                break;
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex);
                }
            }

        }

        private static readonly object writeLock = new object();
        private static void WriteAtPos(int left, int top, string text)
        {
            lock (writeLock)
            {
                Console.SetCursorPosition(left, top);
                Console.WriteLine(text);

                if (bAtivo && bMarketConnected)
                {
                    Console.SetCursorPosition(9, 12);
                }
            }
        }
        #endregion
    }
}
