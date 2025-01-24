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
unit ConnectorInterfaceMarketU;

interface
uses
  System.Generics.Collections,Classes;

type
 {
  Conversão de bolsas
  BCB       = 'A';
  Bovespa   = 'B';
  CBOT      = 'C';
  Economic  = 'E';
  BMF       = 'F';
  CME       = 'M';
  Nymex     = 'N';
  Comex     = 'O';
  Pioneer   = 'P';
  SP        = 'S';
  DowJones  = 'X';
  Nyse      = 'Y';
  Cambio    = 'D';
  Unknown   = ' ';
 }

  //////////////////////////////////////////////////////////////////////////////
  // Enums
  //nResult : connStMarket
  TConnMarketDataState = (
    ConncsDisconnected       = 0,
    ConncsConnecting         = 1,
    ConncsConnectedWaiting   = 2,
    ConncsConnectedNotLogged = 3,
    ConncsConnectedLogged    = 4
    );

  //nResult : connStLogin and connStActv
  TConnAuthenticationResult = (
    connArSuccess=0,
    connArLoginInvalid=1,
    connArPasswordInvalid=2,
    aconnArPasswordBlocked=3,
    connArPasswordExpired=4,
    connArUnknown=200);

  //nResult : connStBroker
  TConnBrokerConnectionState = (
    ConnHcsDisconnected=0,
    ConnHcsConnecting=1,
    ConnHcsConnected=2,
    ConnHcsBrokerDisconnected=3,
    ConnHcsBrokerConnecting=4,
    ConnHcsBrokerConnected=5
    );

  TConnTradeType = (
    ttUnknown         = 32,
    ttCrossTrade      = 1,
    ttAggressorBuyer  = 2,
    ttAggressorSeller = 3,
    ttAuction         = 4,
    ttSurveillance    = 5,
    ttExpit           = 6,
    ttOptionExercise  = 7,
    ttOverTheCounter  = 8,
    ttDerivativeTerm  = 9,
    ttIndex           = 10,
    ttBTC             = 11,
    ttOnBehalf        = 12,
    ttRLP             = 13
    );

   TConnStateType = (connStLogin, connStBroker, connStMarket, connStActv);
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

  TypeChangeState = (tcsOpened=0, tcsSuspended=1, tcsFrozen=2, tcsInhibited=3, tcsAuctioned=4, tcsOpenReprogramed=5,
                     tcsClosed=6, tcsUnknown=7, tcsNightProcess=8, tcsPreparation=9, tcsPreClosing=10, tcsPromoter=11,
                     tcsEODConsulting=12, tcsPreOpening=13, tcsAfterMarket=14,tcsTrading=15,tcsImpedido=16,tcsBovespa=17,
                     tcsInterrupted=18, tcsNone=255);

  // #Records
  //////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  // Callbacks
  TStateCallback           = procedure( nConnStateType , nResult : Integer)stdcall;

  TAssetListCallback       = procedure(rAssetID  : TAssetIDRec; pwcName : PWideChar) stdcall;

  TAssetListInfoCallback                           = procedure(rAssetID  : TAssetIDRec;
                                                 strName, strDescription : PWideChar;
    nMinOrderQtd, nMaxOrderQtd, nLote, stSecurityType, ssSecuritySubType : Integer;
                                 sMinPriceIncrement, sContractMultiplier : Double;
                                                                 strDate : PWideChar) stdcall;

  TChangeCotation          = procedure(rAssetID  : TAssetIDRec;
                                        pwcDate   : PWideChar;
                                           sPrice : Double) stdcall;

  TChangeStateTicker       = procedure(rAssetID   : TAssetIDRec;
                                        pwcDate   : PWideChar;
                                           nState : Integer) stdcall;


  TNewTradeCallback        = procedure(rAssetID   : TAssetIDRec;
                                        pwcDate   : PWideChar;
                                    sPrice, sVol  : Double;
         nQtd, nBuyAgent, nSellAgent, nTradeType  : Integer;
                                          bIsEdit : Char) stdcall;

  THistoryTradeCallback    = procedure(rAssetID   : TAssetIDRec;
                                        pwcDate   : PWideChar;
                                    sPrice, sVol  : Double;
         nQtd, nBuyAgent, nSellAgent, nTradeType  : Integer) stdcall;

  TAdjustHistoryCallback   = procedure(                rAssetID  : TAssetIDRec;
                                                       sValue    : Double;
      strAdjustType, strObserv, dtAjuste, dtDeliber, dtPagamento : PWideChar;
                                                    nAffectPrice : Integer) stdcall;

  TNewDailyCallback        = procedure(                                           rAssetID : TAssetIDRec;
                                                                                   pwcDate : PWideChar;
    sOpen, sHigh, sLow, sClose, sVol, sAjuste, sMaxLimit, sMinLimit, sVolBuyer, sVolSeller : Double;
             nQtd, nNegocios, nContratosOpen, nQtdBuyer, nQtdSeller, nNegBuyer, nNegSeller : Integer) stdcall;

  TPriceBookCallback        = procedure (          rAssetID : TAssetIDRec ;
                   nAction , nPosition, Side, nQtds, nCount : Integer;
                                                     sPrice : Double;
                                      pArraySell, pArrayBuy : Pointer) stdcall;

  TOfferBookCallback        = procedure (          rAssetID : TAssetIDRec ;
                     nAction, nPosition, Side, nQtd, nAgent : Integer;
                                                   nOfferID : Int64;
                                                     sPrice : Double;
       bHasPrice, bHasQtd, bHasDate, bHasOfferID, bHasAgent : Char;
                                                   pwcDate  : PWideChar;
                                      pArraySell, pArrayBuy : Pointer) stdcall;

  TTinyBookCallback        = procedure(rAssetID  : TAssetIDRec;
                                       sPrice    : Double;
                                     nQtd, nSide : Integer) stdcall;

  TProgressCallback         = procedure ( rAssetID  : TAssetIDRec ;
                                          nProgress : Integer) stdcall;

  // #Callbacks
  //////////////////////////////////////////////////////////////////////////////

const
  c_strDateFormat = 'dd/mm/yyyy hh:nn:ss.zzz';

  //////////////////////////////////////////////////////////////////////////////
  // Error Codes
  NL_OK                 = 000;     // OK
  NL_LOGIN_INVALID      = [1..4];  // LOGIN INVALID
  NL_ERR_INIT           = 080;     // Not initialized
  NL_ERR_INVALID_ARGS   = 090;     // Invalid arguments
  NL_ERR_INTERNAL_ERROR = 100;     // Internal error
  // #Error Codes
  //////////////////////////////////////////////////////////////////////////////

implementation

end.
