unit callbackTypeU;

interface

uses
  structs;

type
// Callbacks //
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

implementation

end.
