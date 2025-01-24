//******************************************************************************
//
//       Nome: ConnectorInterfaceU
//  Descrição: Define interface para a biblioteca, com declaração de registros e
//             tipos estáticos presentes na interface
//
//    Criação:
// Modificado:
//
//******************************************************************************
unit ConnectorInterfaceU;

{$I KoT.inc}

interface
uses
  System.Generics.Collections,
  System.Classes,
  HadesBasicDataTypesU,
  ConnectionDataTypesU,
  TDataFormat;

type
  NResult = Integer; // Nelogica Result

  //////////////////////////////////////////////////////////////////////////////
  // Enums
  TMarketDataConnectionState = ConnectionDataTypesU.ConnectionState;

  TAuthenticationResult = HadesBasicDataTypesU.TAuthenticationResult;

  TBrokerConnectionState = HadesBasicDataTypesU.TBrokerConnectionState;

  TConnActivationResult = (
    connActivatValid    = 0,
    connActivatInvalid  = 1
  );

  TConnTradeType = TDataFormat.TTradeType;

  TConnStateType = (
    connStLogin         = 0, // Info
    connStBroker        = 1, // Hades
    connStMarket        = 2, // Mercury
    connStActv          = 3,

    connStUnknown       = 255
  );

  TypeChangeState = (tcsOpened=0, tcsSuspended=1, tcsFrozen=2, tcsInhibited=3, tcsAuctioned=4, tcsOpenReprogramed=5,
                     tcsClosed=6, tcsUnknown=7, tcsNightProcess=8, tcsPreparation=9, tcsPreClosing=10, tcsPromoter=11,
                     tcsEODConsulting=12, tcsPreOpening=13, tcsAfterMarket=14,tcsTrading=15,tcsImpedido=16,tcsBovespa=17,
                     tcsInterrupted=18, tcsNone=255);

  TValidityType = HadesBasicDataTypesU.TBrokerTimeInForce;
  // #Enums

  //////////////////////////////////////////////////////////////////////////////
  // Records
  ////////////////////////////////////////////////////////////////////////////
  // Asset Identifier
  PAssetIDRec = ^TAssetIDRec;
  TAssetIDRec = packed record
    pchTicker : PWideChar;
    pchBolsa  : PWideChar;
    nFeed     : Integer;
  end;

  PDataSerieIDRec = ^TDataSerieIDRec;
  TDataSerieIDRec = packed record
    pchTicker      : PWideChar;
    pchBolsa       : PWideChar;
    nFeed          : Integer;
    Level          : Integer;
    Offset         : Integer;
    Factor         : Integer;
    HasAfterMarket : Char;
    Adjusted       : Char;
  end;

  PAccountRec = ^TAccountRec;
  TAccountRec = packed record
    pchAccountID ,  pchTitular, pchNomeCorretora : PWideChar;
    nCorretoraID : Integer;
  end;

  PPositionRec = ^TPositionRec;
  TPositionRec = packed record
    //Utilizado por todas posicoes
    CorretoraId             : Integer;
    Conta, Titular, Ticker  : PWideChar;

    //Custodia
    QtdD1, QtdD2, QtdD3, QtdBloq,
    QtdPend, QtdAlloc, QtdProv,
    QtdDisp , CarteiraId    : Integer;
    DescCarteira            : PWideChar;

    //Posição aberta no Intraday
    Qtd, QtdBuy, QtdSell    : Integer;
    AvgPriceIntraday        : Double;

    //Posição no dia
    AvgPriceSellToday, AvgPriceBuyToday : Double;
  end;

  POrderRec = ^TOrderRec;
  TOrderRec = packed record
    CorretoraId, Qtd                                    : Integer;
    Price, AvgPrice                                     : Double;
    Conta, Titular, ClOrdID, Status, Ticker, Date, Side : PWideChar;
  end;

  TradeRec = record
    TAssetIDRec   : TAssetIDRec;
    dtDate        : TDateTime;
    sPrice, sVol  : Double;
    nQtd, nBuyAgent, nSellAgent, nTradeType  : Integer;
  end;
  PTradeRec = ^TradeRec;

  // #Records
  //////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  // Callbacks
  TStateCallback = procedure(
    nStateType : Integer;
    nActResult : Integer
  ) stdcall;

  TAssetListCallback = procedure(
    rAssetID : TAssetIDRec;
    pwcName  : PWideChar
  ) stdcall;

  TAssetListInfoCallback = procedure(
    rAssetID            : TAssetIDRec;
    strName             : PWideChar;
    strDescription      : PWideChar;
    nMinOrderQtd        : Integer;
    nMaxOrderQtd        : Integer;
    nLote               : Integer;
    stSecurityType      : Integer;
    ssSecuritySubType   : Integer;
    sMinPriceIncrement  : Double;
    sContractMultiplier : Double;
    strDate             : PWideChar;
    strISIN             : PWideChar
  ) stdcall;

  TAssetListInfoCallbackV2 = procedure(
    rAssetID            : TAssetIDRec;
    strName             : PWideChar;
    strDescription      : PWideChar;
    nMinOrderQtd        : Integer;
    nMaxOrderQtd        : Integer;
    nLote               : Integer;
    stSecurityType      : Integer;
    ssSecuritySubType   : Integer;
    sMinPriceIncrement  : Double;
    sContractMultiplier : Double;
    strDate             : PWideChar;
    strISIN             : PWideChar;
    strSetor            : PWideChar;
    strSubSetor         : PWideChar;
    strSegmento         : PWideChar
  ) stdcall;

  TChangeCotation = procedure(
    rAssetID     : TAssetIDRec;
    pwcDate      : PWideChar;
    nTradeNumber : Cardinal;
    sPrice       : Double
  ) stdcall;

  TChangeStateTicker = procedure(
    rAssetID : TAssetIDRec;
    pwcDate  : PWideChar;
    nState   : Integer
  ) stdcall;

  TTradeCallback = procedure(
    rAssetID     : TAssetIDRec;
    pwcDate      : PWideChar;
    nTradeNumber : Cardinal;
    sPrice       : Double;
    sVol         : Double;
    nQtd         : Integer;
    nBuyAgent    : Integer;
    nSellAgent   : Integer;
    nTradeType   : Integer;
    bIsEdit      : Char
  ) stdcall;

  THistoryTradeCallback = procedure(
    rAssetID     : TAssetIDRec;
    pwcDate      : PWideChar;
    nTradeNumber : Cardinal;
    sPrice       : Double;
    sVol         : Double;
    nQtd         : Integer;
    nBuyAgent    : Integer;
    nSellAgent   : Integer;
    nTradeType   : Integer
  ) stdcall;

  TTinyBookCallback = procedure(
    rAssetID : TAssetIDRec;
    sPrice   : Double;
    nQtd     : Integer;
    nSide    : Integer
  ) stdcall;

  TAdjustHistoryCallback = procedure(
    rAssetID      : TAssetIDRec;
    sValue        : Double;
    strAdjustType : PWideChar;
    strObserv     : PWideChar;
    dtAjuste      : PWideChar;
    dtDeliber     : PWideChar;
    dtPagamento   : PWideChar;
    nAffectPrice  : Integer
  ) stdcall;

  TAdjustHistoryCallbackV2 = procedure(
    rAssetID     : TAssetIDRec;
    sValue       : Double;
    strAdjustType: PWideChar;
    strObserv    : PWideChar;
    dtAjuste     : PWideChar;
    dtDeliber    : PWideChar;
    dtPagamento  : PWideChar;
    nFlags       : Cardinal;
    dMult        : Double
  ) stdcall;

  TDailyCallback = procedure(
    rAssetID       : TAssetIDRec;
    pwcDate        : PWideChar;
    sOpen          : Double;
    sHigh          : Double;
    sLow           : Double;
    sClose         : Double;
    sVol           : Double;
    sAjuste        : Double;
    sMaxLimit      : Double;
    sMinLimit      : Double;
    sVolBuyer      : Double;
    sVolSeller     : Double;
    nQtd           : Integer;
    nNegocios      : Integer;
    nContratosOpen : Integer;
    nQtdBuyer      : Integer;
    nQtdSeller     : Integer;
    nNegBuyer      : Integer;
    nNegSeller     : Integer
  ) stdcall;

  THistoryCallback = procedure(
    rAssetID   : TAssetIDRec;
    nCorretora : Integer;
    nQtd       : Integer;
    nTradedQtd : Integer;
    nLeavesQtd : Integer;
    nSide      : Integer;
    sPrice     : Double;
    sStopPrice : Double;
    sAvgPrice  : Double;
    nProfitID  : Int64;
    TipoOrdem  : PWideChar;
    Conta      : PWideChar;
    Titular    : PWideChar;
    ClOrdID    : PWideChar;
    Status     : PWideChar;
    Date       : PWideChar
  ) stdcall;

  THistoryCallbackV2 = procedure(
    rAssetID     : TAssetIDRec;
    nCorretora   : Integer;
    nQtd         : Integer;
    nTradedQtd   : Integer;
    nLeavesQtd   : Integer;
    nSide        : Integer;
    nValidity    : Integer;
    sPrice       : Double;
    sStopPrice   : Double;
    sAvgPrice    : Double;
    nProfitID    : Int64;
    TipoOrdem    : PWideChar;
    Conta        : PWideChar;
    Titular      : PWideChar;
    ClOrdID      : PWideChar;
    Status       : PWideChar;
    Date         : PWideChar;
    LastUpdate   : PWideChar;
    CloseDate    : PWideChar;
    ValidityDate : PWideChar
  ) stdcall;

  TOrderChangeCallback = procedure(
    rAssetID    : TAssetIDRec;
    nCorretora  : Integer;
    nQtd        : Integer;
    nTradedQtd  : Integer;
    nLeavesQtd  : Integer;
    nSide       : Integer;
    sPrice      : Double;
    sStopPrice  : Double;
    sAvgPrice   : Double;
    nProfitID   : Int64;
    TipoOrdem   : PWideChar;
    Conta       : PWideChar;
    Titular     : PWideChar;
    ClOrdID     : PWideChar;
    Status      : PWideChar;
    Date        : PWideChar;
    TextMessage : PWideChar
  ) stdcall;

  TOrderChangeCallbackV2 = procedure(
    rAssetID     : TAssetIDRec;
    nCorretora   : Integer;
    nQtd         : Integer;
    nTradedQtd   : Integer;
    nLeavesQtd   : Integer;
    nSide        : Integer;
    nValidity    : Integer;
    sPrice       : Double;
    sStopPrice   : Double;
    sAvgPrice    : Double;
    nProfitID    : Int64;
    TipoOrdem    : PWideChar;
    Conta        : PWideChar;
    Titular      : PWideChar;
    ClOrdID      : PWideChar;
    Status       : PWideChar;
    Date         : PWideChar;
    LastUpdate   : PWideChar;
    CloseDate    : PWideChar;
    ValidityDate : PWideChar;
    TextMessage  : PWideChar
  ) stdcall;

  TAccountCallback = procedure(
    nCorretora            : Integer;
    CorretoraNomeCompleto : PWideChar;
    AccountID             : PWideChar;
    NomeTitular           : PWideChar
  ) stdcall;

  TPriceBookCallback = procedure(
    rAssetID   : TAssetIDRec ;
    nAction    : Integer;
    nPosition  : Integer;
    Side       : Integer;
    nQtds      : Integer;
    nCount     : Integer;
    sPrice     : Double;
    pArraySell : Pointer;
    pArrayBuy  : Pointer
  ) stdcall;

  // PriceBookV2 usa um formato diferente no ponteiro
  TPriceBookCallbackV2 = procedure(
    rAssetID   : TAssetIDRec ;
    nAction    : Integer;
    nPosition  : Integer;
    Side       : Integer;
    nQtds      : Int64;
    nCount     : Int64;
    sPrice     : Double;
    pArraySell : Pointer;
    pArrayBuy  : Pointer
  ) stdcall;

  TOfferBookCallback = procedure(
    rAssetID    : TAssetIDRec;
    nAction     : Integer;
    nPosition   : Integer;
    Side        : Integer;
    nQtd        : Integer;
    nAgent      : Integer;
    nOfferID    : Int64;
    sPrice      : Double;
    bHasPrice   : Char;
    bHasQtd     : Char;
    bHasDate    : Char;
    bHasOfferID : Char;
    bHasAgent   : Char;
    pwcDate     : PWideChar;
    pArraySell  : Pointer;
    pArrayBuy   : Pointer
  ) stdcall;

  // OfferBookV2 usa um formato diferente no ponteiro
  TOfferBookCallbackV2 = procedure(
    rAssetID    : TAssetIDRec;
    nAction     : Integer;
    nPosition   : Integer;
    Side        : Integer;
    nQtd        : Int64;
    nAgent      : Integer;
    nOfferID    : Int64;
    sPrice      : Double;
    bHasPrice   : Char;
    bHasQtd     : Char;
    bHasDate    : Char;
    bHasOfferID : Char;
    bHasAgent   : Char;
    pwcDate     : PWideChar;
    pArraySell  : Pointer;
    pArrayBuy   : Pointer
  ) stdcall;

  TTheoreticalPriceCallback = procedure(
    rAssetID          : TAssetIDRec;
    dTheoreticalPrice : Double;
    nTheoreticalQtd   : Int64
  ) stdcall;

  TProgressCallback = procedure(
    rAssetID  : TAssetIDRec;
    nProgress : Integer
  ) stdcall;

  // #Callbacks
  //////////////////////////////////////////////////////////////////////////////

const
  c_strDateFormat = 'dd/mm/yyyy hh:nn:ss.zzz';

  NL_OK                 = NResult($00000000);  // OK
  NL_INTERNAL_ERROR     = NResult($80000001);  // Internal error
  NL_NOT_INITIALIZED    = NResult($80000002);  // Not initialized
  NL_INVALID_ARGS       = NResult($80000003);  // Invalid arguments
  NL_WAITING_SERVER     = NResult($80000004);  // Aguardando dados do servidor

implementation

end.
