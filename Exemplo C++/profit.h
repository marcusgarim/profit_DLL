#pragma once

typedef struct
{
    wchar_t* ticker;
    wchar_t* bolsa;
    int feed;
} TAssetID;

////////////////////////////////////////////////////////////////////////////////
// WARNING: Não utilizar funções da dll dentro do CALLBACK
////////////////////////////////////////////////////////////////////////////////
//Callback do stado das diferentes conexões
typedef void(__stdcall* TStateCallback)(int nConnStateType, int nResult);

////////////////////////////////////////////////////////////////////////////////
//Callback  do estado do hystorico de ordens
typedef void(__stdcall* THistoryCallBack)(TAssetID AssetID,
    int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side,
    double sPrice, double sStopPrice, double sAvgPrice,
    __int64 nProfitID,
    wchar_t* TipoOrdem, wchar_t* Conta, wchar_t* Titular, wchar_t* ClOrdID, wchar_t* Status, wchar_t* Date);

typedef void(__stdcall* TProgressCallBack)(TAssetID assetId,
    int nProgress);

////////////////////////////////////////////////////////////////////////////////
//Callback de alterção em ordens
typedef void(__stdcall* TOrderChangeCallBack)(TAssetID AssetID,
    int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side,
    double sPrice, double sStopPrice, double sAvgPrice,
    __int64 nProfitID,
    wchar_t* TipoOrdem, wchar_t* Conta, wchar_t* Titular, wchar_t* ClOrdID, wchar_t* Status, wchar_t* Date, wchar_t* TextMessage);

////////////////////////////////////////////////////////////////////////////////
//Callback com a lista de contas
typedef void(__stdcall* TAccountCallback)(int nCorretora,
    wchar_t* CorretoraNomeCompleto, wchar_t* AccountID, wchar_t* NomeTitular);

////////////////////////////////////////////////////////////////////////////////
//Callback com informações marketData
typedef void(__stdcall* TNewTradeCallback)(TAssetID assetId,
    wchar_t* date,
    unsigned int nTradeNumber,
    double price, double vol,
    int qtd, int buyAgent, int sellAgent, int tradeType,
    wchar_t bIsEdit);

typedef void(__stdcall* THistoryTradeCallback)(TAssetID assetId,
    wchar_t* date,
    unsigned int nTradeNumber,
    double price, double vol,
    int qtd, int buyAgent, int sellAgent, int tradeType);

typedef void(__stdcall* TNewDailyCallback)(TAssetID TAssetIDRec,
    wchar_t* date,
    double sOpen, double sHigh, double sLow, double sClose, double sVol, double sAjuste, double sMaxLimit, double sMinLimit,
    double sVolBuyer, double sVolSeller, int nQtd, int nNegocios, int nContratosOpen, int nQtdBuyer, int nQtdSeller, int nNegBuyer, int nNegSeller);

typedef void(__stdcall* TChangeStateTicker)(TAssetID assetId, wchar_t* date, int nState);

typedef void(__stdcall* TTinyBookCallback)(TAssetID assetId, double price, int qtd, int side);

////////////////////////////////////////////////////////////////////////////////
//Callback com informações marketData

typedef void(__stdcall* TPriceBookCallback)(TAssetID assetId,
    int nAction, int nPosition, int Side, int nQtd, int nCount,
    double sPrice,
    void* pArraySell, void* pArrayBuy);

typedef void(__stdcall* TOfferBookCallback)(TAssetID assetId,
    int nAction, int nPosition, int Side, int nQtd, int nAgent, __int64 nOfferID,
    double sPrice,
    int bHasPrice, int bHasQtd, int bHasDate, int bHasOfferID, int bHasAgent,
    wchar_t* date,
    void* pArraySell, void* pArrayBuy);

typedef void(__stdcall* TNewTinyBookCallBack)(TAssetID assetId,
    double price,
    int qtd, int side);

typedef void(__stdcall* TChangeCotation)(TAssetID assetId, wchar_t* date, unsigned int nTradeNumber, double sPrice);

typedef void(__stdcall* TAssetListInfoCallback)(TAssetID assetId, wchar_t* strName, wchar_t* strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote, int stSecurityType, int ssSecuritySubType, double sMinPriceIncrement, double sContractMultiplier, wchar_t* strDate, wchar_t* strISIN);
typedef void(__stdcall* TAssetListInfoCallbackV2)(TAssetID assetId, wchar_t* strName, wchar_t* strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote, int stSecurityType, int ssSecuritySubType, double sMinPriceIncrement, double sContractMultiplier, wchar_t* strDate, wchar_t* strISIN, wchar_t* strSetor, wchar_t* strSubSetor, wchar_t* strSegmento);
typedef void(__stdcall* TAssetListCallback)(TAssetID assetId, wchar_t* strName);

typedef void(__stdcall* TAdjustHistoryCallback)(TAssetID assetId, double sValue, wchar_t* strAdjustType, wchar_t* strObserv, wchar_t* dtAjuste, wchar_t* dtDeliber, wchar_t* dtPagamento, int nAffectPrice);
typedef void(__stdcall* TAdjustHistoryCallbackV2)(TAssetID assetId, double sValue, wchar_t* strAdjustType, wchar_t* strObserv, wchar_t* dtAjuste, wchar_t* dtDeliber, wchar_t* dtPagamento, int nFlags, double dMult);
typedef void(__stdcall* TTheoreticalPriceCallback)(TAssetID assetId, double dTheoreticalPrice, __int64 nTheoreticalQtd);

typedef int(__stdcall* SetChangeCotationCallback)(TChangeCotation ChangeCotation);

typedef int(__stdcall* SetAssetListCallback)(TAssetListCallback AssetListCallback);
typedef int(__stdcall* SetAssetListInfoCallback)(TAssetListInfoCallback AssetListInfoCallback);
typedef int(__stdcall* SetAssetListInfoCallbackV2)(TAssetListInfoCallbackV2 AssetListInfoCallbackV2);
typedef int(__stdcall* SetAdjustHistoryCallback)(TAdjustHistoryCallback AdjustHistoryCallback);
typedef int(__stdcall* SetAdjustHistoryCallbackV2)(TAdjustHistoryCallbackV2 AdjustHistoryCallbackV2);
typedef int(__stdcall* SetChangeStateTickerCallback)(TChangeStateTicker ChangeState);
typedef int(__stdcall* SetTheoreticalPriceCallback)(TTheoreticalPriceCallback ChangeState);

typedef int(__stdcall* SetEnabledLogToDebug)(int bEnabled);

typedef int(__stdcall* DLLInitializeMarketLogin)(
    const wchar_t* activationKey,
    const wchar_t* user,
    const wchar_t* password,
    TStateCallback stateCallback,
    TNewTradeCallback newTradeCallback,
    TNewDailyCallback newDailyCallback,
    TPriceBookCallback priceBookCallback,
    TOfferBookCallback offerBookCallback,
    THistoryTradeCallback newHistoryCallback,
    TProgressCallBack progressCallBack,
    TNewTinyBookCallBack newTinyBookCallBack);


typedef int(__stdcall* DLLInitializeLogin) (
    const wchar_t* activationKey,
    const wchar_t* user,
    const wchar_t* password,
    TStateCallback stateCallback,
    THistoryCallBack historyCallBack,
    TOrderChangeCallBack orderChangeCallBack,
    TAccountCallback accountCallback,
    TNewTradeCallback newTradeCallback,
    TNewDailyCallback newDailyCallback,
    TPriceBookCallback priceBookCallback,
    TOfferBookCallback offerBookCallback,
    THistoryTradeCallback newHistoryCallback,
    TProgressCallBack progressCallBack,
    TNewTinyBookCallBack newTinyBookCallBack);

typedef int(__stdcall* Finalize)();

typedef int(__stdcall* SubscribeTicker)(const wchar_t* ticker, const wchar_t* bolsa);
typedef int(__stdcall* UnsubscribeTicker)(const wchar_t* ticker, const wchar_t* bolsa);
typedef int(__stdcall* SubscribePriceBook)(const wchar_t* ticker, const wchar_t* bolsa);
typedef int(__stdcall* UnsubscribePriceBook)(const wchar_t* ticker, const wchar_t* bolsa);
typedef int(__stdcall* SubscribeOfferBook)(const wchar_t* ticker, const wchar_t* bolsa);
typedef int(__stdcall* UnsubscribeOfferBook)(const wchar_t* ticker, const wchar_t* bolsa);

typedef wchar_t* (__stdcall* GetAgentNameByID)(int nID);
typedef wchar_t* (__stdcall* GetAgentShortNameByID)(int nID);

typedef int(__stdcall* FreePointer)(void* pointer, int nSize);

typedef int(__stdcall* SetServerAndPort)(wchar_t* server, wchar_t* port);
typedef int(__stdcall* GetServerClock)(double* serverClock, int* nYear, int* nMonth, int* nDay, int* nHour, int* nMin, int* nSec, int* nMilisec);

////////////////////////////////////////////////////////////////////////////////
// Roteamento
typedef __int64(__stdcall* SendBuyOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, double sPrice, int nAmount);
typedef __int64(__stdcall* SendSellOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, double sPrice, int nAmount);
typedef __int64(__stdcall* SendStopBuyOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, double sPrice, double sStopPrice, int nAmount);
typedef __int64(__stdcall* SendStopSellOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, double sPrice, double sStopPrice, int nAmount);
typedef __int64(__stdcall* SendZeroPosition)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* pwcTicker, wchar_t* pwcBolsa, wchar_t* pwcSenha, double sPrice);

typedef int(__stdcall* SendChangeOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcClOrdId, double sPrice, int nAmount);
typedef int(__stdcall* SendCancelOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* pwcClOrdId, wchar_t* sSenha);
typedef int(__stdcall* SendCancelOrders)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* pwcSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa);
typedef int(__stdcall* SendCancelAllOrders)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* pwcSenha);

typedef int(__stdcall* GetAccount)();
typedef int(__stdcall* GetOrders)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* dateStart, wchar_t* dateEnd);
typedef int(__stdcall* GetOrder)(const wchar_t* pwcClOrdId);
typedef int(__stdcall* GetOrderProfitID)(__int64 nProfitID);
typedef void* (__stdcall* GetPosition)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* pwcTicker, wchar_t* pwcBolsa);
typedef int(__stdcall* GetHistoryTrades)(const wchar_t* pwcTicker, const wchar_t* bolsa, wchar_t* dateStart, wchar_t* dtDateEnd);

typedef int(__stdcall* SetDayTrade)(int bUseDayTrade);
typedef int(__stdcall* SetEnabledHistOrder)(int bEnabled);

typedef int(__stdcall* SubscribeAdjustHistory)(wchar_t* pwcTicker, wchar_t* bolsa);
typedef int(__stdcall* UnsubscribeAdjustHistory)(wchar_t* pwcTicker, wchar_t* bolsa);

typedef int(__stdcall* GetLastDailyClose)(wchar_t* ticker, wchar_t* bolsa, double* dClose, int bAdjusted);

typedef __int64(__stdcall* SendMarketBuyOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, int nAmount);
typedef __int64(__stdcall* SendMarketSellOrder)(const wchar_t* pwcIDAccount, const wchar_t* pwcIDCorretora, wchar_t* sSenha, wchar_t* pwcTicker, wchar_t* pwcBolsa, int nAmount); 

// #Functions

//////////////////////////////////////////////////////////////////////////////
// Error Codes
const int NL_OK                 = 0x00000000;  // OK
const int NL_INTERNAL_ERROR     = 0x80000001;  // Internal error
const int NL_NOT_INITIALIZED    = 0x80000002;  // Not initialized
const int NL_INVALID_ARGS       = 0x80000003;  // Invalid arguments
const int NL_WAITING_SERVER     = 0x80000004;  // Aguardando dados do servidor

typedef struct {
    int day;
    int month;
    int year;
    int hour;
    int min;
    int sec;
    int mili;
} Date;

typedef struct {
    double   price;
    double   volume;
    int      qtd;
    wchar_t* asset;
    Date     date;
} Trade;

typedef struct {
    double open;
    double close;
    double max;
    double min;
    double volume;
    int    qtd;
    int    neg;
    Date   date;
    wchar_t* asset;
} TradeCandle;

typedef struct {
    int   length;
    char* data;
} String;

typedef struct {
    int corretora_id;
    String account_id;
    String titular;
    String ticker;
    int intraday_position;
    double price;
    double avg_sell_price;
    int sell_qtd;
    double avg_buy_price;
    int buy_qtd;
    int custody_d1;
    int custody_d2;
    int custody_d3;
    int blocked;
    int pending;
    int allocated;
    int provisioned;
    int qtd_position;
    int available;
} Position;