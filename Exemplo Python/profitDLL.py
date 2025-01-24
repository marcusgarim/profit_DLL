#Imports para execução da DLL
import time
import gc
from ctypes import *
from ctypes.wintypes import UINT
import struct
from datetime import*

#Caminho para a DLL, python tem que ser 32bits
profit_dll = WinDLL('./ProfitDLL.dll')
profit_dll.argtypes  = None

# Error Codes
NL_OK                 = 0x00000000;  # OK
NL_INTERNAL_ERROR     = 0x80000001;  # Internal error
NL_NOT_INITIALIZED    = 0x80000002;  # Not initialized
NL_INVALID_ARGS       = 0x80000003;  # Invalid arguments
NL_WAITING_SERVER     = 0x80000004;  # Aguardando dados do servidor

# @dataclass
class TAssetID(Structure):
    _fields_ = [("ticker", c_wchar_p),
                ("bolsa", c_wchar_p),
                ("feed", c_int)]

# @dataclass
class TGroupOffer(Structure):
    _fields_ = [("nPosition", c_int),
                ("nQtd", c_int),
                ("nOfferID", c_int),
                ("nAgent", c_int),
                ("sPrice", c_double),
                ("strDtOffer", c_int)]


# @dataclass
class TGroupPrice(Structure):
    _fields_ = [("nQtd", c_int),
                ("nCount", c_int),
                ("sPrice", c_double)]

# @dataclass
class TNewTradeCallback(Structure):
    _fields_ = [("assetId", TAssetID),
                ("date", c_wchar_p),
                ("tradeNumber", c_uint),
                ("price", c_double),
                ("vol", c_double),
                ("qtd", c_int),
                ("buyAgent", c_int),
                ("sellAgent", c_int),
                ("tradeType", c_int),
                ("bIsEdit", c_int)]

class TTheoreticalPriceCallback(Structure):
    _fields_ = [("assetId", TAssetID),
                ("dTheoreticalPrice", c_double),
                ("nTheoreticalQtd", c_uint)]

# @dataclass
class TNewDailyCallback(Structure):
    _fields_ = [("tAssetIDRec", TAssetID),
                ("date", c_wchar_p),
                ("sOpen", c_double),
                ("sHigh", c_double),
                ("sLow", c_double),
                ("sClose", c_double),
                ("sVol", c_double),
                ("sAjuste", c_double),
                ("sMaxLimit", c_double),
                ("sMinLimit", c_double),
                ("sVolBuyer", c_double),
                ("sVolSeller", c_double),
                ("nQtd", c_int),
                ("nNegocios", c_int),
                ("nContratosOpen", c_int),
                ("nQtdBuyer", c_int),
                ("nQtdSeller", c_int),
                ("nNegBuyer", c_int),
                ("nNegSeller", c_int)]



# @dataclass
class TNewHistoryCallback(Structure):
    _fields_ = [("assetId", TAssetID),
                ("date", c_wchar_p),
                ("tradeNumber", c_uint),
                ("price", c_double),
                ("vol", c_double),
                ("qtd", c_int),
                ("buyAgent", c_int),
                ("sellAgent", c_int),
                ("tradeType", c_int)]



# @dataclass
class TProgressCallBack(Structure):
    _fields_ = [("assetId", TAssetID),
                ("nProgress", c_int)]


# @dataclass
class TNewTinyBookCallBack(Structure):
    _fields_ = [("assetId", TAssetID),
                ("price", c_double),
                ("qtd", c_int),
                ("side", c_int)]



# @dataclass
class TPriceBookCallback(Structure):
    _fields_ = [("assetId", TAssetID),
                ("nAction", c_int),
                ("nPosition", c_int),
                ("side", c_int),
                ("nQtd", c_int),
                ("ncount", c_int),
                ("sprice", c_double),
                ("pArraySell", POINTER(c_int)),
                ("pArrayBuy", POINTER(c_int))]



# @dataclass
class TOfferBookCallback(Structure):
    _fields_ = [("assetId", TAssetID),
                ("nAction", c_int),
                ("nPosition", c_int),
                ("side", c_int),
                ("nQtd", c_int),
                ("nAgent", c_int),
                ("nOfferID", c_longlong),
                ("sPrice", c_double),
                ("bHasPrice", c_int),
                ("bHasQtd", c_int),
                ("bHasDate", c_int),
                ("bHasOfferId", c_int),
                ("bHasAgent", c_int),
                ("date", c_wchar_p),
                ("pArraySell", POINTER(c_int)),
                ("pArrayBuy", POINTER(c_int))]


#Variaveis de Controle 
bAtivo = False
bMarketConnected = False
bConnectado = False
bBrokerConnected = False
nCount = 0

#BEGIN DEF
@WINFUNCTYPE(None, c_int32, c_int32)
def stateCallback(nType, nResult):
    global bAtivo
    global bMarketConnected
    global bConnectado
    
    nConnStateType = nType
    result = nResult
        
    if nConnStateType == 0: # notificacoes de login
        if result == 0:
            bConnectado = True
            print("Login: conectado")
        else :
            bConnectado = False
            print('Login: ' + str(result))
    elif nConnStateType == 1:
        if result == 5:
            # bBrokerConnected = True
            print("Broker: Conectado.")            
        elif result > 2:
            # bBrokerConnected = False
            print("Broker: Sem conexão com corretora.")            
        else:
            # bBrokerConnected = False
            print("Broker: Sem conexão com servidores (" + str(result) + ")")
            
    elif nConnStateType == 2:  # notificacoes de login no Market
        if result == 4:
            print("Market: Conectado" )        
            bMarketConnected = True
        else:
            print("Market: " + str(result))
            bMarketConnected = False

    elif nConnStateType == 3: # notificacoes de login
        if result == 0:
            print("Ativação: OK")
            bAtivo = True
        else:
            print("Ativação: " + str(result))
            bAtivo = False    
        
    if bMarketConnected and bAtivo and bConnectado:
        print("Serviços Conectados")

    return

@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_uint, c_double, c_double, c_int, c_int, c_int, c_int)
def newHistoryCallback(assetId, date, tradeNumber, price, vol, qtd, buyAgent, sellAgent, tradeType):    
    print(assetId.ticker + ' | Trade History | ' + date + ' (' + str(tradeNumber) + ') ' + str(price))
    return

@WINFUNCTYPE(None, TAssetID, c_int)
def progressCallBack(assetId, nProgress):
    print(assetId.ticker + ' | Progress | ' + str(nProgress))
    return

@WINFUNCTYPE(None, c_int, c_wchar_p, c_wchar_p, c_wchar_p)
def accountCallback(nCorretora, corretoraNomeCompleto, accountID, nomeTitular):
    print("Conta | " + accountID + ' - ' + nomeTitular + ' | Corretora ' + str(nCorretora) + ' - ' + corretoraNomeCompleto)
    return

@WINFUNCTYPE(None, TAssetID, c_int, c_int, c_int, c_int, c_int, c_double, POINTER(c_int), POINTER(c_int))
def priceBookCallback(assetId, nAction, nPosition, Side, nQtd, nCount, sPrice, pArraySell, pArrayBuy):
    if pArraySell is not None:
        print("todo - priceBookCallBack")
    return


@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_uint, c_double, c_double, c_int, c_int, c_int, c_int, c_wchar)
def newTradeCallback(assetId, date, tradeNumber, price, vol, qtd, buyAgent, sellAgent, tradeType, bIsEdit):
    print(assetId.ticker + ' | Trade | ' + str(date) + '(' + str(tradeNumber) + ') ' + str(price))
    return


@WINFUNCTYPE(None, TAssetID, c_double, c_int, c_int)
def newTinyBookCallBack(assetId, price, qtd, side):
    if side == 0 :
        print(assetId.ticker + ' | TinyBook | Buy: ' + str(price) + ' ' + str(qtd))
    else :
        print(assetId.ticker + ' | TinyBook | Sell: ' + str(price) + ' ' + str(qtd))
        
    return


@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_double, c_double, c_double, c_double, c_double, c_double, c_double, c_double, c_double,
           c_double, c_int, c_int, c_int, c_int, c_int, c_int, c_int)
def newDailyCallback(assetID, date, sOpen, sHigh, sLow, sClose, sVol, sAjuste, sMaxLimit, sMinLimit, sVolBuyer,
                     sVolSeller, nQtd, nNegocios, nContratosOpen, nQtdBuyer, nQtdSeller, nNegBuyer, nNegSeller):
    print(assetID.ticker + ' | DailySignal | ' + date + ' Open: ' + str(sOpen) + ' High: ' + str(sHigh) + ' Low: ' + str(sLow) + ' Close: ' + str(sClose))
    return

price_array_sell = []
price_array_buy = []

def descript_price_array(price_array):
    global profit_dll

    price_array_descripted = []
    n_qtd = price_array[0]
    n_tam = price_array[1]
    print(f"qtd: {n_qtd}, n_tam: {n_tam}")

    arr = cast(price_array, POINTER(c_char))
    frame = bytearray()
    for i in range(n_tam):
        c = arr[i]
        frame.append(c[0])
    
    start = 8
    for i in range(n_qtd):
        price = struct.unpack('d', frame[start:start + 8])[0]
        start += 8
        qtd = struct.unpack('i', frame[start:start+4])[0]
        start += 4
        agent = struct.unpack('i', frame[start:start+4])[0]
        start += 4
        offer_id = struct.unpack('q', frame[start:start+8])[0]
        start += 8
        date_length = struct.unpack('h', frame[start:start+2])[0]
        start += 2
        date = frame[start:start+date_length]
        start += date_length

        price_array_descripted.append([price, qtd, agent, offer_id, date])

    return price_array_descripted

@WINFUNCTYPE(None, TAssetID, c_int, c_int, c_int, c_int, c_int, c_longlong, c_double, c_int, c_int, c_int, c_int, c_int,
           c_wchar_p, POINTER(c_int), POINTER(c_int))
def offerBookCallback(assetId, nAction, nPosition, Side, nQtd, nAgent, nOfferID, sPrice, bHasPrice,
                      bHasQtd, bHasDate, bHasOfferID, bHasAgent, date, pArraySell, pArrayBuy):
    global price_array_buy
    global price_array_sell

    if bool(pArraySell):
        price_array_sell = descript_price_array(pArraySell)

    if bool(pArrayBuy):
        price_array_buy = descript_price_array(pArrayBuy)

    if Side == 0:
        lst_book = price_array_buy
    else:
        lst_book = price_array_sell

    if lst_book and 0 <= nPosition <= len(lst_book):
        """
        atAdd = 0
        atEdit = 1
        atDelete = 2
        atDeleteFrom = 3
        atFullBook = 4
        """
        if nAction == 0:
            group = [sPrice, nQtd, nAgent]
            idx = len(lst_book)-nPosition
            lst_book.insert(idx, group)
        elif nAction == 1:
            group = lst_book[-nPosition - 1]
            group[1] = group[1] + nQtd
            group[2] = group[2] + nAgent
        elif nAction == 2:
            del lst_book[-nPosition - 1]
        elif nAction == 3:
            del lst_book[-nPosition - 1:]
    return


@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_uint, c_double)
def changeCotationCallback(assetId, date, tradeNumber, sPrice):
    print("todo - changeCotationCallback")
    return

@WINFUNCTYPE(None, TAssetID, c_wchar_p)
def assetListCallback(assetId, strName):
    print ("assetListCallback Ticker=" + str(assetId.ticker) + " Name=" + str(strName))
    return

@WINFUNCTYPE(None, TAssetID, c_double, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_uint, c_double)
def adjustHistoryCallbackV2(assetId, value, strType, strObserv, dtAjuste, dtDelib, dtPagamento, nFlags, dMult):
    print("todo - adjustHistoryCallbackV2")
    return

@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_wchar_p, c_int, c_int, c_int, c_int, c_int, c_double, c_double, c_wchar_p, c_wchar_p)
def assetListInfoCallback(assetId, strName, strDescription, iMinOrdQtd, iMaxOrdQtd, iLote, iSecurityType, iSecuritySubType, dMinPriceInc, dContractMult, strValidDate, strISIN):
    print('TAssetListInfoCallback = Ticker: ' + str(assetId.ticker) +
          'Name: ' + str(strName) +
          'Descrição: ' + str(strDescription))
    return

@WINFUNCTYPE(None, TAssetID, c_wchar_p, c_wchar_p, c_int, c_int, c_int, c_int, c_int, c_double, c_double, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p)
def assetListInfoCallbackV2(assetId, strName, strDescription, iMinOrdQtd, iMaxOrdQtd, iLote, iSecurityType, iSecuritySubType, dMinPriceInc, dContractMult, strValidDate, strISIN, strSetor, strSubSetor, strSegmento):
    print('TAssetListInfoCallbackV2 = Ticker: ' + str(assetId.ticker) +
          'Name: ' + str(strName) +
          'Descrição: ' + str(strDescription) +
          'Setor: ' + str(strSetor))
    return

@WINFUNCTYPE(None, TAssetID,
             c_int, c_int, c_int, c_int, c_int, c_int,
             c_double, c_double, c_double,
             c_longlong, 
             c_wchar_p, c_wchar_p , c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p)
def historyCallbackV2(rAssetID,
                    nCorretora, nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity,
                    sPrice, sStopPrice, sAvgPrice,
                    nProfitID,
                    tipoOrdem, conta, titular, clOrdID, status, creationDate, lastUpdateDate, closeDate, validityDate):
    global gOrders
    global rotPassword

    print('History callback V2: {0}, status={1}'.format(clOrdID, status))

    # Coloca ordem no dicionário para consulta posterior
    gOrders[str(clOrdID)] = TProfitOrder(
                    rAssetID,
                    clOrdID,
                    nProfitID,
                    conta,
                    nCorretora,
                    rotPassword,
                    sPrice,
                    sStopPrice,
                    nQtd,
                    status,
                    lastUpdateDate,
                    closeDate,
                    validityDate,
                    nValidity)
    return

@WINFUNCTYPE(None, TAssetID,
             c_int, c_int, c_int, c_int, c_int, c_int,
             c_double, c_double, c_double,
             c_longlong, 
             c_wchar_p, c_wchar_p , c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p)
def orderChangeCallbackV2(rAssetID,
                    nCorretora, nQtd, nTradedQtd, nLeavesQtd, nSide, nValidity,
                    sPrice, sStopPrice, sAvgPrice,
                    nProfitID,
                    tipoOrdem, conta, titular, clOrdID, status, creationDate, lastUpdateDate, closeDate, validityDate, textMessage):
    global gOrders
    global rotPassword

    print('Order change callback V2: {0}, status={1}'.format(clOrdID, status))

    # Coloca ordem no dicionário para consulta posterior
    gOrders[str(clOrdID)] = TProfitOrder(
                    rAssetID,
                    clOrdID,
                    nProfitID,
                    conta,
                    nCorretora,
                    rotPassword,
                    sPrice,
                    sStopPrice,
                    nQtd,
                    status,
                    lastUpdateDate,
                    closeDate,
                    validityDate,
                    nValidity)
    return
#END DEF

#EXEMPLOS
def SenSellOrder() :
    qtd = int(1)
    preco = float(100000)
    # precoStop = float(100000)
    nProfitID = profit_dll.SendSellOrder (c_wchar_p('CONTA'), c_wchar_p('BROKER'),
                                          c_wchar_p('PASS'),c_wchar_p('ATIVO'),
                                          c_wchar_p('BOLSA'),
                                          c_double(preco), c_int(qtd));

    print(str(nProfitID))

def wait_login():    
    global profit_dll
    global bMarketConnected
    global bAtivo

    bWaiting = True
    while bWaiting:        
        if bMarketConnected  :
            profit_dll.SetAssetListCallback(assetListCallback)
            profit_dll.SetAdjustHistoryCallbackV2(adjustHistoryCallbackV2)
            profit_dll.SetAssetListInfoCallback(assetListInfoCallback)
            profit_dll.SetAssetListInfoCallbackV2(assetListInfoCallbackV2)
            profit_dll.SetHistoryCallbackV2(historyCallbackV2)
            profit_dll.SetOrderChangeCallbackV2(orderChangeCallbackV2)
            print("DLL Conected")
            
            bWaiting = False
    print('stop waiting')

def subscribeOffer():
    global profit_dll
    print("subscribe offer book")

    asset = input('Asset: ')
    bolsa = input('Bolsa: ')

    result = profit_dll.SubscribeOfferBook(c_wchar_p(asset), c_wchar_p(bolsa))
    print ("SubscribeOfferBook: " + str(result))

def subscribeTicker():
    global profit_dll

    asset = input('Asset: ')
    bolsa = input('Bolsa: ')            
    
    result = profit_dll.SubscribeTicker(c_wchar_p(asset), c_wchar_p(bolsa))
    print ("SubscribeTicker: " + str(result))

def unsubscribeTicker():
    global profit_dll

    asset = input('Asset: ')
    bolsa = input('Bolsa: ')
    
    result = profit_dll.UnsubscribeTicker(c_wchar_p(asset), c_wchar_p(bolsa))
    print ("UnsubscribeTicker: " + str(result))    

def printLastAdjusted():
    global profit_dll
    close = c_double()
    result = profit_dll.GetLastDailyClose(c_wchar_p("MGLU3"), c_wchar_p("B"), byref(close), 1)
    print(f'Last session close: {close}, result={str(result)}')

def printPosition():
    global profit_dll

    asset = input('Asset: ')
    bolsa = input('Bolsa: ')
    corretora = input('Corretora: ')
    acc_id = input('AccountID: ')

    result = profit_dll.GetPosition(c_wchar_p(str(acc_id)), c_wchar_p(str(corretora)), c_wchar_p(asset), c_wchar_p(bolsa))

    n_qtd = result[0]

    if (n_qtd == 0):
        print('Nao ha posicao para esse ativo')
    else:
        n_tam = result[1]
        print(f"qtd: {n_qtd}, n_tam: {n_tam}")

        arr = cast(result, POINTER(c_char))
        frame = bytearray()
        for i in range(n_tam):
            c = arr[i]
            frame.append(c[0])
        
        start = 8

        for i in range(n_qtd):
            corretora_id = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            acc_id_length = struct.unpack('h', frame[start:start+2])[0]
            start += 2
            account_id = frame[start:start+acc_id_length]
            start += acc_id_length

            titular_length = struct.unpack('h', frame[start:start+2])[0]
            start += 2
            titular = frame[start:start+titular_length]
            start += titular_length

            ticker_length = struct.unpack('h', frame[start:start+2])[0]
            start += 2
            ticker = frame[start:start+ticker_length]
            start += ticker_length

            intraday_pos = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            price = struct.unpack('d', frame[start:start + 8])[0]
            start += 8

            avg_sell_price = struct.unpack('d', frame[start:start + 8])[0]
            start += 8

            sell_qtd = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            avg_buy_price = struct.unpack('d', frame[start:start + 8])[0]
            start += 8

            buy_qtd = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            custody_d1 = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            custody_d2 = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            custody_d3 = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            blocked = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            pending = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            allocated = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            provisioned = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            qtd_position = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            available = struct.unpack('i', frame[start:start+4])[0]
            start += 4

            print(f"Corretora: {corretora_id}, Titular: {str(titular)}, Ticker: {str(ticker)}, Price: {price}, AvgSellPrice: {avg_sell_price}, AvgBuyPrice: {avg_buy_price}, SellQtd: {sell_qtd}, BuyQtd: {buy_qtd}")

def dllStart():    
    try:
        global profit_dll
        key = input("Chave de acesso: ")
        user = input("Usuário: ") # preencher com usuário da conta (email ou documento)
        password = input("Senha: ") # preencher com senha da conta
        
        bRoteamento = True
        
        if bRoteamento :            
            result = profit_dll.DLLInitializeLogin(c_wchar_p(key), c_wchar_p(user), c_wchar_p(password), stateCallback, historyCallBack, orderChangeCallBack, accountCallback,
                                              newTradeCallback, newDailyCallback, priceBookCallback,
                                              offerBookCallback, newHistoryCallback, progressCallBack, newTinyBookCallBack)
        else :
            result = profit_dll.DLLInitializeMarketLogin(c_wchar_p(key), c_wchar_p(user), c_wchar_p(password), stateCallback, newTradeCallback, newDailyCallback, priceBookCallback,
                                                 offerBookCallback, newHistoryCallback, progressCallBack, newTinyBookCallBack)

        profit_dll.SendSellOrder.restype = c_longlong
        profit_dll.SendBuyOrder.restype = c_longlong
        profit_dll.SendStopBuyOrder.restype = c_longlong
        profit_dll.SendStopSellOrder.restype = c_longlong
        profit_dll.SendZeroPosition.restype = c_longlong
        profit_dll.GetAgentNameByID.restype = c_wchar_p
        profit_dll.GetAgentShortNameByID.restype = c_wchar_p
        profit_dll.GetPosition.restype = POINTER(c_int)
        profit_dll.SendMarketSellOrder.restype = c_longlong
        profit_dll.SendMarketBuyOrder.restype = c_longlong
        profit_dll.SendMarketSellOrder.restype = c_longlong
        profit_dll.SendMarketBuyOrder.restype = c_longlong

        print('DLLInitialize: ' + str(result))
        wait_login()
      
    except Exception as e:
        print(str(e))

def dllEnd():   
    global profit_dll
    result = profit_dll.DLLFinalize()

    print('DLLFinalize: ' + str(result))

# Funções de roteamento

rotPassword = '' # preencher com senha de roteamento
accountID   = '' # preencher com accountID
corretora   = '' # preencher com corretora

class TProfitOrder(Structure):
    _fields_ = [("assetId", TAssetID),
                ("clordid", c_wchar_p),
                ("profitid", c_longlong),
                ("accountID", c_wchar_p),
                ("corretora", c_int),
                ("rot_password", c_wchar_p),
                ("price", c_double),
                ("stop_price", c_double),
                ("amount", c_int),
                ("status", c_wchar_p),
                ("last_update_date", c_wchar_p),
                ("close_date", c_wchar_p),
                ("validity_date", c_wchar_p),
                ("validity", c_int)]

gOrders = {}

@WINFUNCTYPE(None, TAssetID,
             c_int, c_int, c_int, c_int, c_int,
             c_double, c_double, c_double,
             c_longlong, 
             c_wchar_p, c_wchar_p , c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p)
def historyCallBack(rAssetID,
                    nCorretora, nQtd, nTradedQtd, nLeavesQtd, Side,
                    sPrice, sStopPrice, sAvgPrice,
                    nProfitID,
                    tipoOrdem, conta, titular, clOrdID, status, date):
    global gOrders
    global rotPassword

    print('History callback: {0}, status={1}'.format(clOrdID, status))

    # Coloca ordem no dicionário para consulta posterior
    gOrders[str(clOrdID)] = TProfitOrder(
                    rAssetID,
                    clOrdID,
                    nProfitID,
                    conta, 
                    nCorretora, 
                    rotPassword, 
                    sPrice, 
                    sStopPrice,
                    nQtd,
                    status,
                    None,
                    None,
                    None,
                    -1)
    return

@WINFUNCTYPE(None, TAssetID,
             c_int, c_int, c_int, c_int, c_int,
             c_double, c_double, c_double,
             c_longlong, 
             c_wchar_p, c_wchar_p , c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p)
def orderChangeCallBack(rAssetID,
                        nCorretora, nQtd, nTradedQtd, nLeavesQtd, Side, sPrice, sStopPrice, sAvgPrice,
                        nProfitID, tipoOrdem, conta, titular, clOrdID, status, date, textMessage):
    global gOrders
    global rotPassword

    print('Order change callback: {0}, status={1}'.format(clOrdID, status))

    # Coloca ordem no dicionário para consulta posterior
    gOrders[str(clOrdID)] = TProfitOrder(
                    rAssetID,
                    clOrdID,
                    nProfitID,
                    conta, 
                    nCorretora, 
                    rotPassword, 
                    sPrice, 
                    sStopPrice,
                    nQtd,
                    status,
                    None,
                    None,
                    None,
                    -1)
    return

def buyStopOrder():
    global accountID
    global rotPassword
    global corretora

    price = ""
    stop_price = ""

    asset = input('Ativo: ')
    #asset = 'PETR4'

    bolsa = input('Bolsa: ')
    #bolsa = 'B'

    price = input('Price: ')
    #price = '31.50'

    stopPrice = input('Stop price: ')
    #stopPrice = '31.25'

    amount = input('Quantidade: ')
    #amount = 100

    print("Enviando ordem stop compra em {1} offset={0}".format(price, stopPrice))
    profit_dll.SendStopBuyOrder.argtypes = [
        c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_double, c_double, c_int
    ]
    profitID = profit_dll.SendStopBuyOrder(
        c_wchar_p(accountID), 
        c_wchar_p(corretora), 
        c_wchar_p(rotPassword), 
        c_wchar_p(asset), 
        c_wchar_p(bolsa), 
        c_double(float(price)), 
        c_double(float(stopPrice)),
        c_int(int(amount)))

def sellStopOrder():
    global accountID
    global rotPassword
    global corretora

    price = ""
    stop_price = ""

    asset = input('Ativo: ')
    #asset = 'PETR4'

    bolsa = input('Bolsa: ')
    #bolsa = 'B'

    price = input('Price: ')
    #price = '31.50'

    stopPrice = input('Stop price: ')
    #stopPrice = '31.25'

    amount = input('Quantidade: ')
    #amount = 100

    print("Enviando ordem stop venda em {1} offset={0}".format(price, stopPrice))
    profit_dll.SendStopSellOrder.argtypes = [
        c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_wchar_p, c_double, c_double, c_int
    ]
    profitID = profit_dll.SendStopSellOrder(
        c_wchar_p(accountID), 
        c_wchar_p(corretora), 
        c_wchar_p(rotPassword), 
        c_wchar_p(asset), 
        c_wchar_p(bolsa), 
        c_double(float(price)), 
        c_double(float(stopPrice)),
        c_int(int(amount)))

def sendBuyMarketOrder(): 
    global accountID
    global rotPassword
    global corretora
    asset = input('Ativo: ')   # asset = 'PETR4'
    bolsa = input('Bolsa: ')   # bolsa = B
    amount = input('Quantidade: ')

    nProfitID = profit_dll.SendMarketBuyOrder(
        c_wchar_p(accountID), 
        c_wchar_p(corretora), 
        c_wchar_p(rotPassword), 
        c_wchar_p(asset), 
        c_wchar_p(bolsa),
        c_int(int(amount)))
    print(str(nProfitID))

def sendSellMarketOrder(): 
    global accountID
    global rotPassword
    global corretora
    asset = input('Ativo: ')   # asset = 'PETR4'
    bolsa = input('Bolsa: ')   # bolsa = B
    amount = input('Quantidade: ')

    nProfitID = profit_dll.SendMarketSellOrder(
        c_wchar_p(accountID), 
        c_wchar_p(corretora), 
        c_wchar_p(rotPassword), 
        c_wchar_p(asset), 
        c_wchar_p(bolsa),
        c_int(int(amount)))
    print(str(nProfitID))

def getOrders():
    global accountID
    global corretora

    now = datetime.now()
    tomorrow = datetime.now() + timedelta(days=1)

    # retorno em historyCallback
    profit_dll.GetOrders(
        c_wchar_p(accountID), 
        c_wchar_p(corretora), 
        c_wchar_p(now.strftime("%d/%m/%Y")),
        c_wchar_p(tomorrow.strftime("%d/%m/%Y")))

def getOrder():
    global accountID
    global corretora

    clord = input('Insira uma ordem (clOrdID): ')

    # retorno em orderChangeCallback
    profit_dll.GetOrder(c_wchar_p(clord))

def getOrderProfitID():
    global accountID
    global corretora

    pid = int(input('Insira uma ordem (ProfitID): '))

    # retorno em orderChangeCallback
    profit_dll.GetOrderProfitID(c_longlong(pid))

def selectOrder():
    global gOrders
    
    if len(gOrders.keys()) > 0:
        print("selecione uma ordem")
        i = 0
        for key, value in gOrders.items():
            print('{0}. ProfitID={1} ClordID={2}, price={3}, amount={4}, status={5}'.format(i, value.profitid, value.clordid, value.price, value.amount, value.status))
            i += 1

        print('-1. Cancelar')
        
        if (choice := int(input())) != -1:
            listOrders = list(gOrders.items())
            return listOrders[choice][1]
    else:
        print("nao ha ordens para selecionar")

    return None

def cancelOrder():
    global accountID
    global corretora
    global rotPassword

    order = selectOrder()
    if order != None:
        print('Cancelando ordem {0}'.format(order.clordid))
        profit_dll.SendCancelOrder(c_wchar_p(accountID), c_wchar_p(corretora), order.clordid, c_wchar_p(rotPassword))

def cancelAllOrders():
    global accountID
    global corretora
    global rotPassword
    profit_dll.SendCancelAllOrders(accountID, corretora, rotPassword)

def changeOrder():
    global accountID
    global corretora
    global rotPassword

    order = selectOrder()

    price = float(input('Insira novo preço: '))
    amount = int(input('Insira nova quantidade: '))
    profit_dll.SendChangeOrder(c_wchar_p(accountID), c_wchar_p(corretora), c_wchar_p(rotPassword), order.clordid, c_double(price), c_wchar_p(amount))

def getAccount():
    # retorno em TAccountCallback
    profit_dll.GetAccount(); 

if __name__ == '__main__':
    dllStart()

    strInput = ""
    while strInput != "exit":
        strInput = input('Insira o comando: ')
        if strInput == 'subscribe' :
            subscribeTicker()
        elif strInput == 'unsubscribe':
            unsubscribeTicker()
        elif strInput == 'offerbook':
            subscribeOffer()
        elif strInput == 'position':
            printPosition()
        elif strInput == 'lastAdjusted':
            printLastAdjusted()
        elif strInput == 'buystop' :
            buyStopOrder()
        elif strInput == 'sellstop':
            sellStopOrder()
        elif strInput == 'cancel':
            cancelOrder()
        elif strInput == 'changeOrder':
            changeOrder()
        elif strInput == 'cancelAllOrders':
            cancelAllOrders()
        elif strInput == 'getOrders':
            getOrders()
        elif strInput == 'getOrder':
            getOrder()
        elif strInput == 'selectOrder':
            selectOrder()
        elif strInput == 'cancelOrder':
            cancelOrder()
        elif strInput == 'getOrderProfitID':
            getOrderProfitID()
        elif strInput == 'getAccount':
            getAccount()
        elif strInput == 'sellAtMarket':
            sendSellMarketOrder()
        elif strInput == 'buyAtMarket':
            sendBuyMarketOrder()    

    dllEnd()