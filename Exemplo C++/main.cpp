/*
   Para compilar pela linha de comando com o compilador do Visual Studio
   cl main.cpp /link ws2_32.lib kernel32.lib

   Para compilar com g++
   g++ main.cpp
*/
#undef UNICODE
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <ctime>
#include <tchar.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <assert.h>

#pragma comment (lib, "Ws2_32.lib")
#pragma warning(disable:4996)

#define MAX(A,B) (((A) > (B)) ? (A) : (B))
#define MIN(A,B) (((A) < (B)) ? (A) : (B))

#include "profit.h"

//////////////////////////////////////////////////////////////////////////////
// DLL Functions
DLLInitializeLogin g_initialize;
DLLInitializeMarketLogin g_initializeMarket;
Finalize g_finalize;
GetServerClock g_GetServerClock;
SetServerAndPort g_setServerAndPort;
////////////////////////////////////////////////////////////////////////////////
// Market Data
SubscribeTicker g_subscribe;
UnsubscribeTicker g_unsubscribe;

SubscribePriceBook g_subscribePrice;
UnsubscribePriceBook g_unsubscribePrice;

SubscribeOfferBook g_subscribeOffer;
UnsubscribeOfferBook g_unsubscribeOffer;

GetAgentNameByID g_getAgentName;
GetAgentShortNameByID g_getAgentShortName;

SetChangeCotationCallback g_SetChangeCotation;
SetAssetListCallback g_SetAssetList;
SetAssetListInfoCallback g_SetAssetListInfo;
SetAssetListInfoCallbackV2 g_SetAssetListInfoV2;
SetEnabledLogToDebug g_SetEnabledLog;

SendBuyOrder g_SendBuyOrder;
SendSellOrder g_SendSellOrder;
SendZeroPosition g_SendZeroPosition;
SendCancelAllOrders g_SendCancelAllOrders;
GetPosition g_GetPosition;
SendChangeOrder g_SendChangeOrder;
GetOrderProfitID g_GetOrderProfitID;
SendStopSellOrder g_SendStopSellOrder;
SetChangeStateTickerCallback g_SetChangeStateTickerCallback;
GetHistoryTrades g_GetHistoryTrades;
SetAdjustHistoryCallback g_SetAdjustHistoryCallback;
SetAdjustHistoryCallbackV2 g_SetAdjustHistoryCallbackV2;
SubscribeAdjustHistory g_SubscribeAdjustHistory;
UnsubscribeAdjustHistory g_UnsubscribeAdjustHistory;
SetTheoreticalPriceCallback g_SetTheoreticalPriceCallback;
GetLastDailyClose g_GetLastDailyClose;
SendMarketBuyOrder g_SendMarketBuyOrder;
SendMarketSellOrder g_SendMarketSellOrder; 

FreePointer g_FreePointer;

static HANDLE mutexTrades;
static std::vector<Trade> trades;
static HANDLE mutexTradesHist;
static std::vector<Trade> trades_hist;

static bool bMarketConnected;
static bool bAtivo;

// Callbacks
void __stdcall stateCallback(int nConnStateType, int result)
{
    if (nConnStateType == 0)
    { // notificacoes de login
        if (result == 0)
            printf("//Login: Conectado\n");
        if (result == 1)
            printf("//Login: Invalido\n");
        if (result == 2)
            printf("//Login: Senha invalida\n");
        if (result == 3)
            printf("//Login: Senha bloqueada\n");
        if (result == 4)
            printf("//Login: Senha Expirada\n");
        if (result == 200)
            printf("//Login: Erro Desconhecido\n");
    }
    if (nConnStateType == 1)
    { // notificacoes de broker
        if (result == 0)
            printf("//Broker Desconectado\n");
        if (result == 1)
            printf("//Broker Conectando\n");
        if (result == 2)
            printf("//Broker Conectado\n");
        if (result == 3)
            printf("//Broker HCS Desconectado\n");
        if (result == 4)
            printf("//Broker HCS Conectando\n");
        if (result == 5)
            printf("//Broker HCS Conectado\n");
    }

    if (nConnStateType == 2)
    { // notificacoes de login no Market
        if (result == 0)
            printf("//Market Desconectado\n");
        if (result == 1)
            printf("//Market Conectando\n");
        if (result == 2)
            printf("//Market csConnectedWaiting\n");
        if (result == 3)
        {
            bMarketConnected = false;
            printf("//Market N�o logado\n");
        }
        if (result == 4)
        {
            bMarketConnected = true;
            printf("//Market Conectado\n");
        }
    }

    if (nConnStateType == 3)
    { // notificacoes de login no Market
        if (result == 0)
        {
            //Atividade: Valida
            bAtivo = true;
            printf("//Profit Notificacao de Atividade Valida\n");
        }
        else
        {
            //Atividade: Invalida
            bAtivo = false;
            printf("//Profit Notificacao de Atividade Invalida\n");
        }
    }
}

static void tradePrint(Trade t)
{
    printf("Candle: Date= %02d/%02d/%02d %02d:%02d:%02d.%03d\n", t.date.day, t.date.month, t.date.year,
        t.date.hour, t.date.min, t.date.sec, t.date.mili);
}

void __stdcall newTradeCallback(TAssetID assetId, wchar_t* date, unsigned int tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType, wchar_t bIsEdit)
{
    Trade trade = { 0 };

    // Formato de data: 06/10/2020 16:54:52.003
    swscanf(date, L"%d/%d/%d %d:%d:%d.%d", &trade.date.day, &trade.date.month, &trade.date.year,
        &trade.date.hour, &trade.date.min, &trade.date.sec, &trade.date.mili);
    trade.asset = assetId.ticker;
    trade.price = price;
    trade.qtd = qtd;
    trade.volume = vol;

    // Salva trade no array
    DWORD w = WaitForSingleObject(mutexTrades, INFINITE);
    trades.push_back(trade);
    ReleaseMutex(mutexTrades);
}

void __stdcall newHistoryCallBack(TAssetID assetId, wchar_t* date, unsigned int tradeNumber, double price, double vol, int qtd, int buyAgent, int sellAgent, int tradeType)
{
    Trade trade = { 0 };

    // Formato de data: 06/10/2020 16:54:52.003
    swscanf(date, L"%d/%d/%d %d:%d:%d.%d", &trade.date.day, &trade.date.month, &trade.date.year,
        &trade.date.hour, &trade.date.min, &trade.date.sec, &trade.date.mili);
    trade.asset = assetId.ticker;
    trade.price = price;
    trade.qtd = qtd;
    trade.volume = vol;

    // Salva trade no history array
    DWORD w = WaitForSingleObject(mutexTradesHist, INFINITE);
    trades_hist.push_back(trade);
    ReleaseMutex(mutexTradesHist);
}

void __stdcall changeStateTickerCallback(TAssetID assetId, wchar_t* date, int nState)
{
    printf("ChangeState callback\n");
}

void __stdcall newDailyCallback(TAssetID assetId, wchar_t* date,
    double sOpen, double sHigh, double sLow, double sClose, double sVol, double sAjuste, double sMaxLimit, double sMinLimit, double sVolBuyer, double sVolSeller,
    int nQtd, int nNegocios, int nContratosOpen, int nQtdBuyer, int nQtdSeller, int nNegBuyer, int nNegSeller)
{
    printf("New daily callback\n");
}

void __stdcall priceBookCallback(TAssetID assetId,
    int nAction, int nPosition, int Side, int nQtd, int nCount,
    double sPrice,
    void* pArraySell, void* pArrayBuy)
{
    printf("priceBookCallback\n");
}

typedef struct {
    int qtd;
    __int64 offer_id;
    int agent;
    double price;
    char date_offer[64];
} BookOffer;

static std::vector<BookOffer> offer_buy_list;
static std::vector<BookOffer> offer_sell_list;

void descriptaOfferArray(void* ptr, std::vector<BookOffer>& offer_list)
{
    offer_list.clear();

    char* at = (char*)ptr;
    int qtd = *(int*)at;
    at += 4;
    int tam = *(int*)at;
    at += 4;

    for (int i = 0; i < qtd; ++i)
    {
        BookOffer offer = { 0 };
        offer.price = *(double*)at;
        at += 8;
        offer.qtd = *(int*)at;
        at += 4;
        offer.agent = *(int*)at;
        at += 4;
        offer.offer_id = *(__int64*)at;
        at += 8;
        short length = *(short*)at;
        at += 2;

        if (length > 0)
        {
            memcpy(offer.date_offer, at, length);
        }
        at += length;
        offer_list.push_back(offer);
    }
    assert((at - (char*)ptr) == tam);  // devem ser iguais
    g_FreePointer(ptr, at - (char*)ptr);
}

typedef enum {
    BOOK_ACTION_ADD = 0,
    BOOK_ACTION_EDIT = 1,
    BOOK_ACTION_DELETE = 2,
    BOOK_ACTION_DELETE_FROM = 3,
    BOOK_ACTION_FULLBOOK = 4,
} BookAction;

typedef enum {
    OFFER_BUY = 0,
    OFFER_SELL = 1,
} OfferSide;

void __stdcall offerBookCallback(TAssetID assetId,
    int nAction, int nPosition, int Side, int nQtd, int nAgent, __int64 nOfferID,
    double dPrice,
    int bHasPrice, int bHasQtd, int bHasDate, int bHasOfferID, int bHasAgent,
    wchar_t* date,
    void* pArraySell, void* pArrayBuy)
{
    std::vector<BookOffer>& book_list = (Side == OFFER_BUY) ? offer_buy_list : offer_sell_list;

    BookOffer offer = { 0 };
    offer.agent = nAgent;
    offer.offer_id = nOfferID;
    offer.price = dPrice;
    offer.qtd = nQtd;
    memcpy(offer.date_offer, date, MAX(wcslen(date), sizeof(offer.date_offer)));

    switch (nAction)
    {
    case BOOK_ACTION_ADD: {
        if (nPosition >= 0 && nPosition < book_list.size())
        {
            book_list.insert(book_list.end() - nPosition, offer);
        }
    } break;
    case BOOK_ACTION_EDIT: {
        if (nPosition >= 0 && nPosition < book_list.size())
        {
            if (bHasQtd)
                book_list[book_list.size() - 1 - nPosition].qtd += offer.qtd;
            if (bHasAgent)
                book_list[book_list.size() - 1 - nPosition].agent = offer.agent;
            if (bHasPrice)
                book_list[book_list.size() - 1 - nPosition].price = offer.price;
            if (bHasOfferID)
                book_list[book_list.size() - 1 - nPosition].offer_id = offer.offer_id;
        }
    } break;
    case BOOK_ACTION_DELETE: {
        if (nPosition >= 0 && nPosition < book_list.size())
        {
            book_list.erase(book_list.end() - nPosition - 1);
        }
    } break;
    case BOOK_ACTION_DELETE_FROM: {
        if (nPosition >= 0 && nPosition < book_list.size())
        {
            book_list.resize(book_list.size() - nPosition - 1);
        }
    } break;
    case BOOK_ACTION_FULLBOOK: {
        if (pArrayBuy != 0)
        {
            descriptaOfferArray(pArrayBuy, offer_buy_list);
        }
        if (pArraySell != 0)
        {
            descriptaOfferArray(pArraySell, offer_sell_list);
        }
    } break;
    default: fprintf(stderr, "Book action %d invalida\n", nAction);
    }
}

void __stdcall orderChangeCallBack(TAssetID assetId,
    int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side,
    double sPrice, double sStopPrice, double sAvgPrice,
    __int64 nProfitID,
    wchar_t* TipoOrdem, wchar_t* Conta, wchar_t* Titular, wchar_t* ClOrdID, wchar_t* Status, wchar_t* Date, wchar_t* TextMessage)
{
    printf("orderChangeCallBack: ");
    wprintf(L"ClorID: %s, ProfitID: %lld, price: %f, stopPrice: %f\n", ClOrdID, nProfitID, sPrice, sStopPrice);
}

void __stdcall accountCallback(int nCorretora,
    wchar_t* CorretoraNomeCompleto, wchar_t* AccountID, wchar_t* NomeTitular)
{
    wprintf(L"Account: Corretora: %s, AccountID: %s\n", CorretoraNomeCompleto, AccountID);
}

void __stdcall progressCallBack(TAssetID assetId, int nProgress)
{
    printf("Progress: %d\n", nProgress);
}

void __stdcall newTinyBookCallBack(TAssetID assetId, double price, int qtd, int side)
{
    // Implementar
}

void __stdcall historyCallBack(TAssetID AssetID,
    int nCorretora, int nQtd, int nTradedQtd, int nLeavesQtd, int Side,
    double sPrice, double sStopPrice, double sAvgPrice,
    __int64 nProfitID,
    wchar_t* TipoOrdem, wchar_t* Conta, wchar_t* Titular, wchar_t* ClOrdID, wchar_t* Status, wchar_t* Date)
{
    printf("historyCallBack\n");
}

void __stdcall assetListInfoCallback(TAssetID assetId, wchar_t* strName, wchar_t* strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote,
    int stSecurityType, int stSecuritySubType, double sMinPriceIncrement, double sContractMultiplier, wchar_t* strDate, wchar_t* strISIN)
{
    wprintf(L"Ticker: %s, Asset: %s, min order: %d, max order: %d, lote %d, min incr: %f, contract mult: %f, type: %d, subtype: %d\n",
        assetId.ticker, strName, nMinOrderQtd, nMaxOrderQtd, nLote, sMinPriceIncrement, sContractMultiplier, stSecurityType, stSecuritySubType);
}

void __stdcall assetListInfoCallbackV2(TAssetID assetId, wchar_t* strName, wchar_t* strDescription, int nMinOrderQtd, int nMaxOrderQtd, int nLote,
    int stSecurityType, int stSecuritySubType, double sMinPriceIncrement, double sContractMultiplier, wchar_t* strDate, wchar_t* strISIN,
    wchar_t* strSetor, wchar_t* strSubSetor, wchar_t* strSegmento)
{
    wprintf(L"Ticker: %s, Asset: %s, min order: %d, max order: %d, lote %d, min incr: %f, contract mult: %f, type: %d, subtype: %d, setor: %s, subsetor: %s, segmento: %s\n",
        assetId.ticker, strName, nMinOrderQtd, nMaxOrderQtd, nLote, sMinPriceIncrement, sContractMultiplier, stSecurityType, stSecuritySubType, strSetor, strSubSetor, strSegmento);
}

void __stdcall adjustHistoryCallback(TAssetID assetId, double sValue, wchar_t* strAdjustType, wchar_t* strObserv, wchar_t* dtAjuste, wchar_t* dtDeliber, wchar_t* dtPagamento, int nAffectPrice)
{
    wprintf(L"Ticker: %s, Valor: %f, Tipo ajuste: %s, Observacao: %s, Data do ajuste: %s, Data deliberacao: %s, Data pagamento: %s, Afeta preco: %d\n",
        assetId.ticker, sValue, strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento, nAffectPrice);
}

void __stdcall adjustHistoryCallbackV2(TAssetID assetId, double sValue, wchar_t* strAdjustType, wchar_t* strObserv, wchar_t* dtAjuste, wchar_t* dtDeliber, wchar_t* dtPagamento, int nFlags, double dMult)
{
    wprintf(L"Ticker: %s, Valor: %f, Tipo ajuste: %s, Observacao: %s, Data do ajuste: %s, Data deliberacao: %s, Data pagamento: %s, Flags: %d, Multiplier: %f\n",
        assetId.ticker, sValue, strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento, nFlags, dMult);
}


void __stdcall theoreticalPriceCallback(TAssetID assetId, double dTheoreticalPrice, __int64 nTheoreticalQtd)
{
    wprintf(L"Theoretical price Ticker= %s, %f\n", assetId.ticker, dTheoreticalPrice);
}

static void PrintPosition(void* pos)
{
    char* start = (char*)pos;
    char* at = (char*)pos;
    int qtdContas = *(int*)at;
    if (qtdContas == 0)
    {
        printf("Sem posicao no ativo\n");
        return;
    }

    printf("Quantidade de contas: %d\n", qtdContas);
    at += 4;
    int bufferSize = *(int*)at;
    printf("Tamanho do buffer:    %d\n", bufferSize);
    at += 4;

    for (int i = 0; i < qtdContas; ++i)
    {
        Position position = { 0 };

        position.corretora_id = *(int*)at;
        at += 4;

        position.account_id.length = *(short*)at;
        at += 2;
        position.account_id.data = at;
        at += position.account_id.length;

        position.titular.length = *(short*)at;
        at += 2;
        position.titular.data = at;
        at += position.titular.length;

        position.ticker.length = *(short*)at;
        at += 2;
        position.ticker.data = at;
        at += position.ticker.length;

        position.intraday_position = *(int*)at;
        at += 4;

        position.price = *(double*)at;
        at += 8;

        position.avg_sell_price = *(double*)at;
        at += 8;

        position.sell_qtd = *(int*)at;
        at += 4;

        position.avg_buy_price = *(double*)at;
        at += 8;

        position.buy_qtd = *(int*)at;
        at += 4;

        position.custody_d1 = *(int*)at;
        at += 4;

        position.custody_d2 = *(int*)at;
        at += 4;

        position.custody_d3 = *(int*)at;
        at += 4;

        position.blocked = *(int*)at;
        at += 4;

        position.pending = *(int*)at;
        at += 4;

        position.allocated = *(int*)at;
        at += 4;

        position.provisioned = *(int*)at;
        at += 4;

        position.qtd_position = *(int*)at;
        at += 4;

        position.available = *(int*)at;
        at += 4;

        printf("ID da corretora:      %d\n", position.corretora_id);
        printf("ID da conta:          %.*s\n", position.account_id.length, position.account_id.data);
        printf("Titular:              %.*s\n", position.titular.length, position.titular.data);
        printf("Ticker:               %.*s\n", position.ticker.length, position.ticker.data);
        printf("Posicao Intraday:     %d\n", position.intraday_position);
        printf("Preco:                %f\n", position.price);
        printf("Preco medio venda:    %f\n", position.avg_sell_price);
        printf("Quantidade venda:     %d\n", position.sell_qtd);
        printf("Preco medio compra:   %f\n", position.avg_buy_price);
        printf("Quantidade compra:    %d\n", position.buy_qtd);
        printf("Custodia em D+1:      %d\n", position.custody_d1);
        printf("Custodia em D+2:      %d\n", position.custody_d2);
        printf("Custodia em D+3:      %d\n", position.custody_d3);
        printf("Bloqueado:            %d\n", position.blocked);
        printf("Pendente:             %d\n", position.pending);
        printf("Alocada:              %d\n", position.allocated);
        printf("Provisionada:         %d\n", position.provisioned);
        printf("Quantidade posicao:   %d\n", position.qtd_position);
        printf("Disponivel:           %d\n", position.available);
    }

    g_FreePointer(start, bufferSize);
}

// ----------------------------------------------
// ----------------------------------------------

bool SubscribeAsset(wchar_t* assetName, wchar_t* bolsa)
{
    if (g_subscribe(assetName, bolsa) != NL_OK)
    {
        wprintf(L"Nao foi possivel subscrever %s\n", assetName);
        return false;
    }
    else
    {
        wprintf(L"Inscrito em %s\n", (wchar_t*)assetName);
        return true;
    }
}

static TradeCandle lastCandle = { 0 };
static double lastPrice;
void ProcessRealTimeTrade(FILE* file, bool print)
{
    WaitForSingleObject(mutexTrades, INFINITE);

    static int lastMin = 0;
    static int lastSec = 0;
    static double maxPrice = 0.0;
    static double minPrice = 0.0;

    for (size_t i = 0; i < trades.size(); ++i)
    {
        if (trades[i].price > maxPrice)
            maxPrice = trades[i].price;
        if (trades[i].price < minPrice)
            minPrice = trades[i].price;

        lastPrice = trades[i].price;
        if (trades[i].date.sec != lastSec)
        {
            Date d = lastCandle.date;

            if (print)
            {
                fprintf(file, "New Trade: Date=%d/%d/%d %d:%d:%d.%d: Open=%f, Close=%f, Max=%f, Min=%f, Qtd=%d, Vol=%f, Neg=%d\n",
                    d.day, d.month, d.year, d.hour, d.min, d.sec, d.mili,
                    lastCandle.open, lastCandle.close, lastCandle.max, lastCandle.min,
                    lastCandle.qtd, lastCandle.volume, lastCandle.neg);
            }

            // forma o próximo candle
            lastCandle.open = trades[i].price;
            lastCandle.date = trades[i].date;
            lastCandle.max = trades[i].price;
            lastCandle.min = trades[i].price;
            lastCandle.qtd = 0;
            lastCandle.volume = 0;
            lastCandle.neg = 0;
            lastCandle.asset = trades[i].asset;

            lastSec = trades[i].date.sec;
        }
        lastCandle.close = trades[i].price; // é sobrescrito a cada trade até que se tenha um candle
        lastCandle.volume += trades[i].volume;
        lastCandle.qtd += trades[i].qtd;
        lastCandle.neg++;
    }
    trades.clear();

    ReleaseMutex(mutexTrades);
}

void ProcessHistoryTrade()
{
    // TODO: Implementar
    WaitForSingleObject(mutexTradesHist, INFINITE);

    for (size_t i = 0; i < trades_hist.size(); ++i)
    {
        tradePrint(trades_hist[i]);
    }
    trades_hist.clear();

    ReleaseMutex(mutexTradesHist);
}

// Aleatoriamente, uma chance em 2000 a cada vez que essa função é chamada, executa
// uma ordem de compra ou venda. Ao chamar uma segunda vez, se position for diferente
// de zero, zera a posição e cancela todas ordens pendentes.
// Exemplo baseado no ativo do mini índice WIN
void ProcessSendOrders(wchar_t* accountID, wchar_t* corretora, wchar_t* password, wchar_t* asset, wchar_t* bolsa)
{
    static int position;
    if (!(accountID && corretora))
    {
        // não é possível fazer ordens ainda, não foi recebido o
        // callback com informações da corretora
        return;
    }

    // Apenas um exemplo, não é garantido que as ordens serão executadas,
    // para isso, chamar GetPosition para verificar se foram executadas ou não.

    int chance = 2000;
    int r = rand() % chance;
    int buyOrSell = rand() % 1000;
    if (r == 1)
    {
        printf("Enviando ordem...\n");
        if (position != 0)
        {
            printf("Encerrando posicao %s de %d ativo(s)\n", (position > 0) ? "comprada" : "vendida", (position < 0) ? -position : position);
            double offset = (position > 0) ? -500.0 : 500.0;    // dar folga pra baixo para vender e pra cima para comprar
            // Encerra posição
            if (g_SendZeroPosition(accountID, corretora, asset, bolsa, password, lastPrice + offset) == -1)
                fprintf(stderr, "Erro ao enviar zerar posicao\n");
            else
                position = 0;

            // Cancela todas ordens pendentes
            char err = g_SendCancelAllOrders(accountID, corretora, password);
            if (err != NL_OK)
            {
                fprintf(stderr, "Falha ao cancelar todas ordens pendentes %d\n", (int)err);
            }
        }
        else
        {
            if (buyOrSell >= 500) // 50% de chance de comprar e 50% de vender
            {
                // tenta compra
                printf("Ordem de compra a %f\n", lastPrice + 100.0);
                if (g_SendBuyOrder(accountID, corretora, password, asset, bolsa, (double)lastPrice + 100.0, 1) == -1)
                {
                    fprintf(stderr, "Erro ao enviar ordem de compra\n");
                }
                else
                    position++;
            }
            else
            {
                // tenta vender
                printf("Ordem de venda a %f\n", lastPrice - 100.0);
                if (g_SendSellOrder(accountID, corretora, password, asset, bolsa, (double)lastPrice - 100.0, 1) == -1)
                {
                    fprintf(stderr, "Erro ao enviar ordem de venda\n");
                }
                else
                    position--;
            }
        }
    }
}

int loadDll(const char* name)
{
    HINSTANCE hdl = LoadLibraryA(name);
    if (hdl == 0)
        return -1;

    g_initialize = reinterpret_cast<DLLInitializeLogin>(GetProcAddress(hdl, "DLLInitializeLogin"));
    g_initializeMarket = reinterpret_cast<DLLInitializeMarketLogin>(GetProcAddress(hdl, "DLLInitializeMarketLogin"));
    g_setServerAndPort = reinterpret_cast<SetServerAndPort>(GetProcAddress(hdl, "SetServerAndPort"));
    g_GetServerClock = reinterpret_cast<GetServerClock>(GetProcAddress(hdl, "GetServerClock"));
    g_finalize = reinterpret_cast<Finalize>(GetProcAddress(hdl, "DLLFinalize"));
    g_subscribe = reinterpret_cast<SubscribeTicker>(GetProcAddress(hdl, "SubscribeTicker"));
    g_unsubscribe = reinterpret_cast<UnsubscribeTicker>(GetProcAddress(hdl, "UnsubscribeTicker"));
    g_getAgentName = reinterpret_cast<GetAgentNameByID>(GetProcAddress(hdl, "GetAgentNameByID"));
    g_getAgentShortName = reinterpret_cast<GetAgentShortNameByID>(GetProcAddress(hdl, "GetAgentShortNameByID"));
    g_subscribePrice = reinterpret_cast<SubscribePriceBook>(GetProcAddress(hdl, "SubscribePriceBook"));
    g_subscribeOffer = reinterpret_cast<SubscribeOfferBook>(GetProcAddress(hdl, "SubscribeOfferBook"));
    g_SendBuyOrder = reinterpret_cast<SendBuyOrder>(GetProcAddress(hdl, "SendBuyOrder"));
    g_SendSellOrder = reinterpret_cast<SendSellOrder>(GetProcAddress(hdl, "SendSellOrder"));
    g_SendZeroPosition = reinterpret_cast<SendZeroPosition>(GetProcAddress(hdl, "SendZeroPosition"));
    g_SendCancelAllOrders = reinterpret_cast<SendCancelAllOrders>(GetProcAddress(hdl, "SendCancelAllOrders"));
    g_GetPosition = reinterpret_cast<GetPosition>(GetProcAddress(hdl, "GetPosition"));
    g_SetAssetList = reinterpret_cast<SetAssetListCallback>(GetProcAddress(hdl, "SetAssetListCallback"));
    g_SendChangeOrder = reinterpret_cast<SendChangeOrder>(GetProcAddress(hdl, "SendChangeOrder"));
    g_GetOrderProfitID = reinterpret_cast<GetOrderProfitID>(GetProcAddress(hdl, "GetOrderProfitID"));
    g_SetAssetListInfo = reinterpret_cast<SetAssetListInfoCallback>(GetProcAddress(hdl, "SetAssetListInfoCallback"));
    g_SetAssetListInfoV2 = reinterpret_cast<SetAssetListInfoCallbackV2>(GetProcAddress(hdl, "SetAssetListInfoCallbackV2"));
    g_FreePointer = reinterpret_cast<FreePointer>(GetProcAddress(hdl, "FreePointer"));
    g_SendStopSellOrder = reinterpret_cast<SendStopSellOrder>(GetProcAddress(hdl, "SendStopSellOrder"));
    g_SetChangeStateTickerCallback = reinterpret_cast<SetChangeStateTickerCallback>(GetProcAddress(hdl, "SetChangeStateTickerCallback"));
    g_GetHistoryTrades = reinterpret_cast<GetHistoryTrades>(GetProcAddress(hdl, "GetHistoryTrades"));
    g_SetAdjustHistoryCallback = reinterpret_cast<SetAdjustHistoryCallback>(GetProcAddress(hdl, "SetAdjustHistoryCallback"));
    g_SetAdjustHistoryCallbackV2 = reinterpret_cast<SetAdjustHistoryCallbackV2>(GetProcAddress(hdl, "SetAdjustHistoryCallbackV2"));
    g_SubscribeAdjustHistory = reinterpret_cast<SubscribeAdjustHistory>(GetProcAddress(hdl, "SubscribeAdjustHistory"));
    g_UnsubscribeAdjustHistory = reinterpret_cast<SubscribeAdjustHistory>(GetProcAddress(hdl, "UnsubscribeAdjustHistory"));
    g_SetTheoreticalPriceCallback = reinterpret_cast<SetTheoreticalPriceCallback>(GetProcAddress(hdl, "SetTheoreticalPriceCallback"));
    g_GetLastDailyClose = reinterpret_cast<GetLastDailyClose>(GetProcAddress(hdl, "GetLastDailyClose"));
    g_SendMarketBuyOrder = reinterpret_cast<SendMarketBuyOrder>(GetProcAddress(hdl, "SendMarketBuyOrder"));		
    g_SendMarketSellOrder = reinterpret_cast<SendMarketSellOrder>(GetProcAddress(hdl, "SendMarketSellOrder")); 

    if (!g_initialize || !g_initializeMarket || !g_finalize || !g_subscribe
        || !g_unsubscribe || !g_getAgentName || !g_getAgentShortName || !g_subscribePrice
        || !g_subscribeOffer || !g_SendBuyOrder || !g_SendSellOrder || !g_SendZeroPosition
        || !g_SendCancelAllOrders || !g_GetPosition || !g_SetAssetList
        || !g_SetAssetListInfo || !g_FreePointer || !g_SendStopSellOrder || !g_SetChangeStateTickerCallback
        || !g_GetHistoryTrades || !g_SetAdjustHistoryCallbackV2 || !g_SubscribeAdjustHistory
        || !g_UnsubscribeAdjustHistory || !g_SetTheoreticalPriceCallback)
    {
        return -1;
    }
    return 0;
}

int initializeDll(wchar_t* key, wchar_t* username, wchar_t* password)
{
    if (g_initialize(key, username, password, stateCallback, historyCallBack, orderChangeCallBack, accountCallback, newTradeCallback, newDailyCallback,
        priceBookCallback, offerBookCallback, newHistoryCallBack, progressCallBack, newTinyBookCallBack) != NL_OK)
    {
        fprintf(stderr, "Erro inicializando roteamento\n");
        return -1;
    }

    if (g_SetAssetListInfoV2(assetListInfoCallbackV2) != NL_OK)
    {
        fprintf(stderr, "Erro inicializando assetListInfoCallbackV2\n");
        return -1;
    }

    if (g_SetChangeStateTickerCallback(changeStateTickerCallback) != NL_OK)
    {
        printf("Nao foi possivel setar changeStateTickerCallback\n");
    }

    if (g_SetAdjustHistoryCallbackV2(adjustHistoryCallbackV2) != NL_OK)
    {
        printf("Nao foi possivel setar adjustHistoryCallbackV2\n");
    }

    if (g_SetTheoreticalPriceCallback(theoreticalPriceCallback) != NL_OK)
    {
        printf("Nao foi possivel setar theoreticalPriceCallback\n");
    }

    return 0;
}

int main()
{
    srand((unsigned int)time(0));

    // Cria mutexes para acessar dados compartilhados escritos pelos callbacks
    // e lidos pela main thread
    mutexTrades = CreateMutexA(NULL, FALSE, NULL);
    mutexTradesHist = CreateMutexA(NULL, FALSE, NULL);

    // Carrega dll e funções
    const char* dllpath = "ProfitDLL.dll";          // Preencher com a localização do dll no sistema de arquivos
    wchar_t* activation_key = (wchar_t*)L"XXXX";    // Preencher chave de ativação
    wchar_t* username = (wchar_t*)L"XXXX";          // Usuário da conta (email ou documento)
    wchar_t* acc_password = (wchar_t*)L"XXXX";      // Senha da conta
    wchar_t* corretora = (wchar_t*)L"XXXX";         // Pode ser obtido através do accountCallback, chamando a função GetAccount
    wchar_t* accountID = (wchar_t*)L"XXXX";         // Pode ser obtido através do accountCallback, chamando a função GetAccount
    wchar_t* asset = (wchar_t*)L"PETR4";
    wchar_t* bolsa = (wchar_t*)L"B";
    wchar_t* rot_password = (wchar_t*)L"XXXX";      // Preencher senha do roteamento

    if (loadDll(dllpath) == -1)
    {
        fprintf(stderr, "Nao foi possivel carregar dll, verifique se o caminho especificado esta correto: %s\n", dllpath);
        return -1;
    }

    if (initializeDll(activation_key, username, acc_password) == -1)
        return -1;

    bool isSubscribed = false;
    while (true)
    {
        if (bMarketConnected && bAtivo)
        {
            if (!isSubscribed)
            {
                isSubscribed = SubscribeAsset(asset, bolsa);

                // Descomentar para solicitar offer book
                /*
                if (g_subscribeOffer(asset, bolsa) != NL_OK)
                {
                    g_subscribeOffer(asset, bolsa);
                    isSubscribed = true;
                }
                */

                // Descomentar para solicitar histórico de trades em um período
                /*
                if (g_GetHistoryTrades(asset, bolsa, (wchar_t*)L"12/01/2021", (wchar_t*)L"13/01/2021") != NL_OK)
                {
                    printf("Nao foi possivel requisitar historico de trades\n");
                }
                */

                // Descomentar para receber histórico de ajustes
                
                /*
                if (g_SubscribeAdjustHistory(asset, bolsa) != NL_OK)
                {
                    printf("Nao foi possivel inscrever no historico de ajustes\n");
                }
                */
            }

            // Processa dados de histórico de trades recebidos
            //ProcessHistoryTrade();

            // Processa lista de trades recebidos em tempo real
            ProcessRealTimeTrade(stdout, true);

            // Algoritmo de compra e venda aleatório
            //ProcessSendOrders(accountID, corretora, rot_password, asset, bolsa);
        }

        // Escape para sair
        if (GetAsyncKeyState(VK_ESCAPE))
        {
            break;
        }
        Sleep(10);  // Afeta taxa de envio de ordens do exemplo
    }

    g_finalize();

    if (mutexTrades && mutexTradesHist)
    {
        CloseHandle(mutexTrades);
        CloseHandle(mutexTradesHist);
    }

    return 0;
}
